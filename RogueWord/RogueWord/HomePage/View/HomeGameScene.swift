//
//  HomeGameScene.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//


import SpriteKit
import UIKit

class HomeGameScene: SKScene {


    var viewModel: HomeGameSceneViewModel!
    weak var viewController: UIViewController?
    var characterNodes: [Int: SKSpriteNode] = [:]
    var personData: UserData?


    override func didMove(to view: SKView) {
           super.didMove(to: view)
           self.backgroundColor = UIColor.clear

           viewModel = HomeGameSceneViewModel(personData: personData)

           viewModel.onCharactersUpdated = { [weak self] in
               self?.setupCharacters()
           }

           viewModel.createCharacters()
       }


    func setupCharacters() {
        for node in characterNodes.values {
            node.removeFromParent()
        }
        characterNodes.removeAll()

        for character in viewModel.characters {
            let characterNode = createCharacterNode(for: character)
            characterNode.position = CGPoint(x: frame.midX + character.position.x, y: frame.midY + character.position.y)
            addChild(characterNode)
            characterNodes[character.characterID] = characterNode

            runRandomAction(for: characterNode, character: character)
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            for node in touchedNodes {
                if let characterNode = node as? SKSpriteNode, let characterIDString = characterNode.name, let characterID = Int(characterIDString) {
                    handleCharacterTap(characterID)
                    break
                }
            }
        }
    }

