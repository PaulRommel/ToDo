//
//  TaskDetailModuleBuilder.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

enum TaskDetailModuleBuilder {
    static func build(with task: TaskItem?) -> UIViewController {
        let view = TaskDetailViewController()
        let presenter = TaskDetailPresenter(task: task)
        let interactor = TaskDetailInteractor()
        let router = TaskDetailRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.listInteractor = TaskListModuleBuilder.sharedInteractor
        router.viewController = view

        return view
    }
}
