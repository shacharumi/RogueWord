import UIKit
import DropDown
import SnapKit

class CollectionPageCell: UITableViewCell {

    let dropDownButton: DropDown = {
       let dropDown = DropDown()
        
        return dropDown
    }()
    
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
    
    let testView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        
        view.backgroundColor = .lightGray
        return view
    }()
    
    let tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    var viewModel = CollectionPageViewModel()
    var cellID: Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
   
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    
    func registerOptionButton(_ tags: [String]) {
        dropDownButton.dataSource = tags
    }
    
    private func setupView() {
        contentView.addSubview(cardView)
        contentView.addSubview(testView)
        testView.addSubview(tagLabel)
        dropDownButton.anchorView = testView
        dropDownButton.direction = .bottom
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTestViewTap))
        testView.addGestureRecognizer(tapGesture)
        
        cardView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(16)
            make.top.equalTo(contentView)
            make.right.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView)
        }
        
        testView.snp.makeConstraints { make in
            make.right.equalTo(cardView).offset(-16)
            make.centerY.equalTo(contentView)
            make.height.equalTo(24)
            make.width.equalTo(50)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dropDownButton.selectionAction = { [weak self] (index: Int, item: String) in
            self?.tagLabel.text = item
            self?.viewModel.updateWordTag(item, self?.cellID ?? 0)
        }
    }

    @objc private func handleTestViewTap() {
        if dropDownButton.isHidden {
            dropDownButton.show()
        } else {
            dropDownButton.hide()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
}
