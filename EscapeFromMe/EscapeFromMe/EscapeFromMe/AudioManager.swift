import AVFoundation

final class AudioManager: NSObject, AVAudioPlayerDelegate {

    static let shared = AudioManager()

    // MARK: - Music

    enum Music: String {
        case menu = "menu_music"
        case game = "game_music"
    }

    // MARK: - Sound Effects

    enum Sound: String {
        case button = "button_click"
        case pause = "pause"
        case score = "score"
        case phew = "phew"
        case hit = "hit"
        case gameOver = "game_over"
    }


    // MARK: - Players

    private var musicPlayer: AVAudioPlayer?

    /*
     Aynı anda birden fazla kısa efekt
     çalabilmek için array kullanıyoruz.
     */
    private var effectPlayers: [AVAudioPlayer] = []

    private var currentMusic: Music?


    // MARK: - Volume

    var musicVolume: Float = 0.30 {
        didSet {
            musicPlayer?.volume = musicVolume
        }
    }

    var soundVolume: Float = 0.80


    // MARK: - Settings

    private let musicEnabledKey =
        "EscapeFromMeMusicEnabled"

    private let soundEnabledKey =
        "EscapeFromMeSoundEnabled"

    private let audioSettingsCreatedKey =
        "EscapeFromMeAudioSettingsCreated"


    private(set) var isMusicEnabled = true
    private(set) var isSoundEnabled = true


    // MARK: - Init

    private override init() {

        super.init()

        loadSettings()
        configureAudioSession()
    }


    // MARK: - Audio Session

    private func configureAudioSession() {

        do {

            /*
             .ambient kullanıyoruz.

             Böylece telefon sessizdeyse
             oyun da sessiz olur.

             Bir oyun için doğal iOS davranışı.
             */

            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: []
            )

            try AVAudioSession.sharedInstance().setActive(true)

        } catch {

            print("❌ Audio Session Error:", error)
        }
    }


    // MARK: - Find Audio File

    /*
     Xcode bazen dosyanın uzantısını
     soldaki menüde göstermiyor.

     Bu fonksiyon:
     wav
     mp3
     m4a
     caf
     aac

     uzantılarını otomatik arıyor.
     */

    private func audioURL(
        named name: String
    ) -> URL? {

        let extensions = [
            "wav",
            "mp3",
            "m4a",
            "caf",
            "aac"
        ]

        for ext in extensions {

            if let url = Bundle.main.url(
                forResource: name,
                withExtension: ext
            ) {

                return url
            }
        }

        print("❌ Ses dosyası bulunamadı: \(name)")

        return nil
    }


    // MARK: - MUSIC

    func playMusic(
        _ music: Music
    ) {

        guard isMusicEnabled else {
            return
        }


        /*
         Aynı müzik zaten çalıyorsa
         tekrar başlatma.
         */

        if currentMusic == music,
           let player = musicPlayer,
           player.isPlaying {

            return
        }


        guard let url =
                audioURL(
                    named: music.rawValue
                ) else {

            return
        }


        do {

            musicPlayer?.stop()


            let player =
                try AVAudioPlayer(
                    contentsOf: url
                )


            // Sonsuz loop
            player.numberOfLoops = -1

            player.volume =
            musicVolume

            player.prepareToPlay()

            player.play()


            musicPlayer =
            player

            currentMusic =
            music


        } catch {

            print(
                "❌ Müzik açılamadı:",
                error
            )
        }
    }


    func stopMusic() {

        musicPlayer?.stop()

        musicPlayer = nil

        currentMusic = nil
    }


    func pauseMusic() {

        musicPlayer?.pause()
    }


    func resumeMusic() {

        guard isMusicEnabled else {
            return
        }

        musicPlayer?.play()
    }


    // MARK: - SOUND EFFECT

    func playSound(
        _ sound: Sound,
        volume: Float? = nil
    ) {

        guard isSoundEnabled else {
            return
        }


        guard let url =
                audioURL(
                    named: sound.rawValue
                ) else {

            return
        }


        do {

            let player =
                try AVAudioPlayer(
                    contentsOf: url
                )


            player.delegate =
            self


            player.volume =
                volume ??
                soundVolume


            player.prepareToPlay()


            effectPlayers.append(
                player
            )


            player.play()


        } catch {

            print(
                "❌ Ses efekti açılamadı:",
                error
            )
        }
    }


    // MARK: - Effect Finished

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {

        effectPlayers.removeAll {
            $0 === player
        }
    }


    // MARK: - Music Settings

    func setMusicEnabled(
        _ enabled: Bool
    ) {

        isMusicEnabled =
        enabled


        UserDefaults.standard.set(
            enabled,
            forKey: musicEnabledKey
        )


        if enabled {

            if let currentMusic {

                playMusic(
                    currentMusic
                )
            }

        } else {

            musicPlayer?.stop()
            musicPlayer = nil
        }
    }


    func toggleMusic() {

        setMusicEnabled(
            !isMusicEnabled
        )
    }


    // MARK: - Sound Settings

    func setSoundEnabled(
        _ enabled: Bool
    ) {

        isSoundEnabled =
        enabled


        UserDefaults.standard.set(
            enabled,
            forKey: soundEnabledKey
        )


        if !enabled {

            for player in effectPlayers {

                player.stop()
            }


            effectPlayers.removeAll()
        }
    }


    func toggleSound() {

        setSoundEnabled(
            !isSoundEnabled
        )
    }


    // MARK: - Load Settings

    private func loadSettings() {

        let defaults =
        UserDefaults.standard


        /*
         Uygulama ilk defa çalışıyorsa
         Music ve Sound varsayılan açık.
         */

        if !defaults.bool(
            forKey:
                audioSettingsCreatedKey
        ) {

            defaults.set(
                true,
                forKey: musicEnabledKey
            )


            defaults.set(
                true,
                forKey: soundEnabledKey
            )


            defaults.set(
                true,
                forKey:
                    audioSettingsCreatedKey
            )
        }


        isMusicEnabled =
            defaults.bool(
                forKey: musicEnabledKey
            )


        isSoundEnabled =
            defaults.bool(
                forKey: soundEnabledKey
            )
    }
}
