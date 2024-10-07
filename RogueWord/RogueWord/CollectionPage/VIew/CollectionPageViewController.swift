//
//  CollectionPageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit
import SnapKit

class CollectionPageViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let headerView = UIView()
    private let backButton = UIButton()
    private let addButton = UIButton()
    
    private var tableView: UITableView!
    private var wrongQuestionButton = UIButton()
    private let viewModel = CollectionPageViewModel()
    private var tapCounts: [IndexPath: Int] = [:]
    var characterTag: String = ""
    var onTagComplete: (() -> Void)?

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupViewModel()
        viewModel.fetchDataFromFirebase()
        viewModel.fetchTagFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchDataFromFirebase()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        // 设置背景颜色
        view.backgroundColor = UIColor(named: "CollectionBackGround")
        
        // 添加头部视图
        view.addSubview(headerView)
        headerView.backgroundColor =  UIColor(named: "CollectionBackGround")
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.height.equalTo(60)
        }
        
        let titlelabel = UILabel()
        titlelabel.text = characterTag
        titlelabel.textColor = UIColor(named: "TextColor")
        titlelabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        headerView.addSubview(titlelabel)
        titlelabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(headerView)
        }
        
        // 设置返回按钮
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.tintColor = UIColor(named: "TextColor")
        backButton.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
        headerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.left.equalTo(headerView).offset(16)
            make.width.height.equalTo(30)
        }
        
        // 设置添加按钮
        addButton.setImage(UIImage(systemName: "plus.square"), for: .normal)
        addButton.tintColor = UIColor(named: "TextColor")
        addButton.addTarget(self, action: #selector(presentAddTagAlert), for: .touchUpInside)
        headerView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.right.equalTo(headerView).offset(-16)
            make.width.height.equalTo(30)
        }
        
        // 添加错误问题按钮
        view.addSubview(wrongQuestionButton)
        wrongQuestionButton.setImage(UIImage(systemName: "questionmark.folder.fill"), for: .normal)
        wrongQuestionButton.tintColor = .black
        wrongQuestionButton.addTarget(self, action: #selector(tapWrongButton), for: .touchUpInside)
        wrongQuestionButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.right.equalTo(view).offset(-16)
            make.width.height.equalTo(50)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(named: "CollectionBackGround")
        tableView.register(CollectionPageCell.self, forCellReuseIdentifier: "CollectionPageCell")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(view)
            make.left.right.equalTo(view)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupViewModel() {
        viewModel.viewModelTag = characterTag
        viewModel.onDataChange = { [weak self] in
            self?.updateTableView()
        }
        
        viewModel.onTagChange = { [weak self] in
            self?.updateTableView()
        }
    }
    
    // MARK: - Action Methods
    
    @objc func tapBackButton() {
        self.dismiss(animated: true, completion: nil)
        // 如果是通过导航控制器推送的，可以使用以下代码：
        // self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapWrongButton() {
        let newVC = WrongQuestionsPage()
        self.present(newVC, animated: true, completion: nil)
     
    }
    
    @objc func updateTag(_ sender: UIButton) {
        guard let tagType = sender.title(for: .normal) else {
            print("按鈕沒有標題")
            return
        }
        
        let tagIndex = sender.tag
        
        viewModel.updateWordTag(tagType, tagIndex)
        
        print("更新標籤: \(tagType), 索引: \(tagIndex)")
    }
    
    @objc func presentAddTagAlert() {
        let alert = UIAlertController(title: "新增標籤", message: "請輸入新的標籤名稱", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "標籤名稱"
        }
        
        let addAction = UIAlertAction(title: "新增", style: .default) { [weak self] (_) in
            if let tagName = alert.textFields?.first?.text, !tagName.isEmpty {
                self?.viewModel.addTag(tagName)
                self?.onTagComplete?()
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    private func updateTableView() {
        print(viewModel.words)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CollectionPageViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 返回行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.words.count
    }
    
    // 配置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionPageCell", for: indexPath) as? CollectionPageCell else {
            return UITableViewCell()
        }
        
        let word = viewModel.words[indexPath.row]
        cell.backgroundColor = UIColor(named: "CollectionBackGround")
        cell.textLabel?.text = word.word.english
        cell.textLabel?.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell.cardView).offset(16)
            make.right.equalTo(cell.cardView).offset(-16)
        }
        cell.tag = word.levelNumber
        cell.registerOptionButton(viewModel.tags)
        cell.cellID = word.levelNumber
        cell.tagLabel.text = word.tag
        cell.dropDownButton.selectionAction = { [weak self] (index: Int, item: String) in
            cell.tagLabel.text = item
            self?.viewModel.updateWordTag(item, word.levelNumber)
        }
        return cell
    }
    
    // 行高
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // 选择行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)

           let word = viewModel.words[indexPath.row]
           if let cell = tableView.cellForRow(at: indexPath) {
               
               let currentTapCount = tapCounts[indexPath] ?? 0
               let newLabel: String
               switch currentTapCount {
               case 0:
                   newLabel = word.word.chinese
               case 1:
                   newLabel = word.word.sentence
               case 2:
                   newLabel = word.word.english
               default:
                   newLabel = word.word.english
               }
               
               UIView.animate(withDuration: 0.3, animations: {
                   cell.textLabel?.alpha = 0.0
               }, completion: { _ in
                   cell.textLabel?.text = newLabel
                   UIView.animate(withDuration: 0.3, animations: {
                       cell.textLabel?.alpha = 1.0
                   })
               })
               
               tapCounts[indexPath] = (currentTapCount + 1) % 3
           }
       }

    // 删除行
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completion) in
            
            self?.viewModel.removeWord(at: indexPath.row)
            self?.updateTableView()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
