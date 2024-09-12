//
//  HomeModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//


import Foundation
import UIKit

class HomeModel {
    
    // MARK: - Properties
    var currentImageIndex = 0
    var images = ["roleAnimate0", "roleAnimate1", "roleAnimate2"]
    var woodImages = ["woodAnimate0", "woodAnimate1", "woodAnimate2", "woodAnimate3"]
    
    var points: [UIImageView] = []
    
    // 定義計時器
    var timer: Timer?
    var animationTimer: Timer?

    // 更新圖片輪播
    func getNextImage() -> UIImage? {
        currentImageIndex = (currentImageIndex + 1) % images.count
        return UIImage(named: images[currentImageIndex])
    }
    
    // 生產隨機點
    func generateRandomPoint(in bounds: CGRect) -> CGPoint {
        let randomX = CGFloat.random(in: 0...bounds.width)
        let randomY = CGFloat.random(in: 0...bounds.height)
        return CGPoint(x: randomX, y: randomY)
    }
    
    // 管理小木頭動畫
    func animateWood(pointView: UIImageView, completion: @escaping () -> Void) {
        var imageIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if imageIndex < self.woodImages.count {
                pointView.image = UIImage(named: self.woodImages[imageIndex])
                imageIndex += 1
            } else {
                UIView.animate(withDuration: 1.0, animations: {
                    pointView.alpha = 0
                }) { _ in
                    pointView.removeFromSuperview()
                    timer.invalidate()
                    completion()
                }
            }
        }
    }
    
    // 移動 squareView 的邏輯
    func moveSquare(_ squareView: UIImageView, to pointView: UIImageView, completion: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            let dx = pointView.center.x - squareView.center.x
            let dy = pointView.center.y - squareView.center.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance <= 30 {
                timer.invalidate()
                completion()
            } else {
                let moveStep: CGFloat = 2.0
                let angle = atan2(dy, dx)
                squareView.center.x += moveStep * cos(angle)
                squareView.center.y += moveStep * sin(angle)
            }
        }
    }
}

