//
//  FirebaseAuthManager.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI
import Firebase


final class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    
    func userNameExists(_ username: String) -> Bool {
        return false;
    }
    
    
    func checkEmailExists(_ emailAddress: String, completion: @escaping ((Bool) -> Void))  {
        Auth.auth().fetchSignInMethods(forEmail: emailAddress) { (signInMethods, error) in
            guard signInMethods != nil, error == nil else {
                completion(false)
                return;
            }
            if signInMethods!.count == 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    func createUserWith(username: String, email: String, password:String, completion: @escaping ((String?) -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                completion(error!.localizedDescription)
                return
            }
            
            FirebaseDatabaseManager.shared.addUserObject(username: username, emailAddress: email) { (error) in
                completion(error)
            }
        }
    }
    
    
    func loginUser(withEmail emailAddress: String, password: String, completion: @escaping ((String, String?) -> Void)) {
        Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
            guard error == nil else {
                completion("", error!.localizedDescription)
                return
            }
            
            FirebaseDatabaseManager.shared.getUserName(forEmail: emailAddress) { (username, error) in
                guard error == nil else {
                    completion(username, error)
                    return
                }
                let safeEmailAddress = FirebaseDatabaseManager.safeEmail(emailAddress: emailAddress)
                FirebaseManager.shared.setUserDefaults(username: username, email: emailAddress, safeEmail: safeEmailAddress)
                completion("", nil)
            }
        }
    }
    
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            FirebaseManager.shared.removeUserDefaults()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}
