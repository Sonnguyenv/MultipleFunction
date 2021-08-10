//
//  MessageModel.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 23/07/2021.
//

import UIKit
import Firebase
import FirebaseFirestore

enum TypeMessage: String {
    case context
    case photo
}

struct MessageModel {
    var typeMessage: TypeMessage?
    var id: String?
    var userId: String?
    var userName: String?
    var createdDate: Date?
    var content: String?
    
    var image: UIImage?
    var downloadURL: URL?

    init(type: TypeMessage, content: String) {
        self.typeMessage = .context
        self.content = content
        self.userName = Global.shared.displayName
        self.userId = UIDevice.current.identifierForVendor?.uuidString
        self.createdDate = Date()
    }
    
    init(type: TypeMessage, url: URL) {
        self.typeMessage = .photo
        self.downloadURL = url
        self.userName = Global.shared.displayName
        self.userId = UIDevice.current.identifierForVendor?.uuidString
        self.createdDate = Date()
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        self.id = document.documentID
        
        if let string = data["type"] as? String {
            self.typeMessage = TypeMessage(rawValue: string)
        }
        
        if let createdDate = data["created"] as? Timestamp {
            self.createdDate = createdDate.dateValue()
        }
        
        if let userName = data["userName"] as? String {
            self.userName = userName
        }
        
        if let content = data["content"] as? String {
            self.content = content
        }
        
        if let userId = data["userId"] as? String {
            self.userId = userId
        }
        
        if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            self.downloadURL = url
        }
        
        self.image = nil
    }

    func toDocument() -> [String: Any] {
        var document: [String: Any] = [:]
        
        document["type"] = self.typeMessage == .context ? "context" : "photo"
        
        if let id = id {
            document["id"] = id
        }
        
        document["userName"] =  userName ?? ""
        document["content"] = content
        document["created"] = createdDate
        document["userId"] = userId
        
        if let url = downloadURL {
            document["url"] = url.absoluteString
        }
                
        return document
    }
}

// MARK: - Comparable
extension MessageModel: Comparable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.createdDate ?? Date() < rhs.createdDate ?? Date()
    }
}
