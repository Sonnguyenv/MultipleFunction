//
//  FireBase.swift
//  MultipleFunction
//
//  Created by Sonnv on 10/08/2021.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import RxSwift
import RxCocoa
import RealmSwift

protocol RoomView: BaseView {}

class PresenterRoomFireBase: Presenter {
    typealias T = RoomView
    var view: RoomView?
    
    let nameDataBase: String = "ChatChanel"
    
    
    private let database = Firestore.firestore()
    private var reference: CollectionReference {
      return database.collection(nameDataBase)
    }
    private let storage = Storage.storage().reference()
    private var listener: ListenerRegistration?
    
    var rooms = BehaviorRelay<[RoomModel]>(value: [])
    
    init() {}
    
    func attachView(_ view: RoomView) {
        self.view = view
        self.setupChannelListener()
    }
    
    func detachView() {
        self.view = nil
    }
    
    private func setupChannelListener() {
        self.view?.onShowProgress?()
        self.listener = reference.addSnapshotListener { [weak self] querySnapshot, error in
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
            self.view?.onDismissProgress?()
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let room = RoomModel(document: change.document) else {
            return
        }

        switch change.type {
        case .added:
            self.handleRoom(type: .added, room: room)
        case .modified:
            self.handleRoom(type: .modified, room: room)
        case .removed:
            self.handleRoom(type: .removed, room: room)
        }
    }
    
    private func handleRoom(type: TypeDocument, room: RoomModel) {
        var values = self.rooms.value
        switch type {
        case .added:
            if values.contains(room) {
                return
            }

            values = values + [room]
        case .modified:
            guard let index = values.firstIndex(where: {$0.id == room.id}) else {
                return
            }
            values[index] = room
        case .removed:
            guard let index = values.firstIndex(where: {$0.id == room.id}) else {
                return
            }
            values.remove(at: index)
        }
        self.rooms.accept(values.sorted(by: {$0.createdDate > $1.createdDate}))
    }
   
    func removeRoom(_ room: RoomModel) {
        self.reference.document(room.id ?? "").delete { error in
            if let error = error {
                self.view?.handleError(error, option: nil)
            }
        }
    }
    
    func addRoom(_ room: RoomModel) {
        self.reference.addDocument(data: room.toDocument()) { error in
            if let error = error {
                self.view?.handleError(error, option: nil)
            }
        }
    }
}
