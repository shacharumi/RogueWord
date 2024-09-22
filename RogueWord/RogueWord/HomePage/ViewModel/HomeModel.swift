//
//  HomeModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import Foundation
import UIKit

class HomeModel {
    
    var currentImageIndex = 0
    var images = ["roleAnimate0", "roleAnimate1", "roleAnimate2"]
    var woodImages = ["woodAnimate0", "woodAnimate1", "woodAnimate2", "woodAnimate3"]
    
    var points: [UIImageView] = []
    var stepsSinceLastImageChange = 0
    let stepsPerImageChange = 10
    
    var timer: Timer?
    var animationTimer: Timer?

    func getNextImage() -> UIImage? {
        currentImageIndex = (currentImageIndex + 1) % images.count
        return UIImage(named: images[currentImageIndex])
    }
    
    func generateRandomPoint(in bounds: CGRect) -> CGPoint {
        let randomX = CGFloat.random(in: 0...bounds.width)
        let randomY = CGFloat.random(in: 0...bounds.height)
        return CGPoint(x: randomX, y: randomY)
    }
    
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
                
                self.stepsSinceLastImageChange += 1
                
                // 檢查是否需要切換圖片
                if self.stepsSinceLastImageChange >= self.stepsPerImageChange {
                    squareView.image = self.getNextImage()
                    self.stepsSinceLastImageChange = 0
                }
                
                self.updateScrollViewContentOffset(scrollView: scrollView, centeredOn: squareView)
            }
        }
    }
    
    func updateScrollViewContentOffset(scrollView: UIScrollView, centeredOn squareView: UIView) {
        let squareCenter = squareView.center
        let scrollViewSize = scrollView.bounds.size
        
        let offsetX = max(0, min(scrollView.contentSize.width - scrollViewSize.width, squareCenter.x - scrollViewSize.width / 2))
        let offsetY = max(0, min(scrollView.contentSize.height - scrollViewSize.height, squareCenter.y - scrollViewSize.height / 2))
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false) // animated 設置為 false 以保持即時性
    }
}
