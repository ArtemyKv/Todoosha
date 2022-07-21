//
//  ListDetailViewViewController.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 17.05.2022.
//

import UIKit

class ListDetailViewController: UIViewController {
    
    var list: List!
    
    var coreDataStack: CoreDataStack!
    
    init(list: List, coreDataStack: CoreDataStack) {
        self.list = list
        self.coreDataStack = coreDataStack
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    var tasksBySections = [Section]()
    
    struct Section {
        var type: SectionType
        var tasks: [Task]
        var isCollapsed: Bool = false
        
        var name: String {
            return type.rawValue
        }
        
        enum SectionType: String {
            case current = "Current"
            case completed = "Completed"
        }
    }
    
    private var listDetailView: ListDetailView! {
        guard isViewLoaded else { return nil }
        return (view as! ListDetailView)
    }
    
    private var tableView: UITableView! {
        guard isViewLoaded else { return nil }
        return listDetailView.tableView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = ListDetailView()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rename", style: .plain, target: self, action: #selector(editBarButtonPressed))
        navigationItem.title = list.name
        
        tableView.delegate = self
        tableView.dataSource = self
        //navigationController?.delegate = self
        
        configureTasksBySections()
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.register(ListDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: ListDetailHeaderView.identifier)
        
        
        
        
        listDetailView.addTaskButton.addTarget(self, action: #selector(addTaskButtonPressed), for: .touchUpInside)
        
        //Dragging
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        
    }
    
    func configureTasksBySections() {
        let tasks: [Task] = (list.tasks?.array as? [Task]) ?? []
        
        var currentTasks = tasks.filter { !$0.isComplete }
        currentTasks.sort { $0.order < $1.order }
        var completedTasks = tasks.filter { $0.isComplete }
        //Handle optinal completionDate!! Now useing force unwrapping which is not really good
        completedTasks.sort { $0.completionDate! < $1.completionDate! }
        
        tasksBySections = [
            Section(type: .current, tasks: currentTasks),
            Section(type: .completed, tasks: completedTasks)
        ]
    }
    
    
    func updateView() {
        navigationItem.title = list.name
    }
    
    //Presents alert when changing list name or after creating new list
    fileprivate func presentRenameAlert() {
        let alert = UIAlertController(title: "New list name", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Accept", style: .default) { _ in
            self.list.name = alert.textFields![0].text ?? ""
            self.coreDataStack.saveContext()
            self.updateView()
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter Name"
            textField.text = self.list.name
        }
        //Enabling and disabling Aceept button if name is empty
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?[0], queue: OperationQueue.main) { _ in
            let textField = alert.textFields![0]
            okAction.isEnabled = !textField.text!.isEmpty
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: alert.textFields?[0], queue: OperationQueue.main) { _ in
            let textField = alert.textFields![0]
            okAction.isEnabled = !textField.text!.isEmpty
        }
        
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    
    //Selector for renameBarButton Action
    @objc func editBarButtonPressed() {
        presentRenameAlert()
        
    }
    
    @objc func addTaskButtonPressed() {
        let addTaskBottomSheetController = AddTaskBottomSheetViewController()
        addTaskBottomSheetController.modalPresentationStyle = .overCurrentContext
        addTaskBottomSheetController.delegate = self
        addTaskBottomSheetController.coreDataStack = coreDataStack
        self.present(addTaskBottomSheetController, animated: false)
    }
}

//MARK: Table view delegate
extension ListDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasksBySections[indexPath.section].tasks[indexPath.row]
        moveToTaskScreen(withTask: task)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Cell moving limits (cant move from or to completed tasks)
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let sourceSectionNumber = sourceIndexPath.section
        let destinationSectionNumber = proposedDestinationIndexPath.section
        
        if sourceSectionNumber == 1 || destinationSectionNumber == 1 {
            return sourceIndexPath
        }
        
        return proposedDestinationIndexPath
    }

}

//MARK: Table view data source
extension ListDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasksBySections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let listSection = tasksBySections[section]
        if listSection.isCollapsed {
            return 0
        } else {
           return tasksBySections[section].tasks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        let task = tasksBySections[indexPath.section].tasks[indexPath.row]
        cell.update(with: task)
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListDetailHeaderView.identifier) as! ListDetailHeaderView
            let listSection = tasksBySections[section]
            header.update(with: listSection)
            header.sectionNumber = section
            header.delegate = self
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentSection = tasksBySections[section]
        if section == 1 && !currentSection.tasks.isEmpty {
            return UITableView.automaticDimension
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedTask = tasksBySections[indexPath.section].tasks.remove(at: indexPath.row)
            coreDataStack.managedContext.delete(removedTask)
            coreDataStack.saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            //Animation works incorrectly
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
            case 0: return true
            case 1: return false
            default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = tasksBySections[sourceIndexPath.section].tasks.remove(at: sourceIndexPath.row)
        tasksBySections[destinationIndexPath.section].tasks.insert(task, at: destinationIndexPath.row)
        
        for (index, task) in tasksBySections[destinationIndexPath.section].tasks.enumerated() {
            task.order = Int32(index)
        }
    }
}

