//
//  IRCameraGridView.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/4/28.

import Foundation
import UIKit

// MARK: - IRCameraGridView Definition
class IRCameraGridView: UIView {

    // MARK: - Properties
    var lineWidth: CGFloat = 0.8
    var numberOfColumns: Int = 0
    var numberOfRows: Int = 0

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(lineWidth)
        context.setStrokeColor(IRCameraColor.gray.withAlphaComponent(0.7).cgColor)

        let columnWidth = self.frame.size.width / CGFloat(numberOfColumns + 1)
        let rowHeight = self.frame.size.height / CGFloat(numberOfRows + 1)

        // Draw columns
        for i in 1...numberOfColumns {
            let x = columnWidth * CGFloat(i)
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: self.frame.size.height))
            context.strokePath()
        }

        // Draw rows
        for i in 1...numberOfRows {
            let y = rowHeight * CGFloat(i)
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: self.frame.size.width, y: y))
            context.strokePath()
        }
    }

    // MARK: - Setup
    private func setup() {
        backgroundColor = .clear
    }
}

