//
//  ViewController.swift
//  ToDo
//
//  Created by Pavel Popov on 05.05.2025.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: - Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let apiUrl = "https://dummyjson.com/todos"
    private let hasLoadedKey = "hasLoadedFromAPI"
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search tasks..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = 80
        table.tableFooterView = UIView()
        return table
    }()
    
    private var models = [Task]()
    private var filteredModels = [Task]()
    private let refreshControl = UIRefreshControl()
    private var isSearching = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        
        // Проверяем, загружали ли уже данные из API
        if !UserDefaults.standard.bool(forKey: hasLoadedKey) {
            loadTasksFromAPI()
        } else {
            loadTasks()
        }
    }
    
    // MARK: - API Methods
    private func loadTasksFromAPI() {
        guard let url = URL(string: apiUrl) else {
            showErrorAlert(message: "Invalid API URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to load tasks: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "No data received")
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(TodoAPIResponse.self, from: data)
                
                // Сохраняем задачи в Core Data
                self.saveTasksFromAPI(apiResponse.todos)
                
                // Помечаем, что данные уже загружены
                UserDefaults.standard.set(true, forKey: self.hasLoadedKey)
                
                // Загружаем задачи из Core Data
                DispatchQueue.main.async {
                    self.loadTasks()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    private func saveTasksFromAPI(_ todos: [TodoItem]) {
        context.perform {
            for todo in todos {
                let newTask = Task(context: self.context)
                newTask.title = todo.todo
                newTask.taskDescription = "Imported from API"
                newTask.createdAt = Date()
                newTask.isCompleted = todo.completed
                newTask.completedAt = todo.completed ? Date() : nil
            }
            
            do {
                try self.context.save()
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to save tasks: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //-----------------------
    // MARK: - Setup
    private func setupUI() {
        title = "To Do List"
        view.backgroundColor = UIColor.white //Цвет фона
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(didTapAdd))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        toolbarItems = [flexibleSpace, addButton]
        navigationController?.setToolbarHidden(false, animated: false)
        
        if let toolbar = navigationController?.toolbar {
            let exactColor = UIColor(hex: "#D70015") ?? UIColor.darkGray
            toolbar.barTintColor = exactColor
            toolbar.tintColor = .yellow
            toolbar.isTranslucent = false
        }
    }
    
    private func setupTableView() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        refreshControl.addTarget(self, action: #selector(loadTasks), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredModels.removeAll()
        } else {
            isSearching = true
            filterTasks(with: searchText)
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredModels.removeAll()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func filterTasks(with searchText: String) {
        filteredModels = models.filter { task in
            let titleMatch = task.title?.lowercased().contains(searchText.lowercased()) ?? false
            let descriptionMatch = task.taskDescription?.lowercased().contains(searchText.lowercased()) ?? false
            return titleMatch || descriptionMatch
        }
    }
    
    // MARK: - Actions
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Task",
                                      message: "Enter task details",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Description (optional)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let titleField = alert.textFields?.first,
                  let title = titleField.text,
                  !title.isEmpty else {
                self?.showErrorAlert(message: "Title cannot be empty")
                return
            }
            
            let description = alert.textFields?[1].text ?? ""
            self?.createItem(title: title, description: description)
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func loadTasks() {
        getAllItems()
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredModels.count : models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        let model = isSearching ? filteredModels[indexPath.row] : models[indexPath.row]
        cell.configure(with: model)
        
        cell.completionHandler = { [weak self] in
            self?.toggleTaskCompletion(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = isSearching ? filteredModels[indexPath.row] : models[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.showEditDialog(for: task)
            }
            
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareTask(task)
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteItem(item: task)
            }
            
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
    
    private func shareTask(_ task: Task) {
        let text = "Моя задача: \(task.title ?? "")\nОписание: \(task.taskDescription ?? "")"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = isSearching ? filteredModels[indexPath.row] : models[indexPath.row]
        showTaskDetail(task: task)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = isSearching ? filteredModels[indexPath.row] : models[indexPath.row]
            deleteItem(item: item)
        }
    }
    
    // MARK: - Task Detail
    private func showTaskDetail(task: Task) {
        let detailVC = TaskDetailViewController(task: task)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Task Completion
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        let task = isSearching ? filteredModels[indexPath.row] : models[indexPath.row]
        task.isCompleted = !task.isCompleted
        task.completedAt = task.isCompleted ? Date() : nil
        
        do {
            try context.save()
            getAllItems()
        } catch {
            showErrorAlert(message: "Failed to update task status: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Core Data Operations
    private func getAllItems() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            models = try context.fetch(request)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.showErrorAlert(message: "Failed to load tasks: \(error.localizedDescription)")
            }
        }
    }
    
    private func createItem(title: String, description: String) {
        let newItem = Task(context: context)
        newItem.title = title
        newItem.taskDescription = description
        newItem.createdAt = Date()
        newItem.isCompleted = false
        
        do {
            try context.save()
            getAllItems()
        } catch {
            showErrorAlert(message: "Failed to create task: \(error.localizedDescription)")
        }
    }
    
    private func deleteItem(item: Task) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            showErrorAlert(message: "Failed to delete task: \(error.localizedDescription)")
        }
    }
    
    private func updateItem(item: Task, newTitle: String, newDescription: String) {
        item.title = newTitle
        item.taskDescription = newDescription
        
        do {
            try context.save()
            getAllItems()
        } catch {
            showErrorAlert(message: "Failed to update task: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    private func showEditDialog(for item: Task) {
        let alert = UIAlertController(title: "Edit Task",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = item.title
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.text = item.taskDescription
            textField.placeholder = "Description"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let titleField = alert.textFields?.first,
                  let newTitle = titleField.text,
                  !newTitle.isEmpty else {
                self?.showErrorAlert(message: "Title cannot be empty")
                return
            }
            
            let newDescription = alert.textFields?[1].text ?? ""
            self?.updateItem(item: item, newTitle: newTitle, newDescription: newDescription)
        }))
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

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

// MARK: - Task Detail ViewController
class TaskDetailViewController: UIViewController {
    private let task: Task
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        label.textColor = UIColor.black // Черный цвет для заголовка ------------------
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
    
    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithTask()
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
    
    private func configureWithTask() {
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

// MARK: - Custom Cell
class TaskCell: UITableViewCell {
    static let identifier = "TaskCell"
    
    var completionHandler: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textColor = UIColor.black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.tintColor = .systemBlue // Синий цвет для чекбокса
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(checkmarkButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        checkmarkButton.addTarget(self, action: #selector(didTapCheckmark), for: .touchUpInside)
    }
    
    @objc private func didTapCheckmark() {
        completionHandler?()
    }
    
    func configure(with task: Task) {
        let attributedString = NSMutableAttributedString(string: task.title ?? "")
        
        if task.isCompleted {
            attributedString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: attributedString.length)
            )
            titleLabel.textColor = .lightGray
            descriptionLabel.textColor = .lightGray
        } else {
            titleLabel.textColor = .black
            descriptionLabel.textColor = .gray
        }
        
        titleLabel.attributedText = attributedString
        checkmarkButton.isSelected = task.isCompleted
        
        // Устанавливаем описание (если есть)
        if let description = task.taskDescription, !description.isEmpty {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = "No description"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let completedAt = task.completedAt {
            dateLabel.text = "Completed: \(dateFormatter.string(from: completedAt))"
        } else {
            dateLabel.text = "Created: \(dateFormatter.string(from: task.createdAt ?? Date()))"
        }
    }
}

extension UIColor {
    // Инициализация из HEX строки (форматы: "#RRGGBB" или "RRGGBB")
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard hexString.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    // Инициализация из RGB значений (0-255)
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: alpha
        )
    }
}
