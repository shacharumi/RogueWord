import UIKit
import SpriteKit
import SnapKit

class ExamCardCell: UICollectionViewCell {
    let customView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.9
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 6
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "waitingNameColor")
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    let timesLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "waitingNameColor")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    let accurencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "waitingNameColor")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    let skView: SKView = {
        let skView = SKView()
        skView.backgroundColor = .clear
        skView.layer.cornerRadius = 12
        skView.clipsToBounds = true
        return skView
    }()
    
    let contentViewBox: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    weak var collectionView: UICollectionView?
    var animationStarted = false
    var slimeNode: SKSpriteNode?
    var animateModel = AnimateModel()
    var tapAction: (() -> Void)?
    var accurencyData: [Accurency]?
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
        
        skView.addSubview(customView)
        customView.snp.makeConstraints { make in
            make.bottom.equalTo(skView.snp.bottom).offset(-300)
            make.centerX.equalTo(contentViewBox)
            make.width.equalTo(250)
            make.height.equalTo(300)
        }
        
        customView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(customView)
            make.top.equalTo(customView).offset(16)
        }
        
        let timesView = UIView()
        timesView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        timesView.layer.cornerRadius = 5
        timesView.layer.masksToBounds = false
        customView.addSubview(timesView)
        timesView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.left.equalTo(customView).offset(16)
            make.right.equalTo(customView).offset(-16)
            make.height.equalTo(60)
        }
        
        let timesTitleLabel = UILabel()
        timesTitleLabel.text = "次數"
        timesTitleLabel.textColor = UIColor(named: "waitingNameColor")
        timesTitleLabel.font = UIFont.systemFont(ofSize: 32)
        timesView.addSubview(timesTitleLabel)
        timesTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(timesView).offset(16)
            make.centerY.equalTo(timesView)
        }
        
        timesView.addSubview(timesLabel)
        timesLabel.snp.makeConstraints { make in
            make.right.equalTo(timesView).offset(-16)
            make.centerY.equalTo(timesView)
        }
        
        let accurencyView = UIView()
        accurencyView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        accurencyView.layer.cornerRadius = 5
        accurencyView.layer.masksToBounds = false
        customView.addSubview(accurencyView)
        accurencyView.snp.makeConstraints { make in
            make.top.equalTo(timesView.snp.bottom).offset(32)
            make.left.equalTo(customView).offset(16)
            make.right.equalTo(customView).offset(-16)
            make.height.equalTo(60)
        }
        
        let accurencyTitleLabel = UILabel()
        accurencyTitleLabel.text = "準確率"
        accurencyTitleLabel.font = UIFont.systemFont(ofSize: 32)
        accurencyTitleLabel.textColor = UIColor(named: "waitingNameColor")
        accurencyView.addSubview(accurencyTitleLabel)
        accurencyTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(accurencyView).offset(16)
            make.centerY.equalTo(accurencyView)
        }
        
        accurencyView.addSubview(accurencyLabel)
        accurencyLabel.snp.makeConstraints { make in
            make.right.equalTo(accurencyView).offset(-16)
            make.centerY.equalTo(accurencyView)
        }
        
        let customViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(customViewTapped))
        customView.addGestureRecognizer(customViewTapGesture)
        customView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScene() {
        let sceneSize = CGSize(width: contentView.bounds.width / 2, height: contentView.bounds.height / 2)
        let scene = SKScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let image = UIImage(named: "ExamBackground")
        
        switch index {
        case 0:
            slimeNode = SKSpriteNode(imageNamed: "Attack_1 (0_0)")
            if let croppedImage = image?.cropped(to: CGRect(x: 0, y: image!.size.height - height, width: width, height: height)) {
                contentViewBox.image = croppedImage
            }
            
            if let accurencyData = self.accurencyData, accurencyData.count > 0 {
                let corrects = Float(accurencyData[0].corrects)
                let times = Float(accurencyData[0].times)
                let accurrency = (corrects / (max(times, 1) * 5))  * 100
                
                titleLabel.text = "單字填空"
                accurencyLabel.text = String(format: "%.1f", accurrency)
                timesLabel.text = "\(accurencyData[0].times)"
            } else {
                titleLabel.text = "單字填空"
                accurencyLabel.text = "N/A"
                timesLabel.text = "0"
            }
            
        case 1:
            slimeNode = SKSpriteNode(imageNamed: "Attack0")
            if let croppedImage = image?.cropped(to: CGRect(x: width, y: image!.size.height - height, width: width, height: height)) {
                contentViewBox.image = croppedImage
            }
            let corrects = Float(accurencyData?[1].corrects ?? 0)
            let times = Float(accurencyData?[1].times ?? 1)
            let accurrency = (corrects / max(times, 1)) * 5 * 100
            if let accurencyData = self.accurencyData {
                titleLabel.text = "段落填空"
                accurencyLabel.text = String(format: "%.1f", accurrency)
                timesLabel.text = "\(accurencyData[1].times)"
            }
            
        case 2:
            slimeNode = SKSpriteNode(imageNamed: "RedHairAttack0")
            if let croppedImage = image?.cropped(to: CGRect(x: 2 * width, y: image!.size.height - height, width: width, height: height)) {
                contentViewBox.image = croppedImage
            }
            let corrects = Float(accurencyData?[2].corrects ?? 0)
            let times = Float(accurencyData?[2].times ?? 1)
            let accurrency = (corrects / max(times, 1)) * 5 * 100
            if let accurencyData = self.accurencyData {
                titleLabel.text = "閱讀理解"
                accurencyLabel.text = String(format: "%.1f", accurrency)
                timesLabel.text = "\(accurencyData[2].times)"
            }
        default:
            print("DEBUG Animate Error")
        }
        
        slimeNode?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 4.2)
        slimeNode?.setScale(1.3)
        if let slimeNode = slimeNode {
            scene.addChild(slimeNode)
        }
        
        skView.presentScene(scene)
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }
    
    @objc func customViewTapped() {
        tapAction?()  // 點擊自定義View觸發事件
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
