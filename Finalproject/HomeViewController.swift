//
//  HomeViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var popularDestinationsView: UIView?
    @IBOutlet weak var popularDestinationsStack: UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWelcomeMessage()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.textAlignment = .center
        welcomeLabel.numberOfLines = 2
        updateWelcomeMessage()
        
        cityTextField.placeholder = "Enter City"
        cityTextField.borderStyle = .roundedRect
        cityTextField.layer.cornerRadius = 8
        cityTextField.layer.borderWidth = 1
        cityTextField.layer.borderColor = UIColor.systemGray4.cgColor
        cityTextField.clearButtonMode = .whileEditing
        cityTextField.returnKeyType = .next
        cityTextField.delegate = self
        
        stateTextField.placeholder = "Enter State"
        stateTextField.borderStyle = .roundedRect
        stateTextField.layer.cornerRadius = 8
        stateTextField.layer.borderWidth = 1
        stateTextField.layer.borderColor = UIColor.systemGray4.cgColor
        stateTextField.clearButtonMode = .whileEditing
        stateTextField.returnKeyType = .search
        stateTextField.delegate = self
        searchButton.layer.cornerRadius = 8
        searchButton.backgroundColor = .systemBlue
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.setTitle("Search", for: .normal)
      
        menuButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        menuButton.tintColor = .systemBlue
        setupPopularDestinations()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateWelcomeMessage() {
        if !DataManager.shared.userProfile.name.isEmpty {
            let firstName = DataManager.shared.userProfile.name.components(separatedBy: " ").first ?? "Traveler"
            welcomeLabel.text = "Welcome, \(firstName)!"
        } else {
            welcomeLabel.text = "Welcome to Tourist Guide!\nDiscover amazing places around the world."
        }
    }
    
    private func setupPopularDestinations() {
        if popularDestinationsView == nil || popularDestinationsStack == nil {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            if let searchButton = searchButton {
                NSLayoutConstraint.activate([
                    containerView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 40),
                    containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
                ])
            }
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = "Popular Destinations"
            titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            containerView.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 12
            stackView.distribution = .fillEqually
            containerView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            popularDestinationsView = containerView
            popularDestinationsStack = stackView
        }
        popularDestinationsStack?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let popularCities = [
            ("New York", "NY"),
            ("Los Angeles", "CA"),
            ("Chicago", "IL"),
            ("Miami", "FL"),
            ("Las Vegas", "NV"),
            ("San Francisco", "CA")
        ]
        for (city, state) in popularCities {
            let cityButton = UIButton(type: .system)
            cityButton.setTitle("🌆 \(city), \(state)", for: .normal)
            cityButton.contentHorizontalAlignment = .left
            cityButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            cityButton.accessibilityLabel = "\(city)|\(state)"
            cityButton.addTarget(self, action: #selector(popularCityTapped), for: .touchUpInside)
            
            popularDestinationsStack?.addArrangedSubview(cityButton)
        }
    }
    
    @objc private func popularCityTapped(_ sender: UIButton) {
        guard let cityAndState = sender.accessibilityLabel?.components(separatedBy: "|"),
              cityAndState.count == 2 else {
            return
        }
        
        let city = cityAndState[0]
        let state = cityAndState[1]
        let touristPlacesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TouristPlacesListViewController") as! TouristPlacesListViewController
        touristPlacesVC.city = city
        touristPlacesVC.state = state
        navigationController?.pushViewController(touristPlacesVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let city = cityTextField.text, !city.isEmpty,
              let state = stateTextField.text, !state.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter both city and state", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let touristPlacesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TouristPlacesListViewController") as! TouristPlacesListViewController
        touristPlacesVC.city = city
        touristPlacesVC.state = state
        navigationController?.pushViewController(touristPlacesVC, animated: true)
    }

    @IBAction func menuButtonTapped(_ sender: UIButton) {
       
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cityTextField {
            stateTextField.becomeFirstResponder()
        } else if textField == stateTextField {
            searchButtonTapped(searchButton)
        }
        return true
    }
}
