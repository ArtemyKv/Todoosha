//
//  DataBase.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 14.05.2022.
//

import Foundation

struct Database: Codable {
    
    
    init(userGroups: [Group], userUngroupedLists: [List]) {
        self.userGroups = userGroups
        self.userUngroupedLists = userUngroupedLists
    }
    
    var basicLists: [List] = [
        List(title: "Today"),
        List(title: "Income"),
        List(title: "Important"),
        List(title: "Planned")
    ]
    
    var userGroups: [Group] = []
    var userUngroupedLists: [List] = []
    
    
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let databaseArchiveURL = documentsDirectory.appendingPathComponent("database").appendingPathExtension("plist")

    
    static func loadData() -> Database? {
        guard let codedDatabae = try? Data(contentsOf: databaseArchiveURL) else { return nil }
        let plistDecoder = PropertyListDecoder()
        return try? plistDecoder.decode(Database.self, from: codedDatabae)
        
    }
    
    static func saveDatabase(database: Database) {
        let plistEncoder = PropertyListEncoder()
        let data = try? plistEncoder.encode(database)
        try? data?.write(to: databaseArchiveURL, options: .noFileProtection)
    }
    
    mutating func addGroup(title: String) {
        userGroups.append(Group(title: title))
    }
    
    static func loadSampleDatabase() -> Database {
        let sampleUserGroups: [Group] = [
            Group(title: "FirstOne", subitems: [
                List(title: "One"),
                List(title: "Two"),
                List(title: "Three")
            ]),
            Group(title: "SecondOne", subitems: [
                List(title: "One"),
                List(title: "Two"),
                List(title: "Three"),
            ]),
            Group(title: "ThirdOne", subitems: [
                List(title: "One"),
                List(title: "Two"),
                List(title: "Three"),
            ])
        ]
        
        let sampleUngroupedLists = [
            List(title: "ListOne")
        ]
        
        sampleUngroupedLists[0].uncompletedTasks = [Task(name: "FirstOne")]
        
        let database = Database(userGroups: sampleUserGroups, userUngroupedLists: sampleUngroupedLists)
        return database
    }
}

