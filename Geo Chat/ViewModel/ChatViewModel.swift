//
//  ChatViewModel.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 11/02/21.
//

import Foundation
import Firebase
import UIKit



class ChatViewModel: ObservableObject {
    
    var conversationId: String = ""
    var receiver:String = ""
    var sender:String = ""
    
    
    @Published var messages: [Message] = []
    
    private var ref = Database.database().reference()
    
    init(sender: String, receiver: String) {
        self.sender = sender
        self.receiver = receiver
        FirebaseDatabaseManager.shared.getConversationID(sender: sender, receiver: receiver) { [weak self] (conversationId) in
            self?.conversationId = conversationId
            self?.startListening()
        }
        
        
    }
    
    
    func startListening() {
        print("Listening at : messages/\(conversationId)/")
        ref.child("messages/\(conversationId)/").observe(.value) { [weak self] (snapshot) in
            if snapshot.exists() {
                if let data = snapshot.value as? [String : Any] {
                    self?.messages.removeAll()
                    let sortedKeys = Array(data.keys).sorted(by: <)
                    sortedKeys.forEach { (key) in
                        if let messageDict = data[key] as? NSDictionary {
                            let newMessage = Message(text: messageDict["text"] as! String, image_url:  messageDict["image_url"] as! String, message_type:  messageDict["message_type"] as! String, sender:  messageDict["sender"] as! String)
                            self?.messages.append(newMessage)
                        }
                    }
                }
            } else {
                print("Nope Nada!")
            }
        }
    }
    
    func stopListening() {
        print("Stopped Listening, \(conversationId)")
        ref.child("messages/\(conversationId)/").removeAllObservers()
    }
    func sendMessage(text: String, image_url: String, messageType: MessageType) {
        if messageType == .text && text.count == 0 {
            return
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        ref.child("messages/\(conversationId)/\(dateString)/").updateChildValues(["timestamp": dateString,
                                                                                    "text": text,
                                                                                  "message_type": messageType.rawValue,
                                                                                  "sender": sender,
                                                                                  "image_url": image_url]) { (error, ref) in
            guard error == nil else {
                print("Error Sending Message")
                return
            }
        }
    }
    
    
    func uploadImage(image: UIImage) {
        FirebaseStorageManager.shared.uploadImage(conversationId: conversationId, image: image) { [weak self] (url) in
            if url != nil {
                print("Url got it!!!!!")
                self?.sendMessage(text: "", image_url: url!.absoluteString, messageType: .image)
                print("Image Uploaded!")
            }
        }
    }
    
    
    
}
