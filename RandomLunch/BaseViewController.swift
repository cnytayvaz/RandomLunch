//
//  BaseViewController.swift
//  RandomLunch
//
//  Created by Cüneyt AYVAZ on 11.10.2019.
//  Copyright © 2019 Cüneyt AYVAZ. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background.png"))
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = isNavigationBarHidden()
        navigationItem.hidesBackButton = !isBackActionEnabled()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isBackActionEnabled()
    }
    
    func isNavigationBarHidden() -> Bool {
        return false
    }
    
    func isBackActionEnabled() -> Bool {
        return true
    }
}


