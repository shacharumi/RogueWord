//
//  CollectionPageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit

class CollectionPageViewController: UIViewController {
    
    

    private var tableView: UITableView!
    private var collectionView: UICollectionView!
    private var wrongQuestionButton = UIButton()
    private let viewModel = CollectionPageViewModel()
    private var tapCounts: [IndexPath: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
       
        viewModel.onDataChange = { [weak self] in
            self?.updateTableView()
        }

        viewModel.onTagChange = { [weak self] in
            self?.updateCollectionView()
            self?.updateTableView()
        }

        viewModel.fetchDataFromFirebase()
        viewModel.fetchTagFromFirebase()
        
        
        view.addSubview(wrongQuestionButton)
        wrongQuestionButton.setImage(UIImage(systemName: "questionmark.folder.fill"), for: .normal)
        wrongQuestionButton.addTarget(self, action: #selector(tapWrongButton), for: .touchUpInside)
        wrongQuestionButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.right.equalTo(view).offset(-16)
            make.width.height.equalTo(50)
        }
        
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
    
    @objc func tapWrongButton() {
        let newVC = WrongQuestionsPage()
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        collectionView.register(CollectionTagCell.self, forCellWithReuseIdentifier: "CollectionTagCell")

        self.view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(35)
        }
    }

    private func setupTableView() {
        let rightButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(presentAddTagAlert))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.title = "+"
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CollectionPageCell.self, forCellReuseIdentifier: "CollectionPageCell")

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
        print(viewModel.words)
        tableView.reloadData()
    }

    private func updateCollectionView() {
        collectionView.reloadData()
    }
    
    @objc func presentAddTagAlert() {
        let alert = UIAlertController(title: "新增標籤", message: "請輸入新的標籤名稱", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "標籤名稱"
        }
        
        let addAction = UIAlertAction(title: "新增", style: .default) { [weak self] (_) in
            if let tagName = alert.textFields?.first?.text, !tagName.isEmpty {
                self?.viewModel.addTag(tagName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension CollectionPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return viewModel.words.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionPageCell", for: indexPath) as? CollectionPageCell else {
            return UITableViewCell()
        }
        
        let word = viewModel.words[indexPath.row]
        cell.textLabel?.text = word.word.english
        cell.tag = word.levelNumber
        cell.registerOptionButton(viewModel.tags)
        cell.cellID = word.levelNumber
        cell.tagLabel.text = word.tag
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionTagCell", for: indexPath) as! CollectionTagCell
        cell.backgroundColor = .lightGray
        
        let tag = viewModel.tags[indexPath.row]
        cell.button.setTitle(tag, for: .normal)
        cell.button.accessibilityIdentifier = tag
        cell.button.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        
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

extension CollectionPageViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let locationInView = interaction.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: locationInView) {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let action1 = UIAction(title: "刪除", image: UIImage(systemName: "trash")) { action in
                    self.viewModel.removeTag(indexPath.row)
                }
                return UIMenu(title: "", children: [action1])
            }
        }
        
        return nil
    }
}





