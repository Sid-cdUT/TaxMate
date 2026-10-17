# TaxMate 📊

TaxMate is a full-stack, native iOS financial tracking platform designed specifically for freelancers and small business owners to streamline expense auditing and simplify tax season organization.

## 🚀 Key Features

* **Expense Auditing:** Real-time expense capturing and categorization aligned explicitly with standard IRS Schedule C categories.
* **Persistent Local Storage:** Structured data persistence utilizing Apple’s native Core Data framework for secure, offline-first reliability.
* **Cloud Authentication:** Lightweight and secure user identity management powered by Firebase Authentication.
* **Financial Summaries:** Automated tax-deductible summation pipelines that compile customizable, clean financial reports.
* **Modern UI Experience:** Fluid user interface supporting seamless Dark Mode transitions, haptic feedback integration, and dynamic multi-currency properties.

## 🛠️ Technical Stack

* **Language:** Swift 100%
* **Frameworks:** UIKit/SwiftUI, Core Data, Firebase Auth
* **Architecture:** MVC/MVVM Design Patterns
* **Development Tools:** Xcode, Git

## 📂 Architecture Overview

* `TaxMate.xcodeproj`: Core compilation parameters and app build settings.
* `TaxMate/`: Application source directory containing view controllers, state persistence logic, and IRS transactional schemas.
* `Reminder+CoreDataProperties.swift`: Core Data extension files managing structural database entities for user push alerts and automated haptic reminder states.
