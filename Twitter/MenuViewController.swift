//
//  MenuViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/30/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let titlesMenu = ["Home", "User"]
    var hamburgerViewController: HamburgerViewController!
    var viewControllers: [UIViewController] = []
    private var profileUserViewController: UIViewController!
    private var tweetsViewController: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        let storyBoard = UIStoryboard(name: "Main", bundle:  nil)
        profileUserViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileUserViewController")
        tweetsViewController = storyBoard.instantiateViewControllerWithIdentifier("TweetsViewController")
        viewControllers.append(tweetsViewController)
        viewControllers.append(profileUserViewController)
    }
    
    override func viewDidAppear(animated: Bool) {
        hamburgerViewController.contentViewController = viewControllers[0]
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
// TableView
extension MenuViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return titlesMenu.count
        default:
            return 0
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch  indexPath.section {
        case 0:
            let cell  = tableView.dequeueReusableCellWithIdentifier("UserHeaderCell") as! UserHeaderCell
            cell.user = User._currentUser
            cell.constrainsRightOfViewHeader.constant = 50
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            cell.titleLabel.text = titlesMenu[indexPath.row]
            if cell.titleLabel.text == "Home" {
                cell.imageTitle.image = UIImage(named: "home-icon")
            } else {
                 cell.imageTitle.image = UIImage(named: "user-icon")
            }
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 222
        case 1:
            return 45
        default:
            return 0
        }
    }
}
