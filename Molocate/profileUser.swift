
import UIKit

class profileUser: UIViewController,UITableViewDelegate , UITableViewDataSource,UIScrollViewDelegate,  UIGestureRecognizerDelegate{
    
    @IBOutlet var optionsTable: UITableView!
    let AVc :Added =  Added(nibName: "Added", bundle: nil);
    @IBOutlet var followButton: UIBarButtonItem!
    let BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
     var isItMyProfile = true
    var classUser = MoleUser()
    var username2 = ""
    var owntagged = true
    var page = 1
    var redLabelOrigin = 0.0 
    var estRowH = 150.0 
    var vidortag = false // videoysa false
    let names = ["AYARLAR","PROFİLİ DÜZENLE", "ÇIKIŞ YAP"]
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var myRefreshControl = UIRefreshControl()
    @IBOutlet var tableView: UITableView!
  
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.separatorColor = UIColor.clear
        //tableView.scrollEnabled = false
        tableView.isPagingEnabled = true
        
        optionsTable.layer.zPosition = 1
        optionsTable.isHidden = true
        optionsTable.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.width)
        optionsTable.layer.cornerRadius = 0
        optionsTable.tintColor = UIColor.clear
       
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(profileUser.adjustTable))
        gesture.delegate = self
        gesture.direction = .down
        self.view.addGestureRecognizer(gesture)
        
        initGui()
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }

        
    }
    func initGui(){
        
        
        
        if(classUser.isFollowing){
            followButton.image = UIImage(named: "unfollow")
        }else if classUser.username == MoleCurrentUser.username{
            followButton.image = UIImage(named: "settings")
        }else{
            followButton.image = UIImage(named: "follow")
        }
        
        self.navigationItem.title = classUser.username
        
        
        self.myRefreshControl = UIRefreshControl()
        self.myRefreshControl.addTarget(self, action: #selector(profileUser.refreshVideos), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(myRefreshControl)
//
//        settings.layer.zPosition = 1
//        settings.hidden = true
//        settings.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.width, self.view.frame.width)
//        settings.layer.cornerRadius = 0
//        settings.tintColor = UIColor.clearColor()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.hidesBarsOnSwipe = true

  

     
    }
    
    func refreshVideos(){
        if !vidortag{
            MolocateVideo.getUserVideos(classUser.username, type: "user", completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    self.AVc.videoArray = data!
                    self.AVc.tableView?.reloadData()
                    self.myRefreshControl.endRefreshing()
                }
            })

        }else{
            MolocateVideo.getUserVideos(classUser.username, type: "tagged", completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    self.BVc.videoArray = data!
                    self.BVc.tableView?.reloadData()
                    self.myRefreshControl.endRefreshing()
                }
            })
        }
    }
    
    

    func adjustTable() {
        if page == 2 {
            if vidortag {
                if BVc.tableView?.contentOffset.y == 0 {
                    estRowH = Double(tableView.contentSize.height)-Double(MolocateDevice.size.height)-50
                    BVc.tableView?.isScrollEnabled = false
                    self.tableView.isPagingEnabled = true
                    //self.navigationController?.setNavigationBarHidden(false, animated: true)
                   // self.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: true)
                }
            } else {
                if AVc.tableView?.contentOffset.y == 0 {
                    estRowH = Double(tableView.contentSize.height)-Double(MolocateDevice.size.height)-50
                    AVc.tableView?.isScrollEnabled = false
                    self.tableView.isPagingEnabled = true
                    //self.navigationController?.setNavigationBarHidden(false, animated: true)
                   // self.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: true)
                }
            }

        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    func RefreshGuiWithData(){
       
        if(classUser.isFollowing){
            followButton.image = UIImage(named: "unfollow")
        }else if classUser.username == MoleCurrentUser.username{
            self.isItMyProfile = true
            followButton.image = UIImage(named: "settings")
        }else{
            followButton.image = UIImage(named: "follow")
        }
        
        username2 = classUser.first_name
        AVc.classUser = classUser
        AVc.isItMyProfile = self.isItMyProfile
        BVc.isItMyProfile = self.isItMyProfile
        BVc.classUser = classUser
        AVc.getData()
        BVc.getData()
        tableView.reloadData()
       
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 1{
            return 80
        }
        else if (indexPath as NSIndexPath).row == 2{
            return 45
        }
        else if (indexPath as NSIndexPath).row == 0 {
            return CGFloat(estRowH)}
        else{
            return MolocateDevice.size.height - 25
        }
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == optionsTable {
            if (indexPath as NSIndexPath).row == 0{
                return 90
            }
            else{
                return 60
            }
        }
        
        else {
        if (indexPath as NSIndexPath).row == 1{
            return 80
        }
        else if (indexPath as NSIndexPath).row == 2{
            return 45
        }
        else if (indexPath as NSIndexPath).row == 0 {
            return UITableViewAutomaticDimension}
        else{
        return MolocateDevice.size.height-25
        }
    }
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if tableView == optionsTable {
            
            
            self.tableView.isScrollEnabled = true
            //???What is doing that animation
            if((indexPath as NSIndexPath).row == 0){
                UIView.animate(withDuration: 0.75, animations: { () -> Void in
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.alpha = 1
                    self.optionsTable.isHidden = true
                    
                    self.navigationController?.isNavigationBarHidden = false
                    
                    
                }) 
            }
            if (indexPath as NSIndexPath).row == 1 {
                self.tableView.isUserInteractionEnabled = true
                self.tableView.alpha = 1
                self.performSegue(withIdentifier: "goEditProfile", sender: self)
                self.optionsTable.isHidden = true
            }
            if (indexPath as NSIndexPath).row == 2 {
                MolocateAccount.unregisterDevice({ (data, response, error) in
                })
                UserDefaults.standard.set(nil, forKey: "userToken")
                sideClicked = false
                profileOn = 0
                category = "All"
                comments = [MoleVideoComment]()
                video_id = ""
                user = MoleUser()
                videoIndex = 0
                isUploaded = true
                choosedIndex = 2
                frame = CGRect()
                MoleCurrentUser = MoleUser()
                MoleUserToken = nil
                isRegistered = false
                MoleGlobalVideo = nil
                //GlobalVideoUploadRequest = nil
                
                //navigationın düzelmesi sonrası bu böyle olucak
                //self.parentViewController!.parentViewController!.performSegueWithIdentifier("logOut", sender: self)
                self.parent!.parent!.performSegue(withIdentifier: "logout", sender: self)
            }
        
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
    if tableView == optionsTable{
        
        let cell = optionCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        
        if (indexPath as NSIndexPath).row == 0 {
            cell.nameOption.frame = CGRect(x: MolocateDevice.size.width / 2 - 50, y: 40 , width: 100, height: 30)
            cell.nameOption.textAlignment = .center
            cell.nameOption.textColor = UIColor.black
            cell.arrow.isHidden = true
            cell.cancelLabel.isHidden = false
        }else {
            cell.cancelLabel.isHidden = true
        }
        cell.nameOption.text = names[(indexPath as NSIndexPath).row]
        cell.backgroundColor = UIColor.white
        
        return cell


        }
            
            
            
            
            
    else {
        if (indexPath as NSIndexPath).row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! profile1stCell
            
            cell.userCaption.numberOfLines = 0
            cell.userCaption.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.userCaption.text = classUser.bio
            cell.profilePhoto.layer.borderWidth = 0.1
            cell.profilePhoto.layer.masksToBounds = false
            cell.profilePhoto.layer.borderColor = UIColor.white.cgColor
            cell.profilePhoto.backgroundColor = profileBackgroundColor
            cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height/2
            cell.profilePhotoPressed.addTarget(self, action: #selector(profileUser.photoPressed), for: UIControlEvents.touchUpInside)
            cell.profilePhoto.clipsToBounds = true
            cell.profilePhoto.tag = (indexPath as NSIndexPath).row
            if(classUser.profilePic?.absoluteString != ""){
                cell.profilePhoto.sd_setImage(with: classUser.profilePic)
                
            }else{
                cell.profilePhoto.image = UIImage(named: "profile")!
               
            }
            
            if(classUser.first_name == ""){
                cell.name.text = classUser.username
            }else{
                cell.name.text = classUser.first_name
            }
            
          
            return cell
            
        }
        
        else if (indexPath as NSIndexPath).row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! profile2ndCell
            cell.numberFollower.text = "\(classUser.follower_count)"
            cell.numberFollowUser.text = "\(classUser.following_count)"
            cell.numberFollowVenue.text = "\(classUser.place_following_count)"
            cell.numberPostedVenue.text = "\(classUser.different_checkins)"
            cell.followers.addTarget(self, action: #selector(profileUser.followersPressed), for: UIControlEvents.touchUpInside)
            cell.followUser.addTarget(self, action: #selector(profileUser.followUserPressed), for: UIControlEvents.touchUpInside)
            cell.followVenue.addTarget(self, action: #selector(profileUser.followVenuePressed), for: UIControlEvents.touchUpInside)
            cell.postedVenue.addTarget(self, action: #selector(profileUser.postedVenuePressed), for: UIControlEvents.touchUpInside)
            return cell
            
        }
        
        else if (indexPath as NSIndexPath).row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! profile3thCell
            cell.videosButton.setTitle("VİDEOLAR(\(classUser.post_count))", for: UIControlState())
            cell.taggedButton.setTitle("ETİKET(\(classUser.tag_count))", for: UIControlState())
            cell.videosButton.addTarget(self, action: #selector(profileUser.videosButtonTapped(_:)), for: .touchUpInside)
            cell.taggedButton.addTarget(self, action: #selector(profileUser.taggedButtonTapped(_:)), for: .touchUpInside)
            
            if !vidortag {
                cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
                cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
                cell.videosButton.setTitleColor(swiftColor, for: UIControlState())
                cell.taggedButton.setTitleColor(greyColor1, for: UIControlState())
               
                
            } else {
                
                
                cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
                cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
                cell.videosButton.setTitleColor(greyColor1, for: UIControlState())
                cell.taggedButton.setTitleColor(swiftColor, for: UIControlState())
            }
            cell.redLabel.frame.origin.x = CGFloat(redLabelOrigin)
            
            return cell
           
        }
        
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! profile4thCell
            AVc.view.frame.origin.x = 0
            AVc.view.frame.origin.y = 0
            AVc.view.frame.size.width = MolocateDevice.size.width
            AVc.view.frame.size.height = cell.scrollView.frame.height
            self.addChildViewController(AVc);
            AVc.didMove(toParentViewController: self)
            
            var adminFrame :CGRect = AVc.view.frame;
            adminFrame.origin.x = MolocateDevice.size.width
            var deneme :CGRect = AVc.view.frame;
            deneme.origin.x = 0
            
            BVc.classUser = classUser
            BVc.isItMyProfile = isItMyProfile
            BVc.view.frame = adminFrame;
            self.addChildViewController(BVc);
            BVc.didMove(toParentViewController: self)
            
            cell.scrollView.setContentOffset(deneme.origin, animated: true)
            
            scrollWidth = MolocateDevice.size.width*2
            cell.scrollView.contentSize.width = scrollWidth
            cell.scrollView.delegate = self
            cell.scrollView.isScrollEnabled = true
            if owntagged == true {
                cell.scrollView.setContentOffset(deneme.origin, animated: true)
            }
            else {
                cell.scrollView.setContentOffset(adminFrame.origin, animated: true)
            }
            cell.scrollView.addSubview(AVc.view);
            cell.scrollView.addSubview(BVc.view);
            AVc.tableView?.isScrollEnabled = false
            AVc.tableView?.bounces = false
            BVc.tableView?.isScrollEnabled = false
            BVc.tableView?.bounces = false
            return cell
            
        }
        
       
        
        
        }
    }
    
    func photoPressed(_ sender: UIButton){
     //print ("x<<")
        let controller:onePhoto = self.storyboard!.instantiateViewController(withIdentifier: "onePhoto") as! onePhoto
        controller.classUser = classUser
        navigationController?.pushViewController(controller, animated: true)
    }
    func followUserPressed(_ sender: UIButton){
        AVc.player2?.stop()
        AVc.player1?.stop()
        BVc.player2?.stop()
        BVc.player1?.stop()
        
        let controller:Followers = self.storyboard!.instantiateViewController(withIdentifier: "Followers") as! Followers
        controller.classUser = classUser
        controller.followersclicked = false
        navigationController?.pushViewController(controller, animated: true)
    }
    func followVenuePressed(_ sender: UIButton){
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            let controller:findVenueController = self.storyboard!.instantiateViewController(withIdentifier: "findVenueController") as! findVenueController
            self.navigationController?.pushViewController(controller, animated: true)
            MolocateAccount.getFollowingPlaces(classUser.username) { (data, response, error) in
                DispatchQueue.main.async{
                    controller.venues = data
                    controller.tableView.reloadData()
                }
            }
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()

    
    }
    func followersPressed(_ sender: UIButton){
        AVc.player2?.stop()
        AVc.player1?.stop()
        BVc.player2?.stop()
        BVc.player1?.stop()
        let controller:Followers = self.storyboard!.instantiateViewController(withIdentifier: "Followers") as! Followers
        controller.classUser = classUser
        controller.followersclicked = true
        navigationController?.pushViewController(controller, animated: true)
    }
    func postedVenuePressed(_ sender: UIButton){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let controller:findVenueController = self.storyboard!.instantiateViewController(withIdentifier: "findVenueController") as! findVenueController
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getCheckedInPlaces(username: classUser.username) { (data, response, error) in
            DispatchQueue.main.async{
            controller.venues = data
            controller.tableView.reloadData()
            }
        }
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func showTable(){
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.navigationController?.isNavigationBarHidden = true
            self.tableView.isUserInteractionEnabled = false
            
            self.tableView.isScrollEnabled = false
            self.optionsTable.isHidden = false
            self.optionsTable.frame = CGRect(x: self.view.frame.origin.x,y: self.view.frame.origin.y,width: self.view.frame.width,height: self.view.frame.size.width)
            self.tableView.alpha = 0.4
        }) 
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if tableView.cellForRow(at: IndexPath(row: 2, section: 0)) != nil {
        let sv = (tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! profile4thCell).scrollView
        if scrollView == sv {
                    let indexPath = IndexPath(row: 2, section: 0)
                   // let cell = tableView.cellForRowAtIndexPath(indexPath) as! profile3thCell
            
                    redLabelOrigin  = Double(scrollView.contentOffset.x ) / 2
                    if scrollView.contentOffset.x < MolocateDevice.size.width / 2{
                        vidortag = false
                      
                        BVc.player2?.stop()
                        BVc.player1?.stop()
                    }
                    else{
                        vidortag = true
                        AVc.player2?.stop()
                        AVc.player1?.stop()
                    }

                    tableView.reloadRows(at: [indexPath], with: .none)
            
        }
        
        }
        if scrollView == self.tableView {
            
            if (scrollView.contentSize.height-scrollView.contentOffset.y < MolocateDevice.size.height+70) {
                
                BVc.tableView?.isScrollEnabled = true
                AVc.tableView?.isScrollEnabled = true
                tableView.isPagingEnabled = false
                page = 2
                
            } else {
                BVc.tableView?.isScrollEnabled = false
                AVc.tableView?.isScrollEnabled = false
                tableView.isPagingEnabled = true
                page = 1
            }
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == tableView {
            if scrollView.contentOffset.y == 0 {
                if (self.navigationController?.navigationBar.isHidden)! {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                }
            }
        }

        
    }
    

    func videosButtonTapped(_ sender: UIButton) {
        vidortag = false
        owntagged = true
        //print("bastı lan")
        BVc.player2?.stop()
        BVc.player1?.stop()
        let indexPath = IndexPath(row: 2, section: 0)
      
            self.redLabelOrigin = 0
        
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! profile3thCell
        
//        cell.redLabel.frame.origin.x = 0
//        cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
//        cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
//        cell.videosButton.setTitleColor(swiftColor, forState: .Normal)
//        cell.taggedButton.setTitleColor(greyColor1, forState: .Normal)
        
        let indexPath2 = IndexPath(row: 3, section: 0)
        
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.reloadRows(at: [indexPath2], with: .none)
        
        
        
    }
    @IBAction func followButton(_ sender: AnyObject) {
        if(classUser.username == MoleCurrentUser.username){
            showTable() //Settings table
            tableView.isUserInteractionEnabled = false // can be apply for search in maincontroller
        }else {
            if !classUser.isFollowing{
                followButton.image = UIImage(named: "unfollow")
                classUser.isFollowing = true
                classUser.follower_count+=1
                MoleCurrentUser.following_count += 1
                let indexPath = IndexPath(row: 1, section: 0)

                let cell = tableView.cellForRow(at: indexPath) as! profile2ndCell
                cell.numberFollower.text = "\(self.classUser.follower_count)"
                tableView.reloadRows(at: [indexPath], with: .none)
                
                MolocateAccount.follow(classUser.username, completionHandler: { (data, response, error) -> () in
                    //IMP:if request is failed delete change
                })
            }else {
                let actionSheetController: UIAlertController = UIAlertController(title: "Takibi bırakmak istediğine emin misin?", message: nil, preferredStyle: .actionSheet)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .cancel) { action -> Void in}
                actionSheetController.addAction(cancelAction)
                
                let takePictureAction: UIAlertAction = UIAlertAction(title: "Takibi Bırak", style: .default)
                { action -> Void in
                    
                    self.followButton.image = UIImage(named: "follow")
                    self.classUser.isFollowing = false
                    self.classUser.follower_count -= 1
                    let indexPath = IndexPath(row: 1, section: 0)
                    let cell = self.tableView.cellForRow(at: indexPath) as! profile2ndCell
                    cell.numberFollower.text = "\(self.classUser.follower_count)"
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    
                    cell.numberFollower.text = "\(self.classUser.follower_count)"
                    MoleCurrentUser.following_count -= 1
                    MolocateAccount.unfollow(self.classUser.username, completionHandler: { (data, response, error) -> () in
                        //IMP:if request is failed delete change
                        if let parentVC = self.parent {
                            if let parentVC = parentVC as? Followers{
                                MolocateAccount.getFollowings(username: MoleCurrentUser.username, completionHandler: { (data, response, error, count, next, previous) in
                                    DispatchQueue.main.async {
                                        parentVC.userRelations = data
                                        parentVC.myTable.reloadData()
                                    }
                                })
                            }
                        }
                    })
                }
                
                actionSheetController.addAction(takePictureAction)
                actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
                self.present(actionSheetController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func taggedButtonTapped(_ sender: UIButton) {
        vidortag = true
        owntagged = false
       // print("bastı lan2")
        AVc.player2?.stop()
        AVc.player1?.stop()
        let indexPath = IndexPath(row: 2, section: 0)
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! profile3thCell
        
        self.redLabelOrigin = Double(MolocateDevice.size.width)
        let indexPath2 = IndexPath(row: 3, section: 0)
//        cell.redLabel.frame.origin.x = MolocateDevice.size.width / 2
//        cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
//        cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
//        cell.videosButton.setTitleColor(greyColor1, forState: .Normal)
//        cell.taggedButton.setTitleColor(swiftColor, forState: .Normal)
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.reloadRows(at: [indexPath2], with: .none)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == optionsTable {
        return 3
        }
        
        else {
        return 4
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController!.tabBar.isHidden = true
        //(self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    
    
    
}
