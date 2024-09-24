import UIKit
import SnapKit

// MARK: - ExamViewController

class ExamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    var topView: UIView!
    var topLabel: UILabel!

    let data = ["單字填空", "段落填空", "閱讀理解"]
    var currentVisibleIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTopView()
        setupCollectionView()
    }

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

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.left.right.equalTo(view)
            make.height.equalTo(320)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        cell.button.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
        cell.collectionView = collectionView
        return cell
    }

    @objc func cardTapped(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            updateTopView(for: indexPath.item)
        }
    }

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
        let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + collectionView.contentOffset.x, y: collectionView.frame.size.height / 2)

        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            if indexPath.item != currentVisibleIndex {
                currentVisibleIndex = indexPath.item
                let cardData = data[indexPath.item]
                topLabel.text = "當前測驗: \(cardData)"
            }
        }
    }

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
//
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            attribute.alpha = alpha
        }
        return attributes
    }

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

    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    var originalCenter: CGPoint = CGPoint(x: 0, y: 0)
    var isDraggingVertically = false
    weak var collectionView: UICollectionView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)

        button.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false // 確保按鈕的點擊事件不被取消
        contentView.addGestureRecognizer(panGesture) // 添加到 contentView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        let touchPoint = sender.location(in: self.window)

        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
            originalCenter = contentView.center
            isDraggingVertically = false

        case .changed:
            let distanceX = abs(touchPoint.x - initialTouchPoint.x)
            let distanceY = abs(touchPoint.y - initialTouchPoint.y)

            // 判斷滑動方向是否主要為垂直
            if distanceY > distanceX && distanceY > 20 {
                isDraggingVertically = true
                collectionView.isScrollEnabled = false
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

    // 只允許垂直手勢與其他手勢同時識別
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果另一個手勢也是 pan 手勢
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
           let otherPan = otherGestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: contentView)
            let otherVelocity = otherPan.velocity(in: contentView)
            let isCurrentVertical = abs(velocity.y) > abs(velocity.x)
            let isOtherVertical = abs(otherVelocity.y) > abs(otherVelocity.x)
            // 只有當一個是垂直，另一個是水平時才允許同時識別
            return isCurrentVertical != isOtherVertical
        }
        return false
    }

    // 只在垂直滑動時開始手勢識別
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: contentView)
            return abs(velocity.y) > abs(velocity.x)
        }
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

