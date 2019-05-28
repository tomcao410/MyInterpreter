//
//  File.swift
//  ChatApp
//
//  Created by Macbook on 4/16/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

//import UIKit
//import CoreData
//
//extension FriendsController {
//    
//    func setupData() {
//        clearData()
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        
//        if let context = delegate?.persistentContainer.viewContext {
//            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//            mark.name = "Mark Zuckerberg"
//            mark.profileImageName = "mark"
//
//            
//           let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//            steve.name = "Steve Jobs"
//            steve.profileImageName = "steve"
//
//            let bill = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//            bill.name = "Bill Clinton"
//            bill.profileImageName = "bill"
//            
//            let gandhi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//            gandhi.name = "Mahatma Gandhi"
//            gandhi.profileImageName = "gandhi"
//            
//            createMessage(text: "Good morning", friend: steve, minutesAgo: 60, context: context)
//            createMessage(text: "Your fb is dabezt", friend: mark, minutesAgo: 3, context: context)
//            createMessage(text: "You should buy iSomething, it is onsale now! Only 10000000000$, you will receive newest technology on the world. Hope you like it <3", friend: steve, minutesAgo: 50, context: context)
//            createMessage(text: "You're doing good, Trump", friend: bill, minutesAgo: 1, context: context)
//            createMessage(text: "Love, Peace, and Joy", friend: gandhi, minutesAgo: 60 * 24 * 10000, context: context)
//            createMessage(text: "Yes, totally looking for an expensive things like iSomething", friend: steve, minutesAgo: 40, context: context, isSender: true)
//            createMessage(text: "Totally understand that you want something to spend your money on, but you'll have to wait until 13th month of this years for the new release. Sorry but this is just what we do", friend: steve, minutesAgo: 30, context: context)
//            createMessage(text: "Okay, when i wait, can i buy galaxy fold?", friend: steve, minutesAgo: 29, context: context, isSender: true)
//            createMessage(text: "No! if you do that, you're not iFan", friend: steve, minutesAgo: 28, context: context)
//            createMessage(text: "Nah, i don't care, Galaxy Fold is super cool, i will buy it", friend: steve, minutesAgo: 27, context: context, isSender: true)
//            createMessage(text: "Hu hu hu", friend: steve, minutesAgo: 26, context: context)
//            createMessage(text: "Stop crying, okay, i with wait for the iSomething", friend: steve, minutesAgo: 26, context: context, isSender: true)
//            createMessage(text: "Yes, we love you!", friend: steve, minutesAgo: 25, context: context)
//            do {
//                try(context.save())
//            } catch let err {
//                print(err)
//            }
//            
////            messages = [message, messageSteve]
//        }
//        loadData()
//    }
//    
//    func clearData() {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        
//        if let context = delegate?.persistentContainer.viewContext{
//            let fetchRequestMessage = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//            let fetchRequestFriend = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
//            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestMessage)
//            let batchDeleteRequestFriend = NSBatchDeleteRequest(fetchRequest: fetchRequestFriend)
//            
//            do {
//                try context.execute(batchDeleteRequest)
//            } catch let err {
//                print(err)
//            }
//            
//            do {
//                try context.execute(batchDeleteRequestFriend)
//            } catch let err {
//                print(err)
//            }
//        }
//    }
//    
//    func createMessage(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) {
//        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
//        message.friend = friend
//        message.text = text
//        message.date = NSDate().addingTimeInterval(-minutesAgo*60)
//        message.isSender = isSender
//    }
//    
//    func loadData() {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        
//        if let context = delegate?.persistentContainer.viewContext{
//            
//            if let friends = fetchFriends(){
//                messages = [Message]()
//                for friend in friends {
//                    print(friend.name!)
//                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//                    fetchRequest.returnsObjectsAsFaults = false
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//                    if let friendName = friend.name {
//                     fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friendName)
//                    }
//                    fetchRequest.fetchLimit = 1
//                    do {
//                        let fetchMessages = try(context.fetch(fetchRequest)) as? [Message]
//                        messages?.append(contentsOf: fetchMessages!)
//                    } catch let err {
//                        print(err)
//                    }
//                }
//                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
//            }
//        }
//    }
//    
//    private func fetchFriends() -> [Friend]? {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        if let context = delegate?.persistentContainer.viewContext{
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
//            fetchRequest.returnsObjectsAsFaults = false
//            do {
//                return (try context.fetch(fetchRequest)) as? [Friend]
//            } catch let err{
//                print(err)
//            }
//        }
//        return nil
//    }
//}
