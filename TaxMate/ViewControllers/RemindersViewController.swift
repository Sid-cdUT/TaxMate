//
//  RemindersViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/27/26.
//

import UIKit
import UserNotifications

final class RemindersViewController: UIViewController {

    // MARK: - Data Models

    struct ReminderItem {
        let id: String
        let title: String
        let subtitle: String
    }

    struct CustomReminder: Codable {
        let id: String
        let title: String
        let date: Date
    }

    // MARK: - Stored Data

    private let activeReminders: [ReminderItem] = [
        ReminderItem(id: "dailyExpenseLog", title: "Daily Expense Log", subtitle: "Every day at 9:00 AM"),
        ReminderItem(id: "weeklySummary", title: "Weekly Summary", subtitle: "Every Sunday at 7:00 PM"),
        ReminderItem(id: "q1Tax", title: "Quarterly Tax Payments", subtitle: "Apr 15 · Jun 15 · Sep 15 · Jan 15"),
        ReminderItem(id: "taxFilingDeadline", title: "Tax Filing Deadline", subtitle: "April 15 — IRS deadline")
    ]

    private var pendingNotificationIDs: Set<String> = []
    private var customReminders: [CustomReminder] = []

    private let remindersKey = "customReminders"

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
        loadCustomRemindersFromStorage()
        tableView.reloadData()
    }

    // MARK: - UserDefaults Storage

    private func saveCustomReminders() {
        if let data = try? JSONEncoder().encode(customReminders) {
            UserDefaults.standard.set(data, forKey: remindersKey)
        }
    }

    private func loadCustomRemindersFromStorage() {
        if let data = UserDefaults.standard.data(forKey: remindersKey),
           let saved = try? JSONDecoder().decode([CustomReminder].self, from: data) {
            customReminders = saved
        } else {
            customReminders = []
        }
    }

    // MARK: - Clear Expired Reminders

    private func clearExpiredReminders() {
        let now = Date()
        
        // Find expired reminders first
        let expired = customReminders.filter { $0.date < now }
        let before = customReminders.count

        // Remove them from the in-memory list
        customReminders.removeAll { $0.date < now }
        saveCustomReminders()

        // Cancel their notifications
        for reminder in expired {
            NotificationManager.shared.removeCustomReminder(id: reminder.id)
        }

        let removed = before - customReminders.count

        let alert = UIAlertController(
            title: "Expired Reminders Cleared",
            message: removed == 0
                ? "No expired reminders to remove."
                : "\(removed) expired reminder(s) removed.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        // Refresh pending IDs and UI
        loadPendingNotifications()
        tableView.reloadData()
    }


    // MARK: - Nav Bar

    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleAdd)
        )
        addButton.tintColor = AppColors.primary

        let clearButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(handleClearExpired)
        )
        clearButton.tintColor = .systemRed

        navigationItem.rightBarButtonItems = [addButton, clearButton]
    }

    @objc private func handleClearExpired() {
        clearExpiredReminders()
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

    // MARK: - Load Pending Notifications

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
            guard let name = alert?.textFields?.first?.text,
                  !name.trimmingCharacters(in: .whitespaces).isEmpty else {

                let error = UIAlertController(
                    title: "Title Required",
                    message: "Please enter a name for your reminder.",
                    preferredStyle: .alert
                )
                error.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(error, animated: true)
                return
            }

            let id = "custom_\(UUID().uuidString)"
            let date = datePicker.date

            NotificationManager.shared.scheduleCustomReminder(
                id: id,
                title: "TaxMate Reminder",
                body: name,
                date: date
            )

            let newReminder = CustomReminder(id: id, title: name, date: date)
            self?.customReminders.append(newReminder)
            self?.saveCustomReminders()

            self?.tableView.reloadData()

            let confirm = UIAlertController(
                title: "✅ Reminder Set!",
                message: "\"\(name)\" scheduled for \(date.formatted(date: .abbreviated, time: .shortened))",
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
        section == 0 ? "ACTIVE REMINDERS" : "CUSTOM REMINDERS"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? activeReminders.count : max(customReminders.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        cell.accessoryView = nil
        cell.selectionStyle = .none

        if indexPath.section == 0 {
            let reminder = activeReminders[indexPath.row]
            config.text = reminder.title
            config.textProperties.font = .systemFont(ofSize: 15, weight: .semibold)
            config.secondaryText = reminder.subtitle
            config.secondaryTextProperties.font = .systemFont(ofSize: 12)
            config.secondaryTextProperties.color = .secondaryLabel

            let toggle = UISwitch()
            toggle.onTintColor = AppColors.primary
            toggle.accessibilityIdentifier = reminder.id
            toggle.isOn = pendingNotificationIDs.contains(reminder.id)
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
                config.textProperties.font = .systemFont(ofSize: 15)

                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                config.secondaryText = formatter.string(from: reminder.date)
                config.secondaryTextProperties.color = .secondaryLabel

                let dot = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
                dot.backgroundColor = .systemBlue
                dot.layer.cornerRadius = 4
                cell.accessoryView = dot
            }
        }

        cell.contentConfiguration = config
        return cell
    }

    // MARK: - Swipe to Delete

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if indexPath.section == 1,
           editingStyle == .delete,
           !customReminders.isEmpty {

            let reminder = customReminders[indexPath.row]

            customReminders.remove(at: indexPath.row)
            saveCustomReminders()
            NotificationManager.shared.removeCustomReminder(id: reminder.id)
            loadPendingNotifications()
            tableView.reloadData()
        }
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        guard let id = sender.accessibilityIdentifier else { return }
        toggleReminder(id: id, isOn: sender.isOn)
    }
}

