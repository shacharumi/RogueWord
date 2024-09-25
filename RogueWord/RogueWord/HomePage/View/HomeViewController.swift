//
//  HomeViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/24.
//

import UIKit
import SnapKit
import SpriteKit

class HomeViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isUserInteractionEnabled = false
        scrollView.bounces = false
        return scrollView
    }()
    
    var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "HomeBackGround")
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var squareView: SKView!
    var homeModel = HomeModel()
    var animateModel = AnimateModel()
    var characterNode: SKSpriteNode!
    var personData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupView()
        
        squareView = SKView()
        squareView.backgroundColor = .clear
        backgroundImageView.addSubview(squareView)

        squareView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.layoutIfNeeded()

        let sceneSize = CGSize(width: backgroundImageView.frame.width, height: backgroundImageView.frame.height)
        let scene = SKScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear

        squareView.presentScene(scene)

        characterNode = SKSpriteNode(imageNamed: "Idle (0_0)")
        characterNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        scene.addChild(characterNode)

        animateModel.idleAnimate(on: characterNode)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToLevelPage))
        squareView.addGestureRecognizer(tapGesture)
        scrollView.isUserInteractionEnabled = true
        
        homeModel.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(generateRandomPoint), userInfo: nil, repeats: true)
        
        
    }
    
   
    
    @objc func generateRandomPoint() {
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let randomPoint = homeModel.generateRandomPoint(in: visibleRect)
        generatePoint(at: randomPoint)
    }
    
    func generatePoint(at position: CGPoint) {
        if homeModel.points.count >= 1 {
            homeModel.points.first?.removeFromParent()
            homeModel.points.removeAll()
        }
        
        let slimeNode = SKSpriteNode(imageNamed: "Walk (0_0)")
        slimeNode.position = position
        animateModel.slimeWalkAnimate(on: slimeNode)
        
        if let scene = squareView.scene {
            scene.addChild(slimeNode)
            homeModel.points.append(slimeNode)
        }
        
        moveSquareToPoint(slimeNode)
    }
    
    func moveSquareToPoint(_ slimeNode: SKSpriteNode) {
        homeModel.moveSquare(characterNode, to: slimeNode, scrollView: scrollView, animateModel: animateModel) {
            print("Character reached the slime.")
        }
    }
    
    func setupView() {
        view.addSubview(scrollView)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        scrollView.delegate = self
        scrollView.addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            if let imageSize = backgroundImageView.image?.size {
                make.width.equalTo(imageSize.width)
                make.height.equalTo(imageSize.height)
            } else {
                make.width.equalTo(scrollView)
                make.height.equalTo(scrollView)
            }
        }
        
        if let imageSize = backgroundImageView.image?.size {
            scrollView.contentSize = imageSize
            print("圖片尺寸：\(imageSize)")
        } else {
            print("未設置圖片尺寸。")
        }
        
        scrollView.setZoomScale(1.0, animated: false)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        homeModel.fetchLevelNumber() { UserData in
            if let personData = UserData {
                self.personData = personData
                
            } else {
                print("Failed to fetch LevelNumber.")
            }
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundImageView
    }
    
    @objc func pushToLevelPage() {
        let levelUpGamePage = LevelUpGamePageViewController()
       
        levelUpGamePage.levelNumber = personData?.levelNumber ?? 0
        levelUpGamePage.modalPresentationStyle = .fullScreen
        levelUpGamePage.returnLevelNumber = { data in
            self.personData?.levelNumber = data
        }
        self.present(levelUpGamePage, animated: true, completion: nil)
    }
}



struct PersonDataType: Decodable {
    var account: String
        var password: String
        var levelNumber: Int
        var friendList: [String]? // 假設 FriendList 是字符串數組
        var tag: [String]
        
        enum CodingKeys: String, CodingKey {
            case account = "Account"
            case password = "Password"
            case levelNumber = "LevelNumber"
            case friendList = "FriendList"
            case tag = "Tag"
        }
}
