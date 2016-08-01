//
//  LoginViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/22/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    @IBOutlet weak var gradientBlackView: UIView!
    
    @IBOutlet weak var signInLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view. 0, 172, 237 |  29, 202, 255
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        TwitterClient.sharedInstance.login({
            print("I've loged in")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let resultViewController = storyBoard.instantiateViewControllerWithIdentifier("HamburgerViewController") as! HamburgerViewController
            
            self.presentViewController(resultViewController, animated:true, completion:nil)
        }) { (error: NSError) in
            print("ErrorL \(error.localizedDescription)")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
