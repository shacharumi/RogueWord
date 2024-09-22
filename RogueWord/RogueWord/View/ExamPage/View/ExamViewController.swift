import UIKit
import SnapKit

// MARK: - ExamViewController

class ExamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    var topView: UIView!
    var topLabel: UILabel!

    let data = ["單字填空", "段落填空", "閱讀理解"]
    var currentVisibleIndex: Int? // 記錄當前顯示的卡片索引

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTopView()
        setupCollectionView()
    }

    // 設置上方的視圖
    func setupTopView() {
        topView = UIView()
        topView.backgroundColor = .lightGray
        topView.layer.cornerRadius = 20
        view.addSubview(topView)

        topLabel = UILabel()
        topLabel.text = "請選擇一個測驗"
        topLabel.textAlignment = .center
        topLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        topView.addSubview(topLabel)

        // 使用 SnapKit 進行佈局
        topView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(100)
        }

        topLabel.snp.makeConstraints { make in
            make.center.equalTo(topView)
        }
    }

    // 設置下方的輪播視圖 (CollectionView)
    func setupCollectionView() {
        let layout = CardFlowLayout()
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast

        view.addSubview(collectionView)

        // 調整 CollectionView 的佈局，將它放置在螢幕底部
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.left.right.equalTo(view)
            make.height.equalTo(320) // 高度設為 320 以容納 300 高的卡片和一些間距
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 動態設置 contentInset 以便顯示邊緣的卡片
        if let layout = collectionView.collectionViewLayout as? CardFlowLayout {
            let layoutItemWidth = layout.itemSize.width
            collectionView.contentInset = UIEdgeInsets(top: 0, left: (view.frame.width - layoutItemWidth) / 2, bottom: 0, right: (view.frame.width - layoutItemWidth) / 2)
        }
    }

    // UICollectionViewDataSource 方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        cell.button.setTitle(data[indexPath.item], for: .normal)
        cell.button.tag = indexPath.row
        // 為每個按鈕添加點擊事件
        cell.button.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
        cell.collectionView = collectionView // 傳遞 collectionView 的引用
        return cell
    }

    // 點擊卡片時滾動到中央
    @objc func cardTapped(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            updateTopView(for: indexPath.item)
        }
    }

    // 監聽滑動事件
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCenter()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToCenter()
        }
    }

    func scrollToCenter() {
        let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + collectionView.contentOffset.x, y: collectionView.frame.size.height / 2)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            updateTopView(for: indexPath.item)
        }
    }

    // 根據滑動來更新上方視圖
    func updateTopViewForVisibleCard() {
        // 找到 CollectionView 中間的卡片
        let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + collectionView.contentOffset.x, y: collectionView.frame.size.height / 2)

        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            // 只有當前顯示的卡片與上次不同時才更新
            if indexPath.item != currentVisibleIndex {
                currentVisibleIndex = indexPath.item
                let cardData = data[indexPath.item]
                topLabel.text = "當前測驗: \(cardData)"
            }
        }
    }

    // 手動更新上方的視圖
    func updateTopView(for index: Int) {
        if index != currentVisibleIndex {
            currentVisibleIndex = index
            topLabel.text = "當前測驗: \(data[index])"
        }
    }
}

// MARK: - CardFlowLayout

class CardFlowLayout: UICollectionViewFlowLayout {

    let itemScale: CGFloat = 0.85  // 非中央卡片的縮放比例
    let itemAlpha: CGFloat = 0.7   // 非中央卡片的透明度
    let maxScale: CGFloat = 1.0     // 中央卡片的最大縮放比例

    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 20
        // 設置 itemSize 為寬 150，高 300
        itemSize = CGSize(width: 150, height: 300)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true  // 當 bounds 改變時重新計算佈局
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect),
              let collectionView = self.collectionView else { return nil }

        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2

        for attribute in attributes {
            let distance = abs(attribute.center.x - centerX)
            let normalizedDistance = distance / collectionView.bounds.width
            let scale = max(itemScale, maxScale - normalizedDistance * (maxScale - itemScale))
            let alpha = max(itemAlpha, 1 - normalizedDistance * (1 - itemAlpha))

            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            attribute.alpha = alpha
        }
        return attributes
    }

    // 自動讓卡片吸附到中央
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return proposedContentOffset }

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        guard let attributes = super.layoutAttributesForElements(in: targetRect) else { return proposedContentOffset }

        let centerX = proposedContentOffset.x + collectionView.bounds.width / 2

        var closestAttribute: UICollectionViewLayoutAttributes?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for attribute in attributes {
            let distance = attribute.center.x - centerX
            if abs(distance) < abs(minDistance) {
                minDistance = distance
                closestAttribute = attribute
            }
        }

        guard let closest = closestAttribute else { return proposedContentOffset }

        let adjustedOffsetX = proposedContentOffset.x + minDistance
        return CGPoint(x: adjustedOffsetX, y: proposedContentOffset.y)
    }
}

