import SwiftUI

@MainActor
class MapViewModel: ObservableObject {
    enum MapFilter: Hashable {
        case all
        case status(PostStatus)
        case species(PetSpecies)
        case recent
    }

    @Published var selectedFilter: MapFilter = .all
    @Published var isFilterViewPresented = false
    @Published var searchText = ""

    private let allPosts = MockData.posts

    var filteredPosts: [Post] {
        // First, filter by the main filter selection (panel)
        let panelFilteredPosts: [Post]
        switch selectedFilter {
        case .all:
            panelFilteredPosts = allPosts
        case .status(let status):
            panelFilteredPosts = allPosts.filter { $0.status == status.rawValue }
        case .species(let species):
            panelFilteredPosts = allPosts.filter { $0.species == species.rawValue }
        case .recent:
            panelFilteredPosts = allPosts.filter { $0.createdAt > Date().addingTimeInterval(-3600 * 24) }
        }
        
        // Then, apply the text search on top of that
        if searchText.isEmpty {
            return panelFilteredPosts
        } else {
            return panelFilteredPosts.filter { post in
                let petNameMatch = (post.petName ?? "").localizedCaseInsensitiveContains(searchText)
                let descriptionMatch = (post.description ?? "").localizedCaseInsensitiveContains(searchText)
                return petNameMatch || descriptionMatch
            }
        }
    }

    var lostCount: Int {
        allPosts.filter { $0.status == PostStatus.lost.rawValue }.count
    }

    var foundCount: Int {
        allPosts.filter { $0.status == PostStatus.found.rawValue }.count
    }
} 