//
//  CoreDataManager.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/26/26.
//

import CoreData
import Foundation

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaxMate")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Save
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("CoreData save error: \(error)")
            }
        }
    }
    
    // MARK: - Create Expense
    func createExpense(
        title: String,
        amount: Double,
        category: String,
        date: Date,
        isTaxDeductible: Bool,
        irsScheduleCategory: String?,
        receiptImageData: Data?,
        notes: String?,
        userID: String
    ) -> Expense {
        let expense = Expense(context: viewContext)
        expense.id = UUID()
        expense.title = title
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.isTaxDeductible = isTaxDeductible
        expense.irsScheduleCategory = irsScheduleCategory
        expense.receiptImageData = receiptImageData
        expense.notes = notes
        expense.userID = userID
        saveContext()
        return expense
    }
    
    // MARK: - Fetch Expenses
    func fetchExpenses(userID: String) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userID)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Deductible Expenses
    func fetchDeductibleExpenses(userID: String, year: Int? = nil) -> [Expense] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        var predicates: [NSPredicate] = [
            NSPredicate(format: "userID == %@", userID),
            NSPredicate(format: "isTaxDeductible == YES")
        ]
        if let year = year {
            let cal = Calendar.current
            var start = DateComponents()
            start.year = year
            start.month = 1
            start.day = 1
            var end = DateComponents()
            end.year = year
            end.month = 12
            end.day = 31
            if let s = cal.date(from: start), let e = cal.date(from: end) {
                predicates.append(NSPredicate(format: "date >= %@ AND date <= %@", s as NSDate, e as NSDate))
            }
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    // MARK: - Update Expense
    func updateExpense(
        _ expense: Expense,
        title: String,
        amount: Double,
        category: String,
        date: Date,
        isTaxDeductible: Bool,
        irsScheduleCategory: String?,
        receiptImageData: Data?,
        notes: String?
    ) {
        expense.title = title
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.isTaxDeductible = isTaxDeductible
        expense.irsScheduleCategory = irsScheduleCategory
        if let data = receiptImageData {
            expense.receiptImageData = data
        }
        expense.notes = notes
        saveContext()
    }
    
    // MARK: - Delete Expense
    func deleteExpense(_ expense: Expense) {
        viewContext.delete(expense)
        saveContext()
    }
    
    // MARK: - Total Amount
    func totalAmount(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Amount By Category
    func amountByCategory(expenses: [Expense]) -> [(category: String, total: Double)] {
        var dict: [String: Double] = [:]
        for expense in expenses {
            let cat = expense.category ?? "Other"
            dict[cat, default: 0] += expense.amount
        }
        return dict.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
    }
    
    // MARK: - Monthly Totals
    func monthlyTotals(userID: String, months: Int = 7) -> [(month: String, total: Double)] {
        var results: [(String, Double)] = []
        let cal = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        for i in (0..<months).reversed() {
            guard let start = cal.date(byAdding: .month, value: -i, to: now),
                  let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: start)),
                  let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart)
            else { continue }
            
            let request: NSFetchRequest<Expense> = Expense.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "userID == %@", userID),
                NSPredicate(format: "date >= %@ AND date < %@", monthStart as NSDate, monthEnd as NSDate)
            ])
            let expenses = (try? viewContext.fetch(request)) ?? []
            let total = expenses.reduce(0) { $0 + $1.amount }
            results.append((formatter.string(from: start), total))
        }
        return results
    }
}
