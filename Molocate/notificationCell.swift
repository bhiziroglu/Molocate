//
//  notificationCell.swift
//  Molocate
//
//  Created by Kagan Cenan on 21.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class notificationCell: UITableViewCell {
    var fotoButton: UIButton!
    var myLabel: UILabel!
    var myButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        fotoButton = UIButton()
        fotoButton.frame = CGRectMake(5 , 10 , 34 , 34)
        let reportImage = UIImage(named: "profilepic.png")! as UIImage
        fotoButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        contentView.addSubview(fotoButton)
        
        myButton = UIButton()
        myButton.titleLabel?.numberOfLines = 1
        myLabel = UILabel()
        
    }
}