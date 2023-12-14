//
//  ChatsView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI
import Firebase

struct SignOutButton: View {
    @Binding var signOut: Bool
    var body: some View {
        Button {
            self.signOut = true
        } label: {
            Image(systemName: "power")
                .foregroundColor(Color.red)
        }

    }
}


struct ChatsView: View {
    @AppStorage("username") var username = "Anonymous"
    
    @StateObject var lm = LocationManager()
    @State private var signOut = false
    
    var body: some View {
//        ChatViewModel(sender: username, receiver: user)
        NavigationView {
                List(lm.nearByUsers, id: \.self) { user in
                    NavigationLink(destination: ChatView(vm: lm.userVM[user]!)) {
                        Text(user)
                    }
                }.listStyle(PlainListStyle())
                .onChange(of: signOut) { (_) in
                    lm.removeLocation()
                }
                .navigationTitle("Chats")
                .navigationBarItems(trailing: SignOutButton(signOut: $signOut))
        }
        
       

    }
}

