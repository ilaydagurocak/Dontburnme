import UIKit
import SpriteKit

final class GameData {

    static let shared =
        GameData()


    // MARK: - Keys

    private let highScoreKey =
        "EscapeFromMeHighScore"


    private let oldCustomCharacterKey =
        "EscapeFromMeCustomCharacter"


    private let customCharacterFilename =
        "custom_character.png"


    // MARK: - Character

    private(set)
    var customCharacterImage:
    UIImage?


    private init() {

        loadCustomCharacter()
    }


    // MARK: - High Score

    var highScore: Int {

        get {

            UserDefaults.standard
                .integer(
                    forKey:
                        highScoreKey
                )
        }

        set {

            UserDefaults.standard
                .set(
                    newValue,
                    forKey:
                        highScoreKey
                )
        }
    }


    func registerScore(
        _ score: Int
    ) {

        if score > highScore {

            highScore =
            score
        }
    }


    // MARK: - Custom Character

    var hasCustomCharacter:
    Bool {

        customCharacterImage != nil
    }


    func saveCustomCharacter(
        _ image: UIImage
    ) {

        /*
         Vision zaten kişiyi kırptı.

         Burada sadece dosyanın çok büyük
         olmaması için maksimum boyutu
         küçültüyoruz.
         */

        let resizedImage =
            resizeImage(
                image,
                maxSide: 900
            )


        customCharacterImage =
        resizedImage


        guard let pngData =
                resizedImage.pngData()

        else {

            return
        }


        do {

            try pngData.write(
                to:
                    customCharacterURL,

                options:
                    .atomic
            )

        } catch {

            print(
                "Character save error:",
                error
            )
        }


        /*
         Eski JPEG UserDefaults kaydını
         artık kullanmıyoruz.
         */

        UserDefaults.standard
            .removeObject(
                forKey:
                    oldCustomCharacterKey
            )


        NotificationCenter.default
            .post(
                name:
                    .characterPhotoChanged,

                object:
                    nil
            )
    }


    func removeCustomCharacter() {

        customCharacterImage =
        nil


        try? FileManager.default
            .removeItem(
                at:
                    customCharacterURL
            )


        UserDefaults.standard
            .removeObject(
                forKey:
                    oldCustomCharacterKey
            )


        NotificationCenter.default
            .post(
                name:
                    .characterPhotoChanged,

                object:
                    nil
            )
    }


    // MARK: - Texture

    func currentCharacterTexture()
    -> SKTexture {

        if let customCharacterImage {

            let texture =
                SKTexture(
                    image:
                        customCharacterImage
                )


            texture.filteringMode =
            .linear


            return texture
        }


        let texture =
            SKTexture(
                imageNamed:
                    "character_default"
            )


        texture.filteringMode =
        .linear


        return texture
    }


    // MARK: - Storage URL

    private var customCharacterURL:
    URL {

        let fileManager =
            FileManager.default


        let directory =
            fileManager.urls(
                for:
                    .applicationSupportDirectory,

                in:
                    .userDomainMask
            ).first!


        if !fileManager
            .fileExists(
                atPath:
                    directory.path
            ) {

            try? fileManager
                .createDirectory(
                    at:
                        directory,

                    withIntermediateDirectories:
                        true
                )
        }


        return directory
            .appendingPathComponent(
                customCharacterFilename
            )
    }


    // MARK: - Load Character

    private func loadCustomCharacter() {

        /*
         Önce yeni PNG sistemine bak.
         */

        if let image =
            UIImage(
                contentsOfFile:
                    customCharacterURL.path
            ) {

            customCharacterImage =
            image

            return
        }


        /*
         Önceki kodda UserDefaults'a JPEG
         kaydetmiştik.

         Kullanıcı eski sürümden geliyorsa
         karakteri tamamen kaybetmesin diye
         bir defalık migration yapıyoruz.
         */

        if let oldData =
            UserDefaults.standard
                .data(
                    forKey:
                        oldCustomCharacterKey
                ),

           let oldImage =
            UIImage(
                data:
                    oldData
            ) {

            customCharacterImage =
            oldImage


            if let pngData =
                oldImage.pngData() {

                try? pngData.write(
                    to:
                        customCharacterURL,

                    options:
                        .atomic
                )
            }


            UserDefaults.standard
                .removeObject(
                    forKey:
                        oldCustomCharacterKey
                )
        }
    }


    // MARK: - Resize

    private func resizeImage(
        _ image: UIImage,
        maxSide: CGFloat
    ) -> UIImage {

        let oldSize =
            image.size


        let longestSide =
            max(
                oldSize.width,
                oldSize.height
            )


        guard
            longestSide >
            maxSide

        else {

            return image
        }


        let scale =
            maxSide /
            longestSide


        let newSize =
            CGSize(
                width:
                    oldSize.width *
                    scale,

                height:
                    oldSize.height *
                    scale
            )


        /*
         opaque = false çok önemli.
         Böylece transparency korunuyor.
         */

        let format =
            UIGraphicsImageRendererFormat()


        format.opaque =
        false


        format.scale =
        1


        let renderer =
            UIGraphicsImageRenderer(
                size:
                    newSize,

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
                            newSize
                    )
            )
        }
    }
}
