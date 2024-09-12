//
//  CollectionPageCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit
import SnapKit

class CollectionPageCell: UITableViewCell {
    
    let pullDownButton: UIButton = {
        let button = UIButton(type: .system)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        contentView.addSubview(pullDownButton)
        pullDownButton.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-16)
            make.centerY.equalTo(contentView)
            make.height.equalTo(20)
        }
    }
}

