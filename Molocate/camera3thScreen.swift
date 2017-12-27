//
//  camera3thScreen.swift
//  Molocate
//
//  Created by Kagan Cenan on 3.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AWSS3
import Photos

//import QuadratTouch

//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l >= r
//  default:
//    return !(lhs < rhs)
//  }
//}



var selectedVenue = ""
var isCategorySelected = false
var isLocationSelected = false
var videoLocation:locationss!

class camera3thScreen: UIViewController,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var captionView: UITextView!
    
    @IBOutlet var mentionTable: UITableView!
    //Caption view a bottom constrain eklememiz gerekiyor
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var mentionAreas = [NSRange]()
    var mentionedUsers = [String]()
    var isInTheMentionMode = false
    var mentionModeIndex = 0
    var searchResults = [MoleUser]()
    
    
    let lineColor = UIColor(netHex: 0xCCCCCC)
    @IBOutlet var selectVenue: UIButton!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var venueName: UILabel!
    var searchDict:[[String:locationss]]!
    var searchArray:[String]!
    
    var autocompleteUrls = [String]()
    var videoURL: URL?
    var categ:String!
    var kbHeight: CGFloat!
    
    @IBAction func postVideo(_ sender: AnyObject) {
        if (!isLocationSelected){
            //self.postO.enabled = false
            displayAlert(title: "Dikkat", message: "Lütfen konum seçiniz.")
        }
        else {
            
            let random = randomStringWithLength(len: 64)
            let fileName = random //.stringByAppendingFormat(".mp4", random)
            let fileURL = URL(fileURLWithPath: videoPath!)
            UserDefaults.standard.set(videoPath, forKey: "videoPath")
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = fileURL
        
            uploadRequest?.key = "videos/" + (fileName.appendingPathExtension(".mp4")! as String)
            uploadRequest?.bucket = S3BucketName
            
            let json = [
                "video_id": fileName as String,
                "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName.appendingFormat(".mp4", fileName) as String),
                "caption": CaptionText,
                "category": "molocate",
                "tagged_users": self.mentionedUsers,
                "location": [
                    [
                        "id": videoLocation.id,
                        "latitude": videoLocation.lat,
                        "longitude": videoLocation.lon,
                        "name": videoLocation.name,
                        "address": videoLocation.adress
                    ]
                ]
            ] as [String : Any]
            
            CaptionText = ""
            
            let video_id = Int(arc4random_uniform(UInt32.max))
            
            let new_upload = S3Upload()
            
        
            var thumb:Data? = UIImageJPEGRepresentation(thumbnail, 0.5)
            if thumb == nil {
                thumb = UIImageJPEGRepresentation(UIImage(named: "Mole")!, 0.5)
            }
            
            new_upload.upload(false, id: video_id, uploadRequest:uploadRequest!,fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as [String : AnyObject], thumbnail_image: thumb!)
           
             MyS3Uploads.insert(new_upload, at: 0)
            

            self.performSegue(withIdentifier: "finishUpdate", sender: self)
        }
        
    }
    
    @IBAction func selectVenue(sender: AnyObject) {
        
        self.performSegue(withIdentifier: "goTo4th", sender: self)
        
        //
        //        let controller:cameraSearchVenue = self.storyboard!.instantiateViewControllerWithIdentifier("cameraSearchVenue") as! cameraSearchVenue
        //        controller.view.layer.zPosition = 1
        //
        //        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        //        controller.view.frame = self.view.bounds;
        //        //controller.numbers = numbers
        //        controller.willMoveToParentViewController(self)
        //        self.view.addSubview(controller.view)
        //        self.addChildViewController(controller)
        //        controller.didMoveToParentViewController(self)
        
    }
    @IBOutlet var bottomToolbar: UIToolbar!
    struct locationss{
        var id = ""
        var name = ""
        var lat:Float!
        var lon:Float!
        var adress = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        updateSearch(word: "")
        super.touchesBegan(touches, with: event)
    }
    @IBAction func backButton(_ sender: AnyObject) {
 
        //        let alertController = UIAlertController(title: "Emin misiniz?", message: "Geriye giderseniz videonuz silinecektir.", preferredStyle: .Alert)
        //
        //        let cancelAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { (action) in
        //            // ...
        //        }
        //        alertController.addAction(cancelAction)
        //
        //        let OKAction = UIAlertAction(title: "Evet", style: .Default) { (action) in
        //            dispatch_async(dispatch_get_main_queue()) {
        //                let cleanup: dispatch_block_t = {
        //                    do {
        //                        try NSFileManager.defaultManager().removeItemAtURL(self.videoURL!)
        //
        //                    } catch _ {}
        //
        //                }
        //                cleanup()
        //                placesArray.removeAll()
        //                placeOrder.removeAllObjects()
        self.performSegue(withIdentifier: "backFrom3th", sender: self)
        
        
        
        //            }
        //        }
        //        alertController.addAction(OKAction)
        //
        //        self.presentViewController(alertController, animated: true) {
        //            // ...
        //        }
        
        
    }
    @IBAction func buttonVenues(sender: AnyObject) {
        
    }
    
    
    
    
    
    var CaptionText = ""
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
    
        NotificationCenter.default.addObserver(self, selector: #selector(camera3thScreen.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(camera3thScreen.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectVenue.layer.borderColor = lineColor.cgColor
        selectVenue.layer.borderWidth = 0.5
        
        //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(camera3thScreen.dismissKeyboard))
        //        view.addGestureRecognizer(tap)
        
        //let index = NSIndexPath(forRow: 0, inSection: 0)
        //self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        
      
        captionView.delegate = self
        captionView.layer.borderColor = lineColor.cgColor
        captionView.layer.borderWidth = 0.5;
    
        
        mentionTable.isHidden = true
        mentionTable.tableFooterView = UIView()
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self,selector: #selector(camera3thScreen.keyboardNotification),name: NSNotification.Name.UIKeyboardWillChangeFrame,object: nil)
        
        
        

        
        self.categ = ""
        if isLocationSelected {
            venueName.text =  selectedVenue
        } else {
            if placesArray.count == 0 {
                venueName.text = "Konum ara"
            } else {
                selectedVenue = placesArray[0]
                venueName.text = selectedVenue
                let correctedRow = placeOrder.object(forKey: placesArray[0]) as! Int
                videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
                isLocationSelected = true
            }
            
        }
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func keyboardNotification(notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
                
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
                
                
            }
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let attributed = NSMutableAttributedString(string: textView.text)
        
        for mention in mentionAreas {
            attributed.addAttributes([NSForegroundColorAttributeName: swiftColor], range: mention)
        }
        textView.attributedText = attributed
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.backgroundColor = UIColor.white
        if textView.attributedText.string == "" {
            CaptionText = ""
            captionView.attributedText = NSAttributedString(string: "Yorumunuzu buraya yazabilirsiniz.", attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Regular", size:14)!, NSForegroundColorAttributeName: UIColor.lightGray])
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.attributedText.string == "Yorumunuzu buraya yazabilirsiniz." {
            textView.attributedText = NSAttributedString(string: "")
        }
        self.view.backgroundColor = UIColor.lightGray

    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        let new = (textView.attributedText.string as NSString).replacingCharacters(in: range, with: text)
        
        let textRange = NSRange(location: 0, length: new.characters.count )
        
        let mentions = RegexParser.getMentions(fromText: new, range: textRange)
        
        mentionAreas.removeAll()
        mentionedUsers.removeAll()
        
        for mention in mentions where mention.range.length > 1{
           // print(mention.range.location)
            if mention.range.length > 2 {
                
                var word = new.substring(with:mention.range.location+1..<mention.range.location + mention.range.length-1)
                
                if word.hasPrefix("@") {
                    word.remove(at: word.startIndex)
                }
                
                mentionedUsers.append(word)
                mentionAreas.append(mention.range)
            }else if mention.range.location == 0{
                
               // print("mentionn range location")
                var word = new.substring(with:mention.range.location..<mention.range.location + mention.range.length-1)
                
                if word.hasPrefix("@") {
                    word.remove(at: word.startIndex)
                }
                
                mentionedUsers.append(word)
                mentionAreas.append(mention.range)
            }
            
        }

        
        let info = isTheRangeInMentionZone(range: range, text: text)
        
        if info.0{
            isInTheMentionMode = true
            mentionModeIndex = info.1
            updateSearch(word: mentionedUsers[mentionModeIndex])
        }else{
            isInTheMentionMode = false
            mentionModeIndex = 0
            updateSearch(word: "")
        }
        
        //
        //
        //            //mention mode da iken silme islemi yaptigimizda @ isaretini sildik mi
        //        if isInTheMentionMode && text == "" && range.location<mentionAreas[mentionModeIndex].location{
        //            isInTheMentionMode=false
        //            mentionAreas.removeAtIndex(mentionModeIndex)
        //            mentionModeIndex = 0
        //            updateSearch("")
        //            //mentiondayken silme islemi yapip @ tayi gecmediyse
        //        }else if isInTheMentionMode && text == "" && range.location >= mentionAreas[mentionModeIndex].location{
        //            mentionAreas[mentionModeIndex].length =  range.location - mentionAreas[mentionModeIndex].location
        //            let current = textView.text as NSString
        //            let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //            updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //            //mention moddayken kelime girip bosluga bastiysa ya da table dan username sectiyse
        //        }else if isInTheMentionMode  && text.characters.count>0 && text[text.characters.count-1]==" " {
        //            isInTheMentionMode = false
        //            mentionModeIndex = 0
        //            updateSearch("")
        //            //Captionın başına @ ya da ortasinda _@ girildigi durumu tespit ediyoruz
        //        }else if isInTheMentionMode && text.characters.count>0{
        //            mentionAreas[mentionModeIndex].length = range.location - mentionAreas[mentionModeIndex].location+1
        //            let current = textView.text as NSString
        //            let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //            updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //        }else if !isInTheMentionMode && range.length==0 && text == "@" && (textView.text.characters.count == 0 || textView.text[textView.text.characters.count-1]==" "){
        //
        //            var newMention = NSRange()
        //            newMention.length = 0
        //            newMention.location = textView.text.characters.count+1
        //            mentionAreas.append(newMention)
        //
        //            isInTheMentionMode = true
        //            mentionModeIndex = mentionAreas.endIndex-1
        //
        //        }else if !isInTheMentionMode{
        //            let info = isTheRangeInMentionZone(range)
        //            if info.0{
        //                isInTheMentionMode = true
        //                mentionModeIndex = info.1
        //                mentionAreas[mentionModeIndex].length = range.location - mentionAreas[mentionModeIndex].location
        //
        //                let current = textView.text as NSString
        //                let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //                updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //            }
        //        }
        
        //character limit
        return textView.text.characters.count+(text.characters.count-range.length) <= 140
    }
    
    func isTheRangeInMentionZone(range: NSRange, text: String) -> (Bool, Int){
        for i in 0..<mentionAreas.count{
            let mention = mentionAreas[i]
            if text != "" {
                if mention.location <= range.location && mention.location+mention.length > range.location{
                    return (true, i)
                }
            }else{
                if mention.location <= range.location && mention.location+mention.length >= range.location{
                    return (true, i)
                }
            }
        }
        return (false,0)
    }
    
    func updateSearch(word: String){
        //print("word::",word)
        if word == ""{
            mentionTable.isHidden = true
            searchResults.removeAll()
        }else{
            
            
            MolocateAccount.searchUser(word, completionHandler: { (data, response, error) in
                DispatchQueue.main.async{
                    if data.count > 0 {
                        self.searchResults = data
                        self.mentionTable.reloadData()
                    }
                }
            })
            mentionTable.isHidden = false
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count+1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchUsername(style: .default, reuseIdentifier: "mention")
        
        if indexPath.row < searchResults.count {
            cell.followButton.isHidden = true
            cell.usernameLabel.text = "@\(searchResults[indexPath.row].username)"
            if searchResults[indexPath.row].first_name == "" {
                cell.nameLabel.text = "\(searchResults[indexPath.row].username)"
            }
            else{
                cell.nameLabel.text = "\(searchResults[indexPath.row].first_name) \(searchResults[indexPath.row].last_name)"
            }
            if(searchResults[indexPath.row].profilePic?.absoluteString != ""){
                cell.profilePhoto.sd_setImage(with: searchResults[indexPath.row].profilePic, for: UIControlState.normal)
            }else{
                cell.profilePhoto.setImage(UIImage(named: "profile"), for: UIControlState())
            }
            
//            cell.profilePhoto.addTarget(self, action: #selector(MainController.pressedProfileSearch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            //cell.followButton.addTarget(self, action: Selector("pressedFollowSearch"), forControlEvents: .TouchUpInside)
            cell.followButton.tag = indexPath.row
            cell.profilePhoto.tag = indexPath.row
            
            return cell
            
        }else{
            cell.usernameLabel.text = "Kullanicilar araniyor"
            cell.followButton.isHidden = true
            cell.profilePhoto.isHidden = true
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
              if indexPath.row<searchResults.count {
            
            let username = searchResults[indexPath.row].username
            var captiontext = captionView.attributedText.string
            if mentionAreas[mentionModeIndex].location == 0 {
                captiontext = captiontext.substring(to: captiontext.characters.index(captiontext.startIndex, offsetBy: mentionAreas[mentionModeIndex].location+1)) + username + " "
            }else{
                captiontext = captiontext.substring(to: captiontext.characters.index(captiontext.startIndex, offsetBy: mentionAreas[mentionModeIndex].location+2)) + username + " "
            }
            
            
            captionView.attributedText = NSAttributedString(string: captiontext, attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Regular", size:14)!])
            mentionAreas[mentionModeIndex].length = username.characters.count + 2
            mentionedUsers[mentionModeIndex] = username
            
            textViewDidChange(captionView)
            isInTheMentionMode = false
            mentionTable.isHidden = true
            searchResults.removeAll()
            
            
        }
        
    }
    
    
    
    //    func textViewShouldReturn(textField: UITextView!) -> Bool  {
    //        textView.resignFirstResponder()
    //        return true
    //    }
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0..<len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = 0 + (MolocateDevice.size.height - (MolocateDevice.size.height * 0.3 + 255 )) - keyboardSize.height
            self.toolBar.isHidden = true
        }
        
    }
    func keyboardWillHide(notification: Notification) {
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
            self.toolBar.isHidden = false
            self.CaptionText = captionView.text
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let a : CGSize = CGSize.init(width: MolocateDevice.size.width / 4, height: 45)
        
        
        return a
    }
    
    //    @IBAction func postVideo(sender: AnyObject) {
    //        if (!isLocationSelected || !isCategorySelected){
    //            //self.postO.enabled = false
    //            displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
    //        }
    //        else {
    //
    //            let random = randomStringWithLength(64)
    //            let fileName = random //.stringByAppendingFormat(".mp4", random)
    //            let fileURL = NSURL(fileURLWithPath: videoPath!)
    //            NSUserDefaults.standardUserDefaults().setObject(videoPath, forKey: "videoPath")
    //            let uploadRequest = AWSS3TransferManagerUploadRequest()
    //            uploadRequest.body = fileURL
    //            uploadRequest.key = "videos/" + (fileName.stringByAppendingFormat(".mp4", fileName) as String)
    //            uploadRequest.bucket = S3BucketName
    //
    //            let json = [
    //                "video_id": fileName as String,
    //                "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName.stringByAppendingFormat(".mp4", fileName) as String),
    //                "caption": CaptionText,
    //                "category": self.categ,
    //                "tagged_users": "",
    //                "location": [
    //                    [
    //                        "id": videoLocation.id,
    //                        "latitude": videoLocation.lat,
    //                        "longitude": videoLocation.lon,
    //                        "name": videoLocation.name,
    //                        "address": videoLocation.adress
    //                    ]
    //                ]
    //            ]
    //            S3Upload.upload(uploadRequest:uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])
    //
    //
    //            self.performSegueWithIdentifier("finishUpdate", sender: self)
    //
    //        }
    //
    //    }
    //
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //            if !self.postO.enabled {
            //                self.postO.enabled = true
            //            }
        })))
        self.present(alert, animated: true, completion: nil)
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
