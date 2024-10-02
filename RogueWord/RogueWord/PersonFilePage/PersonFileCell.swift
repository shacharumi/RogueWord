//
//  PersonFileCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/22.
//

import UIKit
import SnapKit

class PersonFileCell: UITableViewCell {

    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(10)
            make.height.equalTo(60)
        }

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.left.equalTo(containerView).offset(15)
            make.width.height.equalTo(30)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = .darkGray
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.right.equalTo(containerView).offset(-15)
        }
    }

    func configureCell(with title: String, icon: UIImage?) {
        titleLabel.text = title
        iconImageView.image = icon
    }
}
