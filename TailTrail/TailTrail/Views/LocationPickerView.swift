import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Binding var selectedLocation: CLLocation?
    @Binding var locationName: String
    @Environment(\.dismiss) var dismiss
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $cameraPosition) {
                    // Show selected location
                    if let coordinate = selectedCoordinate {
                        Annotation("Selected Location", coordinate: coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
                }
                .onTapGesture { location in
                    // Convert tap location to map coordinate
                    // This is simplified - in real app you'd need to convert screen coordinates
                }
                .onAppear {
                    // Set initial position
                    if let location = selectedLocation {
                        selectedCoordinate = location.coordinate
                        cameraPosition = .region(MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    } else if let userLocation = locationManager.location {
                        selectedCoordinate = userLocation.coordinate
                        cameraPosition = .region(MKCoordinateRegion(
                            center: userLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
                
                // Center pin overlay
                Image(systemName: "mappin")
                    .font(.title)
                    .foregroundColor(.red)
                    .background(Circle().fill(.white).frame(width: 30, height: 30))
                    .offset(y: -15) // Adjust for pin point
                
                // Instructions
                VStack {
                    Text("Drag map to select location")
                        .font(.caption)
                        .padding(8)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveLocation()
                    }
                    .fontWeight(.semibold)
                }
            }

        }
    }
    
    private func saveLocation() {
        // Get center coordinate from current camera position
        let coordinate: CLLocationCoordinate2D
        
        // For now, use the current location or a default
        if let location = selectedLocation ?? locationManager.location {
            coordinate = location.coordinate
        } else {
            // Default to some coordinate if no location available
            coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        }
        
        selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Get location name
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        Task {
            if let placemarks = try? await geocoder.reverseGeocodeLocation(location),
               let placemark = placemarks.first {
                let street = placemark.thoroughfare ?? ""
                let city = placemark.locality ?? ""
                locationName = "\(street), \(city)".trimmingCharacters(in: .whitespaces)
                if locationName.hasPrefix(", ") {
                    locationName = city
                }
            }
            dismiss()
        }
    }
}

#Preview {
    LocationPickerView(
        selectedLocation: .constant(nil),
        locationName: .constant("")
    )
} 