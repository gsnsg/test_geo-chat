//
//  MessageView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 10/02/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct Bubble: Shape {
    var sender: Bool
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, sender ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        return Path(path.cgPath)
    }
}


struct FullImageView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var image_url: String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                }.padding()
            }
            
            Spacer()
            AnimatedImage(url: URL(string: image_url))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .background(Color.black)
            Spacer()
            
        }
    }
}

var width = UIScreen.main.bounds.width
struct MessageView: View {
    var message: Message
    @AppStorage("username") var currentUser = ""
    @State private var showFullImage = false
    var body: some View {
        HStack {
            if message.sender == currentUser {
                Spacer()
            }
            VStack {
                if message.image_url.count != 0 {
                    
                    AnimatedImage(url: URL(string: message.image_url))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (width / 1.5), height: (width / 1.5))
                        .cornerRadius(20.0)
                    
                } else {
                    Text(message.text)
                        .fontWeight(.medium)
                        .padding()
                        .foregroundColor(.white)
                        .background(currentUser == message.sender ? Color.blue : Color.green)
                        .clipShape(Bubble(sender: currentUser == message.sender))
                }
                    
            }
            if message.sender != currentUser {
                Spacer()
            }
        }
        .onTapGesture {
            if message.message_type == "image" {
                self.showFullImage.toggle()
            }
        }.sheet(isPresented: $showFullImage) {
            FullImageView(image_url: message.image_url)
        }
        
    }
}



