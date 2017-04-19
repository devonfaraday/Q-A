//
//  HolderView.swift
//  Q&A
//
//  Created by Hayden Hastings on 4/18/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class HolderView: UIView {
    weak var delegate: HolderViewDelegate?
    var parentFrame: CGRect = CGRect.zero
    let blueRectangleLayer = RectangleLayer()
    
    func expandView() {
        backgroundColor = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1)
        frame = CGRect(x: frame.origin.x - blueRectangleLayer.lineWidth, y: frame.origin.y - blueRectangleLayer.lineWidth, width: blueRectangleLayer.lineWidth * 2, height: blueRectangleLayer.lineWidth * 2)
        layer.sublayers = nil
        UIView.animate(withDuration: 1.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { self.frame = self.parentFrame
        }, completion: { finished in
            self.addLabel()
        })
    }
    
    func addLabel() {
        delegate?.animateLabel()
    }
}

protocol HolderViewDelegate: class {
    func animateLabel()
}

class RectangleLayer: CAShapeLayer {
    
    override init() {
        super.init()
        fillColor = UIColor.clear.cgColor
        lineWidth = 5.0
        path = rectanglePathFull.cgPath
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var rectanglePathFull: UIBezierPath {
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: CGPoint(x: 0.0, y: 100.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: -lineWidth))
        rectanglePath.addLine(to: CGPoint(x: 100.0, y: -lineWidth))
        rectanglePath.addLine(to: CGPoint(x: 100.0, y: 100.0))
        rectanglePath.addLine(to: CGPoint(x: -lineWidth / 2, y: 100.0))
        rectanglePath.close()
        return rectanglePath
    }
    
    func animateStrokeWithColor(_ color: UIColor) {
        strokeColor = color.cgColor
        let strokeAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0.0
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = 0.4
        add(strokeAnimation, forKey: nil)
    }
}
