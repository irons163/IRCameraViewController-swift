//
//  IRAssetImageFile.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/5/1.
//  Copyright © 2024  All rights reserved.
//        

import UIKit

class IRAssetImageFile: NSObject {
    var desc: String?
    var image: UIImage?
    var path: String
    var title: String?

    init(path: String, image: UIImage) {
        self.path = path
        self.image = image
        super.init()  // Calling super.init() to properly initialize the NSObject
    }
}
