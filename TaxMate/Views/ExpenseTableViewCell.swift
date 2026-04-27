//
//  ExpenseTableViewCell.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/27/26.
//

import UIKit

final class ExpenseTableViewCell: UITableViewCell {
    
    static let reuseID = "ExpenseTableViewCell"
    
    // MARK: - UI
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.secondarySystemGroupedBackground
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 1
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let categoryIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let categoryIconBg: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        l.textColor = AppColors.primary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let taxBadge: UILabel = {
        let l = UILabel()
        l.text = "TAX"
        l.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        l.textColor = AppColors.primaryDark
        l.backgroundColor = AppColors.primaryLight
        l.textAlignment = .center
        l.layer.cornerRadius = 4
        l.clipsToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(cardView)
        categoryIconBg.addSubview(categoryIcon)
        cardView.addSubview(categoryIconBg)
        cardView.addSubview(titleLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(amountLabel)
        cardView.addSubview(taxBadge)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            categoryIconBg.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            categoryIconBg.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            categoryIconBg.widthAnchor.constraint(equalToConstant: 36),
            categoryIconBg.heightAnchor.constraint(equalToConstant: 36),
            
            categoryIcon.centerXAnchor.constraint(equalTo: categoryIconBg.centerXAnchor),
            categoryIcon.centerYAnchor.constraint(equalTo: categoryIconBg.centerYAnchor),
            categoryIcon.widthAnchor.constraint(equalToConstant: 18),
            categoryIcon.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: categoryIconBg.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            amountLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            
            taxBadge.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),
            taxBadge.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            taxBadge.widthAnchor.constraint(equalToConstant: 28),
            taxBadge.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
    
    // MARK: - Configure
    func configure(with expense: Expense) {
        titleLabel.text = expense.title
        dateLabel.text = expense.formattedDate
        amountLabel.text = expense.formattedAmount
        taxBadge.isHidden = !expense.isTaxDeductible
        
        // Category icon and color
        switch expense.category {
        case "Travel":
            categoryIconBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            categoryIcon.tintColor = .systemBlue
            categoryIcon.image = UIImage(systemName: "airplane")
        case "Meals":
            categoryIconBg.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            categoryIcon.tintColor = .systemOrange
            categoryIcon.image = UIImage(systemName: "fork.knife")
        case "Supplies":
            categoryIconBg.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            categoryIcon.tintColor = .systemGreen
            categoryIcon.image = UIImage(systemName: "paperclip")
        case "Software":
            categoryIconBg.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
            categoryIcon.tintColor = .systemPurple
            categoryIcon.image = UIImage(systemName: "laptopcomputer")
        default:
            categoryIconBg.backgroundColor = UIColor.systemGray.withAlphaComponent(0.15)
            categoryIcon.tintColor = .systemGray
            categoryIcon.image = UIImage(systemName: "ellipsis.circle")
        }
    }
}
