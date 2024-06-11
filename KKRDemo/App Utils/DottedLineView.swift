//
//  DottedLineView.swift
//  KKR App
//
//  Created by Darshana Kamble on 17/02/24.
//

import UIKit

class DottedLineView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let pattern: [CGFloat] = [5.0, 5.0] // Adjust the values to change the pattern of the dotted line

        path.setLineDash(pattern, count: 2, phase: 0.0)
        path.lineWidth = 2.0 // Adjust the line width as needed

        path.move(to: CGPoint(x: rect.origin.x, y: rect.size.height / 2.0))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height / 2.0))

        UIColor.black.set() // Adjust the color as needed
        path.stroke()
    }
}
