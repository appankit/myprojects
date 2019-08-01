
import Foundation
import CoreData

class CoreDataStack {
    
    static var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    static var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle(for: CoreDataStack.self).url(forResource: "Clifting", withExtension: "momd")! // type your database name here..
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("Clifting.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(value: true as Bool), NSInferMappingModelAutomaticallyOption: NSNumber(value: true as Bool)]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    static var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<RelationshipUserList> {
        return NSFetchRequest<RelationshipUserList>(entityName: "RelationshipUserList")
    }
    @nonobjc public class func createFetchRequestForFling() -> NSFetchRequest<FlingUserList> {
        return NSFetchRequest<FlingUserList>(entityName: "FlingUserList")
    }
    
    @nonobjc public class func createFetchRequestForConversation() -> NSFetchRequest<Conversions> {
        return NSFetchRequest<Conversions>(entityName: "Conversions")
    }
    
    static func checkConversationExist(id: String) -> Bool
    {
        let request = NSFetchRequest<Conversions>(entityName: "Conversions")
        request.predicate = NSPredicate(format: "unique_chat_id == %@", id)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                return true
            }
            return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    static func addDataToConversation(data: Message,reading_status: String){
        
        if !checkConversationExist(id: data.unique_chat_id){
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Conversions", into: managedObjectContext) as! Conversions
            obj.chat_id = Int32(data.chat_id)
            obj.conversion_id = Int32(data.conversion_id)
            obj.send_by = Int32(data.sender_id)
            obj.received_by = Int32(data.receiver_id)
            obj.last_message = data.chat_message
            obj.modified_date = data.created_date
            obj.user_id = Int32(data.user_id)
            obj.is_read = reading_status
            //  obj.other_user_id = Int32(data.otherUserId!)
            obj.unique_chat_id = data.unique_chat_id
            obj.reading_status = reading_status
            obj.messageType = data.message_type
            obj.modified_date = String(describing: data.created_date) ///convertDateAccordingDeviceTimeString(dategiven: data.created_date)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let yourDate: Date? = formatter.date(from: String(describing: data.created_date))
            formatter.dateFormat = "dd/MM/yyyy" // yyyy-MM-dd"
            let myStringafd = formatter.string(from: yourDate!)//1554788500030377
            obj.dateForSection = myStringafd//tomorrow?.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
            obj.other_user_id = Int32(data.other_user_id)
            obj.localmedianame = data.localmedianame
            obj.medianame =  data.medianame
            obj.me = Int16(data.me)
            
            print("Inserted successfully")
            saveContext()
        }
    }
    
