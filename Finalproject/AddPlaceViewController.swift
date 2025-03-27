//
//  AddPlaceViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//
import UIKit

class AddPlaceViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var city: String = ""
    var state: String = ""
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Add New Place"
       
        nameTextField.placeholder = "Place Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.layer.cornerRadius = 8
        
        locationTextField.placeholder = "Location"
        locationTextField.borderStyle = .roundedRect
        locationTextField.layer.cornerRadius = 8
      
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = .placeholderText
        descriptionTextView.delegate = self
      
        uploadImageButton.layer.cornerRadius = 8
        uploadImageButton.backgroundColor = .systemBlue
        uploadImageButton.setTitleColor(.white, for: .normal)
        
        saveButton.layer.cornerRadius = 8
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
   
        imagePreview.layer.cornerRadius = 8
        imagePreview.clipsToBounds = true
        imagePreview.contentMode = .scaleAspectFill
        imagePreview.image = UIImage(systemName: "photo")
        imagePreview.backgroundColor = .systemGray6
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
              let location = locationTextField.text, !location.isEmpty,
              let description = descriptionTextView.text, description != "Description", !description.isEmpty else {
         
            let alert = UIAlertController(title: "Missing Information", message: "Please fill in all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
    
        let newPlaceId = UUID().uuidString
   
        var imageName = "placeholder"
        if let selectedImage = selectedImage {
            imageName = "userimage_\(newPlaceId)"
      
            if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(imageName)
                try? imageData.write(to: fileURL)
            }
        }
  
        let newPlace = TouristPlace(
            id: newPlaceId,
            name: name,
            description: description,
            location: location,
            city: city,
            state: state,
            rating: 0.0,
            isFavorite: false,
            imageName: imageName,
            comments: []
        )
       
        DataManager.shared.addUserPlace(newPlace)
        
        navigationController?.popViewController(animated: true)
    }
}

extension AddPlaceViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = .placeholderText
        }
    }
}

extension AddPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            imagePreview.image = editedImage
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            imagePreview.image = originalImage
            selectedImage = originalImage
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
