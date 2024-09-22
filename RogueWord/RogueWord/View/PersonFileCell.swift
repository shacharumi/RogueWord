//
//  PersonFileCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/22.
//

import UIKit
import SnapKit

class PersonFileCell: UITableViewCell {
    
    var personDataView: UIView = {
       let view = UIView()
        return view
    }()
    
    var personImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person")
        return image
    }()
    
    var personName: UILabel = {
        let label = UILabel()
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(personDataView)
        personDataView.addSubview(personImage)
        personDataView.addSubview(personName)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpConstrain() {
        personDataView.snp.makeConstraints { make in
            make.top.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
            make.height.equalTo(100)
            make.bottom.equalTo(contentView).offset(-18)
            
        }
        
        personImage.snp.makeConstraints { make in
            make.top.left.equalTo(personDataView).offset(8)
            make.width.height.equalTo(80)
        }
        personName.snp.makeConstraints { make in
            make.top.equalTo(personDataView).offset(8)
            make.left.equalTo(personImage.snp.right).offset(8)
        }
    }
}
