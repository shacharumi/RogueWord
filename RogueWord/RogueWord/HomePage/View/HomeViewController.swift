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
        scrollView.bounces = false
       
        return scrollView
    }()
    
    var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "RockBackGround")
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
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
        
        squareView = UIImageView(frame: CGRect(x: view.frame.width / 2 , y: view.frame.height / 2, width: 100, height: 100))
        squareView.image = UIImage(named: homeModel.images[0])
        squareView.contentMode = .scaleAspectFit
        backgroundImageView.addSubview(squareView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToLevelPage(_:)))
        squareView.addGestureRecognizer(tapGesture)
        squareView.isUserInteractionEnabled = true
        
        homeModel.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(generateRandomPoint), userInfo: nil, repeats: true)
    }

    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: backgroundImageView)
        generatePoint(at: location)
        
    }

    @objc func generateRandomPoint() {
        let screenSize = UIScreen.main.bounds
        let randomPoint = homeModel.generateRandomPoint(in: screenSize)
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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        scrollView.delegate = self
        
        scrollView.addSubview(backgroundImageView)
        
        if let imageSize = backgroundImageView.image?.size {
            backgroundImageView.frame = CGRect(origin: .zero, size: imageSize)
            scrollView.contentSize = imageSize
        }
        
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
        
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundImageView
    }

    @objc func pushToLevelPage(_ sender: UIButton) {
        let levelUpGamePage = LevelUpGamePageViewController()
        levelUpGamePage.modalPresentationStyle = .fullScreen 
        self.present(levelUpGamePage, animated: true, completion: nil)
    }

}
