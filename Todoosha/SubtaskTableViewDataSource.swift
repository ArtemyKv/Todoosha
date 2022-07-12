//
//  SubtaskTableViewDataSource.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 25.05.2022.
//

import Foundation
import UIKit

protocol SubtaskTableViewDataSourceDelegate {
    
}

class SubtaskTableViewDataSource : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var cellDelegate: SubtaskTableViewCellDelegate!
    
    var items: [Subtask]
    
    init(items: [Subtask]) {
        self.items = items
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubtaskTableViewCell.identifier, for: indexPath) as! SubtaskTableViewCell
        let subtask = items[indexPath.row]
        cell.update(with: subtask)
        cell.delegate = cellDelegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let subtask = items.remove(at: sourceIndexPath.row)
        items.insert(subtask, at: destinationIndexPath.row)
    }
}

extension SubtaskTableViewDataSource: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = items[indexPath.row]
        return [dragItem]
    }
}
