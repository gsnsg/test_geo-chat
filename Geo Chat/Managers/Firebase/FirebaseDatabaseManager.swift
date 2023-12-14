//
//  FirebaseDatabaseManager.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI
import Firebase

final class FirebaseDatabaseManager {
    static let shared = FirebaseDatabaseManager()
    
    private var ref = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
           var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
           safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
           return safeEmail
    }
    
    func usernameExists(_ username: String, completion: @escaping ((Bool) -> Void)) {
        self.ref.child("/active_usernames/\(username)").observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    
    func getUserName(forEmail emailAddress: String, completion: @escaping ((String, String?) -> Void)) {
        let safeEmailAddress = Self.safeEmail(emailAddress: emailAddress)
        ref.child("/users/\(safeEmailAddress)/username").observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                completion("", "User not found!")
                return
            }
            guard let username = snapshot.value as? String else {
                completion("", "Unable to decode snapshot")
                return
            }
            completion(username, nil)
        }
    }
    
    
    func addUserObject(username: String, emailAddress: String, completion: @escaping((String?) -> Void)) {
        guard let currentUser = Firebase.Auth.auth().currentUser else {
            completion("Account created but failed to get current user")
            return
        }
        let safeEmailId = Self.safeEmail(emailAddress: emailAddress)
        ref.child("/users/\(safeEmailId)/").updateChildValues(["uid": currentUser.uid, "email": emailAddress, "username": username]) { (error, reference) in
            
            guard error == nil else {
                completion(error!.localizedDescription)
                return
            }
        }
        
        ref.child("active_usernames/\(username)").updateChildValues(["email": emailAddress]) { (error, reference) in
            guard error == nil else {
                completion(error!.localizedDescription)
                return
            }
            
            FirebaseManager.shared.setUserDefaults(username: username, email: emailAddress, safeEmail: safeEmailId)
            
            completion(nil)
            
        }
    }
    
    
    /// Get Conversation id for two users if exists else creates one
    func getConversationID(sender: String, receiver: String, completion: @escaping ((String) -> Void)) {
        let names = Array([sender, receiver]).sorted(by: <)
        let conversationId = names[0] + " "  +  names[1]
        ref.child("chats/\(sender)/\(receiver)/id").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if snapshot.exists() {
                print("Got ! \(snapshot.value!)")
                completion(conversationId)
            } else {
                // Create a new comnversation Id for both the users
                self?.ref.child("chats/\(sender)/\(receiver)").updateChildValues(["id" : conversationId]) { (error, ref) in
                    guard error == nil else {
                        print("Error creating conversation id Sender/Receiver")
                        return
                    }
                    self?.ref.child("chats/\(receiver)/\(sender)").updateChildValues(["id" : conversationId]) { (error, ref) in
                        guard error == nil else {
                            print("Error creating conversation id Receiver/Sender")
                            return
                        }
                        print("\(sender), \(receiver), \(conversationId)")
                        completion(conversationId)
                        
                    }
                    
                }
            }
        }
    }
    
    
    
    
}
