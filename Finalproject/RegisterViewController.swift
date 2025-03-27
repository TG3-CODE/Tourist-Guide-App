//
//  RegisterViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/14/25.
//
import UIKit

class RegisterViewController: UIViewController {
    
    
    private let backgroundImageView = UIImageView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let usernameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let animationView = UIView()
    private var animationTimer: Timer?
    private var animationImages: [(image: UIImage, view: UIImageView)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations()
    }
  
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Create Account"
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "travel_background") ?? UIImage(systemName: "photo")
        backgroundImageView.alpha = 0.3
        view.addSubview(backgroundImageView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .clear
        view.addSubview(animationView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        view.addSubview(containerView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Create New Account"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.returnKeyType = .next
        usernameTextField.delegate = self
        containerView.addSubview(usernameTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        containerView.addSubview(emailTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .next
        passwordTextField.delegate = self
        containerView.addSubview(passwordTextField)
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.returnKeyType = .done
        confirmPasswordTextField.delegate = self
        containerView.addSubview(confirmPasswordTextField)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        containerView.addSubview(registerButton)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            usernameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            registerButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 24),
            registerButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 44),
            registerButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Animations
    private func setupAnimations() {
        let waterfall = createAnimationImage(systemName: "drop.fill", tintColor: .systemBlue)
        let mountain = createAnimationImage(systemName: "mountain.2.fill", tintColor: .systemGreen)
        let sun = createAnimationImage(systemName: "sun.max.fill", tintColor: .systemYellow)
        let cloud = createAnimationImage(systemName: "cloud.fill", tintColor: .systemGray)
        
        animationImages = [(waterfall.image, waterfall.view), (mountain.image, mountain.view),
                           (sun.image, sun.view), (cloud.image, cloud.view)]
        for (_, view) in animationImages {
            animationView.addSubview(view)
        }
    }
    
    private func createAnimationImage(systemName: String, tintColor: UIColor) -> (image: UIImage, view: UIImageView) {
        let image = UIImage(systemName: systemName)!.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.frame = CGRect(x: -100, y: CGFloat.random(in: 100...500), width: 60, height: 60)
        
        return (image, imageView)
    }
    
    private func startAnimations() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.launchRandomAnimation()
        }
        launchRandomAnimation()
    }
    
    private func launchRandomAnimation() {
        guard let randomImageData = animationImages.randomElement() else { return }
        let imageView = randomImageData.view
        imageView.frame.origin.x = -100
        imageView.alpha = 0.7
        imageView.frame.origin.y = CGFloat.random(in: 100...500)
        UIView.animate(withDuration: 8.0, delay: 0, options: .curveLinear) {
            imageView.frame.origin.x = self.view.bounds.width + 100
        } completion: { _ in
            imageView.alpha = 0
        }
    }
    
    private func stopAnimations() {
        animationTimer?.invalidate()
        animationTimer = nil
        for (_, view) in animationImages {
            view.layer.removeAllAnimations()
            view.alpha = 0
        }
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func registerButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields")
            return
        }
        if !email.isValidEmail {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        if password != confirmPassword {
            showAlert(title: "Passwords Don't Match", message: "Please make sure your passwords match")
            return
        }
        DataManager.shared.userProfile.name = username
        DataManager.shared.userProfile.email = email
        DataManager.shared.saveData()
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            registerButtonTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

