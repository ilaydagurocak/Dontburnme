import SpriteKit

final class GameOverScene:
SKScene,
ResponsiveScene {

    private let finalScore:
    Int


    // MARK: - Nodes

    private let background =
        SKSpriteNode(
            imageNamed:
                "background_landscape"
        )


    private let overlay =
        SKSpriteNode(
            color:
                SKColor.black
                    .withAlphaComponent(
                        0.48
                    ),

            size:
                .zero
        )


    private let titleLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let scoreBox =
        SKShapeNode()


    private let scoreTitle =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Bold"
        )


    private let scoreLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let bestTitle =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Bold"
        )


    private let bestLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let replayButton =
        SKSpriteNode(
            imageNamed:
                "button_play"
        )


    private let replayText =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    private let menuButton =
        SKShapeNode()


    private let menuText =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    // MARK: - Init

    init(
        size: CGSize,
        score: Int
    ) {

        self.finalScore =
        score


        super.init(
            size:
                size
        )
    }


    required init?(
        coder aDecoder: NSCoder
    ) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }


    // MARK: - Scene

    override func didMove(
        to view: SKView
    ) {

        setup()

        layoutScene()


        /*
         Oyun müziğini kapat.
         */

        AudioManager.shared.stopMusic()


        // 💀 GAME OVER SOUND

        AudioManager.shared.playSound(
            .gameOver,
            volume:
                0.90
        )
    }


    override func didChangeSize(
        _ oldSize: CGSize
    ) {

        layoutScene()
    }


    func refreshLayout() {

        layoutScene()
    }


    // MARK: - Setup

    private func setup() {

        // BACKGROUND

        background.zPosition =
        -100


        addChild(
            background
        )


        // OVERLAY

        overlay.zPosition =
        -90


        addChild(
            overlay
        )


        // TITLE

        titleLabel.text =
        "GAME OVER"


        titleLabel.fontColor =
            SKColor(
                red:
                    1,

                green:
                    0.25,

                blue:
                    0.48,

                alpha:
                    1
            )


        titleLabel.horizontalAlignmentMode =
        .center


        titleLabel.verticalAlignmentMode =
        .center


        addChild(
            titleLabel
        )


        // SCORE BOX

        scoreBox.fillColor =
            SKColor(
                red:
                    0.10,

                green:
                    0.08,

                blue:
                    0.28,

                alpha:
                    0.90
            )


        scoreBox.strokeColor =
            SKColor.white
                .withAlphaComponent(
                    0.50
                )


        scoreBox.lineWidth =
        2


        addChild(
            scoreBox
        )


        // SCORE

        scoreTitle.text =
        "SCORE"


        scoreTitle.fontColor =
            SKColor.white
                .withAlphaComponent(
                    0.80
                )


        scoreTitle.horizontalAlignmentMode =
        .center


        addChild(
            scoreTitle
        )


        scoreLabel.text =
        "\(finalScore)"


        scoreLabel.fontColor =
        .white


        scoreLabel.horizontalAlignmentMode =
        .center


        addChild(
            scoreLabel
        )


        // BEST

        bestTitle.text =
        "BEST"


        bestTitle.fontColor =
            SKColor(
                red:
                    1,

                green:
                    0.82,

                blue:
                    0.10,

                alpha:
                    1
            )


        bestTitle.horizontalAlignmentMode =
        .center


        addChild(
            bestTitle
        )


        bestLabel.text =
        "\(GameData.shared.highScore)"


        bestLabel.fontColor =
        .white


        bestLabel.horizontalAlignmentMode =
        .center


        addChild(
            bestLabel
        )


        // REPLAY

        replayButton.name =
        "replay"


        addChild(
            replayButton
        )


        replayText.name =
        "replay"


        replayText.text =
        "PLAY AGAIN"


        replayText.fontColor =
        .white


        replayText.horizontalAlignmentMode =
        .center


        replayText.verticalAlignmentMode =
        .center


        replayText.zPosition =
        5


        addChild(
            replayText
        )


        // MAIN MENU

        menuButton.name =
        "menu"


        menuButton.fillColor =
            SKColor(
                red:
                    1,

                green:
                    0.08,

                blue:
                    0.45,

                alpha:
                    1
            )


        menuButton.strokeColor =
        .white


        menuButton.lineWidth =
        2


        addChild(
            menuButton
        )


        menuText.name =
        "menu"


        menuText.text =
        "MAIN MENU"


        menuText.fontColor =
        .white


        menuText.horizontalAlignmentMode =
        .center


        menuText.verticalAlignmentMode =
        .center


        menuText.zPosition =
        5


        addChild(
            menuText
        )
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


        overlay.size =
        size


        overlay.position =
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
                            15,
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

        titleLabel.fontSize =
            clamp(
                safe.height *
                0.12,

                min:
                    38,

                max:
                    70
            )


        titleLabel.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.79
            )


        // SCORE BOX

        let boxWidth =
            clamp(
                safe.width *
                0.30,

                min:
                    220,

                max:
                    360
            )


        let boxHeight =
            safe.height *
            0.27


        scoreBox.path =
            CGPath(
                roundedRect:
                    CGRect(
                        x:
                            -boxWidth /
                            2,

                        y:
                            -boxHeight /
                            2,

                        width:
                            boxWidth,

                        height:
                            boxHeight
                    ),

                cornerWidth:
                    22,

                cornerHeight:
                    22,

                transform:
                    nil
            )


        scoreBox.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.53
            )


        // SCORE LABELS

        scoreTitle.fontSize =
            clamp(
                boxHeight *
                0.18,

                min:
                    12,

                max:
                    18
            )


        scoreLabel.fontSize =
            clamp(
                boxHeight *
                0.32,

                min:
                    24,

                max:
                    40
            )


        bestTitle.fontSize =
        scoreTitle.fontSize


        bestLabel.fontSize =
        scoreLabel.fontSize *
        0.72


        scoreTitle.position =
            CGPoint(
                x:
                    scoreBox.position.x -
                    boxWidth *
                    0.22,

                y:
                    scoreBox.position.y +
                    boxHeight *
                    0.18
            )


        scoreLabel.position =
            CGPoint(
                x:
                    scoreTitle
                        .position.x,

                y:
                    scoreBox.position.y -
                    boxHeight *
                    0.16
            )


        bestTitle.position =
            CGPoint(
                x:
                    scoreBox.position.x +
                    boxWidth *
                    0.22,

                y:
                    scoreTitle
                        .position.y
            )


        bestLabel.position =
            CGPoint(
                x:
                    bestTitle
                        .position.x,

                y:
                    scoreLabel
                        .position.y
            )


        // PLAY AGAIN

        let replayWidth =
            clamp(
                safe.width *
                0.26,

                min:
                    190,

                max:
                    320
            )


        replayButton.size =
            CGSize(
                width:
                    replayWidth,

                height:
                    replayWidth *
                    0.36
            )


        replayButton.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.255
            )


        replayText.position =
        replayButton.position


        replayText.fontSize =
            clamp(
                replayButton
                    .size.height *
                0.33,

                min:
                    16,

                max:
                    26
            )


        // MAIN MENU

        let menuWidth =
            replayWidth *
            0.88


        let menuHeight =
            replayButton
                .size.height *
            0.67


        menuButton.path =
            CGPath(
                roundedRect:
                    CGRect(
                        x:
                            -menuWidth /
                            2,

                        y:
                            -menuHeight /
                            2,

                        width:
                            menuWidth,

                        height:
                            menuHeight
                    ),

                cornerWidth:
                    menuHeight /
                    2,

                cornerHeight:
                    menuHeight /
                    2,

                transform:
                    nil
            )


        menuButton.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.minY +
                    safe.height *
                    0.09
            )


        menuText.position =
        menuButton.position


        menuText.fontSize =
            clamp(
                menuHeight *
                0.34,

                min:
                    14,

                max:
                    21
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


        case "replay":

            // 🔊 BUTTON CLICK

            AudioManager.shared.playSound(
                .button,
                volume:
                    0.75
            )


            openScene(
                GameScene(
                    size:
                        size
                ),

                transition:
                    .fade(
                        withDuration:
                            0.25
                    )
            )


        case "menu":

            // 🔊 BUTTON CLICK

            AudioManager.shared.playSound(
                .button,
                volume:
                    0.75
            )


            openScene(
                MainMenuScene(
                    size:
                        size
                ),

                transition:
                    .fade(
                        withDuration:
                            0.25
                    )
            )


        default:

            break
        }
    }
}
