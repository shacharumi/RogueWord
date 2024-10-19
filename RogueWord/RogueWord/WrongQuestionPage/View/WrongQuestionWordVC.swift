
//
//  WrongQuestionWordVC.swift
//  RogueWord
//
//  Created by shachar on 2024/9/23.
//

// WrongQuestionWordVC.swift
import UIKit
import SnapKit

class WrongQuestionWordVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var questions: [GetWordFillType] = []  // 这里存放传递过来的问题数据
    var questionsTitle: String?
    var dataDismiss: (() -> Void)?  // 闭包，用于在视图控制器消失后回调
    
    var viewModel: WrongQuestionWordViewModel!
    private let tableView = UITableView()
    private var customNavBar: UIView!
    private let menuButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar()
        setupTableView()
        view.backgroundColor = UIColor(named: "CollectionBackGround")
        // 初始化 ViewModel
        viewModel = WrongQuestionWordViewModel(questions: questions, questionsTitle: questionsTitle)
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
                    case .success():
                        let successAlert = UIAlertController(title: "取消收藏", message: "取消收藏成功", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                            // 在弹框消失后，执行回调并关闭当前视图控制器
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
        tableView.register(QuestionPageCell.self, forCellReuseIdentifier: "QuestionPageCell")
        tableView.backgroundColor = UIColor(named: "CollectionBackGround")
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    // 返回问题数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return viewModel.questions.count
    }
     
    // 配置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionPageCell", for: indexPath) as? QuestionPageCell else {
            return UITableViewCell()
        }
        
        let question = viewModel.getQuestion(at: indexPath.row)
        let selectedAnswer = viewModel.getSelectedAnswer(for: indexPath.row)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "CollectionBackGround")

        // 显示用户选择的答案
        cell.answerSelectLabel.text = "(\(selectedAnswer))"
        
        // 设置问题和选项
        cell.questionLabel.text = question.question
        cell.optionLabel0.setTitle(question.options[0], for: .normal)
        cell.optionLabel1.setTitle(question.options[1], for: .normal)
        cell.optionLabel2.setTitle(question.options[2], for: .normal)
        cell.optionLabel3.setTitle(question.options[3], for: .normal)
        
        // 设置按钮的 tag，以区分是哪一个选项
        cell.optionLabel0.tag = indexPath.row * 10 + 0
        cell.optionLabel1.tag = indexPath.row * 10 + 1
        cell.optionLabel2.tag = indexPath.row * 10 + 2
        cell.optionLabel3.tag = indexPath.row * 10 + 3
        
        // 添加目标动作
        cell.optionLabel0.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        cell.optionLabel1.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        cell.optionLabel2.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        cell.optionLabel3.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
        
        // 设置答案和翻译按钮
        cell.answerLabel.text = "Answer: \(question.answer)"
        cell.translateButton.tag = indexPath.row
        cell.translateButton.addTarget(self, action: #selector(translateText(_:)), for: .touchUpInside)
        cell.translateButton.isHidden = true

        // 如果用户选择查看答案
        if viewModel.isTapCheck {
            // 禁用选项按钮
            cell.optionLabel0.isUserInteractionEnabled = false
            cell.optionLabel1.isUserInteractionEnabled = false
            cell.optionLabel2.isUserInteractionEnabled = false
            cell.optionLabel3.isUserInteractionEnabled = false

            let correctAnswer = question.answerOptions
            
            cell.translateButton.isHidden = false
            if selectedAnswer == correctAnswer {
                cell.answerSelectLabel.textColor = .green
                cell.answerSelectLabel.text = "( \(selectedAnswer) )"

            } else {
                cell.answerSelectLabel.textColor = .red
                cell.answerSelectLabel.text = "( \(selectedAnswer) )"
            }
        } else {
            // 如果未查看答案，确保颜色和交互性是正常的
            cell.answerSelectLabel.textColor = .black
            cell.optionLabel0.isUserInteractionEnabled = true
            cell.optionLabel1.isUserInteractionEnabled = true
            cell.optionLabel2.isUserInteractionEnabled = true
            cell.optionLabel3.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    // MARK: - 用户交互
    
    // 处理选项按钮的点击事件
    @objc func tapOption(_ sender: UIButton) {
        // 通过 tag 计算出问题的索引和选项的索引
        let questionIndex = sender.tag / 10
        let optionIndex = sender.tag % 10
        
        var answer = ""
        switch optionIndex {
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
        
        // 设置用户选择的答案
        viewModel.setSelectedAnswer(answer, for: questionIndex)
        
        // 刷新当前单元格
        let indexPath = IndexPath(row: questionIndex, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // 显示答案的详细信息
    @objc private func translateText(_ sender: UIButton) {
        let question = viewModel.getQuestion(at: sender.tag)
        let alert = UIAlertController(title: "Answer Text", message: question.answer, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
