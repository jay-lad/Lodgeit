//
//  ThemeButton.swift
//  MySampleApp
//
//  Created by piyushMac on 10/02/17.
//
//

import UIKit

class ThemeButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 3.0
        self.backgroundColor = themeColor
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState())
        self.titleLabel?.font = UIFont(name: "Helvetica", size: 16)
    }
}

class ThemeButtonDark: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = themeBackGroundColor
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState())
        self.titleLabel?.font = UIFont(name: "Helvetica", size: 16)
    }
}
