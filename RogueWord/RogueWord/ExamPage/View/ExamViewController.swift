import UIKit
import SnapKit

class ExamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    var collectionView: UICollectionView!
    let data = ["單字填空", "段落填空", "閱讀理解"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新 itemSize 为 collectionView 的实际大小
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.bounds.size
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimationOnCenteredCell()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        // 初始设置 itemSize，会在 viewDidLayoutSubviews 中更新
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .lightGray
        collectionView.register(ExamCardCell.self, forCellWithReuseIdentifier: "ExamCardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true  // 禁用默认的分页
        
        // 确保 contentInset 为零
        collectionView.contentInset = .zero
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExamCardCell", for: indexPath) as! ExamCardCell
        cell.button.setTitle(data[indexPath.row], for: .normal)
        cell.index = indexPath.item  // 设置索引
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentIndex()
    }
    
    func updateCurrentIndex() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth = layout.itemSize.width
        let spacing = layout.minimumLineSpacing
        
        // 当前偏移量
        let offset = collectionView.contentOffset.x
        
        // 计算当前索引
        let index = Int(round(offset / (cellWidth + spacing)))
        
        // 确保索引在有效范围内
        let clampedIndex = max(0, min(index, data.count - 1))
        
        print("当前索引：\(clampedIndex)")
        
        // 获取当前居中的单元格并触发动画
        if let cell = collectionView.cellForItem(at: IndexPath(item: clampedIndex, section: 0)) as? ExamCardCell {
            cell.startAnimation()
        }
    }
    
    func startAnimationOnCenteredCell() {
        let centerPoint = CGPoint(x: collectionView.bounds.midX + collectionView.contentOffset.x,
                                  y: collectionView.bounds.midY + collectionView.contentOffset.y)
        
        if let indexPath = collectionView.indexPathForItem(at: centerPoint),
           let cell = collectionView.cellForItem(at: indexPath) as? ExamCardCell {
            print("Centered cell index: \(indexPath.item)")
            cell.startAnimation()
        }
    }
    
    @objc func tapButton(_ sender: UIButton) {
        switch sender.tag {
            
        case 0 :
            let presentVC = WordFillInTheBlankPageViewController()
            presentVC.modalPresentationStyle = .fullScreen
            self.present(presentVC, animated: true)
        case 1:
            let presentVC = ParagraphFillInTheBlanksViewController()
            presentVC.modalPresentationStyle = .fullScreen
            self.present(presentVC, animated: true)
        case 2:
            let presentVC = ReadingViewController()
            presentVC.modalPresentationStyle = .fullScreen
            self.present(presentVC, animated: true)
        default:
            print("DEBUG present ERROR")
        }
    }
}
