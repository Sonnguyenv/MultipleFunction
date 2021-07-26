//
//  MessageModel.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 23/07/2021.
//

import UIKit
import Firebase
import FirebaseFirestore

struct MessageModel {
    let id: String?
    var userId: String?
    let userName: String?
    let createdDate: Date
    var content: String

    init(userName: String, content: String) {
        self.id = nil
        self.userName = userName
        self.content = content
        self.createdDate = Date()
        self.userId = UIDevice.current.identifierForVendor?.uuidString
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let createdDate = data["created"] as? Timestamp,
            let userName = data["userName"] as? String,
            let content = data["content"] as? String,
            let userId = data["userId"] as? String
        else {
            return nil
        }

        self.id = document.documentID
        self.userName = userName
        self.createdDate = createdDate.dateValue()
        self.content = content
        self.userId = userId
    }

    func toDocument() -> [String: Any] {
        var document: [String: Any] = [:]

        if let id = id {
            document["id"] = id
        }
        document["userName"] =  userName ?? ""
        document["content"] = content
        document["created"] = createdDate
        document["userId"] = userId
        return document
    }
}

// MARK: - Comparable
extension MessageModel: Comparable {
  static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
    return lhs.id == rhs.id
  }

  static func < (lhs: MessageModel, rhs: MessageModel) -> Bool {
    return lhs.createdDate < rhs.createdDate
  }
}
