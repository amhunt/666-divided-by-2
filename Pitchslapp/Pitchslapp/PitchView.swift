//
//  PitchView.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 6/2/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PitchView: UIView {
    
    var noteLabel: UILabel!
    var activityView: NVActivityIndicatorView!
    
    override init(frame: CGRect) {
        
        let myPurple = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
        
        let size = frame.width / 3
        
        let viewFrame = CGRect(x: frame.width/2 - size/2, y: frame.height/2 - size/2, width: size, height: size)
        
        super.init(frame: viewFrame)
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.backgroundColor = myPurple
        
        noteLabel = UILabel()
        noteLabel.textAlignment = .Center
        noteLabel.textColor = UIColor.whiteColor()
        noteLabel.font = UIFont(name: "Avenir-Heavy", size: size/5)!
        
        let xCenterConstraint = NSLayoutConstraint(item: noteLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let yCenterConstraint = NSLayoutConstraint(item: noteLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(noteLabel)
        self.addConstraints([xCenterConstraint, yCenterConstraint])
        
        let activitySize = size * 1
        let sizeDist = size - activitySize
        
        let activityRect = CGRect(x: viewFrame.origin.x + sizeDist/2, y: viewFrame.origin.y + sizeDist/2, width: activitySize, height: activitySize)
        
        activityView = NVActivityIndicatorView(frame: activityRect, type: .BallScaleRipple)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showInView(aView: UIView!, withMessage message: String!, animated: Bool)
    {
        noteLabel.text = message
        aView.addSubview(self)
        
        if animated
        {
            self.showAnimate()
        }
        aView.addSubview(activityView)
        activityView.startAnimation()
    }
    
    func showAnimate()
    {
        self.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.removeFromSuperview()
                }
        });
    }
    
    func removeFromView() {
        self.removeAnimate()
        activityView.removeFromSuperview()
        activityView.stopAnimation()
    }

}
