import UIKit
import SpriteKit
import SnapKit

class ExamCardCell: UICollectionViewCell {
    let skView: SKView = {
        let skView = SKView()
        skView.backgroundColor = UIColor.white
        skView.isOpaque = false
        skView.allowsTransparency = true
        skView.layer.cornerRadius = 12
        skView.clipsToBounds = true
        return skView
    }()

    let contentViewBox: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        button.alpha = 0.5
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()

    weak var collectionView: UICollectionView?
    var animationStarted = false
    var slimeNode: SKSpriteNode?
    var animateModel = AnimateModel()
    var tapAction: (() -> Void)?

    var index: Int = 0 {
        didSet {
            setupScene()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(contentViewBox)
        contentViewBox.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        contentViewBox.addSubview(skView)
        skView.snp.makeConstraints { make in

            make.edges.equalTo(contentView)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        contentViewBox.addGestureRecognizer(tapGesture)

        skView.addSubview(button)
        button.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.bottom).offset(-270)
            make.centerX.equalTo(contentViewBox)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupScene() {
        let sceneSize = CGSize(width: contentView.bounds.width, height: contentView.bounds.height)
        let scene = SKScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let image = UIImage(named: "ExamBackground")

        //slimeNode?.size = CGSize(width: scene.size.width * 0.8, height: scene.size.height * 0.8)
        switch index {
        case 0:
            slimeNode = SKSpriteNode(imageNamed: "Attack_1 (0_0)")
            if let croppedImage = image?.cropped(to: CGRect(x: 0, y: image!.size.height - height, width: width, height: height)) {
                contentViewBox.image = croppedImage
            }
        case 1:
            slimeNode = SKSpriteNode(imageNamed: "Attack0")
            if let croppedImage = image?.cropped(to: CGRect(x: width, y: image!.size.height - height, width: width, height: height)) {
                contentViewBox.image = croppedImage
            }
        case 2:
            slimeNode = SKSpriteNode(imageNamed: "RedHairAttack0")
            if let croppedImage = image?.cropped(to: CGRect(x: 2 * width, y: image!.size.height - height, width: width, height: height)) {
                contentViewBox.image = croppedImage
            }
        default:
            print("DEBUG Animate Error")
        }

        slimeNode?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 4.2)
        slimeNode?.setScale(2)
        // 添加到场景
        if let slimeNode = slimeNode {
            scene.addChild(slimeNode)
        }

        skView.presentScene(scene)
    }

    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }

    func startAnimation() {
        if !animationStarted {
            animationStarted = true
            print("here is index \(index)")
            switch index {
            case 0:
                if let slimeNode = slimeNode {
                    animateModel.runAttackAnimation5(on: slimeNode)
                    animationStarted = false
                }
            case 1:
                if let slimeNode = slimeNode {
                    animateModel.knightRunAttackAnimation(on: slimeNode)
                    animationStarted = false
                }
            case 2:
                if let slimeNode = slimeNode {
                    animateModel.RedHairdRunAttackAnimation(on: slimeNode)
                    animationStarted = false
                }
            default:
                print("DEBUG animate error")
            }
        }
    }
}

extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
