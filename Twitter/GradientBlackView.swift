//
//  GradientBlackView.swift
//  Twitter
//
//  Created by Cao Thắng on 7/24/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import Foundation
import UIKit
class GradientBlackView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     
     }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    func setUpView(){
        self.backgroundColor = UIColor.clearColor()
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor,UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8).CGColor]
        self.layer.insertSublayer(gradient, atIndex: 0)
    }

}
