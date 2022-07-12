//
//  HomeViewController.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 12.05.2022.
//



import UIKit


class HomeViewController: UIViewController {
    
    var database: Database!
    
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
        case group(Group)
        case list(List)
    }

    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //Configuring Navigation Bar
        self.navigationItem.title = "Todoosha"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        
        //Setting up database
        database = Database.loadData() ?? Database.loadSampleDatabase()
        
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
        collectionView.dragDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.dropDelegate = self
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
                                if let listIndex = group.subitems.firstIndex(of: list) {
                                    group.subitems.remove(at: listIndex)
                                }
                            default:
                                break
                        }
                    //If section is ungroupedLists - simply delete list from data base
                    case 2:
                        self.database.userUngroupedLists.remove(at: indexPath.row)
                    default:
                        break
                }
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
    
    func createGroupCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Group> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Group> { (cell, indexPath, groupItem) in
            
            var content = cell.defaultContentConfiguration()
            content.text = groupItem.title
            content.image = UIImage(systemName: "folder")
            cell.contentConfiguration = content
            
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
        }
        
        return cellRegistration
    }
    
    func createListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, List> {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, List> { (cell, indexPath, listItem) in
            var content = cell.defaultContentConfiguration()
            content.text = listItem.title
            
            if indexPath.section == 0 {
                switch indexPath.item {
                    case 0:
                        content.image = UIImage(systemName: "sun.max")
                    case 1:
                        content.image = UIImage(systemName: "envelope.open")
                    case 2:
                        content.image = UIImage(systemName: "star")
                    case 3:
                        content.image = UIImage(systemName: "calendar")
                    default:
                        break
                }
            } else {
                content.image = UIImage(systemName: "list.bullet")
            }
            cell.contentConfiguration = content
        }
        return cellRegistraion
    }
    
    func setupDataSource() {
        let groupCellRegistration = createGroupCellRegistration()
        let listCellRegistration = createListCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, listItem in
            switch listItem {
                case .group(let group):
                    let cell = collectionView.dequeueConfiguredReusableCell(using: groupCellRegistration, for: indexPath, item: group)
                    return cell
                case .list(let list):
                    let cell = collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: list)
                    return cell
            }
        })
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
            guard let self = self else {return}
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
        let basicListItems = database.basicLists.map { ListItem.list($0) }
        
        basicListsSectionSnapshot.append(basicListItems)
        dataSource.apply(basicListsSectionSnapshot, to: .basicLists)
        
        //Grouped section snapshot
        var userGroupsSectionSnaphot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        var groupItemsToExpand = [ListItem]()
        for groupItem in database.userGroups {
            let groupListItem = ListItem.group(groupItem)
            userGroupsSectionSnaphot.append([groupListItem])
            
            if groupItem.isExpanded {
                groupItemsToExpand.append(groupListItem)
            }
                
            let listItems = groupItem.subitems.map { ListItem.list($0) }
                
            userGroupsSectionSnaphot.append(listItems, to: groupListItem)
            }
        userGroupsSectionSnaphot.expand(groupItemsToExpand)

        dataSource.apply(userGroupsSectionSnaphot, to: .groupedLists)
        
        //Ungrouped section snapshot
        var ungroupedListsSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        
        let ungroupedListItems = database.userUngroupedLists.map { ListItem.list($0) }
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
                self.navigationController?.pushViewController(ListDetailViewController(list: list), animated: true)
            default:
                return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        
        switch item {
            case .group(let group):
                group.isExpanded.toggle()
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
        taskBottomSheetController.delegate = self
        taskBottomSheetController.modalPresentationStyle = .overCurrentContext
        self.present(taskBottomSheetController, animated: false)
    }
    
    @objc func addListButtonTapped() {
        let newList = List(title: "New list")
        database.userUngroupedLists.append(newList)
        self.navigationController?.pushViewController(ListDetailViewController(list: newList), animated: true)
    }
    
    @objc func addGroupButtonTapped() {
        let alert = UIAlertController(title: "New Group", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = "New Group"
            textField.placeholder = "Group Name"
            textField.textAlignment = .left
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            let groupTitle = alert.textFields![0].text!.isEmpty ? "New Group" : alert.textFields![0].text!
            self.database.addGroup(title: groupTitle)
            self.applySnapshots()
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?[0], queue: OperationQueue.main) { _ in
            let textField = alert.textFields![0]
            createAction.isEnabled = !textField.text!.isEmpty
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: alert.textFields?[0], queue: OperationQueue.main) { _ in
            let textField = alert.textFields![0]
            createAction.isEnabled = !textField.text!.isEmpty
        }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        self.present(alert, animated: true)
    }
}

extension HomeViewController: AddTaskBottomSheetDelegate {
    func saveTask(_ task: Task) {
        database.basicLists[1].uncompletedTasks.append(task)
        self.applySnapshots()
    }
    
    
}
//========================================РАЗОБРАТЬСЯ!!!!

extension HomeViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = dataSource.itemIdentifier(for:indexPath)
        return [dragItem]
    }
}

extension HomeViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }
}

