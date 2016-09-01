//
//  SampleCell.swift
//  CarsonDaily
//
//  Created by Kevin Clark on 8/4/16.
//  Copyright © 2016 Translate Abroad. All rights reserved.
//

import UIKit

class SampleCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    var sample: Sample! {
        willSet {
            titleLbl.text = newValue.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLbl.textColor = UIColor.whiteColor()
        backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            titleLbl.textColor = UIColor.init(red: 52/255.0, green: 223/255.0, blue: 233/255.0, alpha: 1)
        }
        else {
            titleLbl.textColor = UIColor.whiteColor()
        }
    }

}
