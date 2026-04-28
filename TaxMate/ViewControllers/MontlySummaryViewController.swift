//
//  MontlySummaryViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/27/26.
//

import UIKit
import FirebaseAuth

final class MonthlySummaryViewController: UIViewController {

    // MARK: - Properties
    private var categoryTotals: [(category: String, total: Double, percentage: Double)] = []
    private var monthlyData: [(month: String, total: Double)] = []
    private var selectedMonthIndex: Int? = nil

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

    private let monthLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let totalLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 42, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let changeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chartContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let chartTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "7-MONTH SPENDING"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chartView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let categoryTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "BY CATEGORY"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryLabel
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Monthly Summary"
        view.backgroundColor = AppColors.background
        setupLayout()
        loadData()
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

        headerCard.addSubview(monthLabel)
        headerCard.addSubview(totalLabel)
        headerCard.addSubview(changeLabel)
        chartContainerView.addSubview(chartTitleLabel)
        chartContainerView.addSubview(chartView)

        contentView.addSubview(headerCard)
        contentView.addSubview(chartContainerView)
        contentView.addSubview(categoryTitleLabel)
        contentView.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            monthLabel.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 24),
            monthLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),

            totalLabel.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 4),
            totalLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),

            changeLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 4),
            changeLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),
            changeLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -24),

            chartContainerView.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 16),
            chartContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartContainerView.heightAnchor.constraint(equalToConstant: 180),

            chartTitleLabel.topAnchor.constraint(equalTo: chartContainerView.topAnchor, constant: 12),
            chartTitleLabel.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 16),

            chartView.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor, constant: 8),
            chartView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor, constant: 8),
            chartView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor, constant: -8),
            chartView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: -8),

            categoryTitleLabel.topAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: 16),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            tableView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 400),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }

    // MARK: - Load Data
    private func loadData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Monthly totals
        monthlyData = CoreDataManager.shared.monthlyTotals(userID: userID, months: 7)

        // Current month data
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: Date())

        let expenses = CoreDataManager.shared.fetchExpenses(userID: userID)
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())

        let thisMonthExpenses = expenses.filter {
            let month = Calendar.current.component(.month, from: $0.date ?? Date())
            let year = Calendar.current.component(.year, from: $0.date ?? Date())
            return month == currentMonth && year == currentYear
        }

        let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let lastMonth = Calendar.current.component(.month, from: lastMonthDate)
        let lastYear = Calendar.current.component(.year, from: lastMonthDate)

        let lastMonthExpenses = expenses.filter {
            let month = Calendar.current.component(.month, from: $0.date ?? Date())
            let year = Calendar.current.component(.year, from: $0.date ?? Date())
            return month == lastMonth && year == lastYear
        }

        let thisTotal = CoreDataManager.shared.totalAmount(for: thisMonthExpenses)
        let lastTotal = CoreDataManager.shared.totalAmount(for: lastMonthExpenses)

        let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.currencyCode = currency
        totalLabel.text = numFormatter.string(from: NSNumber(value: thisTotal)) ?? "$0.00"

        if lastTotal > 0 {
            let change = ((thisTotal - lastTotal) / lastTotal) * 100
            let arrow = change >= 0 ? "↑" : "↓"
            changeLabel.text = "\(arrow) \(String(format: "%.0f", abs(change)))% from last month"
            changeLabel.textColor = change >= 0 ?
                UIColor.white.withAlphaComponent(0.8) :
                UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 1)
        } else {
            changeLabel.text = "First month of tracking!"
        }

        // Category breakdown
        let categoryData = CoreDataManager.shared.amountByCategory(expenses: thisMonthExpenses)
        categoryTotals = categoryData.map { cat in
            let pct = thisTotal > 0 ? (cat.total / thisTotal) * 100 : 0
            return (cat.category, cat.total, pct)
        }

        drawChart()
        tableView.reloadData()
    }

    // MARK: - Draw Bar Chart
    private func drawChart() {
        chartView.subviews.forEach { $0.removeFromSuperview() }
        guard !monthlyData.isEmpty else { return }

        let maxValue = monthlyData.map { $0.total }.max() ?? 1
        let barCount = monthlyData.count
        let spacing: CGFloat = 8

        DispatchQueue.main.async {
            let totalWidth = self.chartView.bounds.width
            let totalHeight = self.chartView.bounds.height
            guard totalWidth > 0, totalHeight > 0 else { return }

            let barWidth = (totalWidth - (spacing * CGFloat(barCount + 1))) / CGFloat(barCount)

            for (i, data) in self.monthlyData.enumerated() {
                let barHeight = maxValue > 0 ?
                    CGFloat(data.total / maxValue) * (totalHeight - 30) : 0

                let x = spacing + CGFloat(i) * (barWidth + spacing)
                let y = totalHeight - 30 - barHeight

                // Bar
                let bar = UIView(frame: CGRect(x: x, y: y, width: barWidth, height: barHeight))
                bar.backgroundColor = AppColors.primary.withAlphaComponent(0.8)
                bar.layer.cornerRadius = 4
                bar.isUserInteractionEnabled = true
                bar.tag = i

                let tap = UITapGestureRecognizer(target: self, action: #selector(self.barTapped(_:)))
                bar.addGestureRecognizer(tap)
                self.chartView.addSubview(bar)

                // Month label
                let label = UILabel(frame: CGRect(x: x, y: totalHeight - 22, width: barWidth, height: 20))
                label.text = data.month
                label.font = UIFont.systemFont(ofSize: 9)
                label.textColor = .secondaryLabel
                label.textAlignment = .center
                self.chartView.addSubview(label)
            }
        }
    }

    @objc private func barTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        selectedMonthIndex = index

        // Highlight selected bar
        for (i, subview) in chartView.subviews.enumerated() {
            if !(subview is UILabel) {
                subview.backgroundColor = i == index ?
                    AppColors.primary :
                    AppColors.primary.withAlphaComponent(0.4)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawChart()
    }
}

// MARK: - TableView
extension MonthlySummaryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryTotals.isEmpty ? 1 : categoryTotals.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "CATEGORY BREAKDOWN"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()

        if categoryTotals.isEmpty {
            config.text = "No expenses this month"
            config.textProperties.color = .secondaryLabel
            config.textProperties.alignment = .center
        } else {
            let row = categoryTotals[indexPath.row]
            config.text = row.category
            config.textProperties.font = UIFont.systemFont(ofSize: 15)

            let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency

            let amount = formatter.string(from: NSNumber(value: row.total)) ?? "$0"
            config.secondaryText = "\(amount) • \(String(format: "%.0f", row.percentage))%"
            config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
            config.secondaryTextProperties.color = AppColors.primary
        }

        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}
