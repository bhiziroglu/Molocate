//
//  commentCell.swift
//  Molocate
//
//  Created by MellonCorp on 3/15/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {

    @IBOutlet var comment: UILabel!
    @IBOutlet var username: UIButton!
    @IBOutlet var profilePhoto: UIButton!
    
    var screenSize = UIScreen.mainScreen().bounds
   
   
    override func awakeFromNib() {
      
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
        
    
}
