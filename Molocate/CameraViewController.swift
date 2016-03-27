
//
//  CameraViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 16.11.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import QuadratTouch
import RecordButton



var locationDict:[[String:locations]]!

struct locations{
    var id = ""
    var name = ""
    var lat:Float!
    var lon:Float!
    var adress = ""
}

private enum AVCamSetupResult: Int {
    case Success
    case CameraNotAuthorized
    case SessionConfigurationFailed
}
var videoPath: String?
var videoData: NSData?
var fakeoutputFileURL: NSURL?
var fakebackgrounID: NSInteger?
var placesArray = [String]()
var videoId:String!
var videoUrl:String!
var tempAssetURL: NSURL!
var audioAsset:AVAsset!
typealias JSONParameters = [String: AnyObject]

class CameraViewController: UIViewController,CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate{
    var recordButton : RecordButton!
    var progressTimer : NSTimer!
    var progress : CGFloat! = 0
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var rootLayer = CALayer()
    var camera = true
    var videoURL = NSURL()
    var sessionQueue: dispatch_queue_t?
    var vurl: NSURL?
    var topLayer = CALayer()
    var flashLayer = CALayer()
    var bottomLayer = CALayer()
    var firstAsset:AVAsset!
    var secondAsset:AVAsset!
    var isFlashMode = false
    var deviceLat: CLLocationDegrees?
    var deviceLon: CLLocationDegrees?
    //var placesClient: GMSPlacesClient?
    @IBOutlet var toolbarYancı: UILabel!
    
    @IBOutlet var bottomToolbar: UIToolbar!
    @IBOutlet var toolbar: UIToolbar!
    private var setupResult: AVCamSetupResult = .Success
    private var sessionRunning: Bool = false
    private var backgroundRecordingID: UIBackgroundTaskIdentifier = 0
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureMovieFileOutput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recordingDelegate: AVCaptureFileOutputRecordingDelegate?
    
    var location:CLLocation!
    var locationManager:CLLocationManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.barTintColor = swiftColor
        toolbar.translucent = false
        toolbar.clipsToBounds = true
        
        bottomToolbar.barTintColor = swiftColor
        bottomToolbar.translucent = false
        bottomToolbar.clipsToBounds = true
        
        locationDict = [[String:locations]]()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        location = locationManager.location
        deviceLat = locationManager.location?.coordinate.latitude
        deviceLon = locationManager.location?.coordinate.longitude
        let width = self.view.frame.width
        let height = (self.view.frame.height-self.view.frame.width-2*self.toolbar.frame.height-self.toolbarYancı.frame.height)
        let topRect = CGRect(x: 0, y: self.view.frame.width+self.toolbar.frame.height+self.toolbarYancı.frame.height, width: width, height: height)
        let nview = UIView(frame: topRect)
        
        recordButton = RecordButton(frame: CGRectMake(0,0,2*topRect.height/3,2*topRect.height/3))
        recordButton.center = nview.center
        recordButton.progressColor = .redColor()
        recordButton.closeWhenFinished = false
        recordButton.buttonColor = swiftColor
        recordButton.addTarget(self, action: "holdDown", forControlEvents: .TouchDown)
        recordButton.addTarget(self, action: "holdRelease", forControlEvents: .TouchUpInside)
        recordButton.center.x = self.view.center.x
        view.addSubview(recordButton)
        
        self.captureSession = AVCaptureSession()
        
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.session = self.captureSession
        
        
        

        self.setupResult = AVCamSetupResult.Success
        
