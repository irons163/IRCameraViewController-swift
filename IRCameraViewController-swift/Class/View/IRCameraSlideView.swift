//
//  IRCameraSlideView.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2023/1/15.
//  Copyright © 2023  All rights reserved.
//        

import Foundation
import UIKit

protocol IRCameraSlideViewProtocol: AnyObject {
    func initialPosition(with view: UIView) -> CGFloat
    func finalPosition() -> CGFloat
}

class IRCameraSlideView: UIView {

    static let exceptionName = "IRCameraSlideViewException"
    static let exceptionMessage = "Invoked abstract method"

    // MARK: - Public methods

    static func showSlideUpView(_ slideUpView: IRCameraSlideView, slideDownView: IRCameraSlideView, at view: UIView, completion: @escaping () -> Void) {
        slideUpView.addSlide(to: view, withOriginY: slideUpView.finalPosition())
        slideDownView.addSlide(to: view, withOriginY: slideDownView.finalPosition())

        slideUpView.removeSlideFromSuperview(remove: false, withDuration: 0.15, originY: slideUpView.initialPosition(with: view), completion: nil)
        slideDownView.removeSlideFromSuperview(remove: false, withDuration: 0.15, originY: slideDownView.initialPosition(with: view), completion: completion)
    }

    static func hideSlideUpView(_ slideUpView: IRCameraSlideView, slideDownView: IRCameraSlideView, at view: UIView, completion: @escaping () -> Void) {
        slideUpView.hideWithAnimation(at: view, withTimeInterval: 0.3, completion: nil)
        slideDownView.hideWithAnimation(at: view, withTimeInterval: 0.3, completion: completion)
    }

    func showWithAnimation(at view: UIView, completion: @escaping () -> Void) {
        addSlide(to: view, withOriginY: finalPosition())
        removeSlideFromSuperview(remove: false, withDuration: 0.15, originY: initialPosition(with: view), completion: completion)
    }

    func hideWithAnimation(at view: UIView, completion: @escaping () -> Void) {
        hideWithAnimation(at: view, withTimeInterval: 0.6, completion: completion)
    }

    // MARK: - IRCameraSlideViewProtocol

    func initialPosition(with view: UIView) -> CGFloat {
        NSException(name: NSExceptionName(rawValue: IRCameraSlideView.exceptionName), reason: IRCameraSlideView.exceptionMessage, userInfo: nil).raise()
        return 0.0
    }

    func finalPosition() -> CGFloat {
        NSException(name: NSExceptionName(rawValue: IRCameraSlideView.exceptionName), reason: IRCameraSlideView.exceptionMessage, userInfo: nil).raise()
        return 0.0
    }

    // MARK: - Private methods

    private func addSlide(to view: UIView, withOriginY originY: CGFloat) {
        let width = view.frame.width
        let height = view.frame.height / 2

        var frame = self.frame
        frame.size.width = width
        frame.size.height = height
        frame.origin.y = originY
        self.frame = frame

        view.addSubview(self)
    }

    private func hideWithAnimation(at view: UIView, withTimeInterval timeInterval: CGFloat, completion: (() -> Void)?) {
        addSlide(to: view, withOriginY: initialPosition(with: view))

        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: TimeInterval(timeInterval))
            DispatchQueue.main.async {
                self.removeSlideFromSuperview(remove: true, withDuration: timeInterval, originY: self.finalPosition(), completion: completion)
            }
        }
    }

    private func removeSlideFromSuperview(remove: Bool, withDuration duration: CGFloat, originY: CGFloat, completion: (() -> Void)?) {
        var frame = self.frame
        frame.origin.y = originY

        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.frame = frame
        }, completion: { finished in
            if finished {
                if remove {
                    self.removeFromSuperview()
                }

                completion?()
            }
        })
    }
}
