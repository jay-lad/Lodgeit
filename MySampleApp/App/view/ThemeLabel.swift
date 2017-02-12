//
//  ThemeLabel.swift
//  MySampleApp
//
//  Created by piyushMac on 10/02/17.
//
//

import UIKit

class ThemeLabelTitle: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.font = UIFont.systemFontOfSize(22.0)
        self.textColor = themeColor
    }
}

class ThemeLabelDetail: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.font = UIFont.systemFontOfSize(14)
    }
}

class ThemeLabelDetailBold: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if #available(iOS 8.2, *) {
            self.font = UIFont.systemFontOfSize(14, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
        }
    }
}
