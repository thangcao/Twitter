//
//  MenuViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/30/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController, BaseViewMenuControllerDelegate {
    
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var leftMarginContent: NSLayoutConstraint!
    
    var isOpenSlideMenu: Bool = false
    var menuviewController : UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuView.addSubview(menuviewController.view)
        }
    }
    var contentViewController: UIViewController! {
        didSet (oldContentViewController) {
            view.layoutIfNeeded()
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
                
            }
            contentViewController.willMoveToParentViewController(self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)
            if let navigationController = contentViewController as? UINavigationController {
                print("Hello")
                if navigationController.topViewController is BaseViewMenuController {
                    print("Hello 123 ")
                    let baseViewController  = navigationController.topViewController as! BaseViewMenuController
                    baseViewController.menuDelegate = self
                }
            }
            //            contentViewController.menuDelegate = self
            UIView.animateWithDuration(0.3) {
                self.leftMarginContent.constant = 0
                self.view.layoutIfNeeded()
                self.isOpenSlideMenu = true
            }
        }
    }
    var originalLeftMargin: CGFloat!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Do any additional setup after loading the view.
        
        
    }
    override func viewWillLayoutSubviews() {
       
    }
    override func viewDidAppear(animated: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        menuViewController.hamburgerViewController = self
        self.menuviewController = menuViewController
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            originalLeftMargin = leftMarginContent.constant
        } else if sender.state == UIGestureRecognizerState.Changed {
            if velocity.x > 0 {
                leftMarginContent.constant = originalLeftMargin + translation.x
            }
        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.5, animations: {
                if velocity.x > 0 {
                    self.leftMarginContent.constant = self.view.frame.size.width - 50
                    self.isOpenSlideMenu = false
                } else {
                    self.leftMarginContent.constant = 0
                    self.isOpenSlideMenu = true
                }
                self.view.layoutIfNeeded()
            })
            
        }
    }
    // MARK : SlideMenu Delegate
    func callSlideMenuDelegate(isCall: Bool) {
        if isCall{
            if isOpenSlideMenu {
                UIView.animateWithDuration(1, animations: {
                    self.leftMarginContent.constant = self.view.frame.size.width - 50
                    self.isOpenSlideMenu = false
                })
            } else {
                UIView.animateWithDuration(1, animations: {
                    self.leftMarginContent.constant = 0
                    self.isOpenSlideMenu = true
                })
            }
        }
    }
}
