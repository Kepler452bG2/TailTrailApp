import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation? = nil
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
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

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            requestLocationUpdate()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        // Stop updating to save battery, we can re-request if needed
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
} 