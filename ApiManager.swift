

import UIKit
import Alamofire
import SVProgressHUD

class ApiManager: NSObject {
    static let sharedInstance = ApiManager()
    let BaseUrl : String = hostUrl
    func requestGETURL(_ strURL: String, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void)
    {
        if(isInternetAvailable() == false)
        {
            Appdata.sharedInstance.AlertView(title: "Alert", message: NSLocalizedString("Internet Not Available", comment: ""))
            return
        }
        
        let mainUrl : String = "\(self.BaseUrl)\(strURL)"
        Alamofire.request(mainUrl).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let resJson = responseObject.result.value!
                success(resJson as! NSDictionary)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    func requestPOSTURL(_ strURL : String, params : [String : AnyObject]?, progress : Bool, headers : [String : String]?, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void){
        let mainUrl : String = "\(self.BaseUrl)\(strURL)"
        if(isInternetAvailable() == false)
        {
            Appdata.sharedInstance.AlertView(title: "Alert", message: NSLocalizedString("Internet Not Available", comment: ""))
            return
        }
        if(progress == true)
        {
            SVProgressHUD.show()
        }
        Alamofire.request(mainUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            (responseObject) -> Void in
            if(progress == true)
            {
                SVProgressHUD.dismiss()
            }
            if responseObject.result.isSuccess {
                let resJson = responseObject.result.value!
                success(resJson as! NSDictionary)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    func requestPOSTURL1(_ strURL : String, params : [String : AnyObject]?, progress : Bool, headers : [String : String]?, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void){
        let mainUrl : String = strURL
        if(isInternetAvailable() == false)
        {
            Appdata.sharedInstance.AlertView(title: "Alert", message: NSLocalizedString("Internet Not Available", comment: ""))
            return
        }
        if(progress == true)
        {
            SVProgressHUD.show()
        }
        Alamofire.request(mainUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON {
            (responseObject) -> Void in
            if(progress == true)
            {
                SVProgressHUD.dismiss()
            }
            if responseObject.result.isSuccess {
                let resJson = responseObject.result.value!
                success(resJson as! NSDictionary)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    func requestPOSTImageURL(_ strURL : String, params : [String : Any]?,image : [UIImage],uniqueId: String, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void){
        let mainUrl : String = "\(self.BaseUrl)\(strURL)"
            SVProgressHUD.show()
        //        let imgData = UIImageJPEGRepresentation(image,1)
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            // import image to request
//             for img in image{
//                multipartFormData.append(imageData, withName: "\(imageParamName)[]", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
//            }
//            for (key, value) in parameters {
//                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//            }
//        }, to: mainUrl,
//           
//           encodingCompletion: { encodingResult in
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    
//                }
//            case .failure(let error):
//                print(error)
//            }
//            
//        })
        if(isInternetAvailable() == false)
        {
            Appdata.sharedInstance.AlertView(title: "Alert", message: NSLocalizedString("Internet Not Available", comment: ""))
            return
        }
        
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                for img in image{
                    var imgName = String(Date().millisecondsSince1970)
                    let imgData = img.compress(.medium)
                    MultipartFormData.append(imgData!, withName: "profileImage[]", fileName: "\(imgName).png", mimeType: "image/png")
                }
                for (key, value) in params! {
                    MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
                
        }, to: mainUrl) { (result) in
                      SVProgressHUD.dismiss()
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { responseObject in
                    if responseObject.result.isSuccess {
                        let resJson = responseObject.result.value!
                        success(resJson as! NSDictionary)
                    }
                    if responseObject.result.isFailure {
                        let error : Error = responseObject.result.error!
                        failure(error)
                    }
                }
                
            case .failure(let encodingError):
                failure(encodingError)
                break
            }
        }
    }
    
    
    func requestPOSTChatImageURL(_ strURL : String, params : [String : Any]?,image : [UIImage],uniqueId: String, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void){
        let mainUrl : String = "\(self.BaseUrl)\(strURL)"
        //        SVProgressHUD.show()
        //        let imgData = UIImageJPEGRepresentation(image,1)
        //        Alamofire.upload(multipartFormData: { multipartFormData in
        //            // import image to request
        //             for img in image{
        //                multipartFormData.append(imageData, withName: "\(imageParamName)[]", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
        //            }
        //            for (key, value) in parameters {
        //                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
        //            }
        //        }, to: mainUrl,
        //
        //           encodingCompletion: { encodingResult in
        //            switch encodingResult {
        //            case .success(let upload, _, _):
        //                upload.responseJSON { response in
        //
        //                }
        //            case .failure(let error):
        //                print(error)
        //            }
        //
        //        })
        //
       // let imgData = image[0].compress(.medium)
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                for img in image{
                    var imgName = String(Date().millisecondsSince1970)
                    let imgData = img.compress(.medium)
                    MultipartFormData.append(imgData!, withName: "chat_media", fileName: "\(imgName).png", mimeType: "image/png")
                }
                for (key, value) in params! {
                    MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
                
        }, to: mainUrl) { (result) in
            //            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { responseObject in
                    if responseObject.result.isSuccess {
                        let resJson = responseObject.result.value!
                        success(resJson as! NSDictionary)
                    }
                    if responseObject.result.isFailure {
                        let error : Error = responseObject.result.error!
                        failure(error)
                    }
                }
                
            case .failure(let encodingError):
                failure(encodingError)
                break
            }
        }
    }
    
    func requestPOSTVideoURL(_ strURL : String, params : [String : AnyObject]?,video : Data,uniqueId: String, headers : [String : String]?, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void){
        
        let mainUrl : String = "\(self.BaseUrl)\(strURL)"
        
        //        SVProgressHUD.show()
        
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                MultipartFormData.append(video, withName: "media", fileName: "\(uniqueId).mp4", mimeType: "video/mp4")
                
                for (key, value) in params! {
                    MultipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
                
        }, to: mainUrl) { (result) in
            //            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { responseObject in
                    if responseObject.result.isSuccess {
                        let resJson = responseObject.result.value!
                        success(resJson as! NSDictionary)
                    }
                    if responseObject.result.isFailure {
                        let error : Error = responseObject.result.error!
                        failure(error)
                    }
                }
                
            case .failure(let encodingError):
                failure(encodingError)
                break
            }
        }
    }
    func requestPOSTFileURL(_ strURL : String, params : [String : AnyObject]?,video : Data,uniqueId: String, headers : [String : String]?, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void){
        
        let mainUrl : String = "\(self.BaseUrl)\(strURL)"
        
        //        SVProgressHUD.show()
        
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                MultipartFormData.append(video, withName: "media", fileName: "\(uniqueId)", mimeType: "text/plain")
                
                for (key, value) in params! {
                    MultipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
                
        }, to: mainUrl) { (result) in
            //            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { responseObject in
                    if responseObject.result.isSuccess {
                        let resJson = responseObject.result.value!
                        success(resJson as! NSDictionary)
                    }
                    if responseObject.result.isFailure {
                        let error : Error = responseObject.result.error!
                        failure(error)
                    }
                }
                
            case .failure(let encodingError):
                failure(encodingError)
                break
            }
        }
    }
    
    func requestPOSTAudioURL(_ strURL : String, params : [String : AnyObject]?,audio : Data,uniqueId: String, headers : [String : String]?, success:@escaping (NSDictionary) -> Void, failure:@escaping (Error) -> Void){
        
        let mainUrl : String = "\(self.BaseUrl)\(strURL)"
        
        //        SVProgressHUD.show()
        
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                MultipartFormData.append(audio, withName: "media", fileName: "\(uniqueId).m4a", mimeType: "audio/m4a")
                
                for (key, value) in params! {
                    MultipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
                
        }, to: mainUrl) { (result) in
            //            SVProgressHUD.dismiss()
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { responseObject in
                    if responseObject.result.isSuccess {
                        let resJson = responseObject.result.value!
                        success(resJson as! NSDictionary)
                    }
                    if responseObject.result.isFailure {
                        let error : Error = responseObject.result.error!
                        failure(error)
                    }
                }
                
            case .failure(let encodingError):
                failure(encodingError)
                break
            }
        }
    }
}
