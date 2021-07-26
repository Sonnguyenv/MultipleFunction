//
//  ChannelModel.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 23/07/2021.
//

import UIKit
import FirebaseFirestore

struct UserlModel {
    var id: String?
    var name: String?

    init() {}
    
    init(name: String) {
        id = nil
        self.name = name
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let name = data["name"] as? String else {
            return nil
        }

        id = document.documentID
        self.name = name
    }

    func toDocument() -> [String: Any] {
        var document: [String: Any] = [:]
        document["name"] = name

        if let id = id {
            document["id"] = id
        }

        return document
    }
}

// MARK: - Comparable
extension UserlModel: Comparable {
  static func == (lhs: UserlModel, rhs: UserlModel) -> Bool {
    return lhs.id == rhs.id
  }

  static func < (lhs: UserlModel, rhs: UserlModel) -> Bool {
    return lhs.name ?? "" < rhs.name ?? ""
  }
}
