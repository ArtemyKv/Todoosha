//
//  List.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 12.05.2022.
//

import Foundation


final class List {
    var id: UUID
    var title: String
    var uncompletedTasks: [Task] = []
    var completedTasks: [Task] = []
    var groupID: UUID?
    
    init(title: String) {
        self.title = title
        self.id = UUID()
    }
    
    
}

extension List: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
extension List: Codable { }

extension List: Equatable {
    
    static func ==(lhs: List, rhs: List) -> Bool {
        lhs.id == rhs.id
    }
}

