//
//  Global.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit

final class Global: NSObject {
    static let shared = Global()

    private struct Keywords {
        static let displayName = "DISPLAY_NAME"
    }

    var displayName: String {
        set {
            guard !newValue.isEmpty else {
                UserDefaults.standard.setValue("", forKey: Keywords.displayName)
                return
            }
            UserDefaults.standard.setValue(newValue, forKey: Keywords.displayName)
        }
        get {
            guard let value = UserDefaults.standard.string(forKey: Keywords.displayName) else {
                return ""
            }
            return value
        }
    }

    func clearAll() {
        UserDefaults.standard.setValue("", forKey: Keywords.displayName)
    }
}
