//
//  LoginViewModel.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI
import Combine
import Firebase


final class LoginViewModel: ObservableObject {
    
    //MARK:- Published properties for Login Form
    @Published var emailAddress: String = ""
    @Published var password: String = ""
    @Published var showProgressView: Bool = false
    @Published var showSignUpView: Bool = false;
    
    
    @Published var emailErrorText = "";
    @Published var passwordErrorText = "";
    
    //MARK:- User Error
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertText: String = ""
    
    
    
    
    private func isValidEmail(_ emailAddress: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailAddress)
    }
    
    
    
    func loginUser() {
        if !isValidEmail(emailAddress) {
            self.showAlert = true
            self.alertTitle = "Oops 😬"
            self.alertText = "Please enter a valid email address"
            return
        }
        
        if password.count < 8 {
            self.showAlert = true
            self.alertTitle = "Oops 😬"
            self.alertText = "Please enter a valid password"
            return
        }
        
        self.showProgressView.toggle()
        FirebaseAuthManager.shared.loginUser(withEmail: emailAddress, password: password) { [weak self] (success, error) in
            
            DispatchQueue.main.async {
                self?.showProgressView.toggle()
            }
            
            if error != nil {
                self?.showAlert = true
                self?.alertTitle = "Oops 😬"
                self?.alertText = error!

            }
        }
    }
}
