//
//  SideMenuVC.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit

enum TypeSideMenu {
    case home
    case user
    case setting
    case logout

    var image: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "home")
        case .user:
            return UIImage(named: "user")
        case .setting:
            return UIImage(named: "settings")
        case .logout:
            return UIImage(named: "exit")
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .user:
            return "Profile"
        case .setting:
            return "Setting"
        case .logout:
            return "Logout"
        }
    }
}

protocol SideMenuDelegate: AnyObject {
    func selectItem(_ type: TypeSideMenu)
}

class SideMenuVC: UIViewController {

    @IBOutlet var sideMenuTableView: UITableView!
    @IBOutlet var footerLabel: UILabel!

    var delegate: SideMenuDelegate?

    var defaultHighlightedCell: Int = 0

    var menu: [TypeSideMenu] = [.home, .user, .setting, .logout]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.backgroundColor = #colorLiteral(red: 0.737254902, green: 0.1294117647, blue: 0.2941176471, alpha: 1)
        self.sideMenuTableView.separatorStyle = .none

        // Set Highlighted Cell
        DispatchQueue.main.async {
            let defaultRow = IndexPath(row: self.defaultHighlightedCell, section: 0)
            self.sideMenuTableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
        }

        // Footer
        self.footerLabel.textColor = UIColor.white
        self.footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        self.footerLabel.text = "Developed by Sonnv"

        // Register TableView Cell
        self.sideMenuTableView.register(SideMenuCell.nib, forCellReuseIdentifier: SideMenuCell.identifier)

        // Update TableView with the data
        self.sideMenuTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension SideMenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewDataSource

extension SideMenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuCell.identifier, for: indexPath) as? SideMenuCell else { fatalError("xib doesn't exist") }

        cell.parseData(self.menu[indexPath.row])

        // Highlighted color
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = #colorLiteral(red: 0.6196078431, green: 0.1098039216, blue: 0.2509803922, alpha: 1)
        cell.selectedBackgroundView = myCustomSelectionColorView
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectItem(self.menu[indexPath.row])
    }
}

class SideEvent: EventType {
    
}


