//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl

class WallViewController: DrawingListViewController {

    // MARK: Loading Methods
    override func viewDidLoad() {
        self.tintColor = redColor
        super.viewDidLoad()
        
        loadMoreDrawings = api.loadWall
        
        self.refreshControl?.beginRefreshing()
//        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("firstOpen")) {
            prefs.setValue(true, forKey: "firstOpen")
            if let newVC = self.tabBarController!.storyboard?.instantiateViewControllerWithIdentifier("DrawingViewController") {
                self.tabBarController!.presentViewController(newVC, animated: true, completion: nil)
            }
        } else if false {
            //"Want to know if someone follows you or comments on your drawings?
        }
    }
    
    @IBAction func backToHome(segue: UIStoryboardSegue) {}
}