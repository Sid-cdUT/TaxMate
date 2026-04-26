//
//  ProfileViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileViewController: UIViewController {

    // MARK: - Properties
    private var userData: [String: Any] = [:]
    private var selectedImage: UIImage?

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        l.textColor = UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let businessLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16)
        l.textColor = .systemGray
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let changePhotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Change Photo", for: .normal)
        b.setTitleColor(.systemGreen, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        return tv
    }()

    // MARK: - Table Sections
    private let sections = ["PERSONAL INFO", "ACCOUNT", "DANGER ZONE"]
    private let personalRows = ["Full Name", "Business Name", "Email", "Business Type"]
    private let accountRows = ["Change Password"]
    private let dangerRows = ["Log Out", "Delete Account"]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = UIColor.systemGray6
        setupLayout()
        setupTableView()
        loadUserData()
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

        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(businessLabel)
        contentView.addSubview(changePhotoButton)
        contentView.addSubview(tableView)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            businessLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            businessLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            businessLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            changePhotoButton.topAnchor.constraint(equalTo: businessLabel.bottomAnchor, constant: 8),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 700),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        changePhotoButton.addTarget(self, action: #selector(handleChangePhoto), for: .touchUpInside)
    }

    // MARK: - Load User Data
    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self.userData = data
                self.nameLabel.text = data["fullName"] as? String ?? "User"
                self.businessLabel.text = data["businessName"] as? String ?? ""
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Change Photo
    @objc private func handleChangePhoto() {
        let sheet = UIAlertController(title: "Change Photo", message: nil, preferredStyle: .actionSheet)
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

    // MARK: - Edit Field
    private func handleEditField(_ field: String, currentValue: String) {
        let alert = UIAlertController(title: "Edit \(field)", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = currentValue
            tf.placeholder = field
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let value = alert?.textFields?.first?.text, !value.isEmpty else { return }
            self?.updateField(field, value: value)
        })
        present(alert, animated: true)
    }

    private func updateField(_ field: String, value: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let key: String
        switch field {
        case "Full Name": key = "fullName"
        case "Business Name": key = "businessName"
        case "Business Type": key = "businessType"
        default: return
        }
        Firestore.firestore().collection("users").document(uid).updateData([key: value]) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    self?.loadUserData()
                }
            }
        }
    }

    // MARK: - Change Password
    private func handleChangePassword() {
        let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "New Password"
            tf.isSecureTextEntry = true
        }
        alert.addTextField { tf in
            tf.placeholder = "Confirm New Password"
            tf.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self, weak alert] _ in
            guard let password = alert?.textFields?.first?.text,
                  let confirm = alert?.textFields?.last?.text,
                  password == confirm, password.count >= 6 else {
                let err = UIAlertController(title: "Error", message: "Passwords don't match or are too short.", preferredStyle: .alert)
                err.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(err, animated: true)
                return
            }
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                DispatchQueue.main.async {
                    let msg = error == nil ? "Password updated successfully!" : error!.localizedDescription
                    let ok = UIAlertController(title: error == nil ? "Success" : "Error", message: msg, preferredStyle: .alert)
                    ok.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ok, animated: true)
                }
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Log Out
    private func handleLogOut() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) {  _ in
            do {
                try Auth.auth().signOut()
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = scene.delegate as? SceneDelegate else { return }
                sceneDelegate.window?.rootViewController = sceneDelegate.makeLoginNavController()
            } catch {
                print("Sign out error: \(error)")
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Delete Account
    private func handleDeleteAccount() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account and all data. This cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) {  _ in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Firestore.firestore().collection("users").document(uid).delete()
            Auth.auth().currentUser?.delete { error in
                DispatchQueue.main.async {
                    if error == nil {
                        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let sceneDelegate = scene.delegate as? SceneDelegate else { return }
                        sceneDelegate.window?.rootViewController = sceneDelegate.makeLoginNavController()
                    }
                }
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return personalRows.count
        case 1: return accountRows.count
        case 2: return dangerRows.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()

        switch indexPath.section {
        case 0:
            let row = personalRows[indexPath.row]
            config.text = row
            switch row {
            case "Full Name": config.secondaryText = userData["fullName"] as? String ?? ""
            case "Business Name": config.secondaryText = userData["businessName"] as? String ?? ""
            case "Email": config.secondaryText = Auth.auth().currentUser?.email ?? ""
            case "Business Type": config.secondaryText = userData["businessType"] as? String ?? ""
            default: break
            }
            cell.accessoryType = .disclosureIndicator
        case 1:
            config.text = accountRows[indexPath.row]
            config.textProperties.color = .systemBlue
            cell.accessoryType = .disclosureIndicator
        case 2:
            let row = dangerRows[indexPath.row]
            config.text = row
            config.textProperties.color = row == "Delete Account" ? .systemRed : .systemOrange
        default: break
        }

        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let row = personalRows[indexPath.row]
            if row == "Email" { return }
            let current = (userData[row == "Full Name" ? "fullName" : row == "Business Name" ? "businessName" : "businessType"] as? String) ?? ""
            handleEditField(row, currentValue: current)
        case 1:
            handleChangePassword()
        case 2:
            if indexPath.row == 0 { handleLogOut() }
            else { handleDeleteAccount() }
        default: break
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let edited = info[.editedImage] as? UIImage {
            profileImageView.image = edited
            profileImageView.tintColor = .clear
        }
    }
}
