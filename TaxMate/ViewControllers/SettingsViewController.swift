//
//  SettingsViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit
import FirebaseAuth

final class SettingsViewController: UIViewController {

    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let sections = ["APPEARANCE", "REGIONAL", "TAX", "NOTIFICATIONS"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = AppColors.background
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Dark Mode
    private func setDarkMode(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "darkModeEnabled")
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        window.overrideUserInterfaceStyle = enabled ? .dark : .light
    }
    
    // MARK: - Currency Picker
    private func showCurrencyPicker() {
        let currencies = ["USD 🇺🇸", "EUR 🇪🇺", "GBP 🇬🇧", "MXN 🇲🇽", "CAD 🇨🇦", "JPY 🇯🇵"]
        let currencyCodes = ["USD", "EUR", "GBP", "MXN", "CAD", "JPY"]
        
        let alert = UIAlertController(title: "Default Currency", message: nil, preferredStyle: .actionSheet)
        
        for (index, currency) in currencies.enumerated() {
            alert.addAction(UIAlertAction(title: currency, style: .default) { _ in
                UserDefaults.standard.set(currencyCodes[index], forKey: "defaultCurrency")
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Tax Year Picker
    private func showTaxYearPicker() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = ["\(currentYear - 2)", "\(currentYear - 1)", "\(currentYear)"]
        let alert = UIAlertController(title: "Tax Year", message: nil, preferredStyle: .actionSheet)
        for year in years {
            alert.addAction(UIAlertAction(title: year, style: .default) { _ in
                UserDefaults.standard.set(year, forKey: "taxYear")
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Notifications
    private func scheduleDailyReminder(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "dailyReminderEnabled")
        if enabled {
            NotificationManager.shared.scheduleDailyReminder()
        } else {
            NotificationManager.shared.removeDailyReminder()
        }
    }
    
    private func scheduleQuarterlyReminders(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "quarterlyTaxEnabled")
        if enabled {
            NotificationManager.shared.scheduleQuarterlyTaxReminders()
        } else {
            NotificationManager.shared.removeQuarterlyTaxReminders()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2  // Dark Mode, App Theme
        case 1: return 2  // Currency, Tax Jurisdiction
        case 2: return 2  // Tax Year, Auto-mark Deductible
        case 3: return 2  // Daily Reminder, Quarterly Tax
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        switch indexPath.section {
        case 0: // APPEARANCE
            if indexPath.row == 0 {
                config.text = "Dark Mode"
                config.secondaryText = "Apply dark color scheme app-wide"
                let toggle = UISwitch()
                toggle.isOn = UserDefaults.standard.bool(forKey: "darkModeEnabled")
                toggle.onTintColor = AppColors.primary
                toggle.addTarget(self, action: #selector(darkModeToggled(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            } else {
                config.text = "App Icon"
                config.secondaryText = "Default"
                cell.accessoryType = .disclosureIndicator
            }
            
        case 1: // REGIONAL
            if indexPath.row == 0 {
                let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
                config.text = "Default Currency"
                config.secondaryText = currency
                cell.accessoryType = .disclosureIndicator
            } else {
                config.text = "Tax Jurisdiction"
                config.secondaryText = "United States"
                cell.accessoryType = .disclosureIndicator
            }
            
        case 2: // TAX
            if indexPath.row == 0 {
                let currentYear = Calendar.current.component(.year, from: Date())
                let year = UserDefaults.standard.string(forKey: "taxYear") ?? "\(currentYear)"
                config.text = "Tax Year"
                config.secondaryText = year
                cell.accessoryType = .disclosureIndicator
            } else {
                config.text = "Auto-mark as Deductible"
                config.secondaryText = "Pre-check deductible on new expenses"
                let toggle = UISwitch()
                toggle.isOn = UserDefaults.standard.bool(forKey: "autoMarkDeductible")
                toggle.onTintColor = AppColors.primary
                toggle.addTarget(self, action: #selector(autoMarkToggled(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            }
            
        case 3: // NOTIFICATIONS
            if indexPath.row == 0 {
                config.text = "Daily Expense Reminder"
                config.secondaryText = "Every day at 9:00 AM"
                let toggle = UISwitch()
                toggle.isOn = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
                toggle.onTintColor = AppColors.primary
                toggle.addTarget(self, action: #selector(dailyReminderToggled(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            } else {
                config.text = "Quarterly Tax Reminders"
                config.secondaryText = "Apr 15, Jun 15, Sep 15, Jan 15"
                let toggle = UISwitch()
                toggle.isOn = UserDefaults.standard.bool(forKey: "quarterlyTaxEnabled")
                toggle.onTintColor = AppColors.primary
                toggle.addTarget(self, action: #selector(quarterlyToggled(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            }
            
        default: break
        }
        
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 { showCurrencyPicker() }
        case 2:
            if indexPath.row == 0 { showTaxYearPicker() }
        case 3:
            // Navigate to Reminders screen
            let vc = RemindersViewController()
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    // MARK: - Toggle Actions
    @objc private func darkModeToggled(_ sender: UISwitch) {
        setDarkMode(sender.isOn)
    }
    
    @objc private func autoMarkToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "autoMarkDeductible")
    }
    
    @objc private func dailyReminderToggled(_ sender: UISwitch) {
        if sender.isOn {
            NotificationManager.shared.requestAuthorization { granted in
                if !granted {
                    sender.isOn = false
                    let alert = UIAlertController(
                        title: "Notifications Disabled",
                        message: "Please enable notifications in Settings to use reminders.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    self.scheduleDailyReminder(true)
                }
            }
        } else {
            scheduleDailyReminder(false)
        }
    }
    
    @objc private func quarterlyToggled(_ sender: UISwitch) {
        if sender.isOn {
            NotificationManager.shared.requestAuthorization { granted in
                if !granted {
                    sender.isOn = false
                } else {
                    self.scheduleQuarterlyReminders(true)
                }
            }
        } else {
            scheduleQuarterlyReminders(false)
        }
    }
}
