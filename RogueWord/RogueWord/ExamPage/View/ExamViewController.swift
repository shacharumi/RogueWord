import UIKit
import SnapKit

class ExamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    let data = ["單字填空", "段落填空", "閱讀理解"]
    var currentVisibleIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
    }

    func setupCollectionView() {
        let layout = CardFlowLayout()
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(ExamCardCell.self, forCellWithReuseIdentifier: "ExamCardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(16)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view).offset(-16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? CardFlowLayout {
            let layoutItemWidth = layout.itemSize.width
            collectionView.contentInset = UIEdgeInsets(
                top: 0,
                left: (view.frame.width - layoutItemWidth) / 2,
                bottom: 0,
                right: (view.frame.width - layoutItemWidth) / 2
            )
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExamCardCell", for: indexPath) as! ExamCardCell
        cell.label.text = data[indexPath.item]
        cell.collectionView = collectionView
        cell.index = indexPath.row  // 設定索引

        // 設定點擊事件的閉包
        cell.tapAction = { [weak self] in
            guard let self = self else { return }
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCenterAndAnimate()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToCenterAndAnimate()
        }
    }

    func scrollToCenterAndAnimate() {
        // 计算中心点
        let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + collectionView.contentOffset.x, y: collectionView.frame.size.height / 2)
        
        // 找到居中的单元格
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            // 滚动到居中的单元格
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            // 获取居中的单元格
            if let cell = collectionView.cellForItem(at: indexPath) as? ExamCardCell {
                // 启动动画
                cell.startAnimation()
            }
        }
    }
}

// MARK: - CardFlowLayout

class CardFlowLayout: UICollectionViewFlowLayout {

    let itemScale: CGFloat = 0.6  // 非中央卡片的縮放比例
    let itemAlpha: CGFloat = 0.7   // 非中央卡片的透明度
    let maxScale: CGFloat = 1.0     // 中央卡片的最大縮放比例
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 20
        let screenWidth = UIScreen.main.bounds.width
        itemSize = CGSize(width: 300, height: 500)
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

