import UIKit
import SnapKit

class ExamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    var collectionView: UICollectionView!
    let data = ["單字填空", "段落填空", "閱讀理解"]
    var wordData: [Accurency] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        fetchAccurencyRecords()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBarController?.tabBar.backgroundColor = .white
        self.tabBarController?.tabBar.tintColor = .black
        self.tabBarController?.tabBar.alpha = 0.4
        self.automaticallyAdjustsScrollViewInsets = false

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
            make.top.left.right.bottom.equalTo(view)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExamCardCell", for: indexPath) as! ExamCardCell
        cell.accurencyData = wordData
        //cell.label.text = "\(data[indexPath.row])"  // 使用 Label 來顯示文字
        cell.index = indexPath.item  // 设置索引
        
        // 添加點擊手勢
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        cell.customView.tag = indexPath.row
        cell.customView.addGestureRecognizer(tapGesture)
        cell.customView.isUserInteractionEnabled = true
        
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
    
    func fetchAccurencyRecords() {
        let query = FirestoreEndpoint.fetchAccurencyRecords.ref
        FirestoreService.shared.getDocuments(query) { [weak self] (accurencyRecords: [Accurency]) in
            guard let self = self else { return }
            let sortedAccurencyRecords = accurencyRecords.sorted(by: { $0.title < $1.title })
            self.wordData = sortedAccurencyRecords
            print(self.wordData)
            self.collectionView.reloadData()
        }
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        switch view.tag {
        case 0:
            let presentVC = WordFillInTheBlankPageViewController()
            presentVC.modalPresentationStyle = .fullScreen
            presentVC.wordDatas = wordData[0]
            
            presentVC.datadismiss = { [weak self] wordsData in
                guard let self = self else { return }
                if let data = wordsData {
                    self.wordData[0] = data
                    print("收到的資料: \(data)")
                }
            }
            self.present(presentVC, animated: true)
            
        case 1:
            let presentVC = ParagraphFillInTheBlanksViewController()
            presentVC.modalPresentationStyle = .fullScreen
            presentVC.wordDatas = wordData[1]
            
            presentVC.datadismiss = { [weak self] wordsData in
                guard let self = self else { return }
                if let data = wordsData {
                    self.wordData[1] = data
                    print("收到的資料: \(data)")
                }
            }
            self.present(presentVC, animated: true)
            
        case 2:
            let presentVC = ReadingViewController()
            presentVC.modalPresentationStyle = .fullScreen
            presentVC.wordDatas = wordData[2]
            
            presentVC.datadismiss = { [weak self] wordsData in
                guard let self = self else { return }
                if let data = wordsData {
                    self.wordData[2] = data
                    print("收到的資料: \(data)")
                }
            }
            self.present(presentVC, animated: true)
            
        default:
            print("DEBUG present ERROR")
        }
    }
}
