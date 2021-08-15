//
//  Presenter.swift
//  MultipleFunction
//
//  Created by Sonnv on 15/08/2021.
//

import UIKit

protocol Presenter {
    associatedtype T
    
    func attachView(_ view: T)
    func detachView()

}

