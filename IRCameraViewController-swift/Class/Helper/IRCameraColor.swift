//
//  IRCameraColor.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2023/1/14.     

import UIKit

class IRCameraColor: UIColor {

    static let irGrayColor: UIColor = IRCameraColor.color(red: 200, green: 200, blue: 200)
    static var staticTintColor: UIColor?
    static override var tintColor: UIColor {
        set {
            Self.staticTintColor = newValue
        }
        get {
            guard let tintColor = Self.staticTintColor else {
                return  Self.color(red: 255, green: 91, blue: 1)
            }
            return tintColor
        }
    }

    class func color(red: Int, green: Int, blue: Int) -> UIColor {
        let divisor: CGFloat = 255
        return UIColor(red: CGFloat(red) / divisor, green: CGFloat(green) / divisor, blue: CGFloat(blue) / divisor, alpha: 1)
    }
}
