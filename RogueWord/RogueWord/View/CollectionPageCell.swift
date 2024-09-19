import UIKit
import DropDown
import SnapKit

class CollectionPageCell: UITableViewCell {

    let dropDownButton: DropDown = {
       let dropDown = DropDown()
        return dropDown
    }()
    
    let testView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
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
        contentView.addSubview(testView)
        testView.addSubview(tagLabel)
        dropDownButton.anchorView = testView
        dropDownButton.direction = .bottom
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTestViewTap))
        testView.addGestureRecognizer(tapGesture)
        
        testView.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-16)
            make.height.equalTo(50)
            make.width.equalTo(90)
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
}
