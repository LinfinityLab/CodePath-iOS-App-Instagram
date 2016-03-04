//
//  ViewController.swift
//  Instagram
//
//  Created by Weifan Lin on 3/3/16.
//  Copyright © 2016 Weifan Lin. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var media: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 320
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadFromNetwork()
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
        let usernameLable = UILabel(frame: CGRect(x: 50, y: 10, width: 150, height: 30))
        
        profileView.setImageWithURL(NSURL(string: profilePhotoUrl)!)
        
        usernameLable.text = data["user"]!["username"] as? String
        
        headerView.addSubview(profileView)
        headerView.addSubview(usernameLable)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

