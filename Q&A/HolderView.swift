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
    
    func expandView() {
        backgroundColor = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1)
        layer.sublayers = nil
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear,
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
