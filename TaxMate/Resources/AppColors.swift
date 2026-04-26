//
//  AppColors.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/26/26.
//

import UIKit

struct AppColors {
    // Primary
    static let primary = UIColor(red: 0.13, green: 0.73, blue: 0.52, alpha: 1)      // TaxMate Green
    static let primaryDark = UIColor(red: 0.05, green: 0.55, blue: 0.38, alpha: 1)  // Dark Green
    static let primaryLight = UIColor(red: 0.85, green: 0.97, blue: 0.92, alpha: 1) // Light Green
    
    // Navy
    static let navy = UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1)
    
    // Background
    static let background = UIColor.systemGroupedBackground
    static let card = UIColor.secondarySystemGroupedBackground
    
    // Text
    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
    
    // Accents
    static let danger = UIColor.systemRed
    static let warning = UIColor.systemOrange
    static let blue = UIColor.systemBlue
}

struct AppFonts {
    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    static func semibold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    static func mono(_ size: CGFloat) -> UIFont {
        return UIFont.monospacedDigitSystemFont(ofSize: size, weight: .semibold)
    }
}

