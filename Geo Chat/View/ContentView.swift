//
//  ContentView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 03/02/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @AppStorage("email") var email: String = ""
    var body: some View {
        if email.count == 0 {
            LoginView()
        } else {
            ChatsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
