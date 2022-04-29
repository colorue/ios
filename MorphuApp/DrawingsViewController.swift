//
//  DrawingsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/28/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

final class DrawingsViewController: UICollectionViewController {
  // MARK: - Properties
  private let drawings = [UIImage(named: "Onboarding1"), UIImage(named: "Onboarding2"), UIImage(named: "Onboarding3"), UIImage(named: "Onboarding4"), UIImage(named: "Onboarding5")]
  private let reuseIdentifier = "drawingCell"
  private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
  private let itemsPerRow: CGFloat = 3


  override func viewDidLoad() {
    navigationController?.navigationBar.setBottomBorderColor(color: Theme.divider, height: 0.5)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "openDrawing" {
        guard let nav = segue.destination as? UINavigationController,
          let drawingController = nav.topViewController as? DrawingViewController,
          let drawingCell = sender as? DrawingCell
        else { return }
        drawingController.baseImage = drawingCell.imageView?.image
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
//    cell.backgroundColor = .lightGray
    cell.imageView?.image = drawings[indexPath.row]
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
}
