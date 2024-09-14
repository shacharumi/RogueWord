//
//  HomeViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//
import UIKit
import SnapKit

class HomeViewController: UIViewController {

    // MARK: - Properties
    
    var animateView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "BackGround")
        return view
    }()
    
    var levelView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var squareView: UIImageView!
    var levelButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    
    
    var homeModel = HomeModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(0, forKey: "level")
        view.backgroundColor = .white
        setupView()
        let a = FirebaseToJSONFileUploader()
        a.fetchAndSaveWordsToJSON()
        squareView = UIImageView(frame: CGRect(x: 50, y: 50, width: 80, height: 80))
        squareView.image = UIImage(named: homeModel.images[0])
        squareView.contentMode = .scaleAspectFit
        animateView.addSubview(squareView)
        animateView.backgroundColor = .blue
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        animateView.addGestureRecognizer(tapGesture)
        
        homeModel.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(generateRandomPoint), userInfo: nil, repeats: true)
    }

    // MARK: - Actions
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: animateView)
        generatePoint(at: location)
    }

    @objc func generateRandomPoint() {
        let randomPoint = homeModel.generateRandomPoint(in: animateView.bounds)
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
        animateView.addSubview(pointView)

        homeModel.points.append(pointView)
        moveSquareToPoint(pointView)  // 在這裡加上參數標籤
    }


    func moveSquareToPoint(_ pointView: UIImageView) {
        homeModel.moveSquare(squareView, to: pointView) {
            self.homeModel.animateWood(pointView: pointView) {
                print("Wood animation completed.")
            }
        }
    }

    // MARK: - Setup UI
    func setupView() {
        view.addSubview(animateView)
        view.addSubview(levelView)

        animateView.snp.makeConstraints { make in
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

    @objc func pushToLevelPage(_ sender: UIButton) {
        let LevelUpGamePage = LevelUpGamePageViewController()
        self.navigationController?.pushViewController(LevelUpGamePage, animated: true)
    }
}
