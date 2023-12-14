//
//  LoginView.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("email") var email: String = "" {
        didSet {
            // If user is signed up or logged in this is triggered
            withAnimation {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    //MARK:- Login View Model
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack {
                        Image("login_image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                        
                        
                        InputView(text: $viewModel.emailAddress, header: "Email Address", description: "Email Address", textFieldType: .text)
                        InputView(text: $viewModel.password, header: "Password", description: "Password", textFieldType: .password)
                        
                        
                        
                        Button(action: {
                            self.viewModel.loginUser()
                        }) {
                            ButtonTextView(text: "Login")
                        }
                        .padding(.top)
                        
                        
                        NavigationLink(destination: SignUpView(), isActive: $viewModel.showSignUpView, label: {})
                        
                        HStack(alignment: .center) {
                            Text("Don't have an account?")
                                .font(.system(size: 15, weight: .light))
                            Button(action: {
                                self.viewModel.showSignUpView.toggle()
                            }) {
                                Text("Sign Up")
                                    .font(.system(size: 15))
                                    .foregroundColor(.primaryButtonColor)
                            }
                        }.padding(.top)
                        
                        
                    }.padding()
                    .navigationTitle("Welcome Back!")
                }
            }.alert(isPresented: $viewModel.showAlert) { () -> Alert in
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
