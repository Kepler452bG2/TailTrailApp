import SwiftUI

struct FeedView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var postService: PostService
    
    @State private var selectedSpecies: PetSpecies? = nil
    @State private var selectedStatus: PostStatus = .lost
    @State private var searchText = ""
    @State private var autoScrollIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var filteredPosts: [Post] {
        return postService.posts.filter { post in
            // Updated status matching logic to include "active" posts in the "lost" tab
            let statusMatch: Bool
            if selectedStatus == .lost {
                statusMatch = post.status == "lost" || post.status == "active"
            } else {
                statusMatch = post.status == selectedStatus.rawValue
            }
            
            let speciesMatch = selectedSpecies == nil || post.species == selectedSpecies?.rawValue
            let searchMatch = searchText.isEmpty ||
                              (post.petName ?? "").localizedCaseInsensitiveContains(searchText) ||
                              (post.description ?? "").localizedCaseInsensitiveContains(searchText)
            
            return statusMatch && speciesMatch && searchMatch
        }
    }
    
    private let cardColors: [Color] = [
        .pink.opacity(0.4), .blue.opacity(0.4), .green.opacity(0.4), .yellow.opacity(0.4)
    ]

    private var lostCount: Int {
        postService.posts.filter { $0.status == PostStatus.lost.rawValue }.count
    }
    
    private var foundCount: Int {
        postService.posts.filter { $0.status == PostStatus.found.rawValue }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    navigationHeader
                    searchBar
                    speciesFilter
                    lostFoundSegmentedControl
                    nearbyPetsSection
                    mainPostList
                }
                .padding(.vertical)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await postService.refreshPosts()
                }
            }
        }
    }

    private var navigationHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: -15) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("Search")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(Color(hex: "#3E5A9A")) // Blue color
                    
                    ZStack {
                        // Декоративные линии
                        Path { path in path.move(to: CGPoint(x: 0, y: 10)); path.addLine(to: CGPoint(x: 8, y: 0)) }.stroke(Color(hex: "#FBCF3A"), style: StrokeStyle(lineWidth: 2.5, lineCap: .round)) // Yellow
                        Path { path in path.move(to: CGPoint(x: 5, y: 18)); path.addLine(to: CGPoint(x: 18, y: 0)) }.stroke(Color(hex: "#22A6A2"), style: StrokeStyle(lineWidth: 2.5, lineCap: .round)) // Teal
                        Path { path in path.move(to: CGPoint(x: 15, y: 18)); path.addLine(to: CGPoint(x: 23, y: 8)) }.stroke(Color(hex: "#FBCF3A"), style: StrokeStyle(lineWidth: 2.5, lineCap: .round)) // Yellow
                    }
                    .offset(x: 10, y: 0)
                }

                // Текст "Pet"
                Text("Pet")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(Color(hex: "#3E5A9A")) // Blue color
            }
            .padding(.leading)
            
            Spacer()
            
            HStack(spacing: 8) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#3E5A9A")) // Blue icon
                }
            }
        }
        .padding(.horizontal)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "#3E5A9A")) // Blue icon
            TextField("Search pet...", text: $searchText)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color(hex: "#3E5A9A"), lineWidth: 1.5)) // Blue border
        .padding(.horizontal)
    }

    private var mainPostList: some View {
        let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(filteredPosts) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    PetCardView(post: post)
                }
                .buttonStyle(.plain)
                .padding(8)
                .onAppear {
                    if post == postService.posts.last {
                        Task {
                            await postService.loadMorePosts()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private var lostFoundSegmentedControl: some View {
        HStack(spacing: 0) {
            SegmentedControlButton(title: "Lost", count: lostCount, status: .lost, selection: $selectedStatus)
            SegmentedControlButton(title: "Found", count: foundCount, status: .found, selection: $selectedStatus)
        }
        .padding(4)
        .background(Color.white.opacity(0.5)) // Semi-transparent white
        .clipShape(Capsule())
        .padding(.horizontal)
    }

    private var speciesFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(species: nil, selection: $selectedSpecies)
                ForEach(PetSpecies.allCases) { species in
                    FilterButton(species: species, selection: $selectedSpecies)
                }
            }
            .padding(.horizontal)
        }
    }

    private var nearbyPetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All pet categories near you")
                .font(.title3.weight(.bold))
                .foregroundColor(Color(hex: "#3E5A9A")) // Blue title
                .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(postService.posts.prefix(10)) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                NearbyPetCardView(post: post)
                            }
                            .id(post.id)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, (UIScreen.main.bounds.width - 140) / 2)
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 220)
                .onReceive(timer) { _ in
                    let pets = Array(postService.posts.prefix(10))
                    guard !pets.isEmpty else { return }
                    
                    autoScrollIndex = (autoScrollIndex + 1) % pets.count
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        proxy.scrollTo(pets[autoScrollIndex].id, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct SegmentedControlButton: View {
    let title: String
    let count: Int
    let status: PostStatus
    @Binding var selection: PostStatus
    
    var body: some View {
        Button(action: { withAnimation(.bouncy) { selection = status } }) {
            HStack(spacing: 8) {
                Text(title)
                Text("\(count)")
                    .font(.caption.bold())
                    .padding(6)
                    .background(selection == status ? Color.white.opacity(0.3) : Color(hex: "#3E5A9A").opacity(0.1)) // Subtle blue
                    .clipShape(Circle())
            }
            .foregroundColor(selection == status ? .white : Color(hex: "#3E5A9A")) // Blue text
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(selection == status ? Color(hex: "#FBCF3A") : Color.clear) // Yellow selected
            .clipShape(Capsule())
        }
    }
}

private struct FilterButton: View {
    let species: PetSpecies?
    @Binding var selection: PetSpecies?
    
    var isSelected: Bool {
        species == selection
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                selection = species
            }
        }) {
            Text(species?.rawValue.capitalized ?? "All")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "#3E5A9A") : Color(.systemBackground)) // Blue selected
                .foregroundColor(isSelected ? .white : Color(hex: "#3E5A9A")) // Blue text
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color(hex: "#3E5A9A"), lineWidth: 1.5) // Blue border
                )
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(PostService(authManager: AuthenticationManager()))
} 