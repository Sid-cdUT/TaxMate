//
//  RegisterViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RegisterViewController: UIViewController {

    private var selectedProfileImage: UIImage?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
        iv.backgroundColor = UIColor.systemGray6
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let selectPhotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("select photo", for: .normal)
        b.setTitleColor(.systemGreen, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let fullNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        return tf
    }()

    private let businessNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Business Name"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        return tf
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.isSecureTextEntry = true
        tf.returnKeyType = .next
        return tf
    }()

    private let confirmPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        return tf
    }()

    private let businessTypeControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Freelance", "LLC", "S-Corp", "Other"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .systemGreen
        return sc
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .systemRed
        l.numberOfLines = 0
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    private let signUpButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Sign Up", for: .normal)
        b.backgroundColor = UIColor.systemGreen
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        b.layer.cornerRadius = 25
        return b
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = UIColor.systemGray6
        navigationController?.navigationBar.isHidden = false
        setupLayout()
        setupActions()
        setupKeyboardHandling()
    }

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

        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOpacity = 1
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let businessTypeLabel = UILabel()
        businessTypeLabel.text = "BUSINESS TYPE"
        businessTypeLabel.font = UIFont.systemFont(ofSize: 11)
        businessTypeLabel.textColor = .systemGray
        businessTypeLabel.translatesAutoresizingMaskIntoConstraints = false

        let accountInfoLabel = UILabel()
        accountInfoLabel.text = "ACCOUNT INFO"
        accountInfoLabel.font = UIFont.systemFont(ofSize: 11)
        accountInfoLabel.textColor = .systemGray
        accountInfoLabel.translatesAutoresizingMaskIntoConstraints = false

        [fullNameField, businessNameField, emailField, passwordField, confirmPasswordField]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        businessTypeControl.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white

        contentView.addSubview(cardView)
        [profileImageView, selectPhotoButton, accountInfoLabel,
         fullNameField, businessNameField, emailField, passwordField,
         confirmPasswordField, businessTypeLabel, businessTypeControl,
         errorLabel, signUpButton, activityIndicator].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            profileImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            selectPhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            selectPhotoButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            accountInfoLabel.topAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: 16),
            accountInfoLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),

            fullNameField.topAnchor.constraint(equalTo: accountInfoLabel.bottomAnchor, constant: 8),
            fullNameField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            fullNameField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            fullNameField.heightAnchor.constraint(equalToConstant: 50),

            businessNameField.topAnchor.constraint(equalTo: fullNameField.bottomAnchor, constant: 8),
            businessNameField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            businessNameField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            businessNameField.heightAnchor.constraint(equalToConstant: 50),

            emailField.topAnchor.constraint(equalTo: businessNameField.bottomAnchor, constant: 8),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 50),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 8),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: 50),

            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            confirmPasswordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            confirmPasswordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),

            businessTypeLabel.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 16),
            businessTypeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),

            businessTypeControl.topAnchor.constraint(equalTo: businessTypeLabel.bottomAnchor, constant: 8),
            businessTypeControl.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            businessTypeControl.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            errorLabel.topAnchor.constraint(equalTo: businessTypeControl.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            signUpButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            signUpButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            signUpButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            signUpButton.heightAnchor.constraint(equalToConstant: 52),

            activityIndicator.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor),

            cardView.bottomAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 32),
            contentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
        ])
    }

    private func setupActions() {
        selectPhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))
        profileImageView.addGestureRecognizer(tap)
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        [fullNameField, businessNameField, emailField, passwordField, confirmPasswordField].forEach {
            $0.delegate = self
        }
    }

    @objc private func handleSelectPhoto() {
        let sheet = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)
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

    @objc private func handleSignUp() {
        guard let fullName = fullNameField.text?.trimmingCharacters(in: .whitespaces), !fullName.isEmpty,
              let businessName = businessNameField.text?.trimmingCharacters(in: .whitespaces), !businessName.isEmpty,
              let email = emailField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            showError("Please fill in all fields.")
            return
        }

        guard password == confirmPassword else {
            showError("Passwords do not match.")
            return
        }

        guard password.count >= 8 else {
            showError("Password must be at least 8 characters.")
            return
        }

        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasNumber = password.contains(where: { $0.isNumber })
        let hasSpecial = password.contains(where: { "!@#$%^&*".contains($0) })

        guard hasUppercase && hasNumber && hasSpecial else {
            showError("Password must contain at least one uppercase letter, one number, and one special character (!@#$%^&*).")
            return
        }
        setLoading(true)

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showError(error.localizedDescription)
                }
                return
            }

            guard let user = result?.user else { return }
            let businessTypes = ["Freelance", "LLC", "S-Corp", "Other"]
            let businessType = businessTypes[self.businessTypeControl.selectedSegmentIndex]

            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "uid": user.uid,
                "email": email,
                "fullName": fullName,
                "businessName": businessName,
                "businessType": businessType,
                "createdAt": FieldValue.serverTimestamp()
            ]) { error in
                DispatchQueue.main.async {
                    self.setLoading(false)
                    if let error = error {
                        self.showError(error.localizedDescription)
                    } else {
                        self.navigateToMain()
                    }
                }
            }
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func setLoading(_ loading: Bool) {
        signUpButton.isEnabled = !loading
        signUpButton.alpha = loading ? 0.5 : 1
        if loading { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
    }

    private func navigateToMain() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = scene.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.rootViewController = sceneDelegate.makeMainTabBar()
    }

    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let fields = [fullNameField, businessNameField, emailField, passwordField, confirmPasswordField]
        if let index = fields.firstIndex(of: textField), index < fields.count - 1 {
            fields[index + 1].becomeFirstResponder()
        } else {
            handleSignUp()
        }
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let edited = info[.editedImage] as? UIImage {
            selectedProfileImage = edited
            profileImageView.image = edited
            profileImageView.tintColor = .clear
        }
    }
}
