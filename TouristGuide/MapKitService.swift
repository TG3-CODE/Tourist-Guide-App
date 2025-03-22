//
//  MapKitService.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/13/25.
//
import Foundation
import MapKit

class MapKitService {
  
    static let shared = MapKitService()
    private init() {}
   
    func searchForTouristPlaces(in city: String, state: String, completion: @escaping ([TouristPlace]?, Error?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "\(city) \(state) tourist attractions"
        searchRequest.region = MKCoordinateRegion(.world)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let response = response else {
                completion([], nil)
                return
            }
           
            var places: [TouristPlace] = []
            
            for (index, item) in response.mapItems.enumerated() {
               
                var placeCity = city
                var placeState = state

                if let locality = item.placemark.locality {
                    placeCity = locality
                }
                if let administrativeArea = item.placemark.administrativeArea {
                    placeState = administrativeArea
                }
                
                let placeId = "mapkit_place_\(index)_\(item.name ?? "unknown")"
                
                let place = TouristPlace(
                    id: placeId,
                    name: item.name ?? "Tourist Attraction",
                    description: item.placemark.title ?? "A tourist attraction in \(city), \(state)",
                    location: "\(item.placemark.coordinate.latitude),\(item.placemark.coordinate.longitude)",
                    city: placeCity,
                    state: placeState,
                    rating: 0.0,
                    isFavorite: DataManager.shared.isFavoritePlace(placeId),
                    imageName: "",
                    comments: []
                )
                
                places.append(place)
            }
            
            completion(places, nil)
        }
    }
    
    func getPlaceDetails(_ place: TouristPlace, completion: @escaping (TouristPlace?, Error?) -> Void) {
        
        completion(place, nil)
    }
  
    func getDirections(from originCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D, transportType: MKDirectionsTransportType = .automobile, completion: @escaping (MKRoute?, Error?) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: originCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = transportType
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let response = response, let route = response.routes.first else {
                completion(nil, NSError(domain: "No route found", code: 404, userInfo: nil))
                return
            }
            
            completion(route, nil)
        }
    }
    
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let placemark = placemarks?.first, let location = placemark.location else {
                completion(nil, NSError(domain: "No location found", code: 404, userInfo: nil))
                return
            }
            
            completion(location.coordinate, nil)
        }
    }
   
    func findNearbyTransportation(near coordinate: CLLocationCoordinate2D, type: String, completion: @escaping ([MKMapItem]?, Error?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = type
       
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 2000, 
            longitudinalMeters: 2000
        )
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let response = response else {
                completion([], nil)
                return
            }
            
            completion(response.mapItems, nil)
        }
    }
    func getEstimatedTravelTimes(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping ([String: TimeInterval]?, Error?) -> Void) {
        var results: [String: TimeInterval] = [:]
        let group = DispatchGroup()
        var lastError: Error?
        
        group.enter()
        getDirections(from: origin, to: destination, transportType: .automobile) { route, error in
            if let route = route {
                results["car"] = route.expectedTravelTime
            }
            if let error = error {
                lastError = error
            }
            group.leave()
        }
    
        group.enter()
        getDirections(from: origin, to: destination, transportType: .walking) { route, error in
            if let route = route {
                results["walking"] = route.expectedTravelTime
            }
            if let error = error {
                lastError = error
            }
            group.leave()
        }
        
        group.enter()
        getDirections(from: origin, to: destination, transportType: .transit) { route, error in
            if let route = route {
                results["transit"] = route.expectedTravelTime
            }
            if let error = error {
                lastError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if results.isEmpty, let error = lastError {
                completion(nil, error)
            } else {
                completion(results, nil)
            }
        }
    }
}
