//
//  NotificationManager.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/26/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    // MARK: - Daily Reminder
    func scheduleDailyReminder() {
        removeDailyReminder()
        let content = UNMutableNotificationContent()
        content.title = "TaxMate Daily Log 💼"
        content.body = "Don't forget to log today's business expenses!"
        content.sound = .default
        
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyExpenseLog", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyExpenseLog"])
    }
    
    // MARK: - Quarterly Tax Reminders
    func scheduleQuarterlyTaxReminders() {
        removeQuarterlyTaxReminders()
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())
        
        let quarters: [(id: String, month: Int, day: Int, label: String)] = [
            ("q1Tax", 4,  15, "Q1 Estimated Tax Payment Due"),
            ("q2Tax", 6,  15, "Q2 Estimated Tax Payment Due"),
            ("q3Tax", 9,  15, "Q3 Estimated Tax Payment Due"),
            ("q4Tax", 1,  15, "Q4 Estimated Tax Payment Due"),
        ]
        
        for q in quarters {
            let content = UNMutableNotificationContent()
            content.title = "⚠️ \(q.label)"
            content.body = "IRS estimated tax payment is due today. Open TaxMate to review your expenses."
            content.sound = .default
            
            var components = DateComponents()
            components.year = currentYear
            components.month = q.month
            components.day = q.day
            components.hour = 9
            components.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: q.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func removeQuarterlyTaxReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["q1Tax", "q2Tax", "q3Tax", "q4Tax"]
        )
    }
    
    // MARK: - Weekly Summary
    func scheduleWeeklySummary() {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Expense Summary 📊"
        content.body = "Review this week's spending and check your tax deductions in TaxMate."
        content.sound = .default
        
        var components = DateComponents()
        components.weekday = 2
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklySummary", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeWeeklySummary() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weeklySummary"])
    }
    
    // MARK: - Custom Reminder
    func scheduleCustomReminder(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeCustomReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
