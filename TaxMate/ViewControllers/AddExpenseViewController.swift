//
//  AddExpenseViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/26/26.
//

import UIKit
import FirebaseAuth

final class AddExpenseViewController: UIViewController {

    // MARK: - Properties
    var expenseToEdit: Expense?
    private var selectedReceiptImage: UIImage?

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Expense title"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.returnKeyType = .next
        return tf
    }()

    private let amountField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "$ 0.00"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.keyboardType = .decimalPad
        return tf
    }()

    private let categoryControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Travel", "Meals", "Supplies", "Software", "Other"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = AppColors.primary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return sc
    }()

    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.tintColor = AppColors.primary
        return dp
    }()

    private let taxDeductibleSwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = AppColors.primary
        s.isOn = UserDefaults.standard.bool(forKey: "autoMarkDeductible")
        return s
    }()

    private let irsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Select IRS Category →", for: .normal)
        b.setTitleColor(AppColors.primary, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.contentHorizontalAlignment = .left
        return b
    }()

    private var selectedIRSCategory: String?

    private let receiptImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.systemGray6
        iv.image = UIImage(systemName: "photo")
        iv.tintColor = .systemGray3
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let attachReceiptButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("📎  Attach Receipt", for: .normal)
        b.setTitleColor(AppColors.primary, for: .normal)
        return b
    }()

    private let notesView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = UIColor.systemGray6
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return tv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupLayout()
        setupActions()
        populateIfEditing()
        setupKeyboardHandling()
    }

    // MARK: - Nav Bar
    private func setupNavigationBar() {
        title = expenseToEdit == nil ? "Add Expense" : "Edit Expense"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain, target: self, action: #selector(handleCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(handleSave)
        )
        navigationItem.rightBarButtonItem?.tintColor = AppColors.primary
    }

    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        func sectionLabel(_ text: String) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            l.textColor = .secondaryLabel
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }

        let detailsLabel = sectionLabel("DETAILS")
        let categoryLabel = sectionLabel("CATEGORY")
        let dateLabel = sectionLabel("DATE")
        let taxLabel = sectionLabel("TAX")
        let receiptLabel = sectionLabel("RECEIPT")
        let notesLabel = sectionLabel("NOTES")

        let taxRow = makeRow(left: "Tax Deductible", right: taxDeductibleSwitch)
        let irsRow = makeRow(left: "IRS Schedule C", right: irsButton)
        let dateRow = makeRow(left: "Date", right: datePicker)

        [titleField, amountField, categoryControl, receiptImageView,
         attachReceiptButton, notesView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [taxRow, irsRow, dateRow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [detailsLabel, titleField, amountField, categoryLabel, categoryControl,
         dateLabel, dateRow, taxLabel, taxRow, irsRow,
         receiptLabel, receiptImageView, attachReceiptButton,
         notesLabel, notesView].forEach { contentView.addSubview($0) }

        let p: CGFloat = 16

        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            detailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),

            titleField.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 8),
            titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            titleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            titleField.heightAnchor.constraint(equalToConstant: 50),

            amountField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 8),
            amountField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            amountField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            amountField.heightAnchor.constraint(equalToConstant: 50),

            categoryLabel.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),

            categoryControl.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categoryControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            categoryControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            dateLabel.topAnchor.constraint(equalTo: categoryControl.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),

            dateRow.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            dateRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            dateRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            dateRow.heightAnchor.constraint(equalToConstant: 50),

            taxLabel.topAnchor.constraint(equalTo: dateRow.bottomAnchor, constant: 20),
            taxLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),

            taxRow.topAnchor.constraint(equalTo: taxLabel.bottomAnchor, constant: 8),
            taxRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            taxRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            taxRow.heightAnchor.constraint(equalToConstant: 50),

            irsRow.topAnchor.constraint(equalTo: taxRow.bottomAnchor, constant: 8),
            irsRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            irsRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            irsRow.heightAnchor.constraint(equalToConstant: 50),

            receiptLabel.topAnchor.constraint(equalTo: irsRow.bottomAnchor, constant: 20),
            receiptLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),

            receiptImageView.topAnchor.constraint(equalTo: receiptLabel.bottomAnchor, constant: 8),
            receiptImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            receiptImageView.widthAnchor.constraint(equalToConstant: 120),
            receiptImageView.heightAnchor.constraint(equalToConstant: 90),

            attachReceiptButton.topAnchor.constraint(equalTo: receiptImageView.bottomAnchor, constant: 8),
            attachReceiptButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            notesLabel.topAnchor.constraint(equalTo: attachReceiptButton.bottomAnchor, constant: 20),
            notesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),

            notesView.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 8),
            notesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            notesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            notesView.heightAnchor.constraint(equalToConstant: 80),

            contentView.bottomAnchor.constraint(equalTo: notesView.bottomAnchor, constant: 32),
        ])
    }

    private func makeRow(left: String, right: UIView) -> UIView {
        let row = UIView()
        row.backgroundColor = UIColor.systemGray6
        row.layer.cornerRadius = 8
        row.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        right.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(label)
        row.addSubview(right)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            right.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -12),
            right.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    // MARK: - Populate for editing
    private func populateIfEditing() {
        guard let expense = expenseToEdit else { return }
        titleField.text = expense.title
        amountField.text = String(format: "%.2f", expense.amount)
        datePicker.date = expense.date ?? Date()
        taxDeductibleSwitch.isOn = expense.isTaxDeductible

        let categories = ["Travel", "Meals", "Supplies", "Software", "Other"]
        if let cat = expense.category,
           let index = categories.firstIndex(of: cat) {
            categoryControl.selectedSegmentIndex = index
        }
        if let irsCategory = expense.irsScheduleCategory {
            selectedIRSCategory = irsCategory
            irsButton.setTitle(irsCategory, for: .normal)
        }
        if let data = expense.receiptImageData {
            receiptImageView.image = UIImage(data: data)
        }
        notesView.text = expense.notes
    }

    // MARK: - Actions
    private func setupActions() {
        attachReceiptButton.addTarget(self, action: #selector(handleAttachReceipt), for: .touchUpInside)
        irsButton.addTarget(self, action: #selector(handleIRSPicker), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAttachReceipt))
        receiptImageView.addGestureRecognizer(tap)
        titleField.delegate = self
        amountField.delegate = self
    }

    @objc private func handleCancel() {
        dismiss(animated: true)
    }

    @objc private func handleSave() {
        guard let title = titleField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter an expense title.")
            return
        }
        guard let amountText = amountField.text,
              let amount = Double(amountText), amount >= 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid amount.")
            return
        }

        let categories = ["Travel", "Meals", "Supplies", "Software", "Other"]
        let category = categories[categoryControl.selectedSegmentIndex]
        let date = datePicker.date
        let isTaxDeductible = taxDeductibleSwitch.isOn
        let receiptData = selectedReceiptImage?.jpegData(compressionQuality: 0.7)
        let notes = notesView.text
        let userID = Auth.auth().currentUser?.uid ?? ""

        if let expense = expenseToEdit {
            CoreDataManager.shared.updateExpense(
                expense,
                title: title,
                amount: amount,
                category: category,
                date: date,
                isTaxDeductible: isTaxDeductible,
                irsScheduleCategory: selectedIRSCategory,
                receiptImageData: receiptData,
                notes: notes
            )
        } else {
            _ = CoreDataManager.shared.createExpense(
                title: title,
                amount: amount,
                category: category,
                date: date,
                isTaxDeductible: isTaxDeductible,
                irsScheduleCategory: selectedIRSCategory,
                receiptImageData: receiptData,
                notes: notes,
                userID: userID
            )
        }
        dismiss(animated: true)
    }

    @objc private func handleAttachReceipt() {
        let sheet = UIAlertController(title: "Receipt Photo", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.presentPicker(source: .camera)
            })
        }
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentPicker(source: .photoLibrary)
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func presentPicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func handleIRSPicker() {
        let categories = [
            "Advertising", "Car & Truck", "Commissions", "Contract Labor",
            "Insurance", "Legal & Professional", "Office Expense",
            "Rent or Lease", "Repairs & Maintenance", "Supplies",
            "Taxes & Licenses", "Travel", "Meals & Entertainment",
            "Utilities", "Wages", "Other"
        ]
        let alert = UIAlertController(title: "IRS Schedule C", message: nil, preferredStyle: .actionSheet)
        for cat in categories {
            alert.addAction(UIAlertAction(title: cat, style: .default) { [weak self] _ in
                self?.selectedIRSCategory = cat
                self?.irsButton.setTitle(cat, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        scrollView.contentInset.bottom = 0
    }
}

// MARK: - UITextFieldDelegate
extension AddExpenseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField { amountField.becomeFirstResponder() }
        else { textField.resignFirstResponder() }
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddExpenseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let edited = info[.editedImage] as? UIImage {
            selectedReceiptImage = edited
            receiptImageView.image = edited
            receiptImageView.tintColor = .clear
        }
    }
}
