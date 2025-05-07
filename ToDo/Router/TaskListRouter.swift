//
//  TaskListRouter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

protocol TaskListRouterProtocol: AnyObject {
    func showTaskDetail(for task: TaskItem?)
}

final class TaskListRouter: TaskListRouterProtocol {
    weak var viewController: UIViewController?

    func showTaskDetail(for task: TaskItem?) {
        let detailVC = TaskDetailModuleBuilder.build(with: task)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
