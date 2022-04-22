//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import RealmSwift
import UIKit

class TasksViewController: UITableViewController {
    var taskList: TaskList!
    
    private var currentTasks: Results<Task>!

    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        
        getTasksLists()
    }

    
    private func getTasksLists() {
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = section == 0 ? currentTasks.count : completedTasks.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .normal, title: "Complete") { _, _, _ in
            let task = self.currentTasks[indexPath.row]
            let indexPathNew = IndexPath(row: self.completedTasks.count, section: 1)
            StorageManager.shared.doneTask(task)
            tableView.moveRow(at: indexPath, to: indexPathNew)
            
        }
        complete.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        let restore = UIContextualAction(style: .normal, title: "Restore") { _, _, _ in
            let task = self.completedTasks[indexPath.row]
            let indexPathNew = IndexPath(row: self.currentTasks.count, section: 0)
            StorageManager.shared.restoreTask(task)
            tableView.moveRow(at: indexPath, to: indexPathNew)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            let task: Task!
            if indexPath.section == 0 {
                task = self.currentTasks[indexPath.row]
            } else {
                task = self.completedTasks[indexPath.row]
            }
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        }
        edit.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            var task: Task!
            if indexPath.section == 0 {
                task = self.currentTasks[indexPath.row]
            } else {
                task = self.completedTasks[indexPath.row]
            }
            StorageManager.shared.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        var actions: [UIContextualAction] = []
        if indexPath.section == 0 {
            actions = [complete, edit, delete]
        } else {
            actions = [restore, edit, delete]
        }
        let actionConfig = UISwipeActionsConfiguration(actions: actions)
        return actionConfig
    }
}

extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                // TODO: - edit task
                self.editTask(task: task, newName: newValue)
                completion()
            } else {
                self.saveTask(withName: newValue, andNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        StorageManager.shared.save(task, to: taskList)
        let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
    
    private func editTask(task: Task, newName: String) {
        StorageManager.shared.edit(task, newTitle: newName)
        let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
        tableView.reloadRows(at: [rowIndex], with: .automatic)
    }
}
