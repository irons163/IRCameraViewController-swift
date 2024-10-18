//
//  IRCameraSlideUpView.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2023/1/15.
//  Copyright © 2023  All rights reserved.
//        

import UIKit

class IRCameraSlideUpView: UIView, IRCameraSlideViewProtocol {

    // MARK: - IRCameraSlideViewProtocol

    func initialPosition(with view: UIView) -> CGFloat {
        return 0
    }

    func finalPosition() -> CGFloat {
        return -self.frame.height
    }
}
