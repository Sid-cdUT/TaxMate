//
//  ExpenseDetailViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/27/26.
//

import UIKit

final class ExpenseDetailViewController: UIViewController {

    // MARK: - Properties
    private var expense: Expense

    init(expense: Expense) {
        self.expense = expense
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerCard: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.primary
        v.layer.cornerRadius = 24
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 42, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let receiptImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Delete Expense", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private var tableRows: [(key: String, value: String)] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Expense Detail"
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupLayout()
        populateData()
    }

    private func setupNavigationBar() {
        let editButton = UIBarButtonItem(
            title: "Edit", style: .plain,
            target: self, action: #selector(handleEdit)
        )
        editButton.tintColor = AppColors.primary
        navigationItem.rightBarButtonItem = editButton
    }

    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        headerCard.addSubview(titleLabel)
        headerCard.addSubview(amountLabel)
        headerCard.addSubview(dateLabel)

        contentView.addSubview(headerCard)
        contentView.addSubview(tableView)
        contentView.addSubview(receiptImageView)
        contentView.addSubview(deleteButton)

        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -24),

            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            amountLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),

            dateLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),
            dateLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 320),

            receiptImageView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            receiptImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            receiptImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            receiptImageView.heightAnchor.constraint(equalToConstant: 200),

            deleteButton.topAnchor.constraint(equalTo: receiptImageView.bottomAnchor, constant: 16),
            deleteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])

        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(showFullScreenReceipt))
        receiptImageView.addGestureRecognizer(tap)
    }

    // MARK: - Populate
    private func populateData() {
        titleLabel.text = expense.title
        amountLabel.text = expense.formattedAmount
        dateLabel.text = "\(expense.category ?? "") • \(expense.formattedDate)"

        tableRows = [
            ("Category", expense.category ?? "—"),
            ("Date", expense.formattedDate),
            ("Amount", expense.formattedAmount),
            ("Tax Deductible", expense.isTaxDeductible ? "Yes ✓" : "No"),
            ("IRS Category", expense.irsScheduleCategory ?? "—"),
            ("Notes", expense.notes ?? "—"),
        ]
        tableView.reloadData()

        if let data = expense.receiptImageData,
           let img = UIImage(data: data) {
            receiptImageView.image = img
            receiptImageView.isHidden = false
        }
    }

    // MARK: - Actions
    @objc private func handleEdit() {
        let vc = AddExpenseViewController()
        vc.expenseToEdit = expense
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true) { [weak self] in
            self?.populateData()
        }
    }

    @objc private func handleDelete() {
        let alert = UIAlertController(
            title: "Delete Expense",
            message: "This will permanently delete '\(expense.title ?? "this expense")'. This cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            CoreDataManager.shared.deleteExpense(self.expense)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func showFullScreenReceipt() {
        guard let image = receiptImageView.image else { return }
        let vc = FullScreenImageViewController(image: image)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

// MARK: - TableView
extension ExpenseDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = tableRows[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = row.key
        config.textProperties.font = UIFont.systemFont(ofSize: 14)
        config.textProperties.color = .secondaryLabel
        config.secondaryText = row.value
        config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        config.secondaryTextProperties.color = row.key == "Tax Deductible" && expense.isTaxDeductible ? AppColors.primary : .label
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - Full Screen Image
final class FullScreenImageViewController: UIViewController {
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: view.topAnchor),
            iv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss_))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismiss_() { dismiss(animated: true) }
}
