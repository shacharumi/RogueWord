//
//  BattleGameScene.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//

import SpriteKit
import UIKit
import FirebaseDatabase

class BattleGameScene: SKScene {

    var enchantress: SKSpriteNode!
    var knight: SKSpriteNode!
    var musketeer: SKSpriteNode!
    var wizard: SKSpriteNode!

    var rank: Rank?
    weak var viewController: UIViewController?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        self.backgroundColor = .clear

        enchantress = createCharacter(named: "Enchantress", position: CGPoint(x: center.x - 100, y: center.y + 30))
        knight = createCharacter(named: "Knight", position: CGPoint(x: center.x - 100, y: center.y - 170))
        musketeer = createCharacter(named: "Musketeer", position: CGPoint(x: center.x + 100, y: center.y - 170))
        wizard = createCharacter(named: "Wizard", position: CGPoint(x: center.x + 100, y: center.y + 30))

        runRandomAction(for: enchantress, characterName: "Enchantress")
        runRandomAction(for: knight, characterName: "Knight")
        runRandomAction(for: musketeer, characterName: "Musketeer")
        runRandomAction(for: wizard, characterName: "Wizard")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            for node in touchedNodes {
                if let characterNode = node as? SKSpriteNode, let characterName = characterNode.name {
                    handleCharacterTap(characterName, node: characterNode)
                    break
                }
            }
        }
    }

    func handleCharacterTap(_ characterName: String, node: SKSpriteNode) {
        guard let rank = self.rank else { return }
        guard let requiredLevel = node.userData?["requiredLevel"] as? Int else { return }
        let rankScore = Int(rank.rankScore) ?? 0

        if characterName == "Knight" {
            // Present alert with options
            let alert = UIAlertController(title: "Knight", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "創建房間", style: .default, handler: { [weak self] _ in
                self?.createRoom()
            }))
            alert.addAction(UIAlertAction(title: "掃描Qrcode", style: .default, handler: { [weak self] _ in
                self?.scanQRCode()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.viewController?.present(alert, animated: true, completion: nil)
            return
        }

        // For other characters, proceed as before
        let battlePage = BattleViewController()
        battlePage.rank = rank
        battlePage.modalPresentationStyle = .fullScreen
        self.viewController?.present(battlePage, animated: true, completion: nil)
    }

    func createRoom() {
        // 使用编码后的电子邮件作为唯一的房间 ID
        let email = UserDefaults.standard.string(forKey: "email") ?? "unknownEmail"
        let roomID = encodeEmail(email)

        // 获取 Firebase Realtime Database 的引用
        let ref = Database.database().reference()

        // 获取当前用户的信息
        let playerName = UserDefaults.standard.string(forKey: "fullName") ?? "Unknown Player"
        let userEmail = email

        // 创建房间节点的数据
        let roomData: [String: Any] = [
            "createdBy": playerName,
            "createdByEmail": userEmail, // 使用电子邮件识别房间创建者
            "score": 0,
            "isStart": false,
            "participants": [
                encodeEmail(userEmail): [
                    "name": playerName,
                    "accurency": 0,
                    "time": 0
                ]
            ]
        ]

        // 保存到数据库
        ref.child("rooms").child(roomID).setValue(roomData) { [weak self] (error, _) in
            if let error = error {
                print("Error creating room: \(error.localizedDescription)")
                // 显示错误给用户
                let errorAlert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self?.viewController?.present(errorAlert, animated: true, completion: nil)
            } else {
                // 成功创建房间
                // 跳转到 RoomViewController
                let roomVC = RoomViewController()
                roomVC.roomID = roomID
                roomVC.modalPresentationStyle = .fullScreen
                self?.viewController?.present(roomVC, animated: true, completion: nil)
            }
        }
    }

    func scanQRCode() {
        let scannerVC = QRCodeScannerViewController()
        scannerVC.delegate = self  // 设置委托
        scannerVC.modalPresentationStyle = .fullScreen
        self.viewController?.present(scannerVC, animated: true, completion: nil)
    }

    func createCharacter(named characterName: String, position: CGPoint) -> SKSpriteNode {
        let character = SKSpriteNode(imageNamed: "\(characterName)Idle0")
        character.position = position
        character.name = characterName

        character.zPosition = 1
        addChild(character)

        let labelText: String
        let fontName: String
        var requiredLevel: Int = 0

        switch characterName {
        case "Enchantress":
            labelText = "銅牌"
            fontName = "Arial-BoldMT"
            requiredLevel = 0

        case "Knight":
            labelText = "銀牌"
            fontName = "HelveticaNeue-Bold"
            requiredLevel = 200

        case "Musketeer":
            labelText = "金牌"
            fontName = "Courier-Bold"
            requiredLevel = 500

        case "Wizard":
            labelText = "大師"
            fontName = "Courier-Bold"
            requiredLevel = 1000

        default:
            labelText = "鐵牌"
            fontName = "Helvetica"
            requiredLevel = 0
        }

        character.userData = ["requiredLevel": requiredLevel]

        if !labelText.isEmpty {
            let label = SKLabelNode(text: labelText)
            label.fontName = fontName
            label.fontSize = 20
            label.fontColor = UIColor(named: "HomeTextColor")

            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: character.size.height / 2 + 10)
            label.name = "label"

            let backgroundSize = CGSize(width: label.frame.width + 15, height: label.frame.height + 5)

            let background = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(origin: .zero, size: backgroundSize), cornerRadius: 10).cgPath)
            background.fillColor = UIColor(named: "HomeTextBackGround") ?? .white
            background.strokeColor = .clear
            background.alpha = 0.8

            background.position = CGPoint(x: label.position.x - backgroundSize.width / 2, y: label.position.y - backgroundSize.height / 2)

            character.addChild(background)
            character.addChild(label)
        }

        return character
    }

    func runRandomAction(for character: SKSpriteNode, characterName: String) {
        if characterName == "Enchantress" {
            stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 7, timePerFrame: 0.4)
        } else if characterName == "Knight" {
            stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 5, timePerFrame: 0.4)
        } else if characterName == "Musketeer" || characterName == "Wizard"  {
            stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 4, timePerFrame: 0.4)
        }
    }

    func stopAnimation(_ character: SKSpriteNode, characterName: String, imageName: String, imageCount: Int, timePerFrame: Double) {
        var idleTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            idleTextures.append(texture)
        }
        let idleAnimation = SKAction.animate(with: idleTextures, timePerFrame: timePerFrame)

        let sequence = SKAction.sequence([idleAnimation, SKAction.run {
            self.runRandomAction(for: character, characterName: characterName)
        }])
        character.run(sequence)
    }

    func encodeEmail(_ email: String) -> String {
        return email.replacingOccurrences(of: ".", with: ",")
    }

    func decodeEmail(_ encodedEmail: String) -> String {
        return encodedEmail.replacingOccurrences(of: ",", with: ".")
    }
}


extension BattleGameScene: QRCodeScannerDelegate {
    func didScanQRCode(with roomID: String) {
        joinRoom(with: roomID)
    }

    func joinRoom(with roomID: String) {
        let ref = Database.database().reference()
        let email = UserDefaults.standard.string(forKey: "email") ?? "unknownEmail"
        let userEmail = email
        let playerName = UserDefaults.standard.string(forKey: "fullName") ?? "Unknown Player"

        ref.child("rooms").child(roomID).child("participants").child(encodeEmail(userEmail)).setValue([
            "name": playerName,
            "accurency": 0,
            "time": 0
        ]) { [weak self] (error, _) in
            if let error = error {
                print("Error joining room: \(error.localizedDescription)")
                let errorAlert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self?.viewController?.present(errorAlert, animated: true, completion: nil)
            } else {
                let roomVC = RoomViewController()
                roomVC.roomID = roomID
                roomVC.modalPresentationStyle = .fullScreen
                self?.viewController?.present(roomVC, animated: true, completion: nil)
            }
        }
    }
}
