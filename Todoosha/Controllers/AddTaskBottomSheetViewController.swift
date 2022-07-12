//
//  AddTaskBottonSheetViewController.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 30.05.2022.
//

import UIKit

protocol AddTaskBottomSheetDelegate: AnyObject {
    func saveTask(_ task: Task)
}


class AddTaskBottomSheetViewController: UIViewController {
    
    //MARK: Properties
    
    var task: Task?
    
    weak var delegate: AddTaskBottomSheetDelegate?
    
    
    //MARK: Seting up views
    
    //Container sheet view
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    //View for dimming background
    let maxDimmedAlpha: CGFloat = 0.6
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    lazy var tapGestureView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    //Content of the bottom sheet
    //First row
    var cancelButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.borderless()
        configuration.buttonSize = .medium
        configuration.title = "Cancel"
        button.configuration = configuration
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "New Task"
        label.textAlignment = .center
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return label
    }()
    
    var createButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.borderless()
        configuration.title = "Create"
        configuration.buttonSize = .medium
        button.configuration = configuration
        button.isEnabled = false
        return button
    }()
    
    lazy var firstRowHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, titleLabel, createButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    //Second  row
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.placeholder = "New task"
        textField.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return textField
    }()
    
    lazy var checkmarkButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.borderless()
        configuration.title = ""
        configuration.image = UIImage(systemName: "diamond")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.medium)
        button.configuration = configuration
        return button
    }()
    
    lazy var secondRowHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [checkmarkButton, nameTextField])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    //Third row
    lazy var myDayButton: UIButton = {
        configureButton(title: "My Day", imageName: "sun.max")
    }()
    
    lazy var remindButton: UIButton = {
        configureButton(title: "Remind", imageName: "clock")
    }()
    
    lazy var dueButton: UIButton = {
        configureButton(title: "Due", imageName: "calendar")
    }()
    
    func configureButton(title: String, imageName: String) -> UIButton {
        let button = UIButton()
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.buttonSize = .medium
        configuration.image = UIImage(systemName: imageName)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 5
        configuration.title = title
        button.configuration = configuration
        return button
    }
    
    lazy var thirdRowHStack: UIStackView = {
        let spacer = UIView()
        let stack = UIStackView(arrangedSubviews: [myDayButton, remindButton, dueButton, spacer])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    //Date rows
    //Forth row
    lazy var reminderLabel: UILabel = {
        let label = UILabel()
        label.text = "Remind date"
        label.textAlignment = .right
        return label
    }()
    
    lazy var reminderDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = .current
        datePicker.minimumDate = Date()

        return datePicker
    }()
    
    lazy var forthRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reminderLabel,reminderDatePicker])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()
    
    //Fifth row
    lazy var dueLabel: UILabel = {
        let label = UILabel()
        label.text = "Due date"
        label.textAlignment = .right
        return label
    }()
    
    lazy var dueDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = .current
        datePicker.minimumDate = Date()
        return datePicker
    }()
    
    lazy var fifthRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dueLabel,dueDatePicker])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()
    
    lazy var spacer: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        view.setContentCompressionResistancePriority(UILayoutPriority(749), for: .vertical)
        return view
    }()
    
    lazy var containerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstRowHStack, secondRowHStack, thirdRowHStack, forthRowStack, fifthRowStack, spacer])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 16
        return stack
    }()

    
    //Height of the bottom sheet
    let defaultHeightConstant: CGFloat = 180
    let dismissableHeight: CGFloat = 200
    let maxHeight: CGFloat = 800
    
    var containerViewHeight: CGFloat {
        containerStack.frame.height
    }
    
    let defaultRowHeightConstant: CGFloat = 44
    
    //Dynamic constraints
    var heightConstraint: NSLayoutConstraint?
    var bottomAnchorConstraint: NSLayoutConstraint?
    var spacerHeightConstraint: NSLayoutConstraint?
    

    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupPanGesture()
        setupTapGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Button actions
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        myDayButton.addTarget(self, action: #selector(myDayButtonPressed), for: .touchUpInside)
        remindButton.addTarget(self, action: #selector(dateButtonPressed(sender:)), for: .touchUpInside)
        dueButton.addTarget(self, action: #selector(dateButtonPressed(sender:)), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateAppearance()
        nameTextField.becomeFirstResponder()
    }
    
    //MARK: Setting up views and constraints
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        view.addSubview(tapGestureView)
        
        //Add content to sheet
        containerView.addSubview(containerStack)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        tapGestureView.translatesAutoresizingMaskIntoConstraints = false
        
        //Content
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tapGestureView.topAnchor.constraint(equalTo: view.topAnchor),
            tapGestureView.bottomAnchor.constraint(equalTo: containerView.topAnchor),
            tapGestureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tapGestureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerStack.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 10),
            containerStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerStack.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),
            //firstRowHStack.heightAnchor.constraint(equalToConstant: defaultRowHeightConstant),
            //secondRowHStack.heightAnchor.constraint(equalToConstant: 30),
            //thirdRowHStack.heightAnchor.constraint(equalToConstant: defaultRowHeightConstant)
        ])
        
        heightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeightConstant)
        bottomAnchorConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeightConstant)
        //spacerHeightConstraint = spacer.heightAnchor.constraint(equalToConstant: 0)
        
        heightConstraint?.isActive = true
        bottomAnchorConstraint?.isActive = true
        //spacerHeightConstraint?.isActive = true
    }
    
    //MARK: Animating views
    func animateAppearance() {
        dimmedView.alpha = 0
        tapGestureView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.bottomAnchorConstraint?.constant = 0
            self.view.layoutIfNeeded()
            
        }
        
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
            self.tapGestureView.alpha = 0.1
        }
    }
    
    func animateDismiss() {
        UIView.animate(withDuration: 0.3) {
            self.bottomAnchorConstraint?.constant = self.defaultHeightConstant
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
            self.tapGestureView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    //MARK: setting up gestures
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        
        view.addGestureRecognizer(panGesture)
    }

    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        let isDraggingDown = translation.y > 0
        
        switch gesture.state {
            case .changed:
                heightConstraint?.constant = isDraggingDown ? (defaultHeightConstant - translation.y) : (defaultHeightConstant - translation.y / 10)
                self.view.layoutIfNeeded()
            case .ended:
                if defaultHeightConstant - translation.y < dismissableHeight {
                    nameTextField.resignFirstResponder()
                    animateDismiss()
                }
                else {
                    UIView.animate(withDuration: 0.3) {
                        self.heightConstraint?.constant = self.defaultHeightConstant
                        self.view.layoutIfNeeded()
                    }
                }
            default:
                break
        }
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gesture:)))
        tapGesture.delaysTouchesEnded = false
        tapGesture.delaysTouchesBegan = false
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        tapGestureView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture(gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        animateDismiss()
    }
    
    //MARK: managing kyboard appearance
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo, let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.size.height
        print(keyboardHeight)
        
        bottomAnchorConstraint?.constant = -keyboardHeight
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomAnchorConstraint?.constant = 0
        view.layoutIfNeeded()
    }
    
    //MARK: Button actions
    
    @objc func cancelButtonTapped() {
        nameTextField.resignFirstResponder()
        animateDismiss()
    }
    
    @objc func createButtonTapped() {
        task = Task(name: nameTextField.text!)
        task?.creationDate = Date()
        task?.dueDate = dueButton.isSelected ? dueDatePicker.date : nil
        task?.remindDate = remindButton.isSelected ? reminderDatePicker.date : nil
        task?.myDay = myDayButton.isSelected
        delegate?.saveTask(task!)
        nameTextField.resignFirstResponder()
        animateDismiss()
    }
    
    @objc func textFieldEditingChanged() {
        if let taskName = nameTextField.text {
            createButton.isEnabled = !taskName.isEmpty
        }
    }
    
    @objc func myDayButtonPressed() {
        myDayButton.isSelected.toggle()
    }
    
    fileprivate func toggleDatePickerRowVisibility(row: UIStackView) {
        UIView.animate(withDuration: 0.25) {
            row.isHidden.toggle()
            if row.isHidden {
                self.heightConstraint?.constant -= self.defaultRowHeightConstant
                self.view.layoutIfNeeded()
            } else {
                self.heightConstraint?.constant += self.defaultRowHeightConstant
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func dateButtonPressed(sender: UIButton) {
        sender.isSelected.toggle()
        
        switch sender {
            case remindButton:
                toggleDatePickerRowVisibility(row: forthRowStack)
                
            case dueButton:
                toggleDatePickerRowVisibility(row: fifthRowStack)
            default:
                break
        }
    }
}
