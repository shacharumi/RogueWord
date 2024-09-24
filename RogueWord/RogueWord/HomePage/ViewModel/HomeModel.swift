//
//  HomeModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/24.
//

import Foundation
import UIKit
import SpriteKit

class HomeModel {
    
    enum CharacterState {
            case idle
            case running
            case attacking
        }
        
        var characterState: CharacterState = .idle
        
        var points: [SKSpriteNode] = []
        
        var timer: Timer?
        
        var personData: PersonDataType?
    
        func generateRandomPoint(in rect: CGRect) -> CGPoint {
            let randomX = CGFloat.random(in: rect.minX...(rect.maxX - 50)) // 减去节点宽度，防止超出边界
            let randomY = CGFloat.random(in: rect.minY...(rect.maxY - 50)) // 减去节点高度，防止超出边界
            return CGPoint(x: randomX, y: randomY)
        }
        
        func moveSquare(_ characterNode: SKSpriteNode, to slimeNode: SKSpriteNode, scrollView: UIScrollView, animateModel: AnimateModel, completion: @escaping () -> Void) {
            guard let scene = characterNode.scene else { return }
            
            // 调整人物朝向
            if slimeNode.position.x < characterNode.position.x {
                characterNode.xScale = abs(characterNode.xScale) * -1 
            } else {
                characterNode.xScale = abs(characterNode.xScale)
            }
            
            if characterState != .running {
                characterState = .running
                characterNode.removeAllActions()
                animateModel.runRunAnimation(on: characterNode)
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                let dx = slimeNode.position.x - characterNode.position.x
                let dy = slimeNode.position.y - characterNode.position.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance <= 60 {
                    timer.invalidate()
                    if slimeNode.position.x < characterNode.position.x {
                        characterNode.xScale = abs(characterNode.xScale) * -1
                    } else {
                        characterNode.xScale = abs(characterNode.xScale)
                    }
                    self.characterState = .attacking
                    characterNode.removeAllActions()
                    let attackAnimations = [animateModel.runAttackAnimation1, animateModel.runAttackAnimation2, animateModel.runAttackAnimation3, animateModel.runAttackAnimation4]
                    if let randomAttack = attackAnimations.randomElement() {
                        randomAttack(characterNode)
                    }
                    slimeNode.removeAllActions()
                    animateModel.slimeHurtAnimation(on: slimeNode)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.characterState = .idle
                        characterNode.removeAllActions()
                        animateModel.idleAnimate(on: characterNode)
                        slimeNode.removeFromParent()
                    }
                    completion()
                } else {
                    let moveStep: CGFloat = 2.0
                    let angle = atan2(dy, dx)
                    characterNode.position.x += moveStep * cos(angle)
                    characterNode.position.y += moveStep * sin(angle)
                    
                    self.updateScrollViewContentOffset(scrollView: scrollView, centeredOn: characterNode, in: scene)
                }
            }
        }
    
    func updateScrollViewContentOffset(scrollView: UIScrollView, centeredOn characterNode: SKSpriteNode, in scene: SKScene) {
        let nodePositionInView = scene.convertPoint(toView: characterNode.position)
        let scrollViewSize = scrollView.bounds.size
        
        let offsetX = max(0, min(scrollView.contentSize.width - scrollViewSize.width, nodePositionInView.x - scrollViewSize.width / 2))
        let offsetY = max(0, min(scrollView.contentSize.height - scrollViewSize.height, nodePositionInView.y - scrollViewSize.height / 2))
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    func fetchLevelNumber(completion: @escaping (PersonDataType?) -> Void) {
        let query = FirestoreEndpoint.fetchPersonData.ref.document(account)
        
        FirestoreService.shared.getDocument(query) { (personData: PersonDataType?) in
            guard let personData = personData else {
                print("DEBUG: Failed to fetch or decode PersonDataType.")
                completion(nil)
                return
            }
            print("DEBUG: LevelNumber is \(personData.levelNumber)")
            completion(personData)
        }
    }
}
