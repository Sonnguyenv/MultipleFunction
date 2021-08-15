//
//  HouseVC.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

class HomeVC: BaseVC, RoomView {
   
    @IBOutlet weak var tableView: UITableView!
    
    var presenter = PresenterRoomFireBase()
    
    private var currentChannelAlertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attachView(self)
        self.initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
    }

    private func initViews() {
        self.addSideMenu()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(addUser))
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        self.presenter.rooms.bind(to: tableView.rx.items(cellIdentifier: "UserCell",
                                               cellType: UserCell.self)) {[weak self] (row, room, cell) in
            guard let _ = self else {return}
            cell.parseData(room)
        }.disposed(by: disposeBag)

        self.tableView.rx.modelSelected(RoomModel.self).subscribe(onNext: {[weak self] room in
            guard let self = self else {return}
            let vc = ChatVC()
            vc.presenter.room = room
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        self.tableView.rx.itemDeleted.subscribe(onNext: {[weak self] index in
            guard let self = self else {return}
            let room = self.presenter.rooms.value[index.row]
            self.presenter.removeRoom(room)
        }).disposed(by: disposeBag)
    }

    @objc private func addUser() {
        let alertController = UIAlertController(title: "Create a new user", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { field in
            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
            field.placeholder = "User name"
            field.returnKeyType = .done
        }

        let createAction = UIAlertAction(
            title: "Create",
            style: .default) { _ in
            self.createRoom()
        }
        createAction.isEnabled = false
        alertController.addAction(createAction)
        alertController.preferredAction = createAction

        present(alertController, animated: true) {
            alertController.textFields?.first?.becomeFirstResponder()
        }
        self.currentChannelAlertController = alertController
    }

    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let alertController = self.currentChannelAlertController else {
            return
        }
        alertController.preferredAction?.isEnabled = field.hasText
    }

    // MARK: - Helpers
    @objc private func createRoom() {
        guard let alertController = currentChannelAlertController,
              let roomName = alertController.textFields?.first?.text else {return}
        let room = RoomModel(name: roomName)
        self.presenter.addRoom(room)
    }
}
