//
//  FirebaseFirestoreManager.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 11/02/21.
//

import Foundation
import FirebaseStorage


final class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    private let rootRef = Storage.storage().reference()
    
    
    func uploadImage(conversationId: String, image: UIImage, completion: @escaping((URL?) -> Void)) {
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        let imageName = "\(conversationId) + \(dateString).jpeg"
        
        let imageRef = rootRef.child("/chats/").child(conversationId).child(imageName)
        imageRef.putData(data, metadata: nil) { (metaData, error) in
            guard error == nil else {
                return
            }
            print("In Here. Got the download url!!!!")
            imageRef.downloadURL { (url, error) in
                if let downloadUrl = url {
                    completion(downloadUrl)
                }
            }
        }
        
        
    }
}

