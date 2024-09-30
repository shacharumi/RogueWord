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
            
            // 創建 userData，暫時將 userName 設為空字串
            var userData = UserData(
                userID: appleIDCredential.user,
                fullName: fullName,
                userName: "",  // 暫時設為空，稍後由使用者輸入
                email: appleIDCredential.email ?? "",
                realUserStatus: appleIDCredential.realUserStatus.rawValue,
                tag: ["All"],
                levelData: LevelData(correct: 0, levelNumber: 1, wrong: 0, isCorrect: []),
                rank: Rank(correct: 0.0, playTimes: 0.0, winRate: 0.0, rankScore: 0.0),
                image: ""
            )

            let query = FirestoreEndpoint.fetchPersonData.ref.whereField("userID", isEqualTo: "\(appleIDCredential.user)")
            
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    print("DEBUG: Error fetching document -", error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    // 資料存在，跳轉到主頁面
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
                    print("DEBUG: Document with this userID already exists.")
                } else {
                    // 沒有相同 userID，跳出 Alert 要求輸入名字
                    self.promptForUserName { userName in
                        // 更新 userData 的 userName
                        userData.userName = userName
                        
                        // 保存資料到 Firestore 和 UserDefaults
                        let docRef = FirestoreEndpoint.fetchPersonData.ref.document(userData.userID)
                        self.model.setData(userData, at: docRef)
                        let wordQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Word")
                        let wordInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 0)
                        self.model.setData(wordInitData, at: wordQuery)
                        let paragraphQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Paragraph")
                        let paragrphaInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 1)
                        self.model.setData(paragrphaInitData, at: paragraphQuery)
                        let readingQuery = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Reading")
                        let readingInitData = Accurency(corrects: 0, wrongs: 0, times: 0, title: 2)
                        self.model.setData(readingInitData, at: readingQuery)
                        
                        self.saveToUserDefaults(userData)
                        
                        // 跳轉到主頁面
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
                    }
                }
            }
        }
    }
    
    func promptForUserName(completion: @escaping (String) -> Void) {
        // 建立一個 AlertController 來要求使用者輸入名字
        let alertController = UIAlertController(title: "輸入名字", message: "請輸入您的名字", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "名字"
        }
        
        // 增加一個提交按鈕
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            if let userName = alertController.textFields?.first?.text, !userName.isEmpty {
                // 回傳輸入的 userName
                completion(userName)
            } else {
                // 如果輸入為空，則顯示錯誤提示
                self.presentErrorAlert(message: "名字不能為空")
            }
        }
        alertController.addAction(confirmAction)
        
        // 增加一個取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            // 如果使用者取消，可能需要處理，例如返回登入畫面
            print("使用者取消了輸入名字")
        }
        alertController.addAction(cancelAction)
        
        // 顯示 Alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            // 重新要求使用者輸入名字
            self.promptForUserName { userName in
                // 繼續流程
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveToUserDefaults(_ data: UserData) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data.userID, forKey: "userID")
        userDefaults.set(data.fullName, forKey: "fullName")
        userDefaults.set(data.email, forKey: "email")
        userDefaults.set(data.realUserStatus, forKey: "realUserStatus")
        userDefaults.set(data.image, forKey: "image")
        userDefaults.set(data.userName, forKey: "userName")
        print("DEBUG: Data saved to UserDefaults.")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        switch (error) {
        case ASAuthorizationError.canceled:
            print("使用者取消了授權請求")
        case ASAuthorizationError.failed:
            print("授權請求失敗")
        case ASAuthorizationError.invalidResponse:
            print("授權請求無效")
        case ASAuthorizationError.notHandled:
            print("授權請求未處理")
        case ASAuthorizationError.unknown:
            print("未知的授權錯誤")
        default:
            print("其他錯誤: \(error.localizedDescription)")
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

struct Rank: Codable {
    var correct: Float
    var playTimes: Float
    var winRate: Float
    var rankScore: Float
}

struct UserData: Codable {
    let userID: String
    let fullName: String?
    var userName: String?
    let email: String?
    let realUserStatus: Int?
    var tag: [String]?
    var levelData: LevelData?
    var rank: Rank?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case userID
        case fullName = "fullName"
        case userName
        case email
        case realUserStatus
        case tag = "Tag"
        case levelData = "LevelData"
        case rank
        case image
    }
}