    static func UpdateMarkAsRead(senderId:Int)
    {
        // let predicate = NSPredicate(format:"((senderid == %d or receiverid) and status == %d)",senderId, senderId,0)
        let predicate = NSPredicate(format:"((send_by == %d or received_by == %d) and is_read == %@)",senderId,senderId,"0")
        let fetchRequest = NSBatchUpdateRequest(entityName: "Conversions")
        fetchRequest.propertiesToUpdate = ["is_read":"1"]
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .updatedObjectsCountResultType
        
        do {
            let result = try  CoreDataStack.managedObjectContext.execute(fetchRequest) as! NSBatchUpdateResult
            //Will print the number of rows affected/updated
            print(result)
            print(predicate)
            print("Success")
        }catch {
        }
    }
    
    
    static func getAllUnReadMessagecount(senderId:Int , receiverId:Int) -> Int
    {
        let predicate = NSPredicate(format:"(((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d)) and is_read == %@)", senderId,receiverId,receiverId,senderId,"0")
        //        let predicate = NSPredicate(format:"(((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d)) and (user_id != %d or user_id != %d ) and is_read == %@)", senderId,receiverId,receiverId,senderId,senderId,receiverId,"0")
        let objContext = CoreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<Conversions>(entityName: "Conversions")
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Conversions", in: objContext)!
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        let sortDescriptor = NSSortDescriptor(key: "chat_id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do{
            let results = try  CoreDataStack.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Conversions]
            return results.count
        }
        catch
        {
            return 0
        }
    }
    
    static func getAllUnReadMessagecount() -> Int
    {
        let predicate = NSPredicate(format:"is_read == %@", "0")
        //        let predicate = NSPredicate(format:"(((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d)) and (user_id != %d or user_id != %d ) and is_read == %@)", senderId,receiverId,receiverId,senderId,senderId,receiverId,"0")
        let objContext = CoreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<Conversions>(entityName: "Conversions")
        fetchRequest.returnsObjectsAsFaults = true
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Conversions", in: objContext)!
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity
        let sortDescriptor = NSSortDescriptor(key: "chat_id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do{
            let results = try  CoreDataStack.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Conversions]
            return results.count
        }
        catch
        {
            return 0
        }
    }
    
    static func updateChatData(data: Message,reading_status: String){
        let request = NSFetchRequest<Conversions>(entityName: "Conversions")
        request.predicate = NSPredicate(format: "unique_chat_id == %@", data.unique_chat_id )
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                let obj = result[0]
                if data.message_type == "IMAGE"{
                    obj.medianame = data.medianame
                }
                obj.conversion_id = Int32(data.conversion_id)
                obj.chat_id = Int32(data.chat_id)
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        saveContext()
    }
    
    
    
    static func addDataToRecentConversationList(data: Message,reading_status: String){
        checkRecentConversationExistAndDelete(senderId: Int32(data.sender_id), receiverId: Int32(data.receiver_id))
        // if !checkRecentConversationExist(senderId: Int32(data.sender_id), receiverId: Int32(data.receiver_id)){
        let obj = NSEntityDescription.insertNewObject(forEntityName: "RecentConversationList", into: managedObjectContext) as! RecentConversationList
        obj.conversion_id = Int32(data.conversion_id)
        obj.send_by = Int32(data.sender_id)
        obj.received_by = Int32(data.receiver_id)
        obj.last_message = data.last_message
        obj.modified_date = String(describing: data.created_date)
        obj.other_user_first_name = data.other_user_first_name
        obj.other_user_last_name = data.other_user_last_name
        obj.profile_pics = data.profile_pics
        obj.modified_date = data.created_date
        obj.is_deactivate = data.is_deactivate
        obj.modified_date = String(describing: data.created_date)
        ///convertDateAccordingDeviceTimeString(dategiven: data.created_date)
        //            let formatter = DateFormatter()
        //            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //            let yourDate: Date? = formatter.date(from: String(describing: data.created_date))
        //            formatter.dateFormat = "dd/MM/yyyy" // yyyy-MM-dd"
        //            let myStringafd = formatter.string(from: yourDate!)
        
        print("Inserted successfully")
        saveContext()
        //        }else{
        //            let request = NSFetchRequest<RecentConversationList>(entityName: "RecentConversationList")
        //            request.predicate = NSPredicate(format: "((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d))",Int32(data.sender_id),Int32(data.receiver_id),Int32(data.receiver_id),Int32(data.sender_id))
        //            do{
        //                let result = try CoreDataStack.managedObjectContext.fetch(request)
        //                if result.count > 0{
        //                    let obj = result[0]
        //                    let objUser = UserDefaultManager.getCustomObjFromUserDefaults(key: UD_UserData) as! User
        //                    if objUser.userId != data.receiver_id{
        //                        obj.other_user_first_name = data.other_user_first_name
        //                        obj.other_user_last_name = data.other_user_last_name
        //                        obj.profile_pics = data.profile_pics
        //                    }
        //                    obj.conversion_id = Int32(data.conversion_id)
        //                    obj.send_by = Int32(data.sender_id)
        //                    obj.received_by = Int32(data.receiver_id)
        //                    obj.last_message = data.last_message
        //                    obj.modified_date = data.created_date
        //                    obj.modified_date = String(describing: data.created_date)
        //
        //                }
        //            } catch let error as NSError {
        //                print("Could not fetch \(error), \(error.userInfo)")
        //            }
        //            saveContext()
        //        }
    }
    
    
    static func deleteRecentConversation(conversationId: Int16)
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentConversationList")
        request.predicate = NSPredicate(format: "conversion_id == %d",conversationId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CoreDataStack.managedObjectContext.execute(deleteRequest)
            try CoreDataStack.managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
        saveContext()
    }
    
    static func deleteConversation(conversationId: Int16)
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversions")
        request.predicate = NSPredicate(format: "conversion_id == %d",conversationId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CoreDataStack.managedObjectContext.execute(deleteRequest)
            try CoreDataStack.managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
        saveContext()
    }
    static func deleteSingleMessage(chatId: Int16)
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversions")
        request.predicate = NSPredicate(format: "chat_id == %d",chatId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CoreDataStack.managedObjectContext.execute(deleteRequest)
            try CoreDataStack.managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
        saveContext()
    }
    
    //chat_id
    
    static func checkRecentConversationExistAndDelete(senderId: Int32,receiverId: Int32)
    {
        //        let request = NSFetchRequest<RecentConversationList>(entityName: "RecentConversationList")
        //        request.predicate = NSPredicate(format: "((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d))",senderId,receiverId,receiverId,senderId)
        //        do{
        //            let result = try CoreDataStack.managedObjectContext.fetch(request)
        //            if result.count > 0{
        //                return true
        //            }
        //            return false
        //        } catch let error as NSError {
        //            print("Could not fetch \(error), \(error.userInfo)")
        //        }
        //        return false
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentConversationList")
        request.predicate = NSPredicate(format: "((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d))",senderId,receiverId,receiverId,senderId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CoreDataStack.managedObjectContext.execute(deleteRequest)
            try CoreDataStack.managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
        saveContext()
    }
    
    
    // MARK: - Core Data Saving support
    
    static func fetchFlingData(userId: Int32) -> NSFetchedResultsController<NSFetchRequestResult>{
        var fetchedResultsController: NSFetchedResultsController<FlingUserList>!
        let request = createFetchRequestForFling()
        let sort = NSSortDescriptor(key: "created_date", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "request_status == %@ And own_id == %d", "0",userId)
        // request.fetchBatchSize = 20
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        //  fetchedResultsController.fetchRequest.predicate = withPredicate
        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        
    }
    
    
    
    static func deleteExpiredRelationshipData(){
        let request = NSFetchRequest<RelationshipUserList>(entityName: "RelationshipUserList")
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                for item in result{
                    var remainingHoursToExpire =  Date().getDifferentBetweenDatesInHours(date: (convertDateAccordingDeviceTime(dategiven: item.created_date!)))
                    if CLIFT_EXPIRE{
                        
                        if remainingHoursToExpire > 24 {
                            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
                            request.predicate = NSPredicate(format: "selection_id == %d", item.selection_id)
                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                            do {
                                try CoreDataStack.managedObjectContext.execute(deleteRequest)
                                try CoreDataStack.managedObjectContext.save()
                            } catch {
                                print ("There was an error")
                            }
                            saveContext()
                        }
                        
                    }else{
                        //                        let objSub = getSubscriptionPlan(key: UD_CliftBoost)
                        //                        if objSub != nil {
                        //                            let obj = objSub
                        //                            if obj?.type == "Clifting_Boost_Weekly" {
                        //                                let date = obj!.date
                        //                                let diff = date.getDifferentInHours()
                        //                                if diff > 168 { // For Daily
                        //                                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
                        //                                    request.predicate = NSPredicate(format: "selection_id == %d", item.selection_id)
                        //                                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                        //                                    do {
                        //                                        try CoreDataStack.managedObjectContext.execute(deleteRequest)
                        //                                        try CoreDataStack.managedObjectContext.save()
                        //                                    } catch {
                        //                                        print ("There was an error")
                        //                                    }
                        //                                    UserDefaultManager.removeCustomObject(key: UD_CliftBoost)
                        //                                    saveContext()
                        //                                }
                        //                                print("difference:",date.getDifferentInHours())
                        //                            }else{
                        //                                let date = obj!.date
                        //                                let diffMonth = date.getDifferentInMonth()
                        //                                if diffMonth > 1 { // For Monthly
                        //                                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
                        //                                    request.predicate = NSPredicate(format: "selection_id == %d", item.selection_id)
                        //                                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                        //                                    do {
                        //                                        try CoreDataStack.managedObjectContext.execute(deleteRequest)
                        //                                        try CoreDataStack.managedObjectContext.save()
                        //                                    } catch {
                        //                                        print ("There was an error")
                        //                                    }
                        //                                    UserDefaultManager.removeCustomObject(key: UD_CliftBoost)
                        //                                    saveContext()
                        //                                }
                        //                            }
                        //                        }
                    }
                    
                    //                    let objSub = getSubscriptionPlan(key: UD_CliftBoost)
                    //                    if objSub != nil {
                    //                        let obj = objSub
                    //                        if obj?.type == "Clifting_Boost_Weekly" {
                    //                            let date = obj!.date
                    //                            let diff = date.getDifferentInHours()
                    //                            if diff > 168 { // For Daily
                    //                                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
                    //                                request.predicate = NSPredicate(format: "selection_id == %d", item.selection_id)
                    //                                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                    //                                do {
                    //                                    try CoreDataStack.managedObjectContext.execute(deleteRequest)
                    //                                    try CoreDataStack.managedObjectContext.save()
                    //                                } catch {
                    //                                    print ("There was an error")
                    //                                }
                    //                                UserDefaultManager.removeCustomObject(key: UD_CliftBoost)
                    //                                saveContext()
                    //                            }
                    //                            print("difference:",date.getDifferentInHours())
                    //                        }else{
                    //                            let date = obj!.date
                    //                            let diffMonth = date.getDifferentInMonth()
                    //                            if diffMonth > 1 { // For Monthly
                    //                                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
                    //                                request.predicate = NSPredicate(format: "selection_id == %d", item.selection_id)
                    //                                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                    //                                do {
                    //                                    try CoreDataStack.managedObjectContext.execute(deleteRequest)
                    //                                    try CoreDataStack.managedObjectContext.save()
                    //                                } catch {
                    //                                    print ("There was an error")
                    //                                }
                    //                                UserDefaultManager.removeCustomObject(key: UD_CliftBoost)
                    //                                saveContext()
                    //                            }
                    //                        }
                    //                    }
                    //else{
                    //                        if remainingHoursToExpire > 24 {
                    //                            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
                    //                            request.predicate = NSPredicate(format: "selection_id == %d", item.selection_id)
                    //                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                    //                            do {
                    //                                try CoreDataStack.managedObjectContext.execute(deleteRequest)
                    //                                try CoreDataStack.managedObjectContext.save()
                    //                            } catch {
                    //                                print ("There was an error")
                    //                            }
                    //                            saveContext()
                    //                        }
                    //                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        saveContext()
    }
    
    static func fetchLastChatId() -> Int32{
        
        let request = NSFetchRequest<Conversions>(entityName: "Conversions")
        let sort = NSSortDescriptor(key: "chat_id", ascending: false)
        let predicate = NSPredicate(format:"(chat_id != %d)", 0)
        request.sortDescriptors = [sort]
        request.predicate = predicate
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                var obj = result[0]
                return obj.chat_id
                // return true
            }
            //  return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return 0
    }
    
    static func fetchChatData(own_id : Int32, sender_id: Int32 ) -> [Message]{
        var arrChat = [Message]()
        let request = NSFetchRequest<Conversions>(entityName: "Conversions")
        let predicate = NSPredicate(format:"((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d))", own_id,sender_id,sender_id,own_id)//NSPredicate(format:"user_id == %d AND other_user_id == %d", own_id,sender_id)
        let sort = NSSortDescriptor(key: "chat_id", ascending: true)
        //request.propertiesToGroupBy = ["modified_date"]
        // request.propertiesToFetch = ["order_num","cust_name"]
        // request.resultType = .dictionaryResultType
        request.sortDescriptors = [sort]
        request.predicate = predicate
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                for item in result{
                    let message = Message()
                    message.chat_id = Int(item.chat_id)
                    message.conversion_id = Int(item.conversion_id)
                    message.sender_id = Int(item.send_by)
                    message.receiver_id = Int(item.received_by)
                    message.chat_message = item.last_message ?? ""
                    message.unique_chat_id = item.unique_chat_id ?? ""
                    message.created_date = item.modified_date ?? ""
                    message.dateForSection = item.dateForSection ?? ""
                    message.user_id = Int(item.user_id)
                    message.localmedianame = item.localmedianame ?? ""
                    message.medianame = item.medianame ?? ""
                    message.message_type = item.messageType ?? ""
                    arrChat.append(message)
                }
                print(result)
                return arrChat
                // return true
            }
            //  return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return arrChat
    }
    
    static func fetchTotalChatData(own_id : Int32, sender_id: Int32 ) -> Int{
        var arrChat = [Message]()
        let request = NSFetchRequest<Conversions>(entityName: "Conversions")
        let predicate = NSPredicate(format:"((send_by == %d and received_by == %d) or (send_by == %d and received_by == %d))", own_id,sender_id,sender_id,own_id)//NSPredicate(format:"user_id == %d AND other_user_id == %d", own_id,sender_id)
        request.predicate = predicate
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            return result.count
            // return true
            //  return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return 0
    }
    
    
    
    static func getMessageByChatId(chat_id: Int32) -> Message
    {
        var arrChat = Message()
        let request = NSFetchRequest<Conversions>(entityName: "Conversions")
        let predicate = NSPredicate(format:"chat_id == %d",chat_id)//NSPredicate(format:"user_id == %d AND other_user_id == %d", own_id,sender_id)
        request.predicate = predicate
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                for item in result{
                    let message = Message()
                    message.chat_id = Int(item.chat_id)
                    message.conversion_id = Int(item.conversion_id)
                    message.sender_id = Int(item.send_by)
                    message.receiver_id = Int(item.received_by)
                    message.chat_message = item.last_message ?? ""
                    message.unique_chat_id = item.unique_chat_id ?? ""
                    message.created_date =  item.modified_date ?? "" //myStringafd//tomorrow?.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
                    message.dateForSection = item.dateForSection ?? ""
                    message.user_id = Int(item.user_id)
                    message.localmedianame = item.localmedianame ?? ""
                    message.medianame = item.medianame ?? ""
                    message.message_type = item.messageType ?? ""
                    arrChat = message
                }
                print(result)
                return arrChat
                // return true
            }
            //  return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return arrChat
    }
    //    static func fetchRelationshipData(userId: Int32) -> NSFetchedResultsController<NSFetchRequestResult>{
    //        var fetchedResultsController: NSFetchedResultsController<RelationshipUserList>!
    //        let request = createFetchRequest()
    //        let sort = NSSortDescriptor(key: "created_date", ascending: true)
    //        request.sortDescriptors = [sort]
    //        request.predicate = NSPredicate(format: "request_status == %@ and own_id == %d", "0",userId)
    //        // request.fetchBatchSize = 20
    //        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    //        //  fetchedResultsController.fetchRequest.predicate = withPredicate
    //        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
    //    }
    
    static func fetchRelationshipData(userId: Int32) -> [RelationshipUserList]{
        var data = [RelationshipUserList]()
        let request = NSFetchRequest<RelationshipUserList>(entityName: "RelationshipUserList")
        let sort = NSSortDescriptor(key: "created_date", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "request_status == %@ and own_id == %d", "0",userId)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                return result
                // return true
            }
            return data
            
            //  return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return data
    }
    
    //    static func fetchFlingData(userId: Int32) -> NSFetchedResultsController<NSFetchRequestResult>{
    //        var fetchedResultsController: NSFetchedResultsController<FlingUserList>!
    //        let request = createFetchRequestForFling()
    //        let sort = NSSortDescriptor(key: "created_date", ascending: true)
    //        request.sortDescriptors = [sort]
    //        request.predicate = NSPredicate(format: "request_status == %@ And own_id == %d", "0",userId)
    //        // request.fetchBatchSize = 20
    //        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    //        //  fetchedResultsController.fetchRequest.predicate = withPredicate
    //        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
    //
    //    }
    
    static func flingUserData(userId: Int32) -> [FlingUserList] {
        var data = [FlingUserList]()
        let request = NSFetchRequest<FlingUserList>(entityName: "FlingUserList")
        let sort = NSSortDescriptor(key: "created_date", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "request_status == %@ and own_id == %d", "0",userId)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                return result
                // return true
            }
            return data
            
            //  return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return data
    }
    
    static func fetchListOfRecentChatUser(own_id : Int32) -> [Message]{
        var arrChat = [Message]()
        let request = NSFetchRequest<RecentConversationList>(entityName: "RecentConversationList")
        let predicate = NSPredicate(format:"(send_by == %d or received_by == %d)", own_id,own_id)//NSPredicate(format:"user_id == %d AND other_user_id == %d", own_id,sender_id)
        let sort = NSSortDescriptor(key: "modified_date", ascending: false)
        //        request.propertiesToGroupBy = ["modified_date"]
        //        request.propertiesToFetch = ["order_num","cust_name"]
        //        request.resultType = .dictionaryResultType
        request.sortDescriptors = [sort]
        request.predicate = predicate
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                for item in result{
                    let message = Message()
                    message.conversion_id = Int(item.conversion_id)
                    message.sender_id = Int(item.send_by)
                    message.receiver_id = Int(item.received_by)
                    message.last_message = item.last_message ?? ""
                    message.created_date = item.modified_date ?? ""
                    message.other_user_first_name = item.other_user_first_name ?? ""
                    message.other_user_last_name = item.other_user_last_name ?? ""
                    message.profile_pics = item.profile_pics ?? ""
                    message.is_deactivate = item.is_deactivate ?? ""
                    arrChat.append(message)
                }
                print(result)
                return arrChat
                // return true
            }
            //  return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return arrChat
    }
    
    
    static func fetchRecentConversationData(own_id : Int32) -> NSFetchedResultsController<NSFetchRequestResult>{
        var fetchedResultsController: NSFetchedResultsController<RecentConversationList>!
        let request = NSFetchRequest<RecentConversationList>(entityName: "RecentConversationList")
        let predicate = NSPredicate(format:"(send_by == %d or received_by == %d)", own_id,own_id)//NSPredicate(format:"user_id == %d AND other_user_id == %d", own_id,sender_id)
        let sort = NSSortDescriptor(key: "modified_date", ascending: true)
        //        request.propertiesToGroupBy = ["modified_date"]
        //        request.propertiesToFetch = ["order_num","cust_name"]
        //        request.resultType = .dictionaryResultType
        request.sortDescriptors = [sort]
        request.predicate = predicate
        //        let request = createFetchRequestForConversation()
        //        let sort = NSSortDescriptor(key: "modified_date", ascending: true)
        //request.propertiesToGroupBy = ["modified_date"]
        // request.propertiesToFetch = ["order_num","cust_name"]
        // request.resultType = .dictionaryResultType
        // request.sortDescriptors = [sort]
        // request.predicate = NSPredicate(format: "request_status == %@", "1")
        // request.fetchBatchSize = 20
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        //  fetchedResultsController.fetchRequest.predicate = withPredicate
        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
    }
    
    
    static func fetchConversationData() -> NSFetchedResultsController<NSFetchRequestResult>{
        var fetchedResultsController: NSFetchedResultsController<Conversions>!
        let request = createFetchRequestForConversation()
        let sort = NSSortDescriptor(key: "modified_date", ascending: true)
        //request.propertiesToGroupBy = ["modified_date"]
        // request.propertiesToFetch = ["order_num","cust_name"]
        // request.resultType = .dictionaryResultType
        request.sortDescriptors = [sort]
        // request.predicate = NSPredicate(format: "request_status == %@", "1")
        // request.fetchBatchSize = 20
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        //  fetchedResultsController.fetchRequest.predicate = withPredicate
        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        
    }
    
    static func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    static func checkRelationshipUserExist(id: Int32) -> Bool
    {
        let request = NSFetchRequest<RelationshipUserList>(entityName: "RelationshipUserList")
        request.predicate = NSPredicate(format: "selection_id == %d", id)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                return true
            }
            return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    
    static func addDataToRelationshipUserlist(data: UserListing, own_id: Int){
        if !checkRelationshipUserExist(id: Int32(data.selection_id!)){
            let obj = NSEntityDescription.insertNewObject(forEntityName: "RelationshipUserList", into: managedObjectContext) as! RelationshipUserList
            obj.selection_id = Int32(data.selection_id!)
            obj.request_status = data.request_status!
            obj.user_id = Int32(data.userId ?? 0)
            obj.firstname = data.firstname ?? ""
            obj.lastname = data.lastname ?? ""
            obj.own_id = Int32(own_id)
            if let addr = data.address{
                obj.address = addr
            }
            let remainingHoursToExpire =  Date().getDifferentBetweenDatesInHours(date: (convertDateAccordingDeviceTime(dategiven: data.created_date!)))
            obj.remainingExpirationTime = Int16(remainingHoursToExpire)
            obj.created_date = data.created_date!
            if data.profile_pics?.count ?? 0 > 0{
                obj.profile_pics = data.profile_pics?[0].mediaName!
            }
            saveContext()
        }else{
            let request = NSFetchRequest<RelationshipUserList>(entityName: "RelationshipUserList")
            request.predicate = NSPredicate(format: "selection_id == %d", data.selection_id ?? 0)
            do{
                let result = try CoreDataStack.managedObjectContext.fetch(request)
                if result.count > 0{
                    let obj = result[0]
                        as! RelationshipUserList
                    obj.selection_id = Int32(data.selection_id!)
                    obj.request_status = data.request_status!
                    obj.user_id = Int32(data.userId ?? 0)
                    obj.firstname = data.firstname ?? ""
                    obj.lastname = data.lastname ?? ""
                    obj.own_id = Int32(own_id)
                    if let addr = data.address{
                        obj.address = addr
                    }
                    obj.created_date = data.created_date!
                    if data.profile_pics?.count ?? 0 > 0{
                        obj.profile_pics = data.profile_pics?[0].mediaName!
                    }else{
                        obj.profile_pics = ""
                    }
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            saveContext()
        }
    }
    
    static func updateRelationShpiExpirationTime(){
        let request = NSFetchRequest<RelationshipUserList>(entityName: "RelationshipUserList")
        //request.predicate = NSPredicate(format: "selection_id == %d", data.selection_id ?? 0)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                for item in result{
                    let remainingHoursToExpire =  Date().getDifferentBetweenDatesInHours(date: (convertDateAccordingDeviceTime(dategiven: item.created_date!)))
                    item.remainingExpirationTime = Int16(remainingHoursToExpire)
                    saveContext()
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    static func deleteRelationshipUserlist(selection_id: Int32){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
        request.predicate = NSPredicate(format: "selection_id == %d", selection_id)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CoreDataStack.managedObjectContext.execute(deleteRequest)
            try CoreDataStack.managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
        saveContext()
    }
    
    static func relationshipUserExist(selection_id: Int32)-> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RelationshipUserList")
        request.predicate = NSPredicate(format: "selection_id == %d", selection_id)
        
        do {
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                return true
            }
            return false
        } catch {
            print ("There was an error")
        }
       return false
    }
    
    static func updateRelationshipUserlist(status: String,selection_id: Int32){
        let request = NSFetchRequest<RelationshipUserList>(entityName: "RelationshipUserList")
        request.predicate = NSPredicate(format: "selection_id == %d", selection_id)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                let obj = result[0]
                obj.request_status = status
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        saveContext()
        
    }
    
    static func checkFlingUserExist(id: Int32) -> Bool
    {
        let request = NSFetchRequest<FlingUserList>(entityName: "FlingUserList")
        request.predicate = NSPredicate(format: "selection_id == %d", id)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                return true
            }
            return false
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    
    static func addDataToFlingUserlist(data: UserListing, own_id: Int){
        
        if !checkFlingUserExist(id: Int32(data.selection_id!)){
            let obj = NSEntityDescription.insertNewObject(forEntityName: "FlingUserList", into: managedObjectContext) as! FlingUserList
            obj.selection_id = Int32(data.selection_id!)
            obj.request_status = data.request_status!
            obj.user_id = Int32(data.userId!)
            obj.own_id = Int32(own_id)
            if let fname = data.firstname{
                obj.firstname = fname
            }
            if let lName = data.lastname{
                obj.lastname = lName
            }
            if let addr = data.address{
                obj.address = addr
            }
            obj.created_date = data.created_date!
            if data.profile_pics?.count ?? 0 > 0{
                obj.profile_pics = data.profile_pics?[0].mediaName!
            }
            saveContext()
        }else{
            let request = NSFetchRequest<FlingUserList>(entityName: "FlingUserList")
            request.predicate = NSPredicate(format: "selection_id == %d", data.selection_id!)
            do{
                let result = try CoreDataStack.managedObjectContext.fetch(request)
                if result.count > 0{
                    let obj = result[0]
                    obj.selection_id = Int32(data.selection_id!)
                    obj.request_status = data.request_status!
                    obj.user_id = Int32(data.userId!)
                    obj.own_id = Int32(own_id)
                    if let fname = data.firstname{
                        obj.firstname = fname
                    }
                    if let lName = data.lastname{
                        obj.lastname = lName
                    }
                    if let addr = data.address{
                        obj.address = addr
                    }
                    obj.created_date = data.created_date!
                    if data.profile_pics?.count ?? 0 > 0{
                        obj.profile_pics = data.profile_pics?[0].mediaName!
                    }else{
                        obj.profile_pics = ""
                    }
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            saveContext()
        }
    }
    
    static func deleteFlingUser(selection_id: Int32){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FlingUserList")
        request.predicate = NSPredicate(format: "selection_id == %d", selection_id)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CoreDataStack.managedObjectContext.execute(deleteRequest)
            try CoreDataStack.managedObjectContext.save()
        } catch {
            print ("There was an error")
        }
        saveContext()
    }
    static func updateFlingStatus(status: String,selection_id: Int32){
        let request = NSFetchRequest<FlingUserList>(entityName: "FlingUserList")
        request.predicate = NSPredicate(format: "selection_id == %d", selection_id)
        do{
            let result = try CoreDataStack.managedObjectContext.fetch(request)
            if result.count > 0{
                let obj = result[0]
                obj.request_status = status
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        saveContext()
    }
}
