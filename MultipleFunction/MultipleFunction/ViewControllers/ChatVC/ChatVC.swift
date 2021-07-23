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
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    private let database = Firestore.firestore()
    private var reference: CollectionReference?
    private var messageListener: ListenerRegistration?

    private let items = BehaviorRelay<[MessageModel]>(value: [])
    private var message: MessageModel = MessageModel(user: UserlModel(name: ""), content: "")

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        self.setupTextField()
        self.registerKeyboardNotifications()
    }

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow(notification:)),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide(notification:)),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
    }

    @objc func keyboardWillShow(notification:NSNotification){
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

    @objc func keyboardWillHide(notification:NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.tableView.contentInset = UIEdgeInsets.zero
    }

    func initViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        self.tabBarController?.tabBar.isHidden = true
        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")

        self.items.bind(to: tableView.rx.items(cellIdentifier: "MessageCell", cellType: MessageCell.self)) { (row, element, cell) in
            cell.parseData(element)
        }.disposed(by: disposeBag)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupTextField() {
        self.textViewMessage.layer.cornerRadius = 15
        self.textViewMessage.layer.borderWidth = 1
        self.textViewMessage.layer.borderColor = UIColor.systemGray.cgColor

        self.textViewMessage.rx.text.orEmpty
            .subscribe(onNext: { text in
                self.message.content = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }).disposed(by: disposeBag)

        self.textViewMessage.rx.text.orEmpty
            .map({$0.trimmingCharacters(in: .whitespacesAndNewlines).count > 0})
            .bind(to: self.buttonSend.rx.isEnabled)
            .disposed(by: disposeBag)

        self.buttonSend.rx.tap
            .subscribe(onNext: {
                self.items.accept(self.items.value + [self.message])
                self.reloadData()
            }).disposed(by: disposeBag)
    }

    func reloadData() {
        self.textViewMessage.text = nil
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.items.value.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension ChatVC: UITableViewDelegate {

}
