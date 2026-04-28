//
//  RemindersViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/27/26.
//

import UIKit
import UserNotifications

final class RemindersViewController: UIViewController {

    // MARK: - Data
    struct ReminderItem {
        let id: String
        let title: String
        let subtitle: String
    }

    private let activeReminders: [ReminderItem] = [
        ReminderItem(id: "dailyExpenseLog", title: "Daily Expense Log", subtitle: "Every day at 9:00 AM"),
        ReminderItem(id: "weeklySummary", title: "Weekly Summary", subtitle: "Every Sunday at 7:00 PM"),
        ReminderItem(id: "q1Tax", title: "Quarterly Tax Payments", subtitle: "Apr 15 · Jun 15 · Sep 15 · Jan 15"),
        ReminderItem(id: "taxFilingDeadline", title: "Tax Filing Deadline", subtitle: "April 15 — IRS deadline"),
    ]

    private var pendingNotificationIDs: Set<String> = []
    private var customReminders: [(id: String, title: String, date: Date)] = []

    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reminders"
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupLayout()
        loadPendingNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPendingNotifications()
    }

    // MARK: - Nav Bar
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(handleAdd)
        )
        addButton.tintColor = AppColors.primary
        navigationItem.rightBarButtonItem = addButton
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Load Pending
    private func loadPendingNotifications() {
        NotificationManager.shared.fetchPendingNotifications { [weak self] requests in
            self?.pendingNotificationIDs = Set(requests.map { $0.identifier })
            self?.tableView.reloadData()
        }
    }

    // MARK: - Add Custom Reminder
    @objc private func handleAdd() {
        let alert = UIAlertController(
            title: "Add Reminder",
            message: "Set a custom reminder",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "Reminder name"
        }

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: container.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 150),
        ])
        alert.view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 95),
            container.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 150),
            alert.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 60),
        ])

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            guard let name = alert?.textFields?.first?.text, !name.isEmpty else { return }
            let id = "custom_\(UUID().uuidString)"
            NotificationManager.shared.scheduleCustomReminder(
                id: id,
                title: "TaxMate Reminder",
                body: name,
                date: datePicker.date
            )
            self?.customReminders.append((id: id, title: name, date: datePicker.date))
            self?.loadPendingNotifications()

            let confirm = UIAlertController(
                title: "✅ Reminder Set!",
                message: "\"\(name)\" scheduled for \(datePicker.date.formatted(date: .abbreviated, time: .shortened))",
                preferredStyle: .alert
            )
            confirm.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(confirm, animated: true)
        })
        present(alert, animated: true)
    }

    // MARK: - Toggle Reminder
    private func toggleReminder(id: String, isOn: Bool) {
        NotificationManager.shared.requestAuthorization { [weak self] granted in
            guard granted else {
                let alert = UIAlertController(
                    title: "Notifications Disabled",
                    message: "Enable notifications in Settings to use reminders.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
                self?.tableView.reloadData()
                return
            }

            if isOn {
                switch id {
                case "dailyExpenseLog":
                    NotificationManager.shared.scheduleDailyReminder()
                case "weeklySummary":
                    NotificationManager.shared.scheduleWeeklySummary()
                case "q1Tax":
                    NotificationManager.shared.scheduleQuarterlyTaxReminders()
                case "taxFilingDeadline":
                    self?.scheduleTaxDeadline()
                default: break
                }
            } else {
                switch id {
                case "dailyExpenseLog":
                    NotificationManager.shared.removeDailyReminder()
                case "weeklySummary":
                    NotificationManager.shared.removeWeeklySummary()
                case "q1Tax":
                    NotificationManager.shared.removeQuarterlyTaxReminders()
                case "taxFilingDeadline":
                    NotificationManager.shared.removeCustomReminder(id: "taxFilingDeadline")
                default: break
                }
            }
            self?.loadPendingNotifications()
        }
    }

    private func scheduleTaxDeadline() {
        let cal = Calendar.current
        let year = cal.component(.year, from: Date())
        var components = DateComponents()
        components.year = year
        components.month = 4
        components.day = 15
        components.hour = 9
        components.minute = 0
        if let date = cal.date(from: components), date > Date() {
            NotificationManager.shared.scheduleCustomReminder(
                id: "taxFilingDeadline",
                title: "📋 Tax Filing Deadline",
                body: "Federal tax returns are due today (April 15).",
                date: date
            )
        }
    }
}

// MARK: - TableView
extension RemindersViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "ACTIVE REMINDERS" : "RECENT NOTIFICATIONS"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? activeReminders.count : max(customReminders.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        cell.accessoryView = nil

        if indexPath.section == 0 {
            let reminder = activeReminders[indexPath.row]
            config.text = reminder.title
            config.textProperties.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            config.secondaryText = reminder.subtitle
            config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
            config.secondaryTextProperties.color = .secondaryLabel

            let toggle = UISwitch()
            toggle.onTintColor = AppColors.primary
            toggle.tag = indexPath.row

            // Check if reminder is active
            let isActive: Bool
            switch reminder.id {
            case "dailyExpenseLog":
                isActive = pendingNotificationIDs.contains("dailyExpenseLog")
            case "weeklySummary":
                isActive = pendingNotificationIDs.contains("weeklySummary")
            case "q1Tax":
                isActive = pendingNotificationIDs.contains("q1Tax")
            case "taxFilingDeadline":
                isActive = pendingNotificationIDs.contains("taxFilingDeadline")
            default:
                isActive = false
            }
            toggle.isOn = isActive
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle

        } else {
            if customReminders.isEmpty {
                config.text = "No custom reminders yet"
                config.textProperties.color = .secondaryLabel
                config.textProperties.alignment = .center
            } else {
                let reminder = customReminders[indexPath.row]
                config.text = reminder.title
                config.textProperties.font = UIFont.systemFont(ofSize: 15)

                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                config.secondaryText = formatter.string(from: reminder.date)
                config.secondaryTextProperties.color = .secondaryLabel

                // Blue dot for unread
                let dot = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
                dot.backgroundColor = .systemBlue
                dot.layer.cornerRadius = 4
                cell.accessoryView = dot
            }
        }

        cell.contentConfiguration = config
        return cell
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        let reminder = activeReminders[sender.tag]
        toggleReminder(id: reminder.id, isOn: sender.isOn)
    }
}
