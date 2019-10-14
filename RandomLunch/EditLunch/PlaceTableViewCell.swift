//
//  PlaceTableViewCell.swift
//  RandomLunch
//
//  Created by Cüneyt AYVAZ on 11.10.2019.
//  Copyright © 2019 Cüneyt AYVAZ. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeRateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with place: Place) {
        placeNameLabel.text = place.name
        placeRateLabel.text = place.rate.description + "X"
        selectedView.isHidden = !place.selected
    }
    
}
