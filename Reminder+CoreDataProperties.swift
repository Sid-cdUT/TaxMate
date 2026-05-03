//
//  Reminder+CoreDataProperties.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/27/26.
//
//

public import Foundation
public import CoreData


public typealias ReminderCoreDataPropertiesSet = NSSet

extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var createdAt: Date?

}

extension Reminder : Identifiable {

}
