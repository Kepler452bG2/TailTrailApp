import SwiftUI

struct FeedView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var postService: PostService
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedSpecies: PetSpecies? = nil
    @State private var selectedStatus: PostStatus = .lost
    @State private var searchText = ""
    @State private var autoScrollIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @AppStorage("searchRadius") private var searchRadius: Double = 50.0

    var filteredPosts: [Post] {
        return postService.posts.filter { post in
            // Updated status matching logic - active posts show in lost tab
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
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        navigationHeader
                        searchBar
                        speciesFilter
                        lostFoundSegmentedControl
                        nearbyPetsSection
                        
                        // Recent Posts section
                        Text("Recent Posts")
                            .font(.title2.bold())
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        mainPostList
                    }
                    .padding(.vertical)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                .background(Color("BackgroundColor").ignoresSafeArea())
                .navigationBarHidden(true)
                .onAppear {
                    // Request location and load posts
                    locationManager.requestLocationUpdate()
                    
                    // Clear any previous errors
                    postService.clearError()
                    
                    Task {
                        // First try to load all posts
                        await postService.refreshPosts()
                        
                        // Then filter by location if available
                        if let location = locationManager.location {
                            await postService.loadPostsNearLocation(location, radius: searchRadius)
                        }
                    }
                }
                .onChange(of: searchRadius) { oldValue, newRadius in
                    // Reload posts when search radius changes
                    if let location = locationManager.location {
                        Task {
                            await postService.loadPostsNearLocation(location, radius: newRadius)
                        }
                    }
                }
                .onAppear {
                    Task {
                        await postService.refreshPosts()
                    }
                }
                
                // Offline indicator
                if postService.isOffline {
                    VStack {
                        Spacer()
                        OfflineBanner()
                    }
                }
                
                // Error alert
                if postService.showError {
                    VStack {
                        Spacer()
                        ErrorBanner(
                            message: postService.errorMessage ?? "An error occurred",
                            onRetry: {
                                Task {
                                    await postService.retry()
                                }
                            },
                            onDismiss: {
                                postService.clearError()
                            }
                        )
                    }
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
            .padding(.trailing)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search pets...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Capsule().fill(Color.white))
        .overlay(Capsule().stroke(Color.black, lineWidth: 1.5))
        .padding(.horizontal)
    }

    private var speciesFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                SpeciesFilterButton(
                    title: "All",
                    isSelected: selectedSpecies == nil,
                    action: { selectedSpecies = nil }
                )
                
                ForEach(PetSpecies.allCases, id: \.self) { species in
                    SpeciesFilterButton(
                        title: species.rawValue.capitalized,
                        isSelected: selectedSpecies == species,
                        action: { selectedSpecies = species }
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private var lostFoundSegmentedControl: some View {
        HStack(spacing: 0) {
            SegmentedControlButton(
                title: "Lost",
                count: lostCount,
                isSelected: selectedStatus == .lost,
                action: { withAnimation(.bouncy) { selectedStatus = .lost } }
            )
            
            SegmentedControlButton(
                title: "Found",
                count: foundCount,
                isSelected: selectedStatus == .found,
                action: { withAnimation(.bouncy) { selectedStatus = .found } }
            )
        }
        .padding(4)
        .background(Color("CardBackgroundColor").cornerRadius(12))
        .padding(.horizontal)
    }

    private var nearbyPetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All pet categories near")
                    .font(.title3.weight(.bold))
                if let city = locationManager.currentCity {
                    Text(city)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.orange)
                } else {
                    Text("you")
                        .font(.title3.weight(.bold))
                }
            }
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        if postService.posts.isEmpty && postService.isLoading {
                            // Show loading placeholders
                            ForEach(0..<4, id: \.self) { index in
                                SimplePetCardView(
                                    color: cardColors[index % cardColors.count],
                                    count: 0
                                )
                                .redacted(reason: .placeholder)
                                .id("loading-\(index)")
                            }
                        } else if postService.posts.isEmpty {
                            // Show default cards when no posts
                            ForEach(0..<4, id: \.self) { index in
                                SimplePetCardView(
                                    color: cardColors[index % cardColors.count],
                                    count: [20, 17, 15, 12][index]
                                )
                                .id("empty-\(index)")
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                }
                            }
                        } else {
                            // Show actual posts
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
                            
                            // Add placeholders if less than 4 posts
                            if postService.posts.count < 4 {
                                ForEach(0..<(4 - postService.posts.count), id: \.self) { index in
                                    SimplePetCardView(
                                        color: cardColors[index % cardColors.count],
                                        count: Int.random(in: 5...20)
                                    )
                                    .id("placeholder-\(index)")
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                    }
                                }
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

    private var mainPostList: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ],
            spacing: 20
        ) {
            if postService.isLoading && postService.posts.isEmpty {
                ForEach(0..<4) { _ in
                    PostCardSkeleton()
                }
            } else if filteredPosts.isEmpty {
                EmptyStateView(
                    title: "No posts found",
                    message: selectedSpecies == nil ? 
                        "No \(selectedStatus.rawValue) pets in your area" :
                        "No \(selectedSpecies?.rawValue ?? "") pets found",
                    iconName: "pawprint"
                )
                .gridCellColumns(2)
            } else {
                ForEach(filteredPosts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PetCardView(post: post)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if post == postService.posts.last {
                            Task {
                                await postService.loadMorePosts()
                            }
                        }
                    }
                }
            }
            
            if postService.isLoading && !postService.posts.isEmpty {
                ProgressView()
                    .gridCellColumns(2)
                    .padding()
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Supporting Views

struct OfflineBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
            Text("You're offline")
                .foregroundColor(.white)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.orange)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 100) // Avoid tab bar
    }
}

struct ErrorBanner: View {
    let message: String
    let onRetry: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.white)
                Text("Error")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            HStack {
                Button("Retry") {
                    onRetry()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(6)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.red)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 100) // Avoid tab bar
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct PostCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 100)
            
            // Info section
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: 100)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                    .frame(maxWidth: 70)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)
                    .frame(maxWidth: 50)
            }
            .padding(12)
            .background(Color.white)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .redacted(reason: .placeholder)
    }
} 