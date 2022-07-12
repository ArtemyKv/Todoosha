//
//  TaskTableViewCell.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 18.05.2022.
//

import UIKit

//Protocol for implementing tapping checkmark feature
protocol TaskTableViewCellDelegate: AnyObject {
    func checkmarkTapped(sender: UITableViewCell)
}

class TaskTableViewCell: UITableViewCell {
    
    static var identifier = "TaskCell"
    
    weak var delegate: TaskTableViewCellDelegate?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        //Add configuration later
        return label
    }()
    var completeButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.borderless()
        configuration.title = ""
        configuration.image = UIImage(systemName: "diamond")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.medium)
        button.configuration = configuration
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        self.contentView.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            completeButton.widthAnchor.constraint(equalTo: completeButton.heightAnchor, multiplier: 1),
            completeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            completeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: completeButton.trailingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor)
        ])
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    func update(with task: Task) {
        let attributedString = NSMutableAttributedString(string: task.name)
        let attributeRange = NSRange(location: 0, length: attributedString.length)
        if task.isComplete {
            completeButton.configuration?.image = UIImage(systemName: "checkmark.diamond")
            attributedString.addAttribute(NSMutableAttributedString.Key.strikethroughStyle, value: 2, range: attributeRange)
            titleLabel.attributedText = attributedString
            titleLabel.textColor = .systemGray
        } else {
            attributedString.removeAttribute(NSMutableAttributedString.Key.strikethroughStyle, range: attributeRange)
            titleLabel.attributedText = attributedString
            titleLabel.textColor = .black
            completeButton.configuration?.image = UIImage(systemName: "diamond")
        }
    }
    //Action for button target
    @objc func completeButtonTapped() {
        delegate?.checkmarkTapped(sender: self)
    }
}
