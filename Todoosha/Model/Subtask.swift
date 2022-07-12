//
//  Subtask.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 24.05.2022.
//

import Foundation

struct Subtask {
    var name: String
    
    var isComplete: Bool = false
}

extension Subtask: Hashable { }
extension Subtask: Codable { }
