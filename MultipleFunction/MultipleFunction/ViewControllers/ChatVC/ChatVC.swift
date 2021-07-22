//
//  ChatVC.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit
import RxSwift
import RxCocoa

struct MessageModel {
    var name: String?
    var message: String?

    init() {}

    init(name: String, message: String) {
        self.name = name
        self.message = message
    }
}

class ChatVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var buttonSend: UIButton!

    let items = BehaviorRelay<[MessageModel]>(value: [])

    var message: MessageModel = MessageModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSideMenu(false)
        self.initViews()
        self.setupTextField()
    }

    func initViews() {
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        self.tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")

        items.bind(to: tableView.rx.items(cellIdentifier: "MessageCell", cellType: MessageCell.self)) { (row, element, cell) in
            cell.parseData(element)
        }.disposed(by: disposeBag)
    }

    func setupTextField() {
        self.textViewMessage.layer.cornerRadius = 10
        self.textViewMessage.layer.borderWidth = 1
        self.textViewMessage.layer.borderColor = UIColor.gray.cgColor

        self.textViewMessage.rx.text.orEmpty
            .subscribe(onNext: { text in
                self.message.message = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }).disposed(by: disposeBag)

        self.textViewMessage.rx.text.orEmpty
            .map({$0.count > 0})
            .bind(to: self.buttonSend.rx.isEnabled)
            .disposed(by: disposeBag)

        self.buttonSend.rx.tap
            .subscribe(onNext: {
                self.items.accept(self.items.value + [self.message])
//                self.insertMessage()
                self.tableView.reloadData()
                self.textViewMessage.text = nil
            }).disposed(by: disposeBag)
    }

//    func insertMessage() {
//        self.tableView.beginUpdates()
//        self.tableView.insertRows(at: [IndexPath.init(item: self.items.value.count - 1, section: 0)], with: .automatic)
//        self.tableView.endUpdates()
//    }
}

extension ChatVC: UITableViewDelegate {

}
