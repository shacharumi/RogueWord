import UIKit
import AuthenticationServices
import SnapKit

class LoginViewController: UIViewController {

    let backgroundImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let buttonView = UIView()
    let viewModel = LoginViewModel()

    var backgroundImages: [UIImage] = []
    var currentFrameIndex: Int = 0
    var animationTimer: Timer?
    let totalFrames = 64
    let frameDuration: TimeInterval = 0.1

    var buttonOriginalCenterY: CGFloat = 0
    var isButtonMovedDown: Bool = false

    // 将按钮声明为类属性
    let authorizationAppleIDButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
        startBackgroundAnimation()
    }

    deinit {
        animationTimer?.invalidate()
    }

    func setupUI() {
        setupBackground()

        authorizationAppleIDButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: .touchUpInside)

        buttonView.addSubview(authorizationAppleIDButton)
        view.addSubview(buttonView)

        buttonView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.equalTo(60)
            make.width.equalTo(200)
            make.bottom.equalTo(view).offset(-100)
        }

        authorizationAppleIDButton.snp.makeConstraints { make in
            make.edges.equalTo(buttonView)
        }

        view.layoutIfNeeded()
        buttonOriginalCenterY = buttonView.center.y
    }

    func setupBackground() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        for i in 0...63 {
            let imageName = String(format: "login%02d", i)
            if let image = UIImage(named: imageName) {
                backgroundImages.append(image)
            } else {
                print("未找到圖片: \(imageName)")
            }
        }

        if let firstImage = backgroundImages.first {
            backgroundImageView.image = firstImage
        }
    }

    func startBackgroundAnimation() {
        animationTimer = Timer.scheduledTimer(timeInterval: frameDuration, target: self, selector: #selector(updateBackgroundImage), userInfo: nil, repeats: true)
    }

    @objc func updateBackgroundImage() {
        guard !backgroundImages.isEmpty else { return }

        currentFrameIndex = (currentFrameIndex + 1) % totalFrames
        backgroundImageView.image = backgroundImages[currentFrameIndex]

        handleButtonMovement(for: currentFrameIndex)
    }

    func handleButtonMovement(for frameIndex: Int) {
        let framesToMove: [Int: CGFloat] = [
            6: 5,
            8: -5,
            10: 5,
            12: -5,
            22: 5,
            23: -5,
            25: 5,
            28: -5,
            38: 5,
            40: -5,
            42: 5,
            44: -5,
            54: 5,
            56: -5,
            58: 5,
            60: -5
        ]

        if let movement = framesToMove[frameIndex] {
            animateButton(by: movement)
        }
    }

    func animateButton(by deltaY: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            self.buttonView.center.y += deltaY
        }) { _ in

        }
    }

    func setupBindings() {

        viewModel.onUserDataSaved = { [weak self] in
            self?.navigateToMainScreen()
        }

        viewModel.onError = { [weak self] errorMessage in
            self?.presentErrorAlert(message: errorMessage)
        }

        viewModel.onPromptForUserName = { [weak self] completion in
            self?.promptForUserName(completion: completion)
        }
    }

    @objc func pressSignInWithAppleButton() {
        authorizationAppleIDButton.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.authorizationAppleIDButton.isEnabled = true
        }

        let authorizationAppleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        authorizationAppleIDRequest.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [authorizationAppleIDRequest])

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
        let alertController = UIAlertController(title: "輸入遊戲暱稱", message: "請輸入您的遊戲暱稱", preferredStyle: .alert)
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
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
