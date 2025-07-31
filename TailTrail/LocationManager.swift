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
        // Set default city and country for simulator
        self.currentCity = "Almaty"
        self.currentCountry = "Kazakhstan"
        print("📍 Simulator location: \(currentCity ?? "Unknown"), \(currentCountry ?? "Unknown")")
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
            
            // Set fallback values based on coordinates
            #if targetEnvironment(simulator)
            // For simulator, use default values
            self.currentCity = "Almaty"
            self.currentCountry = "Kazakhstan"
            print("📍 Using fallback location for simulator: \(currentCity ?? "Unknown"), \(currentCountry ?? "Unknown")")
            #else
            // For real device, try to determine approximate location
            if location.coordinate.latitude > 0 {
                self.currentCity = "Unknown City"
                self.currentCountry = "Unknown Country"
            } else {
                self.currentCity = "Unknown City"
                self.currentCountry = "Unknown Country"
            }
            print("📍 Using fallback location: \(currentCity ?? "Unknown"), \(currentCountry ?? "Unknown")")
            #endif
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Error getting location: \(error.localizedDescription)")
        
        // Set fallback values if location fails
        Task { @MainActor in
            #if targetEnvironment(simulator)
            self.currentCity = "Almaty"
            self.currentCountry = "Kazakhstan"
            print("📍 Using fallback location for simulator after error: \(currentCity ?? "Unknown"), \(currentCountry ?? "Unknown")")
            #else
            self.currentCity = "Unknown City"
            self.currentCountry = "Unknown Country"
            print("📍 Using fallback location after error: \(currentCity ?? "Unknown"), \(currentCountry ?? "Unknown")")
            #endif
        }
    }
} 