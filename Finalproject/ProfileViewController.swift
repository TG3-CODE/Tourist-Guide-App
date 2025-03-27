//
//  ProfileViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/12/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    private let datePicker = UIDatePicker()
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
        setupDatePicker()
    }
    
    private func setupUI() {
        title = "Profile & Settings"
       
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logoutButton
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray6
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemGray2
        
        uploadImageButton.setTitle("Change Photo", for: .normal)
       
        nameTextField.placeholder = "Full Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.layer.cornerRadius = 8
        
        dobTextField.placeholder = "Date of Birth"
        dobTextField.borderStyle = .roundedRect
        dobTextField.layer.cornerRadius = 8
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.layer.cornerRadius = 8
        emailTextField.keyboardType = .emailAddress
       
        saveButton.layer.cornerRadius = 8
        saveButton.backgroundColor = .blue
        saveButton.setTitleColor(.white, for: .normal)
        
        favoritesButton.layer.cornerRadius = 8
        favoritesButton.backgroundColor = .blue
        favoritesButton.setTitleColor(.white, for: .normal)
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton, doneButton], animated: false)
        dobTextField.inputView = datePicker
        dobTextField.inputAccessoryView = toolbar
    }
    
    private func loadUserProfile() {
        let userProfile = DataManager.shared.userProfile
        
        nameTextField.text = userProfile.name
        emailTextField.text = userProfile.email
        
        if let dob = userProfile.dateOfBirth {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dobTextField.text = formatter.string(from: dob)
            datePicker.date = dob
        }
        
        locationSwitch.isOn = userProfile.locationEnabled
        notificationSwitch.isOn = userProfile.notificationsEnabled
        if let imageName = userProfile.profileImageName,
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(imageName)
            if let image = UIImage(contentsOfFile: fileURL.path) {
                profileImageView.image = image
                selectedImage = image
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dobTextField.text = formatter.string(from: datePicker.date)
        dismissKeyboard()
    }
    
    @IBAction func uploadImageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter your name and email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if !email.isValidEmail {
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        var dob: Date? = nil
        if let dobText = dobTextField.text, !dobText.isEmpty {
            dob = datePicker.date
        }
        var imageName: String? = DataManager.shared.userProfile.profileImageName
        if let selectedImage = selectedImage {
            imageName = "profile_\(UUID().uuidString)"
            if let imageData = selectedImage.jpegData(compressionQuality: 0.8),
               let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(imageName!)
                try? imageData.write(to: fileURL)
            }
        }
        let updatedProfile = UserProfile(
            name: name,
            dateOfBirth: dob,
            email: email,
            locationEnabled: locationSwitch.isOn,
            notificationsEnabled: notificationSwitch.isOn,
            profileImageName: imageName
        )
        
        DataManager.shared.userProfile = updatedProfile
        DataManager.shared.saveData()
        let isNewUser = navigationController?.viewControllers.first is RegisterViewController

        let alert = UIAlertController(title: "Success", message: "Profile updated successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if isNewUser {
                let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                self?.navigationController?.setViewControllers([homeVC], animated: true)
            }
        })
        present(alert, animated: true)
    }
    
    @IBAction func favoritesButtonTapped(_ sender: UIButton) {
        let favoritesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FavoritesViewController") as! FavoritesViewController
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    @objc func logoutButtonTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            let currentEmail = DataManager.shared.userProfile.email
            DataManager.shared.userProfile = UserProfile(
                name: "",
                dateOfBirth: nil,
                email: currentEmail,
                locationEnabled: true,
                notificationsEnabled: true,
                profileImageName: nil
            )
            DataManager.shared.saveData()
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        })
        
        present(alert, animated: true)
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            selectedImage = originalImage
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
