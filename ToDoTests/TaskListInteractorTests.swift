//
//  TaskListInteractorTests.swift
//  ToDoUITests
//
//  Created by Pavel Popov on 11.05.2025.
//

import XCTest
@testable import ToDo
import CoreData

class TaskListInteractorTests: XCTestCase {
    
    var interactor: TaskListInteractor!
    var mockPresenter: MockTaskListInteractorOutput!
    var mockContext: NSManagedObjectContext!
    
    override func setUp() {
            super.setUp()
            
            // Создаем in-memory CoreData stack для тестов
            let persistentStoreDescription = NSPersistentStoreDescription()
            persistentStoreDescription.type = NSInMemoryStoreType
            
            let container = NSPersistentContainer(name: "ToDo")
            container.persistentStoreDescriptions = [persistentStoreDescription]
            container.loadPersistentStores { (description, error) in
                if let error = error {
                    fatalError("Failed to load in-memory store: \(error)")
                }
            }
            
            mockContext = container.viewContext
            interactor = TaskListInteractor()
            //interactor.context = mockContext // Добавляем доступ к context
            interactor.setContextForTesting(mockContext)
            mockPresenter = MockTaskListInteractorOutput()
            interactor.presenter = mockPresenter
        }
    
    override func tearDown() {
        interactor = nil
        mockPresenter = nil
        mockContext = nil
        super.tearDown()
    }
    
    func testFetchTasks() {
        // Given
        let task = Task(context: mockContext)
        task.title = "Test Task"
        task.taskDescription = "Test Description"
        task.createdAt = Date()
        task.isCompleted = false
        
        try! mockContext.save()
        
        // When
        interactor.fetchTasks()
        
        // Then
        XCTAssertTrue(mockPresenter.didRetrieveTasksCalled)
        XCTAssertEqual(mockPresenter.retrievedTasks?.count, 1)
        XCTAssertEqual(mockPresenter.retrievedTasks?.first?.title, "Test Task")
    }
    
    func testCreateTask() {
        // When
        interactor.createTask(title: "New Task", description: "New Description")
        
        // Then
        XCTAssertTrue(mockPresenter.didCreateTaskCalled)
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let tasks = try! mockContext.fetch(fetchRequest)
        
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "New Task")
        XCTAssertEqual(tasks.first?.taskDescription, "New Description")
        XCTAssertFalse(tasks.first?.isCompleted ?? true)
    }
    
    func testToggleTaskCompletion() {
        // Given
        let task = Task(context: mockContext)
        task.title = "Test Task"
        task.isCompleted = false
        try! mockContext.save()
        
        // When
        interactor.toggleTaskCompletion(task)
        
        // Then
        XCTAssertTrue(mockPresenter.didToggleTaskCompletionCalled)
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
    }
    
    func testDeleteTask() {
        // Given
        let task = Task(context: mockContext)
        task.title = "Task to delete"
        try! mockContext.save()
        
        // When
        interactor.deleteTask(task)
        
        // Then
        XCTAssertTrue(mockPresenter.didDeleteTaskCalled)
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let tasks = try! mockContext.fetch(fetchRequest)
        
        XCTAssertTrue(tasks.isEmpty)
    }
    
    func testSearchTasks() {
        // Given
        let task1 = Task(context: mockContext)
        task1.title = "Buy milk"
        task1.taskDescription = "From the store"
        
        let task2 = Task(context: mockContext)
        task2.title = "Call mom"
        task2.taskDescription = "About weekend plans"
        
        try! mockContext.save()
        
        // When
        interactor.searchTasks(with: "milk")
        
        // Then
        XCTAssertTrue(mockPresenter.didSearchTasksCalled)
        XCTAssertEqual(mockPresenter.searchedTasks?.count, 1)
        XCTAssertEqual(mockPresenter.searchedTasks?.first?.title, "Buy milk")
    }
}

class MockTaskListInteractorOutput: TaskListInteractorOutputProtocol {
    var didRetrieveTasksCalled = false
    var retrievedTasks: [Task]?
    
    var didCreateTaskCalled = false
    
    var didUpdateTaskCalled = false
    
    var didDeleteTaskCalled = false
    
    var didToggleTaskCompletionCalled = false
    
    var didSearchTasksCalled = false
    var searchedTasks: [Task]?
    
    var onErrorCalled = false
    var errorMessage: String?
    
    func didRetrieveTasks(_ tasks: [Task]) {
        didRetrieveTasksCalled = true
        retrievedTasks = tasks
    }
    
    func didCreateTask(_ task: Task) {
        didCreateTaskCalled = true
    }
    
    func didUpdateTask(_ task: Task) {
        didUpdateTaskCalled = true
    }
    
    func didDeleteTask(_ task: Task) {
        didDeleteTaskCalled = true
    }
    
    func didToggleTaskCompletion(_ task: Task) {
        didToggleTaskCompletionCalled = true
    }
    
    func didSearchTasks(_ tasks: [Task]) {
        didSearchTasksCalled = true
        searchedTasks = tasks
    }
    
    func onError(message: String) {
        onErrorCalled = true
        errorMessage = message
    }
}
