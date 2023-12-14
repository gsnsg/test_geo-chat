//
//  AppUser.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import Foundation

enum MessageType: String {
    case text = "text"
    case image = "image"
}

struct Message: Codable, Hashable {
    var text: String = ""
    var message_type: String = ""
    var sender: String = ""
    var image_url: String = ""
    
    init(text: String, image_url: String, message_type: String, sender: String) {
        self.text = text
        self.image_url = image_url
        self.message_type = message_type
        self.sender = sender
    }
}
