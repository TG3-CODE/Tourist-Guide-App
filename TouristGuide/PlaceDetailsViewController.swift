//
//  PlaceDetailsViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//
import UIKit

class PlaceDetailsViewController: UIViewController {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var place: TouristPlace!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cachedPlace = DataManager.shared.getCachedPlace(id: place.id) {
            place = cachedPlace
            updateRatingDisplay()
        }
        updateFavoriteButtonAppearance()
    }
    
    private func setupUI() {
        title = place.name
        if place.imageName.starts(with: "userimage_"),
           let image = UIImage.loadFromDocumentsDirectory(imageName: place.imageName) {
            placeImageView.image = image
        } else if let image = UIImage(named: place.imageName) {
            placeImageView.image = image
        } else {
            let firstLetter = place.name.prefix(1).uppercased()
            let hue = CGFloat(place.name.hash % 100) / 100.0
            let color = UIColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1.0)
            
            placeImageView.image = createPlaceholderImage(text: firstLetter, color: color, size: CGSize(width: placeImageView.bounds.width, height: placeImageView.bounds.height))
        }
        nameLabel.text = place.name
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        descriptionLabel.text = place.description
        updateRatingDisplay()
        placeImageView.layer.cornerRadius = 12
        placeImageView.clipsToBounds = true
        placeImageView.contentMode = .scaleAspectFill
        commentsButton.layer.cornerRadius = 8
        commentsButton.backgroundColor = .systemBlue
        commentsButton.setTitleColor(.white, for: .normal)
        
        directionsButton.layer.cornerRadius = 8
        directionsButton.backgroundColor = .systemBlue
        directionsButton.setTitleColor(.white, for: .normal)
        
        favoriteButton.layer.cornerRadius = 8
        favoriteButton.backgroundColor = .systemBlue
        favoriteButton.setTitleColor(.white, for: .normal)
        updateFavoriteButtonAppearance()
    }
    
    private func updateFavoriteButtonAppearance() {
        if favoriteButton != nil {
            favoriteButton.setImage(UIImage(systemName: place.isFavorite ? "star.fill" : "star"), for: .normal)
            favoriteButton.tintColor = place.isFavorite ? .systemYellow : .systemGray
            favoriteButton.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            favoriteButton.layer.borderWidth = 1
            favoriteButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    private func updateRatingDisplay() {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ratingStackView.axis = .horizontal
        ratingStackView.alignment = .center
        ratingStackView.distribution = .fillEqually
        ratingStackView.spacing = 2
        let rating = place.rating
        let fullStarCount = Int(rating)
        let hasHalfStar = (rating - Double(fullStarCount)) >= 0.5
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            NSLayoutConstraint.activate([
                starImageView.widthAnchor.constraint(equalToConstant: 20),
                starImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
            if i <= fullStarCount {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = .systemYellow
            } else if i == fullStarCount + 1 && hasHalfStar {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = .systemGray
            }
            
            ratingStackView.addArrangedSubview(starImageView)
        }
        let valueLabel = UILabel()
        valueLabel.text = String(format: "%.1f/5.0", rating)
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .darkGray
        valueLabel.textAlignment = .left
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        ratingStackView.addArrangedSubview(valueLabel)
    }
    
    private func createPlaceholderImage(text: String, color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: size.width * 0.3),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let string = text
            let stringSize = string.size(withAttributes: attrs)
            let stringRect = CGRect(
                x: (size.width - stringSize.width) / 2,
                y: (size.height - stringSize.height) / 2,
                width: stringSize.width,
                height: stringSize.height
            )
            
            string.draw(in: stringRect, withAttributes: attrs)
        }
    }
    
    @IBAction func commentsButtonTapped(_ sender: UIButton) {
        let reviewsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ReviewsViewController") as! ReviewsViewController
        reviewsVC.place = place
        navigationController?.pushViewController(reviewsVC, animated: true)
    }
    
    @IBAction func directionsButtonTapped(_ sender: UIButton) {
        let navigationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NavigationViewController") as! NavigationViewController
        navigationVC.destination = place.location
        navigationVC.placeName = place.name
        navigationController?.pushViewController(navigationVC, animated: true)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        place.isFavorite.toggle()
        updateFavoriteButtonAppearance()
        if place.isFavorite {
            DataManager.shared.addFavoritePlace(place)
            DataManager.shared.saveData()
            showToast(message: "Added to favorites")
        } else {
            DataManager.shared.removeFavoritePlace(place.id)
            DataManager.shared.saveData() 
            showToast(message: "Removed from favorites")
        }
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.width/2 - 150, y: view.frame.height - 100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}


