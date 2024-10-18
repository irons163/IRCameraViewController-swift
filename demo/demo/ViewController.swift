//
//  ViewController.swift
//  demo
//
//  Created by Phil on 2020/9/30.
//  Copyright © 2020 Phil. All rights reserved.
//

import UIKit
import IRCameraViewController_swift

class ViewController: UIViewController, IRCameraDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var useCustomizePhotoProcessingView: Bool = false
    var vc: FilterViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let image = vc?.image {
            imageView.image = image
        }
    }

    @IBAction func addNewPhotoButtonClick(_ sender: Any) {
        /*
        IRCameraColor.tintColor = .white

        IRCamera.setOption(kIRCameraOptionSaveImageToAlbum, value: true)
        IRCamera.setOption(kIRCameraOptionUseOriginalAspect, value: true)
        IRCamera.setOption(kIRCameraOptionHiddenToggleButton, value: true)
        IRCamera.setOption(kIRCameraOptionHiddenAlbumButton, value: true)
        IRCamera.setOption(kIRCameraOptionHiddenFilterButton, value: true)
        */

        useCustomizePhotoProcessingView = false
        let cameraViewController = IRCameraNavigationController(with: self)
        present(cameraViewController, animated: true, completion: nil)
    }

    @IBAction func addNewPhotoWithCustomPhotoProcessingButtonClick(_ sender: Any) {
        useCustomizePhotoProcessingView = true
        let cameraViewController = IRCameraNavigationController(with: self)
        present(cameraViewController, animated: true, completion: nil)
    }

    // MARK: - IRCameraDelegate

    func cameraDidCancel() {
        dismiss(animated: true, completion: nil)
    }

    func dealWithImage(_ image: UIImage) {
        if !useCustomizePhotoProcessingView {
            vc = nil
            imageView.image = image
            dismiss()
            return
        }

        vc = storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController
        vc?.image = image
        dismiss()
        present(vc!, animated: true, completion: nil)
    }

    func cameraDidTakePhoto(_ image: UIImage) {
        dealWithImage(image)
    }

    func cameraDidSelectAlbumPhoto(_ image: UIImage) {
        dealWithImage(image)
    }

    func dismiss() {
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    func customizePhotoProcessingView() -> Bool {
        return useCustomizePhotoProcessingView
    }
}
