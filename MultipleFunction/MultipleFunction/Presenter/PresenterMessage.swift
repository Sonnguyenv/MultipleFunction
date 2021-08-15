//
//  PresenterMessage.swift
//  MultipleFunction
//
//  Created by Sonnv on 15/08/2021.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import RxSwift
import RxCocoa

enum TypeDocument {
    case added
    case modified
    case removed
}

protocol MessageView: BaseView {
}

class PresenterMessage: Presenter {
    typealias T = MessageView
    var view: MessageView?
    
    private let database = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    var room: RoomModel = RoomModel()
    
    var items = BehaviorRelay<[MessageModel]>(value: [])
    
    func attachView(_ view: MessageView) {
        self.view = view
        self.loadData()
    }
    
    func detachView() {
        self.view = nil
    }
    
    private func loadData() {
        guard let id = room.id else {
            return
        }
        
        self.reference = database.collection("ChatChanel/\(id)/thread")
        self.reference?.getDocuments(completion: { [weak self] querySnapshot, error in
            guard let self = self else { return }

            guard querySnapshot != nil else {
                if let error = error {
                    self.view?.handleError(error, option: nil)
                }
                return
            }
            querySnapshot?.documents.forEach({ snapshot in
                guard let message = MessageModel(document: snapshot) else {
                    return
                }
                self.insertMessage(message: message) { [weak self] newMessage in
                    guard let self = self else {return}
                    self.handleMessage(type: .added, message: newMessage)
                }
            })
        })
        
        self.listenToMessages()
    }
    
    private func listenToMessages() {
        reference?.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }

            guard let snapshot = querySnapshot else {
                if let error = error {
                    self.view?.handleError(error, option: nil)
                }
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = MessageModel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            self.insertMessage(message: message) { [weak self] newMessage in
                guard let self = self else {return}
                self.handleMessage(type: .added, message: newMessage)
            }
        case .modified:
            self.handleMessage(type: .modified, message: message)
        case .removed:
            self.handleMessage(type: .removed, message: message)
        }
    }
    
    private func handleMessage(type: TypeDocument, message: MessageModel) {
        var values = self.items.value
        switch type {
        case .added:
            if values.contains(message) {
                return
            }
            
            values = values + [message]
        case .modified:
            guard let index = values.firstIndex(where: {$0.id == message.id}) else {
                return
            }
            values[index] = message
        case .removed:
            guard let index = values.firstIndex(where: {$0.id == message.id}) else {
                return
            }
            values.remove(at: index)
        }
        self.items.accept(values.sorted())
    }
    
    func remove(_ message: MessageModel) {
        guard let id = message.id else {
            return
        }
        
        self.reference?.document(id).delete { error in
            if let error = error {
                self.view?.handleError(error, option: nil)
            }
        }
    }
    
    func save(_ message: MessageModel) {
        self.reference?.addDocument(data: message.toDocument()) { [weak self] error in
            guard let _ = self else { return }
            if let error = error {
                self?.view?.handleError(error, option: nil)
                return
            }
        }
    }
    
    func uploadImage(_ image: UIImage, to channel: RoomModel, completion: @escaping (URL?) -> Void) {
        guard let roomId = self.room.id, let scaledImage = image.scaledToSafeUploadSize,
            let data = scaledImage.jpegData(compressionQuality: 1)
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
    
    private func insertMessage(message: MessageModel, completion: @escaping (MessageModel) -> Void) {
        guard let url = message.downloadURL?.absoluteString else {
            completion(message)
            return
        }
        
        let ref = Storage.storage().reference(forURL: url)
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { data, _ in
            guard let imageData = data else {
                completion(message)
                return
            }
            
            var messageImage = message
            messageImage.image = UIImage(data: imageData)
            completion(messageImage)
        }
    }
}
