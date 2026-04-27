//
//  HomeViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var expenses: [Expense] = []
    private var userName: String = ""
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = .label
        return l
    }()
    
    // Summary Card
    private let summaryCard = UIView()
    
    private let totalExpensesLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 42, weight: .bold)
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        return l
    }()
    
    private let totalTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "TOTAL EXPENSES"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        return l
    }()
    
    private let deductibleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        return l
    }()
    
    private let lastLoginLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        return l
    }()
    
    // Quick Actions
    private let addExpenseButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("＋  Add Expense", for: .normal)
        b.backgroundColor = AppColors.primaryLight
        b.setTitleColor(AppColors.primaryDark, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        b.layer.cornerRadius = 22
        return b
    }()
    
    private let taxSummaryButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Tax Summary", for: .normal)
        b.backgroundColor = AppColors.primary
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        b.layer.cornerRadius = 22
        return b
    }()
    
    // Recent Expenses
    private let recentLabel: UILabel = {
        let l = UILabel()
        l.text = "RECENT EXPENSES"
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "expenseCell")
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No expenses yet!\nTap + to add your first expense."
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    
    // Floating Button
    private let floatingButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        b.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.backgroundColor = AppColors.primary
        b.layer.cornerRadius = 30
        b.layer.shadowColor = AppColors.primary.cgColor
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 12
        b.layer.shadowOpacity = 0.4
        return b
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupLayout()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "TaxMate"
        let alertButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: #selector(showNotifications)
        )
        alertButton.tintColor = AppColors.primary
        navigationItem.rightBarButtonItem = alertButton
    }
    
    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Summary Card
        summaryCard.backgroundColor = AppColors.primary
        summaryCard.layer.cornerRadius = 24
        summaryCard.layer.shadowColor = AppColors.primary.cgColor
        summaryCard.layer.shadowOffset = CGSize(width: 0, height: 8)
        summaryCard.layer.shadowRadius = 20
        summaryCard.layer.shadowOpacity = 0.3
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        
        [greetingLabel, nameLabel, summaryCard, addExpenseButton,
         taxSummaryButton, recentLabel, tableView, emptyStateLabel]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            }
        
        [totalTitleLabel, totalExpensesLabel, deductibleLabel, lastLoginLabel]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                summaryCard.addSubview($0)
            }
        
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            // Greeting
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Summary Card
            summaryCard.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            totalTitleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 24),
            totalTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 24),
            
            totalExpensesLabel.topAnchor.constraint(equalTo: totalTitleLabel.bottomAnchor, constant: 4),
            totalExpensesLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 24),
            totalExpensesLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -24),
            
            deductibleLabel.topAnchor.constraint(equalTo: totalExpensesLabel.bottomAnchor, constant: 4),
            deductibleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 24),
            
            lastLoginLabel.topAnchor.constraint(equalTo: deductibleLabel.bottomAnchor, constant: 8),
            lastLoginLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 24),
            lastLoginLabel.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -24),
            
            // Quick Actions
            addExpenseButton.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 16),
            addExpenseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addExpenseButton.heightAnchor.constraint(equalToConstant: 44),
            
            taxSummaryButton.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 16),
            taxSummaryButton.leadingAnchor.constraint(equalTo: addExpenseButton.trailingAnchor, constant: 12),
            taxSummaryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            taxSummaryButton.heightAnchor.constraint(equalToConstant: 44),
            taxSummaryButton.widthAnchor.constraint(equalTo: addExpenseButton.widthAnchor),
            
            // Recent
            recentLabel.topAnchor.constraint(equalTo: addExpenseButton.bottomAnchor, constant: 24),
            recentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: recentLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 400),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            
            // Floating Button
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            floatingButton.widthAnchor.constraint(equalToConstant: 60),
            floatingButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Actions
    private func setupActions() {
        addExpenseButton.addTarget(self, action: #selector(handleAddExpense), for: .touchUpInside)
        taxSummaryButton.addTarget(self, action: #selector(handleTaxSummary), for: .touchUpInside)
        floatingButton.addTarget(self, action: #selector(handleAddExpense), for: .touchUpInside)
    }
    
    @objc private func handleAddExpense() {
        let vc = AddExpenseViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    @objc private func handleTaxSummary() {
        tabBarController?.selectedIndex = 2
    }
    
    @objc private func showNotifications() {
        let alert = UIAlertController(title: "Notifications", message: "No new notifications", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Load Data
    private func loadData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Load greeting
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        switch hour {
        case 0..<12: greeting = "Good morning"
        case 12..<17: greeting = "Good afternoon"
        default: greeting = "Good evening"
        }
        greetingLabel.text = greeting
        
        // Load last login
        let lastLogin = UserDefaults.standard.string(forKey: "lastLogin") ?? "First time!"
        lastLoginLabel.text = "Last login: \(lastLogin)"
        
        // Save current login time
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        UserDefaults.standard.set(formatter.string(from: Date()), forKey: "lastLogin")
        
        // Load user name from Firestore
        Firestore.firestore().collection("users").document(userID).getDocument { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                let name = snapshot?.data()?["fullName"] as? String ?? "there"
                self?.userName = name
                self?.nameLabel.text = "Hello, \(name)! 👋"
            }
        }
        
        // Load expenses from Core Data
        expenses = CoreDataManager.shared.fetchExpenses(userID: userID)
        let total = CoreDataManager.shared.totalAmount(for: expenses)
        let deductible = expenses.filter { $0.isTaxDeductible }.reduce(0) { $0 + $1.amount }
        
        // Format currency
        let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        let formatter2 = NumberFormatter()
        formatter2.numberStyle = .currency
        formatter2.currencyCode = currency
        
        totalExpensesLabel.text = formatter2.string(from: NSNumber(value: total)) ?? "$0.00"
        deductibleLabel.text = "\(formatter2.string(from: NSNumber(value: deductible)) ?? "$0.00") tax-deductible"
        
        // Update table
        emptyStateLabel.isHidden = !expenses.isEmpty
        tableView.reloadData()
    }
}

// MARK: - TableView
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(expenses.count, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        let expense = expenses[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = expense.title
        config.secondaryText = "\(expense.formattedDate) • \(expense.category ?? "")"
        config.textProperties.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
        config.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = config
        
        // Amount label
        let amountLabel = UILabel()
        amountLabel.text = expense.formattedAmount
        amountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        amountLabel.textColor = AppColors.primary
        amountLabel.sizeToFit()
        cell.accessoryView = amountLabel
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tabBarController?.selectedIndex = 1
    }
}
