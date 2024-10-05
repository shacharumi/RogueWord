import SpriteKit

class GameScene: SKScene {

    var enchantress: SKSpriteNode!
    var knight: SKSpriteNode!
    var musketeer: SKSpriteNode!

    weak var viewController: UIViewController?
    var wordData: [Accurency] = []

    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
      self.backgroundColor = UIColor.clear

        enchantress = createCharacter(named: "Enchantress", position: CGPoint(x: frame.midX - 150, y: frame.midY))
        knight = createCharacter(named: "Knight", position: CGPoint(x: frame.midX, y: frame.midY))
        musketeer = createCharacter(named: "Musketeer", position: CGPoint(x: frame.midX + 150, y: frame.midY))

        runRandomAction(for: enchantress, characterName: "Enchantress")
        runRandomAction(for: knight, characterName: "Knight")
        runRandomAction(for: musketeer, characterName: "Musketeer")
    }

    func createCharacter(named characterName: String, position: CGPoint) -> SKSpriteNode {
        let character = SKSpriteNode(imageNamed: "\(characterName)Idle0")
        character.position = position
        character.name = characterName
        character.zPosition = 1
        addChild(character)
        
        let labelText: String
        let fontName: String
        switch characterName {
        case "Enchantress":
            labelText = "單字填空"
            fontName = "Arial-BoldMT"
        case "Knight":
            labelText = "段落填空"
            fontName = "HelveticaNeue-Bold"
        case "Musketeer":
            labelText = "閱讀理解"
            fontName = "Courier-Bold"
        default:
            labelText = ""
            fontName = "Helvetica"
        }
        
        if !labelText.isEmpty {
            let label = SKLabelNode(text: labelText)
            label.fontName = fontName
            label.fontSize = 20
            label.fontColor = .black
            label.position = CGPoint(x: 0, y: character.size.height / 2 + 10)
            label.name = "label"
            character.addChild(label)
        }
        
        return character
    }



    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        print("aaaaa")
        for node in nodesAtPoint {
            if let spriteNode = node as? SKSpriteNode, let characterName = spriteNode.name {
                showPopupInViewController(for: characterName)
                break
            }
        }
    }

    func showPopupInViewController(for characterName: String) {
        guard let viewController = viewController else { return }

        var dataIndex = 0
        switch characterName {
        case "Enchantress":
            dataIndex = 0
        case "Knight":
            dataIndex = 1
        case "Musketeer":
            dataIndex = 2
        default:
            return
        }

        guard dataIndex < wordData.count else { return }
        let data = wordData[dataIndex]

        let popupView = CharacterPopupView()
        popupView.configure(with: data)
    
        let popupWidth: CGFloat = UIScreen.main.bounds.width
        let popupHeight: CGFloat = UIScreen.main.bounds.height
        popupView.backgroundColor = .clear
        popupView.frame = CGRect(x: 0, y: 0, width: popupWidth, height: popupHeight)
        popupView.center = viewController.view.center

        popupView.buttonAction = { [weak self] in
            self?.presentCorrespondingViewController(for: characterName)
        }

        viewController.view.addSubview(popupView)
    }

    func presentCorrespondingViewController(for characterName: String) {
        guard let viewController = viewController else { return }

        var presentVC: UIViewController?

        switch characterName {
        case "Enchantress":
            let vc = WordFillInTheBlankPageViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.wordDatas = wordData[0]
            presentVC = vc
        case "Knight":
            let vc = ParagraphFillInTheBlanksViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.wordDatas = wordData[1]
            presentVC = vc
        case "Musketeer":
            let vc = ReadingViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.wordDatas = wordData[2]
            presentVC = vc
        default:
            break
        }

        if let vcToPresent = presentVC {
            viewController.present(vcToPresent, animated: true, completion: nil)
        }
    }

    func runRandomAction(for character: SKSpriteNode, characterName: String) {
        let randomChoice = Int.random(in: 0...5)
        
        switch randomChoice {
        case 0:
            if characterName == "Enchantress" || characterName == "Musketeer" {
            runAnimationAndMove(character, characterName: characterName, imageName: "Run", imageCount: 13)
            } else if characterName == "Knight" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Run", imageCount: 11)
            }
        case 1:
                if characterName == "Enchantress" || characterName == "Musketeer" {
            runAnimationAndMove(character, characterName: characterName, imageName: "Walk", imageCount: 13)
                } else if characterName == "Knight" {
                    runAnimationAndMove(character, characterName: characterName, imageName: "Walk", imageCount: 12)
                }
            
        case 2:
            if characterName == "Enchantress" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Jump", imageCount: 7)
            } else if characterName == "Knight" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Jump", imageCount: 5)
            } else if characterName == "Musketeer" {
                runAnimationAndMove(character, characterName: characterName, imageName: "Jump", imageCount: 6)
            }
        case 3:
            if characterName == "Enchantress" {
                stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 7, timePerFrame: 0.5)
            } else if characterName == "Knight" {
                stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 5, timePerFrame: 0.5)
            } else if characterName == "Musketeer" {
                stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 4, timePerFrame: 0.5)
            }
            
        case 4:
            if characterName == "Enchantress" {
                stopAnimation(character, characterName: characterName, imageName: "Dead", imageCount: 4, timePerFrame: 0.5)
            } else if characterName == "Knight" {
                stopAnimation(character, characterName: characterName, imageName: "Dead", imageCount: 3, timePerFrame: 0.5)
            } else if  characterName == "Musketeer" {
                stopAnimation(character, characterName: characterName, imageName: "Dead", imageCount: 3, timePerFrame: 0.5)
            }
        case 5:
            if characterName == "Enchantress" {
                stopAnimation(character, characterName: characterName, imageName: "Attack", imageCount: 21, timePerFrame: 0.2)
            } else if characterName == "Knight" {
                stopAnimation(character, characterName: characterName, imageName: "Attack", imageCount: 16, timePerFrame: 0.2)
            } else if characterName == "Musketeer" {
                stopAnimation(character, characterName: characterName, imageName: "Attack", imageCount: 19, timePerFrame: 0.2)
            }
        default:
            break
        }
    }
    
    // 執行跑步動畫並移動
    func runAnimationAndMove(_ character: SKSpriteNode, characterName: String, imageName: String, imageCount: Int) {
        var runTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            runTextures.append(texture)
        }
        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.1)
        let repeatRunAnimation = SKAction.repeatForever(runAnimation)
        
        let randomX = CGFloat.random(in: 0...(frame.size.width - 50))
        let randomY = CGFloat.random(in: 0...(frame.size.height - 50))
        let randomPoint = CGPoint(x: randomX, y: randomY)
        
        let deltaX = randomX - character.position.x
        if deltaX < 0 {
            character.xScale = -1
        } else {
            character.xScale = 1
        }
        
        if let label = character.childNode(withName: "label") as? SKLabelNode {
            label.xScale = character.xScale == -1 ? -1 : 1
        }
        
        character.run(repeatRunAnimation, withKey: "\(imageName)Animation")
        
        let moveAction = SKAction.move(to: randomPoint, duration: 7)
        
        let moveCompletion = SKAction.run {
            character.removeAction(forKey: "\(imageName)Animation")
            self.runRandomAction(for: character, characterName: characterName)
        }
        
        let sequence = SKAction.sequence([moveAction, moveCompletion])
        character.run(sequence)
    }

    
    func stopAnimation(_ character: SKSpriteNode, characterName: String, imageName: String, imageCount: Int, timePerFrame: Double) {
        var idleTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            idleTextures.append(texture)
        }
        let idleAnimation = SKAction.animate(with: idleTextures, timePerFrame: timePerFrame)
        
        let sequence = SKAction.sequence([idleAnimation, SKAction.run {
            self.runRandomAction(for: character, characterName: characterName)
        }])
        character.run(sequence)
    }
}




