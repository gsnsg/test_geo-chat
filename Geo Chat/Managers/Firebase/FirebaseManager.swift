//
//  FirebaseManager.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import Foundation


final class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    
    func setUserDefaults(username: String, email: String, safeEmail: String) {
        UserDefaults.standard.setValue(email, forKey: "email")
        UserDefaults.standard.setValue(safeEmail, forKey: "safe_email")
        UserDefaults.standard.setValue(username, forKey: "username")   
    }
    
    func removeUserDefaults() {
        UserDefaults.standard.setValue("", forKey: "email")
        UserDefaults.standard.setValue("", forKey: "safe_email")
        UserDefaults.standard.setValue("", forKey: "username")
    }
}
