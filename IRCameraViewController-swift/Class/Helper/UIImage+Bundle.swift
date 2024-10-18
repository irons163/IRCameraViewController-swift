//
//  UIImage+Bundle.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/4/29.      

import UIKit

extension UIImage {
    convenience init?(imageNamedForCurrentBundle name: String) {
        let bundle = Utility.bundleForCurrentClass()
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}
