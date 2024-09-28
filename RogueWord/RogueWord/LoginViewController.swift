import UIKit
import AuthenticationServices
import SnapKit

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
            
            // 建立用戶資料
            var userData = UserData(
                userID: appleIDCredential.user,
                fullName: fullName,
                userName: nil,
                email: appleIDCredential.email,
                realUserStatus: appleIDCredential.realUserStatus.rawValue,
                tag: nil,
                levelData: nil
            )
            
            // Firestore 查詢
            let query = FirestoreEndpoint.fetchPersonData.ref.whereField("userID", isEqualTo: "\(appleIDCredential.user)")
            
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    print("DEBUG: Error fetching document -", error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    // 如果文檔存在，提取數據並更新 userData
                    for document in snapshot.documents {
                        let data = document.data()
                        
                        // 解析 tag
                        let tag = data["Tag"] as? [String]
                        
                        // 解析 levelData
                        if let levelDataDict = data["LevelData"] as? [String: Any] {
                            let levelData = LevelData(
                                correct: levelDataDict["Correct"] as? Int ?? 0,
                                levelNumber: levelDataDict["LevelNumber"] as? Int ?? 0,
                                wrong: levelDataDict["Wrong"] as? Int ?? 0,
                                isCorrect: levelDataDict["isCorrect"] as? [Bool] ?? []
                            )
                            userData.levelData = levelData
                        }
                        
                        // 解析 rank
                        if let rankDict = data["rank"] as? [String: Any] {
                            let rank = Rank(
                                correct: rankDict["correct"] as? Int ?? 0,
                                playTimes: rankDict["playTimes"] as? Int ?? 0,
                                winRate: rankDict["winRate"] as? Int ?? 0
                            )
                            userData.rank = rank
                        }
                        
                    }
                    
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
                                self.saveToUserDefaults(userData)
                            }
                        } else {
                            UIView.animate(withDuration: 0.5) {
                                self.view.alpha = 1.0
                            }
                        }
                    }
                    print("DEBUG: Document with this fullName already exists.")
                } else {
                    // 如果文檔不存在，保存新數據
                    guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
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
        userDefaults.set(data.image, forKey: "image")
        userDefaults.set(data.userName, forKey: "userName")
        userDefaults.setStruct(data.rank, forKey: "rank")
        print("DEBUG: Data saved to UserDefaults.")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        switch error {
        case ASAuthorizationError.canceled:
            print("DEBUG: User canceled authorization.")
        case ASAuthorizationError.failed:
            print("DEBUG: Authorization failed.")
        case ASAuthorizationError.invalidResponse:
            print("DEBUG: Invalid response from authorization.")
        case ASAuthorizationError.notHandled:
            print("DEBUG: Authorization not handled.")
        case ASAuthorizationError.unknown:
            print("DEBUG: Unknown authorization error.")
        default:
            print("DEBUG: Authorization error: \(error.localizedDescription)")
        }
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
}

struct Rank: Codable {
    var correct: Int
    var playTimes: Int
    var winRate: Int
}

struct UserData: Codable {
    let userID: String
    let fullName: String?
    let userName: String?
    let email: String?
    let realUserStatus: Int?
    var tag: [String]?
    var levelData: LevelData?
    var rank: Rank?
    var image: String?
}

extension UserDefaults {
    func setStruct<T: Codable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            self.set(encoded, forKey: key)
        }
    }
    
    func getStruct<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            return try? decoder.decode(T.self, from: data)
        }
        return nil
    }
}
