//
//  RoomViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/13.
//

import UIKit
import Firebase
import SnapKit
import FirebaseDatabaseInternal

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var roomID: String?
    var qrCodeImageView: UIImageView!
    var tableView: UITableView!
    var participants: [[String: Any]] = []
    var isRoomCreator: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PlayViewColor")

        setupTopView()
        setupQRCodeImageView()
        setupTableView()
        generateQRCode()
        observeParticipants()
        observeIsStart()
        checkIfRoomCreator()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    func removeObservers() {
        guard let roomID = roomID else { return }
        let ref = Database.database().reference().child("rooms").child(roomID)
        ref.removeAllObservers()
    }
 
    func setupTopView() {
        let topView = UIView()
        topView.backgroundColor = .clear
        view.addSubview(topView)

        topView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.height.equalTo(50)
        }

        let backButton = UIButton(type: .system)
        backButton.tintColor = UIColor(named: "TextColor")
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        topView.addSubview(backButton)

        backButton.snp.makeConstraints { make in
            make.left.equalTo(topView).offset(16)
            make.centerY.equalTo(topView)
        }

        let titleLabel = UILabel()
        titleLabel.text = "連線等待室"
        titleLabel.textColor = UIColor(named: "TextColor")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        topView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(topView)
            make.centerY.equalTo(topView)
        }
    }

    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

    func setupQRCodeImageView() {
        qrCodeImageView = UIImageView()
        view.addSubview(qrCodeImageView)

        qrCodeImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(70)
            make.centerX.equalTo(view)
            make.width.height.equalTo(200)
        }
    }

    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "PlayViewColor")
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ParticipantCell")

        tableView.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(20)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }

    func generateQRCode() {
        guard let roomID = roomID else { return }
        let qrCodeImage = generateQRCodeImage(from: roomID)
        qrCodeImageView.image = qrCodeImage
    }

    func generateQRCodeImage(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.utf8)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            // Increase the size of the QR code
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                // Convert to UIImage
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    func observeParticipants() {
        guard let roomID = roomID else { return }
        let ref = Database.database().reference().child("rooms").child(roomID).child("participants")

        ref.observe(.value) { [weak self] snapshot in
            var newParticipants: [[String: Any]] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let participantData = childSnapshot.value as? [String: Any] {
                    newParticipants.append(participantData)
                }
            }

            newParticipants.sort { (p1, p2) -> Bool in
                let accuracy1 = p1["accuracy"] as? Float ?? -1
                let accuracy2 = p2["accuracy"] as? Float ?? -1

                if accuracy1 != accuracy2 {
                    return accuracy1 > accuracy2
                } else {
                    let time1 = p1["time"] as? TimeInterval ?? Double.infinity
                    let time2 = p2["time"] as? TimeInterval ?? Double.infinity
                    return time1 < time2
                }
            }

            self?.participants = newParticipants
            self?.tableView.reloadData()
        }
    }

    func checkIfRoomCreator() {
        guard let roomID = roomID else { return }
        let ref = Database.database().reference().child("rooms").child(roomID)

        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            if let roomData = snapshot.value as? [String: Any],
               let createdByEmail = roomData["createdByEmail"] as? String,
               let currentUserEmail = UserDefaults.standard.string(forKey: "email") {
                if createdByEmail == currentUserEmail {
                    self.isRoomCreator = true
                    self.setupStartButton()
                }
            }
        }
    }

    func setupStartButton() {
        let startButton = UIButton(type: .system)
        startButton.setTitle("開始遊戲", for: .normal)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        startButton.backgroundColor = UIColor(named: "TextColor")
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)

        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
    }

    @objc func startButtonTapped() {
        guard let roomID = roomID else { return }
        let ref = Database.database().reference().child("rooms").child(roomID)

        ref.updateChildValues(["isStart": true]) { (error, _) in
            if let error = error {
                print("Error updating isStart: \(error.localizedDescription)")
                let errorAlert = UIAlertController(title: "錯誤", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
            }
        }
    }

    func observeIsStart() {
        guard let roomID = roomID else { return }
        let ref = Database.database().reference().child("rooms").child(roomID).child("isStart")

        ref.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            if let isStart = snapshot.value as? Bool, isStart == true {
                ref.removeAllObservers()
                self.navigateToGame()
            }
        }
    }

    func navigateToGame() {
        let gameVC = UnitGameViewController()
        gameVC.roomID = self.roomID

        let data: [FireBaseWord] = [
            FireBaseWord(levelNumber: 2, tag: "All", word: JsonWord(levelNumber: 2, english: "several", chinese: "幾個的;一些的", property: "quant.", sentence: "She has several books on her desk.")),
            FireBaseWord(levelNumber: 2, tag: "All", word: JsonWord(levelNumber: 2, english: "hurry", chinese: "匆忙", property: "verb", sentence: "We need to hurry or we'll miss the train.")),
            FireBaseWord(levelNumber: 2, tag: "All", word: JsonWord(levelNumber: 2, english: "complicated", chinese: "複雜的", property: "adj.", sentence: "The instructions are too complicated for beginners.")),
            FireBaseWord(levelNumber: 2, tag: "All", word: JsonWord(levelNumber: 2, english: "solution", chinese: "解決方法", property: "noun", sentence: "He came up with a clever solution to the problem.")),
            FireBaseWord(levelNumber: 2, tag: "All", word: JsonWord(levelNumber: 2, english: "quickly", chinese: "快速地", property: "adv.", sentence: "The athlete quickly crossed the finish line."))
        ]
        gameVC.collectionData = data
        gameVC.modalPresentationStyle = .fullScreen
        self.present(gameVC, animated: true, completion: nil)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "ParticipantCell"
        let cell: UITableViewCell

        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reusedCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }

        let participant = participants[indexPath.row]
        let name = participant["name"] as? String ?? "Unknown"
        let accuracy = participant["accuracy"] as? Float ?? -1
        let time = participant["time"] as? TimeInterval ?? Double.infinity

        cell.textLabel?.text = "\(indexPath.row + 1). \(name)"
        cell.textLabel?.textColor = UIColor(named: "TextColor")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        cell.backgroundColor =  UIColor(named: "PlayViewColor")
        var detailText = ""
        if accuracy >= 0 {
            detailText += "答對率: \(String(format: "%.0f%%", accuracy))"
        }
        if time != Double.infinity {
            if !detailText.isEmpty { detailText += " - " }
            detailText += "時間: \(String(format: "%.2f", time))s"
        }
        cell.detailTextLabel?.text = detailText

        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