class CharacterPopupView: UIView {
    
    // MARK: - Subviews
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        // 添加阴影
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "測試標題" // 可以根据需求动态设置
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        label.textColor = UIColor.darkText
        label.numberOfLines = 0
        return label
    }()
    
    // 新增标题和数值标签
    private let timesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "練習次數："
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "waitingLabel") ?? UIColor.gray
        return label
    }()
    
    private let timesValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0" // 初始值，可动态设置
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .right
        label.textColor = UIColor(named: "waitingLabel") ?? UIColor.gray
        return label
    }()
    
    private let accuracyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "準確率："
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "waitingLabel") ?? UIColor.gray
        return label
    }()
    
    private let accuracyValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0%" // 初始值，可动态设置
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .right
        label.textColor = UIColor(named: "waitingLabel") ?? UIColor.gray
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("開始練習", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor.gray
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    // MARK: - Properties
    
    var buttonAction: (() -> Void)?
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景，拦截所有触摸事件
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景，拦截所有触摸事件
        setupViews()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        // 添加按钮的目标方法
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // 添加背景视图
        addSubview(backgroundView)
        
        // 将 closeButton 添加到 backgroundView 中
        addSubview(closeButton)
        
        // 创建水平堆叠视图
        let timesStackView = UIStackView(arrangedSubviews: [timesTitleLabel, timesValueLabel])
        timesStackView.axis = .horizontal
        timesStackView.spacing = 8
        timesStackView.alignment = .fill
        timesStackView.distribution = .fillProportionally
        
        let accuracyStackView = UIStackView(arrangedSubviews: [accuracyTitleLabel, accuracyValueLabel])
        accuracyStackView.axis = .horizontal
        accuracyStackView.spacing = 8
        accuracyStackView.alignment = .fill
        accuracyStackView.distribution = .fillProportionally
        
        // 创建主垂直堆叠视图
        let stackView = UIStackView(arrangedSubviews: [titleLabel, timesStackView, accuracyStackView, actionButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        backgroundView.addSubview(stackView)
        
        // 使用 SnapKit 进行布局
        backgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(250) // 增加宽度以适应新的布局
            make.height.equalTo(300) // 动态高度
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(backgroundView).offset(16)
            make.right.equalTo(backgroundView).offset(-16)
            make.height.width.equalTo(30) // 增大尺寸以提高触控范围
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(backgroundView).offset(16)
            make.left.equalTo(backgroundView).offset(16)
            make.right.equalTo(backgroundView).offset(-16)
            make.bottom.equalTo(backgroundView).offset(-16) // 确保堆叠视图不超出背景视图
        }
        
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(64)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with data: Accurency) {
        switch data.title {
        case 0:
            titleLabel.text = "單字測試"
        case 1:
            titleLabel.text = "段落填空"
        case 2:
            titleLabel.text = "閱讀理解"
        default:
            titleLabel.text = "未知測試"
        }
        
        timesValueLabel.text = "\(data.times)"
        
        if data.times == 0 {
            accuracyValueLabel.text = "0%"
        } else {
            let accuracyNumber = (Double(data.corrects) / Double(data.times)) * 100
            let accuracy = String(format: "%.1f%%", accuracyNumber)
            accuracyValueLabel.text = accuracy
        }
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped() {
        buttonAction?()
    }
    
    @objc private func closeButtonTapped() {
        print("Close button tapped") // 调试用
        self.removeFromSuperview()
    }
}

