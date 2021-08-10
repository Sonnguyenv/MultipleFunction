//
//  ChatVC.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit
import RxSwift
import RxCocoa
//import RxDataSources
import FirebaseFirestore
import FirebaseStorage
import Photos

enum CellType {
    case message(MessageModel)
    case image(MessageModel)
}

class ChatVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: ChatBarView!
    
    private let database = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private var messageListener: ListenerRegistration?

    private var heighttKeyBoard: CGFloat = 0.0
    
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

        self.tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        self.tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        items.bind(to: tableView.rx.items) { table, index, element in
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
                self.save(message)
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
                self.reference?.document(message.id ?? "").delete()
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
//        cell.actionLongPress = {[weak self] message in
//            guard let self = self else { return }
//            let isEnableDelete = message.userId == UIDevice.current.identifierForVendor?.uuidString
//            self.showActionSheet(isEnableDelete: isEnableDelete, handlerDelete: {
//                self.reference?.document(message.id ?? "").delete()
//            }, handlerCopy: {
//                UIPasteboard.general.string = message.content
//            })
//        }
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
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { notification in
                self.keyboardWillShow(notification as NSNotification)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map({$0})
            .subscribe(onNext: { notification in
                self.keyboardWillHide(notification as NSNotification)
        }).disposed(by: disposeBag)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        self.heighttKeyBoard = bottom
        self.scrollView.setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
        self.tableView.contentInset = UIEdgeInsets(top: bottom, left: 0, bottom: 0 , right: 0)
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.scrollView.setContentOffset(.zero, animated: false)
        self.tableView.contentInset = UIEdgeInsets.zero
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
            guard let url = message.downloadURL else {
                self.insertNewMessage(message)
                return
            }
            
            downloadImage(at: url) { [weak self] image in
              guard let self = self, let image = image else {
                return
              }
                var messageImage = message
                messageImage.image = image
                
              self.insertNewMessage(messageImage)
            }
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
        self.scrollToLastItem()
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
    

    private func sendPhoto(_ image: UIImage) {
        self.onShowProgress()
        self.uploadImage(image, to: room) { [weak self] url in
            guard let self = self else { return }
            guard let url = url else {
                return
            }
            
            let message = MessageModel(type: .photo, url: url)
            self.save(message)
            self.onDismissProgress()
        }
    }
    
    private func uploadImage(_ image: UIImage, to channel: RoomModel, completion: @escaping (URL?) -> Void) {
        guard let roomId = room.id, let scaledImage = image.scaledToSafeUploadSize,
            let data = scaledImage.jpegData(compressionQuality: 0.4)
        else {
            return completion(nil)
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let imageReference = storage.child("\(roomId)/\(imageName)")
        imageReference.putData(data, metadata: metadata) { _, _ in
            imageReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { data, _ in
            guard let imageData = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }

    private func scrollToLastItem() {
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

// MARK: - UIImagePickerControllerDelegate
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage( for: asset, targetSize: size,
                contentMode: .aspectFit, options: nil) { result, _ in
                guard let image = result else {
                    return
                }
                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
