//
//  Subtask+CoreDataClass.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 13.07.2022.
//
//

import Foundation
import CoreData

@objc(Subtask)
public class Subtask: NSManagedObject {
    
    var wrappedName: String {
        name ?? "New Subtask"
    }
}
