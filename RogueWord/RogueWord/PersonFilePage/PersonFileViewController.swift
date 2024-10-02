import UIKit
import SnapKit

class PersonFileViewController: UIViewController {

    let tableView = UITableView()
    let headerView = UIView()

    let viewModel = PersonFileViewModel()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "輸入名稱"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.isUserInteractionEnabled = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "viewBackGround")

        setupNavigationBar()
        setupUI()
        setupTableView()

        viewModel.requestNotificationAuthorization()

        loadUserData()
    }

    func setupNavigationBar() {
        
        navigationItem.title = "個人頁面"
        self.navigationController?.navigationBar.isTranslucent = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "tabBarColor")
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance


    }

    func loadUserData() {
        nameLabel.text = viewModel.user.name
        print(viewModel.user.profileImage)
        profileImageView.image = viewModel.user.profileImage
    }

    func setupUI() {
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 20
        headerView.layer.shadowColor = UIColor.lightGray.cgColor
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.addSubview(headerView)

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(200)
        }

        headerView.addSubview(profileImageView)
        headerView.addSubview(nameLabel)

        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(headerView).offset(20)
            make.centerX.equalTo(headerView)
            make.width.height.equalTo(100)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.left.equalTo(headerView).offset(20)
            make.right.equalTo(headerView).offset(-20)
            make.height.equalTo(40)
        }
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(PersonFileCell.self, forCellReuseIdentifier: "PersonFileCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(named: "viewBackGround")
        tableView.tableFooterView = UIView()

        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc func changeProfileImage() {
        showEditProfileAlert()
    }

    @objc func nameLabelTapped() {
        showNameEditAlert()
    }

    func showNameEditAlert() {
        let alertController = UIAlertController(title: "更改名稱", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "輸入新名稱"
            textField.text = self.viewModel.user.name
        }
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                self.viewModel.user.name = newName
                self.nameLabel.text = newName
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func showEditProfileAlert() {
        let alertController = UIAlertController(title: "修改名稱 & 大頭貼", message: nil, preferredStyle: .actionSheet)

        let changeNameAction = UIAlertAction(title: "更改名稱", style: .default) { _ in
            self.showNameEditAlert()
        }

        let changeProfilePictureAction = UIAlertAction(title: "更改大頭貼", style: .default) { _ in
            self.showProfilePictureOptions()
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(changeNameAction)
        alertController.addAction(changeProfilePictureAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func showProfilePictureOptions() {
        let alertController = UIAlertController(title: "更改大頭貼", message: nil, preferredStyle: .actionSheet)

        let takePhotoAction = UIAlertAction(title: "透過相機拍一張", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        }

        let chooseFromLibraryAction = UIAlertAction(title: "從相簿選擇圖片", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibraryAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("該功能在此裝置不適用")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    func showTimePicker() {
            let alertController = UIAlertController(title: "選擇時間", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.minuteInterval = 30
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addSubview(datePicker)
            
            datePicker.snp.makeConstraints { make in
                make.leading.equalTo(alertController.view).offset(20)
                make.trailing.equalTo(alertController.view).offset(-20)
                make.top.equalTo(alertController.view).offset(50)
                make.height.equalTo(150)
            }
            
            let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
                let selectedDate = datePicker.date
                self.viewModel.scheduleNotification(for: selectedDate)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }

    func showVersionPicker() {
        let alertController = UIAlertController(title: "選擇版本", message: nil, preferredStyle: .actionSheet)

        let versions = ["多益", "托福", "全民英檢", "雅思"]

        for version in versions {
            let action = UIAlertAction(title: version, style: .default) { _ in
                self.viewModel.user.selectedVersion = version
                self.versionSelected(version)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)


        present(alertController, animated: true, completion: nil)
    }

    func versionSelected(_ version: String) {
        let confirmAlert = UIAlertController(title: "已選擇版本", message: "選擇了 \(version)", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(confirmAlert, animated: true, completion: nil)
    }

    func logout() {
        viewModel.clearUserData()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            let navController = UINavigationController(rootViewController: loginVC)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let delegate = windowScene.delegate as? SceneDelegate,
               let window = delegate.window {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        }
    }

    func deleteAccount() {
        let alertController = UIAlertController(title: "刪除帳號", message: "真的要刪除帳號嗎？刪除掉了則無法復原", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .destructive) { _ in
            self.viewModel.clearUserData()

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                let navController = UINavigationController(rootViewController: loginVC)

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let delegate = windowScene.delegate as? SceneDelegate,
                   let window = delegate.window {
                    window.rootViewController = navController
                    window.makeKeyAndVisible()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PersonFileViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PersonFileCell", for: indexPath) as? PersonFileCell else {
            return UITableViewCell()
        }

        let option = viewModel.settingsOptions[indexPath.row]
        cell.configureCell(with: option.0, icon: option.1)
        
        let last = viewModel.settingsOptions.count
        if indexPath.row + 1 == last {
            cell.titleLabel.textColor = .red
            cell.iconImageView.tintColor = .red
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.settingsOptions[indexPath.row].0

        if option == "修改名稱 & 大頭貼" {
            showEditProfileAlert()
        } else if option == "分享APP给朋友" {
            viewModel.shareApp(from: self)
        } else if option == "設定提醒時間" {
            showTimePicker()
        } else if option == "選擇版本" {
            showVersionPicker()
        } else if option == "登出" {
            logout()
        } else if option == "刪除帳號" {
            deleteAccount()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PersonFileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
            viewModel.user.profileImage = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
