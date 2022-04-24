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

    func saveList(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }

    func save(object: Object) {
        write {
            realm.add(object)
        }
    }

    func delete(object: Object) {
        if let task = object as? Task {
            write {
                realm.delete(task)
            }
        } else if let taskList = object as? TaskList {
            write {
                realm.delete(taskList.tasks)
                realm.delete(taskList)
            }
        }
    }

    func edit(object: Object, newName: String, newNote: String = "") {
        if let task = object as? Task {
            write {
                task.name = newName
                task.note = newNote
            }
        } else if let taskList = object as? TaskList {
            write {
                taskList.name = newName
            }
        }
    }

    func done(object: Object) {
        if let task = object as? Task {
            write {
                task.setValue(true, forKey: "isComplete")
            }
        } else if let taskList = object as? TaskList {
            write {
                taskList.tasks.setValue(true, forKey: "isComplete")
            }
        }
    }

    

    // MARK: - Tasks

    func save(_ task: Task, to taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func restore(task: Task) {
        write {
            task.setValue(false, forKey: "isComplete")
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
