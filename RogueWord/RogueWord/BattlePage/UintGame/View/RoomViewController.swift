//
//  RoomViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/13.
//

import UIKit
import Firebase
import SnapKit

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var qrCodeImageView: UIImageView!
    var tableView: UITableView!
    
    var roomID: String?
    var viewModel: RoomViewModel!
    var isRoomCreator: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PlayViewColor")
        
        viewModel = RoomViewModel(roomID: roomID)
        
        setupTopView()
        setupQRCodeImageView()
        setupTableView()
        setupBindings()
        
        viewModel.fetchParticipants()
        viewModel.observeIsStart()
        viewModel.checkIfRoomCreator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeObservers()
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
        
        generateQRCode()
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "PlayViewColor")
        view.addSubview(tableView)
        tableView.register(ParticipantCell.self, forCellReuseIdentifier: "ParticipantCell")
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(20)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    func setupBindings() {
        viewModel.onParticipantsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onRoomCreatorStatusChanged = { [weak self] in
            if self?.viewModel.isRoomCreator == true {
                self?.setupStartButton()
            }
        }
        
        viewModel.onIsStartChanged = { [weak self] in
            if self?.viewModel.isStart == true {
                self?.navigateToGame()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                let errorAlert = UIAlertController(title: "錯誤", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                self?.present(errorAlert, animated: true, completion: nil)
            }
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
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
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
        viewModel.startGame { [weak self] result in
            switch result {
            case .success():
                break
            case .failure(let error):
                self?.viewModel.onError?(error)
            }
        }
    }
    
    func navigateToGame() {
        let gameVC = UnitGameViewController()
        gameVC.roomID = self.roomID
        
        let data: [FireBaseWord] = [
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "ubiquitous",
                    chinese: "無處不在的",
                    property: "adj.",
                    sentence: "Smartphones have become ubiquitous in modern society."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "quintessential",
                    chinese: "典型的",
                    property: "adj.",
                    sentence: "She is the quintessential professional, always prepared and punctual."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "conundrum",
                    chinese: "難題",
                    property: "noun",
                    sentence: "The issue presents a conundrum that has yet to be resolved."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "ephemeral",
                    chinese: "短暫的",
                    property: "adj.",
                    sentence: "Fashions are ephemeral, they change with time."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "juxtapose",
                    chinese: "並列",
                    property: "verb",
                    sentence: "The exhibition juxtaposes modern art with classical sculptures."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "esoteric",
                    chinese: "深奧的",
                    property: "adj.",
                    sentence: "The professor's lectures were so esoteric that only a few students could understand them."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "meticulous",
                    chinese: "一絲不苟的",
                    property: "adj.",
                    sentence: "She is meticulous in her work, ensuring every detail is perfect."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "ambivalent",
                    chinese: "矛盾的",
                    property: "adj.",
                    sentence: "He felt ambivalent about the promotion, excited yet apprehensive."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "cogent",
                    chinese: "有說服力的",
                    property: "adj.",
                    sentence: "She presented a cogent argument that convinced everyone."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "perfunctory",
                    chinese: "敷衍的",
                    property: "adj.",
                    sentence: "His perfunctory response indicated a lack of interest."
                )
            ),
            // 新增五個高難度項目
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "lucid",
                    chinese: "清晰的",
                    property: "adj.",
                    sentence: "She gave a lucid account of the complex situation."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "intransigent",
                    chinese: "不妥協的",
                    property: "adj.",
                    sentence: "The negotiators found the other party to be intransigent."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "obfuscate",
                    chinese: "使模糊",
                    property: "verb",
                    sentence: "The company's financial statement was designed to obfuscate the real situation."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "magnanimous",
                    chinese: "寬宏大量的",
                    property: "adj.",
                    sentence: "Despite the rivalry, he was magnanimous in victory."
                )
            ),
            FireBaseWord(
                levelNumber: 900,
                tag: "Advanced",
                word: JsonWord(
                    levelNumber: 900,
                    english: "sagacious",
                    chinese: "睿智的",
                    property: "adj.",
                    sentence: "Her sagacious decisions have greatly benefited the company."
                )
            )
        ]

        gameVC.collectionData = data
        gameVC.modalPresentationStyle = .fullScreen
        self.present(gameVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "ParticipantCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ParticipantCell else {
            return UITableViewCell()
        }
        
        let participant = viewModel.participants[indexPath.row]
        cell.nameLabel.text = "\(indexPath.row + 1). \(participant.name)"
        
        if participant.accuracy >= 0 {
            cell.accuracyLabel.text = "答對率: \(String(format: "%.0f%%", participant.accuracy))"
        } else {
            cell.accuracyLabel.text = "答對率: 100%"
        }
        
        if participant.time != Double.infinity {
            cell.timeLabel.text = "時間: \(String(format: "%.2f", participant.time))s"
        } else {
            cell.timeLabel.text = "時間: 0.0s"
        }
        
        cell.backgroundColor = UIColor(named: "PlayViewColor")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
