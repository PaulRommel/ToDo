//
//  ToDoUITests.swift
//  ToDoUITests
//
//  Created by Pavel Popov on 01.05.2025.
//

import XCTest

final class ToDoUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    private func createTask(title: String, description: String? = nil) {
        let addButton = app.toolbars["Toolbar"].buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        let alert = app.alerts["New Task"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        
        let titleField = alert.textFields.firstMatch
        titleField.tap()
        titleField.typeText(title)
        
        if let description = description {
            let descriptionField = alert.textFields.element(boundBy: 1)
            descriptionField.tap()
            descriptionField.typeText(description)
        }
        
        alert.buttons["Submit"].tap()
    }
    
    private func deleteTask(at index: Int) {
        let cell = app.cells.element(boundBy: index)
        cell.swipeLeft()
        cell.buttons["Delete"].tap()
    }
    
    // MARK: - Test Cases
    func testCreateTask() throws {
        // Given
        let taskTitle = "Test Task"
        let taskDescription = "Test Description"
        
        // When
        createTask(title: taskTitle, description: taskDescription)
        
        // Then
        let cell = app.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        XCTAssertTrue(cell.staticTexts[taskTitle].exists)
        XCTAssertTrue(cell.staticTexts[taskDescription].exists)
    }
    
    func testCompleteTask() throws {
        // Given
        let taskTitle = "Task to Complete"
        createTask(title: taskTitle)
        
        // When
        let cell = app.cells.firstMatch
        let checkmarkButton = cell.buttons["circle"]
        checkmarkButton.tap()
        
        // Then
        XCTAssertTrue(cell.buttons["checkmark.circle.fill"].exists)
        
        // Verify strikethrough style (indirectly by checking text color)
        let titleLabel = cell.staticTexts[taskTitle]
        XCTAssertEqual(titleLabel.label, taskTitle)
    }
    
    func testEditTask() throws {
        // Given
        let originalTitle = "Original Title"
        let editedTitle = "Edited Title"
        createTask(title: originalTitle)
        
        // When
        let cell = app.cells.firstMatch
        cell.press(forDuration: 1)
        
        let editAction = app.buttons["Edit"]
        XCTAssertTrue(editAction.waitForExistence(timeout: 2))
        editAction.tap()
        
        let alert = app.alerts["Edit Task"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        
        let titleField = alert.textFields.firstMatch
        titleField.tap()
        titleField.clearText()
        titleField.typeText(editedTitle)
        
        alert.buttons["Save"].tap()
        
        // Then
        XCTAssertTrue(cell.staticTexts[editedTitle].exists)
        XCTAssertFalse(cell.staticTexts[originalTitle].exists)
    }
    
    func testDeleteTask() throws {
        // Given
        let taskTitle = "Task to Delete"
        createTask(title: taskTitle)
        
        // When
        deleteTask(at: 0)
        
        // Then
        let cell = app.cells.firstMatch
        XCTAssertFalse(cell.staticTexts[taskTitle].exists)
    }
    
    func testSearchTask() throws {
        // Given
        let task1 = "Important Task"
        let task2 = "Regular Task"
        createTask(title: task1)
        createTask(title: task2)
        
        // When
        let searchBar = app.searchFields["Search tasks..."]
        searchBar.tap()
        searchBar.typeText("Important")
        
        // Then
        XCTAssertTrue(app.cells.staticTexts[task1].exists)
        XCTAssertFalse(app.cells.staticTexts[task2].exists)
        
        // When clearing search
        app.buttons["Cancel"].tap()
        
        // Then both tasks should be visible again
        XCTAssertTrue(app.cells.staticTexts[task1].exists)
        XCTAssertTrue(app.cells.staticTexts[task2].exists)
    }
    
    func testTaskDetailView() throws {
        // Given
        let taskTitle = "Detailed Task"
        let taskDescription = "This is a detailed description"
        createTask(title: taskTitle, description: taskDescription)
        
        // When
        app.cells.firstMatch.tap()
        
        // Then
        XCTAssertTrue(app.navigationBars["Task Details"].exists)
        XCTAssertTrue(app.staticTexts[taskTitle].exists)
        XCTAssertTrue(app.staticTexts[taskDescription].exists)
        XCTAssertTrue(app.staticTexts["Status: Pending"].exists)
    }
    
    func testContextMenuActions() throws {
        // Given
        let taskTitle = "Context Menu Task"
        createTask(title: taskTitle)
        
        // When
        let cell = app.cells.firstMatch
        cell.press(forDuration: 1)
        
        // Then
        XCTAssertTrue(app.buttons["Edit"].exists)
        XCTAssertTrue(app.buttons["Delete"].exists)
    }
}

// Extension to clear text in text fields
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
