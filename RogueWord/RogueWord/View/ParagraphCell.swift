//
//  ParagraphCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//

import Foundation
import UIKit
import SnapKit

class ParagraphCell: UITableViewCell {

    // 問題標題
    var answerSelectLabel: UILabel = {
       let label = UILabel()
       label.textColor = .black
       label.numberOfLines = 0
       label.font = UIFont.boldSystemFont(ofSize: 18)  // 加大字型
       return label
    }()
    
    // 選項按鈕
    var optionLabel0: UIButton = {
       let button = UIButton()
       button.tag = 0
       button.setTitleColor(.darkGray, for: .normal)  // 調整成深灰色
       button.titleLabel?.numberOfLines = 0
       button.titleLabel?.font = UIFont.systemFont(ofSize: 16)  // 加大字型
       button.contentHorizontalAlignment = .left
       button.isUserInteractionEnabled = true
       return button
    }()
    
    var optionLabel1: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var optionLabel2: UIButton = {
        let button = UIButton()
        button.tag = 2
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var optionLabel3: UIButton = {
        let button = UIButton()
        button.tag = 3
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.isUserInteractionEnabled = true
        return button
    }()
    
    // 答案說明
    var answerLabel: UILabel = {
       let label = UILabel()
       label.textColor = .lightGray
       label.numberOfLines = 0
       label.font = UIFont.italicSystemFont(ofSize: 14)  // 改為斜體字
       return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(answerSelectLabel)
        contentView.addSubview(answerLabel)
        contentView.addSubview(optionLabel0)
        contentView.addSubview(optionLabel1)
        contentView.addSubview(optionLabel2)
        contentView.addSubview(optionLabel3)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupConstraints() {
        answerSelectLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(60)  // 調整寬度
        }

        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(answerSelectLabel.snp.bottom).offset(8)
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(60)
        }

        optionLabel0.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(answerSelectLabel.snp.right).offset(12)  // 擴大間距
            make.right.equalTo(contentView).offset(-16)
        }

        optionLabel1.snp.makeConstraints { make in
            make.top.equalTo(optionLabel0.snp.bottom).offset(10)  // 調整上下間距
            make.left.equalTo(answerSelectLabel.snp.right).offset(12)
            make.right.equalTo(contentView).offset(-16)
        }

        optionLabel2.snp.makeConstraints { make in
            make.top.equalTo(optionLabel1.snp.bottom).offset(10)
            make.left.equalTo(answerSelectLabel.snp.right).offset(12)
            make.right.equalTo(contentView).offset(-16)
        }

        optionLabel3.snp.makeConstraints { make in
            make.top.equalTo(optionLabel2.snp.bottom).offset(10)
            make.left.equalTo(answerSelectLabel.snp.right).offset(12)
            make.right.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView).offset(-16)
        }
    }
}
