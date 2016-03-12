import UIKit
import SystemConfiguration

let baseUrl = "http://molocate.elasticbeanstalk.com/"


struct videoInf{
    var username:String = ""
    var category:String = ""
    var location:String = ""
    var locationID:String = ""
    var caption:String = ""
    var urlSta:NSURL = NSURL()
    var urlTemp:NSURL = NSURL()
    var likeCount = 0
    var commentCount = 0
    var comments = [String]()
    
}

var nextU:NSURL!
var userToken: String?

struct User{
    var username:String = ""
    var email : String = ""
    var profilePic:NSURL = NSURL()
    var token: String = ""
    var first_name = ""
    var last_name = ""
    var post_count = 0;
    var tag_count = 0;
    var follower_count = 0;
    var following_count = 0;
    var isFollowing:Bool = false;
    
    func printUser() -> Void {
        print("username: " + username)
        print("email: " + email)
        //print("profile_pic: " + profilePic.absoluteString)
        //print("token: "+ token)
        print("first_name: "+first_name)
        print("last_name: "+last_name)
        print("post_count:  \(post_count)");
        print("tag_count:  \(tag_count)");
        print("follower_count:  \(follower_count)");
        print("following_count:  \(following_count)");
    }
    
    func follow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: baseUrl + "/relation/api/follow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.follow()")
            }
            
        }
        
        task.resume()
        
    }
    
    
    func unfollow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: baseUrl + "relation/api/unfollow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.unfollow()")
            }
            
        }
        
        task.resume()
    }
}

var currentUser:User = User()

public class Molocate {
    
    
    
    class func getFollowers(username: String, completionHandler: (data: Array<String>, response: NSURLResponse!, error: NSError!, count: Int, next: String?, previous: String? ) -> ()) {
        
        let url = NSURL(string: baseUrl + "relation/api/followers/" + (username as String) + "/")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var users: Array<String> = Array<String>();
                
                if(count != 0){
                    users = result["results"] as! Array<String>
                }
                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<String>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowers()")
            }
            
        }
        task.resume()
    }
    
    
    class func getFollowings(username: String, completionHandler: (data: Array<String>!, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        
        let url = NSURL(string: baseUrl + "relation/api/followings/" + (username as String) + "/");
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken! , forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print("======================================")
                print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var users: Array<String> = Array<String>();
                
                if(count != 0) {users = result["results"] as! Array<String>}
                
                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<String>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowings()")
            }
            
        }
        
        task.resume()
        
    }
    
    
    class func getUser(username: String, completionHandler: (data: User, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: baseUrl + "account/api/get_user/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                var user = User()
                user.email = result["email"] as! String
                user.username = result["username"] as! String
                user.first_name = result["first_name"] as! String
                user.last_name = result["last_name"] as! String
                user.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                user.follower_count = result["follower_count"] as! Int
                user.following_count = result["following_count"]as! Int
                
                completionHandler(data: user, response: response , error: nsError  )
            } catch{
                completionHandler(data: User() , response: nil , error: nsError  )
                print("Error:: in mole.getUser()")
            }
            
            
        }
        
        task.resume()
    }
    
    
    class func getExploreVideos(var nextURL: NSURL?, completionHandler: (data: [videoInf]?, response: NSURLResponse!, error: NSError!) -> ()){
        
        let request = NSMutableURLRequest(URL: nextURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                let videos = result["results"] as! NSArray
                if (result["next"] != nil){
                    if result["next"] is NSNull {
                        print("next is null")
                        nextU = nil
                    }else {
                        let nextStr = result["next"] as! String
                        print(nextStr)
                        nextU = NSURL(string: nextStr)!
                    }
                }
                
                var videoArray = [videoInf]()
                
                for item in videos {
                    
                    var videoStr = videoInf()
                    videoStr.urlSta = NSURL(string:  item["video_url"] as! String)!
                    videoStr.username = item["owner_user"]!!["username"] as! String
                    videoStr.location = item["place_taken"]!!["name"] as! String
                    videoStr.locationID = item["place_taken"]!!["place_id"] as! String
                    videoStr.caption = item["caption"] as! String
                    videoStr.likeCount = item["like_count"] as! Int
                    videoStr.commentCount = item["comment_count"] as! Int
                    videoStr.category = item["category"] as! String
                    videoArray.append(videoStr)
                }
                completionHandler(data: videoArray, response: response, error: nsError)
            }catch{
                completionHandler(data: nil, response: NSURLResponse(), error: nsError)
                
            }
        }
        task.resume()
    }
    
    

    
    
    class func getCurrentUser(completionHandler: (data: User, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: baseUrl +  "/account/api/current/")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            
            let nsError = error;
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(result)
                currentUser.email = result["email"] as! String
                currentUser.username = result["username"] as! String
                currentUser.first_name = result["first_name"] as! String
                currentUser.last_name = result["last_name"] as! String
                currentUser.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                currentUser.tag_count = result["tag_count"] as! Int
                currentUser.post_count = result["post_count"] as! Int
                currentUser.follower_count = result["follower_count"] as! Int
                currentUser.following_count = result["following_count"]as! Int
                
                completionHandler(data: currentUser, response: response , error: nsError  )
            } catch{
                completionHandler(data: User() , response: nil , error: nsError  )
                print("Error:: in mole.getCurrentUser()")
            }
            
        }
        
        task.resume();
        
    }
    
}