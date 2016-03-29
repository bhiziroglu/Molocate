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
        fotoButton.layer.borderWidth = 0.1
        fotoButton.layer.masksToBounds = false
        fotoButton.layer.borderColor = UIColor.whiteColor().CGColor
        fotoButton.layer.cornerRadius = fotoButton.frame.height/2
        fotoButton.clipsToBounds = true
        
        let reportImage = UIImage(named: "profilepic.png")! as UIImage
        fotoButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        contentView.addSubview(fotoButton)
        
        myButton = UIButton()
        myButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 12)
        myButton.titleLabel?.numberOfLines = 1
        
        myLabel = UILabel()
        
    }
}