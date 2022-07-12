//
//  Group.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 12.05.2022.
//

import Foundation

final class Group {
    var title: String
    var subitems: [List]
    var id: UUID
    
    var isExpanded: Bool
    
    init(title: String, subitems: [List] = []) {
        self.title = title
        self.subitems = subitems
        self.id = UUID()
        self.isExpanded = true
    }
}

extension Group: Equatable {
    static func ==(lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
    }
}

extension Group: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
extension Group: Codable { }
