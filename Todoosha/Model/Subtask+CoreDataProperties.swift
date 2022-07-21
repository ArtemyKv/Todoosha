//
//  Subtask+CoreDataProperties.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 13.07.2022.
//
//

import Foundation
import CoreData


extension Subtask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subtask> {
        return NSFetchRequest<Subtask>(entityName: "Subtask")
    }

    @NSManaged public var isComplete: Bool
    @NSManaged public var name: String?
    @NSManaged public var task: Task?

}

extension Subtask : Identifiable {

}
