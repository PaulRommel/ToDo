//
//  TaskListInteractor.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit
import CoreData

protocol TaskListInteractorInputProtocol: AnyObject {
    var presenter: TaskListInteractorOutputProtocol? { get set }
    
    func fetchTasks()
    func loadTasksFromAPI()
    func createTask(title: String, description: String)
    func updateTask(_ task: Task, newTitle: String, newDescription: String)
    func deleteTask(_ task: Task)
    func toggleTaskCompletion(_ task: Task)
    func searchTasks(with text: String)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didRetrieveTasks(_ tasks: [Task])
    func didCreateTask(_ task: Task)
    func didUpdateTask(_ task: Task)
    func didDeleteTask(_ task: Task)
    func didToggleTaskCompletion(_ task: Task)
    func didSearchTasks(_ tasks: [Task])
    func onError(message: String)
}

class TaskListInteractor: TaskListInteractorInputProtocol {
    
#if DEBUG
    func setContextForTesting(_ context: NSManagedObjectContext) {
        self.context = context
    }
#endif
    
    weak var presenter: TaskListInteractorOutputProtocol?
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let apiUrl = "https://dummyjson.com/todos"
    private let hasLoadedKey = "hasLoadedFromAPI"
    
    func fetchTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let tasks = try context.fetch(request)
            presenter?.didRetrieveTasks(tasks)
        } catch {
            presenter?.onError(message: "Failed to fetch tasks: \(error.localizedDescription)")
        }
    }
    
    func loadTasksFromAPI() {
        guard let url = URL(string: apiUrl) else {
            presenter?.onError(message: "Invalid API URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.presenter?.onError(message: "Failed to load tasks: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.presenter?.onError(message: "No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(TodoAPIResponse.self, from: data)
                self.saveTasksFromAPI(apiResponse.todos)
                UserDefaults.standard.set(true, forKey: self.hasLoadedKey)
                self.fetchTasks()
            } catch {
                self.presenter?.onError(message: "Failed to decode response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func saveTasksFromAPI(_ todos: [TodoItem]) {
        context.perform {
            for todo in todos {
                let newTask = Task(context: self.context)
                newTask.title = todo.todo
                newTask.taskDescription = "Imported from API"
                newTask.createdAt = Date()
                newTask.isCompleted = todo.completed
                newTask.completedAt = todo.completed ? Date() : nil
            }
            
            do {
                try self.context.save()
            } catch {
                self.presenter?.onError(message: "Failed to save tasks: \(error.localizedDescription)")
            }
        }
    }
    
    func createTask(title: String, description: String) {
        let newTask = Task(context: context)
        newTask.title = title
        newTask.taskDescription = description
        newTask.createdAt = Date()
        newTask.isCompleted = false
        
        do {
            try context.save()
            presenter?.didCreateTask(newTask)
        } catch {
            presenter?.onError(message: "Failed to create task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: Task, newTitle: String, newDescription: String) {
        task.title = newTitle
        task.taskDescription = newDescription
        
        do {
            try context.save()
            presenter?.didUpdateTask(task)
        } catch {
            presenter?.onError(message: "Failed to update task: \(error.localizedDescription)")
        }
    }
    
    func deleteTask(_ task: Task) {
        context.delete(task)
        
        do {
            try context.save()
            presenter?.didDeleteTask(task)
        } catch {
            presenter?.onError(message: "Failed to delete task: \(error.localizedDescription)")
        }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        task.isCompleted = !task.isCompleted
        task.completedAt = task.isCompleted ? Date() : nil
        
        do {
            try context.save()
            presenter?.didToggleTaskCompletion(task)
        } catch {
            presenter?.onError(message: "Failed to update task status: \(error.localizedDescription)")
        }
    }
    
    func searchTasks(with text: String) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        if !text.isEmpty {
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
            let descriptionPredicate = NSPredicate(format: "taskDescription CONTAINS[cd] %@", text)
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, descriptionPredicate])
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let tasks = try context.fetch(request)
            presenter?.didSearchTasks(tasks)
        } catch {
            presenter?.onError(message: "Failed to search tasks: \(error.localizedDescription)")
        }
    }
}
