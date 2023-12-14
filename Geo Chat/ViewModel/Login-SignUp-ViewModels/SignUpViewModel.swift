//
//  SignUpViewModel.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 07/02/21.
//

import SwiftUI
import Combine


final class SignUpViewModel: ObservableObject {
    
    //MARK:- Username, Email, Password Statuses
    
    enum UsernameStatus: String {
        case invalid = "Pick a username with more than or equal to 6 characters"
        case unavailable = "Username unavailable. Please choose another one"
        case available = ""
    }
    enum EmailAddressStatus: String {
        case invalidEmail = "Enter a valid email address"
        case unavailable = "Email already registered, Please choose another email"
        case available = ""
    }
    enum PasswordStatus: String {
        case notStrong = "Pick a password with min 8 characters and with atleast 1 digit and 1 special character"
        case notSame = "Passwords don't match"
        case empty = "Password is empty"
        case valid = ""
    }
    
    
    
    //MARK:- Published Properties for Sign Up Form
    @Published var username: String = ""
    @Published var emailAddress: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var showNextScreen: Bool = false
    
    @Published var usernameErrorText = "";
    @Published var emailErrorText = "";
    @Published var passwordErrorText = "";
    
    @Published var usernameErrorStatus: UsernameStatus = .available
    
    //MARK:- User Error
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertText: String = ""
    
    
    @Published var showProgressView: Bool = false
    @Published var disableSignUpButton: Bool = true
    
    //MARK:- Publishers for form fields
    private var cancellables = Set<AnyCancellable>()
    
    
    
    var isEmailValidPublisher: AnyPublisher<EmailAddressStatus, Never> {
        $emailAddress
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {
                if !self.isValidEmail($0) {
                    return .invalidEmail
                }
                var status: EmailAddressStatus = .available
                FirebaseAuthManager.shared.checkEmailExists($0) { (exists) in
                    if exists {
                        status =  .unavailable
                    }
                }
                return status
            }
            .eraseToAnyPublisher()
    }
    
    var isPasswordStrongPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {
                self.isValidPassword($0)
            }
            .eraseToAnyPublisher()
    }
    
    private var arePasswordsEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $repeatPassword)
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .map { $0 == $1 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher, isPasswordStrongPublisher, arePasswordsEqualPublisher)
            .map {
                if $0 {
                    return PasswordStatus.empty
                }
                if !$1 {
                    return PasswordStatus.notStrong
                }

                if !$2 {
                    return PasswordStatus.notSame
                }

                return PasswordStatus.valid

            }
            .eraseToAnyPublisher()
    }
    
    private var disableButtonPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isUsernameValidPublisher, isEmailValidPublisher, isPasswordValidPublisher)
            .map {
                if $0 != UsernameStatus.available || $1 != EmailAddressStatus.available || $2 != PasswordStatus.valid {
                    return true
                }
                return false
            }.eraseToAnyPublisher()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
        return passwordRegEx.evaluate(with: password)
    }
    
    var isUsernameValidPublisher: AnyPublisher<UsernameStatus, Never> {
        $username
            .dropFirst()
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .map {
                if $0.count < 6 {
                    self.usernameErrorStatus = .invalid
                    return .invalid
                }
                
                FirebaseDatabaseManager.shared.usernameExists(self.username) { [weak self] (exists) in
                    self?.usernameErrorStatus = exists ? .unavailable : .available
                }
                return .available
            }
            .eraseToAnyPublisher()
    }
    
    //MARK:- Class Init
    
    init() {
        
        isUsernameValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map {
                return $0.rawValue
            }
            .assign(to: \.usernameErrorText, on: self)
            .store(in: &cancellables)
        
        isEmailValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0.rawValue }
            .assign(to: \.emailErrorText, on: self)
            .store(in: &cancellables)
        
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0.rawValue }
            .assign(to: \.passwordErrorText, on: self)
            .store(in: &cancellables)
        
        disableButtonPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: \.disableSignUpButton, on: self)
            .store(in: &cancellables)
        
        
    }
    
    
    //MARK:- Create User Function
    func createUser() {
        self.showProgressView.toggle()
        FirebaseAuthManager.shared.createUserWith(username: username, email: emailAddress, password: password) { [weak self] (response) in
            
            DispatchQueue.main.async {
                self?.showProgressView.toggle()
            }
            
            if response != nil {
                self?.showAlert = true
                self?.alertTitle = "Oops 😬"
                self?.alertText = response!

            }
        }
    }
}
