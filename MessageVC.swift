//
//  MessageVC.swift
//  MySampleApp
//
//  Created by Jay Lad on 02/03/17.
//
//

import UIKit
import AWSMobileHubHelper
import AWSAPIGateway
import TwilioChatClient
import TwilioAccessManager
import IQKeyboardManagerSwift

class MessageVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblMessagereceived: UILabel!

    var twlclient: TwilioChatClient? = nil
    var generalChannel: TCHChannel? = nil
    var messages: [TCHMessage] = []
    var currentUser:String = ""
    var allMembers:[TCHMember] = []
    var messageSender:String = ""
    var currentchannelname:String = ""

    @IBOutlet weak var txtMessagetoSend: UITextView!
    @IBOutlet weak var tblMessages: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let username = NSUserDefaults.standardUserDefaults().valueForKey("Username") as? String ?? ""
        self.currentUser = username
        twlclient?.delegate = self
//        self.tblMessages.registerClass(SenderCell.self, forCellReuseIdentifier: "SenderCell")
//        self.tblMessages.registerClass(receiverCell.self, forCellReuseIdentifier: "receiverCell")
       // self.getToken()
        // Do any additional setup after loading the view.
        tblMessages.estimatedRowHeight = 68
        tblMessages.rowHeight = UITableViewAutomaticDimension
        tblMessages.layoutIfNeeded()
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        txtMessagetoSend.text = "Write message"
        txtMessagetoSend.textColor = UIColor.lightGrayColor()
        
        self.title = currentchannelname

        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.joinChannelWith()
    }

    func joinChannelWith() {
        
        self.generalChannel?.joinWithCompletion({ (result) in
            if result.isSuccessful() {
                print("Channel joined.")
                let lastmessageid = NSUserDefaults.standardUserDefaults().valueForKey("LastmessageIndex") as? Int ?? 0
                self.generalChannel?.messages.getMessagesBefore(UInt(lastmessageid), withCount: 50, completion: { (result, messages) in
                    if result.isSuccessful(){
                        self.messages = messages
                        self.tblMessages.reloadData()
                        if self.messages.count > 2 {
                            let oldLastCellIndexPath = NSIndexPath(forRow: self.messages.count-2, inSection: 0)
                            self.tblMessages.scrollToRowAtIndexPath(oldLastCellIndexPath, atScrollPosition: .Bottom, animated: false)
                            
                            // Animate on the next pass through the runloop.
                            dispatch_async(dispatch_get_main_queue(), {
                                self.scrollToBottom(true)
                            })
                        }
                    }
                })
                self.generalChannel?.members.membersWithCompletion({ (result, page) in
                    print(result)
                    for member in page.items(){
                        self.allMembers.append(member)
                    }
                })
            } else {
                print("Channel NOT joined.")
            }
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnSendMessage(sender: AnyObject) {
        if txtMessagetoSend.text == "" {
            return
        }
        if let messages = generalChannel?.messages {
            let message = messages.createMessageWithBody(self.txtMessagetoSend.text!)
            messages.sendMessage(message, completion: { (result) in
                if result.isSuccessful() {
                    print("Message sent.")
                    print(result)
                    self.txtMessagetoSend.text = ""
                } else {
                    print("Message NOT sent.")
                }
            })
            
        }

    }
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, heightForRowAt indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAt indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dict = messages[indexPath.row]
        print(dict)
        let timestamp = DateTodayFormatter().stringFromDate(NSDate.dateWithISO8601String(dict.timestamp))

        //identityId
        if dict.author != NSUserDefaults.standardUserDefaults().valueForKey("identityId") as? String
        {
            
            let cellReceiver = tableView.dequeueReusableCellWithIdentifier("receiverCell", forIndexPath: indexPath) as! receiverCell
        
            for memberData in self.allMembers {
                if memberData.userInfo.identity == dict.author {
                    cellReceiver.lblReceiverName.text = "\(memberData.userInfo.friendlyName), \(timestamp!)"
                }
            }
            
            
            //  cellReceiver.lblReceiverName.text = dict.attributes().first?.0
            
            cellReceiver.lblMessage.text = dict.body
            return cellReceiver
        }
        else {
            let cellSender = tableView.dequeueReusableCellWithIdentifier("SenderCell", forIndexPath: indexPath) as! SenderCell
            cellSender.lblName.text = "\(timestamp!), \(currentUser)"
            
            cellSender.lblMessage.text = "\(dict.body)"
            return cellSender
        }
        
        
//        if dict.sid == self.generalChannel?.createdBy{
//            
//            
//        }
//        else{
//            
//        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if txtMessagetoSend.textColor == UIColor.lightGrayColor() {
            txtMessagetoSend.text = ""
            txtMessagetoSend.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if txtMessagetoSend.text.isEmpty {
            txtMessagetoSend.text = "Write message"
            txtMessagetoSend.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        
        
        return true
    }
    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let dict = messages[indexPath.row]
//        
//        if dict.author == self.generalChannel?.createdBy{
//            let cell = tblMessages.dequeueReusableCellWithIdentifier("SenderCell", forIndexPath: indexPath) as! SenderCell
//            print(dict.body)
//            cell.lblName?.text = "\(dict.author)"
//            cell.lblMessage?.text = "\(dict.body)"
//            return cell
//        }
//        else{
//            let cell = tblMessages.dequeueReusableCellWithIdentifier("receiverCell", forIndexPath: indexPath) as! receiverCell
//            cell.lblReceiverName.text = dict.author
//            cell.lblMessage.text = dict.body
//            return cell
//        }
//        
//        
//    }
//    func getToken() -> String? {
//        
//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSCognitoUserPoolRegion, identityPoolId: "us-east-1:7d68636d-14e4-4f46-92ea-31b5d1cd7946")
//        
//        let configuration = AWSServiceConfiguration(region: AWSCloudLogicDefaultRegion, credentialsProvider: credentialsProvider)
//        
//        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
//        
//        let body = ACSTokenRequest()
//        body.userid = AWSIdentityManager.defaultIdentityManager().identityId
//        
//        let client = ACSACSApisClient.defaultClient()
//        
//        client.getTokenPost(body).continueWithBlock {(task: AWSTask) -> AnyObject? in
//            if let error = task.error {
//                print("Error occurred: \(error)")
//                return nil
//            }
//            
//            if let result = task.result {
//                // Do something with result
//                print(result)
//                _ = result.token()
//                
//                
//                let property = TwilioChatClientProperties()
//                property.initialMessageCount = 10
//                self.twlclient = TwilioChatClient(token: "\(result.token())", properties: property, delegate: self)
//                // self.getChannel(String(token))
//                
//                
//                let defaults = NSUserDefaults.standardUserDefaults()
//                print("\(result.valueForKey("username"))")
//                defaults.setObject(result.valueForKey("identity"), forKey: "identity")
//                print(defaults.valueForKey("identity") as? String ??  "")
//                return result.token()
//                
//            }
//            return nil
//        }
//        return nil
//    }

    
//    func loadMessages() {
//        self.messages.removeAll()
//        let message = self.generalChannel?.messages
//        self.messages.append([message])
//    }
    
//    func addMessages(messages: [TWMMessage]) {
//          self.messages.appendContentsOf(messages)
//          self.messages.sortInPlace { $1.timestamp > $0.timestamp }
//          
//          dispatch_async(dispatch_get_main_queue()) {
//                  () -> Void in
//                  self.tableView.reloadData()
//                  if self.messages.count > 0 {
//                          self.scrollToBottomMessage()
//                      }
//              }
//    }
    
    func addMessages(messages: [TCHMessage]) {
        self.messages += messages
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
}

extension MessageVC : TwilioChatClientDelegate {
    
//    func chatClient(client: TwilioChatClient!, synchronizationStatusChanged status: TCHClientSynchronizationStatus) {
//        
//        if status == .Completed {
//            // Join (or create) the general channel
//            let defaultChannel = "general"
//            twlclient!.channelsList().channelWithSidOrUniqueName(defaultChannel, completion: { (result, channel) in
//                if let channel = channel {
//                    self.generalChannel = channel
//                    channel.joinWithCompletion({ result in
//                        print(result)
////                        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String ?? "Unknown"
////                        self.twlclient!.userInfo.setFriendlyName(username, completion: { (result) in
////                            if result.isSuccessful(){
////                                print("success")
////                            }
////                        })
////                        self.twlclient?.channelsList().publicChannelsWithCompletion({ (result, page) in
////                            print(page.items())
////                        })
////                        let lastmessageid = NSUserDefaults.standardUserDefaults().valueForKey("LastmessageIndex") as? Int ?? 0
////                        self.generalChannel?.messages.getMessagesBefore(UInt(lastmessageid), withCount: 50, completion: { (result, messages) in
////                            if result.isSuccessful(){
////                                self.messages = messages
////                                self.tblMessages.reloadData()
////                                if self.messages.count > 2 {
////                                    let oldLastCellIndexPath = NSIndexPath(forRow: self.messages.count-2, inSection: 0)
////                                    self.tblMessages.scrollToRowAtIndexPath(oldLastCellIndexPath, atScrollPosition: .Bottom, animated: false)
////                                    
////                                    // Animate on the next pass through the runloop.
////                                    dispatch_async(dispatch_get_main_queue(), {
////                                        self.scrollToBottom(true)
////                                    })
////                                }
////                            }
////                        })
////                        self.generalChannel?.members.membersWithCompletion({ (result, page) in
////                            print(result)
////                            for member in page.items(){
////                             self.allMembers.append(member)
////                            }
////                        })
//                    })
//                    
//                } else {
//                    // Create the general channel (for public use) if it hasn't been created yet
//                    self.twlclient!.channelsList().createChannelWithOptions([TCHChannelOptionFriendlyName: self.currentchannelname, TCHChannelOptionType: TCHChannelType.Public.rawValue], completion: { (result, channel) -> Void in
//                        if result.isSuccessful() {
//                            self.generalChannel = channel
//                            self.generalChannel?.joinWithCompletion({ result in
//                                self.generalChannel?.setUniqueName(defaultChannel, completion: { result in
//                                    print("channel unique name set")
//                                })
//                            })
//                        }
//                    })
//                }
//            })
//        }
//    }
    
    func scrollToBottom(animated:Bool) {
        let indexPath = NSIndexPath(forRow: self.messages.count-1, inSection: 0)
        self.tblMessages.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
    }
    
    func chatClient(client: TwilioChatClient!, channelAdded channel: TCHChannel!) {
        print(channel)
    }
    
    func chatClient(client: TwilioChatClient!, errorReceived error: TCHError!) {
        print(error.description)
    }
    
    func chatClient(client: TwilioChatClient!, userInfo: TCHUserInfo!, updated: TCHUserInfoUpdate) {
        print(userInfo)
        print(updated)
    }
    
    func chatClient(client: TwilioChatClient!, channel: TCHChannel!, messageChanged message: TCHMessage!) {
        print(message)
    }
    
    func chatClient(client: TwilioChatClient!, channel: TCHChannel!, memberJoined member: TCHMember!) {
        print(member)
    }
    
    func chatClient(client: TwilioChatClient!, typingStartedOnChannel channel: TCHChannel!, member: TCHMember!) {
        
    }
    
    
    // Called whenever a channel we've joined receives a new message
    func chatClient(client: TwilioChatClient!, channel: TCHChannel!, messageAdded message: TCHMessage!) {
        self.messages.append(message)
        self.tblMessages.reloadData()
        if self.messages.count > 2 {
            let oldLastCellIndexPath = NSIndexPath(forRow: self.messages.count-2, inSection: 0)
            self.tblMessages.scrollToRowAtIndexPath(oldLastCellIndexPath, atScrollPosition: .Bottom, animated: false)
            
            // Animate on the next pass through the runloop.
            dispatch_async(dispatch_get_main_queue(), {
                self.scrollToBottom(true)
            })
        }
        print(message.index)
        channel.getMembersCountWithCompletion { (result, count) in
            print(count)
            print(result)
        }
        
       // let id = message.sid
        NSUserDefaults.standardUserDefaults().setInteger(Int(message.index), forKey: "LastmessageIndex")
        
        //self.txtMessagerec.text.appendContentsOf("\(self.messages[0].body)")
        dispatch_async(dispatch_get_main_queue()) {
            if self.messages.count > 0 {
                //self.sc6rollToBottomMessage()
            }
        }
    }
    
    
}

class DateTodayFormatter {
    func stringFromDate(date: NSDate?) -> String? {
        guard let date = date else {
            return nil
        }
        
        let messageDate = roundDateToDay(date)
        let todayDate = roundDateToDay(NSDate())
        
        let formatter = NSDateFormatter()
        
        if messageDate == todayDate {
            formatter.dateFormat = "'Today' - hh:mma"
        }
        else {
            formatter.dateFormat = "MMM. dd - hh:mma"
        }
    
        return formatter.stringFromDate(date)
    }
    
    func roundDateToDay(date: NSDate) -> NSDate {
        let calendar  = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
    
        return calendar.dateFromComponents(components)!
    }
}

extension NSDate {
    class func dateWithISO8601String(dateString: String) -> NSDate? {
        var formattedDateString = dateString
        
        if dateString.hasSuffix("Z") {
            let lastIndex = dateString.characters.indices.last!
            formattedDateString = dateString.substringToIndex(lastIndex) + "-000"
        }
        return dateFromString(formattedDateString, withFormat:"yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }
    
    class func dateFromString(str: String, withFormat dateFormat: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as NSLocale!
        return formatter.dateFromString(str) as NSDate?
    }
}


