//
//  DataModels.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//
import Foundation
import UIKit

struct TouristPlace: Codable {
    let id: String
    let name: String
    let description: String
    let location: String
    let city: String
    let state: String
    var rating: Double
    var isFavorite: Bool
    var imageName: String
    var comments: [Comment]
  
    static func createMockPlace(id: String = UUID().uuidString, name: String, city: String, state: String) -> TouristPlace {
        return TouristPlace(
            id: id,
            name: name,
            description: "A popular tourist attraction in \(city), \(state).",
            location: "",
            city: city,
            state: state,
            rating: 0.0,
            isFavorite: false,
            imageName: "",
            comments: []
        )
    }
}

struct Comment: Codable {
    let id: String
    let userName: String
    let text: String
    let rating: Double
}

struct UserProfile: Codable {
    var name: String
    var dateOfBirth: Date?
    var email: String
    var locationEnabled: Bool
    var notificationsEnabled: Bool
    var profileImageName: String?
}

class DataManager {
    static let shared = DataManager()
    
    private init() {
        loadData()
    }
  
    var userProfile = UserProfile(name: "", dateOfBirth: nil, email: "", locationEnabled: true, notificationsEnabled: true, profileImageName: nil)
  
    private var placeCache: [String: TouristPlace] = [:]
    private var favoritePlaceIds: Set<String> = []
    private var userAddedPlaces: [TouristPlace] = []
    
    
    func loadData() {
        if let savedFavorites = UserDefaults.standard.stringArray(forKey: "favoritePlaceIds") {
            favoritePlaceIds = Set(savedFavorites)
        }
        if let savedProfile = UserDefaults.standard.data(forKey: "userProfile") {
            let decoder = JSONDecoder()
            if let loadedProfile = try? decoder.decode(UserProfile.self, from: savedProfile) {
                userProfile = loadedProfile
            }
        }
    
        if let savedPlaces = UserDefaults.standard.data(forKey: "userAddedPlaces") {
            let decoder = JSONDecoder()
            if let loadedPlaces = try? decoder.decode([TouristPlace].self, from: savedPlaces) {
                userAddedPlaces = loadedPlaces
            }
        }
    }
    func addComment(to placeId: String, comment: Comment) {
        
        if var place = getCachedPlace(id: placeId) {
            place.comments.append(comment)
            let totalRating = place.comments.reduce(0) { $0 + $1.rating }
            place.rating = place.comments.isEmpty ? 0 : totalRating / Double(place.comments.count)
            updatePlaceCache(place)
        }
    }
    func saveData() {
       
        UserDefaults.standard.set(Array(favoritePlaceIds), forKey: "favoritePlaceIds")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
        
        if let encoded = try? encoder.encode(userAddedPlaces) {
            UserDefaults.standard.set(encoded, forKey: "userAddedPlaces")
        }
    }
  
    
    func addFavoritePlace(_ place: TouristPlace) {
        favoritePlaceIds.insert(place.id)
        updatePlaceCache(place)
        saveData()
    }
    
    func removeFavoritePlace(_ placeId: String) {
        favoritePlaceIds.remove(placeId)
        saveData()
    }
    
    func isFavoritePlace(_ placeId: String) -> Bool {
        return favoritePlaceIds.contains(placeId)
    }
    
    func getFavoritePlaceIds() -> Set<String> {
        return favoritePlaceIds
    }
    
    private func updatePlaceCache(_ place: TouristPlace) {
        placeCache[place.id] = place
    }
    
    func getCachedPlace(id: String) -> TouristPlace? {
        return placeCache[id]
    }
  
    
    func addUserPlace(_ place: TouristPlace) {
        userAddedPlaces.append(place)
        saveData()
    }
    
    
    func updateUserAddedPlaceComment(placeId: String, comment: Comment) {
        if let index = userAddedPlaces.firstIndex(where: { $0.id == placeId }) {
            userAddedPlaces[index].comments.append(comment)
  
            let totalRating = userAddedPlaces[index].comments.reduce(0) { $0 + $1.rating }
            userAddedPlaces[index].rating = userAddedPlaces[index].comments.isEmpty ? 0 : totalRating / Double(userAddedPlaces[index].comments.count)
   
            saveData()
        }
    }
    
    func getUserAddedPlaces(for city: String, state: String) -> [TouristPlace] {
        return userAddedPlaces.filter {
            $0.city.lowercased() == city.lowercased() &&
            $0.state.lowercased() == state.lowercased()
        }
    }
    
    func getAllUserAddedPlaces() -> [TouristPlace] {
        return userAddedPlaces
    }
}

extension UIImage {
    
    static let imageCache = NSCache<NSString, UIImage>()
    
    static func loadFromURL(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
   
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            imageCache.setObject(image, forKey: NSString(string: urlString))
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
