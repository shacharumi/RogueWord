//
//  PersonFileViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/22.
//

import UIKit
import SnapKit

class PersonFileViewController: UIViewController {
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setUpTableView()
        
    }
    
    
}

extension PersonFileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PersonFileCell", for: indexPath) as? PersonFileCell else {
            return UITableViewCell()
        }

        if indexPath.row == 0 {
            cell.personName.text = "Leo"
            cell.personDataView.isHidden = false
        } else {
            cell.personName.text = "Other Person"
            cell.personDataView.isHidden = true
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension PersonFileViewController {
    func setUpTableView() {
        view.addSubview(tableView)
        tableView.register(PersonFileCell.self, forCellReuseIdentifier: "PersonFileCell")
        tableView.backgroundColor = .lightGray
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.right.left.equalTo(view)
            
        }
    }
}
