//
//  profileLocation.swift
//  Molocate
//
//  Created by Kagan Cenan on 23.02.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import SDWebImage
import Haneke


class profileLocation: UIViewController,UITableViewDelegate , UITableViewDataSource , UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate {
    @IBOutlet var LocationTitle: UILabel!

    @IBOutlet var videosTitle: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var locationName: UILabel!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var videoCount: UILabel!
    var videoArray = [videoInf]()
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    @IBOutlet var followButton: UIBarButtonItem!
   
    @IBOutlet var toolBar: UIToolbar!
    @IBAction func followButton(sender: AnyObject) {
        
        
    }
    @IBOutlet var followerCount: UIButton!
    
    @IBAction func followersButton(sender: AnyObject) {
    }
    
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var refreshing: Bool = false
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var myCache = Shared.dataCache
    var refreshControl:UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = swiftColor3
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        self.followerCount.setTitle("\(thePlace.following_count)", forState: UIControlState.Normal)
        self.locationName.text = thePlace.name
        self.LocationTitle.text = thePlace.name
        self.address.text = thePlace.address
        self.videoCount.text = "Videos(\(thePlace.video_count))"
        self.videoArray = thePlace.videoArray
        //videocounta mekanda çekilen video toplamı yazacak
        
        self.player1 = Player()
        self.player1.delegate = self
        self.player1.playbackLoops = true
        
        self.player2 = Player()
        self.player2.delegate = self
        self.player2.playbackLoops = true

        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return screenSize.width + 150
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow {
            let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
            
            cell.initialize(indexPath.row, videoInfo:  videoArray[indexPath.row])
            
            cell.Username.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.placeName.addTarget(self, action: "pressedPlace:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
            
            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != currentUser.username){
                cell.followButton.addTarget(self, action: "pressedFollow:", forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.followButton.hidden = true
            }
            
            cell.likeButton.addTarget(self, action: "pressedLike:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            cell.commentCount.text = "\(videoArray[indexPath.row].commentCount)"
            cell.commentButton.addTarget(self, action: "pressedComment:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: "pressedReport:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: "pressedLikeCount:", forControlEvents: UIControlEvents.TouchUpInside)
            
            
            myCache.fetch(URL:self.videoArray[indexPath.row].urlSta ).onSuccess{ NSData in
                dispatch_async(dispatch_get_main_queue()){
                    
                    
                    let url = self.videoArray[indexPath.row].urlSta.absoluteString
                    
                    let path = NSURL(string: DiskCache.basePath())!.URLByAppendingPathComponent("shared-data/original")
                    let cached = DiskCache(path: path.absoluteString).pathForKey(url)
                    let file = NSURL(fileURLWithPath: cached)
                    if indexPath.row % 2 == 1 {
                        
                        self.player1.setUrl(file)
                        self.player1.view.frame = cell.newRect
                        cell.contentView.addSubview(self.player1.view)
                        
                    }else{
                        
                        self.player2.setUrl(file)
                        self.player2.view.frame = cell.newRect
                        cell.contentView.addSubview(self.player2.view)
                    }
                }
                
            }
            return cell
        }else{
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! videoCell
            if pressedLike {
                pressedLike = false
                cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
                
                if(videoArray[indexPath.row].isLiked == 0) {
                    cell.likeButton.setBackgroundImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
                }else{
                    cell.likeButton.setBackgroundImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
                    cell.likeButton.tintColor = UIColor.whiteColor()
                }
            }else if pressedFollow{
                pressedFollow = true
                
                cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
                
            }
            return cell
        }

    }
    
    
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        
        Molocate.getUser(videoArray[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                controller.username.text = user.username
                controller.followingsCount.setTitle("\(data.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(data.follower_count)", forState: .Normal)
            }
        }
        
    }
    
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        print("place e basıldı at index path: \(buttonRow) ")
        print("================================" )
        Molocate.getPlace(videoArray[buttonRow].locationID) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
            }
        }
        
    }
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        print("followa basıldı at index path: \(buttonRow) ")
        
        Molocate.follow (videoArray[buttonRow].username){ (data, response, error) -> () in
            //print(data)
        }
    }
    
    func pressedLikeCount(sender: UIButton) {
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
        if(videoArray[buttonRow].isLiked == 0){
            sender.highlighted = true
            
            self.videoArray[buttonRow].isLiked=1
            self.videoArray[buttonRow].likeCount+=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            Molocate.likeAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }else{
            sender.highlighted = false
            
            self.videoArray[buttonRow].isLiked=0
            self.videoArray[buttonRow].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            Molocate.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }
    }
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        videoIndex = buttonRow
        video_id = videoArray[videoIndex].id
        myViewController = "HomeController"
        Molocate.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                print("comment e basıldı at index path: \(buttonRow)")
            }
        }
        
        
        
    }
    
    
    func pressedReport(sender: UIButton) {
        let buttonRow = sender.tag
        Molocate.reportAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
            print(data)
        }
        print("pressedReport at index path: \(buttonRow)")
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Report the Video", style: .Default) { action -> Void in
            
            print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }

    override func viewDidDisappear(animated: Bool) {
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
        
    }
    
    func playerReady(player: Player) {
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(!refreshing) {
            let rowHeight = screenSize.width + 138
            let y = scrollView.contentOffset.y
            
            let front = ceil(y/rowHeight)
            //print(front * rowHeight/2 - y)
            dispatch_async(dispatch_get_main_queue()){
                if front * rowHeight-rowHeight/2 - y < 0 {
                    if (front) % 2 == 1{
                        
                        if self.player1.playbackState.description != "Playing" {
                            self.player2.stop()
                            self.player1.playFromBeginning()
                            //print("player1")
                        }
                    }else{
                        if self.player2.playbackState.description != "Playing"{
                            self.player1.stop()
                            self.player2.playFromBeginning()
                            //print("player2")
                        }
                    }
                }
            }
            
            
        }
    }

    
    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
            
            if((!refreshing)&&(indexPath.row%8 == 0)&&(nextU != nil)){
                
                Molocate.getExploreVideos(nextU, completionHandler: { (data, response, error) -> () in
                    dispatch_async(dispatch_get_main_queue()){
                        
                        for item in data!{
                            self.videoArray.append(item)
                            let newIndexPath = NSIndexPath(forRow: self.videoArray.count-1, inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                        }
                        
                        
                        
                    }
                    
                })
                
            }
        }
        else {
            
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
