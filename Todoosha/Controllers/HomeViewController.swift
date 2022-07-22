//
//  HomeViewController.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 12.05.2022.
//



import UIKit
import CoreData


class HomeViewController: UIViewController {
    
    lazy var coreDataStack: CoreDataStack = CoreDataStack(modelName: "Todoosha")
    
    var groupFetchRequest: NSFetchRequest<Group>?
    var groups: [Group] = []
    
    var ungroupedListsFetchRequest: NSFetchRequest<List>?
    var ungroupedLists: [List] = []
    
    
    
    var collectionView: UICollectionView!
    var addTaskButton: UIButton!
    var addListButton: UIButton!
    var addGroupButton: UIButton!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ListItem>!
    
    
    enum Section: CaseIterable {
        case basicLists
        case groupedLists
        case ungroupedLists
    }
    
    enum ListItem: Hashable {
        case basic(BasicItem)
        case group(Group)
        case list(List)
    }
    
    enum BasicItem: String, CaseIterable {
        case today = "Today"
        case income = "Income"
        case important = "Important"
        case planned = "Planned"
        
        var name: String {
            return self.rawValue
        }
    }

    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //Configuring Navigation Bar
        self.navigationItem.title = "Todoosha"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        
        //Setting fetch requests and do fetching from Core Data
        setupFetchRequests()
        performFetching()
        
        
        //Configuring Buttons
        addTaskButton = setupButtonsWith(title: "Task")
        addListButton = setupButtonsWith(title: "List")
        addGroupButton = setupButtonsWith(title: "Group")
        
