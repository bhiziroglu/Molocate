import UIKit

let MolocateBaseUrl = "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/"


var is4s = false


struct MoleUserFollowings {
    var is_following = 0
    var picture_url = NSURL()
    var type:String = ""
    var username:String = ""
    var place_id:String = ""
}

var nextT:NSURL!

var nextU:NSURL!

var MoleUserToken: String?

var IsExploreInProcess = false

struct MoleUser{
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
    var gender = "male"
    var birthday = "2016-10-12"
    
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
}

var MoleCurrentUser: MoleUser = MoleUser()
var FaceUsername = ""
var FaceMail = ""
var FbToken = ""

public class MolocateAccount {
    
    class func follow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "/relation/api/follow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
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
    
    class func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    class func unfollow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl + "relation/api/unfollow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
           // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
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
    
 
    
    class func getFollowers(username: String, completionHandler: (data: Array<MoleUser>, response: NSURLResponse!, error: NSError!, count: Int, next: String?, previous: String? ) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "relation/api/followers/?username=" + (username as String) )!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
           // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
               // print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var users: Array<MoleUser> = Array<MoleUser>()
                
                if(count != 0){
                    print(result["results"] )
                    for thing in result["results"] as! NSArray{
                        var user = MoleUser()
                        user.username = thing["username"] as! String
                        user.profilePic = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        if(username == MoleCurrentUser.username){
                            user.isFollowing = thing["is_following"] as! Int == 0 ? false:true
                        }
                        users.append(user)
                    }
                }
                
                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<MoleUser>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowers()")
            }
            
        }
        task.resume()
    }
    
    
    class func getFollowings(username: String, completionHandler: (data: Array<MoleUserFollowings>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "relation/api/followings/?username=" + (username as String));
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            
            do {
                
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var followings: Array<MoleUserFollowings> = Array<MoleUserFollowings>()
                
                if(count != 0){
                    for thing in result["results"] as! NSArray{
                        var user = MoleUserFollowings()
                        user.username = thing["username"] as! String
                        user.picture_url = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        user.type = thing["type"] as! String
                        if user.type == "place" {
                            user.place_id = thing["place_id"] as! String
                        }
                        followings.append(user)
                    }
                }
                
                
                completionHandler(data: followings , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<MoleUserFollowings>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowings()")
            }
            
        }
        
        task.resume()
        
    }
       
    class func getUser(username: String, completionHandler: (data: MoleUser, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "account/api/get_user/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(result)
                var user = MoleUser()
                user.email = result["email"] as! String
                user.username = result["username"] as! String
                user.first_name = result["first_name"] as! String
                user.last_name = result["last_name"] as! String
                user.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                user.follower_count = result["follower_count"] as! Int
                user.following_count = result["following_count"]as! Int
                user.tag_count = result["tag_count"] as! Int
                user.post_count = result["post_count"]as! Int
                user.isFollowing = result["is_following"] as! Int == 1 ? true:false
           
                completionHandler(data: user, response: response , error: nsError  )
            } catch{
                completionHandler(data: MoleUser() , response: nil , error: nsError  )
                print("Error:: in mole.getUser()")
            }
            
            
        }
        
        task.resume()
    }
    

    
    

        class func EditUser(completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        do{
            
            let Body = ["profile_pic": MoleCurrentUser.profilePic.absoluteString,
                        "first_name": MoleCurrentUser.first_name,
                        "last_name": MoleCurrentUser.last_name,
                        "gender": MoleCurrentUser.gender,
                        "birthday": MoleCurrentUser.birthday
                        ]
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(Body, options: NSJSONWritingOptions())
            let url = NSURL(string: MolocateBaseUrl + "account/api/edit_user/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.HTTPBody = jsonData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                let nsError = error
                
                do {
                //check result if it is succed
                    _ = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    completionHandler(data: "success" , response: response , error: nsError  )
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    print("Error:: in mole.EditUser()")
                }
                
            }
            
            task.resume()
        }catch{
                    completionHandler(data: "fail" , response: nil , error: nil )
            print("Error:: in mole.EditUser()")
        }
    }
    
    class func uploadProfilePhoto(image: NSData, completionHandler: (data: String!, response: NSURLResponse!, error: NSError!) -> ()){
       
        let headers = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "/account/api/upload_picture/")!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.HTTPBody = image
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))

            let nsError = error;
            
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                var urlString = ""
                if(result["result"] as! String=="success"){
                    urlString = result["picture_url"] as! String
                }else{
                    urlString = ""
                }
                completionHandler(data: urlString, response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                
                print("Error:: in mole.uploadProfilePhoto()")
            }
            
        }
        
        task.resume();
        

            
    }
       
    class func getCurrentUser(completionHandler: (data: MoleUser, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl +  "/account/api/current/")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        //print(MoleUserToken)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            //print(data)
            let nsError = error;
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                //print(result)
                MoleCurrentUser.email = result["email"] as! String
                MoleCurrentUser.username = result["username"] as! String
                MoleCurrentUser.first_name = result["first_name"] as! String
                MoleCurrentUser.last_name = result["last_name"] as! String
                MoleCurrentUser.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                MoleCurrentUser.tag_count = result["tag_count"] as! Int
                MoleCurrentUser.post_count = result["post_count"] as! Int
                MoleCurrentUser.follower_count = result["follower_count"] as! Int
                MoleCurrentUser.following_count = result["following_count"]as! Int
                MoleCurrentUser.gender =  result["gender"] is NSNull ? "": (result["gender"] as! String)
                MoleCurrentUser.birthday = result["birthday"] is NSNull || (result["birthday"] as! String)   == "" ? "1970-01-01" : result["birthday"] as! String
                
                completionHandler(data: MoleCurrentUser, response: response , error: nsError  )
            } catch{
                completionHandler(data: MoleUser() , response: nil , error: nsError  )
                print("Error:: in mole.getCurrentUser()")
            }
            
        }
        
        task.resume();
        
    }
    
    
    
}
