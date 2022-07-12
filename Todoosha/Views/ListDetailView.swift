//
//  ListDetailView.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 18.05.2022.
//

import UIKit

class ListDetailView: UIView {

    var tableView: UITableView!
    //var textField: UITextField!
    
    var addTaskButton: UIButton!
    
    func setupVIew() {
        /*
        textField = {
            let textField = UITextField()
            textField.textAlignment = .natural
            textField.placeholder = "Add new task"
            textField.borderStyle = .roundedRect
            return textField
        }()
        */
        
        addTaskButton = {
            let button = UIButton()
            var config = UIButton.Configuration.filled()
            config.title = "Add new task"
            button.configuration = config
            
            return button
        }()
        tableView = UITableView(frame: self.bounds, style: .plain)

  
        
        let vStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [tableView, addTaskButton])
            stack.axis = .vertical
            stack.distribution = .fill
            stack.alignment = .fill
            stack.frame = self.bounds
            return stack
        }()
        
        self.addSubview(vStack)
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            //textField.heightAnchor.constraint(equalToConstant: 50),
            addTaskButton.leadingAnchor.constraint(equalTo: vStack.leadingAnchor, constant: 15),
            addTaskButton.trailingAnchor.constraint(equalTo: vStack.trailingAnchor, constant: -15),
            addTaskButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupVIew()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupVIew()
    }
    
}
