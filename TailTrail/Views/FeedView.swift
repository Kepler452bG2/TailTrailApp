import SwiftUI

struct FeedView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var selectedSpecies: PetSpecies? = nil
    @State private var selectedStatus: PostStatus = .lost
    @State private var searchText = ""
    
    // --- New Hierarchical Location Data ---
    @State private var selectedCountry = "USA"
    @State private var selectedCity = "New York"
    
    let locationData: [String: [String]] = [
        "USA": ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"],
        "Kazakhstan": ["Almaty", "Astana", "Shymkent", "Karaganda", "Aktobe"],
        "Turkey": ["Istanbul", "Ankara", "Izmir", "Bursa", "Antalya"],
        "Russia": ["Moscow", "Saint Petersburg", "Novosibirsk", "Yekaterinburg", "Kazan"]
    ]
    
    var countries: [String] {
        locationData.keys.sorted()
    }
    
    var citiesForSelectedCountry: [String] {
        locationData[selectedCountry] ?? []
    }
    // ------------------------------------

    private var filteredPosts: [Post] {
        return MockData.posts.filter { post in
            let statusMatch = post.status == selectedStatus
            let speciesMatch = selectedSpecies == nil || post.species == selectedSpecies
            let searchMatch = searchText.isEmpty ||
                              post.title.localizedCaseInsensitiveContains(searchText) ||
                              post.description.localizedCaseInsensitiveContains(searchText)
            
            return statusMatch && speciesMatch && searchMatch
        }
    }

    private var lostCount: Int {
        MockData.posts.filter { $0.status == .lost }.count
    }
    
    private var foundCount: Int {
        MockData.posts.filter { $0.status == .found }.count
    }

    private let cardColors: [Color] = [
        .yellow.opacity(0.6),
        .pink.opacity(0.6),
        .blue.opacity(0.6),
        .green.opacity(0.6)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        navigationHeader
                        searchBar
                        speciesFilter
                        lostFoundSegmentedControl
                        lostFoundInYourArea
                        mainPostList
                    }
                    .padding(.vertical)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
    
    private var navigationHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: -10) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("Search".localized())
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.black)

                    // Sparkles
                    ZStack {
                        // Left stick
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 25))
                            path.addQuadCurve(to: CGPoint(x: 11, y: 10), control: CGPoint(x: 4, y: 18))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                        // Middle stick (longest)
                        Path { path in
                            path.move(to: CGPoint(x: 12, y: 28))
                            path.addQuadCurve(to: CGPoint(x: 28, y: 8), control: CGPoint(x: 18, y: 18))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        
                        // Right stick
                        Path { path in
                            path.move(to: CGPoint(x: 24, y: 29))
                            path.addQuadCurve(to: CGPoint(x: 34, y: 18), control: CGPoint(x: 29, y: 24))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    }
                    .frame(width: 32, height: 32)
                    .foregroundColor(.black)
                    .offset(x: 0, y: -10)
                }

                // Outlined Text with a thinner stroke
                let petText = "Pet".localized()
                ZStack {
                    Text(petText).offset(x: 1, y: 1)
                    Text(petText).offset(x: -1, y: -1)
                    Text(petText).offset(x: -1, y: 1)
                    Text(petText).offset(x: 1, y: -1)
                    Text(petText).foregroundColor(Color.theme.background)
                }
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.black)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
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
            TextField("Search pet".localized(), text: $searchText)
                .autocorrectionDisabled()
        }
        .foregroundColor(.gray)
        .padding()
        .background(
            ZStack {
                Capsule()
                    .fill(Color.yellow)
                    .offset(x: 3, y: 3)
                
                Capsule()
                    .fill(Color.white)
                    .overlay(
                        Capsule().stroke(Color.black, lineWidth: 1.5)
                    )
            }
        )
        .padding(.horizontal)
    }
    
    private var speciesFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(PetSpecies.allCases, id: \.self) { species in
                    Button(action: {
                        withAnimation(.bouncy) {
                        selectedSpecies = (selectedSpecies == species) ? nil : species
                        }
                    }) {
                        Text(species.rawValue.capitalized.localized())
                    }
                    .buttonStyle(StickerButtonStyle(isSelected: selectedSpecies == species))
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var lostFoundInYourArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All pet categories near you".localized())
                .font(.title3.weight(.bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(MockData.posts.enumerated()), id: \.element.id) { index, post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCardView(
                                post: post,
                                color: cardColors[index % cardColors.count]
                            )
                                .frame(width: 250)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var lostFoundSegmentedControl: some View {
        HStack(spacing: 0) {
            SegmentedControlButton(title: "Lost".localized(), count: lostCount, status: .lost, selection: $selectedStatus)
            SegmentedControlButton(title: "Found".localized(), count: foundCount, status: .found, selection: $selectedStatus)
        }
        .padding(4)
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var mainPostList: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
            ForEach(Array(filteredPosts.enumerated()), id: \.element.id) { index, post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    PostCardView(
                        post: post,
                        color: cardColors[index % cardColors.count]
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

// Custom button style for the "sticker" effect
private struct StickerButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        if isSelected {
            // Selected state style (solid black)
            configuration.label
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.black)
                .foregroundColor(Color.white)
                .clipShape(Capsule())
        } else {
            // Unselected state style (white with black border)
            configuration.label
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .overlay(
                            Capsule().stroke(Color.black, lineWidth: 1.5)
                        )
                )
                .foregroundColor(.black)
        }
    }
}

// A new component for the segmented control buttons with counters
private struct SegmentedControlButton: View {
    let title: String
    let count: Int
    let status: PostStatus
    @Binding var selection: PostStatus
    
    var body: some View {
        Button(action: {
            withAnimation(.bouncy) {
                selection = status
            }
        }) {
            HStack(spacing: 8) {
                Text(title)
                Text("\(count)")
                    .font(.caption.bold())
                    .padding(6)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
            }
            .foregroundColor(selection == status ? .white : .gray)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(selection == status ? Color.theme.accent : Color.clear)
            .cornerRadius(8)
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(PostService())
} 