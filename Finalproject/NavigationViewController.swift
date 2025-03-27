//
//  NavigationViewController.swift
//  Finalproject
//
//  Created by Gayatri Talluri on 3/8/25.
//
import UIKit
import MapKit
import CoreLocation

class NavigationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationTextField: UITextField!
    @IBOutlet weak var findRouteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    var destination: String = ""
    var placeName: String = ""
    var userLocation: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var currentRoute: MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationServices()
    
        let coordinates = destination.components(separatedBy: ",")
        if coordinates.count == 2,
           let latitude = Double(coordinates[0]),
           let longitude = Double(coordinates[1]) {
            destinationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            addDestinationPin()
        }
    }
    
    private func setupUI() {
        title = "Directions to \(placeName)"
        mapView.delegate = self
        currentLocationTextField.placeholder = "Enter your current location"
        currentLocationTextField.borderStyle = .roundedRect
        currentLocationTextField.layer.cornerRadius = 8
        currentLocationTextField.layer.borderWidth = 1
        currentLocationTextField.layer.borderColor = UIColor.systemGray4.cgColor
        currentLocationTextField.clearButtonMode = .whileEditing
        currentLocationTextField.returnKeyType = .search
        currentLocationTextField.delegate = self

        findRouteButton.layer.cornerRadius = 8
        findRouteButton.backgroundColor = .systemBlue
        findRouteButton.setTitleColor(.white, for: .normal)
        findRouteButton.setTitle("Find Route", for: .normal)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
   
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            showLocationPermissionAlert()
        }
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Access Required",
            message: "This app needs your location to provide directions. Please enable location access in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func addDestinationPin() {
        guard let coordinate = destinationCoordinate else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = placeName
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func getDirectionsWithMapKit(from originCoordinate: CLLocationCoordinate2D) {
        guard let destinationCoordinate = destinationCoordinate else {
            showAlert(title: "Error", message: "Destination coordinates not available")
            return
        }
        activityIndicator.startAnimating()
        mapView.removeOverlays(mapView.overlays)
        let transportType: MKDirectionsTransportType = .automobile
        MapKitService.shared.getDirections(from: originCoordinate, to: destinationCoordinate, transportType: transportType) { [weak self] route, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to get directions: \(error.localizedDescription)")
                    return
                }
                
                guard let route = route else { return }
                self?.currentRoute = route
                self?.mapView.addOverlay(route.polyline)
                let rect = route.polyline.boundingMapRect
                self?.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
                self?.showTransportationOptions(distance: route.distance / 1000, timeInMinutes: route.expectedTravelTime / 60)
            }
        }
    }
    
    private func showTransportationOptions(distance: Double, timeInMinutes: Double) {
        let actionSheet = UIAlertController(title: "Transportation Options", message: "Choose your preferred mode of transportation", preferredStyle: .actionSheet)
        let carTime = timeInMinutes
        actionSheet.addAction(UIAlertAction(title: "🚗 Car: \(Int(carTime)) minutes", style: .default) { [weak self] _ in
            self?.showRouteDetailsAlert(
                mode: "Car",
                distance: distance,
                duration: carTime,
                instructions: "Follow the highlighted route on the map.\nEstimated fuel cost: $\(String(format: "%.2f", distance * 0.1))"
            )
        })
      
        let busTime = timeInMinutes * 1.5
        actionSheet.addAction(UIAlertAction(title: "🚌 Bus: \(Int(busTime)) minutes", style: .default) { [weak self] _ in
            self?.showRouteDetailsAlert(
                mode: "Bus",
                distance: distance,
                duration: busTime,
                instructions: "Take bus routes near your location.\nEstimated fare: $\(Int(distance * 0.05 + 2))"
            )
        })
        if distance > 5 {
            let trainTime = timeInMinutes * 0.8
            actionSheet.addAction(UIAlertAction(title: "🚆 Train: \(Int(trainTime)) minutes", style: .default) { [weak self] _ in
                self?.showRouteDetailsAlert(
                    mode: "Train",
                    distance: distance,
                    duration: trainTime,
                    instructions: "Head to the nearest train station.\nEstimated fare: $\(Int(distance * 0.08 + 3))"
                )
            })
        }
        if distance > 100 {
            let flightTime = 60 + (distance * 0.1)
            actionSheet.addAction(UIAlertAction(title: "✈️ Flight: \(Int(flightTime)) minutes", style: .default) { [weak self] _ in
                self?.showRouteDetailsAlert(
                    mode: "Flight",
                    distance: distance,
                    duration: flightTime,
                    instructions: "Check nearest airports for available flights.\nEstimated cost: $\(Int(distance * 0.5 + 50)/8)"
                )
            })
        }
        if distance < 5 {
            let walkingTime = distance * 12
            actionSheet.addAction(UIAlertAction(title: "🚶 Walking: \(Int(walkingTime)) minutes", style: .default) { [weak self] _ in
                self?.showRouteDetailsAlert(
                    mode: "Walking",
                    distance: distance,
                    duration: walkingTime,
                    instructions: "Follow the pedestrian route.\nCalories burned: ~\(Int(distance * 65))"
                )
            })
        }
      
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = findRouteButton
            popoverController.sourceRect = findRouteButton.bounds
        }
        
        present(actionSheet, animated: true)
    }
    
    private func showRouteDetailsAlert(mode: String, distance: Double, duration: Double, instructions: String) {
        let message = """
        Distance: \(String(format: "%.1f", distance)) km
        Estimated Time: \(Int(duration)) minutes
        
        \(instructions)
        """
        
        let alert = UIAlertController(title: "\(mode) Route Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func findRouteButtonTapped(_ sender: UIButton) {
        if let locationText = currentLocationTextField.text, !locationText.isEmpty {
            activityIndicator.startAnimating()
            
            MapKitService.shared.geocodeAddress(locationText) { [weak self] coordinate, error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    
                    if let error = error {
                        self?.showAlert(title: "Error", message: "Could not find the location: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let coordinate = coordinate else { return }
                    self?.getDirectionsWithMapKit(from: coordinate)
                }
            }
        }
        else if let userLocation = userLocation {
            getDirectionsWithMapKit(from: userLocation)
        }
        else {
            showAlert(title: "Error", message: "Please enter your current location or allow location access")
        }
    }
}


extension NavigationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "destinationPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let infoButton = UIButton(type: .detailDisclosure)
            infoButton.addTarget(self, action: #selector(destinationInfoTapped), for: .touchUpInside)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }
        if let pinView = annotationView as? MKPinAnnotationView {
            pinView.pinTintColor = .red
            pinView.animatesDrop = true
        }
        
        return annotationView
    }
    
    @objc func destinationInfoTapped() {
        let alert = UIAlertController(title: placeName, message: "This is your destination.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Show Transportation Options", style: .default) { [weak self] _ in
            if let route = self?.currentRoute {
                self?.showTransportationOptions(distance: route.distance / 1000, timeInMinutes: route.expectedTravelTime / 60)
            }
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}
extension NavigationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        if mapView.annotations.count == 0 {
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            mapView.setRegion(region, animated: true)
        }
    
        if destinationCoordinate != nil {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

extension NavigationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == currentLocationTextField {
            findRouteButtonTapped(findRouteButton)
        }
        
        return true
    }
}
