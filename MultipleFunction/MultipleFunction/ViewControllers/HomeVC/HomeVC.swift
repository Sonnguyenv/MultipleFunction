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
    private var channelReference: CollectionReference {
      return database.collection(nameDataBase)
    }

    private var users = BehaviorRelay<[UserlModel]>(value: [])
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
        channelListener = channelReference.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            self.onShowProgress()
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
//            let userabc = snapshot.documentChanges.flatMap({UserlModel(document: $0.document)})
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
            self.onDismissProgress()
        }
    }

    private func initViews() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .done,
                                                                target: self, action: #selector(showSideMenu))
        self.navigationItem.leftBarButtonItem?.tintColor = .black

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(addUser))
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        self.users.bind(to: tableView.rx.items(cellIdentifier: "UserCell",
                                               cellType: UserCell.self)) { (row, element, cell) in
            cell.parseData(element)
        }.disposed(by: disposeBag)

        self.tableView.rx.modelSelected(UserlModel.self).subscribe(onNext: {[weak self] user in
            let vc = ChatVC()
            vc.user = user
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }

    @objc private func showSideMenu() {
        EventHub.post(SideEvent())
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
        currentChannelAlertController = alertController
    }

    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let alertController = currentChannelAlertController else {
            return
        }
        alertController.preferredAction?.isEnabled = field.hasText
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let user = UserlModel(document: change.document) else {
            return
        }

        switch change.type {
        case .added:
            addChannelToTable(user)
        case .modified:
            updateChannelInTable(user)
        case .removed:
            removeChannelFromTable(user)
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

      let channel = UserlModel(name: channelName)
        channelReference.addDocument(data: channel.toDocument()) { error in
        if let error = error {
          print("Error saving channel: \(error.localizedDescription)")
        }
      }
    }

    private func addChannelToTable(_ user: UserlModel) {
        if users.value.contains(user) {
            return
        }

        let newUser = users.value + [user]
        users.accept(newUser.sorted())
    }

    private func updateChannelInTable(_ user: UserlModel) {
        var allUser = users.value
        guard let index = allUser.firstIndex(where: {$0.id == user.id}) else {
            return
        }
        allUser[index] = user
        self.users.accept(allUser)
    }

    private func removeChannelFromTable(_ user: UserlModel) {
        var allUser = users.value
        guard let index = allUser.firstIndex(where: {$0.id == user.id}) else {
            return
        }
        allUser.remove(at: index)
        self.users.accept(allUser)
    }
}
