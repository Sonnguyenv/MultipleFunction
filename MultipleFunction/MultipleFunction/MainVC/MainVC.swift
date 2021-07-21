//
//  MainVC.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit

class MainVC: UIViewController {
        
    private var sideMenuVC: SideMenuVC!
    private var tabbar: TabBarController!
    
//    private var sideMenuShadowView: UIView!
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    // Expand/Collapse the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!

    private var revealSideMenuOnTop: Bool = true
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
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = self.isExpanded ? 0 : (-self.sideMenuRevealWidth - self.paddingForRotation)
            }
        }
    }
    
    func setupSideMenu() {
        
//        self.sideMenuShadowView = UIView(frame: self.view.bounds)
//        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.sideMenuShadowView.backgroundColor = .black
//        self.sideMenuShadowView.alpha = 0.0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
//        if self.revealSideMenuOnTop {
//            view.insertSubview(self.sideMenuShadowView, at: 1)
//        }

        // Tabbar
        
        self.tabbar = TabBarController(nibName: "TabBarController", bundle: nil)
//        self.view.insertSubview(self.tabbar.view, at: 0)
        self.view.addSubview(self.tabbar.view)
        self.addChild(self.tabbar)
        self.tabbar.didMove(toParent: self)

        // Side Menu
        self.sideMenuVC = SideMenuVC(nibName: "SideMenuVC", bundle: nil)
        
        self.sideMenuVC.defaultHighlightedCell = 0 // Default Highlighted Cell
        self.sideMenuVC.delegate = self
        self.view.addSubview(self.sideMenuVC.view)
//        self.view.insertSubview(self.sideMenuVC.view, at: 1)
        self.addChild(self.sideMenuVC)
        self.sideMenuVC.didMove(toParent: self)
        
        
        // Side Menu AutoLayout

        self.sideMenuVC.view.translatesAutoresizingMaskIntoConstraints = false

        if self.revealSideMenuOnTop {
            self.sideMenuTrailingConstraint = self.sideMenuVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
            self.sideMenuTrailingConstraint.isActive = true
        }
        
        NSLayoutConstraint.activate([
            self.sideMenuVC.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuVC.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        // Side Menu Gestures
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)

        // Default Main View Controller
//        showViewController(viewController: UINavigationController.self, storyboardId: "HomeNavID")
    }
    
//    func animateShadow(targetPosition: CGFloat) {
//        UIView.animate(withDuration: 0.5) {
//            // When targetPosition is 0, which means side menu is expanded, the shadow opacity is 0.6
//            self.view.alpha = (targetPosition == 0) ? 0.6 : 0.0
//        }
//    }
//
    @objc func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) {
                self.view.alpha = 0.7
            }
        }
        else {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) {
                self.view.alpha = 1.0
            }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }
}

