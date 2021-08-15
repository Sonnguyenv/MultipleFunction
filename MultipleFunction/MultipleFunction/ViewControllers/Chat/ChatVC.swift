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
import FirebaseStorage
import Photos

enum CellType {
    case message(MessageModel)
    case image(MessageModel)
}

class ChatVC: BaseVC, MessageView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: ChatBarView!
    
    var presenter = PresenterMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        self.presenter.attachView(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
    }
    
    override func heightKeyboard(height: CGFloat) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: height), animated: false)
        self.tableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0 , right: 0)
    }
    
    override func keyboardHide() {
        self.scrollView.setContentOffset(.zero, animated: false)
        self.tableView.contentInset = UIEdgeInsets.zero
    }
    
    private func initViews() {
        self.navigationItem.title = presenter.room.name
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.tabBarController?.tabBar.isHidden = true

        self.tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        self.tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.presenter.items
            .do(onNext: { _ in
                self.scrollToLastItem()
            })
            .bind(to: tableView.rx.items) { table, index, element in
            switch element.typeMessage {
            case .context:
                return self.makeCellMessage(with: element, from: table)
            case .photo:
                return self.makeCellImage(with: element, from: table)
            default:
                return UITableViewCell()
            }
        }.disposed(by: disposeBag)
        
        self.textView.actionEvent.subscribe(onNext: {[weak self] event in
            guard let self = self else { return }
            switch event {
            case .send(let text):
                let message = MessageModel(type: .context, content: text)
                self.presenter.save(message)
            case .camera:
                self.showOptionCameraAndLibrary {
                    self.showCameraOrLibrary(true)
                } handlerLibrary: {
                    self.showCameraOrLibrary(false)
                }

            case .handleScroll:
                let height = self.tableView.contentSize.height
                self.tableView.setContentOffset(CGPoint(x: 0, y: height), animated: false)
            }
        }).disposed(by: disposeBag)
    }
    
    private func makeCellMessage(with element: MessageModel, from table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell else {
            return UITableViewCell()
        }
        
        cell.parseData(element)
        cell.actionLongPress = {[weak self] message in
            guard let self = self else { return }
            let isEnableDelete = message.userId == UIDevice.current.identifierForVendor?.uuidString
            self.showActionSheet(isEnableDelete: isEnableDelete, handlerDelete: {
                self.presenter.remove(message)
            }, handlerCopy: {
                UIPasteboard.general.string = message.content
            })
        }
        return cell
    }

    private func makeCellImage(with element: MessageModel, from table: UITableView) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "ImageCell") as? ImageCell else {
            return UITableViewCell()
        }
        cell.parseData(element)
        return cell
    }
    
    private func showCameraOrLibrary(_ isCamera: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = isCamera ? .camera : .photoLibrary
        self.present(picker, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func sendPhoto(_ image: UIImage) {
        self.presenter.uploadImage(image, to: self.presenter.room) { [weak self] url in
            guard let self = self else { return }
            guard let url = url else {
                return
            }
            
            let message = MessageModel(type: .photo, url: url)
            self.presenter.save(message)
        }
    }

    private func scrollToLastItem() {
        DispatchQueue.main.async {
            guard !self.presenter.items.value.isEmpty else {
                return
            }
            
            let indexPath = IndexPath(row: self.presenter.items.value.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension ChatVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
//        if let asset = info[.phAsset] as? PHAsset {
//            let size = CGSize(width: 500, height: 500)
//            PHImageManager.default().requestImage( for: asset, targetSize: size,
//                contentMode: .aspectFit, options: nil) { result, _ in
//                guard let image = result else {
//                    return
//                }
//                self.sendPhoto(image)
//            }
//        } else
        if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
