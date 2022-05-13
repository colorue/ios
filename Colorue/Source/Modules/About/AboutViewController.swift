//
//  SettingsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 5/11/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

final class AboutViewController: UITableViewController {

  @IBOutlet weak var snapSwitch: UISwitch?

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = Theme.backgroundGrey
    tableView.separatorColor = Theme.divider


    let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
    footerLabel.textColor = .lightGray
    footerLabel.textAlignment = .center
    footerLabel.numberOfLines = 2
    footerLabel.font = .systemFont(ofSize: 16.0)
    tableView.tableFooterView = footerLabel
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      footerLabel.text = "Version \(version)\n© Dylan Wight"
    }
  }

  // MARK: - UITableViewController
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 12.0
  }
//
//  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//    return 20.0
//  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.section == 0 else { return }
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath.row {
    case 0:
      openPage(page: "https://instagram.com/colorue")
    case 1:
      openPage(page: "https://github.com/colorue/ios")
    case 2:
      shareColorue(page: "https://itunes.apple.com/app/id1621782369", indexPath: indexPath)
    case 3:
      openPage(page: "https://colorue.org")
    case 4:
      openPage(page: "mailto:feedback@colorue.com")
    case 5:
      writeReview()
    default:
      return
    }
  }

  private func openPage(page: String) {
    if let url = URL(string: page) {
      UIApplication.shared.open(url)
    }
  }

  func writeReview () {
    guard let url = URL(string: "https://itunes.apple.com/app/id1621782369") else { return }
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    components?.queryItems = [URLQueryItem(name: "action", value: "write-review")]
    guard let writeReviewURL = components?.url else { return }
    UIApplication.shared.open(writeReviewURL)
  }

  func shareColorue (page: String, indexPath: IndexPath) {
    guard let url = URL(string: page) else { return }

    let activityViewController : UIActivityViewController = UIActivityViewController(
      activityItems: ["Simple, but effective drawing for iOS", url], applicationActivities: nil)

    // This lines is for the popover you need to show in iPad
    activityViewController.popoverPresentationController?.sourceView = tableView
    if let cell = tableView?.cellForRow(at: indexPath) {
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
  }
}
