//
//  TaxSummaryViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit
import FirebaseAuth

final class TaxSummaryViewController: UIViewController {

    // MARK: - Properties
    private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    private var deductibleExpenses: [Expense] = []
    private var categoryBreakdown: [(category: String, total: Double)] = []

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let yearControl: UISegmentedControl = {
        let currentYear = Calendar.current.component(.year, from: Date())
        let sc = UISegmentedControl(items: ["\(currentYear-2)", "\(currentYear-1)", "\(currentYear)"])
        sc.selectedSegmentIndex = 2
        sc.selectedSegmentTintColor = AppColors.primary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let totalCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1)
        v.layer.cornerRadius = 24
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let totalTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "TOTAL DEDUCTIBLE"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let totalAmountLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 42, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let percentLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tipsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("💡  See Tax Saving Tips  →", for: .normal)
        b.setTitleColor(AppColors.primaryLight, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        return tv
    }()

    private let exportButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Export Tax Report", for: .normal)
        b.backgroundColor = AppColors.primary
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        b.layer.cornerRadius = 22
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tax Summary"
        view.backgroundColor = AppColors.background
        setupLayout()
        setupActions()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    // MARK: - Layout
    private func setupLayout() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Export", style: .plain,
            target: self, action: #selector(handleExport)
        )
        navigationItem.rightBarButtonItem?.tintColor = AppColors.primary

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

        totalCard.addSubview(totalTitleLabel)
        totalCard.addSubview(totalAmountLabel)
        totalCard.addSubview(percentLabel)
        totalCard.addSubview(tipsButton)

        contentView.addSubview(yearControl)
        contentView.addSubview(totalCard)
        contentView.addSubview(tableView)
        contentView.addSubview(exportButton)

        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            yearControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            yearControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            yearControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            totalCard.topAnchor.constraint(equalTo: yearControl.bottomAnchor, constant: 16),
            totalCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            totalCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            totalTitleLabel.topAnchor.constraint(equalTo: totalCard.topAnchor, constant: 24),
            totalTitleLabel.leadingAnchor.constraint(equalTo: totalCard.leadingAnchor, constant: 24),

            totalAmountLabel.topAnchor.constraint(equalTo: totalTitleLabel.bottomAnchor, constant: 4),
            totalAmountLabel.leadingAnchor.constraint(equalTo: totalCard.leadingAnchor, constant: 24),

            percentLabel.topAnchor.constraint(equalTo: totalAmountLabel.bottomAnchor, constant: 4),
            percentLabel.leadingAnchor.constraint(equalTo: totalCard.leadingAnchor, constant: 24),

            tipsButton.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 12),
            tipsButton.leadingAnchor.constraint(equalTo: totalCard.leadingAnchor, constant: 24),
            tipsButton.bottomAnchor.constraint(equalTo: totalCard.bottomAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: totalCard.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 450),

            exportButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            exportButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            exportButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            exportButton.heightAnchor.constraint(equalToConstant: 52),
            exportButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        yearControl.addTarget(self, action: #selector(yearChanged), for: .valueChanged)
        tipsButton.addTarget(self, action: #selector(showTaxTips), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(handleExport), for: .touchUpInside)
    }

    @objc private func yearChanged() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = [currentYear - 2, currentYear - 1, currentYear]
        selectedYear = years[yearControl.selectedSegmentIndex]
        loadData()
    }

    @objc private func showTaxTips() {
        let vc = TaxTipsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleExport() {
        var csv = "TaxMate Tax Report \(selectedYear)\n"
        csv += "IRS Schedule C Category,Total\n"
        for row in categoryBreakdown {
            csv += "\(row.category),\(String(format: "%.2f", row.total))\n"
        }
        let total = categoryBreakdown.reduce(0) { $0 + $1.total }
        csv += "\nTotal Deductible,\(String(format: "%.2f", total))\n"

        let vc = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        present(vc, animated: true)
    }

    // MARK: - Load Data
    private func loadData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        deductibleExpenses = CoreDataManager.shared.fetchDeductibleExpenses(
            userID: userID, year: selectedYear
        )

        let allExpenses = CoreDataManager.shared.fetchExpenses(userID: userID)
        let totalAll = CoreDataManager.shared.totalAmount(for: allExpenses)
        let totalDeductible = CoreDataManager.shared.totalAmount(for: deductibleExpenses)
        let pct = totalAll > 0 ? Int((totalDeductible / totalAll) * 100) : 0

        let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency

        totalAmountLabel.text = formatter.string(from: NSNumber(value: totalDeductible)) ?? "$0.00"
        percentLabel.text = "\(pct)% of \(selectedYear) expenses are tax-deductible"

        // Group by IRS category
        var dict: [String: Double] = [:]
        for expense in deductibleExpenses {
            let key = expense.irsScheduleCategory ?? "Other"
            dict[key, default: 0] += expense.amount
        }
        categoryBreakdown = dict.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
        tableView.reloadData()
    }
}

// MARK: - TableView
extension TaxSummaryViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "IRS SCHEDULE C BREAKDOWN"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryBreakdown.isEmpty ? 1 : categoryBreakdown.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()

        if categoryBreakdown.isEmpty {
            config.text = "No deductible expenses for \(selectedYear)"
            config.textProperties.color = .secondaryLabel
            config.textProperties.alignment = .center
        } else {
            let row = categoryBreakdown[indexPath.row]
            config.text = row.category
            config.textProperties.font = UIFont.systemFont(ofSize: 15)

            let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            config.secondaryText = formatter.string(from: NSNumber(value: row.total)) ?? "$0.00"
            config.secondaryTextProperties.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
            config.secondaryTextProperties.color = AppColors.primary
        }

        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}
