//
//  TaskTableViewController.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 25.05.2022.
//

import UIKit

protocol TaskTableViewControllerDelegate: AnyObject {
    func updateTaskWith(task: Task)
}


class TaskTableViewController: UITableViewController {
    
    var task: Task!
    
    var subtaskDataSource: SubtaskTableViewDataSource!
    
    var coreDataStack: CoreDataStack!

    weak var delegate: TaskTableViewControllerDelegate?
    
    
    //MARK: Outlets
    
    //Navigation bar
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    //Name section
    @IBOutlet weak var isCompleteButton: UIButton!
    @IBOutlet weak var isImportantButton: UIButton!
    @IBOutlet weak var nameTextView: UITextView!
    
    //Subtasks section
    @IBOutlet weak var subtasksTableView: UITableView!
    @IBOutlet weak var subtaskTextField: UITextField!
    
    
    //Dates section
    
    @IBOutlet weak var myDayLabel: UILabel!
    @IBOutlet weak var remindDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    //Notes section
    @IBOutlet weak var notesTextView: UITextView!
    
    //Toolbar
    @IBOutlet weak var creationDateButton: UIBarButtonItem!
    @IBOutlet weak var deleteTaskButton: UIBarButtonItem!
    
    //MARK: IndexPaths for selectable cells
    
    let nameCellIndexPath = IndexPath(row: 0, section: 0)
    let subtaskTableViewIndexPath = IndexPath(row: 0, section: 1)
    let myDayCellIndexPath = IndexPath(row: 0, section: 2)
    let remindMeCellIndexpath = IndexPath(row: 1, section: 2)
    let dueDateIndexPath = IndexPath(row: 2, section: 2)
    let addFilesIndexPath = IndexPath(row: 0, section: 3)
    let notesIndexPath = IndexPath(row: 0, section: 4)
    
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        subtaskDataSource = SubtaskTableViewDataSource(subtasks: task.subtasks)
        subtaskDataSource.cellDelegate = self
        subtaskDataSource.delegate = self
        subtasksTableView.dataSource = subtaskDataSource
        subtasksTableView.delegate = subtaskDataSource
        subtasksTableView.dragDelegate = subtaskDataSource
        subtasksTableView.register(SubtaskTableViewCell.self, forCellReuseIdentifier: SubtaskTableViewCell.identifier)
        
        nameTextView.delegate = self
        notesTextView.delegate = self
        
        nameTextView.inputAccessoryView = setupInputAccessoryView()
        notesTextView.inputAccessoryView = setupInputAccessoryView()
        
        updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateTaskWith(task: task)
    }
    
    
    //MARK: Actions
    
    //Navigation bar
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    
    //Name section
    
    
    
    @IBAction func isCompleteButtonPressed(_ sender: UIButton) {
        task.isComplete.toggle()
        updateView()
    }
    
    @IBAction func isImportantButtonPressed(_ sender: UIButton) {
        task.isImportant.toggle()
        updateView()
    }
    
    //Date section
    func myDayButtonTapped() {
        task.myDay.toggle()
        updateView()
    }
    
    func reminderCellTapped() {
        
    }
    
    //Subtasks section
    @IBAction func textFieldDoneButtonPressed(_ sender: UITextField) {
        if let subtaskName = sender.text, !subtaskName.isEmpty {
            let subtask = Subtask(context: coreDataStack.managedContext)
            subtask.name = subtaskName
            task.addToSubtasks(subtask)
            updateSubtaskTableView()
            sender.text = ""
            sender.resignFirstResponder()
            coreDataStack.saveContext()
        }
    }
    
    
    
    //Toolbar
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    //MARK: Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
            case myDayCellIndexPath:
                myDayButtonPressed()
            default:
                break
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let defaultHeight = CGFloat(44)
        switch indexPath {
            case subtaskTableViewIndexPath:
                return CGFloat(task.subtasks?.count ?? 0) * defaultHeight
            case notesIndexPath:
                return 200
            case nameCellIndexPath:
                return UITableView.automaticDimension
            default:
                return defaultHeight
        }
    }
    

    
    //MARK: Methods
    
    func updateView() {
        nameTextView.text = task.name
        myDayLabel.text = task.myDay ? "Remove from My Day" : "Add to My Day"
        remindDateLabel.text = task.remindDate?.formatted(date: .abbreviated, time: .omitted)
        dueDateLabel.text = task.dueDate?.formatted(date: .abbreviated, time: .omitted)
        isCompleteButton.isSelected = task.isComplete
        isImportantButton.isSelected = task.isImportant
        notesTextView.text = task.notes
        
        coreDataStack.saveContext()
        
        
        //Creation(completion) toolbar text
        let prefix = task.isComplete ? "Completed" : "Created"
        let dateToDisplay = task.isComplete ? task.completionDate : task.creationDate
        
        if let dateToDisplay = dateToDisplay {
            creationDateButton.title = prefix + " " + dateToDisplay.formatted(date: .abbreviated, time: .shortened)
        } else {
            creationDateButton.title = ""
        }
    }
    
    func updateSubtaskTableView() {
        subtasksTableView.reloadData()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func myDayButtonPressed() {
        task.myDay.toggle()
        updateView()
    }
    
    func setupInputAccessoryView() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolBarDoneButtonPressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [flexibleSpace, doneButton]
        return toolBar
    }
    
    @objc func toolBarDoneButtonPressed() {
        nameTextView.resignFirstResponder()
        notesTextView.resignFirstResponder()
    }
        
}

extension TaskTableViewController: SubtaskTableViewCellDelegate {
    func textFieldEditingFinished(sender: UITableViewCell) {
        guard let indexPath = subtasksTableView.indexPath(for: sender),
              let subtask = task.subtasks?[indexPath.row] as? Subtask,
              let cell = sender as? SubtaskTableViewCell
        else { return }
        subtask.name = cell.titleTextField.text!
        updateSubtaskTableView()
        coreDataStack.saveContext()
    }
    
    
    func checkmarkTapped(sender: UITableViewCell) {
        guard let indexPath = subtasksTableView.indexPath(for: sender),
              let subtask = task.subtasks?[indexPath.row] as? Subtask
        else { return }
        subtask.isComplete.toggle()
        updateSubtaskTableView()
        coreDataStack.saveContext()
    }
    
    func xmarkTapped(sender: UITableViewCell) {
        guard let indexPath = subtasksTableView.indexPath(for: sender) else { return }
        task.removeFromSubtasks(at: indexPath.row)
        updateSubtaskTableView()
        coreDataStack.saveContext()
    }
    
    
}

extension TaskTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        task.name = nameTextView.text
        task.notes = notesTextView.text
        tableView.beginUpdates()
        tableView.endUpdates()
        coreDataStack.saveContext()
    }
}

extension TaskTableViewController: SubtaskTableViewDataSourceDelegate {
    func reorderingFinished() {
        coreDataStack.saveContext()
    }
    
    
}
