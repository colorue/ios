//
//  DrawingsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/28/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation
import RealmSwift

final class DrawingsViewController: UICollectionViewController {
  // MARK: - Properties
//  private let drawings = [UIImage(named: "Onboarding1"), UIImage(named: "Onboarding2"), UIImage(named: "Onboarding3"), UIImage(named: "Onboarding4"), UIImage(named: "Onboarding5")]


//  private var drawings = realm.objects(Drawing.self)

  private var drawings: Results<Drawing> {
    let realm = try! Realm()
    return realm.objects(Drawing.self)
      .sorted(byKeyPath: "updatedAt", ascending: false)
  }

  var notificationToken: NotificationToken?


  private let reuseIdentifier = "drawingCell"
  private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
  private let itemsPerRow: CGFloat = 3


  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.setBottomBorderColor(color: Theme.divider, height: 0.5)

//    collectionView?.backgroundColor = Theme.divider


    if let savedDrawing = UserDefaults.standard.string(forKey: Prefs.savedDrawing) {
      let realm = try! Realm()
      let drawing = Drawing()
      drawing.base64 = savedDrawing
      try! realm.write {
        realm.add(drawing)
        UserDefaults.standard.removeObject(forKey: Prefs.savedDrawing)
      }
    }

    notificationToken = drawings.observe { [weak self] (changes) in
        guard let collectionView = self?.collectionView else { return }
        switch changes {
        case .initial:
          collectionView.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            // Query results have changed.
            print("Deleted indices: ", deletions)
            print("Inserted indices: ", insertions)
            print("Modified modifications: ", modifications)
            collectionView.reloadData()

//          tableView.performBatchUpdates({
//              // Always apply updates in the following order: deletions, insertions, then modifications.
//              // Handling insertions before deletions may result in unexpected behavior.
//              tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//                                   with: .automatic)
//              tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//                                   with: .automatic)
//              tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//                                   with: .automatic)
//          }, completion: { finished in
//              // ...
//          })
        case .error(let error):
            // An error occurred while opening the Realm file on the background worker thread
            fatalError("\(error)")
        }
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let drawingController = segue.destination as? DrawingViewController else { return }
      if let drawingCell = sender as? DrawingCell {
        drawingController.drawing = drawingCell.drawing
      }
  }

  @IBAction func close(_ unwindSegue: UIStoryboardSegue) {}
}

// MARK: - UICollectionViewDataSource
extension DrawingsViewController {
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
extension DrawingsViewController: UICollectionViewDelegateFlowLayout {
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
        let copyAction =
            UIAction(title: NSLocalizedString("Copy", comment: ""),
                     image: UIImage(systemName: "doc.on.doc")) { action in
                self.performCopy(indexPath)
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
          return UIMenu(title: "", children: [copyAction, shareAction, saveAction, deleteAction])
      }
  }

  private func performShare (_ indexPath: IndexPath) {
    print("performShare", indexPath)
  }

  private func performCopy (_ indexPath: IndexPath) {
    print("performCopy", indexPath)
  }

  private func performSave (_ indexPath: IndexPath) {
    print("performSave", indexPath)
  }

  private func performDelete (_ indexPath: IndexPath) {
    let deleteAlert = UIAlertController(title: "This drawing will be deleted from Colorue.", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

    deleteAlert.addAction(UIAlertAction(title: "Delete Drawing", style: .destructive, handler: { (action: UIAlertAction!) in
      print("performDelete", indexPath)
    }))

    deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
    self.present(deleteAlert, animated: true, completion: nil)
  }
}
