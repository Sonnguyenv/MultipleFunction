//
//  MainVC.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit

class MainVC: BaseVC {
        
    private var sideMenuVC: SideMenuVC!
    private var tabbar: TabBarController!
    
    private var sideMenuShadowView: UIView!
    private var sideMenuRevealWidth: CGFloat = 260
    private var isExpanded: Bool = false

    // Expand/Collapse the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!

    var gestureEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventHub.addObserver(self, thread: .main) {[weak self] (_: SideEvent) in
            self?.sideMenuState(expanded: true)
        }
        
        self.setupSideMenu()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.sideMenuTrailingConstraint.constant = self.isExpanded ? 0 : (-self.sideMenuRevealWidth)
        }
    }
    
    func setupSideMenu() {
        self.sideMenuShadowView = UIView(frame: self.view.frame)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        sideMenuShadowView.addGestureRecognizer(tapGestureRecognizer)

        // Tabbar
        self.tabbar = TabBarController(nibName: "TabBarController", bundle: nil)
        self.view.addSubview(self.tabbar.view)
        self.addChild(self.tabbar)
        self.tabbar.didMove(toParent: self)

        self.view.addSubview(self.sideMenuShadowView)

        // Side Menu
        self.sideMenuVC = SideMenuVC(nibName: "SideMenuVC", bundle: nil)
        self.sideMenuVC.delegate = self
        self.view.addSubview(self.sideMenuVC.view)
        self.addChild(self.sideMenuVC)
        self.sideMenuVC.didMove(toParent: self)

        // AutoLayout
        self.sideMenuVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.tabbar.view.translatesAutoresizingMaskIntoConstraints = false

        self.sideMenuTrailingConstraint = self.sideMenuVC.view.leadingAnchor
                                                                .constraint(equalTo: view.leadingAnchor,
                                                                            constant: -self.sideMenuRevealWidth)
        self.sideMenuTrailingConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            self.sideMenuVC.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuVC.view.topAnchor.constraint(equalTo: view.topAnchor),

            self.tabbar.view.topAnchor.constraint(equalTo: view.topAnchor),
            self.tabbar.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.tabbar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.tabbar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: 0) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) {
                self.sideMenuShadowView.alpha = 0.2
            }
        }
        else {
            self.animateSideMenu(targetPosition: -self.sideMenuRevealWidth) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) {
                self.sideMenuShadowView.alpha = 0.0
            }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            self.sideMenuTrailingConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
}

extension MainVC: UIGestureRecognizerDelegate {
    @objc func tapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                self.sideMenuState(expanded: false)
            }
        }
    }

    // Close side menu when you tap on the shadow background view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.sideMenuVC.view))! {
            return false
        }
        return true
    }
}

extension MainVC: SideMenuDelegate {
    func selectItem(_ type: TypeSideMenu) {
        switch type {
        case .home:
            self.tabbar.selectedIndex = 0
        case .user:
            print("user")
        case.setting:
            print("setting")
        case .logout:
            self.logout()
        }

        // Collapse side menu with animation
        DispatchQueue.main.async {
            self.sideMenuState(expanded: false)
        }
    }
}