        // Check video authorization status. Video access is required and audio access is optional.
        // If audio access is denied, audio is not recorded during movie recording.
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized:
            // The user has previously granted access to the camera.
            break
        case .NotDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend(self.sessionQueue!)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) {granted in
                if !granted {
                    self.setupResult = AVCamSetupResult.CameraNotAuthorized
                }
                dispatch_resume(self.sessionQueue!)
            }
        default:
            // The user has previously denied access.
            self.setupResult = AVCamSetupResult.CameraNotAuthorized
        }

        
        dispatch_async(self.sessionQueue!) {
            guard self.setupResult == AVCamSetupResult.Success else {
                return
            }

            self.backgroundRecordingID = UIBackgroundTaskInvalid
            
            let videoDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)
            let videoDeviceInput: AVCaptureDeviceInput!
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
            } catch let error as NSError {
                videoDeviceInput = nil
                NSLog("Could not create video device input: %@", error)
            } catch _ {
                fatalError()
            }
            
            
            

            self.captureSession!.beginConfiguration()
            
            
            if self.captureSession!.canAddInput(videoDeviceInput) {
                self.captureSession!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // This part is for the square shaped capture. Actually our capture is on all screen like normal camera but we are reducing that into square shaped with the two cover layer.
                    let newFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.previewLayer!.frame = newFrame
                    let y = (self.view.frame.height+self.view.frame.width)/2
                    let width = self.view.frame.width
                    let height = (self.view.frame.height-self.view.frame.width-2*self.toolbar.frame.height-self.toolbarYancı.frame.height)
                    let topRect = CGRect(x: 0, y: self.view.frame.width+self.toolbar.frame.height+self.toolbarYancı.frame.height, width: width, height: height)
                    //let bottomRect = CGRect(x: 0, y: 0, width: width , height: height)
                    self.topLayer.frame = topRect
                    //self.bottomLayer.frame = bottomRect
                    self.topLayer.backgroundColor = UIColor.whiteColor().CGColor
                    //self.bottomLayer.backgroundColor = UIColor.whiteColor().CGColor
                    self.topLayer.opacity = 0.6
                    self.bottomLayer.opacity = 0.6
                    self.view.layer.addSublayer(self.previewLayer!)
                    self.view.layer.addSublayer(self.bottomLayer)
                    self.view.layer.addSublayer(self.bottomToolbar.layer)
                    self.view.layer.addSublayer(self.topLayer)
                    self.view.layer.addSublayer(self.toolbar.layer)
                    self.view.layer.addSublayer(self.toolbarYancı.layer)
                    self.view.layer.addSublayer(self.recordButton.layer)
                    self.view.layer.addSublayer(self.flashButton.layer)

                    //self.view.layer.addSublayer(self.videoDoneOutlet.layer)
                    
                    
                }
            } else {
                NSLog("Could not add video device input to the session")
           //     self.setupResult = AVCamSetupResult.SessionConfigurationFailed
            }
            
            let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            let audioDeviceInput: AVCaptureDeviceInput!
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                
            } catch let error as NSError {
                audioDeviceInput = nil
                NSLog("Could not create audio device input: %@", error)
            } catch _ {
                fatalError()
            }
            
            if self.captureSession!.canAddInput(audioDeviceInput) {
                self.captureSession!.addInput(audioDeviceInput)
            } else {
                NSLog("Could not add audio device input to the session")
            }
            
            let movieFileOutput = AVCaptureMovieFileOutput()
            let preferredTimeScale:Int32 = 30
            let totalSeconds:Int64 = Int64(Int(15) * Int(preferredTimeScale))
            let maxDuration:CMTime = CMTimeMake(totalSeconds, preferredTimeScale)
            movieFileOutput.maxRecordedDuration = maxDuration
            if self.captureSession!.canAddOutput(movieFileOutput) {
                self.captureSession!.addOutput(movieFileOutput)
                let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
                if connection?.supportsVideoStabilization ?? false {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
                }
                self.videoOutput = movieFileOutput
                
            } else {
                NSLog("Could not add movie file output to the session")
                //self.setupResult = AVCamSetupResult.SessionConfigurationFailed
            }
            
            
            self.captureSession!.commitConfiguration()
            self.captureSession?.startRunning()
        }
        

     
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {


        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(self.sessionQueue!) {
            switch self.setupResult {
            case .Success:
                // Only setup observers and start the session running if setup succeeded.
              
                self.captureSession!.startRunning()
                self.sessionRunning = self.captureSession!.running
                
            case .CameraNotAuthorized:
                dispatch_async(dispatch_get_main_queue()){
                    let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera" )
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    // Provide quick access to Settings.
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: UIAlertActionStyle.Default) {action in
                        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                    }
                    alertController.addAction(settingsAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            case .SessionConfigurationFailed:
                dispatch_async(dispatch_get_main_queue()) {
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        
        let session = Session.sharedSession()
        
        //var parameters = [Parameter.query:"moda sahil"]
        let parameters = location!.parameters()
        let searchTask = session.venues.search(parameters) {
            (result) -> Void in
            if let response = result.response {
                //print(response)
                let venues = response["venues"] as! [JSONParameters]?
                for item in venues! {
                    let distance = item["location"]!["distance"] as! NSInteger
                    let isVerified = item["verified"] as! Bool
                    let checkinsCount = item["stats"]!["checkinsCount"] as! NSInteger
                    let enoughCheckin:Bool = (checkinsCount > 700)
                    if (distance < 400){
                        if(isVerified||enoughCheckin){
                            print(item)
                         placesArray.append(item["name"] as! String)
                         let name = item["name"] as! String
                         let id = item["id"] as! String
                         let lat = item["location"]!["lat"] as! Float
                         let lon = item["location"]!["lng"] as! Float
                         //let adress = item["location"]!["address"]
                         var loc = locations()
                         loc.name = name
                         loc.id = id
                         loc.lat = lat
                         loc.lon = lon
                         //loc.adress = adress

                        var locationDictitem = [name:loc]
                            locationDict.append(locationDictitem)
                        
                        }
                    }
                    
                   
//                    if(item["verified"]! as! NSObject == 1){
//                        
//                    }
//                    print(item["name"])
//                    print(item["location"]!["address"])//!["distance"])
//                    print(item["verified"])
//                    print(item["stats"]!["checkinsCount"])
//                    print("----------")
                }
                //                self.tableView.reloadData()
            }
        }
        searchTask.start()
//        placesClient = GMSPlacesClient()
//        placesClient?.currentPlaceWithCallback({
//            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
//            
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//
//        
//                
//                var array = placeLikelihoodList!.likelihoods
//            
//                
//                for item in array {
//                    print(item)
//                    var tempPlace: GMSPlace = item.place
//                    var tempPlaceTypes = tempPlace.types as NSArray
//                    let c : NSArray = ["airport", "amusement_park", "aquarium" , "art_gallery","bakery","bar","beauty_salon","bicycle_store","book_store","bowling_alley","cafe","campground","casino","church","city_hall","clothing_store","convenience_store","department_store","electronics_store","embassy","finance","florist","food","furniture_store","gas_station","grocery_or_supermarket","gym","hair_care","hardware_store","health","hindu_temple","home_goods_store","hospital","jewelry_store","library","liquor_store","lodging","meal_delivery","meal_takeaway","mosque","movie_theater","museum","night_club","painter","park","parking","pet_store","place_of_worship","restaurant","rv_park","school","shoe_store","shopping_mall","spa","stadium","store","synagogue","train_station","university","veterinary_care","zoo"]
//                
//                    
//                    var placeLon = tempPlace.coordinate.longitude
//                    var PlaceLat = tempPlace.coordinate.latitude
//                    var diflon = placeLon - self.deviceLon!
//                    var diflat = PlaceLat - self.deviceLat!
//                    
//                    var distancedeg = (diflon*diflon) + (diflat*diflat)
//                    var distance = sqrt(distancedeg)*111
//                   
//                    if(distance < 0.500){
//                        placesArray.append(tempPlace.name)
//                        
//                    }
//                    
//                    
//                }
//                
//            
//        })

    }

    
    @IBAction func focusTap(gestureRecognizer: UIGestureRecognizer) {
        let devicePoint = (self.previewLayer! as AVCaptureVideoPreviewLayer).captureDevicePointOfInterestForPoint(gestureRecognizer.locationInView(gestureRecognizer.view))
        self.focusWithMode(AVCaptureFocusMode.AutoFocus, exposeWithMode: AVCaptureExposureMode.AutoExpose, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
        
    }
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!

    @IBOutlet var cameraChange: UIBarButtonItem!
    @IBAction func cameraChange(sender: AnyObject) {
        
        self.cameraChange.enabled = false
        self.recordButton.enabled = false
        
        
        dispatch_async(self.sessionQueue!) {
            let currentVideoDevice = self.videoDeviceInput.device
            var preferredPosition = AVCaptureDevicePosition.Unspecified
            let currentPosition = currentVideoDevice.position
            
            switch currentPosition {
            case AVCaptureDevicePosition.Unspecified, AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
            case AVCaptureDevicePosition.Back:
                preferredPosition = AVCaptureDevicePosition.Front
            }
            
            let videoDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo,  preferringPosition: preferredPosition)
            let videoDeviceInput: AVCaptureDeviceInput!
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch _ {
                videoDeviceInput = nil
            }
            
            self.captureSession!.beginConfiguration()
            
            // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
            self.captureSession!.removeInput(self.videoDeviceInput)
            
            if self.captureSession!.canAddInput(videoDeviceInput) {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentVideoDevice)
                
                CameraViewController.setFlashMode(AVCaptureFlashMode.On, forDevice: videoDevice!)
                
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:",  name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDevice)
                
                self.captureSession!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                self.captureSession!.addInput(self.videoDeviceInput)
            }
            
            let connection = self.videoOutput!.connectionWithMediaType(AVMediaTypeVideo)
            connection.videoOrientation = self.previewLayer!.connection.videoOrientation
            if connection.supportsVideoStabilization {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
            }
            
            self.captureSession!.commitConfiguration()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.cameraChange.enabled = true
                self.recordButton.enabled = true
                
            }
        }
        
        
    }

    
    
    
    
    /*
    @IBAction func startRecord(sender: AnyObject) {
        self.camChange.enabled = false
        self.recordButton.enabled = false
       

        dispatch_async(self.sessionQueue!) {
        
            if !self.videoOutput!.recording {
                if UIDevice.currentDevice().multitaskingSupported {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                let connection = self.videoOutput!.connectionWithMediaType(AVMediaTypeVideo)
                
                connection.videoOrientation = self.previewLayer!.connection.videoOrientation
                
                // Turn OFF flash for video recording.
                
                
                
                // Start recording to a temporary file.
                let outputFileName = NSProcessInfo.processInfo().globallyUniqueString as NSString
                let outputFilePath: String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName.stringByAppendingPathExtension("mov")!)
                self.videoOutput!.startRecordingToOutputFileURL(NSURL.fileURLWithPath(outputFilePath), recordingDelegate: self)
                
            } else {
                self.videoOutput!.stopRecording()
                
            }
            
                
                
            

            }
        

        
        
        
        
        
        

                    

                    
                    

       
        
    } */


    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        // Enable the Record button to let the user stop the recording.
        dispatch_async( dispatch_get_main_queue()) {
            self.recordButton.enabled = true
            //self.recordButton.setTitle(NSLocalizedString("Stop", comment: "Recording button stop title"), forState: .Normal)
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
        // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
        // is back to NO — which happens sometime after this method returns.
        // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
        
        let currentBackgroundRecordingID = self.backgroundRecordingID
        self.backgroundRecordingID = UIBackgroundTaskInvalid
        fakebackgrounID = currentBackgroundRecordingID
        
        
        
        
        

        
        var success = true
        
        if error != nil {
            NSLog("Movie file finishing error: %@", error!)
            success = error!.userInfo[AVErrorRecordingSuccessfullyFinishedKey] as! Bool? ?? false
        }
        if success {
            //print(outputFileURL)
            if firstAsset == nil {
                firstAsset = AVAsset(URL: outputFileURL)
                tempAssetURL = outputFileURL
                fakeoutputFileURL = outputFileURL
                
            } else {
                
                firstAsset = AVAsset(URL: tempAssetURL)
                secondAsset = AVAsset(URL: outputFileURL)
            
                let merge = AVMutableComposition()
                let firstTrack = merge.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                _ = merge.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                let firstTrackAudio = merge.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
                                //var firstLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
                //var mainInstruction = AVMutableVideoCompositionInstruction()
                
                
                
                
                do {
                        try firstTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: firstAsset.duration), ofTrack: firstAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: kCMTimeZero)
                        try firstTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: secondAsset.duration), ofTrack: secondAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: firstAsset.duration)
//                    
                        try firstTrackAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: firstAsset.duration), ofTrack: firstAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
                        try firstTrackAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: secondAsset.duration), ofTrack: secondAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: firstAsset.duration)

                    
