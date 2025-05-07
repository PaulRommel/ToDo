//
//  TaskDetailInteractor.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import Foundation

protocol TaskDetailInteractorProtocol: AnyObject {
    func saveTask(_ task: TaskItem)
}

final class TaskDetailInteractor: TaskDetailInteractorProtocol {
    weak var listInteractor: TaskListInteractorProtocol?

    func saveTask(_ task: TaskItem) {
        listInteractor?.saveTask(task)
    }
}
