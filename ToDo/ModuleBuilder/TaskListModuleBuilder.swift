//
//  TaskListModuleBuilder.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

enum TaskListModuleBuilder {
    static var sharedInteractor: TaskListInteractorProtocol?

    static func build() -> UIViewController {
        let view = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter
        router.viewController = view

        sharedInteractor = interactor

        return view
    }
}
