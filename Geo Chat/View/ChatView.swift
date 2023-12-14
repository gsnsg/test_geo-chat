//
//  ChatView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 10/02/21.
//

import SwiftUI




struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: ChatViewModel
    @State private var text: String = ""
    
    @State private var showImagePicker = false
    @State private var selectedImage = UIImage()
    @State private var signOut = false
    @State private var dismissView = false

    
    var body: some View {
            VStack {
                ScrollViewReader { proxy in
                    List(0 ..< self.vm.messages.count, id: \.self) { index in
                        MessageView(message: vm.messages[index])
                            .tag(index)
                    }.listStyle(PlainListStyle())
                    .onChange(of: vm.messages, perform: { (_) in
                        proxy.scrollTo(vm.messages.count - 1)
                    })
                    .onAppear {
                        
                        let _ = print(vm.messages.count)
                        proxy.scrollTo(vm.messages.count - 1)
                    }
                    .padding(.top, 10)
                }
                
                HStack {
                    Button {
                        self.showImagePicker.toggle()
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 30))
                    }
                    
                    TextField("Type your message!", text: $text)
                        .padding()
                        .font(.system(size: 16))
                        .frame(height: 40)
                        
                        .overlay(RoundedRectangle(cornerRadius: 30).strokeBorder(Color.gray.opacity(0.5), lineWidth: 1))
                    
                    Button {
                        self.vm.sendMessage(text: text, image_url: "", messageType: .text)
                        text = ""
                    } label: {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.system(size: 35))
                            
                    }
                }.padding(.horizontal)
                
                
            }.sheet(isPresented: $showImagePicker, onDismiss: {
                vm.uploadImage(image: selectedImage)
                
            }, content: {
                ImagePicker(selectedImage: $selectedImage)
            }).navigationTitle(vm.receiver).navigationBarTitleDisplayMode(.inline)
            .onAppear {
                UITableView.appearance().separatorColor = .clear
            }
           
        
        
    }
}

