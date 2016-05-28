//
//  PresentDrawingViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 5/23/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class PresentDrawingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController!.tabBar.selectionIndicatorImage = UIImage(named: "Logo Clear")!
        self.tabBarController!.tabBar.tintColor = UIColor.clearColor()

        performSegueWithIdentifier("newDrawing", sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController!.tabBar.selectionIndicatorImage = nil
        self.tabBarController!.tabBar.tintColor = tabSelectionColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
