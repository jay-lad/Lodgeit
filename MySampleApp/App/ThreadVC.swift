//
//  ThreadVC.swift
//  MySampleApp
//
//  Created by Jay Lad on 13/02/17.
//
//

import UIKit
import AWSMobileHubHelper
import AWSAPIGateway

class ThreadVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblConversationList: UITableView!
    //    var demoFeatures: [DemoFeature] = []
    //dshf sdfkhsfj hds fhskdf
    var signInObserver: AnyObject!
    var signOutObserver: AnyObject!
    var willEnterForegroundObserver: AnyObject!
    
    let userNames: [String] = ["John", "Katie", "Jade", "Taylar"]
    let userLastMessage: [String] = ["Hi, How are you?", "What's up!", "Thank you", "See you tomorrow", "Have a great day"]
    let cellReuseIdentifier = "ThreadCell"
    
    // MARK: - View lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        AWSIdentityManager.defaultIdentityManager().identityId
        
        // You need to call `- updateTheme` here in case the sign-in happens before `- viewWillAppear:` is called.
        updateTheme()
        willEnterForegroundObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.currentQueue()) { _ in
            self.updateTheme()
        }
        
        presentSignInViewController()
        
        signInObserver = NSNotificationCenter.defaultCenter().addObserverForName(AWSIdentityManagerDidSignInNotification, object: AWSIdentityManager.defaultIdentityManager(), queue: NSOperationQueue.mainQueue(), usingBlock: {[weak self] (note: NSNotification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign In Observer observed sign in.")
            
            strongSelf.setupRightBarButtonItem()
            // You need to call `updateTheme` here in case the sign-in happens after `- viewWillAppear:` is called.
            strongSelf.updateTheme()
            })
        
        signOutObserver = NSNotificationCenter.defaultCenter().addObserverForName(AWSIdentityManagerDidSignOutNotification, object: AWSIdentityManager.defaultIdentityManager(), queue: NSOperationQueue.mainQueue(), usingBlock: {[weak self](note: NSNotification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign Out Observer observed sign out.")
            strongSelf.setupRightBarButtonItem()
            strongSelf.updateTheme()
            })
        
        setupRightBarButtonItem()
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSCognitoUserPoolRegion, identityPoolId: "us-east-1:7d68636d-14e4-4f46-92ea-31b5d1cd7946")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        
        let body = ACSTokenRequest()
        body.userid = AWSIdentityManager.defaultIdentityManager().identityId
        
        let client = ACSACSApisClient.defaultClient()
        
        client.getTokenPost(body).continueWithBlock {(task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            
            if let result = task.result {
                // Do something with result
                print(result)
            }
            return nil
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(signInObserver)
        NSNotificationCenter.defaultCenter().removeObserver(signOutObserver)
        NSNotificationCenter.defaultCenter().removeObserver(willEnterForegroundObserver)
    }
    
    func setupRightBarButtonItem() {
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken, {
            let loginButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .Done, target: self, action: nil)
            self.navigationItem.rightBarButtonItem = loginButton
        })
        
        if (AWSIdentityManager.defaultIdentityManager().loggedIn) {
            navigationItem.rightBarButtonItem!.title = NSLocalizedString("Sign-Out", comment: "Label for the logout button.")
            navigationItem.rightBarButtonItem!.action = #selector(self.handleLogout)
        }
    }
    
    func presentSignInViewController() {
        if !AWSIdentityManager.defaultIdentityManager().loggedIn {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("SignIn")
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    func updateTheme() {
        let settings = ColorThemeSettings.sharedInstance
        settings.loadSettings { (themeSettings: ColorThemeSettings?, error: NSError?) -> Void in
            guard let themeSettings = themeSettings else {
                print("Failed to load color: \(error)")
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                let titleTextColor: UIColor = themeSettings.theme.titleTextColor.UIColorFromARGB()
                self.navigationController!.navigationBar.barTintColor = themeSettings.theme.titleBarColor.UIColorFromARGB()
                self.view.backgroundColor = themeSettings.theme.backgroundColor.UIColorFromARGB()
                self.navigationController!.navigationBar.tintColor = titleTextColor
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleTextColor]
                self.tblConversationList.delegate = self
                self.tblConversationList.dataSource = self
                self.tblConversationList.reloadData()
            })
        }
    }
    
    
    func handleLogout() {
        if (AWSIdentityManager.defaultIdentityManager().loggedIn) {
            ColorThemeSettings.sharedInstance.wipe()
            AWSIdentityManager.defaultIdentityManager().logoutWithCompletionHandler({(result: AnyObject?, error: NSError?) -> Void in
                self.navigationController!.popToRootViewControllerAnimated(false)
                self.setupRightBarButtonItem()
                self.presentSignInViewController()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ThreadCell
        
        cell.lblUserName?.text = self.userNames[indexPath.row]
        //        cell.detailTextLabel?.text = self.userLastMessage[indexPath.row]
        
        return cell
        
    }
    
    //    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return self.userNames.count
    //    }
    //
    //    // create a cell for each table view row
    //    func tableView(tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
    //
    //        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ConversatinLIstTableViewCell
    //
    //        cell.lblUserName?.text = self.userNames[indexPath.row]
    ////        cell.detailTextLabel?.text = self.userLastMessage[indexPath.row]
    //
    //        return cell
    //    }
    //
    //    // method to run when table view cell is tapped
    //    func tableView(tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
    //        print("You tapped cell number \(indexPath.row).")
    //    }
    
    
    @IBAction func btnNextClick(sender: AnyObject) {
        
    }
    
}

class ThreadCell: UITableViewCell {
    
    @IBOutlet weak var lblUserName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
