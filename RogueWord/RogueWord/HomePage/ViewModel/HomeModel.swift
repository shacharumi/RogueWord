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
    var personData: UserData?

    // 隨機生成的點只會出現在 Y = -100 且位於螢幕左右邊緣
    func generateRandomPoint(in rect: CGRect) -> CGPoint {
        let screenWidth = rect.width
        let randomX: CGFloat

        // 隨機決定點是在左邊還是右邊
        if Bool.random() {
            randomX = rect.minX  // 左邊
        } else {
            randomX = rect.maxX  // 右邊
        }

        let randomY: CGFloat = 200  // 固定 Y 為 100

        return CGPoint(x: randomX, y: randomY)
    }

    // 為生成的物體設置移動行為，讓其朝某個方向移動
    func moveGeneratedObject(_ objectNode: SKSpriteNode, in rect: CGRect) {
        let destinationY: CGFloat = rect.maxY // 目標是向上移動，離開螢幕
        let moveAction = SKAction.moveTo(y: destinationY, duration: 5.0) // 5秒內向上移動
        objectNode.run(moveAction)
    }

    // 移動邏輯：當物體距離 slimeNode 還剩 60 時停止移動
    func moveSquare(_ characterNode: SKSpriteNode, to slimeNode: SKSpriteNode, scrollView: UIScrollView, animateModel: AnimateModel, completion: @escaping () -> Void) {
        guard let scene = characterNode.scene else { return }

        // 調整角色朝向
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

            // 當距離剩下60時停止移動
            if distance <= 100 {
                timer.invalidate()
                if slimeNode.position.x < characterNode.position.x {
                    characterNode.xScale = abs(characterNode.xScale) * -1
                } else {
                    characterNode.xScale = abs(characterNode.xScale)
                }
                self.characterState = .attacking
                characterNode.removeAllActions()
                
                // 隨機選擇一個攻擊動畫
                let attackAnimations = [animateModel.runAttackAnimation1, animateModel.runAttackAnimation2, animateModel.runAttackAnimation3, animateModel.runAttackAnimation4]
                if let randomAttack = attackAnimations.randomElement() {
                    randomAttack(characterNode)
                }

                slimeNode.removeAllActions()
                animateModel.slimeHurtAnimation(on: slimeNode)
                
                // 延遲1秒後角色恢復閒置狀態並移除 slimeNode
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.characterState = .idle
                    characterNode.removeAllActions()
                    animateModel.idleAnimate(on: characterNode)
                    slimeNode.removeFromParent()
                }
                completion()
            } else {
                // 持續移動直到距離剩下60
                let moveStep: CGFloat = 2.0
                let angle = atan2(dy, dx)
                characterNode.position.x += moveStep * cos(angle)
                characterNode.position.y += moveStep * sin(angle)

                self.updateScrollViewContentOffset(scrollView: scrollView, centeredOn: characterNode, in: scene)
            }
        }
    }

    // 更新 scrollView 內容偏移量，讓角色保持居中
    func updateScrollViewContentOffset(scrollView: UIScrollView, centeredOn characterNode: SKSpriteNode, in scene: SKScene) {
        let nodePositionInView = scene.convertPoint(toView: characterNode.position)
        let scrollViewSize = scrollView.bounds.size

        let offsetX = max(0, min(scrollView.contentSize.width - scrollViewSize.width, nodePositionInView.x - scrollViewSize.width / 2))
        let offsetY = max(0, min(scrollView.contentSize.height - scrollViewSize.height, nodePositionInView.y - scrollViewSize.height / 2))

        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }

    // 獲取用戶數據
    func fetchLevelNumber(completion: @escaping (UserData?) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID not found.")
            completion(nil)
            return
        }

        let docRef = FirestoreEndpoint.fetchPersonData.ref.document(userID)

        FirestoreService.shared.getDocument(docRef) { (personData: UserData?) in
            if let personData = personData {
                print("DEBUG here \(personData)")
                completion(personData)
            } else {
                print("DEBUG: Failed to fetch or decode UserData.")
                completion(nil)
            }
        }
    }
}