extension MainVC: UIGestureRecognizerDelegate {
    @objc func tapGestureRecognizer(sender: UITapGestureRecognizer) {
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
    
    // Dragging Side Menu
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        guard gestureEnabled == true else { return }

        let position: CGFloat = sender.translation(in: self.view).x
        let velocity: CGFloat = sender.velocity(in: self.view).x

        switch sender.state {
        case .began:

            // If the user tries to expand the menu more than the reveal width, then cancel the pan gesture
            if velocity > 0, self.isExpanded {
                sender.state = .cancelled
            }

            // If the user swipes right but the side menu hasn't expanded yet, enable dragging
            if velocity > 0, !self.isExpanded {
                self.draggingIsEnabled = true
            }
            // If user swipes left and the side menu is already expanded, enable dragging
            else if velocity < 0, self.isExpanded {
                self.draggingIsEnabled = true
            }

            if self.draggingIsEnabled {
                // If swipe is fast, Expand/Collapse the side menu with animation instead of dragging
                let velocityThreshold: CGFloat = 550
                if abs(velocity) > velocityThreshold {
                    self.sideMenuState(expanded: self.isExpanded ? false : true)
                    self.draggingIsEnabled = false
                    return
                }

                if self.revealSideMenuOnTop {
                    self.panBaseLocation = 0.0
                    if self.isExpanded {
                        self.panBaseLocation = self.sideMenuRevealWidth
                    }
                }
            }

        case .changed:

            // Expand/Collapse side menu while dragging
            if self.draggingIsEnabled {
                if self.revealSideMenuOnTop {
                    // Show/Hide shadow background view while dragging
                    let xLocation: CGFloat = self.panBaseLocation + position
                    let percentage = (xLocation * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                    let alpha = percentage >= 0.7 ? 0.7 : 1 - percentage
                    self.view.alpha = alpha

                    // Move side menu while dragging
                    if xLocation <= self.sideMenuRevealWidth {
                        self.sideMenuTrailingConstraint.constant = xLocation - self.sideMenuRevealWidth
                    }
                }
                else {
                    if let recogView = sender.view?.subviews[1] {
                        // Show/Hide shadow background view while dragging
                        let percentage = (recogView.frame.origin.x * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                        let alpha = percentage >= 0.7 ? 0.7 : 1 - percentage
                        self.view.alpha = alpha

                        // Move side menu while dragging
                        if recogView.frame.origin.x <= self.sideMenuRevealWidth, recogView.frame.origin.x >= 0 {
                            recogView.frame.origin.x = recogView.frame.origin.x + position
                            sender.setTranslation(CGPoint.zero, in: view)
                        }
                    }
                }
            }
        case .ended:
            self.draggingIsEnabled = false
            // If the side menu is half Open/Close, then Expand/Collapse with animation
            if self.revealSideMenuOnTop {
                let movedMoreThanHalf = self.sideMenuTrailingConstraint.constant > -(self.sideMenuRevealWidth * 0.5)
                self.sideMenuState(expanded: movedMoreThanHalf)
            }
            else {
                if let recogView = sender.view?.subviews[1] {
                    let movedMoreThanHalf = recogView.frame.origin.x > self.sideMenuRevealWidth * 0.5
                    self.sideMenuState(expanded: movedMoreThanHalf)
                }
            }
        default:
            break
        }
    }
}

extension MainVC: SideMenuDelegate {
    func selectItem(_ row: Int) {
//        switch row {
//        case 0:
//            // Home
//            self.showViewController(viewController: UINavigationController.self, storyboardId: "HomeNavID")
//        case 1:
//            // Music
//            self.showViewController(viewController: UINavigationController.self, storyboardId: "MusicNavID")
//        case 2:
//            // Movies
//            self.showViewController(viewController: UINavigationController.self, storyboardId: "MoviesNavID")
//        case 3:
//            // Books
//            self.showViewController(viewController: BooksViewController.self, storyboardId: "BooksVCID")
//        case 4:
//            // Profile
//            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//            let profileModalVC = storyboard.instantiateViewController(withIdentifier: "ProfileModalID") as? ProfileViewController
//            present(profileModalVC!, animated: true, completion: nil)
//        case 5:
//            // Settings
//            self.showViewController(viewController: UINavigationController.self, storyboardId: "SettingsNavID")
//        case 6:
//            // Like us on facebook
//            let safariVC = SFSafariViewController(url: URL(string: "https://www.facebook.com/johncodeos")!)
//            present(safariVC, animated: true)
//        default:
//            break
//        }

        // Collapse side menu with animation
        DispatchQueue.main.async {
            self.sideMenuState(expanded: false)
        }
    }

    func showViewController<T: UIViewController>(viewController: T.Type, storyboardId: String) -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        vc.view.tag = 99
        view.insertSubview(vc.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(vc)
        if !self.revealSideMenuOnTop {
            if isExpanded {
                vc.view.frame.origin.x = self.sideMenuRevealWidth
            }
//            if self.sideMenuShadowView != nil {
//                vc.view.addSubview(self.sideMenuShadowView)
//            }
        }
        vc.didMove(toParent: self)
    }
}
