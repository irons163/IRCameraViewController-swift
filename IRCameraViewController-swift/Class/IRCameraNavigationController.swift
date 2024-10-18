//
//  IRCameraNavigationController.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2023/1/12.
//  Copyright © 2023  All rights reserved.
//        

import UIKit

public class IRCameraNavigationController: UINavigationController {

    public init(with delegate: IRCameraDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.isNavigationBarHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
