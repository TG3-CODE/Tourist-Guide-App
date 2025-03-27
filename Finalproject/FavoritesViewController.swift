//
//  FavoritesViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/12/25.
//
import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    var favoritePlaces: [TouristPlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoritePlaces()
    }
    
    private func setupUI() {
        title = "Favorite Places"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 0)
        emptyStateLabel.text = "No favorite places yet.\nPlaces you mark as favorite will appear here."
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .systemGray
    }
    
    private func fetchFavoritePlaces() {
        let favoriteIds = DataManager.shared.getFavoritePlaceIds()
        favoritePlaces = []
        let userAddedPlaces = DataManager.shared.getAllUserAddedPlaces()
        for place in userAddedPlaces {
            if favoriteIds.contains(place.id) {
                var favoritePlace = place
                favoritePlace.isFavorite = true
                favoritePlaces.append(favoritePlace)
            }
        }
        for favoriteId in favoriteIds {
            if !favoritePlaces.contains(where: { $0.id == favoriteId }) {
                if let cachedPlace = DataManager.shared.getCachedPlace(id: favoriteId) {
                    var favoritePlace = cachedPlace
                    favoritePlace.isFavorite = true
                    favoritePlaces.append(favoritePlace)
                }
            }
        }
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !favoritePlaces.isEmpty
        tableView.isHidden = favoritePlaces.isEmpty
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = favoritePlaces[indexPath.row]
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = place.city + ", " + place.state
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
            } else if i == fullStarCount + 1 && hasHalfStar {                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = .systemGray
            }
            
            ratingStackView.addArrangedSubview(starImageView)
        }
        let removeButton = UIButton(type: .system)
        removeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        removeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        removeButton.tintColor = .systemYellow
        removeButton.tag = indexPath.row
        removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        let accessoryStackView = UIStackView(arrangedSubviews: [ratingStackView, removeButton])
        accessoryStackView.axis = .horizontal
        accessoryStackView.spacing = 8
        accessoryStackView.alignment = .center
        cell.accessoryView = accessoryStackView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let placeDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaceDetailsViewController") as! PlaceDetailsViewController
        placeDetailsVC.place = favoritePlaces[indexPath.row]
        navigationController?.pushViewController(placeDetailsVC, animated: true)
    }
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        let place = favoritePlaces[sender.tag]
        DataManager.shared.removeFavoritePlace(place.id)
        DataManager.shared.saveData()
        favoritePlaces.remove(at: sender.tag)
        updateEmptyState()
        tableView.reloadData()
    }
}
