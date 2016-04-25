//
//  S3upload.swift
//  Molocate
//
//  Created by Kagan Cenan on 23.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import Foundation
import AWSS3

let CognitoRegionType = AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.EUCentral1
let CognitoIdentityPoolId: String = "us-east-1:721a27e4-d95e-4586-a25c-83a658a1c7cc"
let S3BucketName: String = "molocatebucket"
var n = 0

public class S3Upload {
    
    class func upload(uploadRequest: AWSS3TransferManagerUploadRequest, fileURL: String, fileID: String, json: AnyObject) {
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                //print("internet low")
                                //upload(uploadRequest, fileURL: fileURL, fileID: fileID, json: json)
                                
                            })
                            break;
                            
                        default:
                            if (n < 10) {
                            print("upload() failed: [\(error)]")
                                let seconds = 1.0
                                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                
                                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                                    
                                    upload(uploadRequest, fileURL: fileURL, fileID: fileID, json: json)
                                    n += 1
                                    
                                })
                                

                            } else {
                                do {
                                    try NSFileManager.defaultManager().removeItemAtPath(videoPath!)

                                } catch _ {
                                    
                                }
                            }

                            
                            break;
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                        if (n < 10) {
                            let seconds = 1.0
                            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            
                            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                                
                                upload(uploadRequest, fileURL: fileURL, fileID: fileID, json: json)
                                n += 1
                                
                            })
                        } else {
                            do {
                                try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                                
                            } catch _ {
                                
                            }
                        }

                    }
                } else {
                    print("upload() failed: [\(error)]")
                    if (n < 10) {
                       
                        let seconds = 1.0
                        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        
                        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                            
                            upload(uploadRequest, fileURL: fileURL, fileID: fileID, json: json)
                            n += 1
                            
                        })
                    } else {
                        do {
                            try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                            
                        } catch _ {
                            
                        }
                    }

                }
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
                if (n < 10) {
                    
                    let seconds = 1.0
                    let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        
                        upload(uploadRequest, fileURL: fileURL, fileID: fileID, json: json)
                        n += 1
                        
                    })
                } else {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                        
                    } catch _ {
                        
                    }
                }

            }
            
            if task.result != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                CaptionText = CaptionText.componentsSeparatedByString("@")[0]
                    
                                            let newheaders = [
                                                "authorization": "Token \(MoleUserToken!)",
                                                "content-type": "application/json",
                                                "cache-control": "no-cache"
                                            ]
                    
                                            do {
                    
                                                let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options:  NSJSONWritingOptions.PrettyPrinted)
                                               // print(NSString(data: jsonData, encoding: NSUTF8StringEncoding))
                                               // print(jsonData)
                                               // create post request
                    
                                                let request = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "video/update/")!,
                                                    cachePolicy: .UseProtocolCachePolicy,
                                                    timeoutInterval: 10.0)
                                                request.HTTPMethod = "POST"
                                                request.allHTTPHeaderFields = newheaders
                                                request.HTTPBody = jsonData
                    
                    
                                                let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                                                    //print(response)
                                                    //print("=========================================")
                                                    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                                                    dispatch_async(dispatch_get_main_queue(), {
                                                        if error != nil{
                                                            print("Error -> \(error)")
                    
                                                            return
                                                        }
                    
                                                        do {
                    
                                                            let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                                                                    CaptionText = ""
                                                            //print("Result -> \(result)")
                    
                    
                    
                                                        } catch {
                                                           // print("Error -> \(error)")
                                                        }
                    
                                                    })
                                                }
                    
                                                task.resume()
                    
                    
                    
                    
                    
                                            } catch {
                                                print(error)
                    
                    
                                            }
                    
                                let headers2 = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
                    
                                let thumbnailRequest = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "/video/api/upload_thumbnail/?video_id="+fileID)!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 10.0)
                    
                                thumbnailRequest.HTTPMethod = "POST"
                                thumbnailRequest.allHTTPHeaderFields = headers2
                                let image = UIImageJPEGRepresentation(thumbnail, 0.5)
                                thumbnailRequest.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
                                thumbnailRequest.HTTPBody = image
                                let thumbnailTask = NSURLSession.sharedSession().dataTaskWithRequest(thumbnailRequest){data, response, error  in
                                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                                    
                                    let nsError = error;
                                    
                                    
                                    do {
                                        let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                                        //print(result)
                                        
                                        
                                    } catch{
                                        
                                        
                                        print(nsError)
                                    }
                                    
                                }
                                
                                thumbnailTask.resume();
                    
 
                })
                do {
                try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                                                
                dispatch_async(dispatch_get_main_queue()) {
                print("siiiiil")
                
                n = 0
                
                    }
                           } catch _ {
                        
                                }
                    }
            return nil
        }
    }
    
   
}