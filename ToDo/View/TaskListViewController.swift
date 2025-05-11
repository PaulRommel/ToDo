//
//  TaskListViewController.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

class TaskListViewController: UIViewController, TaskListViewProtocol {
    var presenter: TaskListPresenterProtocol?
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search tasks..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = 80
        table.tableFooterView = UIView()
        return table
    }()
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    private func setupUI() {
        title = "To Do List"
        view.backgroundColor = .white
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexibleSpace, addButton]
        navigationController?.setToolbarHidden(false, animated: false)
        
        if let toolbar = navigationController?.toolbar {
            let exactColor = UIColor(named: "AccentColor") ?? UIColor.darkGray
            toolbar.barTintColor = exactColor
            toolbar.tintColor = .yellow
            toolbar.isTranslucent = false
        }
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func didTapAdd() {
        presenter?.didTapAddButton()
    }
    
    @objc private func refreshData() {
        presenter?.refreshData()
    }
    
    // MARK: - TaskListViewProtocol Implementation
    
    func showTasks(_ tasks: [Task]) {
        tableView.reloadData()
    }
    
    func showFilteredTasks(_ tasks: [Task]) {
        tableView.reloadData()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func showAddTaskDialog() {
        // Реализация перенесена в презентер
    }
    
    func showEditDialog(for task: Task) {
        // Реализация перенесена в презентер
    }
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfTasks ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell,
              let task = presenter?.task(at: indexPath) else {
            return UITableViewCell()
        }
        
        cell.configure(with: task)
        cell.completionHandler = { [weak self] in
            self?.presenter?.toggleTaskCompletion(for: task)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectTask(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let task = presenter?.task(at: indexPath) else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                self.presenter?.showEditDialog(for: task)
            }
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter?.deleteTask(task)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            presenter?.didCancelSearch()
        } else {
            presenter?.didSearchTasks(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter?.didCancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
