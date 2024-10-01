//
//  LoginViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import Foundation
import AuthenticationServices

class LoginViewModel {
    
    private let model = FirestoreService()
    private let jsonFileModel = FirebaseToJSONFileUploader()
    
    var onUserDataSaved: (() -> Void)?
    var onError: ((String) -> Void)?
    var onPromptForUserName: ((@escaping (String) -> Void) -> Void)?
    
    init() {
        self.jsonFileModel.fetchAndSaveWordsToJSON()
        self.jsonFileModel.loadWordsFromFile()
        self.jsonFileModel.readWordsFromJSONFile()
    }
    
    func handleAuthorization(authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")
            print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
            
            let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            
            var userData = UserData(
                userID: appleIDCredential.user,
                fullName: fullName,
                userName: "",
                email: appleIDCredential.email ?? "",
                realUserStatus: appleIDCredential.realUserStatus.rawValue,
                tag: ["All"],
                levelData: LevelData(correct: 0, levelNumber: 1, wrong: 0, isCorrect: []),
                rank: Rank(correct: 0.0, playTimes: 0.0, winRate: 0.0, rankScore: 0.0),
                image: ""
            )
            
            let query = FirestoreEndpoint.fetchPersonData.ref.whereField("userID", isEqualTo: "\(appleIDCredential.user)")
            
            query.getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print("DEBUG: Error fetching document -", error.localizedDescription)
                    self?.onError?(error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    self?.saveToUserDefaults(userData)
                    self?.onUserDataSaved?()
                    print("DEBUG: Document with this userID already exists.")
                } else {
                    self?.onPromptForUserName? { userName in
                        userData.userName = userName
                        
                        let docRef = FirestoreEndpoint.fetchPersonData.ref.document(userData.userID)
                        self?.model.setData(userData, at: docRef)
                        
                        let wordQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Word")
                        let wordInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 0)
                        self?.model.setData(wordInitData, at: wordQuery)
                        
                        let paragraphQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Paragraph")
                        let paragrphaInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 1)
                        self?.model.setData(paragrphaInitData, at: paragraphQuery)
                        
                        let readingQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Reading")
                        let readingInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 2)
                        self?.model.setData(readingInitData, at: readingQuery)
                        
                        self?.saveToUserDefaults(userData)
                        self?.onUserDataSaved?()
                    }
                }
            }
        }
    }
    
    func handleAuthorizationError(error: Error) {
        var errorMessage = ""
        switch (error) {
        case ASAuthorizationError.canceled:
            errorMessage = "用戶取消了授權請求"
        case ASAuthorizationError.failed:
            errorMessage = "授權請求失敗"
        case ASAuthorizationError.invalidResponse:
            errorMessage = "授權請求無效"
        case ASAuthorizationError.notHandled:
            errorMessage = "授權請求未處理"
        case ASAuthorizationError.unknown:
            errorMessage = "未知的授權錯誤"
        default:
            errorMessage = "其他錯誤: \(error.localizedDescription)"
        }
        
        print(errorMessage)
        self.onError?(errorMessage)
    }
    
    private func saveToUserDefaults(_ data: UserData) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data.userID, forKey: "userID")
        userDefaults.set(data.fullName, forKey: "fullName")
        userDefaults.set(data.email, forKey: "email")
        userDefaults.set(data.realUserStatus, forKey: "realUserStatus")
        userDefaults.set(data.image, forKey: "image")
        userDefaults.set(data.userName, forKey: "userName")
        print("DEBUG: Data saved to UserDefaults.")
    }
}
