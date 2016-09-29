//
//  GroupTableViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase
import SlackTextViewController
import TTTAttributedLabel
import ActiveLabel

class CommentViewController: SLKTextViewController {
    
    let api = API.sharedInstance
    
    public var drawingInstance: Drawing? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    var tintColor: UIColor? {
        didSet {
            textInputbar.tintColor = tintColor
            rightButton.tintColor = tintColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isInverted = false
        textInputbar.autoHideRightButton = false
        textView.placeholder = "Write comment..."
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.tableFooterView = UIView()
        tableView?.backgroundColor = backgroundColor
        tableView?.register(UINib(nibName: R.nib.commentCell.identifier, bundle: nil), forCellReuseIdentifier: R.nib.commentCell.identifier)
        tableView?.allowsSelection = false
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawingInstance?.getComments().count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.commentCell)!
        cell.comment = drawingInstance?.getComments()[(indexPath as NSIndexPath).row]
        cell.delegate = self
        cell.buttonTag = (indexPath as NSIndexPath).row
        cell.tint = tintColor
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let targetController = segue.destination as? ProfileViewController {
            targetController.tintColor = self.tintColor
            targetController.navigationItem.title = drawingInstance!.getComments()[(sender! as AnyObject).tag].user.username
            targetController.userInstance = drawingInstance!.getComments()[(sender! as AnyObject).tag].user
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return  UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt editActionsForRowAtIndexPath: IndexPath) -> [UITableViewRowAction] {
        if drawingInstance?.getComments()[(editActionsForRowAtIndexPath as NSIndexPath).row].user.userId == api.getActiveUser().userId {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { action, indexPath in
                self.setEditing(false, animated: true)
                let deleteAlert = UIAlertController(title: "Delete comment?", message: "This comment will be deleted permanently", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.deleteComment(self.drawingInstance!, comment: (self.drawingInstance?.getComments()[(editActionsForRowAtIndexPath as NSIndexPath).row])!)
                    Analytics.logEvent(.deletedComment)
                    self.tableView?.reloadData()
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(deleteAlert, animated: true, completion: nil)
            })
            return [deleteAction]
        } else {
            let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Report", handler: { action, indexPath in
                let deleteAlert = UIAlertController(title: "Report comment?", message: "Please report any comments that are overtly sexual, promote violence, or are intentionally mean-spirited.", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.reportComment((self.drawingInstance?.getComments()[(editActionsForRowAtIndexPath as NSIndexPath).row])!)
                    Analytics.logEvent(.reportedComment)
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(deleteAlert, animated: true, completion: nil)
                self.setEditing(false, animated: true)
            })
            return [reportAction]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let comment = drawingInstance?.getComments()[indexPath.row] else { return CGFloat.leastNormalMagnitude }
        
        let font = CommentCell.commentFont
        
        let insets = UIEdgeInsets(top: 28.0, left: 12.0, bottom: 8.0, right: 12.0)

        let width = UIScreen.main.bounds.width - insets.left - insets.right
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2.0
        style.minimumLineHeight = font.lineHeight
        style.maximumLineHeight = font.lineHeight
        
        let attrString = NSAttributedString(string: comment.text, attributes: [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: style
            ])
        
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(
            attrString,
            withConstraints: CGSize(width: width, height: 0.0),
            limitedToNumberOfLines: 0)
        
        return size.height + insets.top + insets.bottom
    }
    
    @IBAction func pullRefresh(_ sender: UIRefreshControl) {
        // TODO: implement pull to refresh
        tableView?.reloadData()
//        tableView?.refreshControl?.endRefreshing()
    }
    
    override func didPressRightButton(_ sender: Any?) {
        API.sharedInstance.addComment(drawingInstance!, text: textInputbar.textView.text)
        textInputbar.textView.text = ""
        Analytics.logEvent(.wroteComment)
        tableView?.reloadData()
    }
}

extension CommentViewController: ActiveLabelDelegate {
    func didSelect(_ text: String, type: ActiveType) {
        print(text, type)
        switch(type) {
        case .hashtag:
//            let hashtagAlert = UIAlertController(title: "#\(text)", message: "Hashtags coming soon!" , preferredStyle: UIAlertControllerStyle.alert)
//            hashtagAlert.addAction(UIAlertAction(title: "Cool", style: UIAlertActionStyle.default, handler: nil))
//            present(hashtagAlert, animated: true, completion: nil)
            
            if let hashTagController = R.storyboard.hashTag.hashTag() {
                hashTagController.text = text
                hashTagController.tintColor = tintColor
                navigationController?.pushViewController(hashTagController, animated: true)
            }
        case .mention:
            if let profileController = R.storyboard.profile.profile() {
                profileController.username = text
                profileController.tintColor = tintColor
                navigationController?.pushViewController(profileController, animated: true)
            }
        default:
            break
        }
    }
}
