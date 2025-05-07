//
//  TaskDetailPresenter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import Foundation

protocol TaskDetailViewProtocol: AnyObject {
    func showTask(_ task: TaskItem)
}

protocol TaskDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapSave(title: String)
}

final class TaskDetailPresenter: TaskDetailPresenterProtocol {
    weak var view: TaskDetailViewProtocol?
    var interactor: TaskDetailInteractorProtocol?
    var router: TaskDetailRouterProtocol?

    private var task: TaskItem?

    init(task: TaskItem?) {
        self.task = task
    }

    func viewDidLoad() {
        if let task = task {
            view?.showTask(task)
        }
    }

    func didTapSave(title: String) {
        let item = TaskItem(
            id: task?.id ?? UUID(),
            title: title,
            isCompleted: task?.isCompleted ?? false,
            createdAt: task?.createdAt ?? Date()
        )
        interactor?.saveTask(item)
        router?.goBack()
    }
}