//MARK: Conforming to TaskCell protocol
extension ListDetailViewController: TaskTableViewCellDelegate {
    func checkmarkTapped(sender: UITableViewCell) {
        if let currentIndexPath = tableView.indexPath(for: sender) {
            
            let task = tasksBySections[currentIndexPath.section].tasks[currentIndexPath.row]
            let targetSectionNumber = currentIndexPath.section == 0 ? 1: 0
            let targetSection = tasksBySections[targetSectionNumber]
            let targetRowNumber = targetSection.tasks.count
            let newIndexPath = IndexPath(item: targetRowNumber, section: targetSectionNumber)
            
            task.isComplete.toggle()
            if task.isComplete {
                task.completionDate = Date()
                task.order = 0
            } else if !task.isComplete {
                task.completionDate = nil
                task.order = Int32(targetSection.tasks.count)
            }
            coreDataStack.saveContext()
            
            tasksBySections[currentIndexPath.section].tasks.remove(at: currentIndexPath.row)
            tasksBySections[targetSectionNumber].tasks.append(task)
            
            if targetSection.isCollapsed {
                tableView.deleteRows(at: [currentIndexPath], with: .automatic)
            } else {
                tableView.moveRow(at: currentIndexPath, to: newIndexPath)
                tableView.reloadRows(at: [newIndexPath], with: .automatic)
            }
            //tableView.reloadData()
        }
        
    }
}
//MARK: HeaderViewDelegate protocol (handling section collapsing behavior)
extension ListDetailViewController: ListDetailHeaderViewDelegate {
    func headerTapped(sender: UITableViewHeaderFooterView) {
        guard let header = sender as? ListDetailHeaderView else { return }
        tasksBySections[header.sectionNumber].isCollapsed.toggle()
        let section = tasksBySections[header.sectionNumber]
        
        var indexPaths = [IndexPath]()
        
        for i in 0..<section.tasks.count {
            let indexPath = IndexPath(row: i, section: header.sectionNumber)
            indexPaths.append(indexPath)
        }
        tableView.beginUpdates()
        if section.isCollapsed {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        } else if !section.isCollapsed {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        tableView.endUpdates()
    }
}
/*
//Conforming to NavigationControllerDelegate (preparing for go back to HomeView)
// It was used when model was based on structs.
extension ListDetailViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        guard let homeVC = viewController as? HomeViewController else { return }
        if let groupID = list.groupID,
           let groupIndex = homeVC.database.userGroups.firstIndex(where: { $0.id == groupID }),
           let listIndex = homeVC.database.userGroups[groupIndex].subitems.firstIndex(of: list) {
            homeVC.database.userGroups[groupIndex].subitems[listIndex] = list
        } else if let listIndex = homeVC.database.userUngroupedLists.firstIndex(of: list) {
            homeVC.database.userUngroupedLists[listIndex] = list
            
        }
         
        homeVC.applySnapshots()
    }
}
 */


extension ListDetailViewController {
    func moveToTaskScreen(withTask task: Task) {
        let storyboard = UIStoryboard(name: "TaskScreen", bundle: nil)
        let taskNavigationController = storyboard.instantiateViewController(withIdentifier: "TaskNavigationController") as! UINavigationController
        let taskViewController = taskNavigationController.viewControllers[0] as! TaskTableViewController
        taskViewController.task = task
        taskViewController.coreDataStack = coreDataStack
        taskViewController.delegate = self
        self.present(taskNavigationController, animated: true)

    }
}


extension ListDetailViewController: TaskTableViewControllerDelegate {
    func updateTaskWith(task: Task) {
        configureTasksBySections()
        tableView.reloadData()
    }
}

extension ListDetailViewController: AddTaskBottomSheetDelegate {
    func saveTask(_ task: Task) {
        let sectionNumber = task.isComplete ? 1 : 0
        
        task.order = task.isComplete ? 0 : Int32(tasksBySections[sectionNumber].tasks.count)
        list.addToTasks(task)
        coreDataStack.saveContext()
        
        tasksBySections[sectionNumber].tasks.append(task)
        tableView.reloadData()
    }
    
    
}


extension ListDetailViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        //let dragItem = UIDragItem(itemProvider: NSItemProvider())
        //dragItem.localObject = tasksBySections[indexPath.section].tasks[indexPath.row]
        return []
    }
}
