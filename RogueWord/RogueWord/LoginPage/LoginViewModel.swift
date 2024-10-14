import Foundation
import AuthenticationServices
import FirebaseFirestore

// 添加擴展
extension Encodable {
    func toDictionary() -> [String: Any]? {
        do {
            let data = try Firestore.Encoder().encode(self)
            return data
        } catch {
            print("Error converting to dictionary: \(error)")
            return nil
        }
    }
}

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
            
            
            var userData = UserData(
                userID: appleIDCredential.user,
                fullName: appleIDCredential.fullName?.givenName,
                userName: "\(UUID())",
                email: appleIDCredential.email ?? "",
                realUserStatus: appleIDCredential.realUserStatus.rawValue,
                tag: ["All"],
                levelData: LevelData(correct: 0, levelNumber: 0, wrong: 0, isCorrect: []),
                fillLevelData: LevelData(correct: 0, levelNumber: 0, wrong: 0, isCorrect: []),
                rank: Rank(correct: 0.0, playTimes: 0.0, winRate: 0.0, rankScore: 0.0),
                image: "",
                version: "多益"
            )
            
            
            
            let query = FirestoreEndpoint.fetchPersonData.ref.document(appleIDCredential.user)
            FirestoreService.shared.getDocument(query) { (personData: UserData?) in
                if let personData = personData {
                    print("DEBUG here \(personData)")
                    userData = personData
                    
                    self.model.downloadImageData(path: personData.image ?? "") { [weak self] imageData in
                        guard let self = self else { return }
                        UserDefaults.standard.setValue(imageData, forKey: "imageData")
                        if let fullName = UserDefaults.standard.string(forKey: "fullName") {
                            userData.fullName = fullName
                        }
                        
                        self.saveToUserDefaults(userData)
                        self.onUserDataSaved?()
                        print("DEBUG: Document with this userID already exists.")
                    }
                } else {
                    print("DEBUG: Failed to fetch or decode UserData.")
                    
                    let dispatchGroup = DispatchGroup()
                    var replacename = ""
                    if UserDefaults.standard.string(forKey: "fullName") == nil {
                        guard let fullName = appleIDCredential.fullName?.givenName else { return }
                        replacename = fullName
                    } else {
                        guard let fullName = UserDefaults.standard.string(forKey: "fullName") else { return }
                        replacename = fullName
                    }
                    dispatchGroup.enter()
                    UserDefaults.standard.set(userData.userID, forKey: "userID")
                    userData.fullName = replacename
                    let docRef = FirestoreEndpoint.fetchPersonData.ref.document(userData.userID)
                    self.model.setData(userData, at: docRef) { error in
                        if let error = error {
                            print("Error writing userData: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.enter()
                    let wordQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Word")
                    let wordInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 0)
                    self.model.setData(wordInitData, at: wordQuery) { error in
                        if let error = error {
                            print("Error writing wordInitData: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.enter()
                    let paragraphQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Paragraph")
                    let paragrphaInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 1)
                    self.model.setData(paragrphaInitData, at: paragraphQuery) { error in
                        if let error = error {
                            print("Error writing paragrphaInitData: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.enter()
                    let readingQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Reading")
                    let readingInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 2)
                    self.model.setData(readingInitData, at: readingQuery) { error in
                        if let error = error {
                            print("Error writing readingInitData: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        self.saveToUserDefaults(userData)
                        self.onUserDataSaved?()
                        
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
        guard let fullName = data.fullName else { return }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data.userID, forKey: "userID")
        userDefaults.set(fullName, forKey: "fullName")
        userDefaults.set(data.email, forKey: "email")
        userDefaults.set(data.image, forKey: "image")
        userDefaults.set(fullName, forKey: "userName")
        userDefaults.set(data.version, forKey: "version")
        print("DEBUG: Data saved to UserDefaults.")
    }
}
