//
//  LoginViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/14/25.
//
import UIKit

class LoginViewController: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let containerView = UIView()
    private let appTitleLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
   
    private func setupUI() {
        view.backgroundColor = .systemBackground
        

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
        
      
        appTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        appTitleLabel.text = "Tourist Guide"
        appTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        appTitleLabel.textAlignment = .center
        containerView.addSubview(appTitleLabel)
       
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "UserName"
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
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        containerView.addSubview(passwordTextField)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        containerView.addSubview(loginButton)
      
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Create Account", for: .normal)
        registerButton.setTitleColor(.systemBlue, for: .normal)
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
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
        
            appTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            appTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            appTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
          
            emailTextField.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 24),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
        
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
           
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
           
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            registerButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            registerButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
  
    private func setupAnimations() {
      
        let plane = createAnimationImage(systemName: "airplane", tintColor: .systemBlue)
        let train = createAnimationImage(systemName: "tram.fill", tintColor: .systemGreen)
        let car = createAnimationImage(systemName: "car.fill", tintColor: .systemRed)
        let bus = createAnimationImage(systemName: "bus.fill", tintColor: .systemOrange)
        
        animationImages = [(plane.image, plane.view), (train.image, train.view), (car.image, car.view), (bus.image, bus.view)]
        
     
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
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password")
            return
        }
        
    
        let name = email.components(separatedBy: "@").first ?? email
        
        DataManager.shared.userProfile.name = name
        DataManager.shared.userProfile.email = email
        DataManager.shared.saveData()
      
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginButtonTapped()
        }
        return true
    }
}
