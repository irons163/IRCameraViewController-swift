//
//  IRCameraSlideDownView.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2023/1/15.       

import Foundation
import UIKit

// MARK: - IRCameraSlideDownView Declaration
class IRCameraSlideDownView: IRCameraSlideView, IRCameraSlideViewProtocol {

    // MARK: - IRCameraSlideViewProtocol Implementation

    override func initialPosition(with view: UIView) -> CGFloat {
        return view.frame.height / 2
    }

    override func finalPosition() -> CGFloat {
        return frame.maxY
    }
}