        addTaskButton.addTarget(self, action: #selector(addTaskButtonTapped), for: .touchUpInside)
        addListButton.addTarget(self, action: #selector(addListButtonTapped), for: .touchUpInside)
        addGroupButton.addTarget(self, action: #selector(addGroupButtonTapped), for: .touchUpInside)

        
        //Main view stackView
        let buttonStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [addListButton, addTaskButton, addGroupButton])
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fill
            return stack
        }()
        
        setupCollectionView()

        let vStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [collectionView, buttonStack])
            stack.axis = .vertical
            stack.alignment = .fill
            stack.distribution = .fill
            stack.frame = view.bounds
            return stack
        }()
        
        view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        setupDataSource()
        applySnapshots()
    }
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshots()
        collectionView.reloadData()
    }
    
    //MARK: Setting up fetch requests and do fetching
    
    func setupFetchRequests() {
        let groupRequest: NSFetchRequest<Group> = Group.fetchRequest()
        let groupSortDescriptor = NSSortDescriptor(key: #keyPath(Group.order), ascending: true)
        groupRequest.sortDescriptors = [groupSortDescriptor]
        groupFetchRequest = groupRequest
        
        let ungroupedListsRequest: NSFetchRequest<List> = List.fetchRequest()
        ungroupedListsRequest.predicate = NSPredicate(format: "%K == nil", #keyPath(List.group))
        let ungroupedListsSortDescriptor = NSSortDescriptor(key: #keyPath(List.order), ascending: true)
        ungroupedListsRequest.sortDescriptors = [ungroupedListsSortDescriptor]
        ungroupedListsFetchRequest = ungroupedListsRequest
    }
    
    func performFetching() {
        guard let groupFetchRequest = groupFetchRequest, let ungroupedListsFetchRequest = ungroupedListsFetchRequest else { return }

        do {
            let groupResults = try coreDataStack.managedContext.fetch(groupFetchRequest)
            groups = groupResults
            let ungroupedResults = try coreDataStack.managedContext.fetch(ungroupedListsFetchRequest)
            ungroupedLists = ungroupedResults
        }catch let error as NSError {
            print("Unable to fetch \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Setting up subviews
    
    func setupCollectionView() {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        layoutConfig.headerMode = .none
        layoutConfig.backgroundColor = .systemBackground
        
        //handling swipe actions
        setupSwipeActions(for: &layoutConfig)
        
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        
    }
    
    //MARK: Setup swipe delete action for list rows
    func setupSwipeActions(for layoutConfig: inout UICollectionLayoutListConfiguration) {
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [unowned self] (indexPath) in
            
            let section = dataSource.sectionIdentifier(for: indexPath.section)
            let listItem = dataSource.itemIdentifier(for: indexPath)
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
    //MARK: Try to refactor! This code is not good!
                switch indexPath.section {
                    //If section is groupedLists
                    case 1:
                        //Get group item from section snapshot by searching for parent item of our listItem
                        let sectionSnapshot = self.dataSource.snapshot(for: .groupedLists)
                        let groupItem = sectionSnapshot.parent(of: listItem!)
                        switch (groupItem, listItem) {
                            case (.group(let group), .list(let list)):
                                //search for index of our list in group and delete it
                                group.removeFromLists(list)
                                self.coreDataStack.managedContext.delete(list)
                            default:
                                break
                        }
                    //If section is ungroupedLists - simply delete list from data base
                    case 2:
                        let list = self.ungroupedLists.remove(at: indexPath.row)
                        self.coreDataStack.managedContext.delete(list)
                    default:
                        break
                }
                self.coreDataStack.saveContext()
                self.applySnapshots()
            }
            
            //Apply delete action only if section is groupedLists, and list item is List
            switch (section, listItem) {
                case (.basicLists, _):
                    return nil
                case (.groupedLists, .group(_)):
                    return nil
                default:
                    return UISwipeActionsConfiguration(actions: [deleteAction])
            }
        }
    }
    
    func setupButtonsWith(title: String) -> UIButton {
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.imagePlacement = .top
        buttonConfiguration.image = UIImage(systemName: "plus")
        buttonConfiguration.title = title
        return UIButton(configuration: buttonConfiguration)
    }
    
    //MARK: Create collection view cell registration and data source
    
    func createBasicListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, BasicItem> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BasicItem> { (cell, indexPath, basicItem) in
            var content = cell.defaultContentConfiguration()
            content.text = basicItem.name
            
            switch basicItem {
                case .today:
                    content.image = UIImage(systemName: "sun.max")
                case .income:
                    content.image = UIImage(systemName: "envelope.open")
                case .important:
                    content.image = UIImage(systemName: "star")
                case .planned:
                    content.image = UIImage(systemName: "calendar")
            }
            cell.contentConfiguration = content
        }
        return cellRegistration
    }
    
    func createGroupCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Group> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Group> { (cell, indexPath, groupItem) in
            var content = cell.defaultContentConfiguration()
            content.text = groupItem.name
            content.image = UIImage(systemName: "folder")
            cell.contentConfiguration = content
            
            //Creating cell accessories
            
            //Options button
            var buttonConfiguration = UIButton.Configuration.borderless()
            buttonConfiguration.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
            let groupOptionsButton = UIButton(configuration: buttonConfiguration)
            groupOptionsButton.showsMenuAsPrimaryAction = true
            
            //Button menu actions
            let newGroupAction = UIAction(title: "Add new list to group", image: UIImage(systemName: "plus.square"), state: .off) { action in
                let list = List(context: self.coreDataStack.managedContext)
                list.group = groupItem
                list.name = "New list"
                self.coreDataStack.saveContext()
                self.applySnapshots()
            }
            
            let renameGroupAction = UIAction(title: "Rename Group", image: UIImage(systemName: "text.cursor")) { action in
                self.presentGroupAlert(isAddingGroup: false, currentGroup: groupItem, currentGroupCellIndexPath: indexPath)
            }
            
            let ungroupListsAction = UIAction(title: "Ungroup lists", image: UIImage(systemName: "folder.badge.minus")) { action in
                if let groupItemIndex = self.groups.firstIndex(of: groupItem) {
                    self.groups.remove(at: groupItemIndex)
                }
                self.coreDataStack.managedContext.delete(groupItem)
                
                if let groupLists = groupItem.lists?.array as? [List] {
                    for list in groupLists {
                        list.order = Int32(self.ungroupedLists.count)
                        self.ungroupedLists.append(list)
                    }
                }
                self.applySnapshots()
            }
            
            //Button menu
            groupOptionsButton.menu = UIMenu(children: [renameGroupAction, newGroupAction, ungroupListsAction])
            
            let customAccessoryConfig = UICellAccessory.CustomViewConfiguration(
                customView: groupOptionsButton,
                placement: .trailing(displayed: .always, at: { accessories in
                return 0
            })
            )
            
            //Disclosure accessory
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            
            //Adding accessories to cell
            cell.accessories = [.customView(configuration: customAccessoryConfig),.outlineDisclosure(options: disclosureOptions),]
        }
        
        return cellRegistration
    }
    
    func createListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, List> {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, List> { (cell, indexPath, listItem) in
            var content = cell.defaultContentConfiguration()
            content.text = listItem.name
            content.image = UIImage(systemName: "list.bullet")
            cell.contentConfiguration = content
            cell.contentConfiguration = content
        }
        return cellRegistraion
    }
    
    func setupDataSource() {
        let basicCellRegistration = createBasicListCellRegistration()
        let groupCellRegistration = createGroupCellRegistration()
        let listCellRegistration = createListCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, listItem in
            switch listItem {
                case .basic(let basicItem):
                    let cell = collectionView.dequeueConfiguredReusableCell(using: basicCellRegistration, for: indexPath, item: basicItem)
                    return cell
                case .group(let group):
                    let cell = collectionView.dequeueConfiguredReusableCell(using: groupCellRegistration, for: indexPath, item: group)
                    return cell
                case .list(let list):
                    let cell = collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: list)
                    return cell
            }
        })
        
        dataSource.sectionSnapshotHandlers.willCollapseItem = { groupItem in
            switch groupItem {
                case .group(let group):
                    group.isExpanded = false
                    self.coreDataStack.saveContext()
                default: break
            }
        }
        
        dataSource.sectionSnapshotHandlers.willExpandItem = { groupItem in
            switch groupItem {
                case .group(let group):
                    group.isExpanded = true
                    self.coreDataStack.saveContext()
                default: break
            }
        }
        
        //========================================РАЗОБРАТЬСЯ!!!!
        //Handle reordering items
        dataSource.reorderingHandlers.canReorderItem = {list in
            let itemIndexPath = self.dataSource.indexPath(for: list)!
            //Disable reordering for basic lists
            if itemIndexPath.section == 0 {
                return false
            }
            return true
        }
        
        dataSource.reorderingHandlers.didReorder = {[weak self] transaction in
            //guard let self = self else {return}
        }
         
    }
  
    func applySnapshots() {
        //Эти строки вызывают ошибки при наличии expand items
        //let sections = Section.allCases
        //var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ListItem>()
        //dataSourceSnapshot.appendSections(sections)
        //dataSource.apply(dataSourceSnapshot)
        
        //Basic section snapshot
        var basicListsSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        let basicListItems = BasicItem.allCases.map { ListItem.basic($0) }
        
        basicListsSectionSnapshot.append(basicListItems)
        dataSource.apply(basicListsSectionSnapshot, to: .basicLists)
        
        //Grouped section snapshot
        var userGroupsSectionSnaphot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        var groupItemsToExpand = [ListItem]()
        for groupItem in groups {
            let groupListItem = ListItem.group(groupItem)
            userGroupsSectionSnaphot.append([groupListItem])
            
            if groupItem.isExpanded {
                groupItemsToExpand.append(groupListItem)
            }
            if let listItems = groupItem.lists?.array.map({ ListItem.list($0 as! List) }) {
                userGroupsSectionSnaphot.append(listItems, to: groupListItem)
            }
        }
        userGroupsSectionSnaphot.expand(groupItemsToExpand)

        dataSource.apply(userGroupsSectionSnaphot, to: .groupedLists)
        
        //Ungrouped section snapshot
        var ungroupedListsSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        
        let ungroupedListItems = ungroupedLists.map { ListItem.list($0) }
        ungroupedListsSectionSnapshot.append(ungroupedListItems)
        
        dataSource.apply(ungroupedListsSectionSnapshot, to: .ungroupedLists)
    }
}

