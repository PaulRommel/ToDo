//
//  TaskDetailViewController.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

final class TaskDetailViewController: UIViewController {
    var presenter: TaskDetailPresenterProtocol!

    private let textField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Task"
        setupTextField()
        setupNavigationBar()
        presenter.viewDidLoad()
    }

    private func setupTextField() {
        view.addSubview(textField)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter task..."
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(saveTapped))
    }

    @objc private func saveTapped() {
        presenter.didTapSave(title: textField.text ?? "")
    }
}

extension TaskDetailViewController: TaskDetailViewProtocol {
    func showTask(_ task: TaskItem) {
        textField.text = task.title
    }
}
