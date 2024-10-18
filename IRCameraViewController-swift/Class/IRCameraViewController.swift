//
//  IRCameraViewController.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2023/1/14.
//  Copyright © 2023  All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// MARK: - Protocol Declaration
protocol IRCameraViewControllerDelegate: AnyObject {
    func didFinishPickingImage(_ image: UIImage)
}

enum IRCameraOption: String {
    case hiddenToggleButton
    case hiddenAlbumButton
    case hiddenFilterButton
    case saveImageToAlbum
    case useOriginalAspect
}

class IRCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    weak var delegate: IRCameraDelegate?
    var camera: IRCamera!
    var wasLoaded = false

    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var topLeftView: UIImageView!
    @IBOutlet weak var topRightView: UIImageView!
    @IBOutlet weak var bottomLeftView: UIImageView!
    @IBOutlet weak var bottomRightView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var gridButton: IRTintedButton!
    @IBOutlet weak var toggleButton: IRTintedButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var closeButton: IRTintedButton!
    @IBOutlet weak var shotButton: IRTintedButton!
    @IBOutlet weak var albumButton: IRTintedButton!
    @IBOutlet weak var slideUpView: IRCameraSlideView!
    @IBOutlet weak var slideDownView: IRCameraSlideView!

    @IBOutlet weak var bottomViewHeightFixed: NSLayoutConstraint!
    @IBOutlet weak var toggleButtonWidth: NSLayoutConstraint!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        if devices.count > 1 {
            if IRCamera.getOption(.hiddenToggleButton) as? Bool == true {
                toggleButton.isHidden = true
                toggleButtonWidth.constant = 0
            }
        } else {
            if IRCamera.getOption(.hiddenToggleButton) as? Bool == true {
                toggleButton.isHidden = true
                toggleButtonWidth.constant = 0
            }
        }

        if IRCamera.getOption(.hiddenAlbumButton) as? Bool == true {
            albumButton.isHidden = true
        }

        if IRCamera.getOption(.useOriginalAspect) as? Bool == true {
            bottomViewHeightFixed.isActive = true
        } else {
            bottomViewHeightFixed.isActive = false
        }

        albumButton.layer.cornerRadius = 10
        albumButton.layer.masksToBounds = true

        closeButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraClose"), for: .normal)
        shotButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraShot"), for: .normal)
        albumButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraRoll"), for: .normal)
        gridButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraGrid"), for: .normal)
        toggleButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraToggle"), for: .normal)

        camera = IRCamera()
        camera.setup(with: flashButton)

        captureView.backgroundColor = .clear

        topLeftView.transform = CGAffineTransform(rotationAngle: 0)
        topRightView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        bottomLeftView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        bottomRightView.transform = CGAffineTransform(rotationAngle: .pi)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChangeNotification), name: UIDevice.orientationDidChangeNotification, object: nil)

        separatorView.isHidden = false
        actionsView.isHidden = true
        topLeftView.isHidden = true
        topRightView.isHidden = true
        bottomLeftView.isHidden = true
        bottomRightView.isHidden = true
        gridButton.isEnabled = false
        toggleButton.isEnabled = false
        shotButton.isEnabled = false
        albumButton.isEnabled = false
        flashButton.isEnabled = false

        camera.startRunning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        deviceOrientationDidChangeNotification()

        separatorView.isHidden = true

        IRCameraSlideView.hideSlideUpView(slideUpView, slideDownView: slideDownView, at: captureView) {
            self.actionsView.isHidden = false
            self.gridButton.isEnabled = true
            self.toggleButton.isEnabled = true
            self.shotButton.isEnabled = true
            self.albumButton.isEnabled = true
            self.flashButton.isEnabled = true
        }

        if !wasLoaded {
            wasLoaded = true
            camera.insertSublayer(withCaptureView: captureView, at: self.view)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)

        camera.stopRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let photo = IRAlbum.image(withMediaInfo: info) else { return }

        if let delegate, delegate.customizePhotoProcessingView() {
            let viewController = IRPhotoViewController.newWithDelegate(delegate, photo: photo)
            viewController.albumPhoto = true
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(viewController, animated: true)
            }

            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: nil)
            }

        } else {
            delegate?.cameraDidTakePhoto(photo)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func closeTapped() {
        delegate?.cameraDidCancel()
    }

    @IBAction func gridTapped() {
        camera.displayGridView()
    }

    @IBAction func flashTapped() {
        camera.changeFlashMode(with: flashButton)
    }

    @IBAction func shotTapped() {
        #if !TARGET_IPHONE_SIMULATOR
        shotButton.isEnabled = false
        albumButton.isEnabled = false

        let deviceOrientation = UIDevice.current.orientation
        let videoOrientation = videoOrientationForDeviceOrientation(deviceOrientation)

        let cropSize: CGSize = IRCamera.getOption(.useOriginalAspect) as? Bool == true ? .zero : captureView.frame.size

        let group = DispatchGroup()
        var photo: UIImage?

        group.enter()
        viewWillDisappearWithCompletion {
            group.leave()
        }

        group.enter()
        camera.takePhoto(with: captureView, videoOrientation: videoOrientation, cropSize: cropSize) { takenPhoto in
            photo = takenPhoto
            group.leave()
        }

        group.notify(queue: .main) {
            guard let photo = photo else { return }
            if let delegate = self.delegate, delegate.customizePhotoProcessingView() {
                delegate.cameraDidTakePhoto(photo)
            } else {
                let viewController = IRPhotoViewController.newWithDelegate(self.delegate, photo: photo)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        #endif
    }

    @IBAction func albumTapped() {
        shotButton.isEnabled = false
        albumButton.isEnabled = false

        viewWillDisappearWithCompletion {
            let pickerController = IRAlbum.imagePickerController(withDelegate: self)
            pickerController.popoverPresentationController?.sourceView = self.albumButton
            self.present(pickerController, animated: true, completion: nil)
        }
    }

    @IBAction func toggleTapped() {
        camera.toggle(with: flashButton)
    }

    @IBAction func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: captureView)
        camera.focusView(captureView, in: touchPoint)
    }

    // MARK: - Private methods

    @objc func deviceOrientationDidChangeNotification() {
        let orientation = UIDevice.current.orientation
        let degrees: Int

        switch orientation {
        case .faceUp, .portrait, .unknown:
            degrees = 0
        case .landscapeLeft:
            degrees = 90
        case .faceDown, .portraitUpsideDown:
            degrees = 180
        case .landscapeRight:
            degrees = 270
        }

        let radians = CGFloat(degrees) * CGFloat.pi / 180
        let transform = CGAffineTransform(rotationAngle: radians)

        UIView.animate(withDuration: 0.5) {
            self.gridButton.transform = transform
            self.toggleButton.transform = transform
            self.albumButton.transform = transform
            self.flashButton.transform = transform
        }
    }

    func videoOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var result = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue) ?? .portrait

        switch deviceOrientation {
        case .landscapeLeft:
            result = .landscapeRight
        case .landscapeRight:
            result = .landscapeLeft
        default:
            break
        }

        return result
    }

    func viewWillDisappearWithCompletion(_ completion: @escaping () -> Void) {
        actionsView.isHidden = true

        IRCameraSlideView.showSlideUpView(slideUpView, slideDownView: slideDownView, at: captureView) {
            completion()
        }
    }
}
