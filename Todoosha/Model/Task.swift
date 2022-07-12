//
//  Task.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 12.05.2022.
//

import Foundation


final class Task {
    var name: String
    var id: UUID
    
    var dueDate: Date?
    var remindDate: Date?
    var subtasks: [Subtask] = []
    var notes: String?
    
    var listID: UUID?
    
    var isImportant: Bool = false
    var isComplete: Bool = false
    var myDay: Bool = false
    
    var creationDate: Date
    
    init(name: String) {
        self.name = name
        self.id = UUID()
        self.creationDate = Date()
    }
    
}

extension Task: Equatable {
    static func ==(lhs:Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
}

extension Task: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
extension Task: Codable { }


/*
 struct Task {
     var name: String
     var id: UUID
     
     var dueDate: Date?
     var remindDate: Date?
     var subtasks: [Subtask] = []
     var notes: String?
     
     var listID: UUID?
     
     var isImportant: Bool = false
     var isComplete: Bool = false
     var myDay: Bool = false
     
     var creationDate: Date
     
     init(name: String) {
         self.name = name
         self.id = UUID()
         self.creationDate = Date()
     }
     
 }

 extension Task: Equatable {
     static func ==(lhs:Task, rhs: Task) -> Bool {
         lhs.id == rhs.id
     }
 }

 extension Task: Hashable { }
 extension Task: Codable { }
 */
