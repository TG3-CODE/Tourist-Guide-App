//
//  ReviewsViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//
import UIKit

class ReviewsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var place: TouristPlace!
    private var ratingButtons: [UIButton] = []
    private var selectedRating: Double = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRatingStars()
    }
    
    private func setupUI() {
        title = "Reviews & Ratings"
       
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
    
        placeNameLabel.text = place.name
       
        commentTextField.placeholder = "Add your comment..."
        commentTextField.borderStyle = .roundedRect
        commentTextField.layer.cornerRadius = 8
        
        submitButton.layer.cornerRadius = 8
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupRatingStars() {
       
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ratingButtons.removeAll()
       
        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button.tintColor = .systemYellow
            button.tag = i
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
            
            ratingStackView.addArrangedSubview(button)
            ratingButtons.append(button)
        }
       
        updateRatingUI(rating: 5)
    }
    
    @objc private func ratingButtonTapped(_ sender: UIButton) {
        let rating = Double(sender.tag)
        selectedRating = rating
        updateRatingUI(rating: rating)
    }
    
    private func updateRatingUI(rating: Double) {
        for (index, button) in ratingButtons.enumerated() {
            let buttonRating = Double(index + 1)
            button.tintColor = buttonRating <= rating ? .systemYellow : .systemGray
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
           
            let alert = UIAlertController(title: "Missing Comment", message: "Please enter a comment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if DataManager.shared.userProfile.name.isEmpty {
            let alert = UIAlertController(title: "Login Required", message: "Please login or create an account to leave a comment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let newComment = Comment(
            id: UUID().uuidString,
            userName: DataManager.shared.userProfile.name,
            text: commentText,
            rating: selectedRating
        )
        DataManager.shared.addComment(to: place.id, comment: newComment)
        DataManager.shared.updateUserAddedPlaceComment(placeId: place.id, comment: newComment)
        place.comments.append(newComment)
        let totalRating = place.comments.reduce(0) { $0 + $1.rating }
        place.rating = place.comments.isEmpty ? 0 : totalRating / Double(place.comments.count)
        commentTextField.text = ""
        selectedRating = 5.0
        updateRatingUI(rating: 5.0)
        let successAlert = UIAlertController(title: "Success", message: "Your review has been submitted!", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
        tableView.reloadData()
    }
}

extension ReviewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return place.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = place.comments[indexPath.row]
        var content = cell.defaultContentConfiguration()
        var starsString = ""
        let fullStars = Int(comment.rating)
        let hasHalfStar = (comment.rating - Double(fullStars)) >= 0.5
        
        for i in 1...5 {
            if i <= fullStars {
                starsString += "★"
            } else if i == fullStars + 1 && hasHalfStar {
                starsString += "⭐"
            } else {
                starsString += "☆"
            }
        }
        
        content.text = "\(comment.userName) - \(starsString) (\(String(format: "%.1f", comment.rating)))"
        content.secondaryText = comment.text
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Comments (\(place.comments.count))"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
