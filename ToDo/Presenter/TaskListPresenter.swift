//
//  TaskListPresenter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import Foundation

protocol TaskListViewProtocol: AnyObject {
    func displayTasks(_ tasks: [TaskItem])
}

protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didToggleTask(_ id: UUID)
    func didDeleteTask(_ id: UUID)
    func didSearch(text: String)
    func didTapAddTask()
    func didSelectTask(_ task: TaskItem)
}

final class TaskListPresenter {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorProtocol?
    var router: TaskListRouterProtocol?
}

extension TaskListPresenter: TaskListPresenterProtocol {
    func viewDidLoad() {
        interactor?.loadTasks()
    }

    func didToggleTask(_ id: UUID) {
        interactor?.toggleTaskCompleted(id)
    }

    func didDeleteTask(_ id: UUID) {
        interactor?.deleteTask(id)
    }

    func didSearch(text: String) {
        interactor?.searchTasks(with: text)
    }

    func didTapAddTask() {
        router?.showTaskDetail(for: nil)
    }

    func didSelectTask(_ task: TaskItem) {
        router?.showTaskDetail(for: task)
    }
}

extension TaskListPresenter: TaskListInteractorOutput {
    func didLoadTasks(_ tasks: [TaskItem]) {
        view?.displayTasks(tasks)
    }
}
