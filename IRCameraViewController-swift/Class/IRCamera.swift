//
//  IRCamera.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2023/1/12.
//  Copyright © 2023  All rights reserved.
//        

import UIKit
import AVFoundation

public protocol IRCameraDelegate: NSObject {
    func cameraDidCancel()
    func cameraDidTakePhoto(_ image: UIImage)
    func cameraDidSavePhoto(_ error: Error?)
    func cameraDidSavePhoto(at path: URL)
    func cameraWillTakePhoto()
    func customizePhotoProcessingView() -> Bool
}

public extension IRCameraDelegate {
    func cameraDidSavePhoto(_ error: Error?) { }
    func cameraDidSavePhoto(at path: URL) { }
    func cameraWillTakePhoto() { }
    func customizePhotoProcessingView() -> Bool { return false }
}

class IRCamera: NSObject {

    private let session: AVCaptureSession
    private var previewLayer: AVCaptureVideoPreviewLayer
    private let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()

    private var rawFileURL: URL?
    private var compressedData: Data?

    init(session: AVCaptureSession = AVCaptureSession()) {
        self.session = session
        self.session.sessionPreset = .photo
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
    }

    private static var optionDictionary: [String: Any]?

    static func newCamera() -> IRCamera {
        return IRCamera()
    }

    static func cameraWithFlashButton(_ flashButton: UIButton) -> IRCamera {
        let camera = IRCamera.newCamera()
        camera.setup(with: flashButton)
        return camera
    }

    static func cameraWithFlashButton(_ flashButton: UIButton, devicePosition: AVCaptureDevice.Position) -> IRCamera {
        let camera = IRCamera.newCamera()
        camera.setup(with: flashButton)
        return camera
    }

    // MARK: - Option Management
    static func setOption(_ option: String, value: Any) {
        if optionDictionary == nil {
            initOptions()
        }
        optionDictionary?[option] = value
    }

    static func getOption(_ option: IRCameraOption) -> Any? {
        if optionDictionary == nil {
            initOptions()
        }
        return optionDictionary?[option.rawValue]
    }

    static func initOptions() {
        optionDictionary = [String: Any]()
    }

    // MARK: - Camera Controls
    func startRunning() {
        session.startRunning()
    }

    func stopRunning() {
        session.stopRunning()
    }

    func insertSublayer(withCaptureView captureView: UIView, at rootView: UIView) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill

        let rootLayer = rootView.layer
        rootLayer.masksToBounds = true

        layer.frame = captureView.frame

        rootLayer.insertSublayer(layer, at: 0)
        self.previewLayer = layer

        let index = captureView.subviews.count - 1
        captureView.insertSubview(self.gridView, at: index)
    }

    func displayGridView() {
        // Logic to manage grid view display
    }

    func changeFlashMode(with button: UIButton) {
        // Logic to change flash mode
    }

    func focusView(_ focusView: UIView, in touchPoint: CGPoint) {
        // Focus the camera on the touched point
    }

    func takePhoto(with captureView: UIView, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // Logic to take a photo with given settings
    }

    func toggle(with flashButton: UIButton) {
        // Logic to toggle camera settings
    }

    // MARK: - Lazy Initializers
    lazy var gridView: IRCameraGridView = {
        var frame = self.previewLayer.frame
        frame.origin = .zero

        let view = IRCameraGridView(frame: frame)
        view.numberOfColumns = 2
        view.numberOfRows = 2
        return view
    }()

    func setup(with flashButton: UIButton) {
        // setup device
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }

        do {
            try device.lockForConfiguration()
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }

            if device.isSmoothAutoFocusSupported {
                device.isSmoothAutoFocusEnabled = true
            }

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus;
            }

            device.exposureMode = .continuousAutoExposure;

            device.unlockForConfiguration()
        } catch {

        }

        // add device input to session
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else { return }
        self.session.addInput(deviceInput)

        // add output to session
//        let outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        let outputSettings: AVCapturePhotoSettings
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            outputSettings = AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            outputSettings = AVCapturePhotoSettings()
        }

//        let outputSettings = AVCapturePhotoSettings()
//        outputSettings.livePhotoVideoCodecType = .jpeg

//        self.photoOutput.outputSettings = outputSettings;
        self.photoOutput.capturePhoto(with: outputSettings, delegate: self)

        guard self.session.canAddOutput(self.photoOutput) else { return }
        self.session.addOutput(self.photoOutput)

        // setup flash button
//        [IRCameraFlash flashModeWithCaptureSession:_session andButton:flashButton];
    }
}

extension IRCamera: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(error!)")
            return
        }

        // Access the file data representation of this photo.
        guard let photoData = photo.fileDataRepresentation() else {
            print("No photo data to write.")
            return
        }

        compressedData = photoData
    }
}
