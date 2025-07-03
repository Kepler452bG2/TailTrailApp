import SwiftUI
import PhotosUI
import CoreLocation

@MainActor
class CreatePostViewModel: ObservableObject {
    
    // Step management
    @Published var currentStep = 1
    
    // Pet Details - Step 1
    @Published var petName: String = ""
    @Published var breed: String = ""
    @Published var color: String = ""
    @Published var isMixedBreed: Bool = false
    @Published var age: Double = 2 // Years
    @Published var gender: PetGender = .male
    @Published var spayedStatus: SpayedStatus = .notSure
    @Published var weight: PetWeight = .medium

    // Location Data
    @Published var locationStatus: LocationStatus = .idle
    @Published var determinedLocation: CLLocation?
    @Published var determinedLocationName: String?

    // Pet Details - Step 2
    @Published var description: String = ""
    @Published var contactPhone: String = ""
    @Published var selectedImages: [UIImage] = []

    // Existing properties for the final post
    @Published var status: PostStatus = .lost
    @Published var species: PetSpecies = .dog
    @Published var selectedCity: String = "Manhattan, NYC" // Default city
    @Published var tags: [String] = ["Dog", "Golden", "Friendly", "Collar"] // Placeholder
    
    let cities = ["Manhattan, NYC", "Almaty, KZ", "Nur-Sultan, KZ", "Shymkent, KZ"]
    
    var locationQuery: String {
        "Current Location - \(selectedCity)"
    }
    
    // UI State
    @Published var selectedPhotoItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                var images: [UIImage] = []
                for item in selectedPhotoItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                await MainActor.run {
                    self.selectedImages = images
                }
            }
        }
    }
    @Published var isShowingPhotoPicker = false
    
    func goToNextStep() {
        guard currentStep < 2 else { return }
        currentStep += 1
    }
    
    func goToPreviousStep() {
        guard currentStep > 1 else { return }
        currentStep -= 1
    }

    func publishPost(postService: PostService) {
        guard let location = determinedLocation, let locationName = determinedLocationName else {
            // Handle error: location not determined
            print("Location has not been determined yet.")
            return
        }

        postService.createPost(
            petName: petName,
            petSpecies: species,
            petBreed: breed,
            age: age,
            gender: gender,
            weight: weight,
            color: color,
            description: description,
            locationName: locationName,
            contactPhone: contactPhone,
            lastSeenLocation: location.coordinate,
            images: selectedImages
        )
    }
    
    func determineCurrentLocation(using locationManager: LocationManager) {
        locationStatus = .determining
        
        guard let location = locationManager.location else {
            locationStatus = .error
            return
        }
        
        self.determinedLocation = location
        
        // Geocode coordinates to get a placemark
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                self.determinedLocationName = [placemark.locality, placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                self.locationStatus = .determined
            } else {
                self.locationStatus = .error
            }
        }
    }
    
    func addTag(_ tag: String) {
        guard !tag.isEmpty && !tags.contains(tag) else { return }
        tags.append(tag)
    }
}

enum LocationStatus {
    case idle
    case determining
    case determined
    case error
}

/*
// Enums for the new fields - MOVED TO Post.swift to avoid duplication
enum PetGender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
}

enum SpayedStatus: String, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case notSure = "Not Sure"
}

enum PetWeight: String, CaseIterable {
    case small = "5-20 lb"
    case medium = "21-50 lb"
    case large = "51-99 lb"
    case xl = "100+ lb"
    
    var subtitle: String {
        switch self {
        case .small: return "SMALL"
        case .medium: return "MEDIUM"
        case .large: return "LARGE"
        case .xl: return "XL"
        }
    }
} 
*/