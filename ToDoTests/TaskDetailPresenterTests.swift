//
//  TaskDetailPresenterTests.swift
//  ToDoTests
//
//  Created by Pavel Popov on 11.05.2025.
//

import XCTest
import CoreData
@testable import ToDo

class TaskDetailPresenterTests: XCTestCase {
    
    var presenter: TaskDetailPresenter!
    var mockView: MockTaskDetailView!
    var mockInteractor: MockTaskDetailInteractor!
    var mockRouter: MockTaskDetailRouter!
    
    override func setUp() {
        super.setUp()
        
        presenter = TaskDetailPresenter()
        mockView = MockTaskDetailView()
        mockInteractor = MockTaskDetailInteractor()
        mockRouter = MockTaskDetailRouter()
        
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
    
    func testViewDidLoadShowsTask() {
        // Given
        let task = Task(context: mockInteractor.context)
        task.title = "Test Task"
        task.taskDescription = "Test Description"
        task.createdAt = Date()
        presenter.task = task
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockView.showTaskDetailCalled)
        XCTAssertEqual(mockView.shownTask?.title, "Test Task")
    }
}

class MockTaskDetailView: TaskDetailViewProtocol {
    var showTaskDetailCalled = false
    var shownTask: Task?
    
    func showTaskDetail(_ task: Task) {
        showTaskDetailCalled = true
        shownTask = task
    }
}

class MockTaskDetailInteractor: TaskDetailInteractorInputProtocol {
    weak var presenter: (any TaskDetailInteractorOutputProtocol)?
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
}

class MockTaskDetailRouter: TaskDetailRouterProtocol {
    static func createModule(with task: Task) -> UIViewController {
        return UIViewController()
    }
}
