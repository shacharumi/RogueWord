//
//  WrongQuestionParagraphVC.swift
//  RogueWord
//
//  Created by shachar on 2024/9/24.
//

// WrongQuestionParagraphVC.swift
import UIKit
import SnapKit

class WrongQuestionParagraphVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var questionData: GetParagraphType?   // 传递过来的问题数据
    var questionsTitle: String?
    var dataDismiss: (() -> Void)?        // 闭包，用于在视图控制器消失后回调
    var viewModel: WrongQuestionParagraphViewModel!

    private let tableView = UITableView()
    private var customNavBar: UIView!
    private let menuButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupCustomNavBar()
        setupTableView()

        // 初始化 ViewModel
        if let questionData = questionData {
            viewModel = WrongQuestionParagraphViewModel(questionData: questionData, questionsTitle: questionsTitle)
        } else {
            // 处理 questionData 为 nil 的情况
            print("Question data is nil")
        }
    }

    // 设置自定义导航栏
    private func setupCustomNavBar() {
        customNavBar = UIView()
        customNavBar.backgroundColor = UIColor(named: "CollectionBackGround")

        view.addSubview(customNavBar)

        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.height.equalTo(60)
        }

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.tintColor = UIColor(named: "TextColor")
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)

        backButton.snp.makeConstraints { make in
            make.leading.equalTo(customNavBar).offset(16)
            make.centerY.equalTo(customNavBar)
        }

        menuButton.setTitle("...", for: .normal)
        menuButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        menuButton.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(menuButton)

        menuButton.snp.makeConstraints { make in
            make.right.equalTo(customNavBar).offset(-16)
            make.centerY.equalTo(customNavBar)
        }
    }

    // 返回按钮功能
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    // 菜单按钮功能
    @objc func menuButtonTapped() {
        let alert = UIAlertController(title: "选项", message: nil, preferredStyle: .actionSheet)

        // 解答选项
        let answerAction = UIAlertAction(title: "解答", style: .default) { [weak self] _ in
            self?.viewModel.showAnswers()
            self?.tableView.reloadData()
        }

        // 取消收藏
        let cancelCollection = UIAlertAction(title: "取消收藏", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.cancelCollection { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        let successAlert = UIAlertController(title: "取消收藏", message: "取消收藏成功", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                            // 在提示框消失后，先关闭当前视图控制器，再调用闭包
                            self.dismiss(animated: true) {
                                self.dataDismiss?()
                            }
                        }))
                        self.present(successAlert, animated: true, completion: nil)
                    case .failure(let error):
                        let errorAlert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(answerAction)
        alert.addAction(cancelCollection)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    // 设置表格视图
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ParagraphCell.self, forCellReuseIdentifier: "ParagraphCell")
        tableView.backgroundColor = UIColor(named: "CollectionBackGround")
        tableView.separatorStyle = .none

        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - UITableViewDataSource

    // 返回行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 问题段落 + 选项数量
        return (viewModel?.questionData.options.count ?? 0) + 1
    }

    // 配置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            // 显示问题段落
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor(named: "CollectionBackGround")

            // 创建卡片样式的 view
            let cardView = UIView()
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 10
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cell.contentView.addSubview(cardView)

            // 添加 label 到卡片内
            let questionLabel = UILabel()
            questionLabel.text = viewModel.getQuestionText()
            questionLabel.numberOfLines = 0
            cardView.addSubview(questionLabel)

            // 使用 SnapKit 设置卡片的 Auto Layout 约束
            cardView.snp.makeConstraints { make in
                make.top.equalTo(cell.contentView.snp.top).offset(10)
                make.leading.equalTo(cell.contentView.snp.leading).offset(10)
                make.trailing.equalTo(cell.contentView.snp.trailing).offset(-10)
                make.bottom.equalTo(cell.contentView.snp.bottom).offset(-10)
            }

            // 设置 label 的约束
            questionLabel.snp.makeConstraints { make in
                make.top.equalTo(cardView.snp.top).offset(15)
                make.leading.equalTo(cardView.snp.leading).offset(15)
                make.trailing.equalTo(cardView.snp.trailing).offset(-15)
                make.bottom.equalTo(cardView.snp.bottom).offset(-15)
            }

            return cell
        } else {
            // 显示选项
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as? ParagraphCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "CollectionBackGround")

            let optionIndex = indexPath.row - 1
            let selectedAnswer = viewModel.getSelectedAnswer(for: optionIndex)
            let options = viewModel.getOptions(for: optionIndex)

            cell.answerSelectLabel.text = "(\(selectedAnswer))"
            cell.optionLabel0.setTitle(options[0], for: .normal)
            cell.optionLabel1.setTitle(options[1], for: .normal)
            cell.optionLabel2.setTitle(options[2], for: .normal)
            cell.optionLabel3.setTitle(options[3], for: .normal)

            // 设置按钮的 tag，用于区分选项
            cell.optionLabel0.tag = optionIndex * 10 + 0
            cell.optionLabel1.tag = optionIndex * 10 + 1
            cell.optionLabel2.tag = optionIndex * 10 + 2
            cell.optionLabel3.tag = optionIndex * 10 + 3

            // 添加目标动作
            cell.optionLabel0.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel1.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel2.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel3.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)

            cell.translateButton.tag = optionIndex
            cell.translateButton.addTarget(self, action: #selector(translateText(_:)), for: .touchUpInside)
            cell.translateButton.isHidden = true

            if viewModel.isTapCheck {
                cell.translateButton.isHidden = false
                cell.optionLabel0.isUserInteractionEnabled = false
                cell.optionLabel1.isUserInteractionEnabled = false
                cell.optionLabel2.isUserInteractionEnabled = false
                cell.optionLabel3.isUserInteractionEnabled = false

                let correctAnswer = viewModel.getCorrectAnswer(for: optionIndex)

                if selectedAnswer == correctAnswer {
                    cell.answerSelectLabel.textColor = .green
                    cell.answerSelectLabel.text = "( \(selectedAnswer) )"
                } else {
                    cell.answerSelectLabel.textColor = .red
                    cell.answerSelectLabel.text = "( \(selectedAnswer) )"
                }
            } else {
                cell.answerSelectLabel.textColor = .black
                cell.optionLabel0.isUserInteractionEnabled = true
                cell.optionLabel1.isUserInteractionEnabled = true
                cell.optionLabel2.isUserInteractionEnabled = true
                cell.optionLabel3.isUserInteractionEnabled = true
            }

            return cell
        }
    }

    // MARK: - 用户交互

    // 处理选项按钮的点击事件
    @objc func tapOptions(_ sender: UIButton) {
        let optionIndex = sender.tag / 10
        let optionTag = sender.tag % 10

        var answer = ""
        switch optionTag {
        case 0:
            answer = "A"
        case 1:
            answer = "B"
        case 2:
            answer = "C"
        case 3:
            answer = "D"
        default:
            print("Option error")
            return
        }

        viewModel.setSelectedAnswer(answer, for: optionIndex)

        // 刷新当前单元格
        let indexPath = IndexPath(row: optionIndex + 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    // 显示答案的详细信息
    @objc private func translateText(_ sender: UIButton) {
        let answerText = viewModel.getAnswerText(for: sender.tag)
        let alert = UIAlertController(title: "Answer Text", message: answerText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
