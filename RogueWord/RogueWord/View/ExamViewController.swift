//
//  ExamViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//

import Foundation
import UIKit
import SnapKit

class ExamViewController: UIViewController {
    
    var buttonArray: [UIButton] = [] // 將 buttonArray 宣告在類別中
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension ExamViewController {
    func setupView() {
        for i in 0..<4 {
            let button = UIButton()
            buttonArray.append(button) // 將按鈕加入到 buttonArray 中
            button.setTitleColor(.lightGray, for: .normal)
            button.addTarget(self, action: #selector(tapToQuestionPage), for: .touchUpInside)
            view.addSubview(button)
            
            switch i {
            case 0:
                button.setTitle("單字填空", for: .normal)
                button.snp.makeConstraints { make in
                    make.top.equalTo(view.safeAreaLayoutGuide)
                    make.left.equalTo(view).offset(16)
                    make.width.height.equalTo(100)
                }
            case 1:
                button.setTitle("段落填空", for: .normal)
                button.snp.makeConstraints { make in
                    make.top.equalTo(view.safeAreaLayoutGuide)
                    make.right.equalTo(view).offset(-16)
                    make.width.height.equalTo(100)
                }
            case 2:
                button.setTitle("閱讀理解", for: .normal)
                button.snp.makeConstraints { make in
                    make.top.equalTo(buttonArray[0].snp.bottom).offset(16) // 正確使用 buttonArray[0]
                    make.left.equalTo(view).offset(16)
                    make.width.height.equalTo(100)
                }
            case 3:
                button.setTitle("聽力測驗", for: .normal)
                button.snp.makeConstraints { make in
                    make.top.equalTo(buttonArray[0].snp.bottom).offset(16) // 正確使用 buttonArray[0]
                    make.right.equalTo(view).offset(-16)
                    make.width.height.equalTo(100)
                }
            default:
                print("Invalid QuestionPage")
            }
        }
    }
    
    @objc func tapToQuestionPage() {
        let questionPage = QuestionPageViewController()
        navigationController?.pushViewController(questionPage, animated: true)
    }
}
