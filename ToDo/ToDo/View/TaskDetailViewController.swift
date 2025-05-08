//
//  TaskDetailViewController.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

class TaskDetailViewController: UIViewController, TaskDetailViewProtocol {
    var presenter: TaskDetailPresenterProtocol?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Task Details"
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, dateLabel, statusLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - TaskDetailViewProtocol
    
    func showTaskDetail(_ task: Task) {
        titleLabel.text = task.title
        
        if let description = task.taskDescription, !description.isEmpty {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = "No description"
            descriptionLabel.textColor = .lightGray
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let completedAt = task.completedAt {
            dateLabel.text = "Completed: \(dateFormatter.string(from: completedAt))"
            statusLabel.text = "Status: Completed"
            statusLabel.textColor = .systemGreen
        } else {
            dateLabel.text = "Created: \(dateFormatter.string(from: task.createdAt ?? Date()))"
            statusLabel.text = "Status: Pending"
            statusLabel.textColor = .systemOrange
        }
    }
}
