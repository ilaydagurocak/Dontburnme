import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

enum PersonCutoutError: LocalizedError {

    case imageCouldNotBePrepared
    case personNotFound
    case maskCouldNotBeCreated
    case outputCouldNotBeCreated


    var errorDescription: String? {

        switch self {

        case .imageCouldNotBePrepared:
            return "Fotoğraf hazırlanamadı."

        case .personNotFound:
            return "Fotoğrafta bir kişi algılanamadı."

        case .maskCouldNotBeCreated:
            return "Kişi maskesi oluşturulamadı."

        case .outputCouldNotBeCreated:
            return "Karakter görseli oluşturulamadı."
        }
    }
}


@available(iOS 15.0, *)
final class PersonCutoutManager {

    static let shared =
        PersonCutoutManager()


    private let ciContext =
        CIContext(
            options: [
                .cacheIntermediates: false
            ]
        )


    private init() {}


    // MARK: - Main Function

    func makePersonCutout(
        from originalImage: UIImage
    ) throws -> UIImage {

        /*
         Önce fotoğrafı:
         - orientation olarak düzelt
         - çok büyükse küçült

         Böylece Vision daha hızlı çalışır.
         */

        let preparedImage =
            prepareImage(
                originalImage,
                maxDimension: 1600
            )


        guard let cgImage =
                preparedImage.cgImage else {

            throw PersonCutoutError
                .imageCouldNotBePrepared
        }


        // MARK: Person Segmentation

        let request =
            VNGeneratePersonSegmentationRequest()


        request.qualityLevel =
        .accurate


        request.outputPixelFormat =
        kCVPixelFormatType_OneComponent8


        let handler =
            VNImageRequestHandler(
                cgImage: cgImage,
                orientation: .up,
                options: [:]
            )


        do {

            try handler.perform(
                [request]
            )

        } catch {

            throw error
        }


        guard let observation =
                request.results?.first else {

            throw PersonCutoutError
                .personNotFound
        }


        let maskBuffer =
            observation.pixelBuffer


        // Mask içinde gerçekten kişi var mı?
        guard let maskBoundingBox =
                boundingBoxOfPerson(
                    in: maskBuffer
                ) else {

            throw PersonCutoutError
                .personNotFound
        }


        // MARK: Core Image

        let inputImage =
            CIImage(
                cgImage: cgImage
            )


        var maskImage =
            CIImage(
                cvPixelBuffer:
                    maskBuffer
            )


        /*
         Vision maskesi fotoğraftan daha küçük
         çözünürlükte gelebilir.

         Maskeyi gerçek fotoğraf boyutuna
         büyütüyoruz.
         */

        let scaleX =
            inputImage.extent.width /
            maskImage.extent.width


        let scaleY =
            inputImage.extent.height /
            maskImage.extent.height


        maskImage =
            maskImage.transformed(
                by:
                    CGAffineTransform(
                        scaleX: scaleX,
                        y: scaleY
                    )
            )


        maskImage =
            maskImage.cropped(
                to:
                    inputImage.extent
            )


        /*
         Kenarların çok sert görünmemesi için
         maskeye minicik yumuşatma.
         */

        maskImage =
            maskImage
                .applyingFilter(
                    "CIGaussianBlur",
                    parameters: [
                        kCIInputRadiusKey: 0.8
                    ]
                )
                .cropped(
                    to:
                        inputImage.extent
                )


        // Tam şeffaf arka plan

        let transparentBackground =
            CIImage(
                color:
                    CIColor(
                        red: 0,
                        green: 0,
                        blue: 0,
                        alpha: 0
                    )
            )
            .cropped(
                to:
                    inputImage.extent
            )


        // MARK: Person + Transparent Background

        let blendFilter =
            CIFilter.blendWithMask()


        blendFilter.inputImage =
        inputImage


        blendFilter.backgroundImage =
        transparentBackground


        blendFilter.maskImage =
        maskImage


        guard let outputImage =
                blendFilter.outputImage else {

            throw PersonCutoutError
                .maskCouldNotBeCreated
        }


        // MARK: Crop

        /*
         Kişinin etrafındaki gereksiz
         boş alanları da kesiyoruz.
         */

        let cropRect =
            cropRectForPerson(
                maskBoundingBox:
                    maskBoundingBox,

                maskSize:
                    CGSize(
                        width:
                            CVPixelBufferGetWidth(
                                maskBuffer
                            ),

                        height:
                            CVPixelBufferGetHeight(
                                maskBuffer
                            )
                    ),

                imageExtent:
                    inputImage.extent
            )


        guard
            cropRect.width > 1,
            cropRect.height > 1,

            let outputCGImage =
                ciContext.createCGImage(
                    outputImage,
                    from: cropRect
                )

        else {

            throw PersonCutoutError
                .outputCouldNotBeCreated
        }


        let finalImage =
            UIImage(
                cgImage:
                    outputCGImage,

                scale:
                    1,

                orientation:
                    .up
            )


        return finalImage
    }


