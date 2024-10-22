//
//  ReadingTestCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/20.
//

import Foundation
import UIKit
import SnapKit

class ReadingTestCell: UITableViewCell {
    var cardView: UIView = {
        let view = UIView()
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    var answerSelectLabel: UILabel = {
       let label = UILabel()
       label.textColor = .black
       label.numberOfLines = 0
       label.font = UIFont.boldSystemFont(ofSize: 16)
       return label
    }()
    
    var optionLabel0: UIButton = {
       let button = UIButton()
        button.tag = 0
        button.setTitleColor(UIColor(named: "HomeTextColor"), for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.isUserInteractionEnabled = true
       return button
    }()
    
    var optionLabel1: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setTitleColor(UIColor(named: "HomeTextColor"), for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var optionLabel2: UIButton = {
        let button = UIButton()
        button.tag = 2
        button.setTitleColor(UIColor(named: "HomeTextColor"), for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var optionLabel3: UIButton = {
        let button = UIButton()
        button.tag = 3
        button.setTitleColor(UIColor(named: "HomeTextColor"), for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var answerLabel: UILabel = {
       let label = UILabel()
       label.textColor = .lightGray
       label.numberOfLines = 0
       label.font = UIFont.systemFont(ofSize: 14)
       return label
    }()
    
    var translateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("翻譯", for: .normal)
        button.isUserInteractionEnabled = true
        button.isHidden = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cardView)
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerSelectLabel)
        contentView.addSubview(answerLabel)
        contentView.addSubview(optionLabel0)
        contentView.addSubview(optionLabel1)
        contentView.addSubview(optionLabel2)
        contentView.addSubview(optionLabel3)
        contentView.addSubview(translateButton)

        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.top.left.equalTo(contentView).offset(8)
            make.right.bottom.equalTo(-8)
        }
        
        answerSelectLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(50)
        }

        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(answerSelectLabel.snp.bottom).offset(8)
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(50)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(answerSelectLabel.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-16)
        }
        
        optionLabel0.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(8)
            make.left.equalTo(answerSelectLabel.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-16)
        }

        optionLabel1.snp.makeConstraints { make in
            make.top.equalTo(optionLabel0.snp.bottom).offset(8)
            make.left.equalTo(answerSelectLabel.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-16)
        }

        optionLabel2.snp.makeConstraints { make in
            make.top.equalTo(optionLabel1.snp.bottom).offset(8)
            make.left.equalTo(answerSelectLabel.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-16)
        }

        optionLabel3.snp.makeConstraints { make in
            make.top.equalTo(optionLabel2.snp.bottom).offset(8)
            make.left.equalTo(answerSelectLabel.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView).offset(-16)
        }
        translateButton.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-16)
            make.height.equalTo(40)
            make.bottom.equalTo(contentView).offset(-8)

        }
    }
}
