import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation? = nil
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var currentCity: String? = nil
    @Published var currentCountry: String? = nil

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        // Set default location for simulator (Almaty, Kazakhstan)
        #if targetEnvironment(simulator)
        // You can change these coordinates to your city
        self.location = CLLocation(latitude: 43.2220, longitude: 76.8512)
        Task {
            await reverseGeocode(location: self.location!)
        }
        #endif
    }

    func requestLocationUpdate() {
        locationManager.startUpdatingLocation()
    }
    
    func fetchLocation() async -> CLLocation? {
        // A more robust implementation would handle authorization status changes here
        requestLocationUpdate()
        
        return await withCheckedContinuation { continuation in
            // This is a simplified approach. A real-world app would need a more
            // sophisticated way to handle timeouts and errors, perhaps with a delegate
            // or a Combine publisher that can be awaited.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Wait for 3 seconds
                continuation.resume(returning: self.location)
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        Task { @MainActor in
            authorizationStatus = status
            
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                requestLocationUpdate()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.location = location
            // Stop updating to save battery, we can re-request if needed
            locationManager.stopUpdatingLocation()
            
            // Get city and country from coordinates
            await reverseGeocode(location: location)
        }
    }
    
    @MainActor
    private func reverseGeocode(location: CLLocation) async {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                self.currentCity = placemark.locality
                self.currentCountry = placemark.country
                print("📍 User location: \(currentCity ?? "Unknown"), \(currentCountry ?? "Unknown")")
            }
        } catch {
            print("❌ Reverse geocoding failed: \(error)")
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
} 