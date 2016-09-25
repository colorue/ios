//
//  HomeTableViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl
import Kingfisher
import FBSDKShareKit
import MessageUI
import Firebase

class DrawingListViewController: UITableViewController, APIDelagate {
    
    // MARK: Properties
    let api = API.sharedInstance
    let bottomRefreshControl = UIRefreshControl()
    var drawingSource = API.sharedInstance.getWall
    
    var controller = MFMessageComposeViewController()

    var tintColor: UIColor?
    
    var loadMoreDrawings: (()->())?
    
    // MARK: Loading Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 586.0
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        self.navigationController?.navigationBar.tintColor = self.tintColor
        
        bottomRefreshControl.triggerVerticalOffset = 50.0
        bottomRefreshControl.addTarget(self, action: #selector(DrawingListViewController.refresh), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        api.delagate = self
        self.refresh()
        
        // bottomRefreshControl needs to be set in viewDidApear
        self.tableView.bottomRefreshControl = bottomRefreshControl
    }
    
    func scrollToTop() {
        if tableView.numberOfRows(inSection: 0) > 0 {
            self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        } else if tableView.numberOfRows(inSection: 1) > 0 {
            self.tableView.scrollToRow(at: IndexPath(item: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    @IBAction func pullRefresh(_ sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : drawingSource().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.drawingCell, for: indexPath)!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        let drawingCell = cell as! DrawingCell
        let drawing: Drawing
        let tag: Int

        if (indexPath as NSIndexPath).section == 0 {
            drawing = api.getDrawingOfTheDay()[0]
            tag = -1
        } else {
            drawing = drawingSource()[(indexPath as NSIndexPath).row]
            tag = (indexPath as NSIndexPath).row
        }
        
        drawingCell.drawing = drawing
        drawingCell.color = tintColor
        drawingCell.delagate = self
        drawingCell.cellTag = tag
        
        if ((indexPath as NSIndexPath).row + 1 >= drawingSource().count) {
            self.loadMoreDrawings?()
        }
    }
    
    @IBAction func refreshPulled(_ sender: UIRefreshControl) {
        refresh()
    }
    
    func refresh() {
        DispatchQueue.main.async(execute: {
            self.bottomRefreshControl.endRefreshing()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    func getClickedDrawing(_ sender: AnyObject) -> Drawing {
        if sender.tag >= 0 {
            return drawingSource()[sender.tag]
        } else {
            return api.getDrawingOfTheDay()[0]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let targetController = segue.destination as? UserListViewController {
            let drawing = getClickedDrawing(sender! as AnyObject)
            targetController.navigationItem.title = "Likes"
            targetController.tintColor = self.tintColor!
            targetController.userSource = { return drawing.getLikes() }
        } else if let targetController = segue.destination as? CommentViewController {
            let drawing = getClickedDrawing(sender! as AnyObject)
            targetController.tintColor = self.tintColor!
            targetController.drawingInstance = drawing
        } else if let targetController = segue.destination as? ProfileViewController {
            let drawing = getClickedDrawing(sender! as AnyObject)
            targetController.navigationItem.title = drawing.getArtist().username
            targetController.tintColor = self.tintColor!
            targetController.userInstance = drawing.getArtist()
        }
    }
    
    override func didReceiveMemoryWarning() {
        api.releaseMemory()
        super.didReceiveMemoryWarning()
    }
}



extension DrawingListViewController: DrawingCellDelagate {
    
    func likeButtonPressed(_ drawing: Drawing) {
        if !(drawing.liked(api.getActiveUser())) {
            api.like(drawing)
            Analytics.logEvent(.likedDrawing)
        } else {
            api.unlike(drawing)
            Analytics.logEvent(.unlikedDrawing)
        }
    }
    
    func presentDrawingActions(_ drawing: Drawing) {
        
        let drawingActions = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if (drawing.getArtist().userId == api.getActiveUser().userId) {
            drawingActions.addAction(UIAlertAction(title: "Set as Profile Drawing", style: .default, handler: { (action: UIAlertAction!) in
                self.api.makeProfilePic(drawing)
                FIRAnalytics.logEvent(withName: "setProfileDrawing", parameters: [:])
            }))
            drawingActions.addAction(UIAlertAction(title: "Share to Facebook", style: .default, handler: { (action: UIAlertAction!) in
                self.shareToFacebook(drawing)
            }))
            drawingActions.addAction(UIAlertAction(title: "Send as Text", style: .default, handler: { (action: UIAlertAction!) in
                self.sendDrawing(drawing)
            }))
            drawingActions.addAction(UIAlertAction(title: "Save", style: .default, handler:  { (action: UIAlertAction!) in
                UIImageWriteToSavedPhotosAlbum(drawing.getImage(), self, nil, nil)
                FIRAnalytics.logEvent(withName: "ownDrawingSavedFeed", parameters: [:])
            }))
            drawingActions.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction!) in
                let activity = R.storyboard.drawing.drawingViewController()!
                if let drawingViewController = activity.topViewController as? DrawingViewController {
                    drawingViewController.baseImage = drawing.getImage()
                    FIRAnalytics.logEvent(withName: "editDrawing", parameters: [:])
                    self.present(activity, animated: true, completion: nil)
                }
            }))
            drawingActions.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                let deleteAlert = UIAlertController(title: "Delete drawing?", message: "This drawing will be deleted permanently", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.deleteDrawing(drawing)
                    FIRAnalytics.logEvent(withName: "drawingDeleted", parameters: [:])
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(deleteAlert, animated: true, completion: nil)
            }))
        } else {
            drawingActions.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (action: UIAlertAction!) in
                let deleteAlert = UIAlertController(title: "Report drawing?", message: "Please report any drawings that are overtly sexual, promote violence, or are intentionally mean-spirited.", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.reportDrawing(drawing)
                    FIRAnalytics.logEvent(withName: "drawingReported", parameters: [:])
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(deleteAlert, animated: true, completion: nil)
            }))
            drawingActions.addAction(UIAlertAction(title: "Save", style: .default, handler:  { (action: UIAlertAction!) in
                UIImageWriteToSavedPhotosAlbum(drawing.getImage(), self, nil, nil)
                FIRAnalytics.logEvent(withName: "friendDrawingSavedFeed", parameters: [:])
            }))
        }
        
        if api.getActiveUser().userId == "5Apylh3iA6bDpkDDGwcG3G8BWZ42" {
            drawingActions.addAction(UIAlertAction(title: "Make DOD!", style: .default, handler:  { (action: UIAlertAction!) in
                self.api.makeDOD(drawing)
            }))
        }
        
        drawingActions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        
        self.present(drawingActions, animated: true, completion: nil)
    }
    
    fileprivate func sendDrawing(_ drawing: Drawing) {
        Analytics.logEvent(.sendDrawing, parameters: ["feed": true as NSObject])

        if (MFMessageComposeViewController.canSendText()) {
            controller.addAttachmentData(UIImagePNGRepresentation(drawing.getImage())!, typeIdentifier: "public.data", filename: "colorue.png")
            controller.messageComposeDelegate = self
            controller.resignFirstResponder()
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func shareToFacebook(_ drawing: Drawing) {
        Analytics.logEvent(.postToFacebook, parameters: ["feed": true as NSObject])
        let content = FBSDKSharePhotoContent()
        let photo = FBSDKSharePhoto(image: drawing.getImage(), userGenerated: true)
        content.photos  = [photo]
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.native
        if !dialog.show() {
            dialog.mode = FBSDKShareDialogMode.automatic
            dialog.show()
        }
    }
}

extension DrawingListViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        self.controller = MFMessageComposeViewController()
    }
}
