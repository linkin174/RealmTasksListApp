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

    func save<T>(_ input: T) {
        if let task = input as? Task {
            write {
                realm.add(task)
            }
        } else if let taskList = input as? TaskList {
            write {
                realm.add(taskList)
            }
        }
    }

    func delete<T>(_ input: T) {
        if let task = input as? Task {
            write {
                realm.delete(task)
            }
        } else if let taskList = input as? TaskList {
            write {
                realm.delete(taskList.tasks)
                realm.delete(taskList)
            }
        }
    }

    func edit<T>(_ input: T, newName: String, newNote: String = "") {
        if let task = input as? Task {
            write {
                task.name = newName
                task.note = newNote
            }
        } else if let taskList = input as? TaskList {
            write {
                taskList.name = newName
            }
        }
    }

    func done<T>(_ input: T) {
        if let task = input as? Task {
            write {
                task.setValue(true, forKey: "isComplete")
            }
        } else if let taskList = input as? TaskList {
            write {
                taskList.tasks.setValue(true, forKey: "isComplete")
            }
        }
    }

    func restoreTask(_ task: Task) {
        write {
            task.setValue(false, forKey: "isComplete")
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
