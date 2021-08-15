//
//  ChannelModel.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 23/07/2021.
//

import UIKit
import FirebaseFirestore
import RealmSwift

class RoomModel: Object {
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var createdDate: Date = Date()

    override static func primaryKey() -> String? {
        return "id"
    }
    
    override init() {}
    
    init(name: String) {
        id = nil
        self.name = name
        self.createdDate = Date()
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        self.id = document.documentID
        
        if let name = data["name"] as? String {
            self.name = name
        }

        if let createdDate = data["created"] as? Timestamp {
            self.createdDate = createdDate.dateValue()
        }
    }

    func toDocument() -> [String: Any] {
        var document: [String: Any] = [:]
        document["name"] = name

        if let id = id {
            document["id"] = id
        }

        document["created"] = createdDate
        return document
    }
}

// MARK: - Comparable
extension RoomModel: Comparable {
  static func == (lhs: RoomModel, rhs: RoomModel) -> Bool {
    return lhs.id == rhs.id
  }

  static func < (lhs: RoomModel, rhs: RoomModel) -> Bool {
    return lhs.name ?? "" < rhs.name ?? ""
  }
}
