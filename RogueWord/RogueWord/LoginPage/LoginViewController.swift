import UIKit
import AuthenticationServices
import SnapKit

class LoginViewController: UIViewController {
    
    let backgroundImageView = UIImageView()
      let titleLabel = UILabel()
      let subtitleLabel = UILabel()
      let buttonView = UIView()
      let viewModel = LoginViewModel()
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          setupUI()
          setupBindings()
      }
      
      func setupUI() {
          // 設置背景圖片或漸變色
          setupBackground()
          
          // 設置標題
          titleLabel.text = "歡迎來到 RogueWord"
          titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
          titleLabel.textColor = .white
          titleLabel.textAlignment = .center
          view.addSubview(titleLabel)
          
          // 設置副標題
          subtitleLabel.text = "請使用 Apple 登錄以繼續"
          subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
          subtitleLabel.textColor = .white
          subtitleLabel.textAlignment = .center
          subtitleLabel.numberOfLines = 0
          view.addSubview(subtitleLabel)
          
          // 設置 Apple 登錄按鈕
          let authorizationAppleIDButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton()
          authorizationAppleIDButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: .touchUpInside)
          
          buttonView.addSubview(authorizationAppleIDButton)
          view.addSubview(buttonView)
          
         
          
          // 使用 SnapKit 設置佈局
          titleLabel.snp.makeConstraints { make in
              make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
              make.left.right.equalTo(view).inset(20)
          }
          
          subtitleLabel.snp.makeConstraints { make in
              make.top.equalTo(titleLabel.snp.bottom).offset(20)
              make.left.right.equalTo(view).inset(40)
          }
          
          buttonView.snp.makeConstraints { make in
              make.center.equalTo(view)
              make.height.equalTo(50)
              make.left.right.equalTo(view).inset(40)
          }
          
          authorizationAppleIDButton.snp.makeConstraints { make in
              make.edges.equalTo(buttonView)
          }
          
      }
    
    func setupBackground() {
           // 方法一：使用漸變色
           let gradientLayer = CAGradientLayer()
           gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
           gradientLayer.startPoint = CGPoint(x: 0, y: 0)
           gradientLayer.endPoint = CGPoint(x: 1, y: 1)
           gradientLayer.frame = view.bounds
           view.layer.insertSublayer(gradientLayer, at: 0)
           
           // 方法二：使用背景圖片
           /*
           backgroundImageView.image = UIImage(named: "background")
           backgroundImageView.contentMode = .scaleAspectFill
           view.addSubview(backgroundImageView)
           backgroundImageView.snp.makeConstraints { make in
               make.edges.equalTo(view)
           }
           */
       }
    
    func setupBindings() {
        viewModel.onUserDataSaved = { [weak self] in
            // 跳转到主页面
            self?.navigateToMainScreen()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            // 显示错误提示
            self?.presentErrorAlert(message: errorMessage)
        }
        
        viewModel.onPromptForUserName = { [weak self] completion in
            // 提示用户输入名字
            self?.promptForUserName(completion: completion)
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
    
    func navigateToMainScreen() {
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
    
    func promptForUserName(completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "輸入名字", message: "請輸入您的名字", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "名字"
        }
        
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            if let userName = alertController.textFields?.first?.text, !userName.isEmpty {
                completion(userName)
            } else {
                self.presentErrorAlert(message: "名字不能為空")
                self.promptForUserName(completion: completion)
            }
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            print("使用者取消了輸入名字")
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 将授权结果传递给 ViewModel
        viewModel.handleAuthorization(authorization: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        viewModel.handleAuthorizationError(error: error)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
