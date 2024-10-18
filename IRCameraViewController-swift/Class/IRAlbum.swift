//
//  IRAlbum.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/4/29.
//  Copyright © 2024  All rights reserved.
//        

import Foundation
import UIKit
import MobileCoreServices

class IRAlbum: NSObject {

    // MARK: - Public Methods

    static func image(withMediaInfo info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let mediaType = info[.mediaType] as? String, mediaType == kUTTypeImage as String {
            return info[.originalImage] as? UIImage
        }
        return nil
    }

    static func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
    }

    static func imagePickerController(withDelegate delegate: (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.delegate = delegate
        pickerController.mediaTypes = [kUTTypeImage as String]
        pickerController.allowsEditing = false
        pickerController.modalPresentationStyle = .popover
        return pickerController
    }
}
