import UIKit

class CollectionPageViewController: UIViewController {

    private var tableView: UITableView!
    private var collectionView: UICollectionView!
    
    private let viewModel = CollectionPageViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()

        let rightBarButton = UIBarButtonItem(title: "按鈕", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        self.navigationItem.rightBarButtonItem = rightBarButton

        // 確保 UI 在數據加載完成後才進行刷新
        viewModel.onDataChange = { [weak self] in
            self?.updateTableView()
        }

        viewModel.onTagChange = { [weak self] in
            self?.updateCollectionView()
            self?.updateTableView()
        }

        // 初始化時加載數據
        viewModel.fetchDataFromFirebase()
        viewModel.fetchTagFromFirebase()

    }

    @objc func rightBarButtonTapped() {
        // 按鈕功能邏輯
    }
    
    @objc func updateTag(_ sender: UIButton) {
        // 確保按鈕的標題存在，否則直接返回
        guard let tagType = sender.title(for: .normal) else {
            print("按鈕沒有標題")
            return
        }
        
        // 使用按鈕的 tag 屬性來標識選擇的標籤索引
        let tagIndex = sender.tag
        
        // 更新 ViewModel 中的標籤
        viewModel.updateWordTag(tagType, tagIndex)
        
        print("更新標籤: \(tagType), 索引: \(tagIndex)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 確保每次視圖出現時都加載數據
        viewModel.fetchDataFromFirebase()
        
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = true
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(35)
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CollectionPageCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
    }

    private func updateTableView() {
        tableView.reloadData()
    }

    private func updateCollectionView() {
        collectionView.reloadData()
    }
}


extension CollectionPageViewController: UITableViewDataSource, UITableViewDelegate {
    // 每個 section 的行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return viewModel.words.count
    }

    // 配置每個 cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CollectionPageCell else {
            return UITableViewCell()
        }
        
        let word = viewModel.words[indexPath.row]
        cell.textLabel?.text = word.word.english  // 顯示詞彙
        cell.tag = word.levelNumber  // 使用 levelNumber 作為 cell 標記

        // 註冊選項按鈕，並確保 `optionArray` 已正確填充
        cell.registerOptionButton(viewModel.tags)
        cell.optionPickerView.tag = indexPath.row
        // 確保按鈕已正確初始化，並迴圈設置目標
//        for buttonIndex in 0..<viewModel.tags.count {
//            let button = cell.optionArray[buttonIndex]
//
//            // 防止重複添加目標動作，先移除所有舊的目標動作
//            button.removeTarget(nil, action: nil, for: .allEvents)
//
//            // 設置按鈕的標籤（tag），用於識別是哪一行的按鈕
//            button.tag = indexPath.row
//
//            // 添加目標動作
//            //button.addTarget(self, action: #selector(updateTag(_:)), for: .touchUpInside)
//        }

        return cell
    }


    // 行的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // 點擊行後的行為
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let word = viewModel.words[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            let newLabel = (cell.textLabel?.text == word.word.english) ? word.word.chinese : word.word.english
            UIView.animate(withDuration: 0.3, animations: {
                cell.textLabel?.alpha = 0.0
            }, completion: { _ in
                cell.textLabel?.text = newLabel
                UIView.animate(withDuration: 0.3, animations: {
                    cell.textLabel?.alpha = 1.0
                })
            })
        }
    }

    // 定義刪除按鈕的行為
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completion) in
            self?.viewModel.removeWord(at: indexPath.row)
            self?.updateTableView()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}


extension CollectionPageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      

        return viewModel.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .lightGray

        let tag = viewModel.tags[indexPath.row]
        let button = UIButton(frame: cell.bounds)
        button.setTitle(tag, for: .normal)
        button.configuration?.titleAlignment = .center
        button.titleLabel?.textColor = .white
        button.isUserInteractionEnabled = true
        button.accessibilityIdentifier = tag
        button.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        cell.contentView.addSubview(button)

        return cell
    }

    @objc func tagTapped(_ sender: UIButton) {
        if let tag = sender.accessibilityIdentifier {
            viewModel.fetchFilterData(tag) { [weak self] in
                self?.updateTableView()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = viewModel.tags[indexPath.row]
        let width = tag.size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)]).width + 20
        return CGSize(width: width, height: 30)
    }
}
