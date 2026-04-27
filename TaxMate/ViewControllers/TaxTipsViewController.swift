//
//  TaxTipsViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/27/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class TaxTipsViewController: UIViewController {

    // MARK: - Data
    struct TaxTip {
        let title: String
        let description: String
        let estimatedSavings: String
        let applicableTo: [String]
    }

    private let allTips: [TaxTip] = [
        TaxTip(title: "Home Office Deduction",
               description: "Deduct $5 per sq ft of dedicated workspace up to 300 sq ft using the simplified method.",
               estimatedSavings: "Up to $1,500/year",
               applicableTo: ["Freelance", "LLC", "S-Corp", "Other"]),
        TaxTip(title: "Vehicle & Mileage",
               description: "Deduct $0.70 per business mile driven. Keep a mileage log for every business trip.",
               estimatedSavings: "Varies",
               applicableTo: ["Freelance", "LLC", "S-Corp", "Other"]),
        TaxTip(title: "Phone & Internet",
               description: "Deduct the business-use percentage of your phone and internet bills.",
               estimatedSavings: "Up to $1,200/year",
               applicableTo: ["Freelance", "LLC", "S-Corp", "Other"]),
        TaxTip(title: "Education & Training",
               description: "Courses, books, and conferences that maintain or improve skills in your current trade.",
               estimatedSavings: "100% deductible",
               applicableTo: ["Freelance", "LLC", "S-Corp", "Other"]),
        TaxTip(title: "Health Insurance Premiums",
               description: "Self-employed individuals can deduct 100% of health insurance premiums for themselves and family.",
               estimatedSavings: "100% deductible",
               applicableTo: ["Freelance", "LLC", "Other"]),
        TaxTip(title: "SEP-IRA Contributions",
               description: "Contribute up to 25% of net self-employment income (max $70,000 for 2026) to a SEP-IRA.",
               estimatedSavings: "Up to $70,000/year",
               applicableTo: ["Freelance", "LLC", "Other"]),
        TaxTip(title: "Meals (50% Deductible)",
               description: "Business meals with clients or team are 50% deductible. Keep receipts and note the business purpose.",
               estimatedSavings: "50% of meal costs",
               applicableTo: ["Freelance", "LLC", "S-Corp", "Other"]),
        TaxTip(title: "Reasonable Salary Strategy",
               description: "Pay yourself a reasonable salary to minimize self-employment taxes on S-Corp distributions.",
               estimatedSavings: "Significant SE tax savings",
               applicableTo: ["S-Corp"]),
        TaxTip(title: "Qualified Business Income (QBI)",
               description: "Deduct up to 20% of qualified business income from pass-through entities.",
               estimatedSavings: "Up to 20% of QBI",
               applicableTo: ["Freelance", "LLC", "S-Corp"]),
        TaxTip(title: "Software & Subscriptions",
               description: "Business software, apps, and subscriptions are fully deductible as business expenses.",
               estimatedSavings: "100% deductible",
               applicableTo: ["Freelance", "LLC", "S-Corp", "Other"]),
    ]

    private var filteredTips: [TaxTip] = []
    private var businessType: String = "Freelance"

    // MARK: - UI
    private let filterControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Freelance", "LLC", "S-Corp", "Other"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = AppColors.primary
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "tipCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let quarterlyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("🗓  Set Up Quarterly Tax Reminders", for: .normal)
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
        title = "Tax Saving Tips"
        view.backgroundColor = AppColors.background
        setupLayout()
        loadBusinessType()
    }

    // MARK: - Layout
    private func setupLayout() {
        let disclaimerLabel: UILabel = {
            let l = UILabel()
            l.text = "⚠️ For informational purposes only. Consult a tax professional for personalized advice."
            l.font = UIFont.systemFont(ofSize: 11)
            l.textColor = .secondaryLabel
            l.numberOfLines = 0
            l.textAlignment = .center
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }()

        view.addSubview(filterControl)
        view.addSubview(tableView)
        view.addSubview(quarterlyButton)
        view.addSubview(disclaimerLabel)

        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            filterControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            filterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            quarterlyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            quarterlyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            quarterlyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            quarterlyButton.heightAnchor.constraint(equalToConstant: 52),

            tableView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: quarterlyButton.topAnchor, constant: -8),
            
            disclaimerLabel.topAnchor.constraint(equalTo: quarterlyButton.bottomAnchor, constant: 8),
            disclaimerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            disclaimerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        quarterlyButton.addTarget(self, action: #selector(handleQuarterlyReminder), for: .touchUpInside)
    }

    // MARK: - Load Business Type
    private func loadBusinessType() {
        guard let userID = Auth.auth().currentUser?.uid else {
            applyFilter()
            return
        }
        Firestore.firestore().collection("users").document(userID).getDocument { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                let type = snapshot?.data()?["businessType"] as? String ?? "Freelance"
                self?.businessType = type
                let types = ["Freelance", "LLC", "S-Corp", "Other"]
                if let index = types.firstIndex(of: type) {
                    self?.filterControl.selectedSegmentIndex = index
                }
                self?.applyFilter()
            }
        }
    }

    @objc private func filterChanged() {
        let types = ["Freelance", "LLC", "S-Corp", "Other"]
        businessType = types[filterControl.selectedSegmentIndex]
        applyFilter()
    }

    private func applyFilter() {
        filteredTips = allTips.filter { $0.applicableTo.contains(businessType) }
        tableView.reloadData()
    }

    @objc private func handleQuarterlyReminder() {
        NotificationManager.shared.requestAuthorization { [weak self] granted in
            if granted {
                NotificationManager.shared.scheduleQuarterlyTaxReminders()
                let alert = UIAlertController(
                    title: "✅ Reminders Set!",
                    message: "You'll be reminded on Apr 15, Jun 15, Sep 15, and Jan 15 to pay your estimated taxes.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Great!", style: .default))
                self?.present(alert, animated: true)
            } else {
                let alert = UIAlertController(
                    title: "Notifications Disabled",
                    message: "Please enable notifications in Settings to receive tax reminders.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}

// MARK: - TableView
extension TaxTipsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTips.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "DEDUCTIONS YOU MAY QUALIFY FOR"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tipCell", for: indexPath)
        let tip = filteredTips[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = tip.title
        config.textProperties.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        config.secondaryText = "\(tip.description)\n💰 \(tip.estimatedSavings)"
        config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tip = filteredTips[indexPath.row]
        let alert = UIAlertController(
            title: tip.title,
            message: "\(tip.description)\n\nEstimated Savings: \(tip.estimatedSavings)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it!", style: .default))
        present(alert, animated: true)
    }
}
