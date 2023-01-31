//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 29.09.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchData()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(task: nil, completion: nil)
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData { [unowned self] result in
            switch result {
            case .success(let tasks):
                self.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    private func save(_ taskName: String) {
        StorageManager.shared.save(taskName) { [unowned self] task in
            taskList.append(task)
            tableView.insertRows(
                at: [IndexPath(row: self.taskList.count - 1, section: 0)],
                with: .automatic
            )
        }
    }
}
//MARK: - UITableViewDelegate, UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              let task = taskList[indexPath.row]
              taskList.remove(at: indexPath.row)
              tableView.deleteRows(at: [indexPath], with: .automatic)
              StorageManager.shared.remove(task: task)
          }
      }
}
//MARK: - AlertController
extension TaskListViewController {
    private func showAlert(task: Task?, completion: (() -> Void)? = nil) {
        let title = task == nil ? "Add new task" : "Update task"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let task = task, let completion = completion {
                StorageManager.shared.update(task: task, taskName: alert.textFields?.first?.text ?? "")
                completion()
            } else {
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self?.save(task)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = task == nil ? "New Task" : ""
            textField.text = task == nil ? "" : task?.name
        }
        present(alert, animated: true)
    }
}
