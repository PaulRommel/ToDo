//
//  TaskItem.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import Foundation

struct TaskItem: Codable, Equatable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
}
