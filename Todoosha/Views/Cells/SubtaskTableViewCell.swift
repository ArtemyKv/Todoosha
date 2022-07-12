
import UIKit

//Protocol for implementing tapping checkmark feature
protocol SubtaskTableViewCellDelegate: AnyObject {
    func checkmarkTapped(sender: UITableViewCell)
    
    func xmarkTapped(sender: UITableViewCell)
    
    func textFieldEditingFinished(sender: UITableViewCell)
}

class SubtaskTableViewCell: UITableViewCell {
    
    
    static var identifier = "SubtaskCell"
    
    weak var delegate: SubtaskTableViewCellDelegate?
    
    let buttonSymbolConfig = UIImage.SymbolConfiguration(scale: .medium)
    
    var titleTextField: UITextField = {
        let textField = UITextField()
        //Add configuration later
        return textField
    }()
    var completeButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.borderless()
        configuration.title = ""
        button.configuration = configuration
        return button
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.borderless()
        let imageConfig = UIImage.SymbolConfiguration(scale: .small)
        configuration.title = ""
        configuration.image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        button.configuration = configuration
        return button
    }()
    
    var hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        return stack
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
        hStack.addArrangedSubview(completeButton)
        hStack.addArrangedSubview(titleTextField)
        hStack.addArrangedSubview(deleteButton)
        self.contentView.addSubview(hStack)
        
        completeButton.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        deleteButton.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: self.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        titleTextField.addTarget(self, action: #selector(doneButtonPressed), for: .primaryActionTriggered)
        
    }
    
    func update(with subtask: Subtask) {
        let attributedString = NSMutableAttributedString(string: subtask.name)
        let attributeRange = NSRange(location: 0, length: attributedString.length)
        if subtask.isComplete {
            completeButton.configuration?.image = UIImage(systemName: "checkmark.diamond", withConfiguration: buttonSymbolConfig)
            attributedString.addAttribute(NSMutableAttributedString.Key.strikethroughStyle, value: 2, range: attributeRange)
            titleTextField.attributedText = attributedString
            titleTextField.textColor = .systemGray
        } else {
            attributedString.removeAttribute(NSMutableAttributedString.Key.strikethroughStyle, range: attributeRange)
            titleTextField.attributedText = attributedString
            titleTextField.textColor = .black
            completeButton.configuration?.image = UIImage(systemName: "diamond", withConfiguration: buttonSymbolConfig)
        }
    }
    //Action for button target
    @objc func completeButtonTapped() {
        delegate?.checkmarkTapped(sender: self)
    }
    
    @objc func deleteButtonTapped() {
        delegate?.xmarkTapped(sender: self)
    }
    
    @objc func doneButtonPressed() {
        delegate?.textFieldEditingFinished(sender: self)
    }
}

