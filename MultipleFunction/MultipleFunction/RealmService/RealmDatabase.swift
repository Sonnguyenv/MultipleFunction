//
//  RealmService.swift
//  MultipleFunction
//
//  Created by Sonnv on 11/08/2021.
//

import UIKit
import RealmSwift

class RealmDatabase: NSObject {
    // MARK: - Singleton
    static var instance = RealmDatabase()
    
    // MARK: - Supporting function
    func write(_ handler: ((_ realm: Realm) -> Void)) {
        do {
            let realm = try Realm()
            try realm.write {
                handler(realm)
            }
        } catch { }
    }
    
    func find<T: Object>(listOf: T.Type, primaryKey: String) -> T? {
        do {
            let realm = try Realm()
            return realm.object(ofType: T.self, forPrimaryKey: primaryKey)
        } catch {
            return nil
        }
    }
    
    func load<T: Object>(listOf: T.Type, filter: String? = nil) -> [T] {
        do {
            var objects = try Realm().objects(T.self)
            if let filter = filter {
                objects = objects.filter(filter)
            }
            var list = [T]()
            for obj in objects {
                list.append(obj)
            }
            return list
        } catch { }
        return []
    }
    
    func add<T: Object>(object: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch { }
    }
    
    func delete<T: Object>(type: T.Type, condition: String) {
        if let object = load(listOf: T.self, filter: condition).first {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(object)
                }
            } catch { }
        }
    }
}
