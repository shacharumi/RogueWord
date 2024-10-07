import SpriteKit
import UIKit

class HomeGameScene: SKScene {

    var enchantress: SKSpriteNode!
    var knight: SKSpriteNode!
    var musketeer: SKSpriteNode!
    var personData: UserData?
    weak var viewController: UIViewController?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.clear

        enchantress = createCharacter(named: "Enchantress", position: CGPoint(x: frame.midX - 150, y: frame.midY))
        knight = createCharacter(named: "Knight", position: CGPoint(x: frame.midX, y: frame.midY))
        musketeer = createCharacter(named: "Musketeer", position: CGPoint(x: frame.midX + 150, y: frame.midY))
        
        runRandomAction(for: enchantress, characterName: "Enchantress")
        runRandomAction(for: knight, characterName: "Knight")
        runRandomAction(for: musketeer, characterName: "Musketeer")
      
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            for node in touchedNodes {
                if let characterNode = node as? SKSpriteNode, let characterName = characterNode.name {
                    handleCharacterTap(characterName)
                    break
                }
            }
        }
    }

    func handleCharacterTap(_ characterName: String) {
        guard let personData = self.personData else { return }
        guard let requiredLevel = Int(characterName) else { return }
        let playerLevel = personData.levelData?.levelNumber ?? 0

        if playerLevel < requiredLevel {
            if let characterNode = self.childNode(withName: characterName) as? SKSpriteNode,
               let warningBox = characterNode.childNode(withName: "warningBox") as? SKShapeNode,
               let warningLabel = warningBox.childNode(withName: "warningLabel") as? SKLabelNode {

                warningLabel.text = "請先通關前面關卡\n當前通關進度: \(playerLevel)"

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
            return
        }

        let levelUpGamePage = LevelUpGamePageViewController()
        levelUpGamePage.levelNumber = personData.levelData?.levelNumber ?? 0
        levelUpGamePage.correctCount = personData.levelData?.correct ?? 0
        levelUpGamePage.wrongCount = personData.levelData?.wrong ?? 0
        levelUpGamePage.isCorrect = personData.levelData?.isCorrect ?? []
        levelUpGamePage.modalPresentationStyle = .fullScreen
        levelUpGamePage.returnLevelNumber = { [weak self] data in
            guard let self = self else { return }
            if self.personData?.levelData == nil {
                self.personData?.levelData = LevelData(correct: 0, levelNumber: data, wrong: 0, isCorrect: [])
            } else {
                self.personData?.levelData?.levelNumber = data
            }
            print("Updated levelNumber: \(data)")
        }
        viewController?.present(levelUpGamePage, animated: true, completion: nil)
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
        case "Enchantress":
            labelText = "初階關卡"
            fontName = "Arial-BoldMT"
            character.name = "0"

        case "Knight":
            labelText = "中階關卡"
            fontName = "HelveticaNeue-Bold"
            character.name = "999"

        case "Musketeer":
            labelText = "高階關卡"
            fontName = "Courier-Bold"
            character.name = "1999"

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
            
            let backgroundSize = CGSize(width: label.frame.width + 15, height: label.frame.height + 5)
            
            let background = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(origin: .zero, size: backgroundSize), cornerRadius: 10).cgPath)
            background.fillColor = UIColor(named: "HomeTextBackGround") ?? .white
            background.strokeColor = .clear
            background.alpha = 0.8
            
            background.position = CGPoint(x: label.position.x - backgroundSize.width / 2, y: label.position.y - backgroundSize.height / 2)
            
            character.addChild(background)
            character.addChild(label)
        }
        
        let warningLabel = SKLabelNode(text: "請先通關前面關卡\n當前通關進度: 初階")
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
        
        warningBox.position = CGPoint(x: 0, y: character.size.height / 2 + 80)
        character.addChild(warningBox)

        return character
    }
    
    func runRandomAction(for character: SKSpriteNode, characterName: String) {
        let randomChoice = Int.random(in: 0...5)
        
        switch randomChoice {
        case 0:
            if characterName == "Enchantress" || characterName == "Musketeer" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Run", imageCount: 13)
            } else if characterName == "Knight" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Run", imageCount: 11)
            }
        case 1:
            if characterName == "Enchantress" || characterName == "Musketeer" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Walk", imageCount: 13)
            } else if characterName == "Knight" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Walk", imageCount: 12)
            }
        case 2:
            if characterName == "Enchantress" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Jump", imageCount: 7)
            } else if characterName == "Knight" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Jump", imageCount: 5)
            } else if characterName == "Musketeer" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Jump", imageCount: 6)
            }
        case 3:
            if characterName == "Enchantress" {
                stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 7, timePerFrame: 0.5)
            } else if characterName == "Knight" {
                stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 5, timePerFrame: 0.5)
            } else if characterName == "Musketeer" {
                stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 4, timePerFrame: 0.5)
            }
        case 4:
            if characterName == "Enchantress" {
                stopAnimation(character, characterName: characterName, imageName: "Dead", imageCount: 4, timePerFrame: 0.5)
            } else if characterName == "Knight" {
                stopAnimation(character, characterName: characterName, imageName: "Dead", imageCount: 3, timePerFrame: 0.5)
            } else if  characterName == "Musketeer" {
                stopAnimation(character, characterName: characterName, imageName: "Dead", imageCount: 3, timePerFrame: 0.5)
            }
        case 5:
            if characterName == "Enchantress" {
                stopAnimation(character, characterName: characterName, imageName: "Attack", imageCount: 21, timePerFrame: 0.2)
            } else if characterName == "Knight" {
                stopAnimation(character, characterName: characterName, imageName: "Attack", imageCount: 16, timePerFrame: 0.2)
            } else if characterName == "Musketeer" {
                stopAnimation(character, characterName: characterName, imageName: "Attack", imageCount: 19, timePerFrame: 0.2)
            }
        default:
            break
        }
    }
    
    func runAnimationAndMove(_ character: SKSpriteNode, characterName: String, imageName: String, imageCount: Int) {
        var runTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            runTextures.append(texture)
        }
        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.1)
        let repeatRunAnimation = SKAction.repeatForever(runAnimation)
        
        let randomX = CGFloat.random(in: 0...(frame.size.width - 50))
        let randomY = CGFloat.random(in: 0...(frame.size.height - 50))
        let randomPoint = CGPoint(x: randomX, y: randomY)
        
        let deltaX = randomX - character.position.x
        if deltaX < 0 {
            character.xScale = -1
        } else {
            character.xScale = 1
        }
        
        if let label = character.childNode(withName: "label") as? SKLabelNode {
            label.xScale = 1 / character.xScale
        }

        if let warningBox = character.childNode(withName: "warningBox") as? SKShapeNode {
            warningBox.xScale = 1 / character.xScale
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
}
