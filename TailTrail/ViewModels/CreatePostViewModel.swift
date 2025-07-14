import SwiftUI
import CoreLocation
import PhotosUI

@MainActor
class CreatePostViewModel: ObservableObject {
    // Step management
    @Published var currentStep = 1
    
    // Step 1
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
        guard let location = locationManager.location else {
            presentAlert(title: "Location Error", message: "Could not determine location. Please enable location services.")
            return
        }
        guard let age = Double(petAge), let weight = Double(petWeight) else {
            presentAlert(title: "Invalid Input", message: "Please enter valid numbers for age and weight.")
            return
        }
        
        isLoading = true
        
        do {
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
                contactPhone: contactPhone,
                lastSeenLocation: location.coordinate,
                images: selectedImages
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