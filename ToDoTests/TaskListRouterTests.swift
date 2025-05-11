//
//  TaskListRouterTests.swift
//  ToDoTests
//
//  Created by Pavel Popov on 11.05.2025.
//

import XCTest
import CoreData
@testable import ToDo

class TaskListRouterTests: XCTestCase {
    
    func testCreateModuleReturnsNavigationController() {
        // When
        let module = TaskListRouter.createModule()
        
        // Then
        XCTAssertTrue(module is UINavigationController)
        let navController = module as! UINavigationController
        XCTAssertTrue(navController.topViewController is TaskListViewController)
    }
    
    func testPresentTaskDetail() {
        // Given
        let router = TaskListRouter()
        let mockView = MockTaskListViewController()
        let task = Task(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        
        // When
        router.presentTaskDetail(from: mockView, for: task)
        
        // Then
        XCTAssertTrue(mockView.mockNavigationController.pushViewControllerCalled)
        XCTAssertTrue(mockView.mockNavigationController.pushedViewController is TaskDetailViewController)
    }
}

class MockTaskListViewController: UIViewController, TaskListViewProtocol {
    var showTasksCalled = false
    var showFilteredTasksCalled = false
    var showErrorCalled = false
    var endRefreshingCalled = false
    var showAddTaskDialogCalled = false
    var showEditDialogCalled = false
    
    let mockNavigationController = MockNavigationController()
    
    override var navigationController: UINavigationController? {
        return mockNavigationController
    }
    
    func showTasks(_ tasks: [Task]) {
        showTasksCalled = true
    }
    
    func showFilteredTasks(_ tasks: [Task]) {
        showFilteredTasksCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
    }
    
    func endRefreshing() {
        endRefreshingCalled = true
    }
    
    func showAddTaskDialog() {
        showAddTaskDialogCalled = true
    }
    
    func showEditDialog(for task: Task) {
        showEditDialogCalled = true
    }
}

class MockNavigationController: UINavigationController {
    var pushViewControllerCalled = false
    var pushedViewController: UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCalled = true
        pushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }
}
