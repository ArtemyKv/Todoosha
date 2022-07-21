//
//  Task+CoreDataClass.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 13.07.2022.
//
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    
    var wrappedName: String {
        name ?? "New Task"
    }
}
