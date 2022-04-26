//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try! Realm()

    private init() {}

    // MARK: - Task List

    func save(object: Object...) {
        write {
            realm.add(object)
        }
    }

    func delete(object: Object) {
        if let taskList = object as? TaskList {
            write {
                realm.delete(taskList.tasks)
                realm.delete(taskList)
            }
        } else {
            write {
                realm.delete(object)
            }
        }
    }

    func edit(object: Object, newName: String, newNote: String? = nil) {
        write {
            object.setValue(newName, forKey: "name")
            if let newNote = newNote {
                object.setValue(newNote, forKey: "note")
            }
        }
    }

    func done(object: Object) {
        if let taskList = object as? TaskList {
            write {
                taskList.tasks.setValue(true, forKey: "isComplete")
            }
        } else if let task = object as? Task {
            write {
                task.isComplete.toggle()
            }
        }
    }

    // MARK: - Tasks

    func save(_ task: Task, to taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }

    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
