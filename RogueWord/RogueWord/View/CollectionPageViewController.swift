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
    
    private let viewModel = CollectionPageViewModel()

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return viewModel.words.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CollectionPageCell else {
            return UITableViewCell()
        }
        
        let word = viewModel.words[indexPath.row]
        cell.textLabel?.text = word.word.english
        cell.tag = word.levelNumber
        cell.registerOptionButton(viewModel.tags)
        cell.optionPickerView.tag = word.levelNumber

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

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
