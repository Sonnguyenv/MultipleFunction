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

class HomeVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!

    let nameDataBase: String = "ChatChanel"
    
    private let database = Firestore.firestore()
    private var reference: CollectionReference {
      return database.collection(nameDataBase)
    }

    private var rooms = BehaviorRelay<[RoomModel]>(value: [])
    private var channelListener: ListenerRegistration?
    private var currentChannelAlertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        self.setupChannelListener()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    private func setupChannelListener() {
        self.channelListener = reference.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            self.onShowProgress()
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
            self.onDismissProgress()
        }
    }

    private func initViews() {
        self.addSideMenu()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(addUser))
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        self.rooms.bind(to: tableView.rx.items(cellIdentifier: "UserCell",
                                               cellType: UserCell.self)) {[weak self] (row, room, cell) in
            guard let _ = self else {return}
            cell.parseData(room)
        }.disposed(by: disposeBag)

        self.tableView.rx.modelSelected(RoomModel.self).subscribe(onNext: {[weak self] room in
            guard let self = self else {return}
            let vc = ChatVC()
            vc.room = room
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        self.tableView.rx.itemDeleted.subscribe(onNext: {[weak self] index in
            guard let self = self else {return}
            let user = self.rooms.value[index.row]
            self.reference.document(user.id ?? "").delete()
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
            self.createUser()
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

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let user = RoomModel(document: change.document) else {
            return
        }

        switch change.type {
        case .added:
            self.addChannelToTable(user)
        case .modified:
            self.updateChannelInTable(user)
        case .removed:
            self.removeChannelFromTable(user)
        }
    }

    // MARK: - Helpers
    @objc private func createUser() {
      guard
        let alertController = currentChannelAlertController,
        let channelName = alertController.textFields?.first?.text
      else {
        return
      }

      let channel = RoomModel(name: channelName)
        self.reference.addDocument(data: channel.toDocument()) { error in
        if let error = error {
          print("Error saving channel: \(error.localizedDescription)")
        }
      }
    }

    private func addChannelToTable(_ user: RoomModel) {
        if self.rooms.value.contains(user) {
            return
        }

        let newUser = rooms.value + [user]
        self.rooms.accept(newUser.sorted())
    }

    private func updateChannelInTable(_ user: RoomModel) {
        var allUser = self.rooms.value
        guard let index = allUser.firstIndex(where: {$0.id == user.id}) else {
            return
        }
        allUser[index] = user
        self.rooms.accept(allUser)
    }

    private func removeChannelFromTable(_ user: RoomModel) {
        var allUser = self.rooms.value
        guard let index = allUser.firstIndex(where: {$0.id == user.id}) else {
            return
        }
        allUser.remove(at: index)
        self.rooms.accept(allUser)
    }
}
