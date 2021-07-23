//
//  SpinnerViewController.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 23/07/2021.
//

import UIKit

class SpinnerViewController: UIViewController {

    var spinner = UIActivityIndicatorView(style: .white)

    override func loadView() {
        view = UIView()
        view.backgroundColor = .gray.withAlphaComponent(0.3)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
