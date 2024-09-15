import UIKit
import SnapKit

class CollectionPageCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // UIPickerView 來顯示選項
    let optionPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    // 選項數據源
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
    
    // 註冊選項，並重新載入 PickerView 數據
    func registerOptionButton(_ tags: [String]) {
        optionArray = tags
        optionPickerView.reloadAllComponents() // 重新載入 UIPickerView
    }
    
    private func setupView() {
        contentView.addSubview(optionPickerView)
        
        // 設置 PickerView 的委派和數據源
        optionPickerView.delegate = self
        optionPickerView.dataSource = self
        
        // 使用 SnapKit 設置 PickerView 的佈局
        optionPickerView.snp.makeConstraints { make in
            make.right.equalTo(contentView).offset(-16)
            make.height.equalTo(50) // 給 PickerView 設置一個合適的高度
            make.width.equalTo(90)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 只顯示一列
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionArray.count // 根據數據源的選項數量
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionArray[row] // 返回每個選項的標題
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 當選擇某個選項時，處理對應的邏輯
        let selectedOption = optionArray[row]
        print(selectedOption)
        print(optionPickerView.tag)
        viewModel.updateWordTag(selectedOption, optionPickerView.tag)
    }
}
