import SpriteKit

final class CharacterSelectionScene:
SKScene,
ResponsiveScene {

    // MARK: - Nodes

    private let background =
        SKSpriteNode(
            imageNamed:
                "background_landscape"
        )


    private let darkOverlay =
        SKSpriteNode(
            color:
                .black,

            size:
                .zero
        )


    private let titleLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let descriptionLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Medium"
        )


    private let backButton =
        SKSpriteNode(
            imageNamed:
                "button_back"
        )


    private let defaultCard =
        SKShapeNode()


    private let customCard =
        SKShapeNode()


    private let defaultPreview =
        SKSpriteNode(
            imageNamed:
                "character_default"
        )


    private let customPreview =
        SKSpriteNode()


    private let defaultText =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Bold"
        )


    private let customText =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Bold"
        )


    private let defaultCheck =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let customCheck =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let continueButton =
        SKShapeNode()


    private let continueText =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private var observer:
    NSObjectProtocol?


    // MARK: - Scene

    override func didMove(
        to view: SKView
    ) {

        setupNodes()

        refreshCharacter()

        layoutScene()


        observer =
            NotificationCenter.default
                .addObserver(
                    forName:
                        .characterPhotoChanged,

                    object:
                        nil,

                    queue:
                        .main

                ) { [weak self] _ in

                    self?
                        .refreshCharacter()
                }
    }


    override func didChangeSize(
        _ oldSize: CGSize
    ) {

        layoutScene()
    }


    func refreshLayout() {

        layoutScene()
    }


    deinit {

        if let observer {

            NotificationCenter.default
                .removeObserver(
                    observer
                )
        }
    }


    // MARK: - Setup

    private func setupNodes() {

        removeAllChildren()


        // BACKGROUND

        background.zPosition =
        -100


        addChild(
            background
        )


        // OVERLAY

        darkOverlay.color =
            SKColor.black
                .withAlphaComponent(
                    0.30
                )


        darkOverlay.zPosition =
        -90


        addChild(
            darkOverlay
        )


        // TITLE

        titleLabel.text =
        "Karakterini Seç"


        titleLabel.fontColor =
        .white


        titleLabel.horizontalAlignmentMode =
        .center


        addChild(
            titleLabel
        )


        // DESCRIPTION

        descriptionLabel.text =
        "Varsayılan karakteri kullan veya kendi fotoğrafını seç."


        descriptionLabel.fontColor =
            SKColor.white
                .withAlphaComponent(
                    0.82
                )


        descriptionLabel.horizontalAlignmentMode =
        .center


        addChild(
            descriptionLabel
        )


        // BACK BUTTON

        backButton.name =
        "back"


        backButton.zPosition =
        20


        addChild(
            backButton
        )


        // CARDS

        configureCard(
            defaultCard,
            name:
                "default"
        )


        configureCard(
            customCard,
            name:
                "gallery"
        )


        addChild(
            defaultCard
        )


        addChild(
            customCard
        )


        // PREVIEWS

        defaultPreview.name =
        "default"


        defaultPreview.zPosition =
        10


        addChild(
            defaultPreview
        )


        customPreview.name =
        "gallery"


        customPreview.zPosition =
        10


        addChild(
            customPreview
        )


        // TEXT

        defaultText.name =
        "default"


        defaultText.text =
        "Varsayılan"


        defaultText.fontColor =
        .white


        defaultText.horizontalAlignmentMode =
        .center


        addChild(
            defaultText
        )


        customText.name =
        "gallery"


        customText.text =
        "Kendi Fotoğrafın"


        customText.fontColor =
        .white


        customText.horizontalAlignmentMode =
        .center


        addChild(
            customText
        )


        // CHECKS

        defaultCheck.text =
        "✓"


        defaultCheck.fontColor =
        .green


        defaultCheck.zPosition =
        20


        addChild(
            defaultCheck
        )


        customCheck.text =
        "✓"


        customCheck.fontColor =
        .green


        customCheck.zPosition =
        20


        addChild(
            customCheck
        )


        // CONTINUE

        continueButton.name =
        "continue"


        continueButton.fillColor =
            SKColor(
                red: 1,
                green: 0.08,
                blue: 0.45,
                alpha: 1
            )


        continueButton.strokeColor =
        .white


        continueButton.lineWidth =
        2


        addChild(
            continueButton
        )


        continueText.name =
        "continue"


        continueText.text =
        "DEVAM ET"


        continueText.fontColor =
        .white


        continueText.horizontalAlignmentMode =
        .center


        continueText.verticalAlignmentMode =
        .center


        continueText.zPosition =
        5


        addChild(
            continueText
        )
    }


    // MARK: - Card

    private func configureCard(
        _ card: SKShapeNode,
        name: String
    ) {

        card.name =
        name


        card.fillColor =
            SKColor.black
                .withAlphaComponent(
                    0.42
                )


        card.strokeColor =
            SKColor.white
                .withAlphaComponent(
                    0.65
                )


        card.lineWidth =
        2


        card.zPosition =
        1
    }


    // MARK: - Character Refresh

    private func refreshCharacter() {

        let texture =
            GameData.shared
                .currentCharacterTexture()


        customPreview.texture =
        texture


        let usingCustom =
            GameData.shared
                .hasCustomCharacter


        defaultCheck.isHidden =
        usingCustom


        customCheck.isHidden =
        !usingCustom


        defaultCard.strokeColor =
            usingCustom
            ?
            SKColor.white
                .withAlphaComponent(
                    0.5
                )
            :
            .systemPink


        defaultCard.lineWidth =
            usingCustom
            ?
            2
            :
            5


        customCard.strokeColor =
            usingCustom
            ?
            .systemPink
            :
            SKColor.white
                .withAlphaComponent(
                    0.5
                )


        customCard.lineWidth =
            usingCustom
            ?
            5
            :
            2


        layoutScene()
    }


    // MARK: - Layout

    private func layoutScene() {

        guard
            size.width > 0,
            size.height > 0

        else {

            return
        }


        aspectFill(
            sprite:
                background,

            sceneSize:
                size
        )


        darkOverlay.size =
        size


        darkOverlay.position =
            CGPoint(
                x:
                    size.width /
                    2,

                y:
                    size.height /
                    2
            )


        let safe =
            safeContentFrame
                .insetBy(
                    dx:
                        max(
                            18,
                            size.width *
                            0.025
                        ),

                    dy:
                        max(
                            12,
                            size.height *
                            0.025
                        )
                )


        // BACK

        let backSize =
            clamp(
                safe.height *
                0.13,

                min:
                    46,

                max:
                    70
            )


        backButton.size =
            CGSize(
                width:
                    backSize,

                height:
                    backSize
            )


        backButton.position =
            CGPoint(
                x:
                    safe.minX +
                    backSize /
                    2,

                y:
                    safe.maxY -
                    backSize /
                    2
            )


        // TITLE

        titleLabel.fontSize =
            clamp(
                safe.height *
                0.09,

                min:
                    28,

                max:
                    48
            )


        titleLabel.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.88
            )


        // DESCRIPTION

        descriptionLabel.fontSize =
            clamp(
                safe.height *
                0.036,

                min:
                    12,

                max:
                    18
            )


        descriptionLabel.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.79
            )


        // CARDS

        let cardWidth =
            min(
                safe.width *
                0.29,

                310
            )


        let cardHeight =
            safe.height *
            0.48


        let cardRect =
            CGRect(
                x:
                    -cardWidth /
                    2,

                y:
                    -cardHeight /
                    2,

                width:
                    cardWidth,

                height:
                    cardHeight
            )


        defaultCard.path =
            CGPath(
                roundedRect:
                    cardRect,

                cornerWidth:
                    24,

                cornerHeight:
                    24,

                transform:
                    nil
            )


        customCard.path =
            CGPath(
                roundedRect:
                    cardRect,

                cornerWidth:
                    24,

                cornerHeight:
                    24,

                transform:
                    nil
            )


        let gap =
            min(
                safe.width *
                0.08,

                80
            )


        defaultCard.position =
            CGPoint(
                x:
                    safe.midX -
                    cardWidth /
                    2 -
                    gap /
                    2,

                y:
                    safe.minY +
                    safe.height *
                    0.48
            )


        customCard.position =
            CGPoint(
                x:
                    safe.midX +
                    cardWidth /
                    2 +
                    gap /
                    2,

                y:
                    defaultCard
                        .position.y
            )


        // PREVIEW

        let previewHeight =
            cardHeight *
            0.56


        if let texture =
            defaultPreview.texture {

            defaultPreview.size =
                fittedTextureSize(
                    texture:
                        texture,

                    targetHeight:
                        previewHeight
                )
        }


        defaultPreview.position =
            CGPoint(
                x:
                    defaultCard
                        .position.x,

                y:
                    defaultCard
                        .position.y +
                    cardHeight *
                    0.08
            )


        if let texture =
            customPreview.texture {

            customPreview.size =
                fittedTextureSize(
                    texture:
                        texture,

                    targetHeight:
                        previewHeight
                )
        }


        customPreview.position =
            CGPoint(
                x:
                    customCard
                        .position.x,

                y:
                    customCard
                        .position.y +
                    cardHeight *
                    0.08
            )


        // LABELS

        defaultText.fontSize =
            clamp(
                safe.height *
                0.042,

                min:
                    13,

                max:
                    21
            )


        customText.fontSize =
        defaultText.fontSize


        defaultText.position =
            CGPoint(
                x:
                    defaultCard
                        .position.x,

                y:
                    defaultCard
                        .position.y -
                    cardHeight *
                    0.36
            )


        customText.position =
            CGPoint(
                x:
                    customCard
                        .position.x,

                y:
                    customCard
                        .position.y -
                    cardHeight *
                    0.36
            )


        // CHECKS

        let checkSize =
            clamp(
                safe.height *
                0.07,

                min:
                    20,

                max:
                    32
            )


        defaultCheck.fontSize =
        checkSize


        customCheck.fontSize =
        checkSize


        defaultCheck.position =
            CGPoint(
                x:
                    defaultCard
                        .position.x +
                    cardWidth *
                    0.39,

                y:
                    defaultCard
                        .position.y +
                    cardHeight *
                    0.34
            )


        customCheck.position =
            CGPoint(
                x:
                    customCard
                        .position.x +
                    cardWidth *
                    0.39,

                y:
                    customCard
                        .position.y +
                    cardHeight *
                    0.34
            )


        // CONTINUE

        let continueWidth =
            clamp(
                safe.width *
                0.25,

                min:
                    180,

                max:
                    300
            )


        let continueHeight =
            clamp(
                safe.height *
                0.11,

                min:
                    44,

                max:
                    62
            )


        continueButton.path =
            CGPath(
                roundedRect:
                    CGRect(
                        x:
                            -continueWidth /
                            2,

                        y:
                            -continueHeight /
                            2,

                        width:
                            continueWidth,

                        height:
                            continueHeight
                    ),

                cornerWidth:
                    continueHeight /
                    2,

                cornerHeight:
                    continueHeight /
                    2,

                transform:
                    nil
            )


        continueButton.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.09
            )


        continueText.position =
        continueButton.position


        continueText.fontSize =
            clamp(
                continueHeight *
                0.37,

                min:
                    16,

                max:
                    24
            )
    }


    // MARK: - Touch

    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard
            let touch =
                touches.first

        else {

            return
        }


        let point =
            touch.location(
                in:
                    self
            )


        switch actionName(
            at:
                point
        ) {


        case "back",
             "continue":

            AudioManager.shared.playSound(
                .button,
                volume:
                    0.75
            )


            openScene(
                MainMenuScene(
                    size:
                        size
                )
            )


        case "default":

            AudioManager.shared.playSound(
                .button,
                volume:
                    0.75
            )


            GameData.shared
                .removeCustomCharacter()


        case "gallery":

            AudioManager.shared.playSound(
                .button,
                volume:
                    0.75
            )


            NotificationCenter.default.post(
                name:
                    .requestCharacterPhoto,

                object:
                    nil
            )


        default:

            break
        }
    }
}
