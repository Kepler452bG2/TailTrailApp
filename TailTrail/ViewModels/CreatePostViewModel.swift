import SwiftUI
import CoreLocation
import PhotosUI

@MainActor
class CreatePostViewModel: ObservableObject {
    // Step management
    @Published var currentStep = 1
    
    // Step 1
    @Published var postType: PostStatus = .lost // lost or found
    @Published var petName: String = ""
    @Published var selectedSpecies: PetSpecies = .dog
    @Published var petBreed: String = ""
    @Published var petAge: String = ""
    @Published var selectedGender: PetGender = .male
    @Published var petColor: String = ""
    @Published var petWeight: String = ""

    // Step 2
    @Published var selectedImages: [UIImage] = []
    @Published var description: String = ""
    @Published var locationName: String = ""
    @Published var contactPhone: String = ""
    
    // Location
    @Published var selectedLocation: CLLocation? = nil
    @Published var showLocationPicker = false
    @Published var useCurrentLocation = true
    
    // Photos Picker
    @Published var selectedPhotoItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                var images: [UIImage] = []
                for item in selectedPhotoItems {
                    if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                self.selectedImages = images
            }
        }
    }
    
    // UI State
    @Published var isLoading = false
    @Published var shouldShowAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    private let postService: PostService
    private var locationManager = LocationManager()

    init(postService: PostService) {
        self.postService = postService
        
        // Get current location when view model is created
        Task {
            await getCurrentLocation()
        }
    }
    
    func getCurrentLocation() async {
        locationManager.requestLocationUpdate()
        
        // Wait a bit for location update
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        if let location = locationManager.location {
            selectedLocation = location
            
            // Get location name
            let geocoder = CLGeocoder()
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                let street = placemark.thoroughfare ?? ""
                let city = placemark.locality ?? ""
                locationName = "\(street), \(city)".trimmingCharacters(in: .whitespaces)
                if locationName.hasPrefix(", ") {
                    locationName = city
                }
                } else {
                    // No placemarks found, set fallback
                    #if targetEnvironment(simulator)
                    locationName = "Almaty, Kazakhstan"
                    #else
                    locationName = "Unknown Location"
                    #endif
                }
            } catch {
                print("❌ Reverse geocoding failed in CreatePostViewModel: \(error)")
                
                // Set fallback location name
                #if targetEnvironment(simulator)
                locationName = "Almaty, Kazakhstan"
                #else
                locationName = "Unknown Location"
                #endif
            }
        } else {
            // No location available, set fallback
            #if targetEnvironment(simulator)
            locationName = "Almaty, Kazakhstan"
            #else
            locationName = "Unknown Location"
            #endif
        }
    }
    
    func goToNextStep() {
        if currentStep == 1, isStep1Valid() {
            currentStep += 1
        }
    }
    
    func goToPreviousStep() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }
    
    func isStep1Valid() -> Bool {
        return !petName.isEmpty && !petBreed.isEmpty && !petAge.isEmpty && !petColor.isEmpty && !petWeight.isEmpty
    }
    
    func publishPost() async {
        // Use selected location or current location
        let location = selectedLocation ?? locationManager.location
        
        guard let location = location else {
            presentAlert(title: "Location Error", message: "Could not determine location. Please enable location services.")
            return
        }
        guard let age = Double(petAge), let weight = Double(petWeight) else {
            presentAlert(title: "Invalid Input", message: "Please enter valid numbers for age and weight.")
            return
        }
        
        isLoading = true
        
        do {
            let formattedPhone = contactPhone.starts(with: "+") ? contactPhone : "+\(contactPhone)"
            try await postService.createPost(
                petName: petName,
                petSpecies: selectedSpecies.rawValue,
                petBreed: petBreed,
                age: age,
                gender: selectedGender.rawValue.lowercased(),
                weight: weight,
                color: petColor,
                description: description,
                locationName: locationName,
                contactPhone: formattedPhone,
                lastSeenLocation: location.coordinate,
                images: selectedImages,
                status: postType
            )
            presentAlert(title: "Success", message: "Your post has been published!")
        } catch {
            presentAlert(title: "Error", message: "Failed to publish post: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func presentAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.shouldShowAlert = true
    }
}