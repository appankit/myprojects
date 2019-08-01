

import Foundation
import SwiftyJSON

public final class UserDetails: NSCoding,JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let status = "status"
    static let data = "data"
    static let message = "message"
    static let userToken = "userToken"
  }

  // MARK: Properties
  public var status: String?
  public var data: Data1?
  public var message: String?
  public var userToken: String?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(parameter : JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
    public required init(parameter json: JSON) {
    status = json[SerializationKeys.status].string
    data = Data1(json: json[SerializationKeys.data])
    message = json[SerializationKeys.message].string
    userToken = json[SerializationKeys.userToken].string
  }
    
    

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = status { dictionary[SerializationKeys.status] = value }
    if let value = data { dictionary[SerializationKeys.data] = value.dictionaryRepresentation() }
    if let value = message { dictionary[SerializationKeys.message] = value }
    if let value = userToken { dictionary[SerializationKeys.userToken] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? String
    self.data = aDecoder.decodeObject(forKey: SerializationKeys.data) as? Data1
    self.message = aDecoder.decodeObject(forKey: SerializationKeys.message) as? String
    self.userToken = aDecoder.decodeObject(forKey: SerializationKeys.userToken) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(status, forKey: SerializationKeys.status)
    aCoder.encode(data, forKey: SerializationKeys.data)
    aCoder.encode(message, forKey: SerializationKeys.message)
    aCoder.encode(userToken, forKey: SerializationKeys.userToken)
  }

}
