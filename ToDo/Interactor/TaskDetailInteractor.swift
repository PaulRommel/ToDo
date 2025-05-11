//
//  TaskDetailInteractor.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit
import CoreData

protocol TaskDetailInteractorInputProtocol: AnyObject {
    //var presenter: TaskDetailInteractorOutputProtocol? { get set }
    var presenter: (any TaskDetailInteractorOutputProtocol)? { get set }
}

protocol TaskDetailInteractorOutputProtocol: AnyObject {
    // Можно добавить методы, если интерактор должен что-то сообщать презентеру
}

class TaskDetailInteractor: TaskDetailInteractorInputProtocol {
    //weak var presenter: TaskDetailInteractorOutputProtocol?
    weak var presenter: (any TaskDetailInteractorOutputProtocol)?
}
