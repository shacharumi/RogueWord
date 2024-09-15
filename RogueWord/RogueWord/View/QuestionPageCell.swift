//
//  QuestionPageCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//

import Foundation
import UIKit
import SnapKit

class QuestionPageCell: UITableViewCell {
    var questionLabel: UILabel = {
       let label = UILabel()
       label.textColor = .black
       label.numberOfLines = 0
       label.font = UIFont.boldSystemFont(ofSize: 16)
       return label
    }()
    
    var optionLabel0: UILabel = {
       let label = UILabel()
       label.textColor = .gray
       label.numberOfLines = 0
       label.font = UIFont.systemFont(ofSize: 14)
       return label
    }()
    
    var optionLabel1: UILabel = {
       let label = UILabel()
       label.textColor = .gray
       label.numberOfLines = 0
       label.font = UIFont.systemFont(ofSize: 14)
       return label
    }()
    
    var optionLabel2: UILabel = {
       let label = UILabel()
       label.textColor = .gray
       label.numberOfLines = 0
       label.font = UIFont.systemFont(ofSize: 14)
       return label
    }()
    
    var optionLabel3: UILabel = {
       let label = UILabel()
       label.textColor = .gray
       label.numberOfLines = 0
       label.font = UIFont.systemFont(ofSize: 14)
       return label
    }()
    
    var answerLabel: UILabel = {
       let label = UILabel()
       label.textColor = .lightGray
       label.numberOfLines = 0
       label.font = UIFont.systemFont(ofSize: 14)
       return label
    }()
    
    // MARK: - 初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(questionLabel)
        contentView.addSubview(optionLabel0)
        contentView.addSubview(optionLabel1)
        contentView.addSubview(optionLabel2)
        contentView.addSubview(optionLabel3)

        contentView.addSubview(answerLabel)
        
        // 設置布局
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // 如果從 Interface Builder 加載，這裡可以放置默認的初始化邏輯
    }
    
    // MARK: - 設置約束
    private func setupConstraints() {
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        optionLabel0.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(8)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        optionLabel1.snp.makeConstraints { make in
            make.top.equalTo(optionLabel0.snp.bottom).offset(8)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        optionLabel2.snp.makeConstraints { make in
            make.top.equalTo(optionLabel1.snp.bottom).offset(8)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        optionLabel3.snp.makeConstraints { make in
            make.top.equalTo(optionLabel2.snp.bottom).offset(8)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }
        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(optionLabel3.snp.bottom).offset(8)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView).offset(-16)
        }
    }
}

