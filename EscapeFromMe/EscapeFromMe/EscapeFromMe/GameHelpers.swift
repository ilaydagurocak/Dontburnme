import SpriteKit
import UIKit

// MARK: - Notifications

extension Notification.Name {

    static let requestCharacterPhoto =
        Notification.Name(
            "requestCharacterPhoto"
        )


    static let characterPhotoChanged =
        Notification.Name(
            "characterPhotoChanged"
        )


    static let characterProcessingStarted =
        Notification.Name(
            "characterProcessingStarted"
        )


    static let characterProcessingFinished =
        Notification.Name(
            "characterProcessingFinished"
        )


    static let characterProcessingFailed =
        Notification.Name(
            "characterProcessingFailed"
        )
}


// MARK: - Responsive Scene

protocol ResponsiveScene:
AnyObject {

    func refreshLayout()
}


// MARK: - Scene Helpers

extension SKScene {

    var safeContentFrame:
    CGRect {

        guard let view else {

            return CGRect(
                origin:
                    .zero,

                size:
                    size
            )
        }


        let insets =
            view.safeAreaInsets


        return CGRect(
            x:
                insets.left,

            y:
                insets.bottom,

            width:
                max(
                    0,

                    size.width -
                    insets.left -
                    insets.right
                ),

            height:
                max(
                    0,

                    size.height -
                    insets.top -
                    insets.bottom
                )
        )
    }


    func openScene(
        _ scene: SKScene,
        transition:
        SKTransition =
            .fade(
                withDuration:
                    0.25
            )
    ) {

        scene.size =
        size


        scene.scaleMode =
        .resizeFill


        view?.presentScene(
            scene,
            transition:
                transition
        )
    }


    func actionName(
        at point: CGPoint
    ) -> String? {

        let touchedNodes =
            nodes(
                at:
                    point
            )


        for node in touchedNodes {

            var currentNode:
            SKNode? =
            node


            while let current =
                currentNode {

                if let name =
                    current.name {

                    return name
                }


                currentNode =
                current.parent
            }
        }


        return nil
    }
}


// MARK: - Aspect Fill

func aspectFill(
    sprite: SKSpriteNode,
    sceneSize: CGSize
) {

    guard let texture =
            sprite.texture

    else {

        sprite.size =
        sceneSize


        sprite.position =
            CGPoint(
                x:
                    sceneSize.width / 2,

                y:
                    sceneSize.height / 2
            )

        return
    }


    let textureSize =
        texture.size()


    guard
        textureSize.width > 0,
        textureSize.height > 0

    else {

        return
    }


    let scaleX =
        sceneSize.width /
        textureSize.width


    let scaleY =
        sceneSize.height /
        textureSize.height


    let scale =
        max(
            scaleX,
            scaleY
        )


    sprite.size =
        CGSize(
            width:
                textureSize.width *
                scale,

            height:
                textureSize.height *
                scale
        )


    sprite.position =
        CGPoint(
            x:
                sceneSize.width / 2,

            y:
                sceneSize.height / 2
        )
}


// MARK: - Texture Size

func fittedTextureSize(
    texture: SKTexture,
    targetHeight: CGFloat
) -> CGSize {

    let textureSize =
        texture.size()


    guard
        textureSize.width > 0,
        textureSize.height > 0

    else {

        return CGSize(
            width:
                targetHeight,

            height:
                targetHeight
        )
    }


    let ratio =
        textureSize.width /
        textureSize.height


    return CGSize(
        width:
            targetHeight *
            ratio,

        height:
            targetHeight
    )
}


// MARK: - Fit Width + Height

func fittedTextureSize(
    texture: SKTexture,
    maxWidth: CGFloat,
    maxHeight: CGFloat
) -> CGSize {

    let textureSize =
        texture.size()


    guard
        textureSize.width > 0,
        textureSize.height > 0

    else {

        return CGSize(
            width:
                maxWidth,

            height:
                maxHeight
        )
    }


    let widthScale =
        maxWidth /
        textureSize.width


    let heightScale =
        maxHeight /
        textureSize.height


    let scale =
        min(
            widthScale,
            heightScale
        )


    return CGSize(
        width:
            textureSize.width *
            scale,

        height:
            textureSize.height *
            scale
    )
}


// MARK: - Clamp

func clamp(
    _ value: CGFloat,
    min minimum: CGFloat,
    max maximum: CGFloat
) -> CGFloat {

    Swift.max(
        minimum,

        Swift.min(
            maximum,
            value
        )
    )
}


// MARK: - SF Symbol Texture

func symbolTexture(
    name: String,
    pointSize: CGFloat = 30
) -> SKTexture? {

    let configuration =
        UIImage.SymbolConfiguration(
            pointSize:
                pointSize,

            weight:
                .bold
        )


    guard let image =
        UIImage(
            systemName:
                name,

            withConfiguration:
                configuration
        )?
        .withTintColor(
            .white,
            renderingMode:
                .alwaysOriginal
        )

    else {

        return nil
    }


    return SKTexture(
        image:
            image
    )
}
