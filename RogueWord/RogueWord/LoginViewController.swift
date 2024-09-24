//
//  LoginViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit

class LoginViewController: UIViewController {
    
    let roleImageView = UIImageView(image: UIImage(named: "roleAnimate0"))
    var animationTimer: Timer?
    var typingTimer: Timer?
    var displayLabel: UILabel!
    
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupBindings()
        startWalkingAnimation()
    }
    
    func setupView() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = UIImage(named: "LoginBackGround")
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.addSubview(backgroundImageView)
        
        roleImageView.frame = CGRect(x: -100, y: view.frame.height - view.safeAreaInsets.bottom - 200, width: 150, height: 150)
        view.addSubview(roleImageView)
        
        displayLabel = UILabel(frame: CGRect(x: 20, y: 200, width: self.view.frame.width - 40, height: 100))
        displayLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        displayLabel.textAlignment = .center
        displayLabel.textColor = .white
        displayLabel.numberOfLines = 0
        displayLabel.lineBreakMode = .byWordWrapping
        self.view.addSubview(displayLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(roleTapped))
        roleImageView.isUserInteractionEnabled = true
        roleImageView.addGestureRecognizer(tapGesture)
    }
    
    func setupBindings() {
        viewModel.roleImageChanged = { [weak self] newImage in
            // 直接切换图片，不做透明度动画，防止闪烁
            self?.roleImageView.image = newImage
        }
        
        viewModel.stringUpdated = { [weak self] newString in
            // 設置初始透明度為 0
            self?.displayLabel.alpha = 0
            self?.displayLabel.text = newString
            
            // 執行淡入動畫
            UIView.animate(withDuration: 0.5) {
                self?.displayLabel.alpha = 1  // alpha 逐漸變為 1
            }
        }

    }
    
    func startWalkingAnimation() {
        startImageAnimation()
        UIView.animate(withDuration: 3.0, delay: 0, options: [.curveLinear], animations: {
            self.roleImageView.center.x = self.view.frame.width / 2
        }, completion: { _ in
            self.stopImageAnimation()
            self.showTextFieldsView()
        })
    }
    
    func startImageAnimation() {
        viewModel.startImageAnimation()
    }
    
    func stopImageAnimation() {
        viewModel.stopImageAnimation()
    }
    
    @objc func roleTapped() {
        viewModel.handleTap()
    }
    
    func showTextFieldsView() {
        let textFieldsView = UIView(frame: CGRect(x: 40, y: view.frame.height / 2 - 100, width: self.view.frame.width - 80, height: 200))
        textFieldsView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        textFieldsView.layer.cornerRadius = 10
        
        let welcomeLabel = UILabel(frame: CGRect(x: 10, y: 10, width: textFieldsView.frame.width - 20, height: 30))
        welcomeLabel.text = "歡迎繼續探索"
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        let accountTextField = UITextField(frame: CGRect(x: 10, y: 50, width: textFieldsView.frame.width - 20, height: 40))
        accountTextField.placeholder = "帳戶"
        accountTextField.borderStyle = .roundedRect
        
        let passwordTextField = UITextField(frame: CGRect(x: 10, y: 100, width: textFieldsView.frame.width - 20, height: 40))
        passwordTextField.placeholder = "密碼"
        passwordTextField.borderStyle = .roundedRect
        
        let registerButton = UIButton(type: .system)
        registerButton.frame = CGRect(x: 10, y: 150, width: (textFieldsView.frame.width - 30) / 2, height: 40)
        registerButton.setTitle("註冊", for: .normal)
        registerButton.backgroundColor = UIColor.systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 5
        
        let loginButton = UIButton(type: .system)
        loginButton.frame = CGRect(x: registerButton.frame.maxX + 10, y: 150, width: (textFieldsView.frame.width - 30) / 2, height: 40)
        loginButton.setTitle("登錄", for: .normal)
        loginButton.backgroundColor = UIColor.systemGreen
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        textFieldsView.addSubview(welcomeLabel)
        textFieldsView.addSubview(accountTextField)
        textFieldsView.addSubview(passwordTextField)
        textFieldsView.addSubview(registerButton)
        textFieldsView.addSubview(loginButton)
        
        self.view.addSubview(textFieldsView)
        
        textFieldsView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            textFieldsView.alpha = 1
        }
    }
    
    @objc func loginButtonTapped() {
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
