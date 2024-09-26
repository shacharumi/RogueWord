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
        imageView.image = UIImage(named: "HomeBackground")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    var squareView: SKView!
    var homeModel = HomeModel()
    var animateModel = AnimateModel()
    var characterNode: SKSpriteNode!
    var personData: UserData?
    var isSceneSetup = false  // 用于确保场景只设置一次

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBarController?.tabBar.backgroundColor = .white
        self.tabBarController?.tabBar.tintColor = .black
        self.tabBarController?.tabBar.alpha = 0.4
        if !isSceneSetup {
            setupScene()
            isSceneSetup = true
        }
    }

    func setupScene() {
        // 初始化 squareView
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
        characterNode.setScale(1.5)
        characterNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 6)
        scene.addChild(characterNode)

        animateModel.idleAnimate(on: characterNode)
        
        // 更新 scrollView 的 contentOffset
        homeModel.updateScrollViewContentOffset(scrollView: scrollView, centeredOn: characterNode, in: scene)
        
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
            print("图片尺寸：\(imageSize)")
        } else {
            print("未设置图片尺寸。")
        }

        scrollView.setZoomScale(1.0, animated: false)

        scrollView.snp.makeConstraints { make in
//            make.top.left.right.equalTo(view)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.edges.equalTo(view)
        }

        homeModel.fetchLevelNumber { [weak self] userData in
            guard let self = self else { return }
            if let userData = userData {
                self.personData = userData
                print("Successfully fetched UserData: \(userData)")
            } else {
                print("Failed to fetch LevelNumber.")
            }
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundImageView
    }

    @objc func pushToLevelPage() {
        guard let personData = self.personData else { return }
        let levelUpGamePage = LevelUpGamePageViewController()

        levelUpGamePage.levelNumber = personData.levelData?.levelNumber ?? 0
        levelUpGamePage.correctCount = personData.levelData?.correct ?? 0
        levelUpGamePage.wrongCount = personData.levelData?.wrong ?? 0
        levelUpGamePage.isCorrect = personData.levelData?.isCorrect ?? []
        levelUpGamePage.modalPresentationStyle = .fullScreen
        levelUpGamePage.returnLevelNumber = { [weak self] data in
            guard let self = self else { return }
            if self.personData?.levelData == nil {
                self.personData?.levelData = LevelData(correct: 0, levelNumber: data, wrong: 0, isCorrect: [])
            } else {
                self.personData?.levelData?.levelNumber = data
            }
            print("Updated levelNumber: \(data)")
        }
        self.present(levelUpGamePage, animated: true, completion: nil)
    }
}
