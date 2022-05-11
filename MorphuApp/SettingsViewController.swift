//
//  SettingsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 5/11/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

final class SettingsViewController: UITableViewController {

  @IBOutlet weak var snapSwitch: UISwitch?

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = Theme.backgroundGrey
    tableView.separatorColor = Theme.divider


    let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
    footerLabel.textColor = .lightGray
    footerLabel.textAlignment = .center
    footerLabel.numberOfLines = 2
    tableView.tableFooterView = footerLabel
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      footerLabel.text = "Version \(version)\n© Dylan Wight"
    }
  }


  // MARK: - UITableViewController
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.5
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 20.0
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let separatorView = UIView(frame: CGRect(
      x: 0,
      y: 0,
      width: tableView.frame.width,
      height: 0.5))
    separatorView.backgroundColor = Theme.divider
    return separatorView
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView()
    footerView.backgroundColor  = Theme.backgroundGrey
    let separatorView = UIView(frame: CGRect(
      x: 0,
      y: footerView.frame.height,
      width: tableView.frame.width,
      height: 0.5))
    separatorView.backgroundColor = .separator
    footerView.addSubview(separatorView)
    return footerView
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.section == 1 else { return }
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath.row {
    case 0:
      openPage(page: "https://instagram.com/colorue")
    case 1:
      openPage(page: "https://github.com/colorue/ios")
    case 2:
      // Share
      return
    case 3:
      openPage(page: "https://colorue.org")
    case 4:
      // Rate the app
      return
    default:
      return
    }
  }

  private func openPage(page: String) {
    if let url = URL(string: page) {
      UIApplication.shared.open(url)
    }
  }
}
