//
//  SearchTableViewCell.swift
//  Cube
//
//  Created by SimranJot Singh on 18/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    //MARK: Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hex: 0x83d0c9)
        titleLabel.backgroundColor = UIColor(hex: 0x83d0c9)
    }
    
    func configureCell(title: String) {
        titleLabel.text = title
    }

}
