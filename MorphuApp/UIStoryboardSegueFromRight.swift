//
//  SegueFromLeft.swift
//  Morphu
//
//  Created by Dylan Wight on 4/10/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit
import QuartzCore

class UIStoryboardSegueFromRight: UIStoryboardSegue {
    
    override func perform() {
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        secondVCView.transform = CGAffineTransformMakeTranslation(screenWidth, 0)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.transform = CGAffineTransformMakeTranslation(-screenWidth, 0)
            secondVCView.transform = CGAffineTransformIdentity
        }) { (Finished) -> Void in
            self.sourceViewController.presentViewController(self.destinationViewController, animated: false, completion: nil)
        }
    }
}

class UIStoryboardUnwindSegueFromRight: UIStoryboardSegue {
    
    override func perform() {
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        secondVCView.transform = CGAffineTransformMakeTranslation(-screenWidth, 0)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.transform = CGAffineTransformMakeTranslation(screenWidth, 0)
            
            secondVCView.transform = CGAffineTransformIdentity

        }) { (Finished) -> Void in
            self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
