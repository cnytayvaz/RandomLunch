//
//  ExtensionUIViewController.swift
//  RandomLunch
//
//  Created by Cüneyt AYVAZ on 11.10.2019.
//  Copyright © 2019 Cüneyt AYVAZ. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(title: String = "Message",
                          message: String,
                          buttonText: String = "OK",
                          buttonAction: @escaping () -> Void = { }) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: buttonText, style: .default) { _ in
            buttonAction()
        }
        alert.addAction(button)
        
        presentViewController(viewController: alert)
    }
    
    func presentViewController(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        present(viewController, animated: animated, completion: completion)
    }
    
    func dismissViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(animated: animated, completion: completion)
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func popToRootViewController(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
}
