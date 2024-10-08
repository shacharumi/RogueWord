import SpriteKit
import UIKit

class CollectionGameScene: SKScene {

    var enchantress: SKSpriteNode!
    var knight: SKSpriteNode!
    var musketeer: SKSpriteNode!
    var slime: SKSpriteNode!
    var tags: [String] = []
    var characterArray: [SKSpriteNode] = []
    weak var viewController: UIViewController?
    var isDragging: Bool = false // 判斷是否正在拖曳
    var selectedCharacter: SKSpriteNode?
    let viewModel = CollectionPageViewModel()
    var onDeletionComplete: (() -> Void)?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.clear

        enchantress = createCharacter(named: "Enchantress", position: CGPoint(x: frame.midX - 150, y: frame.midY))
        knight = createCharacter(named: "Knight", position: CGPoint(x: frame.midX, y: frame.midY))
        musketeer = createCharacter(named: "Musketeer", position: CGPoint(x: frame.midX + 150, y: frame.midY))
        
        slime = createCharacter(named: "Slime", position: CGPoint(x: frame.maxX - 70, y: frame.minY + 200))
        
        characterArray.append(contentsOf: [enchantress, knight, musketeer])

        runRandomAction(for: enchantress, characterName: "Enchantress")
        runRandomAction(for: knight, characterName: "Knight")
        runRandomAction(for: musketeer, characterName: "Musketeer")
        
        runIdleAnimation(for: slime, characterName: "Slime", imageName: "Idle", imageCount: 6)
        
        for i in 0..<characterArray.count {
            characterArray[i].isHidden = true
        }
        
        for i in 0..<tags.count {
            characterArray[i].isHidden = false
        }
    }

    func runIdleAnimation(for character: SKSpriteNode, characterName: String, imageName: String, imageCount: Int) {
        var idleTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            idleTextures.append(texture)
        }
        let idleAnimation = SKAction.animate(with: idleTextures, timePerFrame: 0.2)
        let repeatIdleAnimation = SKAction.repeatForever(idleAnimation)
        character.run(repeatIdleAnimation, withKey: "\(imageName)Animation")
    }

    func handleCharacterTap(_ characterName: String) {
        if characterName == "Slime" {
                let text = "1. 想要增加角色請到關卡頁面收藏單字\n2.要刪除Tag的話長按角色拖曳到這裡即可刪除"
                let alert = UIAlertController(title: "Hint", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            self.viewController?.present(alert, animated: true, completion: nil)
            
        } else {
                let collectionVC = CollectionPageViewController()
                collectionVC.characterTag = characterName
                collectionVC.modalPresentationStyle = .fullScreen
                collectionVC.onTagComplete = { [weak self] in
                    self?.onDeletionComplete?()
                }
                
            self.viewController?.present(collectionVC, animated: true, completion: nil)
            
        }
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
            labelText = tags.count > 0 ? tags[0] : "Enchantress"
            fontName = "Arial-BoldMT"
            character.name = tags.count > 0 ? tags[0] : "Enchantress"

        case "Knight":
            labelText = tags.count > 1 ? tags[1] : "Knight"
            fontName = "HelveticaNeue-Bold"
            character.name = tags.count > 1 ? tags[1] : "Knight"

        case "Musketeer":
            labelText = tags.count > 2 ? tags[2] : "Musketeer"
            fontName = "Courier-Bold"
            character.name = tags.count > 2 ? tags[2] : "Musketeer"

        case "Slime":
            labelText = "DeleteTag"
            fontName = "HelveticaNeue-Bold"
            character.name = "Slime"
            
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

    // 執行跑步動畫並移動
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)

            for node in touchedNodes {
                if let characterNode = node as? SKSpriteNode {
                    selectedCharacter = characterNode
                    isDragging = false // 重置拖曳標誌
                    break
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let character = selectedCharacter {
            let location = touch.location(in: self)
            character.position = location
            isDragging = true // 當角色移動時，設置拖曳標誌
            
            // 檢查角色是否與 slime 發生碰撞
            if character.frame.intersects(slime.frame) {
                showAlertForDeletion(character.name ?? "")
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 如果不是拖曳操作，則處理點擊
        if let character = selectedCharacter, !isDragging {
            handleCharacterTap(character.name ?? "")
        }
        selectedCharacter = nil
    }

    // 顯示刪除確認的 alert
    func showAlertForDeletion(_ tag: String) {
        if let viewController = self.view?.window?.rootViewController {
            let alert = UIAlertController(title: "刪除確認", message: "你確定要刪除嗎？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "刪除", style: .destructive, handler: { _ in
                self.selectedCharacter?.removeFromParent()
                let query = FirestoreEndpoint.fetchFolderWords.ref.whereField("Tag", isEqualTo: tag)
                let userID = UserDefaults.standard.string(forKey: "userID")
                let updateQuery = FirestoreEndpoint.fetchPersonData.ref.document(userID ?? "")
                FirestoreService.shared.deleteDocuments(matching: query) { error in
                    if let error = error {
                        print("DEBUG: 删除失败 - \(error.localizedDescription)")
                    } else {
                        print("DEBUG: 删除成功。")
                    }
                }
                self.tags.removeAll(){ $0 == tag }
                
                FirestoreService.shared.updateData(at: updateQuery, with: ["Tag":self.tags]) { error in
                    if let error = error {
                        print("DEBUG: 删除失败 - \(error.localizedDescription)")
                    } else {
                        print("DEBUG: 删除成功。")
                        self.onDeletionComplete?()
                    }
                }
            }))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

}
