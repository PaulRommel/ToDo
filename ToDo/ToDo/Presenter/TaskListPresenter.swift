//
//  TaskListPresenter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit
import CoreData

protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [Task])
    func showFilteredTasks(_ tasks: [Task])
    func showError(message: String)
    func endRefreshing()
    func showAddTaskDialog()
    func showEditDialog(for task: Task)
}

protocol TaskListPresenterProtocol: AnyObject {
    var view: (any TaskListViewProtocol)? { get set }
    var interactor: (any TaskListInteractorInputProtocol)? { get set }
    var router: (any TaskListRouterProtocol)? { get set }
    
    var numberOfTasks: Int { get }
    func task(at indexPath: IndexPath) -> Task?
    
    func viewDidLoad()
    func refreshData()
    func didTapAddButton()
    func didSelectTask(at indexPath: IndexPath)
    func toggleTaskCompletion(for task: Task)
    func didSearchTasks(with text: String)
    func didCancelSearch()
    func showEditDialog(for task: Task)
    func deleteTask(_ task: Task)
}

class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: (any TaskListViewProtocol)?
    var interactor: (any TaskListInteractorInputProtocol)?
    var router: (any TaskListRouterProtocol)?
    
    private var allTasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var isSearching = false
    
    var numberOfTasks: Int {
        isSearching ? filteredTasks.count : allTasks.count
    }
    
    func task(at indexPath: IndexPath) -> Task? {
        let tasks = isSearching ? filteredTasks : allTasks
        guard indexPath.row < tasks.count else { return nil }
        return tasks[indexPath.row]
    }
    
    func viewDidLoad() {
        if !UserDefaults.standard.bool(forKey: "hasLoadedFromAPI") {
            interactor?.loadTasksFromAPI()
        } else {
            interactor?.fetchTasks()
        }
    }
    
    func refreshData() {
        interactor?.fetchTasks()
    }
    
    func didTapAddButton() {
        let alert = UIAlertController(title: "New Task",
                                    message: "Enter task details",
                                    preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Description (optional)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else {
                self?.view?.showError(message: "Title cannot be empty")
                return
            }
            let description = alert.textFields?[1].text ?? ""
            self?.interactor?.createTask(title: title, description: description)
        })
        
        (view as? UIViewController)?.present(alert, animated: true)
    }
    
    func didSelectTask(at indexPath: IndexPath) {
        guard let task = task(at: indexPath) else { return }
        router?.presentTaskDetail(from: view, for: task)
    }
    
    func toggleTaskCompletion(for task: Task) {
        interactor?.toggleTaskCompletion(task)
    }
    
    func didSearchTasks(with text: String) {
        isSearching = true
        interactor?.searchTasks(with: text)
    }
    
    func didCancelSearch() {
        isSearching = false
        view?.showTasks(allTasks)
    }
    
    func showEditDialog(for task: Task) {
        let alert = UIAlertController(title: "Edit Task",
                                    message: nil,
                                    preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = task.title
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.text = task.taskDescription
            textField.placeholder = "Description"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else {
                self?.view?.showError(message: "Title cannot be empty")
                return
            }
            let newDescription = alert.textFields?[1].text ?? ""
            self?.interactor?.updateTask(task, newTitle: newTitle, newDescription: newDescription)
        })
        
        (view as? UIViewController)?.present(alert, animated: true)
    }
    
    func shareTask(_ task: Task) {
        let text = "Задача: \(task.title ?? "")\nОписание: \(task.taskDescription ?? "")"
        router?.shareText(text, from: view)
    }
    
    func deleteTask(_ task: Task) {
        interactor?.deleteTask(task)
    }
}

extension TaskListPresenter: TaskListInteractorOutputProtocol {
    func didRetrieveTasks(_ tasks: [Task]) {
        allTasks = tasks
        view?.showTasks(tasks)
        view?.endRefreshing()
    }
    
    func didCreateTask(_ task: Task) {
        interactor?.fetchTasks()
    }
    
    func didUpdateTask(_ task: Task) {
        interactor?.fetchTasks()
    }
    
    func didDeleteTask(_ task: Task) {
        interactor?.fetchTasks()
    }
    
    func didToggleTaskCompletion(_ task: Task) {
        interactor?.fetchTasks()
    }
    
    func didSearchTasks(_ tasks: [Task]) {
        filteredTasks = tasks
        view?.showFilteredTasks(tasks)
    }
    
    func onError(message: String) {
        view?.showError(message: message)
        view?.endRefreshing()
    }
}
