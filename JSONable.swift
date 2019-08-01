

import UIKit
import SwiftyJSON

extension JSON {
    func to<T>(type: T?) -> Any? {
        if let baseObj = type as? JSONable.Type {
            if self.type == .array {
                var arrObject: [Any] = []
                for obj in self.arrayValue {
                    let object = baseObj.init(parameter: obj)
                    arrObject.append(object!)
                }
                return arrObject
            } else {
                let object = baseObj.init(parameter: self)
                return object!
            }
        }
        return nil
    }
}
protocol JSONable {
    init?(parameter: JSON)
}

/*let data : NSDictionary = response.value(forKey: "data") as! NSDictionary
 let json = JSON(data)
 if let resData : User = json["User"].to(type: User.self) as? User {}*/
