//
//  DrawingsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/28/22.
//  Duplicateright © 2022 Dylan Wight. All rights reserved.
//

import Foundation
import RealmSwift

final class GalleryViewController: UICollectionViewController {
  // MARK: - Properties
  private var drawings: Results<Drawing> {
    return Database.realm.objects(Drawing.self)
      .sorted(byKeyPath: "updatedAt", ascending: false)
  }
  
  var notificationToken: NotificationToken?
  
  
  private let reuseIdentifier = "drawingCell"
  private let sectionInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
  private let itemsPerRow: CGFloat = 3
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    navigationController?.navigationBar.setBottomBorderColor(color: Theme.divider, height: 0.5)
    
    if let savedDrawing = Database.string(for: .savedDrawing) {
      let realm = try! Realm()
      let drawing = Drawing()
      drawing.base64 = savedDrawing
      try! realm.write {
        realm.add(drawing)
        Database.remove(key: .savedDrawing)
      }
    }
    
    notificationToken = drawings.observe { [weak self] (changes) in
      guard let collectionView = self?.collectionView else { return }
      switch changes {
      case .initial:
        collectionView.reloadData()
      case .update(_, let deletions, let insertions, let modifications):
        collectionView.performBatchUpdates({
          collectionView.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0)}))
          collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))
          collectionView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0) }))
        }, completion: nil)
      case .error(let error):
        fatalError("\(error)")
      }
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Database.remove(key: .openDrawing)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let drawingController = segue.destination as? DrawingViewController else { return }
    if let drawingCell = sender as? DrawingCell {
      drawingController.drawingId = drawingCell.drawing?.id
    }
  }
}

// MARK: - UICollectionViewDataSource
extension GalleryViewController {
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return drawings.count
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: reuseIdentifier,
      for: indexPath
    ) as! DrawingCell
    
    cell.drawing = drawings[indexPath.row]
    return cell
  }
}

// MARK: - Collection View Flow Layout Delegate
extension GalleryViewController: UICollectionViewDelegateFlowLayout {
  // 1
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    // 2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  // 3
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return sectionInsets.left
  }
  
  
  override func collectionView(_ collectionView: UICollectionView,
                               contextMenuConfigurationForItemAt indexPath: IndexPath,
                               point: CGPoint) -> UIContextMenuConfiguration? {
    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
      let duplicateAction =
      UIAction(title: NSLocalizedString("Duplicate", comment: ""),
               image: UIImage(systemName: "plus.square.on.square")) { action in
        self.performDuplicate(indexPath)
      }
      
      let shareAction =
      UIAction(title: NSLocalizedString("Share", comment: ""),
               image: UIImage(systemName: "square.and.arrow.up")) { action in
        self.performShare(indexPath)
      }
      
      let saveAction =
      UIAction(title: NSLocalizedString("Add to Photos", comment: ""),
               image: UIImage(systemName: "square.and.arrow.down")) { action in
        self.performSave(indexPath)
      }
      let deleteAction =
      UIAction(title: NSLocalizedString("Delete from Colorue", comment: ""),
               image: UIImage(systemName: "trash"),
               attributes: .destructive) { action in
        self.performDelete(indexPath)
      }
      return UIMenu(title: "", children: [duplicateAction, shareAction, saveAction, deleteAction])
    }
  }
  
  private func performShare (_ indexPath: IndexPath) {
    let drawing = drawings[indexPath.row]
    guard let base64 = drawing.base64 else { return }

    let data = UIImage.fromBase64(base64).pngData()!
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let filename = paths[0].appendingPathComponent("Colorue.png")
    try? data.write(to: filename)

    let activityViewController : UIActivityViewController = UIActivityViewController(
      activityItems: [filename], applicationActivities: nil)
    
    // This lines is for the popover you need to show in iPad
    activityViewController.popoverPresentationController?.sourceView = collectionView
    if let cell = collectionView?.cellForItem(at: indexPath) {
      print("cell.frame", cell.frame)
      activityViewController.popoverPresentationController?.sourceRect = cell.frame
    }
    
    // This line remove the arrow of the popover to show in iPad
    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
    
    // Pre-configuring activity items
    activityViewController.activityItemsConfiguration = [
      UIActivity.ActivityType.message,
      UIActivity.ActivityType.postToFacebook,
      UIActivity.ActivityType.postToTwitter,
    ] as? UIActivityItemsConfigurationReading
    
    // Anything you want to exclude
    activityViewController.excludedActivityTypes = [
      UIActivity.ActivityType.postToWeibo,
      UIActivity.ActivityType.print,
      UIActivity.ActivityType.assignToContact,
      UIActivity.ActivityType.addToReadingList,
      UIActivity.ActivityType.postToFlickr,
      UIActivity.ActivityType.postToVimeo,
      UIActivity.ActivityType.postToTencentWeibo,
      UIActivity.ActivityType.airDrop,
      UIActivity.ActivityType.saveToCameraRoll
    ]
    
    activityViewController.isModalInPresentation = true
    self.present(activityViewController, animated: true, completion: nil)
    activityViewController.completionWithItemsHandler = { activityType, completed, items, error in
      guard completed else { return }
      AppStoreReviewManager.requestReviewIfAppropriate()
    }
  }
  
  private func performDuplicate (_ indexPath: IndexPath) {
    let drawing = drawings[indexPath.row]
    let drawingDuplicate = Drawing()
    drawingDuplicate.base64 = drawing.base64
    try! Database.realm.write {
      Database.realm.add(drawingDuplicate)
    }
  }
  
  private func performSave (_ indexPath: IndexPath) {
    let drawing = drawings[indexPath.row]
    guard let base64 = drawing.base64 else { return }
    let image = UIImage.fromBase64(base64)
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedImage), nil)
  }
  
  @objc func savedImage(_ im:UIImage, error:Error?, context:UnsafeMutableRawPointer?) {
    if let err = error {
      print(err)
      let photosAlert = UIAlertController(title: "Colorue", message: "Please allow access to Photos to save your drawings", preferredStyle: UIAlertController.Style.alert)

      photosAlert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: {  (action: UIAlertAction!) in
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
      }))
      photosAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
      return self.present(photosAlert, animated: true, completion: nil)
    }
    Haptic.notificationOccurred(.success)
    view.makeToast("Saved to Photos", position: .center)
    AppStoreReviewManager.requestReviewIfAppropriate()
  }
  
  private func performDelete (_ indexPath: IndexPath) {
    let deleteAlert = UIAlertController(title: "This drawing will be deleted from Colorue.", message: nil, preferredStyle: UIAlertController.Style.preferActionSheet)
    
    deleteAlert.addAction(UIAlertAction(title: "Delete Drawing", style: .destructive, handler: { [weak self] (action: UIAlertAction!) in
      guard let drawing = self?.drawings[indexPath.row]  else { return }
      try! Database.realm.write {
        Database.realm.delete(drawing)
      }
    }))
    
    deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
    self.present(deleteAlert, animated: true, completion: nil)
  }

   @IBAction func unwind(segue: UIStoryboardSegue) {}
}

extension GalleryViewController: UIPopoverPresentationControllerDelegate {
  
}
