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
    private var diffableDataSource: UITableViewDiffableDataSource<Section, FireBaseWord>!

    private let viewModel = CollectionPageViewModel()

    enum Section {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupDiffableDataSource()

        viewModel.onDataChange = { [weak self] in
            self?.updateTableView()
        }

        viewModel.onTagChange = { [weak self] in
            self?.updateCollectionView()
        }

        viewModel.fetchDataFromFirebase()
        viewModel.fetchTagFromFirebase()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchDataFromFirebase()
        viewModel.fetchTagFromFirebase()
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

        tableView.dataSource = diffableDataSource
        tableView.delegate = self
    }

    private func setupDiffableDataSource() {
        diffableDataSource = UITableViewDiffableDataSource<Section, FireBaseWord>(tableView: tableView) { (tableView, indexPath, word) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CollectionPageCell
            cell?.textLabel?.text = word.english
            
            cell?.tag = self.viewModel.words[indexPath.row].levelNumber
        
            var menuActions: [UIAction] = []
            for tag in self.viewModel.tags {
                let action = UIAction(title: tag, handler: { action in
                    self.viewModel.updateWordTag(tag, cell?.tag ?? 0)
                })
                menuActions.append(action)
            }

            cell?.pullDownButton.menu = UIMenu(children: menuActions)
            return cell
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, FireBaseWord>()
        snapshot.appendSections([.main])
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FireBaseWord>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.words)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateCollectionView() {
        collectionView.reloadData()
    }
}

extension CollectionPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completion) in
            self?.viewModel.removeWord(at: indexPath.row)
            self?.applySnapshot()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let word = diffableDataSource.itemIdentifier(for: indexPath), let cell = tableView.cellForRow(at: indexPath) {
            let newLabel = (cell.textLabel?.text == word.english) ? word.chinese : word.english
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
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FireBaseWord>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.words)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
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
        let label = UILabel(frame: cell.bounds)
        label.text = tag
        label.textAlignment = .center
        label.textColor = .white
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        cell.contentView.addSubview(label)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = viewModel.tags[indexPath.row]
        let width = tag.size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)]).width + 20
        return CGSize(width: width, height: 30)
    }
}

struct FireBaseWord: Hashable {
    let levelNumber: Int
    let english: String
    let chinese: String
    let property: String
    let sentence: String
    let tag: String
    // 實現 Hashable 協定
    func hash(into hasher: inout Hasher) {
        hasher.combine(english)
        hasher.combine(chinese)
    }
}
