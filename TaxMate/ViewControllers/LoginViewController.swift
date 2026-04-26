//
//  LoginViewController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "dollarsign.circle.fill")
        iv.tintColor = UIColor.systemGreen
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let appTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "TaxMate"
        l.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        l.textColor = UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Sign in to continue"
        l.font = UIFont.systemFont(ofSize: 16)
        l.textColor = .systemGray
        l.textAlignment = .center
        return l
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.returnKeyType = .done
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.systemGray6
        return tf
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

    private let loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Log In", for: .normal)
        b.backgroundColor = UIColor.systemGreen
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        b.layer.cornerRadius = 25
        return b
    }()

    private let forgotPasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Forgot Password?", for: .normal)
        b.setTitleColor(.systemGray, for: .normal)
        return b
    }()

    private let createAccountButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Create Account", for: .normal)
        b.setTitleColor(.systemGreen, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return b
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
        setupLayout()
        setupActions()
        setupKeyboardHandling()
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

        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOpacity = 1
        cardView.translatesAutoresizingMaskIntoConstraints = false

        [appTitleLabel, subtitleLabel, emailField, passwordField,
         errorLabel, loginButton, forgotPasswordButton, createAccountButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .systemGreen

        contentView.addSubview(logoImageView)
        contentView.addSubview(appTitleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(cardView)

        cardView.addSubview(emailField)
        cardView.addSubview(passwordField)
        cardView.addSubview(errorLabel)
        cardView.addSubview(loginButton)
        cardView.addSubview(forgotPasswordButton)
        cardView.addSubview(createAccountButton)
        cardView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 48),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 72),

            appTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            appTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            emailField.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 50),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: 50),

            errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 52),

            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),

            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            createAccountButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 8),
            createAccountButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            createAccountButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),

            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
    }

    @objc private func handleLogin() {
        guard let email = emailField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showError("Please enter your email and password.")
            return
        }
        setLoading(true)
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                if let error = error {
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .wrongPassword, .invalidCredential:
                            self?.showError("Incorrect email or password. Please try again.")
                        case .invalidEmail:
                            self?.showError("Please enter a valid email address.")
                        case .userNotFound:
                            self?.showError("No account found with this email. Please create an account.")
                        case .userDisabled:
                            self?.showError("This account has been disabled. Please contact support.")
                        case .tooManyRequests:
                            self?.showError("Too many attempts. Please try again later.")
                        default:
                            self?.showError("Login failed. Please check your credentials and try again.")
                        }
                    }
                } else {
                    self?.navigateToMain()
                }
            }
        }
    }

    @objc private func handleForgotPassword() {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email address.", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Email"
            tf.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self, weak alert] _ in
            guard let email = alert?.textFields?.first?.text, !email.isEmpty else { return }
            FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showError(error.localizedDescription)
                    } else {
                        let ok = UIAlertController(title: "Email Sent", message: "Check your inbox for a reset link.", preferredStyle: .alert)
                        ok.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ok, animated: true)
                    }
                }
            }
        })
        present(alert, animated: true)
    }

    @objc private func handleCreateAccount() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loginButton.alpha = loading ? 0.5 : 1
        if loading { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
    }

    private func navigateToMain() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = scene.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.rootViewController = sceneDelegate.makeMainTabBar()
    }

    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height + 16
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        scrollView.contentInset.bottom = 0
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField { passwordField.becomeFirstResponder() }
        else { handleLogin() }
        return true
    }
}
