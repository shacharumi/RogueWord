//
//  LoginViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import Foundation
import UIKit

class LoginViewModel {
    var imageNames = ["roleAnimate0", "roleAnimate1", "roleAnimate2"]
    var currentImageIndex = 0
    var tapTimes = 0
    var stringToDisplay = ""  // 需要逐字显示的字符串
    var currentCharacterIndex = 0  // 当前显示的字符位置
    var roleImageChanged: ((UIImage?) -> Void)?
    var stringUpdated: ((String) -> Void)?
    var imageTimer: Timer?
    var typingTimer: Timer?

    // 根据tap次数决定显示的内容和动画
    func handleTap() {
        tapTimes += 1
        switch tapTimes {
        case 1:
            stringToDisplay = "我不太清楚你來這裡的原因，但我相信你心裡已經有了答案"
            animateTextAppearance()
        case 2:
            stringToDisplay = "我知道你有著無比的決心，想要完成一些重要的事情"
            animateTextAppearance()
        case 3:
            stringToDisplay = "我是個在旅途中學習和成長的旅人"
            animateTextAppearance()
        case 4:
            updateRoleImage(with: "witch")
            stringToDisplay = "我見過努力追求夢想的學徒，渴望成為偉大的魔法師"
            animateTextAppearance()
        case 5:
            updateRoleImage(with: "dragon")
            stringToDisplay = "也曾見過翱翔天空的巨龍，那是我未曾忘懷的壯麗一幕"
            animateTextAppearance()
        case 6:
            updateRoleImage(with: "person")
            stringToDisplay = "還有像你們這樣，懷抱著夢想和希望的人們"
            animateTextAppearance()
        case 7:
            updateRoleImage(with: "roleAnimate0")
            stringToDisplay = "現在，我將踏上新的旅程"
            animateTextAppearance()
        case 8:
            stringToDisplay = "你願意和我一起走下去嗎？"
            animateTextAppearance()
        default:
            break
        }
    }

    // 用于更新角色图片
    func updateRoleImage(with imageName: String) {
        roleImageChanged?(UIImage(named: imageName))
    }

    
    func animateTextAppearance() {
        // 重置文字並設置透明度為 0
        stringUpdated?(stringToDisplay)
        
        // 確保 ViewController 中的 UILabel 開始時透明度為 0
        UIView.animate(withDuration: 1) {
            // 通過回調更新 UILabel 的 alpha 來實現淡入效果
            self.stringUpdated?(self.stringToDisplay)
        }
    }


    // 开始图片切换动画
    func startImageAnimation() {
        stopImageAnimation()
        imageTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(animateRoleImage), userInfo: nil, repeats: true)
    }
    
    // 停止图片切换动画
    func stopImageAnimation() {
        imageTimer?.invalidate()
        imageTimer = nil
    }

    // 切换图片
    @objc func animateRoleImage() {
        currentImageIndex = (currentImageIndex + 1) % imageNames.count
        roleImageChanged?(UIImage(named: imageNames[currentImageIndex]))
    }
}
