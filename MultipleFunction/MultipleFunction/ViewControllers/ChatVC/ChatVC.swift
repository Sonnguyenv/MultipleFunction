//
//  ChatVC.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore

class ChatVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: ChatBarView!
    
    private let database = Firestore.firestore()
    private var reference: CollectionReference?
    private var messageListener: ListenerRegistration?

    private let items = BehaviorRelay<[MessageModel]>(value: [])
    
    var room: RoomModel = RoomModel()
    
    deinit {
        messageListener?.remove()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenToMessages()
        self.registerKeyboardNotifications()
        self.initViews()
    }
    
    private func initViews() {
        
        self.navigationItem.title = room.name
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")

        self.items.bind(to: tableView.rx.items(cellIdentifier: "MessageCell", cellType: MessageCell.self)) { (row, element, cell) in
            cell.parseData(element)
            cell.actionLongPress = {[weak self] message in
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { alert in
                    self?.reference?.document(message.id ?? "").delete()
                }
                
                let copyAction = UIAlertAction(title: "Copy", style: .default) { alert in
                    UIPasteboard.general.string = message.content
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                
                if message.userId == UIDevice.current.identifierForVendor?.uuidString {
                    optionMenu.addAction(deleteAction)
                }
                optionMenu.addAction(copyAction)
                optionMenu.addAction(cancelAction)
                
                self?.present(optionMenu, animated: true, completion: nil)
            }
        }.disposed(by: disposeBag)
        
        self.textView.actionSend.subscribe(onNext: { text in
            let name = Global.shared.displayName
            let message = MessageModel(userName: name, content: text)
            self.save(message)
        }).disposed(by: disposeBag)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow(notification:)),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide(notification:)),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
    }
    
    private func listenToMessages() {
        guard let id = room.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        self.onShowProgress()
        self.reference = database.collection("ChatChanel/\(id)/thread")
        
        self.messageListener = reference?.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
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
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = MessageModel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            self.insertNewMessage(message)
        case .modified:
            self.updateMessage(message)
        case .removed:
            self.removeMessage(message)
        }
    }
    
    private func insertNewMessage(_ message: MessageModel) {
        let values = self.items.value
        if values.contains(message) {
            return
        }
        
        let array = values + [message]
        self.items.accept(array.sorted())
        self.reloadData()
    }
    
    private func updateMessage(_ message: MessageModel) {
        var values = self.items.value

        guard let index = values.firstIndex(where: {$0.id == message.id}) else {
            return
        }
        values[index] = message
        self.items.accept(values)
    }
    
    private func removeMessage(_ message: MessageModel) {
        var values = self.items.value
        guard let index = values.firstIndex(where: {$0.id == message.id}) else {
            return
        }
        values.remove(at: index)
        self.items.accept(values)
    }
    
    private func save(_ message: MessageModel) {
        self.reference?.addDocument(data: message.toDocument()) { [weak self] error in
            guard let _ = self else { return }
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }
        }
    }

    @objc private func keyboardWillShow(notification:NSNotification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom , right: 0)
        self.scrollView.contentOffset.y = bottom
        self.tableView.contentInset = UIEdgeInsets(top: bottom, left: 0, bottom: 0 , right: 0)
    }

    @objc private func keyboardWillHide(notification:NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.tableView.contentInset = UIEdgeInsets.zero
    }

    private func reloadData() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.items.value.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension ChatVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension ChatVC: UITableViewDelegate {

}