    func handleCharacterTap(_ characterID: Int) {
        viewModel.handleCharacterTap(characterID: characterID) { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .showWarning(let message):
                if let characterNode = self.characterNodes[characterID] {
                    self.showWarning(message: message, on: characterNode)
                }
            case .navigateToLevelUpGame:
                let levelUpGamePage = LevelUpGamePageViewController()
                levelUpGamePage.levelNumber = self.viewModel.personData?.levelData?.levelNumber ?? 0
                levelUpGamePage.correctCount = self.viewModel.personData?.levelData?.correct ?? 0
                levelUpGamePage.wrongCount = self.viewModel.personData?.levelData?.wrong ?? 0
                levelUpGamePage.isCorrect = self.viewModel.personData?.levelData?.isCorrect ?? []
                levelUpGamePage.modalPresentationStyle = .fullScreen
                levelUpGamePage.returnLevelNumber = { [weak self] data in
                    guard let self = self else { return }
                    if self.viewModel.personData?.levelData == nil {
                        self.viewModel.personData?.levelData = LevelData(correct: 0, levelNumber: data, wrong: 0, isCorrect: [])
                    } else {
                        self.viewModel.personData?.levelData?.levelNumber = data
                    }
                    print("Updated levelNumber: \(data)")
                }
                self.viewController?.present(levelUpGamePage, animated: true, completion: nil)
            case .navigateToSentenceFillGame:
                let fillLevelUpGamePage = SentenceFillGamePageViewController()
                fillLevelUpGamePage.levelNumber = self.viewModel.personData?.fillLevelData?.levelNumber ?? 0
                fillLevelUpGamePage.correctCount = self.viewModel.personData?.fillLevelData?.correct ?? 0
                fillLevelUpGamePage.wrongCount = self.viewModel.personData?.fillLevelData?.wrong ?? 0
                fillLevelUpGamePage.isCorrect = self.viewModel.personData?.fillLevelData?.isCorrect ?? []
                fillLevelUpGamePage.modalPresentationStyle = .fullScreen
                fillLevelUpGamePage.returnLevelNumber = { [weak self] data in
                    guard let self = self else { return }
                    if self.viewModel.personData?.fillLevelData == nil {
                        self.viewModel.personData?.fillLevelData = LevelData(correct: 0, levelNumber: data, wrong: 0, isCorrect: [])
                    } else {
                        self.viewModel.personData?.fillLevelData?.levelNumber = data
                    }
                    print("Updated levelNumber: \(data)")
                }
                self.viewController?.present(fillLevelUpGamePage, animated: true, completion: nil)
            }
        }
    }


    func createCharacterNode(for character: GameCharacter) -> SKSpriteNode {
        let characterNode = SKSpriteNode(imageNamed: "\(character.name)Idle0")
        characterNode.name = "\(character.characterID)"
        characterNode.zPosition = 1

        let label = SKLabelNode(text: character.displayName)
        label.fontName = character.fontName
        label.fontSize = 20
        label.fontColor = UIColor(named: "HomeTextColor")
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: characterNode.size.height / 2 + 10)
        label.name = "label"

        let backgroundSize = CGSize(width: label.frame.width + 15, height: label.frame.height + 5)
        let background = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(origin: .zero, size: backgroundSize), cornerRadius: 10).cgPath)
        background.fillColor = UIColor(named: "HomeTextBackGround") ?? .white
        background.strokeColor = .clear
        background.alpha = 0.8
        background.position = CGPoint(x: label.position.x - backgroundSize.width / 2, y: label.position.y - backgroundSize.height / 2)

        characterNode.addChild(background)
        characterNode.addChild(label)

        let warningLabel = SKLabelNode(text: "")
        warningLabel.fontName = "Arial-BoldMT"
        warningLabel.fontSize = 14
        warningLabel.fontColor = .white
        warningLabel.verticalAlignmentMode = .center
        warningLabel.horizontalAlignmentMode = .center
        warningLabel.numberOfLines = 2
        warningLabel.name = "warningLabel"

        let padding: CGFloat = 20
        let warningBoxWidth = warningLabel.frame.width + padding
        let warningBoxHeight = warningLabel.frame.height + padding

        let warningBox = SKShapeNode(rectOf: CGSize(width: warningBoxWidth, height: warningBoxHeight), cornerRadius: 10)
        warningBox.fillColor = UIColor.red.withAlphaComponent(0.7)
        warningBox.strokeColor = .clear
        warningBox.zPosition = 10
        warningBox.isHidden = true
        warningBox.name = "warningBox"

        warningBox.addChild(warningLabel)
        warningLabel.position = CGPoint(x: 0, y: 0)

        warningBox.position = CGPoint(x: 0, y: characterNode.size.height / 2 + 80)
        characterNode.addChild(warningBox)

        return characterNode
    }


    func showWarning(message: String, on characterNode: SKSpriteNode) {
        if let warningBox = characterNode.childNode(withName: "warningBox") as? SKShapeNode,
           let warningLabel = warningBox.childNode(withName: "warningLabel") as? SKLabelNode {
            
            warningLabel.text = message
            
            let padding: CGFloat = 20
            let warningBoxWidth = warningLabel.frame.width + padding
            let warningBoxHeight = warningLabel.frame.height + padding
            
            let newRect = CGRect(x: -warningBoxWidth / 2, y: -warningBoxHeight / 2, width: warningBoxWidth, height: warningBoxHeight)
            let newPath = UIBezierPath(roundedRect: newRect, cornerRadius: 10).cgPath
            warningBox.path = newPath
            
            warningLabel.position = CGPoint(x: 0, y: 0)
            
            warningBox.xScale = 1 / characterNode.xScale
            
            warningBox.isHidden = false
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let wait = SKAction.wait(forDuration: 2.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let hideAction = SKAction.run {
                warningBox.isHidden = true
            }
            let sequence = SKAction.sequence([fadeIn, wait, fadeOut, hideAction])
            warningBox.run(sequence)
        }
    }


    func runRandomAction(for characterNode: SKSpriteNode, character: GameCharacter) {
        let action = viewModel.getRandomAction(for: character)
        switch action.actionName {
        case "Run":
            runAnimationAndMove(characterNode, character: character, imageName: "Run")
        case "Walk":
            runAnimationAndMove(characterNode, character: character, imageName: "Walk")
        case "Jump", "Idle", "Dead", "Attack":
            stopAnimation(characterNode, character: character, imageName: action.actionName)
        default:
            break
        }
    }

    func runAnimationAndMove(_ characterNode: SKSpriteNode, character: GameCharacter, imageName: String) {
        var textures: [SKTexture] = []
        let imageCount = getImageCount(characterName: character.name, actionName: imageName)
        for i in 0...imageCount {
            let textureName = "\(character.name)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        let animation = SKAction.animate(with: textures, timePerFrame: 0.1)
        let repeatAnimation = SKAction.repeatForever(animation)

        let randomX = CGFloat.random(in: 0...(size.width - 50))
        let randomY = CGFloat.random(in: 0...(size.height - 50))
        let randomPoint = CGPoint(x: randomX, y: randomY)

        let deltaX = randomX - characterNode.position.x
        if deltaX < 0 {
            characterNode.xScale = -1
        } else {
            characterNode.xScale = 1
        }

        if let label = characterNode.childNode(withName: "label") as? SKLabelNode {
            label.xScale = 1 / characterNode.xScale
        }

        if let warningBox = characterNode.childNode(withName: "warningBox") as? SKShapeNode {
            warningBox.xScale = 1 / characterNode.xScale
        }

        characterNode.run(repeatAnimation, withKey: "\(imageName)Animation")

        let moveAction = SKAction.move(to: randomPoint, duration: 7)

        let moveCompletion = SKAction.run { [weak self] in
            characterNode.removeAction(forKey: "\(imageName)Animation")
            self?.runRandomAction(for: characterNode, character: character)
        }

        let sequence = SKAction.sequence([moveAction, moveCompletion])
        characterNode.run(sequence)
    }

    func stopAnimation(_ characterNode: SKSpriteNode, character: GameCharacter, imageName: String) {
        var textures: [SKTexture] = []
        let imageCount = getImageCount(characterName: character.name, actionName: imageName)
        let timePerFrame = getTimePerFrame(actionName: imageName)
        for i in 0...imageCount {
            let textureName = "\(character.name)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        let animation = SKAction.animate(with: textures, timePerFrame: timePerFrame)

        let sequence = SKAction.sequence([animation, SKAction.run { [weak self] in
            self?.runRandomAction(for: characterNode, character: character)
        }])
        characterNode.run(sequence)
    }

    func getImageCount(characterName: String, actionName: String) -> Int {
        switch (characterName, actionName) {
        case ("Enchantress", "Run"), ("Musketeer", "Run"):
            return 13
        case ("Knight", "Run"):
            return 11
        case ("Enchantress", "Walk"), ("Musketeer", "Walk"):
            return 13
        case ("Knight", "Walk"):
            return 12
        case ("Enchantress", "Jump"):
            return 7
        case ("Knight", "Jump"):
            return 5
        case ("Musketeer", "Jump"):
            return 6
        case ("Enchantress", "Idle"):
            return 7
        case ("Knight", "Idle"):
            return 5
        case ("Musketeer", "Idle"):
            return 4
        case ("Enchantress", "Dead"):
            return 4
        case ("Knight", "Dead"), ("Musketeer", "Dead"):
            return 3
        case ("Enchantress", "Attack"):
            return 21
        case ("Knight", "Attack"):
            return 16
        case ("Musketeer", "Attack"):
            return 19
        default:
            return 0
        }
    }

    func getTimePerFrame(actionName: String) -> Double {
        switch actionName {
        case "Attack":
            return 0.2
        default:
            return 0.5
        }
    }
}
