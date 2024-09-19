//
//  HomeViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isUserInteractionEnabled = true
        scrollView.bounces = false // 禁止彈性滾動
        scrollView.minimumZoomScale = 0.5 // 最小縮放比例
        scrollView.maximumZoomScale = 2.0 // 最大縮放比例
        return scrollView
    }()
    
    var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "testImage") // 橫向背景圖片
        imageView.contentMode = .scaleToFill // 確保背景圖不會縮小
        imageView.isUserInteractionEnabled = true // 使其可以接收手勢
        return imageView
    }()
    
    var levelView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var squareView: UIImageView!
    var homeModel = HomeModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(0, forKey: "level")
        view.backgroundColor = .white
        
        setupView()
        
        let a = FirebaseToJSONFileUploader()
        a.fetchAndSaveWordsToJSON()
        
        // 初始化 squareView，縮小角色
        squareView = UIImageView(frame: CGRect(x: 50, y: 50, width: 40, height: 40)) // 縮小角色
        squareView.image = UIImage(named: homeModel.images[0])
        squareView.contentMode = .scaleAspectFit
        backgroundImageView.addSubview(squareView)
        
        // 添加點擊手勢
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        backgroundImageView.addGestureRecognizer(tapGesture)
        
        // 設置計時器定期生成隨機點
        homeModel.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(generateRandomPoint), userInfo: nil, repeats: true)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: backgroundImageView)
        generatePoint(at: location)
    }

    @objc func generateRandomPoint() {
        let randomPoint = homeModel.generateRandomPoint(in: backgroundImageView.bounds)
        generatePoint(at: randomPoint)
    }

    func generatePoint(at position: CGPoint) {
        if homeModel.points.count >= 1 {
            homeModel.points.first?.removeFromSuperview()
            homeModel.points.removeAll()
        }

        let pointView = UIImageView(frame: CGRect(x: position.x - 10, y: position.y - 10, width: 45, height: 45))
        pointView.image = UIImage(named: "wood")
        pointView.contentMode = .scaleAspectFit
        
        // 將生成的點添加到背景圖片中
        backgroundImageView.addSubview(pointView)

        homeModel.points.append(pointView)
        moveSquareToPoint(pointView)
    }

    func moveSquareToPoint(_ pointView: UIImageView) {
        homeModel.moveSquare(squareView, to: pointView, scrollView: scrollView) {
            self.homeModel.animateWood(pointView: pointView) {
                print("Wood animation completed.")
            }
        }
    }

    func setupView() {
        view.addSubview(scrollView)
        view.addSubview(levelView)
        
        scrollView.delegate = self // 設置 scrollView 的 delegate
        
        // 將背景圖片加到 scrollView 中
        scrollView.addSubview(backgroundImageView)
        
        // 設置 scrollView 的 contentSize 為背景圖片的大小
        if let imageSize = backgroundImageView.image?.size {
            backgroundImageView.frame = CGRect(origin: .zero, size: imageSize)
            scrollView.contentSize = imageSize
        }

        // 設置初始的縮放比例
        scrollView.setZoomScale(1.0, animated: false)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        levelView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(50)
        }

        let levelButton = UIButton()
        levelButton.setTitle("開始修煉", for: .normal)
        levelButton.titleLabel?.textAlignment = .center
        levelButton.backgroundColor = .lightGray
        levelView.addSubview(levelButton)
        
        levelButton.snp.makeConstraints { make in
            make.top.equalTo(levelView)
            make.height.equalTo(levelView)
            make.centerX.equalTo(levelView)
        }
        
        levelButton.addTarget(self, action: #selector(pushToLevelPage(_:)), for: .touchUpInside)
    }

    // UIScrollViewDelegate - 指定要縮放的視圖
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundImageView
    }

    @objc func pushToLevelPage(_ sender: UIButton) {
        let levelUpGamePage = LevelUpGamePageViewController()
        self.navigationController?.pushViewController(levelUpGamePage, animated: true)
    }
}
