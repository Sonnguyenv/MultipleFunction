//
//  UIViewControllerExtension.swift
//  MultipleFunction
//
//  Created by Sonnv on 28/07/2021.
//

import UIKit

extension UIViewController {
    
    func showActionSheet(_ title: String? = nil, _ message: String? = nil, isEnableDelete: Bool, handlerDelete: @escaping() -> Void, handlerCopy: @escaping() -> Void) {
        let optionMenu = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { alert in
            handlerDelete()
        }
        
        let copyAction = UIAlertAction(title: "Copy", style: .default) { alert in
            handlerCopy()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if isEnableDelete {
            optionMenu.addAction(deleteAction)
        }
        optionMenu.addAction(copyAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func showOptionCameraAndLibrary(handlerCamera: @escaping() -> Void, handlerLibrary: @escaping() -> Void) {
        let optionMenu = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        let actionCamera = UIAlertAction(title: "Camera", style: .default, handler: { _ in
            handlerCamera()
        })
        
        let actionLibrary = UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            handlerLibrary()
        })
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(actionCamera)
        optionMenu.addAction(actionLibrary)
        optionMenu.addAction(actionCancel)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}
