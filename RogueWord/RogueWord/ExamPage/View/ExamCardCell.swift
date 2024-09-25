import UIKit
import SpriteKit
import SnapKit

class ExamCardCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    // SpriteKit 视图
    let skView: SKView = {
        let skView = SKView()
        
        // 设置白色背景
        skView.backgroundColor = UIColor.white
        
        skView.layer.cornerRadius = 12
        skView.clipsToBounds = true

        skView.layer.shadowColor = UIColor.black.cgColor
        skView.layer.shadowOpacity = 0.1
        skView.layer.shadowOffset = CGSize(width: 0, height: 4)
        skView.layer.shadowRadius = 6

        return skView
    }()

    // UIView 替代 UIButton
    let contentViewBox: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    // 标签
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()

    var initialTouchPoint: CGPoint = .zero
    var originalCenter: CGPoint = .zero
    var isDraggingVertically = false
    weak var collectionView: UICollectionView?
    var animationStarted = false
    var slimeNode: SKSpriteNode?
    var animateModel = AnimateModel()
    var index: Int = 0
    var tapAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 添加 SKView
        contentView.addSubview(skView)
        skView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        setupScene()

        contentView.addSubview(contentViewBox)
        contentViewBox.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        // 添加手势识别器
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        contentView.addGestureRecognizer(panGesture)

        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        contentViewBox.addGestureRecognizer(tapGesture)

        // 添加标签到 contentViewBox
        contentViewBox.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(contentViewBox).offset(16)
            make.centerX.equalTo(contentViewBox)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置 SpriteKit 场景，但不启动动画
    func setupScene() {
        let sceneSize = CGSize(width: contentView.bounds.width, height: contentView.bounds.height)
        let scene = SKScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.lightGray
        slimeNode?.size = CGSize(width: scene.size.width * 0.8, height: scene.size.height * 0.8)
        switch index {
        case 0:
            slimeNode = SKSpriteNode(imageNamed: "Attack_1 (0_0)")
        case 1:
            slimeNode = SKSpriteNode(imageNamed: "Attack_2 (0_0)")
        case 2:
            slimeNode = SKSpriteNode(imageNamed: "Attack_3 (0_0)")
        default:
            print("DEBUG Animate Error")
        }
        slimeNode?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        
        // 添加到场景
        if let slimeNode = slimeNode {
            scene.addChild(slimeNode)
        }

        // 在 SKView 中呈现场景
        skView.presentScene(scene)
    }

    // 点击事件处理
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }

    // 手势处理
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        let touchPoint = sender.location(in: self.window)

        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
            originalCenter = contentView.center
            isDraggingVertically = false

        case .changed:
            let distanceX = touchPoint.x - initialTouchPoint.x
            let distanceY = touchPoint.y - initialTouchPoint.y

            if !isDraggingVertically {
                if abs(distanceY) > abs(distanceX) && abs(distanceY) > 10 {
                    isDraggingVertically = true
                    collectionView.isScrollEnabled = false
                }
            }

            if isDraggingVertically {
                let distanceMoved = touchPoint.y - initialTouchPoint.y
                if distanceMoved < 0 {
                    contentView.center = CGPoint(x: originalCenter.x, y: originalCenter.y + distanceMoved)
                }
            }

        case .ended, .cancelled:
            collectionView.isScrollEnabled = true

            if isDraggingVertically {
                let distanceMoved = touchPoint.y - initialTouchPoint.y
                if distanceMoved < -100 {
                    presentNewViewController()
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.contentView.center = self.originalCenter
                    }
                }
            }

        default:
            break
        }
    }

    // 启动动画
    func startAnimation() {
        if !animationStarted {
            animationStarted = true  // 防止重复启动动画
            
            switch index {
            case 0:
                if let slimeNode = slimeNode {
                    animateModel.runAttackAnimation1(on: slimeNode)
                    animationStarted = false
                }
            case 1:
                if let slimeNode = slimeNode {
                    animateModel.runAttackAnimation2(on: slimeNode)
                    animationStarted = false
                }
            case 2:
                if let slimeNode = slimeNode {
                    animateModel.runAttackAnimation3(on: slimeNode)
                    animationStarted = false
                }
            default:
                print("DEBUG animate error")
            }
        }
    }

    // 手势代理方法
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: self)
            return abs(velocity.y) > abs(velocity.x)
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }

    // 呈现新的 ViewController
    func presentNewViewController() {
        guard let parentVC = self.parentViewController else { return }
        let selectedIndex = self.index

        let newVC: UIViewController

        switch selectedIndex {
        case 0:
            newVC = WordFillInTheBlankPageViewController()
        case 1:
            newVC = ParagraphFillInTheBlanksViewController()
        case 2:
            newVC = ReadingViewController()
        default:
            print("Error: Invalid index")
            return
        }

        newVC.view.backgroundColor = .white
        newVC.modalPresentationStyle = .fullScreen
        parentVC.present(newVC, animated: true, completion: nil)
    }
}
