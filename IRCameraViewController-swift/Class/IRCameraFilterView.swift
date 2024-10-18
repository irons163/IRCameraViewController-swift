//
//  IRCameraFilterView.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/4/29.
//  Copyright © 2024  All rights reserved.
//        

import Foundation
import UIKit

// Define the IRCameraFilterView class with UIView as its superclass
class IRCameraFilterView: UIView {

    // Initializer for creating the view programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    // Required initializer for loading views from a storyboard or nib
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Public methods

    // Method to add this view above another view with an animation
    func addToView(_ view: UIView, aboveView: UIView) {
        var frame = self.frame
        frame.origin.y = view.frame.maxY - aboveView.frame.height
        self.frame = frame
        view.addSubview(self)

        frame.origin.y -= self.frame.height

        UIView.animate(withDuration: 0.5) {
            self.frame = frame
        }
    }

    // Method to remove this view with an animation
    func removeFromSuperviewAnimated() {
        var frame = self.frame
        frame.origin.y += self.frame.height

        UIView.animate(withDuration: 0.5, animations: {
            self.frame = frame
        }) { finished in
            self.removeFromSuperview()
        }
    }

    // MARK: - Private methods

    // Setup method called by initializers to configure the view
    private func setup() {
        var frame = self.frame
        frame.size.width = UIScreen.main.applicationFrame.width
        self.frame = frame
    }
}
