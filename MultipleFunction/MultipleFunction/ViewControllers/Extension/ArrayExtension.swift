//
//  ArrayExtension.swift
//  Binance-ios
//
//  Created by Sonnv on 12/06/2021.
//

import Foundation
import UIKit

extension Array {
    subscript (safe index: Int) -> Element? {
        get {
            return (0 <= index && index < count) ? self[index] : nil
        }
        set (value) {
            if value == nil {
                return
            }

            if !(count > index) {
                print("WARN: index:\(index) is out of range, so ignored. (array:\(self))")
                return
            }

            self[index] = value!
        }
    }
}
