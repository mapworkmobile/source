//
//  SessionManager.swift
//  Mapwork
//
//  Created by James Nebeker on 2/27/21.
//

import Foundation
import Combine
import Amplify
import AmplifyPlugins

enum AuthState {
    case signUp
    case login
    case confirmCode(username:  String)
    case session (user: AuthUser)
    case firstTime
    case confirmSignIn
   
}

enum AuthErrorMessage {
    
}

final class SessionManager: ObservableObject {
    @Published var authState: AuthState = .firstTime
    @Published var errorMessage: AuthErrorMessage? = nil
    func getCurrentAuthUser() {
        if let user = Amplify.Auth.getCurrentUser() {
            authState = .session(user: user)
        } else {
            authState = .login
        }
    }
    
    func showSignUpView()
    {
        authState = .signUp
    }
    
    func showLoginView()
    {
        authState = .login
    }
    
    func showConfirmationSignInView()
    {
        authState = .confirmSignIn
    }

    func signUp(username: String, phoneNumber: String) {
        let userAttributes = [AuthUserAttribute(.phoneNumber, value: phoneNumber)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
      
        _ = Amplify.Auth.signUp(username: username, password: UUID().uuidString, options: options) { [weak self] result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                    DispatchQueue.main.async {
                        self?.authState = .confirmCode(username: username)
                    }
                } else {
                    print("Signup Complete")
                }
            case .failure(let error):
        
                print("An error occurred while registering a user \(error)")
            }
        }
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { [weak self] result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                DispatchQueue.main.async {
                    self?.showLoginView()
                }
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
    
    func signIn(username: String) {
     
        Amplify.Auth.signIn(username: username, password: "bla") { [weak self] result in
        switch result  {
            case .success (let result):
                if case .confirmSignInWithCustomChallenge(_) = result.nextStep {
                    
                 
                   
                    DispatchQueue.main.async {
                        self?.showConfirmationSignInView()
                    }
                    
                } else {
                    print("Sign in succeeded")
                }
            case .failure(let error):
                
                print("Sign in failed \(error)")
            
       
            
            }
        }
    }
    

    
    func customChallenge(response: String) {
        Amplify.Auth.confirmSignIn(challengeResponse: response) {[weak self] result in
          
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.getCurrentAuthUser()
                }
                print("Confirm sign in succeeded")
            case .failure(let error):
                print("Confirm sign in failed \(error)")
            }
        }
    }
    
}
