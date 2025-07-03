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
            panelFilteredPosts = allPosts.filter { $0.status == status }
        case .species(let species):
            panelFilteredPosts = allPosts.filter { $0.species == species }
        case .recent:
            panelFilteredPosts = allPosts.filter { $0.timestamp > Date().addingTimeInterval(-3600 * 24) }
        }
        
        // Then, apply the text search on top of that
        if searchText.isEmpty {
            return panelFilteredPosts
        } else {
            return panelFilteredPosts.filter { post in
                post.title.localizedCaseInsensitiveContains(searchText) ||
                post.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var lostCount: Int {
        allPosts.filter { $0.status == .lost }.count
    }

    var foundCount: Int {
        allPosts.filter { $0.status == .found }.count
    }
} 