//                    // 2.1
//                    var mainInstruction = AVMutableVideoCompositionInstruction()
//                    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
////
////                    // 2.2
//                    let firstInstruction = videoCompositionInstructionForTrack(firstTrack, asset: firstAsset)
//                    firstInstruction.setOpacity(0.0, atTime: firstAsset.duration)
//                    let secondInstruction = videoCompositionInstructionForTrack(secondTrack, asset: secondAsset)
//                    
//                    // 2.3
//                    mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
//                    let mainComposition = AVMutableVideoComposition()
//                    mainComposition.instructions = [mainInstruction]
//                    mainComposition.frameDuration = CMTimeMake(1, 30)
//                    mainComposition.renderSize = CGSize(width: UIScreen.mainScreen().bounds.width,
//                        height: UIScreen.mainScreen().bounds.height)
////
                    
                    
                    
                    
                        _ = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
                        let outputFileName = NSProcessInfo.processInfo().globallyUniqueString as NSString
                        let exportPath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName.stringByAppendingPathExtension("mov")!)
                        print(exportPath)
                        let exportURL = NSURL(fileURLWithPath: exportPath)
                        let exporter = AVAssetExportSession(asset: merge, presetName: AVAssetExportPresetHighestQuality)
                        exporter?.outputURL = exportURL
                        //exporter?.videoComposition = mainComposition
                        exporter?.outputFileType = AVFileTypeQuickTimeMovie
                        exporter?.shouldOptimizeForNetworkUse = true
                        exporter?.exportAsynchronouslyWithCompletionHandler({ () -> Void in

                            dispatch_async(dispatch_get_main_queue()) {
                                
                                let cleanup: dispatch_block_t = {
                                    do {
                                        try NSFileManager.defaultManager().removeItemAtURL(fakeoutputFileURL!)
                                        try NSFileManager.defaultManager().removeItemAtURL(outputFileURL)
                                        
                                    } catch _ {}
                                    
                                }
                                cleanup()

                                
                                fakeoutputFileURL = exporter?.outputURL
                                //print(fakeoutputFileURL)
                                tempAssetURL = fakeoutputFileURL
                                
//                                print(self.secondAsset!.duration)
//                                print(AVAsset(URL: tempAssetURL).duration)

                                
                            }

                        })
                    
                    
                    
                    
                }
                catch let error {
                    print(error)
                }
            }
            
           // fakeoutputFileURL = outputFileURL
            // Check authorization status.
            PHPhotoLibrary.requestAuthorization {status in
                guard status == PHAuthorizationStatus.Authorized else {
                    //cleanup()
                    return
                }
                
                //self.cropVideoSquare(fakeoutputFileURL!)
                
                
                // Save the movie file to the photo library and cleanup.

            }
        } else {
            //cleanup()
        }

        dispatch_async( dispatch_get_main_queue()) {
            // Only enable the ability to change camera if the device has more than one camera.
            self.cameraChange.enabled = (AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 1)
            self.recordButton.enabled = true
            //self.recordButton.setTitle(NSLocalizedString("Record", comment: "Recording button record title"), forState: .Normal)
        }
    }

    @IBAction func videoDone(sender: AnyObject) {
        print(firstAsset.duration.seconds)
        if self.progress > 0.2 {
        tempAssetURL = nil
        firstAsset = nil
        secondAsset = nil
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.cropVideoSquare(fakeoutputFileURL!)
        } else {
            displayAlert("Dikkat!", message: "Videonuz en az 3 saniye olmalıdır.")
        }
        
        
    }

    func focusWithMode(focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point:CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue!) {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
                
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = point
                    device.focusMode = focusMode
                }
                
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = exposureMode
                }
                
                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            } catch _ {}
        }
    }
    
    
    class func setFlashMode(flashMode: AVCaptureFlashMode, forDevice device: AVCaptureDevice) {
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            do {
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                device.flashMode = flashMode
            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            }
        }
    }
    
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice = devices.first as! AVCaptureDevice?
        
        for device in devices as! [AVCaptureDevice] {
            if device.position == position {
                captureDevice = device
                break
            }
        }
        
        return captureDevice
    }
    
    func cropVideoSquare(url: NSURL ){
        
        //All explanations are in crop video square xcodeproject in https://www.one-dreamer.com/cropping-video-square-like-vine-instagram-xcode/
        let tempasset = AVAsset(URL: url)
        let clipVideoTrack = (tempasset.tracksWithMediaType(AVMediaTypeVideo)[0]) as AVAssetTrack
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1,30)
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height)/2)
        
        let t2 = CGAffineTransformRotate(t1, 3.141593/2)
        _ = t2
        transformer.setTransform(t2, atTime: kCMTimeZero)
        instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let exportPath = documentsPath.stringByAppendingFormat("/CroppedVideo.mp4", documentsPath)
        
        let exportURl = NSURL(fileURLWithPath: exportPath)
        
        let exporter = AVAssetExportSession(asset: tempasset, presetName:AVAssetExportPresetMediumQuality )
        exporter?.videoComposition = videoComposition
        exporter?.outputURL = exportURl
        exporter?.outputFileType = AVFileTypeMPEG4

        exporter?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
        
            

            videoPath = exportPath
            
            
            
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(fakeoutputFileURL!)
 
                } catch _ {
                    
                }
        
            self.performSegueWithIdentifier("capturePreview", sender: self)
            
          
            
        })
        
       // self.performSegueWithIdentifier("capturePreview", sender: self)

        
    }

    


    @IBOutlet var backtoCont: UIBarButtonItem!
    @IBAction func backtoCont(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            
            let cleanup: dispatch_block_t = {
                do {
                    
                    try NSFileManager.defaultManager().removeItemAtURL(fakeoutputFileURL!)
                    
                    
                } catch _ {}
                
            }
            if(fakeoutputFileURL != nil){
            cleanup()
            }
        
        self.performSegueWithIdentifier("backToCont", sender: self)
        }
        
        }

    func holdDown(){
        
        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        self.cameraChange.enabled = false
        self.recordButton.enabled = false
       
        
        dispatch_async(self.sessionQueue!) {
            if self.isFlashMode {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                if device.isFlashModeSupported(AVCaptureFlashMode.On){
                    device.torchMode = .On
                }else {
                    print("burda")
                    dispatch_async(dispatch_get_main_queue()) {
                    let newFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.flashLayer.frame = newFrame
                    self.flashLayer.backgroundColor = UIColor.whiteColor().CGColor
                    self.flashLayer.opacity = 0.7
                    self.view.layer.addSublayer(self.flashLayer)
                    }
                    
                }
                

            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            } catch _ {}
        
            }
            
            if self.progress < 1 {
            if !self.videoOutput!.recording {
                if UIDevice.currentDevice().multitaskingSupported {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                let connection = self.videoOutput!.connectionWithMediaType(AVMediaTypeVideo)
                
                connection.videoOrientation = self.previewLayer!.connection.videoOrientation
                
                // Turn OFF flash for video recording.
                
                
                
                // Start recording to a temporary file.
                let outputFileName = NSProcessInfo.processInfo().globallyUniqueString as NSString
                //print(outputFileName)

                let outputFilePath: String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName.stringByAppendingPathExtension("mov")!)
                
                self.videoOutput!.startRecordingToOutputFileURL(NSURL.fileURLWithPath(outputFilePath), recordingDelegate: self)
                
            } else {
                self.videoOutput!.stopRecording()
                
            }
            
            }
            
            
            
        }
        
        
        
        
        
        
        
        
        
        
        

    }
    
    func updateProgress() {
        
        let maxDuration = CGFloat(15) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        
        if progress >= 1 {
            progressTimer.invalidate()
        }
        
    }


    func holdRelease(){
        self.progressTimer.invalidate()

        if self.isFlashMode {
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            if device.isFlashModeSupported(AVCaptureFlashMode.On){
                device.torchMode = .Off
            }else {
                print("burda")
                dispatch_async(dispatch_get_main_queue()) {
                    self.flashLayer.removeFromSuperlayer()
                }
                
            }
            
            
        } catch let error as NSError {
            NSLog("Could not lock device for configuration: %@", error)
        } catch _ {}
            
        }
        
        if self.videoOutput!.recording {
        self.videoOutput?.stopRecording()
        }
        
    }
    
    
    class func setFlashMode(flashMode: AVCaptureFlashMode, device: AVCaptureDevice){
        
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.torchMode = AVCaptureTorchMode.On
                print(device.torchLevel)
                device.unlockForConfiguration()
                
            } catch let error1 as NSError {
                error = error1
                print(error)
            }
        }
        
    }
    
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
           
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
            
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
            
        }
        return (assetOrientation, isPortrait)
    }
    
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        // 1
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        // 2
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        // 3
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
        print(assetInfo.orientation)
        if assetInfo.isPortrait {
            // 4
            print("ppppp")
            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)

            //instruction.setTransform(t2, atTime: kCMTimeZero)
            
            
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                atTime: kCMTimeZero)
            

            
            
        } else {
            // 5
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
            if assetInfo.orientation == .Down {
                print("down")
                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let windowBounds = UIScreen.mainScreen().bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
            }
            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
        
        return instruction
    }
    
    
  
    
    @IBOutlet var flashButton: UIButton!

    @IBAction func flashButton(sender: AnyObject) {
        if isFlashMode == false {
            isFlashMode = true
            flashButton.setTitle("Kapa", forState: .Normal)
        } else {
            isFlashMode = false
            flashButton.setTitle("Ac", forState: .Normal)
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
    
    
}


