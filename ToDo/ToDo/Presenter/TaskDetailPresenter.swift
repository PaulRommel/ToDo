//
//  TaskDetailPresenter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

protocol TaskDetailViewProtocol: AnyObject {
    func showTaskDetail(_ task: Task)
}

protocol TaskDetailPresenterProtocol: AnyObject {
//    var view: TaskDetailViewProtocol? { get set }
//    var interactor: TaskDetailInteractorInputProtocol? { get set }
//    var router: TaskDetailRouterProtocol? { get set }
    var view: (any TaskDetailViewProtocol)? { get set }
    var interactor: (any TaskDetailInteractorInputProtocol)? { get set }
    var router: (any TaskDetailRouterProtocol)? { get set }
    
    var task: Task? { get set }
    
    func viewDidLoad()
}

class TaskDetailPresenter: TaskDetailPresenterProtocol, TaskDetailInteractorOutputProtocol {
//    weak var view: TaskDetailViewProtocol?
//    var interactor: TaskDetailInteractorInputProtocol?
//    var router: TaskDetailRouterProtocol?
    weak var view: (any TaskDetailViewProtocol)?
    var interactor: (any TaskDetailInteractorInputProtocol)? {
            didSet {
                interactor?.presenter = self
            }
        }
    weak var router: (any TaskDetailRouterProtocol)?
    
    var task: Task?
    
    func viewDidLoad() {
        guard let task = task else { return }
        view?.showTaskDetail(task)
    }
}