    // MARK: - Find Person Bounds

    private func boundingBoxOfPerson(
        in pixelBuffer: CVPixelBuffer
    ) -> CGRect? {

        CVPixelBufferLockBaseAddress(
            pixelBuffer,
            .readOnly
        )


        defer {

            CVPixelBufferUnlockBaseAddress(
                pixelBuffer,
                .readOnly
            )
        }


        guard let baseAddress =
                CVPixelBufferGetBaseAddress(
                    pixelBuffer
                ) else {

            return nil
        }


        let width =
            CVPixelBufferGetWidth(
                pixelBuffer
            )


        let height =
            CVPixelBufferGetHeight(
                pixelBuffer
            )


        let bytesPerRow =
            CVPixelBufferGetBytesPerRow(
                pixelBuffer
            )


        let pixels =
            baseAddress
                .assumingMemoryBound(
                    to: UInt8.self
                )


        var minX =
        width


        var minY =
        height


        var maxX =
        -1


        var maxY =
        -1


        /*
         0 = tamamen background
         255 = tamamen person

         20 gibi düşük threshold kullanıyoruz
         ki saç / el / ayak kenarları kesilmesin.
         */

        let threshold:
        UInt8 = 20


        for y in 0..<height {

            let row =
                pixels.advanced(
                    by:
                        y * bytesPerRow
                )


            for x in 0..<width {

                let value =
                row[x]


                if value > threshold {

                    minX =
                    min(minX, x)

                    minY =
                    min(minY, y)

                    maxX =
                    max(maxX, x)

                    maxY =
                    max(maxY, y)
                }
            }
        }


        guard
            maxX >= minX,
            maxY >= minY

        else {

            return nil
        }


        return CGRect(
            x:
                CGFloat(minX),

            y:
                CGFloat(minY),

            width:
                CGFloat(
                    maxX - minX + 1
                ),

            height:
                CGFloat(
                    maxY - minY + 1
                )
        )
    }


    // MARK: - Convert Mask Bounds to Image Bounds

    private func cropRectForPerson(
        maskBoundingBox: CGRect,
        maskSize: CGSize,
        imageExtent: CGRect
    ) -> CGRect {

        guard
            maskSize.width > 0,
            maskSize.height > 0

        else {

            return imageExtent
        }


        let scaleX =
            imageExtent.width /
            maskSize.width


        let scaleY =
            imageExtent.height /
            maskSize.height


        /*
         CVPixelBuffer ve Core Image'ın
         Y koordinat yönleri farklı olduğu için
         burada Y'yi ters çeviriyoruz.
         */

        let x =
            maskBoundingBox.minX *
            scaleX


        let width =
            maskBoundingBox.width *
            scaleX


        let height =
            maskBoundingBox.height *
            scaleY


        let y =
            imageExtent.height -
            (
                maskBoundingBox.maxY *
                scaleY
            )


        var personRect =
            CGRect(
                x: x,
                y: y,
                width: width,
                height: height
            )


        /*
         Kafa, saç, ayakkabı gibi alanların
         kesilmemesi için biraz padding.
         */

        let horizontalPadding =
            personRect.width *
            0.07


        let verticalPadding =
            personRect.height *
            0.06


        personRect =
            personRect.insetBy(
                dx:
                    -horizontalPadding,

                dy:
                    -verticalPadding
            )


        return personRect
            .intersection(
                imageExtent
            )
    }


    // MARK: - Prepare Image

    private func prepareImage(
        _ image: UIImage,
        maxDimension: CGFloat
    ) -> UIImage {

        let normalized =
            normalizeOrientation(
                image
            )


        let originalSize =
            normalized.size


        let largestDimension =
            max(
                originalSize.width,
                originalSize.height
            )


        guard
            largestDimension >
            maxDimension

        else {

            return normalized
        }


        let scale =
            maxDimension /
            largestDimension


        let newSize =
            CGSize(
                width:
                    originalSize.width *
                    scale,

                height:
                    originalSize.height *
                    scale
            )


        let format =
            UIGraphicsImageRendererFormat()


        format.scale =
        1


        format.opaque =
        false


        let renderer =
            UIGraphicsImageRenderer(
                size:
                    newSize,

                format:
                    format
            )


        return renderer.image { _ in

            normalized.draw(
                in:
                    CGRect(
                        origin:
                            .zero,

                        size:
                            newSize
                    )
            )
        }
    }


    // MARK: - Fix Photo Orientation

    private func normalizeOrientation(
        _ image: UIImage
    ) -> UIImage {

        if image.imageOrientation == .up {

            return image
        }


        let format =
            UIGraphicsImageRendererFormat()


        format.scale =
        1


        format.opaque =
        false


        let renderer =
            UIGraphicsImageRenderer(
                size:
                    image.size,

                format:
                    format
            )


        return renderer.image { _ in

            image.draw(
                in:
                    CGRect(
                        origin:
                            .zero,

                        size:
                            image.size
                    )
            )
        }
    }
}
