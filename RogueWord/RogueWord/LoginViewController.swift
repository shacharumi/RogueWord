//
//  LoginViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit
import AuthenticationServices
import SnapKit

var applePersonData = UserData(
    userID: "",
    fullName: "",
    email: "",
    realUserStatus: 0, 
    tag: nil,
    levelData: nil
)


class LoginViewController: UIViewController {
    
    
    
    let buttonView = UIView()
    let model = FirestoreService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authorizationAppleIDButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton()
        
        authorizationAppleIDButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: UIControl.Event.touchUpInside)
        
        authorizationAppleIDButton.frame = self.buttonView.bounds
        view.addSubview(buttonView)
        self.buttonView.addSubview(authorizationAppleIDButton)
        
        buttonView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.height.width.equalTo(100)
        }
        authorizationAppleIDButton.snp.makeConstraints { make in
            make.edges.equalTo(buttonView)
        }
    }
    
    
    
    
    @objc func pressSignInWithAppleButton() {
        let authorizationAppleIDRequest: ASAuthorizationAppleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        authorizationAppleIDRequest.requestedScopes = [.fullName, .email]
        
        let controller: ASAuthorizationController = ASAuthorizationController(authorizationRequests: [authorizationAppleIDRequest])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")
            print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
            
            let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            let userData = UserData(
                userID: appleIDCredential.user,
                fullName: fullName,
                email: appleIDCredential.email,
                realUserStatus: appleIDCredential.realUserStatus.rawValue, 
                tag: nil,
                levelData: nil
                
            )
            
            applePersonData = userData
            
            
            
            let query = FirestoreEndpoint.fetchPersonData.ref.whereField("userID", isEqualTo: "\(appleIDCredential.user)")
            
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    print("DEBUG: Error fetching document -", error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    UIView.animate(withDuration: 1.0, animations: {
                        self.view.alpha = 0
                    }) { _ in
                        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                            tabBarController.view.alpha = 0
                            tabBarController.modalPresentationStyle = .fullScreen
                            self.present(tabBarController, animated: false) {
                                UIView.animate(withDuration: 1.0) {
                                    tabBarController.view.alpha = 1.0
                                }
                            }
                        } else {
                            UIView.animate(withDuration: 0.5) {
                                self.view.alpha = 1.0
                            }
                        }
                    }
                    print("DEBUG: Document with this fullName already exists.")
                } else {
                    guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
                    let docRef = FirestoreEndpoint.fetchPersonData.ref.document(userID)
                    self.saveToUserDefaults(userData)
                    self.model.setData(userData, at: docRef)

                }
            }
        }
    }
    
    func saveToUserDefaults(_ data: UserData) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data.userID, forKey: "userID")
        userDefaults.set(data.fullName, forKey: "fullName")
        userDefaults.set(data.email, forKey: "email")
        userDefaults.set(data.realUserStatus, forKey: "realUserStatus")
        
        print("DEBUG: Data saved to UserDefaults.")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        switch (error) {
        case ASAuthorizationError.canceled:
            break
        case ASAuthorizationError.failed:
            break
        case ASAuthorizationError.invalidResponse:
            break
        case ASAuthorizationError.notHandled:
            break
        case ASAuthorizationError.unknown:
            break
        default:
            break
        }
        
        print("didCompleteWithError: \(error.localizedDescription)")
    }
}



extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}



struct LevelData: Codable {
    var correct: Int
    var levelNumber: Int
    var wrong: Int
    var isCorrect: [Bool]
    
    enum CodingKeys: String, CodingKey {
        case correct = "Correct"
        case levelNumber = "LevelNumber"
        case wrong = "Wrong"
        case isCorrect = "isCorrect"
    }
}

struct UserData: Codable {
    let userID: String
    let fullName: String?
    let email: String?
    let realUserStatus: Int?
    var tag: [String]?
    var levelData: LevelData?

    enum CodingKeys: String, CodingKey {
        case userID
        case fullName = "fullName"
        case email
        case realUserStatus
        case tag = "Tag"
        case levelData = "LevelData"
    }
}
