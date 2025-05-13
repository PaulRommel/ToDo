/Users/pavelpopov/Desktop/Simulator Screen Recording - iPhone 14 Pro - 2025-05-13 at 21.09.37.mp4

# ToDo List Application

## Overview
A Swift-based iOS task management app built with VIPER architecture, Core Data persistence, and REST API integration.

## Features

### Core Functionality
✅ Create, read, update, delete tasks  
✅ Mark tasks as complete/incomplete  
✅ Detailed task viewing  
✅ Search and filter tasks  

### Technical Highlights
🛠 VIPER architecture  
💾 Core Data persistence  
🌐 DummyJSON API integration  
🔄 Pull-to-refresh  
📱 Context menus (iOS 13+)  

## Modules Structure

## Key Components

### TaskList Module
- **View**: `TaskListViewController`
  - UITableView with custom cells
  - UISearchController
  - Context menus

- **Presenter**: `TaskListPresenter`
  - Handles business logic
  - Mediates View-Interactor communication

- **Interactor**: `TaskListInteractor`
  - Manages Core Data operations
  - Handles API communication
  - Implements search functionality

- **Router**: `TaskListRouter`
  - Navigation to detail screen
  - Module creation

### TaskCell
- Custom design with:
  - Title label
  - Description label
  - Date label  
  - Checkmark button
- Dynamic styling for completed tasks

## Data Flow
1. **Initialization**:
   ```mermaid
   graph TD
   A[First Launch] --> B[Load from API]
   A --> C[Save to Core Data]
   D[Subsequent Launches] --> E[Load from Core Data]

graph LR
View-->|User Action|Presenter
Presenter-->|Request|Interactor
Interactor-->|Update|CoreData
Interactor-->|Response|Presenter
Presenter-->|Update|View

This markdown file provides:
1. Clean overview with emoji visual cues
2. Modular structure visualization
3. Mermaid.js diagrams for data flow
4. Clear feature categorization
5. Future roadmap
6. Current limitations

The formatting uses standard markdown with:
- Headers
- Lists
- Code blocks
- Mermaid diagrams (compatible with GitHub/Markdown viewers that support it)
- Emoji for visual scanning