// MARK: - CardCell

class CardCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        button.isUserInteractionEnabled = true
        return button
    }()

    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0) // 記錄起始點位置
    var originalCenter: CGPoint = CGPoint(x: 0, y: 0) // 記錄卡片的初始位置
    var isDraggingVertically = false // 是否檢測到垂直拖動
    weak var collectionView: UICollectionView? // 持有 collectionView 的引用

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)

        // 調整 button 的佈局，使其適應長方形
        button.snp.makeConstraints { make in
            make.edges.equalTo(contentView) // 填滿整個 cell
        }

        // 添加 pan 手勢識別器
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self // 設置手勢的 delegate
        contentView.addGestureRecognizer(panGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        let touchPoint = sender.location(in: self.window)

        switch sender.state {
        case .began:
            // 記錄下拉的起點和卡片的原始位置
            initialTouchPoint = touchPoint
            originalCenter = contentView.center
            isDraggingVertically = false // 開始手勢時重置標誌

        case .changed:
            let distanceX = abs(touchPoint.x - initialTouchPoint.x)
            let distanceY = abs(touchPoint.y - initialTouchPoint.y)

            // 僅當垂直移動距離大於水平移動距離時，且垂直移動距離超過一定閾值時，啟用垂直拖動
            if distanceY > distanceX && distanceY > 20 {
                isDraggingVertically = true
                collectionView.isScrollEnabled = false // 禁止水平滾動
            }

            if isDraggingVertically {
                // 垂直移動：卡片跟隨手指上下移動
                let distanceMoved = touchPoint.y - initialTouchPoint.y
                if distanceMoved < 0 { // 僅允許向上拖動
                    contentView.center = CGPoint(x: originalCenter.x, y: originalCenter.y + distanceMoved)
                }
            }

        case .ended, .cancelled:
            collectionView.isScrollEnabled = true // 手勢結束後允許水平滾動

            if isDraggingVertically {
                let distanceMoved = touchPoint.y - initialTouchPoint.y

                // 檢查手指移動距離是否超過閾值（例如 -100 點）
                if distanceMoved < -100 {
                    // 如果超過閾值，觸發新的 ViewController 顯示
                    presentNewViewController()
                } else {
                    // 如果沒有超過閾值，將卡片還原到原始位置
                    UIView.animate(withDuration: 0.3) {
                        self.contentView.center = self.originalCenter
                    }
                }
            }

        default:
            break
        }
    }

    // 控制手勢是否應該同時識別（在水平方向滑動時不允許垂直手勢同時觸發）
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 檢查手勢是否是滑動
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: contentView)

            if abs(velocity.x) > abs(velocity.y) {
                return false
            }
        }

        // 允許其他情況下的手勢同時識別
        return true
    }

    // 呈現新的ViewController
    func presentNewViewController() {
        guard let parentVC = self.parentViewController else { return }
        let selectedIndex = button.tag

        let newVC: UIViewController

        switch selectedIndex {
        case 0:
            newVC = WordFillInTheBlankPageViewController()
        case 1:
            newVC = ParagraphFillInTheBlanksViewController()
        case 2:
            newVC = ReadingViewController()
        default:
            print("Error: Invalid button tag")
            return
        }

        newVC.view.backgroundColor = .white
        newVC.modalPresentationStyle = .fullScreen
        parentVC.present(newVC, animated: true, completion: nil)
    }
}

// MARK: - UIView Extension

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

