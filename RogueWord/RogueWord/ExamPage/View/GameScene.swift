//
//  GameScene.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//
import SpriteKit

class GameScene: SKScene {

    var enchantress: SKSpriteNode!
    var knight: SKSpriteNode!
    var musketeer: SKSpriteNode!
    var Enchantress: SKSpriteNode!
    weak var viewController: UIViewController?
    var wordData: [Accurency] = []

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.clear

        enchantress = createCharacter(
            named: "SwordMan",
            position: CGPoint(x: frame.midX - 150, y: frame.midY)
        )
        knight = createCharacter(
            named: "Wizard",
            position: CGPoint(x: frame.midX, y: frame.midY)
        )
        musketeer = createCharacter(
            named: "Archer",
            position: CGPoint(x: frame.midX + 150, y: frame.midY)
        )
        Enchantress = createCharacter(
            named: "Enchantress",
            position: CGPoint(x: frame.midX, y: frame.midY + 150)
        )

        runRandomAction(for: enchantress, characterName: "SwordMan")
        runRandomAction(for: knight, characterName: "Wizard")
        runRandomAction(for: musketeer, characterName: "Archer")
        runRandomAction(for: Enchantress, characterName: "Enchantress")
    }

    func createCharacter(named characterName: String, position: CGPoint) -> SKSpriteNode {
        let character = SKSpriteNode(imageNamed: "\(characterName)Idle0")
        character.position = position
        character.name = characterName
        character.zPosition = 1
        addChild(character)

        let labelText: String
        let fontName: String

        switch characterName {
        case "SwordMan":
            labelText = "單字填空"
            fontName = "Arial-BoldMT"
        case "Wizard":
            labelText = "段落填空"
            fontName = "HelveticaNeue-Bold"
        case "Archer":
            labelText = "閱讀理解"
            fontName = "Courier-Bold"
        case "Enchantress":
            labelText = "解答室"
            fontName = "Courier-Bold"
        default:
            labelText = ""
            fontName = "Helvetica"
        }

        if !labelText.isEmpty {
            let label = SKLabelNode(text: labelText)
            label.fontName = fontName
            label.fontSize = 20
            label.fontColor = UIColor(named: "HomeTextColor")
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: character.size.height / 2 + 10)
            label.name = "label"

            let backgroundSize = CGSize(
                width: label.frame.width + 15,
                height: label.frame.height + 5
            )

            let background = SKShapeNode(
                path: UIBezierPath(
                    roundedRect: CGRect(origin: .zero, size: backgroundSize),
                    cornerRadius: 10
                ).cgPath
            )
            background.fillColor = UIColor(named: "HomeTextBackGround") ?? .white
            background.strokeColor = .clear
            background.alpha = 0.8

            background.position = CGPoint(
                x: label.position.x - backgroundSize.width / 2,
                y: label.position.y - backgroundSize.height / 2
            )

            character.addChild(background)
            character.addChild(label)
        }

        if characterName != "Enchantress" {
            let messageBox = SKShapeNode(
                rectOf: CGSize(width: 150, height: 150),
                cornerRadius: 10
            )
            messageBox.fillColor = UIColor.white.withAlphaComponent(0.8)
            messageBox.strokeColor = UIColor.black
            messageBox.lineWidth = 2
            messageBox.zPosition = 10
            messageBox.name = "messageBox"
            messageBox.isHidden = true

            let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            titleLabel.text = "測試標題"
            titleLabel.fontSize = 20
            titleLabel.fontColor = UIColor(named: "HomeTextColor")
            titleLabel.position = CGPoint(x: 0, y: 50)
            titleLabel.verticalAlignmentMode = .center
            titleLabel.name = "titleLabel"
            messageBox.addChild(titleLabel)

            let timesLabel = SKLabelNode(fontNamed: "Helvetica")
            timesLabel.text = "練習次數：0"
            timesLabel.fontSize = 18
            timesLabel.fontColor = UIColor(named: "TextColor")
            timesLabel.position = CGPoint(x: 0, y: 20)
            timesLabel.verticalAlignmentMode = .center
            timesLabel.name = "timesLabel"
            messageBox.addChild(timesLabel)

            let accuracyLabel = SKLabelNode(fontNamed: "Helvetica")
            accuracyLabel.text = "準確率：0%"
            accuracyLabel.fontSize = 18
            accuracyLabel.fontColor = UIColor(named: "TextColor")
            accuracyLabel.position = CGPoint(x: 0, y: -10)
            accuracyLabel.verticalAlignmentMode = .center
            accuracyLabel.name = "accuracyLabel"
            messageBox.addChild(accuracyLabel)

            let startPracticeLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            startPracticeLabel.text = "開始測試"
            startPracticeLabel.fontSize = 20
            startPracticeLabel.fontColor = UIColor(named: "HomeTextColor")
            startPracticeLabel.position = CGPoint(x: 0, y: -40)
            startPracticeLabel.verticalAlignmentMode = .center
            startPracticeLabel.name = "startPracticeLabel"
            startPracticeLabel.userData = ["characterName": characterName]
            messageBox.addChild(startPracticeLabel)

            messageBox.position = CGPoint(
                x: 0,
                y: character.size.height / 2 + 120
            )
            character.addChild(messageBox)
        }

        return character
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "startPracticeLabel" {
                if let characterName = node.userData?["characterName"] as? String {
                    presentCorrespondingViewController(for: characterName)
                }
                node.parent?.isHidden = true
                return
            } else if let characterNode = node as? SKSpriteNode,
                      let characterName = characterNode.name {
                if characterName == "Enchantress" {
                    presentCorrespondingViewController(for: characterName)
                    return
                }

                if let messageBox = characterNode.childNode(
                    withName: "messageBox"
                ) as? SKShapeNode {
                    updateMessageBox(
                        messageBox: messageBox,
                        characterName: characterName
                    )
                    messageBox.isHidden = false
                    messageBox.run(SKAction.sequence([
                        SKAction.wait(forDuration: 2.0),
                        SKAction.fadeOut(withDuration: 1.0),
                        SKAction.run {
                            messageBox.isHidden = true
                            messageBox.alpha = 1.0
                        }
                    ]))
                }
                hideAllMessageBoxes(except: characterNode)
                return
            } else {
                hideAllMessageBoxes()
            }
        }
    }

    func hideAllMessageBoxes(except characterToKeep: SKSpriteNode? = nil) {
        let characters = [enchantress, knight, musketeer]
        for character in characters where character != characterToKeep {
            if let messageBox = character?.childNode(withName: "messageBox") as? SKShapeNode {
                messageBox.isHidden = true
            }
        }
    }

    func updateMessageBox(messageBox: SKShapeNode, characterName: String) {
        var dataIndex = 0
        switch characterName {
        case "SwordMan":
            dataIndex = 0
        case "Wizard":
            dataIndex = 1
        case "Archer":
            dataIndex = 2
        default:
            return
        }

        guard dataIndex < wordData.count else { return }
        let data = wordData[dataIndex]

        if let titleLabel = messageBox.childNode(
            withName: "titleLabel"
        ) as? SKLabelNode {
            switch characterName {
            case "SwordMan":
                titleLabel.text = "單字測試"
            case "Wizard":
                titleLabel.text = "段落填空"
            case "Archer":
                titleLabel.text = "閱讀理解"
            default:
                titleLabel.text = "未知測試"
            }
        }

        if let timesLabel = messageBox.childNode(
            withName: "timesLabel"
        ) as? SKLabelNode {
            timesLabel.text = "練習次數：\(data.times)"
        }

        if let accuracyLabel = messageBox.childNode(
            withName: "accuracyLabel"
        ) as? SKLabelNode {
            let accuracy: String
            if data.times == 0 {
                accuracy = "0%"
            } else {
                let accuracyNumber = (Double(data.corrects) / Double(data.times)) * 100
                accuracy = String(format: "%.1f%%", accuracyNumber)
            }
            accuracyLabel.text = "準確率：\(accuracy)"
        }

        if let parentNode = messageBox.parent {
            let characterXScale = parentNode.xScale
            let scale = characterXScale < 0 ? -1 : 1
            messageBox.children.forEach { node in
                node.xScale = CGFloat(scale)
            }
        }
    }

    func presentCorrespondingViewController(for characterName: String) {
        guard let viewController = viewController else { return }

        var presentVC: UIViewController?

        switch characterName {
        case "SwordMan":
            let vc = WordFillInTheBlankPageViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.wordDatas = wordData[0]
            presentVC = vc
        case "Wizard":
            let vc = ParagraphFillInTheBlanksViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.wordDatas = wordData[1]
            presentVC = vc
        case "Archer":
            let vc = ReadingViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.wordDatas = wordData[2]
            presentVC = vc
        case "Enchantress":
            let vc = ChatRoomViewController()
            vc.modalPresentationStyle = .fullScreen
            presentVC = vc
        default:
            break
        }

        if let vcToPresent = presentVC {
            viewController.present(vcToPresent, animated: true, completion: nil)
        }
    }

    func runRandomAction(for character: SKSpriteNode, characterName: String) {
        let randomChoice = Int.random(in: 0...5)

        switch randomChoice {
        case 0:
            runAnimationAndMove(
                character,
                characterName: characterName,
                imageName: "Run",
                imageCount: 13
            )
        case 1:
            runAnimationAndMove(
                character,
                characterName: characterName,
                imageName: "Walk",
                imageCount: characterName == "Wizard" ? 11 : 13
            )
        case 2:
            runAnimationAndMove(
                character,
                characterName: characterName,
                imageName: "Jump",
                imageCount: characterName == "Wizard" ? 10 : 7
            )
        case 3:
            stopAnimation(
                character,
                characterName: characterName,
                imageName: "Idle",
                imageCount: characterName == "Enchantress" ? 7 : 2,
                timePerFrame: 0.5
            )
        case 4:
            stopAnimation(
                character,
                characterName: characterName,
                imageName: "Dead",
                imageCount: characterName == "Enchantress" ? 4 : 2,
                timePerFrame: 0.5
            )
        case 5:
            stopAnimation(
                character,
                characterName: characterName,
                imageName: "Attack",
                imageCount: characterName == "Wizard" ? 20 : 12,
                timePerFrame: 0.2
            )
        default:
            break
        }
    }

    func runAnimationAndMove(
        _ character: SKSpriteNode,
        characterName: String,
        imageName: String,
        imageCount: Int
    ) {
        var runTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            runTextures.append(texture)
        }
        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.1)
        let repeatRunAnimation = SKAction.repeatForever(runAnimation)

        let randomX = CGFloat.random(in: 0...(frame.size.width))
        let randomY = CGFloat.random(in: 0...(frame.size.height))
        let randomPoint = CGPoint(x: randomX, y: randomY)

        let deltaX = randomX - character.position.x
        character.xScale = deltaX < 0 ? -1 : 1

        if let label = character.childNode(withName: "label") as? SKLabelNode {
            label.xScale = character.xScale == -1 ? -1 : 1
        }

        character.run(repeatRunAnimation, withKey: "\(imageName)Animation")

        let moveAction = SKAction.move(to: randomPoint, duration: 7)

        let moveCompletion = SKAction.run {
            character.removeAction(forKey: "\(imageName)Animation")
            self.runRandomAction(for: character, characterName: characterName)
        }

        let sequence = SKAction.sequence([moveAction, moveCompletion])
        character.run(sequence)
    }

    func stopAnimation(
        _ character: SKSpriteNode,
        characterName: String,
        imageName: String,
        imageCount: Int,
        timePerFrame: Double
    ) {
        var idleTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            idleTextures.append(texture)
        }
        let idleAnimation = SKAction.animate(with: idleTextures, timePerFrame: timePerFrame)

        let sequence = SKAction.sequence([
            idleAnimation,
            SKAction.run {
                self.runRandomAction(for: character, characterName: characterName)
            }
        ])
        character.run(sequence)
    }
}
