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
            let statusMatch = post.status == selectedStatus
            let speciesMatch = selectedSpecies == nil || post.species == selectedSpecies
            let searchMatch = searchText.isEmpty ||
                              post.title.localizedCaseInsensitiveContains(searchText) ||
                              post.description.localizedCaseInsensitiveContains(searchText)
            
            return statusMatch && speciesMatch && searchMatch
        }
    }
    
    private let cardColors: [Color] = [
        .pink.opacity(0.4), .blue.opacity(0.4), .green.opacity(0.4), .yellow.opacity(0.4)
    ]

    private var lostCount: Int {
        postService.posts.filter { $0.status == .lost }.count
    }
    
    private var foundCount: Int {
        postService.posts.filter { $0.status == .found }.count
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
        }
    }

    private var navigationHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: -15) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("Search")
                        .font(.system(size: 40, weight: .heavy))
                    
                    ZStack {
                        // Декоративные линии
                        Path { path in path.move(to: CGPoint(x: 0, y: 10)); path.addLine(to: CGPoint(x: 8, y: 0)) }.stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        Path { path in path.move(to: CGPoint(x: 5, y: 18)); path.addLine(to: CGPoint(x: 18, y: 0)) }.stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        Path { path in path.move(to: CGPoint(x: 15, y: 18)); path.addLine(to: CGPoint(x: 23, y: 8)) }.stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    }
                    .offset(x: 10, y: 0)
                }

                // Текст "Pet" с обводкой
                ZStack {
                    // Обводка
                    Text("Pet").offset(x: 1, y: 1)
                    Text("Pet").offset(x: -1, y: -1)
                    Text("Pet").offset(x: -1, y: 1)
                    Text("Pet").offset(x: 1, y: -1)
                }
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.black)
                .overlay(
                    // Заливка
                    Text("Pet")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.white)
                )
            }
            .foregroundColor(.black)
            .padding(.leading)
            
            Spacer()
            
            HStack(spacing: 8) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title2)
                }
                
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                }
            }
            .foregroundColor(.black)
        }
        .padding(.horizontal)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search pet", text: $searchText)
        }
        .foregroundColor(.gray)
        .padding()
        .background(Capsule().fill(Color.white).overlay(Capsule().stroke(Color.black, lineWidth: 1.5)))
        .padding(.horizontal)
    }

    private var mainPostList: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
            ForEach(filteredPosts) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    PetCardView(post: post)
                }
                .onAppear {
                    if post == postService.posts.last {
                        postService.loadMorePosts()
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var lostFoundSegmentedControl: some View {
        HStack(spacing: 0) {
            SegmentedControlButton(title: "Lost", count: lostCount, status: .lost, selection: $selectedStatus)
            SegmentedControlButton(title: "Found", count: foundCount, status: .found, selection: $selectedStatus)
        }
        .padding(4)
        .background(Color("CardBackgroundColor").cornerRadius(12))
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
                    .background(selection == status ? Color.white.opacity(0.3) : Color.black.opacity(0.1))
                    .clipShape(Circle())
            }
            .foregroundColor(selection == status ? .black : .gray)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(selection == status ? Color(red: 255/255, green: 196/255, blue: 0/255) : Color.clear)
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
                .background(isSelected ? Color.black : Color("CardBackgroundColor"))
                .foregroundColor(isSelected ? .white : Color("PrimaryTextColor"))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.black, lineWidth: isSelected ? 0 : 1.5)
                )
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(LanguageManager.shared)
        .environmentObject(PostService())
} 