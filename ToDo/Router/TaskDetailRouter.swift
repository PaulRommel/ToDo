//
//  TaskDetailRouter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

protocol TaskDetailRouterProtocol: AnyObject {
    func goBack()
}

final class TaskDetailRouter: TaskDetailRouterProtocol {
    weak var viewController: UIViewController?

    func goBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
