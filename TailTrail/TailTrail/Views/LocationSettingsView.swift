import SwiftUI
import CoreLocation

struct LocationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var locationManager = LocationManager()
    
    // State for location
    @State private var locationServices = true
    @AppStorage("searchRadius") private var searchRadius: Double = 50.0 // km

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
                .font(.title2.bold())
                Spacer()
                Text("Location Settings")
                    .font(.headline.bold())
                Spacer()
            }
            .padding()
            
            Form {
                Section(header: Text("Location Permissions")) {
                    Toggle("Enable Location Services", isOn: $locationServices)
                        .tint(.green)
                        .onChange(of: locationServices) { oldValue, newValue in
                            if newValue {
                                locationManager.requestLocationUpdate()
                            }
                        }
                }
                
                if locationServices {
                    Section(header: Text("Current Location")) {
                        HStack {
                            Text("Country")
                            Spacer()
                            Text(locationManager.currentCountry ?? "Detecting...")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("City")
                            Spacer()
                            Text(locationManager.currentCity ?? "Detecting...")
                                .foregroundColor(.gray)
                        }
                        
                        if locationManager.authorizationStatus == .denied {
                            Text("Please enable location access in Settings")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Section(header: Text("Search Radius")) {
                        VStack(alignment: .leading) {
                            Text("Show pets within \(Int(searchRadius)) km")
                                .font(.subheadline)
                            
                            Slider(value: $searchRadius, in: 10...100, step: 10)
                                .tint(.orange)
                            
                            HStack {
                                Text("10 km")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("100 km")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .foregroundColor(.black)
        .background(Color.theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if locationServices {
                locationManager.requestLocationUpdate()
            }
        }
    }
}

#Preview {
    LocationSettingsView()
} 