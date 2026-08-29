import UIKit
import SpriteKit
import PhotosUI

final class GameViewController:
UIViewController {

    private var photoPickerObserver:
    NSObjectProtocol?


    private var didPresentInitialScene =
    false


    // MARK: - Loading UI

    private let processingView =
        UIView()


    private let processingIndicator =
        UIActivityIndicatorView(
            style:
                .large
        )


    private let processingLabel =
        UILabel()


    // MARK: - View

    override func loadView() {

        let skView =
            SKView(
                frame:
                    .zero
            )


        skView.backgroundColor =
        .black


        view =
        skView
    }


    override func viewDidLoad() {
        super.viewDidLoad()


        guard let skView =
                view as? SKView else {

            return
        }


        skView.ignoresSiblingOrder =
        true


        skView.preferredFramesPerSecond =
        60


        skView.isMultipleTouchEnabled =
        false


        #if DEBUG

        skView.showsFPS =
        false


        skView.showsNodeCount =
        false

        #endif


        setupProcessingView()

        observePhotoPickerRequests()
    }


    // MARK: - Loading Screen

    private func setupProcessingView() {

        processingView
            .translatesAutoresizingMaskIntoConstraints =
        false


        processingView.backgroundColor =
            UIColor.black
                .withAlphaComponent(
                    0.72
                )


        processingView.isHidden =
        true


        view.addSubview(
            processingView
        )


        NSLayoutConstraint.activate(
            [

                processingView
                    .leadingAnchor
                    .constraint(
                        equalTo:
                            view.leadingAnchor
                    ),

                processingView
                    .trailingAnchor
                    .constraint(
                        equalTo:
                            view.trailingAnchor
                    ),

                processingView
                    .topAnchor
                    .constraint(
                        equalTo:
                            view.topAnchor
                    ),

                processingView
                    .bottomAnchor
                    .constraint(
                        equalTo:
                            view.bottomAnchor
                    )
            ]
        )


        // Spinner

        processingIndicator
            .translatesAutoresizingMaskIntoConstraints =
        false


        processingIndicator.color =
        .white


        processingView.addSubview(
            processingIndicator
        )


        // Text

        processingLabel
            .translatesAutoresizingMaskIntoConstraints =
        false


        processingLabel.text =
        "Preparing character..."


        processingLabel.textColor =
        .white


        processingLabel.font =
            UIFont.systemFont(
                ofSize:
                    20,

                weight:
                    .bold
            )


        processingLabel.textAlignment =
        .center


        processingView.addSubview(
            processingLabel
        )


        NSLayoutConstraint.activate(
            [

                processingIndicator
                    .centerXAnchor
                    .constraint(
                        equalTo:
                            processingView.centerXAnchor
                    ),

                processingIndicator
                    .centerYAnchor
                    .constraint(
                        equalTo:
                            processingView.centerYAnchor,

                        constant:
                            -20
                    ),


                processingLabel
                    .topAnchor
                    .constraint(
                        equalTo:
                            processingIndicator.bottomAnchor,

                        constant:
                            18
                    ),

                processingLabel
                    .centerXAnchor
                    .constraint(
                        equalTo:
                            processingView.centerXAnchor
                    )
            ]
        )
    }


    private func showProcessing() {

        processingView.isHidden =
        false


        processingIndicator
            .startAnimating()


        view.bringSubviewToFront(
            processingView
        )
    }


    private func hideProcessing() {

        processingIndicator
            .stopAnimating()


        processingView.isHidden =
        true
    }


    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()


        guard let skView =
                view as? SKView else {

            return
        }


        // İlk sahne sadece landscape olduğunda açılsın

        if !didPresentInitialScene {

            guard
                skView.bounds.width >
                skView.bounds.height

            else {

                return
            }


            didPresentInitialScene =
            true


            let menuScene =
                MainMenuScene(
                    size:
                        skView.bounds.size
                )


            menuScene.scaleMode =
            .resizeFill


            skView.presentScene(
                menuScene
            )


            DispatchQueue.main.async {
                [weak self] in

                self?
                    .refreshCurrentScene()
            }


            return
        }


        guard let scene =
                skView.scene else {

            return
        }


        if scene.size !=
            skView.bounds.size {

            scene.size =
            skView.bounds.size
        }


        if let responsiveScene =
            scene as?
            ResponsiveScene {

            responsiveScene
                .refreshLayout()
        }
    }


    override func viewSafeAreaInsetsDidChange() {
        super
            .viewSafeAreaInsetsDidChange()


        refreshCurrentScene()
    }


    override func viewWillTransition(
        to size: CGSize,
        with coordinator:
        UIViewControllerTransitionCoordinator
    ) {

        super
            .viewWillTransition(
                to:
                    size,

                with:
                    coordinator
            )


        coordinator.animate(
            alongsideTransition:
                nil

        ) { [weak self] _ in

            self?
                .refreshCurrentScene()
        }
    }


    private func refreshCurrentScene() {

        guard
            let skView =
                view as? SKView,

            let scene =
                skView.scene

        else {

            return
        }


        if scene.size !=
            skView.bounds.size {

            scene.size =
            skView.bounds.size
        }


        if let responsiveScene =
            scene as?
            ResponsiveScene {

            responsiveScene
                .refreshLayout()
        }
    }


    // MARK: - Photo Picker Observer

    private func observePhotoPickerRequests() {

        photoPickerObserver =
            NotificationCenter.default
                .addObserver(
                    forName:
                        .requestCharacterPhoto,

                    object:
                        nil,

                    queue:
                        .main

                ) { [weak self] _ in

                    self?
                        .openPhotoPicker()
                }
    }


    // MARK: - Open Gallery

    private func openPhotoPicker() {

        var configuration =
            PHPickerConfiguration(
                photoLibrary:
                    .shared()
            )


        configuration.filter =
        .images


        configuration.selectionLimit =
        1


        let picker =
            PHPickerViewController(
                configuration:
                    configuration
            )


        picker.delegate =
        self


        present(
            picker,
            animated:
                true
        )
    }


    // MARK: - Process Person

    private func processSelectedImage(
        _ image: UIImage
    ) {

        showProcessing()


        NotificationCenter.default
            .post(
                name:
                    .characterProcessingStarted,

                object:
                    nil
            )


        guard
            #available(
                iOS 15.0,
                *
            )

        else {

            hideProcessing()

            showError(
                title:
                    "Not supported",

                message:
                    "Background removal requires iOS 15 or later."
            )

            return
        }


        /*
         Vision işlemini main thread'de
         yapmıyoruz.

         Yoksa oyun birkaç saniye donabilir.
         */

        DispatchQueue.global(
            qos:
                .userInitiated
        ).async {


            do {

                let cutout =
                    try PersonCutoutManager
                        .shared
                        .makePersonCutout(
                            from:
                                image
                        )


                DispatchQueue.main.async {
                    [weak self] in


                    GameData.shared
                        .saveCustomCharacter(
                            cutout
                        )


                    self?
                        .hideProcessing()


                    NotificationCenter.default
                        .post(
                            name:
                                .characterProcessingFinished,

                            object:
                                nil
                        )
                }


            } catch {

                DispatchQueue.main.async {
                    [weak self] in


                    self?
                        .hideProcessing()


                    NotificationCenter.default
                        .post(
                            name:
                                .characterProcessingFailed,

                            object:
                                nil
                        )


                    self?
                        .showError(
                            title:
                                "Person Not Found",

                            message:
                                """
                                I couldn’t isolate the person in the photo.
                                Try another photo where a single person is clearly visible, preferably with most of their body in frame.
                                """
                        )
                }
            }
        }
    }


    // MARK: - Error

    private func showError(
        title: String,
        message: String
    ) {

        let alert =
            UIAlertController(
                title:
                    title,

                message:
                    message,

                preferredStyle:
                    .alert
            )


        alert.addAction(
            UIAlertAction(
                title:
                    "Okay",

                style:
                    .default
            )
        )


        present(
            alert,
            animated:
                true
        )
    }


    // MARK: - Cleanup

    deinit {

        if let photoPickerObserver {

            NotificationCenter.default
                .removeObserver(
                    photoPickerObserver
                )
        }
    }


    // MARK: - Landscape

    override var supportedInterfaceOrientations:
    UIInterfaceOrientationMask {

        .landscape
    }


    override var preferredInterfaceOrientationForPresentation:
    UIInterfaceOrientation {

        .landscapeRight
    }


    override var shouldAutorotate:
    Bool {

        true
    }


    // MARK: - Full Screen

    override var prefersStatusBarHidden:
    Bool {

        true
    }


    override var prefersHomeIndicatorAutoHidden:
    Bool {

        true
    }
}


// MARK: - PHPicker

extension GameViewController:
PHPickerViewControllerDelegate {

    func picker(
        _ picker:
        PHPickerViewController,

        didFinishPicking results:
        [PHPickerResult]
    ) {

        picker.dismiss(
            animated:
                true
        )


        guard
            let provider =
                results.first?
                    .itemProvider,

            provider.canLoadObject(
                ofClass:
                    UIImage.self
            )

        else {

            return
        }


        provider.loadObject(
            ofClass:
                UIImage.self

        ) { [weak self] object, error in


            guard
                error == nil,

                let image =
                    object as?
                    UIImage

            else {

                return
            }


            DispatchQueue.main.async {

                self?
                    .processSelectedImage(
                        image
                    )
            }
        }
    }
}
