//
//  ParticipantCell.swift
//  RogueWord
//
//  Created by shachar on 2024/10/15.
//
import UIKit

class ParticipantCell: UITableViewCell {

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor(named: "TextColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let accuracyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(named: "TextColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(named: "TextColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(nameLabel)
        contentView.addSubview(accuracyLabel)
        contentView.addSubview(timeLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        }

        accuracyLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalTo(nameLabel)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(accuracyLabel)
            make.left.equalTo(accuracyLabel.snp.right).offset(16)
            make.right.lessThanOrEqualTo(contentView).offset(-16)
            make.bottom.equalTo(contentView).offset(-16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
