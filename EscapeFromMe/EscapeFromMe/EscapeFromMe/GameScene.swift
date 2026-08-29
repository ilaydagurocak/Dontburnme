import SpriteKit

final class GameScene:
SKScene,
SKPhysicsContactDelegate,
ResponsiveScene {

    // MARK: - Physics Categories

    private let playerCategory:
    UInt32 = 1 << 0


    private let fireCategory:
    UInt32 = 1 << 1


    // MARK: - Nodes

    private let background =
        SKSpriteNode(
            imageNamed:
                "background_landscape"
        )


    private let worldNode =
        SKNode()


    private let player =
        SKSpriteNode()


    // MARK: Pause

    private let pauseButton =
        SKShapeNode()


    private let pauseLabel =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    // MARK: Score

    private let scorePanel =
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


    // MARK: Best

    private let bestPanel =
        SKShapeNode()


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


    // MARK: Pause Overlay

    private let pauseOverlay =
        SKSpriteNode(
            color:
                SKColor.black
                    .withAlphaComponent(
                        0.60
                    ),

            size:
                .zero
        )


    private let pausedText =
        SKLabelNode(
            fontNamed:
                "AvenirNext-Heavy"
        )


    // MARK: - Score

    private var score =
    0 {

        didSet {

            scoreLabel.text =
            "\(score)"


            /*
             Oyun sırasında yeni rekor
             kırılırsa BEST canlı güncellensin.
             */

            if score >
                GameData.shared.highScore {

                bestLabel.text =
                "\(score)"
            }
        }
    }


    // MARK: - Game State

    private var isDraggingPlayer =
    false


    private var isGamePaused =
    false


    private var hasGameEnded =
    false


    // MARK: - Time

    private var lastUpdateTime:
    TimeInterval = 0


    private var spawnTimer:
    TimeInterval = 0


    // MARK: - Running Animation

    private enum RunDirection {

        case none
        case left
        case right
    }


    private var currentDirection:
    RunDirection =
    .none


    // MARK: - Scene

    override func didMove(
        to view: SKView
    ) {

        backgroundColor =
        .black


        physicsWorld.gravity =
        .zero


        physicsWorld.contactDelegate =
        self


        setupScene()

        layoutScene()


        score =
        0


        /*
         Ana menü müziğinden
         oyun müziğine geçiyoruz.
         */

        AudioManager.shared.musicVolume =
        0.25


        AudioManager.shared.playMusic(
            .game
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

    private func setupScene() {

        removeAllChildren()


        // BACKGROUND

        background.zPosition =
        -100


        addChild(
            background
        )


        // WORLD

        worldNode.zPosition =
        0


        addChild(
            worldNode
        )


        // PLAYER

        player.texture =
            GameData.shared
                .currentCharacterTexture()


        player.zPosition =
        30


        worldNode.addChild(
            player
        )


        // PAUSE BUTTON

        pauseButton.name =
        "pause"


        pauseButton.fillColor =
            SKColor(
                red:
                    1,

                green:
                    0.13,

                blue:
                    0.48,

                alpha:
                    1
            )


        pauseButton.strokeColor =
        .white


        pauseButton.lineWidth =
        2


        pauseButton.zPosition =
        220


        addChild(
            pauseButton
        )


        // PAUSE ICON

        pauseLabel.name =
        "pause"


        pauseLabel.text =
        "Ⅱ"


        pauseLabel.fontColor =
        .white


        pauseLabel.horizontalAlignmentMode =
        .center


        pauseLabel.verticalAlignmentMode =
        .center


        pauseLabel.zPosition =
        221


        addChild(
            pauseLabel
        )


        // SCORE PANEL

        configureInfoPanel(
            scorePanel
        )


        addChild(
            scorePanel
        )


        scoreTitle.text =
        "SCORE"


        scoreTitle.fontColor =
            SKColor.white
                .withAlphaComponent(
                    0.78
                )


        scoreTitle.horizontalAlignmentMode =
        .center


        scoreTitle.verticalAlignmentMode =
        .center


        scoreTitle.zPosition =
        102


        addChild(
            scoreTitle
        )


        scoreLabel.text =
        "0"


        scoreLabel.fontColor =
        .white


        scoreLabel.horizontalAlignmentMode =
        .center


        scoreLabel.verticalAlignmentMode =
        .center


        scoreLabel.zPosition =
        102


        addChild(
            scoreLabel
        )


        // BEST PANEL

        configureInfoPanel(
            bestPanel
        )


        addChild(
            bestPanel
        )


        bestTitle.text =
        "BEST"


        bestTitle.fontColor =
            SKColor(
                red:
                    1,

                green:
                    0.82,

                blue:
                    0.12,

                alpha:
                    1
            )


        bestTitle.horizontalAlignmentMode =
        .center


        bestTitle.verticalAlignmentMode =
        .center


        bestTitle.zPosition =
        102


        addChild(
            bestTitle
        )


        bestLabel.text =
        "\(GameData.shared.highScore)"


        bestLabel.fontColor =
        .white


        bestLabel.horizontalAlignmentMode =
        .center


        bestLabel.verticalAlignmentMode =
        .center


        bestLabel.zPosition =
        102


        addChild(
            bestLabel
        )


        // PAUSE OVERLAY

        pauseOverlay.isHidden =
        true


        pauseOverlay.zPosition =
        200


        addChild(
            pauseOverlay
        )


        pausedText.text =
        "PAUSED"


        pausedText.fontColor =
        .white


        pausedText.horizontalAlignmentMode =
        .center


        pausedText.verticalAlignmentMode =
        .center


        pausedText.zPosition =
        205


        pausedText.isHidden =
        true


        addChild(
            pausedText
        )
    }


    private func configureInfoPanel(
        _ panel: SKShapeNode
    ) {

        panel.fillColor =
            SKColor.black
                .withAlphaComponent(
                    0.48
                )


        panel.strokeColor =
            SKColor.white
                .withAlphaComponent(
                    0.22
                )


        panel.lineWidth =
        1.5


        panel.zPosition =
        100
    }


    // MARK: - Responsive Layout

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


        let safe =
            safeContentFrame
                .insetBy(
                    dx:
                        max(
                            10,
                            size.width *
                            0.015
                        ),

                    dy:
                        max(
                            8,
                            size.height *
                            0.015
                        )
                )


        // PLAYER

        let playerHeight =
            clamp(
                safe.height *
                0.205,

                min:
                    72,

                max:
                    135
            )


        if let texture =
            player.texture {

            player.size =
                fittedTextureSize(
                    texture:
                        texture,

                    targetHeight:
                        playerHeight
                )
        }


        let playerY =
            safe.minY +
            player.size.height *
            0.52 +
            safe.height *
            0.015


        if player.position ==
            .zero {

            player.position =
                CGPoint(
                    x:
                        safe.midX,

                    y:
                        playerY
                )

        } else {

            player.position.y =
            playerY


            player.position.x =
                clamp(
                    player.position.x,

                    min:
                        safe.minX +
                        player.size.width *
                        0.5,

                    max:
                        safe.maxX -
                        player.size.width *
                        0.5
                )
        }


        configurePlayerPhysics()


        // PAUSE BUTTON

        let pauseDiameter =
            clamp(
                safe.height *
                0.12,

                min:
                    44,

                max:
                    66
            )


        pauseButton.path =
            CGPath(
                ellipseIn:
                    CGRect(
                        x:
                            -pauseDiameter /
                            2,

                        y:
                            -pauseDiameter /
                            2,

                        width:
                            pauseDiameter,

                        height:
                            pauseDiameter
                    ),

                transform:
                    nil
            )


        pauseButton.position =
            CGPoint(
                x:
                    safe.minX +
                    pauseDiameter *
                    0.55,

                y:
                    safe.maxY -
                    pauseDiameter *
                    0.55
            )


        pauseLabel.fontSize =
        pauseDiameter *
        0.40


        pauseLabel.position =
        pauseButton.position


        // SCORE PANELS

        let panelWidth =
            clamp(
                safe.width *
                0.11,

                min:
                    78,

                max:
                    120
            )


        let panelHeight =
            clamp(
                safe.height *
                0.13,

                min:
                    46,

                max:
                    68
            )


        let panelRect =
            CGRect(
                x:
                    -panelWidth /
                    2,

                y:
                    -panelHeight /
                    2,

                width:
                    panelWidth,

                height:
                    panelHeight
            )


        scorePanel.path =
            CGPath(
                roundedRect:
                    panelRect,

                cornerWidth:
                    14,

                cornerHeight:
                    14,

                transform:
                    nil
            )


        bestPanel.path =
            CGPath(
                roundedRect:
                    panelRect,

                cornerWidth:
                    14,

                cornerHeight:
                    14,

                transform:
                    nil
            )


        scorePanel.position =
            CGPoint(
                x:
                    safe.midX -
                    panelWidth *
                    0.62,

                y:
                    safe.maxY -
                    panelHeight *
                    0.52
            )


        bestPanel.position =
            CGPoint(
                x:
                    safe.midX +
                    panelWidth *
                    0.62,

                y:
                    scorePanel
                        .position.y
            )


        let smallFont =
            clamp(
                panelHeight *
                0.22,

                min:
                    10,

                max:
                    14
            )


        let bigFont =
            clamp(
                panelHeight *
                0.38,

                min:
                    17,

                max:
                    27
            )


        scoreTitle.fontSize =
        smallFont


        scoreLabel.fontSize =
        bigFont


        bestTitle.fontSize =
        smallFont


        bestLabel.fontSize =
        bigFont


        scoreTitle.position =
            CGPoint(
                x:
                    scorePanel
                        .position.x,

                y:
                    scorePanel
                        .position.y +
                    panelHeight *
                    0.20
            )


        scoreLabel.position =
            CGPoint(
                x:
                    scorePanel
                        .position.x,

                y:
                    scorePanel
                        .position.y -
                    panelHeight *
                    0.16
            )


        bestTitle.position =
            CGPoint(
                x:
                    bestPanel
                        .position.x,

                y:
                    bestPanel
                        .position.y +
                    panelHeight *
                    0.20
            )


        bestLabel.position =
            CGPoint(
                x:
                    bestPanel
                        .position.x,

                y:
                    bestPanel
                        .position.y -
                    panelHeight *
                    0.16
            )


        // PAUSE SCREEN

        pauseOverlay.size =
        size


        pauseOverlay.position =
            CGPoint(
                x:
                    size.width /
                    2,

                y:
                    size.height /
                    2
            )


        pausedText.fontSize =
            clamp(
                safe.height *
                0.08,

                min:
                    26,

                max:
                    48
            )


        pausedText.position =
            CGPoint(
                x:
                    safe.midX,

                y:
                    safe.midY
            )
    }


    // MARK: - Physics

    private func configurePlayerPhysics() {

        guard
            player.size.width > 0,
            player.size.height > 0

        else {

            return
        }


        let bodySize =
            CGSize(
                width:
                    player.size.width *
                    0.62,

                height:
                    player.size.height *
                    0.72
            )


        let body =
            SKPhysicsBody(
                rectangleOf:
                    bodySize
            )


        body.isDynamic =
        false


        body.categoryBitMask =
        playerCategory


        body.contactTestBitMask =
        fireCategory


        body.collisionBitMask =
        0


        player.physicsBody =
        body
    }


    // MARK: - Game Loop

    override func update(
        _ currentTime: TimeInterval
    ) {

        if lastUpdateTime ==
            0 {

            lastUpdateTime =
            currentTime


            return
        }


        let delta =
            min(
                currentTime -
                lastUpdateTime,

                0.05
            )


        lastUpdateTime =
        currentTime


        guard
            !isGamePaused,
            !hasGameEnded

        else {

            return
        }


        spawnTimer +=
        delta


        if spawnTimer >=
            currentSpawnInterval {

            spawnTimer =
            0


            spawnFireball()
        }


        updateFireballs(
            deltaTime:
                delta
        )
    }


    // MARK: - Difficulty

    private var currentSpawnInterval:
    TimeInterval {

        let decrease =
            Double(score) *
            0.014


        return max(
            0.30,
            0.92 -
            decrease
        )
    }


    private var currentBaseFireSpeed:
    CGFloat {

        let extra =
            min(
                CGFloat(score) *
                0.007,

                0.48
            )


        return size.height *
        (
            0.47 +
            extra
        )
    }


    // MARK: - Fireballs

    private func spawnFireball() {

        let texture =
            SKTexture(
                imageNamed:
                    "fireball"
            )


        texture.filteringMode =
        .linear


        let fireHeight =
            clamp(
                size.height *
                CGFloat.random(
                    in:
                        0.11...0.15
                ),

                min:
                    46,

                max:
                    90
            )


        let fireSize =
            fittedTextureSize(
                texture:
                    texture,

                targetHeight:
                    fireHeight
            )


        let fire =
            SKSpriteNode(
                texture:
                    texture
            )


        fire.size =
        fireSize


        fire.name =
        "fire"


        fire.zPosition =
        15


        let safe =
        safeContentFrame


        let minX =
            safe.minX +
            fireSize.width *
            0.55


        let maxX =
            safe.maxX -
            fireSize.width *
            0.55


        guard maxX >
                minX

        else {

            return
        }


        fire.position =
            CGPoint(
                x:
                    CGFloat.random(
                        in:
                            minX...maxX
                    ),

                y:
                    size.height +
                    fireHeight
            )


        let speed =
            currentBaseFireSpeed *
            CGFloat.random(
                in:
                    0.90...1.18
            )


        fire.userData =
        NSMutableDictionary()


        fire.userData?["speed"] =
            NSNumber(
                value:
                    Double(speed)
            )


        let radius =
            min(
                fireSize.width,
                fireSize.height
            ) *
            0.30


        let body =
            SKPhysicsBody(
                circleOfRadius:
                    radius
            )


        body.isDynamic =
        true


        body.affectedByGravity =
        false


        body.categoryBitMask =
        fireCategory


        body.contactTestBitMask =
        playerCategory


        body.collisionBitMask =
        0


        body.usesPreciseCollisionDetection =
        true


        fire.physicsBody =
        body


        // FIRE GLOW

        let glow =
            SKSpriteNode(
                imageNamed:
                    "particle_fire"
            )


        glow.size =
            CGSize(
                width:
                    fireSize.width *
                    1.35,

                height:
                    fireSize.height *
                    1.35
            )


        glow.alpha =
        0.58


        glow.zPosition =
        -1


        fire.addChild(
            glow
        )


        glow.run(
            .repeatForever(
                .rotate(
                    byAngle:
                        .pi *
                        2,

                    duration:
                        1.3
                )
            )
        )


        worldNode.addChild(
            fire
        )
    }


    private func updateFireballs(
        deltaTime: TimeInterval
    ) {

        let fireballs =
            worldNode.children.filter {

                $0.name ==
                "fire"
            }


        for node in fireballs {

            guard
                let fire =
                    node as?
                    SKSpriteNode

            else {

                continue
            }


            let speed:
            CGFloat


            if let number =
                fire.userData?["speed"]
                as?
                NSNumber {

                speed =
                    CGFloat(
                        truncating:
                            number
                    )

            } else {

                speed =
                currentBaseFireSpeed
            }


            fire.position.y -=
                speed *
                CGFloat(
                    deltaTime
                )


            fire.zRotation =
                sin(
                    fire.position.y *
                    0.015
                ) *
                0.05


            if fire.position.y <
                -fire.size.height {

                let x =
                fire.position.x


                fire.removeFromParent()


                dodgeSuccessful(
                    atX:
                        x
                )
            }
        }
    }


    // MARK: - Successful Dodge

    private func dodgeSuccessful(
        atX x: CGFloat
    ) {

        score +=
        1


        // 🔊 SCORE SOUND

        AudioManager.shared.playSound(
            .score,
            volume:
                0.45
        )


        let effect =
            SKSpriteNode(
                imageNamed:
                    "score_text"
            )


        effect.zPosition =
        120


        let effectHeight =
            clamp(
                size.height *
                0.07,

                min:
                    26,

                max:
                    46
            )


        if let texture =
            effect.texture {

            effect.size =
                fittedTextureSize(
                    texture:
                        texture,

                    targetHeight:
                        effectHeight
                )
        }


        effect.position =
            CGPoint(
                x:
                    x,

                y:
                    player.position.y +
                    player.size.height *
                    0.70
            )


        addChild(
            effect
        )


        let move =
            SKAction.moveBy(
                x:
                    0,

                y:
                    size.height *
                    0.08,

                duration:
                    0.45
            )


        let fade =
            SKAction.fadeOut(
                withDuration:
                    0.45
            )


        effect.run(
            .sequence(
                [

                    .group(
                        [
                            move,
                            fade
                        ]
                    ),

                    .removeFromParent()
                ]
            )
        )


        // Her 5 skorda PHEW

        if score %
            5 ==
            0 {

            showPhewEffect()
        }
    }


    // MARK: - Phew Effect

    private func showPhewEffect() {

        // 🔊 PHEW SOUND

        AudioManager.shared.playSound(
            .phew,
            volume:
                0.70
        )


        let effect =
            SKSpriteNode(
                imageNamed:
                    "phew_text"
            )


        effect.zPosition =
        125


        let h =
            clamp(
                size.height *
                0.11,

                min:
                    38,

                max:
                    68
            )


        if let texture =
            effect.texture {

            effect.size =
                fittedTextureSize(
                    texture:
                        texture,

                    targetHeight:
                        h
                )
        }


        effect.position =
            CGPoint(
                x:
                    player.position.x +
                    player.size.width *
                    0.8,

                y:
                    player.position.y +
                    player.size.height *
                    0.5
            )


        effect.setScale(
            0.2
        )


        addChild(
            effect
        )


        effect.run(
            .sequence(
                [

                    .scale(
                        to:
                            1,

                        duration:
                            0.16
                    ),

                    .wait(
                        forDuration:
                            0.22
                    ),

                    .group(
                        [

                            .fadeOut(
                                withDuration:
                                    0.20
                            ),

                            .scale(
                                to:
                                    1.25,

                                duration:
                                    0.20
                            )
                        ]
                    ),

                    .removeFromParent()
                ]
            )
        )
    }


    // MARK: - Collision

    func didBegin(
        _ contact: SKPhysicsContact
    ) {

        guard
            !hasGameEnded

        else {

            return
        }


        let combined =
            contact.bodyA
                .categoryBitMask
            |
            contact.bodyB
                .categoryBitMask


        guard combined ==
                (
                    playerCategory |
                    fireCategory
                )

        else {

            return
        }


        hasGameEnded =
        true


        // 💥 HIT SOUND

        AudioManager.shared.playSound(
            .hit,
            volume:
                1.0
        )


        let fireNode =
            contact.bodyA
                .categoryBitMask ==
            fireCategory
            ?
            contact.bodyA.node
            :
            contact.bodyB.node


        fireNode?
            .removeFromParent()


        showHitEffect()

        showPanicCharacter()


        // BEST SCORE SAVE

        GameData.shared
            .registerScore(
                score
            )


        run(
            .sequence(
                [

                    .wait(
                        forDuration:
                            0.42
                    ),

                    .run {
                        [weak self] in

                        self?
                            .showGameOver()
                    }
                ]
            )
        )
    }


    // MARK: - Hit Effect

    private func showHitEffect() {

        let hit =
            SKSpriteNode(
                imageNamed:
                    "hit_effect"
            )


        hit.zPosition =
        150


        if let texture =
            hit.texture {

            hit.size =
                fittedTextureSize(
                    texture:
                        texture,

                    targetHeight:
                        player.size.height *
                        1.25
                )
        }


        hit.position =
        player.position


        worldNode.addChild(
            hit
        )


        hit.setScale(
            0.2
        )


        hit.run(
            .sequence(
                [

                    .scale(
                        to:
                            1.1,

                        duration:
                            0.12
                    ),

                    .group(
                        [

                            .scale(
                                to:
                                    1.4,

                                duration:
                                    0.25
                            ),

                            .fadeOut(
                                withDuration:
                                    0.25
                            )
                        ]
                    ),

                    .removeFromParent()
                ]
            )
        )
    }


    // MARK: - Panic

    private func showPanicCharacter() {

        guard
            !GameData.shared
                .hasCustomCharacter

        else {

            return
        }


        player.removeAction(
            forKey:
                "running"
        )


        let textureName =
            currentDirection ==
            .left
            ?
            "scary_run_left"
            :
            "scary_run_right"


        player.texture =
            SKTexture(
                imageNamed:
                    textureName
            )
    }


    // MARK: - Game Over

    private func showGameOver() {

        let scene =
            GameOverScene(
                size:
                    size,

                score:
                    score
            )


        openScene(
            scene,

            transition:
                .crossFade(
                    withDuration:
                        0.35
                )
        )
    }


    // MARK: - Player Movement

    private func movePlayer(
        toX targetX: CGFloat
    ) {

        guard
            !isGamePaused,
            !hasGameEnded

        else {

            return
        }


        let safe =
        safeContentFrame


        let minX =
            safe.minX +
            player.size.width *
            0.50


        let maxX =
            safe.maxX -
            player.size.width *
            0.50


        let oldX =
        player.position.x


        let newX =
            clamp(
                targetX,

                min:
                    minX,

                max:
                    maxX
            )


        player.position.x =
        newX


        let difference =
            newX -
            oldX


        if difference >
            2 {

            startRunAnimation(
                direction:
                    .right
            )

        } else if difference <
                    -2 {

            startRunAnimation(
                direction:
                    .left
            )
        }
    }


    // MARK: - Run Animation

    private func startRunAnimation(
        direction: RunDirection
    ) {

        guard
            !GameData.shared
                .hasCustomCharacter

        else {

            return
        }


        if currentDirection ==
            direction,

           player.action(
            forKey:
                "running"
           ) != nil {

            return
        }


        currentDirection =
        direction


        let names:
        [String]


        switch direction {

        case .left:

            names =
            [
                "happy_run_left",
                "happy_run_left2"
            ]


        case .right:

            names =
            [
                "happy_run_right",
                "happy_run_right2"
            ]


        case .none:

            stopRunAnimation()

            return
        }


        let textures =
            names.map {

                SKTexture(
                    imageNamed:
                        $0
                )
            }


        let animation =
            SKAction.animate(
                with:
                    textures,

                timePerFrame:
                    0.11,

                resize:
                    false,

                restore:
                    false
            )


        player.run(
            .repeatForever(
                animation
            ),

            withKey:
                "running"
        )
    }


    private func stopRunAnimation() {

        currentDirection =
        .none


        player.removeAction(
            forKey:
                "running"
        )


        guard
            !GameData.shared
                .hasCustomCharacter

        else {

            return
        }


        player.texture =
            SKTexture(
                imageNamed:
                    "character_default"
            )
    }


    // MARK: - Pause

    private func togglePause() {

        guard
            !hasGameEnded

        else {

            return
        }


        // 🔊 PAUSE SOUND

        AudioManager.shared.playSound(
            .pause,
            volume:
                0.75
        )


        isGamePaused.toggle()


        pauseOverlay.isHidden =
        !isGamePaused


        pausedText.isHidden =
        !isGamePaused


        pauseLabel.text =
            isGamePaused
            ?
            "▶"
            :
            "Ⅱ"


        worldNode.speed =
            isGamePaused
            ?
            0
            :
            1


        physicsWorld.speed =
            isGamePaused
            ?
            0
            :
            1


        if isGamePaused {

            stopRunAnimation()


            // 🎵 MUSIC PAUSE

            AudioManager.shared.pauseMusic()

        } else {

            // 🎵 MUSIC RESUME

            AudioManager.shared.resumeMusic()
        }
    }


    // MARK: - Touch Began

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard
            let touch =
                touches.first

        else {

            return
        }


        let location =
            touch.location(
                in:
                    self
            )


        if actionName(
            at:
                location
        ) ==
            "pause" {

            togglePause()

            return
        }


        guard
            !isGamePaused,
            !hasGameEnded

        else {

            return
        }


        isDraggingPlayer =
        true


        movePlayer(
            toX:
                location.x
        )
    }


    // MARK: - Touch Moved

    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard
            isDraggingPlayer,

            let touch =
                touches.first

        else {

            return
        }


        let location =
            touch.location(
                in:
                    self
            )


        movePlayer(
            toX:
                location.x
        )
    }


    // MARK: - Touch Ended

    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        isDraggingPlayer =
        false


        stopRunAnimation()
    }


    // MARK: - Touch Cancelled

    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        isDraggingPlayer =
        false


        stopRunAnimation()
    }
}
