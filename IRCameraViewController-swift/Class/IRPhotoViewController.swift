//
//  IRPhotoViewController.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/4/29.
//  Copyright © 2024  All rights reserved.
//        

import UIKit
import AssetsLibrary

enum IRCache {
    static let satureKey = "IRCacheSatureKey"
    static let curveKey = "IRCacheCurveKey"
    static let vignetteKey = "IRCacheVignetteKey"
}

class IRPhotoViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var filterView: IRCameraFilterView!
    @IBOutlet weak var defaultFilterButton: UIButton!
    @IBOutlet weak var filterWandButton: IRTintedButton!
    @IBOutlet weak var cancelButton: IRTintedButton!
    @IBOutlet weak var confirmButton: IRTintedButton!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!

    weak var delegate: IRCameraDelegate?
    var detailFilterView: UIView!
    var photo: UIImage!
    var cachePhoto: NSCache<AnyObject, AnyObject> = NSCache()
    var albumPhoto: Bool = false

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use newWithDelegate:photo:")
    }

    static func newWithDelegate(_ delegate: IRCameraDelegate?, photo: UIImage) -> IRPhotoViewController {
        let viewController = IRPhotoViewController.newController()
        viewController.delegate = delegate
        viewController.photo = photo
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIScreen.main.bounds.height <= 480 {
            topViewHeight.constant = 0
        }

        photoView.clipsToBounds = true
        photoView.image = photo

        cancelButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraBack"), for: .normal)
        confirmButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraShot"), for: .normal)
        filterWandButton.setImage(UIImage(imageNamedForCurrentBundle: "CameraFilter"), for: .normal)

        if (IRCamera.getOption(.hiddenFilterButton) != nil) {
            filterWandButton.isHidden = true
        }

        addDetailViewToButton(defaultFilterButton)
    }

    @IBAction func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func confirmTapped() {
        delegate?.cameraWillTakePhoto()

        photo = photoView.image
        if albumPhoto {
//            delegate?.cameraDidSelectAlbumPhoto(photo)
            delegate?.cameraDidTakePhoto(photo)
        } else {
            delegate?.cameraDidTakePhoto(photo)
        }

        let status = ALAssetsLibrary.authorizationStatus()
        let library = IRAssetsLibrary.defaultAssetsLibrary

        if (IRCamera.getOption(.saveImageToAlbum) != nil) == true && status != .denied {
            library.saveImage(photo, completion: { assetURL in
                self.delegate?.cameraDidSavePhoto(at: assetURL)
            }) { error in
                // Handle the failure case
            }
        } else {
            // Alternative saving logic
        }
    }

    @IBAction func filtersTapped() {
        if filterView.isDescendant(of: mainView) {
            filterView.removeFromSuperviewAnimated()
        } else {
            filterView.addToView(mainView, aboveView: bottomView)
            view.sendSubviewToBack(filterView)
            view.sendSubviewToBack(photoView)
        }
    }

    @IBAction func defaultFilterTapped(_ button: UIButton) {
        addDetailViewToButton(button)
        photoView.image = photo
    }

    @IBAction func satureFilterTapped(_ button: UIButton) {
        addDetailViewToButton(button)
        if let cachedImage = cachePhoto.object(forKey: IRCache.satureKey as AnyObject) as? UIImage {
            photoView.image = cachedImage
        } else if let filteredImage = photo.saturateImage(1.8, withContrast: 1) {
            cachePhoto.setObject(filteredImage, forKey: IRCache.satureKey as AnyObject)
            photoView.image = filteredImage
        }
    }

    @IBAction func curveFilterTapped(_ button: UIButton) {
        addDetailViewToButton(button)
        if let cachedImage = cachePhoto.object(forKey: IRCache.curveKey as AnyObject) as? UIImage {
            photoView.image = cachedImage
        } else if let filteredImage = photo.curveFilter() {
            cachePhoto.setObject(filteredImage, forKey: IRCache.curveKey as AnyObject)
            photoView.image = filteredImage
        }
    }

    @IBAction func vignetteFilterTapped(_ button: UIButton) {
        addDetailViewToButton(button)
        if let cachedImage = cachePhoto.object(forKey: IRCache.vignetteKey as AnyObject) as? UIImage {
            photoView.image = cachedImage
        } else if let filteredImage = photo.vignetteWithRadius(0, intensity: 6) {
            cachePhoto.setObject(filteredImage, forKey: IRCache.vignetteKey as AnyObject)
            photoView.image = filteredImage
        }
    }

    private func addDetailViewToButton(_ button: UIButton) {
        detailFilterView?.removeFromSuperview()
        let height: CGFloat = 2.5
        let frame = CGRect(x: 0, y: button.frame.maxY - height, width: button.frame.width, height: height)
        detailFilterView = UIView(frame: frame)
        detailFilterView.backgroundColor = IRCameraColor.tintColor
        detailFilterView.isUserInteractionEnabled = false
        button.addSubview(detailFilterView)
    }

    static func newController() -> IRPhotoViewController {
        return IRPhotoViewController(nibName: String(describing: IRPhotoViewController.self), bundle: Bundle(for: IRPhotoViewController.self))
    }
}
