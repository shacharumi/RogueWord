//
//  CollectionTagCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/18.
//
import UIKit

class CollectionTagCell: UICollectionViewCell {
    let button: UIButton = {
        let button = UIButton(frame: .zero)
        button.configuration?.titleAlignment = .center
        button.titleLabel?.textColor = .white
        button.isUserInteractionEnabled = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        button.frame = contentView.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        button.setTitle(nil, for: .normal)
        button.accessibilityIdentifier = nil
        button.removeTarget(nil, action: nil, for: .allEvents)
        
        for interaction in interactions {
            removeInteraction(interaction)
        }
    }
}

