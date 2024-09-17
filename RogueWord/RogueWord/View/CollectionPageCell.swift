import UIKit
import SnapKit

class CollectionPageCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let optionPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    var optionArray: [String] = []
    var viewModel = CollectionPageViewModel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func registerOptionButton(_ tags: [String]) {
        optionArray = tags
        optionPickerView.reloadAllComponents()
    }
    
    private func setupView() {
        contentView.addSubview(optionPickerView)
        
        optionPickerView.delegate = self
        optionPickerView.dataSource = self
        
        optionPickerView.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-16)
            make.height.equalTo(50)
            make.width.equalTo(90)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedOption = optionArray[row]
     
        viewModel.updateWordTag(selectedOption, optionPickerView.tag)
    }
}
