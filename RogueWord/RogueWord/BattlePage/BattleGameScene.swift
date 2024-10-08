//
//  BattleGameScene.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//

import SpriteKit
import UIKit

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
        
        disableUnavailableCharacters()
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
        guard let requiredLevel = Int(characterName) else { return }
        let rankScore = rank.rankScore

        if Int(rankScore) < requiredLevel {
            node.removeAllActions()
            
            node.color = .darkGray
            node.colorBlendFactor = 1.0
            
            node.name = nil
            
            let alert = UIAlertController(title: "排位不足", message: "請先提高牌位", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            //self.viewController?.present(alert, animated: true, completion: nil)
            return
        }

        let battlePage = BattleViewController()
        battlePage.rank = rank
        battlePage.modalPresentationStyle = .fullScreen
        self.viewController?.present(battlePage, animated: true, completion: nil)
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
            labelText = "銅牌"
            fontName = "Arial-BoldMT"
            character.name = "0"

        case "Knight":
            labelText = "銀牌"
            fontName = "HelveticaNeue-Bold"
            character.name = "200"

        case "Musketeer":
            labelText = "金牌"
            fontName = "Courier-Bold"
            character.name = "500"
            
        case "Wizard":
            labelText = "大師"
            fontName = "Courier-Bold"
            character.name = "1000"

        default:
            labelText = "鐵牌"
            fontName = "Helvetica"
            character.name = "0"
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

    func disableUnavailableCharacters() {
        guard let rank = self.rank else {
            print("Rank 未設置")
            return
        }
        let rankScore = Int(rank.rankScore) ?? 0

        let characters: [(node: SKSpriteNode, name: String)] = [
            (enchantress, enchantress.name ?? ""),
            (knight, knight.name ?? ""),
            (musketeer, musketeer.name ?? ""),
            (wizard, wizard.name ?? "")
        ]

        for (character, name) in characters {
            guard let requiredLevel = Int(name) else { continue }
            
            if rankScore < requiredLevel {
                disableCharacter(character)
            }
        }
    }

    func disableCharacter(_ character: SKSpriteNode) {
        character.removeAllActions()
        
        character.color = .darkGray
        character.colorBlendFactor = 1.0
        
        character.name = nil
    }
}
