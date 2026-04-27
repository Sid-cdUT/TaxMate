//
//  ExpenseListViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit
import FirebaseAuth

final class ExpenseListViewController: UIViewController {

    // MARK: - Properties
    private var allExpenses: [Expense] = []
    private var filteredExpenses: [Expense] = []
    private var activeFilter: String = "All"

    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search expenses..."
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let filterControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "Travel", "Meals", "Supplies", "Software", "Other"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = AppColors.primary
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white,
                                   .font: UIFont.systemFont(ofSize: 11, weight: .semibold)], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.reuseID)
        tv.separatorStyle = .none
        tv.backgroundColor = AppColors.background
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true

        let iv = UIImageView(image: UIImage(systemName: "doc.text.magnifyingglass"))
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let l = UILabel()
        l.text = "No expenses found"
        l.font = UIFont.systemFont(ofSize: 16)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false

        v.addSubview(iv)
        v.addSubview(l)

        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: -20),
            iv.widthAnchor.constraint(equalToConstant: 60),
            iv.heightAnchor.constraint(equalToConstant: 60),
            l.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 12),
            l.centerXAnchor.constraint(equalTo: v.centerXAnchor),
        ])
        return v
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Expenses"
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupLayout()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadExpenses()
    }

    // MARK: - Nav Bar
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(handleAdd)
        )
        addButton.tintColor = AppColors.primary
        navigationItem.rightBarButtonItem = addButton
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(filterControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            filterControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            filterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: filterControl.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }

    // MARK: - Actions
    private func setupActions() {
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    @objc private func handleAdd() {
        let vc = AddExpenseViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func filterChanged() {
        let filters = ["All", "Travel", "Meals", "Supplies", "Software", "Other"]
        activeFilter = filters[filterControl.selectedSegmentIndex]
        applyFilters()
    }

    // MARK: - Load Data
    private func loadExpenses() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        allExpenses = CoreDataManager.shared.fetchExpenses(userID: userID)
        applyFilters()
    }

    private func applyFilters() {
        var result = allExpenses
        if activeFilter != "All" {
            result = result.filter { $0.category == activeFilter }
        }
        if let query = searchBar.text, !query.isEmpty {
            result = result.filter {
                ($0.title ?? "").localizedCaseInsensitiveContains(query)
            }
        }
        filteredExpenses = result
        emptyStateView.isHidden = !filteredExpenses.isEmpty
        tableView.isHidden = filteredExpenses.isEmpty
        tableView.reloadData()
    }

    private func deleteExpense(at indexPath: IndexPath) {
        let expense = filteredExpenses[indexPath.row]
        let alert = UIAlertController(
            title: "Delete Expense",
            message: "Are you sure you want to delete '\(expense.title ?? "this expense")'?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            CoreDataManager.shared.deleteExpense(expense)
            self?.loadExpenses()
        })
        present(alert, animated: true)
    }
}

// MARK: - TableView
extension ExpenseListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredExpenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.reuseID,
                                                  for: indexPath) as! ExpenseTableViewCell
        cell.configure(with: filteredExpenses[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 72 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ExpenseDetailViewController(expense: filteredExpenses[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteExpense(at: indexPath)
            completion(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self = self else { return }
            let vc = AddExpenseViewController()
            vc.expenseToEdit = self.filteredExpenses[indexPath.row]
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
            completion(true)
        }
        edit.backgroundColor = AppColors.primary
        edit.image = UIImage(systemName: "pencil")

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}

// MARK: - SearchBar
extension ExpenseListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        applyFilters()
    }
}
