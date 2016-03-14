//
//  ViewController.swift
//  Instagram
//
//  Created by Weifan Lin on 3/3/16.
//  Copyright © 2016 Weifan Lin. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errMsgButton: UIButton!
    
    var media : [NSDictionary]?
    var select = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.frame = CGRectMake(0, 60, 414, 716)
        tableView.rowHeight = 320
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //tableView.addSubview(errMsgButton)
        tableView.bringSubviewToFront(errMsgButton)
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        if Reachability.isConnectedToNetwork() {
            
            dismissNetworkErr()
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)// show loading state
            loadFromNetwork()
            MBProgressHUD.hideHUDForView(self.view, animated: true)// hide loading state
        } else {
            showNetworkErr()
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    


    func loadFromNetwork() {
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
//                            NSLog("response: \(responseDictionary)")
                            self.media = responseDictionary["data"] as? [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let media = media {
            return media.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InstagramCell", forIndexPath: indexPath) as! InstagramCell
        
        let data = media![indexPath.section]
        
        let imageUrl = data["images"]!["standard_resolution"]!!["url"] as! String
        cell.photoView.setImageWithURL(NSURL(string: imageUrl)!)
    
        return cell
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).CGColor
        profileView.layer.borderWidth = 1;
        
        // Use the section number to get the right URL
        let data = media![section]
        let profilePhotoUrl = data["user"]!["profile_picture"] as! String
        let usernameLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 150, height: 30))
        
        profileView.setImageWithURL(NSURL(string: profilePhotoUrl)!)
        
        usernameLabel.text = data["user"]!["username"] as? String
        
        headerView.addSubview(profileView)
        headerView.addSubview(usernameLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @IBAction func errMsgTap(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            dismissNetworkErr()
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadFromNetwork()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        } else {
            showNetworkErr()
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        if Reachability.isConnectedToNetwork() {
            dismissNetworkErr()
        } else {
            showNetworkErr()
            refreshControl.endRefreshing()
        }
        
        loadFromNetwork()
        refreshControl.endRefreshing()
        
    }
    
    func showNetworkErr(){
        self.tableView.frame = CGRectMake(0, 82, 414, 716)
        self.errMsgButton.hidden = false
    }
    
    func dismissNetworkErr(){
        self.tableView.frame = CGRectMake(0, 60, 414, 716)
        self.errMsgButton.hidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    internal class Reachability {
        class func isConnectedToNetwork() -> Bool {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
                SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
            }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                return false
            }
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            return (isReachable && !needsConnection)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        select = media![indexPath.row]["images"]!["standard_resolution"]!!["url"] as! String
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PhotoDetailsViewController
        
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        
        let selected = media![indexPath!.row]["images"]!["standard_resolution"]!!["url"] as! String
        
        vc.photoUrl = selected
        
        
    }

}

