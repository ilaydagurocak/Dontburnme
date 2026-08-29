import SpriteKit

final class MainMenuScene:
SKScene,
ResponsiveScene {

    // MARK: - Nodes

    private let background =
        SKSpriteNode(
            imageNamed:
                "background_landscape"
        )


    private let titleShadow =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let titleLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let subtitleLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-DemiBold"
        )


    private let character =
        SKSpriteNode()


    private let playButton =
        SKSpriteNode(
            imageNamed:
                "button_play"
        )


    private let playLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let characterButton =
        SKShapeNode()


    private let characterButtonIcon =
        SKSpriteNode()


    private let characterButtonLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Bold"
        )


    // MARK: - Scene

    override func didMove(
        to view: SKView
    ) {

        backgroundColor =
        .black


        setupNodes()

        refreshCharacter()

        layoutScene()


        // 🎵 MENU MUSIC

        AudioManager.shared.musicVolume =
        0.30


        AudioManager.shared.playMusic(
            .menu
        )
    }


    override func didChangeSize(
        _ oldSize: CGSize
    ) {

        layoutScene()
    }


    // MARK: - Responsive

    func refreshLayout() {

        layoutScene()
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


        // TITLE SHADOW

        titleShadow.text =
        "DON'T BURN ME!"


        titleShadow.fontColor =
            SKColor.black
                .withAlphaComponent(
                    0.60
                )


        titleShadow.horizontalAlignmentMode =
        .center


        titleShadow.verticalAlignmentMode =
        .center


        titleShadow.zPosition =
        1


        addChild(
            titleShadow
        )


        // TITLE

        titleLabel.text =
        "DON'T BURN ME!"


        titleLabel.fontColor =
        .white


        titleLabel.horizontalAlignmentMode =
        .center


        titleLabel.verticalAlignmentMode =
        .center


        titleLabel.zPosition =
        2


        addChild(
            titleLabel
        )


        // SUBTITLE

        subtitleLabel.text =
        "Escape the flames and beat your record!"


        subtitleLabel.fontColor =
            SKColor.white
                .withAlphaComponent(
                    0.82
                )


        subtitleLabel.horizontalAlignmentMode =
        .center


        subtitleLabel.verticalAlignmentMode =
        .center


        addChild(
            subtitleLabel
        )


        // CHARACTER

        character.zPosition =
        10


        addChild(
            character
        )


        // PLAY BUTTON

        playButton.name =
        "play"


        playButton.zPosition =
        20


        addChild(
            playButton
        )


        // PLAY LABEL

        playLabel.name =
        "play"


        playLabel.text =
        "PLAY"


        playLabel.fontColor =
        .white


        playLabel.horizontalAlignmentMode =
        .center


        playLabel.verticalAlignmentMode =
        .center


        playLabel.zPosition =
        21


        addChild(
            playLabel
        )


        // CHARACTER BUTTON

        characterButton.name =
        "character"


        characterButton.fillColor =
            SKColor(
                red: 1,
                green: 0.10,
                blue: 0.48,
                alpha: 1
            )


        characterButton.strokeColor =
        .white


        characterButton.lineWidth =
        3


        characterButton.zPosition =
        20


        addChild(
            characterButton
        )


        // CHARACTER ICON

        if let texture =
            symbolTexture(
                name:
                    "photo.on.rectangle",
                pointSize:
                    30
            ) {

            characterButtonIcon.texture =
            texture
        }


        characterButtonIcon.name =
        "character"


        characterButtonIcon.zPosition =
        21


        addChild(
            characterButtonIcon
        )


        // CHARACTER TEXT

        characterButtonLabel.name =
        "character"


        characterButtonLabel.text =
        "CHARACTER"


        characterButtonLabel.fontColor =
        .white


        characterButtonLabel.horizontalAlignmentMode =
        .center


        characterButtonLabel.verticalAlignmentMode =
        .center


        characterButtonLabel.zPosition =
        21


        addChild(
            characterButtonLabel
        )
    }


    // MARK: - Character

    private func refreshCharacter() {

        let texture =
            GameData.shared
                .currentCharacterTexture()


        character.texture =
        texture
    }


    // MARK: - Layout

    private func layoutScene() {

        guard
            size.width > 0,
            size.height > 0

        else {

            return
        }


        // BACKGROUND

        aspectFill(
            sprite:
                background,

            sceneSize:
                size
        )


        let safe =
            safeContentFrame
                .insetBy(
                    dx:
                        max(
                            14,
                            size.width *
                            0.02
                        ),

                    dy:
                        max(
                            10,
                            size.height *
                            0.02
                        )
                )


        // TITLE

        let titleSize =
            clamp(
                safe.height *
                0.105,

                min:
                    30,

                max:
                    58
            )


        titleLabel.fontSize =
        titleSize


        titleShadow.fontSize =
        titleSize


        titleLabel.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.84
            )


        titleShadow.position =
            CGPoint(
                x:
                    titleLabel
                        .position.x +
                    3,

                y:
                    titleLabel
                        .position.y -
                    4
            )


        // SUBTITLE

        subtitleLabel.fontSize =
            clamp(
                safe.height *
                0.037,

                min:
                    12,

                max:
                    19
            )


        subtitleLabel.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.755
            )


        // CHARACTER

        let characterHeight =
            safe.height *
            0.36


        let texture =
            GameData.shared
                .currentCharacterTexture()


        character.texture =
        texture


        character.size =
            fittedTextureSize(
                texture:
                    texture,

                targetHeight:
                    characterHeight
            )


        character.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.49
            )


        // PLAY BUTTON

        let playWidth =
            clamp(
                safe.width *
                0.26,

                min:
                    180,

                max:
                    330
            )


        playButton.size =
            CGSize(
                width:
                    playWidth,

                height:
                    playWidth *
                    0.37
            )


        playButton.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.195
            )


        playLabel.fontSize =
            clamp(
                playButton
                    .size.height *
                0.40,

                min:
                    22,

                max:
                    36
            )


        playLabel.position =
        playButton.position


        // CHARACTER BUTTON

        let buttonDiameter =
            clamp(
                safe.height *
                0.14,

                min:
                    50,

                max:
                    78
            )


        characterButton.path =
            CGPath(
                ellipseIn:
                    CGRect(
                        x:
                            -buttonDiameter /
                            2,

                        y:
                            -buttonDiameter /
                            2,

                        width:
                            buttonDiameter,

                        height:
                            buttonDiameter
                    ),

                transform:
                    nil
            )


        characterButton.position =
            CGPoint(
                x:
                    safe.minX +
                    buttonDiameter *
                    0.72,

                y:
                    safe.minY +
                    buttonDiameter *
                    0.78
            )


        characterButtonIcon.size =
            CGSize(
                width:
                    buttonDiameter *
                    0.42,

                height:
                    buttonDiameter *
                    0.42
            )


        characterButtonIcon.position =
        characterButton.position


        characterButtonLabel.fontSize =
            clamp(
                buttonDiameter *
                0.20,

                min:
                    10,

                max:
                    14
            )


        characterButtonLabel.position =
            CGPoint(
                x:
                    characterButton
                        .position.x,

                y:
                    safe.minY +
                    buttonDiameter *
                    0.10
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


        case "play":

            // 🔊 BUTTON CLICK

            AudioManager.shared.playSound(
                .button,
                volume:
                    0.75
            )


            let game =
                GameScene(
                    size:
                        size
                )


            openScene(
                game,

                transition:
                    .doorsOpenHorizontal(
                        withDuration:
                            0.35
                    )
            )


        case "character":

            // 🔊 BUTTON CLICK

            AudioManager.shared.playSound(
                .button,
                volume:
                    0.75
            )


            let scene =
                CharacterSelectionScene(
                    size:
                        size
                )


            openScene(
                scene
            )


        default:

            break
        }
    }
}
