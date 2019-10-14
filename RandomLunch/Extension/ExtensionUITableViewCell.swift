//
//  ExtensionUITableViewCell.swift
//  RandomLunch
//
//  Created by Cüneyt AYVAZ on 11.10.2019.
//  Copyright © 2019 Cüneyt AYVAZ. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
}
