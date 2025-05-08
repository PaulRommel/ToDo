//
//  Task.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import Foundation

// MARK: - API Response Models
struct TodoAPIResponse: Codable {
    let todos: [TodoItem]
    let total: Int
    let skip: Int
    let limit: Int
}

struct TodoItem: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
