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
    var stepsSinceLastImageChange = 0 // 記錄角色移動步數的變量
    let stepsPerImageChange = 10      // 設置每移動 10 步切換一次圖片
    
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
    
    // 移動 squareView 的邏輯，並在移動過程中更新 scrollView 的鏡頭位置
    func moveSquare(_ squareView: UIImageView, to pointView: UIImageView, scrollView: UIScrollView, completion: @escaping () -> Void) {
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
                
                // 每移動一小步就增加步數
                self.stepsSinceLastImageChange += 1
                
                // 檢查是否需要切換圖片
                if self.stepsSinceLastImageChange >= self.stepsPerImageChange {
                    squareView.image = self.getNextImage()
                    self.stepsSinceLastImageChange = 0 // 重置步數計數器
                }
                
                // 在每次 squareView 移動時更新 scrollView 的 contentOffset
                self.updateScrollViewContentOffset(scrollView: scrollView, centeredOn: squareView)
            }
        }
    }
    
    // 更新 scrollView 的偏移量，讓 squareView 保持在 scrollView 的中心
    func updateScrollViewContentOffset(scrollView: UIScrollView, centeredOn squareView: UIView) {
        let squareCenter = squareView.center
        let scrollViewSize = scrollView.bounds.size
        
        // 計算新的偏移量
        let offsetX = max(0, min(scrollView.contentSize.width - scrollViewSize.width, squareCenter.x - scrollViewSize.width / 2))
        let offsetY = max(0, min(scrollView.contentSize.height - scrollViewSize.height, squareCenter.y - scrollViewSize.height / 2))
        
        // 更新 scrollView 的 contentOffset
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false) // animated 設置為 false 以保持即時性
    }
}
