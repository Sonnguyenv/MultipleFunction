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
    var messageId: String? {
      return id ?? UUID().uuidString
    }
    let userName: String?
    let createdDate: Date
    var content: String

    init(user: UserlModel, content: String) {
        self.userName = user.name
        self.content = content
        self.createdDate = Date()
        self.id = nil
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let createdDate = data["created"] as? Timestamp,
            let userName = data["userName"] as? String,
            let content = data["content"] as? String
        else {
            return nil
        }

        self.id = document.documentID
        self.userName = userName
        self.createdDate = createdDate.dateValue()
        self.content = content
    }

    func toDocument() -> [String: Any] {
        var document: [String: Any] = [:]

        if let id = id {
            document["id"] = id
        }
        document = ["content": content]
        document = ["created": createdDate]

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
