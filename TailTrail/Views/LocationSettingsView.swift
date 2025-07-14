import SwiftUI

struct LocationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // State for location
    @State private var selectedCountry = "USA"
    @State private var locationServices = true
    
    // Hardcoded location data
    private let countries = ["USA", "Kazakhstan", "Turkey", "Russia"]

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
                    Toggle("Enable Location Services", isOn: $locationServices).tint(.green)
                }
                
                if locationServices {
                    Section(header: Text("Region")) {
                        Picker("Country", selection: $selectedCountry) {
                            ForEach(countries, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
        }
        .foregroundColor(.black)
        .background(Color.theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    LocationSettingsView()
} 