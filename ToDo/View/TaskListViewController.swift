//
//  TaskListViewController.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

final class TaskListViewController: UIViewController {
    var presenter: TaskListPresenterProtocol!

    private var tasks: [TaskItem] = []

    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDo"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupSearch()
        setupNavigationBar()
        presenter.viewDidLoad()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search tasks"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAdd))
    }

    @objc private func didTapAdd() {
        presenter.didTapAddTask()
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func displayTasks(_ tasks: [TaskItem]) {
        self.tasks = tasks.sorted(by: { $0.createdAt > $1.createdAt })
        tableView.reloadData()
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = task.title
        config.secondaryText = task.isCompleted ? "✓ Completed" : nil
        cell.contentConfiguration = config
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        presenter.didToggleTask(task.id)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Swipe to delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            let task = self.tasks[indexPath.row]
            self.presenter.didDeleteTask(task.id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    // Tap to edit
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { _, _, completion in
            let task = self.tasks[indexPath.row]
            self.presenter.didSelectTask(task)
            completion(true)
        }
        edit.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [edit])
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter.didSearch(text: searchController.searchBar.text ?? "")
    }
}
