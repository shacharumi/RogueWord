//
//  TabBarController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//

import UIKit

class TabBarController: UITabBarController {

    private var customTabBarView: UIView!
    private var tabBarButtons: [UIButton] = []

    // 从 Storyboard 加载时，必须实现 init(coder:)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        // 隐藏默认的 TabBar
        tabBar.isHidden = true

        // 自定义 TabBar 的高度
        let height: CGFloat = 60

        // 创建自定义的 TabBar 视图
        customTabBarView = UIView(frame: CGRect(x: 20, y: view.frame.height - height - 20 - view.safeAreaInsets.bottom, width: view.frame.width - 40, height: height))
        customTabBarView.backgroundColor = .black
        customTabBarView.layer.cornerRadius = height / 2
        customTabBarView.layer.shadowColor = UIColor.black.cgColor
        customTabBarView.layer.shadowOpacity = 0.2
        customTabBarView.layer.shadowOffset = CGSize(width: 0, height: 5)
        customTabBarView.layer.shadowRadius = 10

        view.addSubview(customTabBarView)

        // 设置 TabBar 按钮的图标
        let tabBarButtonImages = ["house", "pencil.and.list.clipboard", "books.vertical", "gamecontroller", "gearshape"]
        let numberOfButtons = tabBarButtonImages.count
        let buttonWidth = customTabBarView.frame.width / CGFloat(numberOfButtons)

        // 创建 TabBar 按钮
        for (index, imageName) in tabBarButtonImages.enumerated() {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: customTabBarView.frame.height)
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = .gray
            button.tag = index
            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
            customTabBarView.addSubview(button)
            tabBarButtons.append(button)
        }

        updateSelectedTab(index: 0)
    }

    @objc private func tabBarButtonTapped(_ sender: UIButton) {
        // 触感反馈
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()

        let fromView = selectedViewController?.view
        let toView = viewControllers?[sender.tag].view
        
        guard let fromView = fromView, let toView = toView, fromView != toView else { return }

        // 在这里添加淡入淡出动画效果
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve]) { finished in
            if finished {
                self.selectedIndex = sender.tag
            }
        }

        updateSelectedTab(index: sender.tag)
    }

    private func updateSelectedTab(index: Int) {
        for (i, button) in tabBarButtons.enumerated() {
            if i == index {
                UIView.animate(withDuration: 0.3, animations: {
                    button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    button.tintColor = .orange
                })
            } else {
                // 未选中状态
                UIView.animate(withDuration: 0.3, animations: {
                    button.transform = CGAffineTransform.identity
                    button.tintColor = .gray
                })
            }
        }
    }

    // 调整自定义 TabBar 的布局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height: CGFloat = 60
        customTabBarView.frame = CGRect(x: 20, y: view.frame.height - height - 20 - view.safeAreaInsets.bottom, width: view.frame.width - 40, height: height)
    }

    // 控制自定义 TabBar 的显示和隐藏
    func setCustomTabBarHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.customTabBarView.alpha = hidden ? 0 : 1
            }
        } else {
            customTabBarView.alpha = hidden ? 0 : 1
        }
    }
}
