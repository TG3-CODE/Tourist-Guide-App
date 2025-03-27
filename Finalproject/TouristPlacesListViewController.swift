//
//  TouristPlacesListViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//
import UIKit
import MapKit

class TouristPlacesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var city: String = ""
    var state: String = ""
    var places: [TouristPlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPlacesFromMapKit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteStatus()
        tableView.reloadData()
    }
    private func setupUI() {
        title = "Top \(city) Attractions"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                          target: self,
                                                          action: #selector(addButtonTapped))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 0)
        activityIndicator.hidesWhenStopped = true
    }
    private func fetchPlacesFromMapKit() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        
        MapKitService.shared.searchForTouristPlaces(in: city, state: state) { [weak self] places, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
                
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    return
                }
                
                if let places = places {
                    self?.places = places
                    if let userPlaces = self?.getUserAddedPlaces() {
                        self?.places.append(contentsOf: userPlaces)
                    }
                    
                    self?.updateFavoriteStatus()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func getUserAddedPlaces() -> [TouristPlace] {
        return DataManager.shared.getUserAddedPlaces(for: city, state: state)
    }
    
    private func updateFavoriteStatus() {
        let favoritePlaceIds = DataManager.shared.getFavoritePlaceIds()
        for i in 0..<places.count {
            places[i].isFavorite = favoritePlaceIds.contains(places[i].id)
        }
    }
    @objc private func addButtonTapped() {
        if DataManager.shared.userProfile.name.isEmpty {
            let alert = UIAlertController(
                title: "Login Required",
                message: "You need to be logged in to add a new place. Please login or create an account.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let addPlaceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddPlaceViewController") as! AddPlaceViewController
        addPlaceVC.city = city
        addPlaceVC.state = state
        navigationController?.pushViewController(addPlaceVC, animated: true)
    }
    
    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        places[index].isFavorite.toggle()
        
        if places[index].isFavorite {
            DataManager.shared.addFavoritePlace(places[index])
            showToast(message: "Added to favorites")
        } else {
            DataManager.shared.removeFavoritePlace(places[index].id)
            showToast(message: "Removed from favorites")
        }
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = "Tourist Attraction"
        if let imageView = cell.imageView {
            if place.imageName.starts(with: "userimage_"),
               let image = UIImage.loadFromDocumentsDirectory(imageName: place.imageName) {
                imageView.image = image
            } else {
                let firstLetter = place.name.prefix(1).uppercased()
                let hue = CGFloat(place.name.hash % 100) / 100.0
                let color = UIColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1.0)
                let size = CGSize(width: 60, height: 60)
                UIGraphicsBeginImageContextWithOptions(size, false, 0)
                color.setFill()
                UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 30).fill()
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 30),
                    .foregroundColor: UIColor.white
                ]
                
                let string = String(firstLetter)
                let stringSize = string.size(withAttributes: attrs)
                let stringRect = CGRect(
                    x: (size.width - stringSize.width) / 2,
                    y: (size.height - stringSize.height) / 2,
                    width: stringSize.width,
                    height: stringSize.height
                )
                
                string.draw(in: stringRect, withAttributes: attrs)
                imageView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            imageView.layer.cornerRadius = 30
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
        }
        let ratingStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .fillEqually
        ratingStackView.spacing = 2
        let rating = place.rating
        let fullStarCount = Int(rating)
        let hasHalfStar = (rating - Double(fullStarCount)) >= 0.5
        
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            
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
        let ratingLabel = UILabel()
        ratingLabel.text = place.rating > 0 ? String(format: " %.1f", place.rating) : " N/A"
        ratingLabel.font = UIFont.systemFont(ofSize: 12)
        ratingLabel.textColor = .darkGray
        ratingStackView.addArrangedSubview(ratingLabel)
        let favoriteButton = UIButton(type: .system)
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favoriteButton.setImage(UIImage(systemName: place.isFavorite ? "star.fill" : "star"), for: .normal)
        favoriteButton.tintColor = place.isFavorite ? .systemYellow : .systemGray
        favoriteButton.tag = indexPath.row
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
      
        let accessoryStackView = UIStackView(arrangedSubviews: [ratingStackView, favoriteButton])
        accessoryStackView.axis = .horizontal
        accessoryStackView.spacing = 8
        accessoryStackView.alignment = .center
        cell.accessoryView = accessoryStackView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let placeDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaceDetailsViewController") as! PlaceDetailsViewController
        placeDetailsVC.place = places[indexPath.row]
        navigationController?.pushViewController(placeDetailsVC, animated: true)
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
