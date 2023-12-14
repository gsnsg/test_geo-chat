//
//  SignUpView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI
import UIKit

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    
    @AppStorage("email") var email: String = "" {
        didSet {
            // If user is signed up or logged in this is triggered
            withAnimation {
                self.presentationMode.wrappedValue.dismiss()
            }

        }
    }
    
    
    //MARK:- View Model
    @StateObject private var viewModel = SignUpViewModel()
    @State private var dismissView: Bool = false
    
    
    //MARK:- Views
    var body: some View {
        ZStack {
            
            VStack {
                Form {
                    
                    Section(header: Text("USERNAME"),footer: Text(viewModel.usernameErrorStatus.rawValue).foregroundColor(.red)) {
                        TextField("Username", text: $viewModel.username)
                    }
                    Section(header: Text("Email Address"), footer: Text(viewModel.emailErrorText).foregroundColor(.red)) {
                        TextField("Email Address", text: $viewModel.emailAddress)
                    }
                    
                    Section(header: Text("Password"), footer: Text(viewModel.passwordErrorText).foregroundColor(.red)) {
                        SecureField("Password", text: $viewModel.password)
                        SecureField("Re-Enter Password", text: $viewModel.repeatPassword)
                    }
                }
                
                Button(action: {
                    self.viewModel.createUser()
                    
                }) {
                    ButtonTextView(text: "Sign Up!").padding()
                }.disabled(viewModel.disableSignUpButton)
                
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.startLocation.x < value.location.x - 24 {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }))
            .navigationBarTitle("Sign Up!")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomBackButton(dismissParentView: Binding<Bool>(get: { () -> Bool in
                return self.dismissView
            }, set: { (dismiss) in
                self.presentationMode.wrappedValue.dismiss()
            })))
            .alert(isPresented: $viewModel.showAlert) { () -> Alert in
                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertText), dismissButton: .default(Text("Ok")))
            }
            
            
            if viewModel.showProgressView {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.45))
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
}
