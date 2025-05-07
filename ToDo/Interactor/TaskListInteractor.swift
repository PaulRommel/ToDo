//
//  TaskListInteractor.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import Foundation

protocol TaskListInteractorProtocol: AnyObject {
    func loadTasks()
    func toggleTaskCompleted(_ id: UUID)
    func deleteTask(_ id: UUID)
    func saveTask(_ task: TaskItem)
    func searchTasks(with text: String)
}

protocol TaskListInteractorOutput: AnyObject {
    func didLoadTasks(_ tasks: [TaskItem])
}

final class TaskListInteractor: TaskListInteractorProtocol {
    weak var output: TaskListInteractorOutput?

    private var allTasks: [TaskItem] = []

    private let storageKey = "task_items"

    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            allTasks = decoded
        }
        output?.didLoadTasks(allTasks)
    }

    func toggleTaskCompleted(_ id: UUID) {
        guard let index = allTasks.firstIndex(where: { $0.id == id }) else { return }
        allTasks[index].isCompleted.toggle()
        persist()
        output?.didLoadTasks(allTasks)
    }

    func deleteTask(_ id: UUID) {
        allTasks.removeAll { $0.id == id }
        persist()
        output?.didLoadTasks(allTasks)
    }

    func saveTask(_ task: TaskItem) {
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[index] = task
        } else {
            allTasks.append(task)
        }
        persist()
        output?.didLoadTasks(allTasks)
    }

    func searchTasks(with text: String) {
        if text.isEmpty {
            output?.didLoadTasks(allTasks)
        } else {
            let filtered = allTasks.filter { $0.title.localizedCaseInsensitiveContains(text) }
            output?.didLoadTasks(filtered)
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(allTasks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

