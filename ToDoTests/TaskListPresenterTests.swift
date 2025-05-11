//
//  TaskListPresenterTests.swift
//  ToDoTests
//
//  Created by Pavel Popov on 11.05.2025.
//

import XCTest
import CoreData
@testable import ToDo

class TaskListPresenterTests: XCTestCase {
    
    var presenter: TaskListPresenter!
    var mockView: MockTaskListView!
    var mockInteractor: MockTaskListInteractorInput!
    var mockRouter: MockTaskListRouter!
    
    override func setUp() {
        super.setUp()
        
        presenter = TaskListPresenter()
        mockView = MockTaskListView()
        mockInteractor = MockTaskListInteractorInput()
        mockRouter = MockTaskListRouter()
        
        presenter.view = mockView
        presenter.interactor = mockInteractor
        presenter.router = mockRouter
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }
    
    func testViewDidLoadLoadsTasks() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.fetchTasksCalled)
    }
    
    func testNumberOfTasks() {
        // Given
        let task1 = Task(context: mockInteractor.context)
        task1.title = "Task 1"
        
        let task2 = Task(context: mockInteractor.context)
        task2.title = "Task 2"
        
        mockInteractor.stubbedTasks = [task1, task2]
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertEqual(presenter.numberOfTasks, 2)
    }
    
    func testTaskAtIndexPath() {
        // Given
        let task1 = Task(context: mockInteractor.context)
        task1.title = "Task 1"
        
        let task2 = Task(context: mockInteractor.context)
        task2.title = "Task 2"
        
        mockInteractor.stubbedTasks = [task1, task2]
        presenter.viewDidLoad()
        
        // When
        let indexPath = IndexPath(row: 0, section: 0)
        let task = presenter.task(at: indexPath)
        
        // Then
        XCTAssertEqual(task?.title, "Task 1")
    }
    
    func testDidTapAddButtonShowsAlert() {
        // When
        presenter.didTapAddButton()
        
        // Then
        XCTAssertTrue(mockView.showAddTaskDialogCalled)
    }
    
    func testToggleTaskCompletion() {
        // Given
        let task = Task(context: mockInteractor.context)
        task.isCompleted = false
        
        // When
        presenter.toggleTaskCompletion(for: task)
        
        // Then
        XCTAssertTrue(mockInteractor.toggleTaskCompletionCalled)
        XCTAssertEqual(mockInteractor.toggledTask, task)
    }
    
    func testDidSelectTaskNavigatesToDetail() {
        // Given
        let task = Task(context: mockInteractor.context)
        mockInteractor.stubbedTasks = [task]
        presenter.viewDidLoad()
        
        // When
        let indexPath = IndexPath(row: 0, section: 0)
        presenter.didSelectTask(at: indexPath)
        
        // Then
        XCTAssertTrue(mockRouter.presentTaskDetailCalled)
        XCTAssertEqual(mockRouter.presentedTask, task)
    }
    
    func testSearchTasks() {
        // Given
        let task1 = Task(context: mockInteractor.context)
        task1.title = "Buy milk"
        
        let task2 = Task(context: mockInteractor.context)
        task2.title = "Call mom"
        
        mockInteractor.stubbedTasks = [task1, task2]
        presenter.viewDidLoad()
        
        // When
        presenter.didSearchTasks(with: "milk")
        
        // Then
        XCTAssertTrue(mockInteractor.searchTasksCalled)
        XCTAssertEqual(mockInteractor.searchText, "milk")
    }
}

class MockTaskListView: TaskListViewProtocol {
    var showTasksCalled = false
    var shownTasks: [Task]?
    
    var showFilteredTasksCalled = false
    var shownFilteredTasks: [Task]?
    
    var showErrorCalled = false
    var errorMessage: String?
    
    var endRefreshingCalled = false
    
    var showAddTaskDialogCalled = false
    
    var showEditDialogCalled = false
    var editedTask: Task?
    
    func showTasks(_ tasks: [Task]) {
        showTasksCalled = true
        shownTasks = tasks
    }
    
    func showFilteredTasks(_ tasks: [Task]) {
        showFilteredTasksCalled = true
        shownFilteredTasks = tasks
    }
    
    func showError(message: String) {
        showErrorCalled = true
        errorMessage = message
    }
    
    func endRefreshing() {
        endRefreshingCalled = true
    }
    
    func showAddTaskDialog() {
        showAddTaskDialogCalled = true
    }
    
    func showEditDialog(for task: Task) {
        showEditDialogCalled = true
        editedTask = task
    }
}

class MockTaskListInteractorInput: TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol?
    
    var fetchTasksCalled = false
    var loadTasksFromAPICalled = false
    var createTaskCalled = false
    var createdTitle: String?
    var createdDescription: String?
    var updateTaskCalled = false
    var updatedTask: Task?
    var deleteTaskCalled = false
    var deletedTask: Task?
    var toggleTaskCompletionCalled = false
    var toggledTask: Task?
    var searchTasksCalled = false
    var searchText: String?
    
    var stubbedTasks: [Task] = []
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    func fetchTasks() {
        fetchTasksCalled = true
        presenter?.didRetrieveTasks(stubbedTasks)
    }
    
    func loadTasksFromAPI() {
        loadTasksFromAPICalled = true
    }
    
    func createTask(title: String, description: String) {
        createTaskCalled = true
        createdTitle = title
        createdDescription = description
        
        let task = Task(context: context)
        task.title = title
        task.taskDescription = description
        stubbedTasks.append(task)
        
        presenter?.didCreateTask(task)
    }
    
    func updateTask(_ task: Task, newTitle: String, newDescription: String) {
        updateTaskCalled = true
        updatedTask = task
        task.title = newTitle
        task.taskDescription = newDescription
        presenter?.didUpdateTask(task)
    }
    
    func deleteTask(_ task: Task) {
        deleteTaskCalled = true
        deletedTask = task
        stubbedTasks.removeAll { $0 == task }
        presenter?.didDeleteTask(task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        toggleTaskCompletionCalled = true
        toggledTask = task
        task.isCompleted = !task.isCompleted
        presenter?.didToggleTaskCompletion(task)
    }
    
    func searchTasks(with text: String) {
        searchTasksCalled = true
        searchText = text
        let filtered = stubbedTasks.filter { $0.title?.contains(text) ?? false }
        presenter?.didSearchTasks(filtered)
    }
}

class MockTaskListRouter: TaskListRouterProtocol {
    static func createModule() -> UIViewController {
        return UIViewController()
    }
    
    var presentTaskDetailCalled = false
    var presentedTask: Task?
    var shareTextCalled = false
    var sharedText: String?
    
    func presentTaskDetail(from view: (any TaskListViewProtocol)?, for task: Task) {
        presentTaskDetailCalled = true
        presentedTask = task
    }
    
    func shareText(_ text: String, from view: (any TaskListViewProtocol)?) {
        shareTextCalled = true
        sharedText = text
    }
}
