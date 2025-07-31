import SwiftUI
import CoreLocation

struct LocationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var locationManager = LocationManager()
    
    // State for location
    @State private var locationServices = true
    @AppStorage("searchRadius") private var searchRadius: Double = 50.0 // km

    var body: some View {
        ZStack {
            // Background like FeedView
            Color.clear.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("backicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("Location Settings")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Location Permissions Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("LOCATION PERMISSIONS")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Enable Location Services")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Toggle("", isOn: $locationServices)
                                        .tint(.green)
                                        .onChange(of: locationServices) { oldValue, newValue in
                                            if newValue {
                                                locationManager.requestLocationUpdate()
                                            }
                                        }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.3))
                            }
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // Current Location Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CURRENT LOCATION")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Country")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text(locationManager.currentCountry ?? "Detecting...")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.3))
                                
                                Divider()
                                    .padding(.horizontal, 20)
                                
                                HStack {
                                    Text("City")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text(locationManager.currentCity ?? "Detecting...")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.3))
                            }
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // Search Radius Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SEARCH RADIUS")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                Text("Show pets within \(Int(searchRadius)) km")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 8) {
                                    Slider(value: $searchRadius, in: 10...100, step: 1)
                                        .accentColor(.blue)
                                        .padding(.horizontal, 20)
                                    
                                    HStack {
                                        Text("10 km")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("100 km")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 20)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Account for tab bar
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            locationManager.requestLocationUpdate()
        }
    }
}

#Preview {
    LocationSettingsView()
} 