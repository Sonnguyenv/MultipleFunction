//
//  BaseView.swift
//  MultipleFunction
//
//  Created by Sonnv on 15/08/2021.
//

import UIKit

@objc protocol BaseView {
    @objc func handleError(_ error: Error, option: Any?)
    @objc optional func onPullRefresh()
    @objc optional func onShowProgress()
    @objc optional func onDismissProgress()
}
