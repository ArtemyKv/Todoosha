//
//  SubtaskTableViewDataSource.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 25.05.2022.
//

import Foundation
import UIKit

protocol SubtaskTableViewDataSourceDelegate: AnyObject {
    func reorderingFinished()
}

class SubtaskTableViewDataSource : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var cellDelegate: SubtaskTableViewCellDelegate?
    weak var delegate: SubtaskTableViewDataSourceDelegate?
    
    var subtasks: NSOrderedSet?
    
    init(subtasks: NSOrderedSet?) {
        self.subtasks = subtasks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subtasks?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubtaskTableViewCell.identifier, for: indexPath) as! SubtaskTableViewCell
        let subtask = subtasks![indexPath.row] as! Subtask
        cell.update(with: subtask)
        cell.delegate = cellDelegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let subtasks = subtasks,
              let replacedSubtask = subtasks[sourceIndexPath.row] as? Subtask,
              let parentTask = replacedSubtask.task else { return }
        parentTask.removeFromSubtasks(at: sourceIndexPath.row)
        parentTask.insertIntoSubtasks(replacedSubtask, at: destinationIndexPath.row)
        delegate?.reorderingFinished()
    }
}

extension SubtaskTableViewDataSource: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let subtasks = subtasks else { return [] }
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = subtasks[indexPath.row]
        return [dragItem]
    }
}
