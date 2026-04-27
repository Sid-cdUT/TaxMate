//
//  Expense.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/26/26.
//

import Foundation
import CoreData

@objc(Expense)
public class Expense: NSManagedObject {
    
}

extension Expense {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var isTaxDeductible: Bool
    @NSManaged public var irsScheduleCategory: String?
    @NSManaged public var receiptImageData: Data?
    @NSManaged public var notes: String?
    @NSManaged public var userID: String?
    
    // MARK: - Computed Properties
    var formattedAmount: String {
        let currency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date ?? Date())
    }
}