//MARK: CollectionView Delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = dataSource.itemIdentifier(for: indexPath)
        
        switch item {
            case .list(let list):
                self.navigationController?.pushViewController(ListDetailViewController(list: list, coreDataStack: coreDataStack), animated: true)
            default:
                return
        }
    }

    //========================================РАЗОБРАТЬСЯ!!!!

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        print("target")
        return proposedIndexPath
    }
    
}

//MARK: Button actions
extension HomeViewController {
    @objc func addTaskButtonTapped() {
        let taskBottomSheetController = AddTaskBottomSheetViewController()
        //taskBottomSheetController.delegate = self
        taskBottomSheetController.modalPresentationStyle = .overCurrentContext
        self.present(taskBottomSheetController, animated: false)
    }
    
    @objc func addListButtonTapped() {
        let newList = List(context: coreDataStack.managedContext)
        newList.name = "New List"
        newList.order = Int32(ungroupedLists.count)
        ungroupedLists.append(newList)
        coreDataStack.saveContext()
        self.navigationController?.pushViewController(ListDetailViewController(list: newList, coreDataStack: coreDataStack), animated: true)
    }
    
    @objc func addGroupButtonTapped() {
       presentGroupAlert(isAddingGroup: true)
    }
    
    func presentGroupAlert(isAddingGroup: Bool, currentGroup: Group? = nil, currentGroupCellIndexPath: IndexPath? = nil) {
        
        let title = isAddingGroup ? "New Group" : "Rename Group"
        let textFieldText =  currentGroup?.name ?? "New Group"
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = textFieldText
            textField.placeholder = "Group Name"
            textField.textAlignment = .left
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            let groupName = alert.textFields![0].text!.isEmpty ? "New Group" : alert.textFields![0].text!
            let group = Group(context: self.coreDataStack.managedContext)
            group.name = groupName
            group.order = Int32(self.groups.count)
            self.groups.append(group)
            self.coreDataStack.saveContext()
            self.applySnapshots()
        }
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
            guard let currentGroup = currentGroup,
                  let currentGroupCellIndexPath = currentGroupCellIndexPath,
                  let groupItem = self.dataSource.itemIdentifier(for: currentGroupCellIndexPath) else { return }

            let groupName = alert.textFields![0].text!
            currentGroup.name = groupName
            
            self.coreDataStack.saveContext()
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems([groupItem])
            self.dataSource.apply(snapshot)
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?[0], queue: OperationQueue.main) { _ in
            let textField = alert.textFields![0]
            createAction.isEnabled = !textField.text!.isEmpty
            renameAction.isEnabled = !textField.text!.isEmpty
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: alert.textFields?[0], queue: OperationQueue.main) { _ in
            let textField = alert.textFields![0]
            createAction.isEnabled = !textField.text!.isEmpty
            renameAction.isEnabled = !textField.text!.isEmpty
        }
        
        alert.addAction(cancelAction)
        alert.addAction(isAddingGroup ? createAction : renameAction)
        self.present(alert, animated: true)
    }
}

/*
extension HomeViewController: AddTaskBottomSheetDelegate {
    func saveTask(_ task: Task) {
        database.basicLists[1].uncompletedTasks.append(task)
        self.applySnapshots()
    }
    
    
}
 */


