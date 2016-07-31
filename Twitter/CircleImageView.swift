//
//  CircleImageView.swift
//  Twitter
//
//  Created by Cao Thắng on 7/24/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    func setUpView(){
        self.layer.cornerRadius =
            self.frame.size.width / 2
        self.clipsToBounds = true
    }
    func borderView(radius: CGFloat, color: CGColor){
        self.clipsToBounds = true
        self.layer.borderColor = color
        self.layer.borderWidth = radius
    }
}
