import SwiftUI

struct FeedView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var postService: PostService
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedStatus: PostStatus = .lost
    @State private var autoScrollIndex = 0
    @State private var showingFilters = false
    @State private var showAllPosts = false
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @AppStorage("searchRadius") private var searchRadius: Double = 50.0

    private var lostCount: Int {
        postService.posts.filter { $0.status == PostStatus.lost.rawValue }.count
    }
    
    private var foundCount: Int {
        postService.posts.filter { $0.status == PostStatus.found.rawValue }.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed header at top - НЕ скроллится
                navigationHeader
                    .padding(.top, 20)
                    .background(Color.clear)
                    .zIndex(2)
                
                // Scrollable content - только контент скроллится
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        searchBar
                        speciesFilter
                        .padding(.top, 12)
                        nearbyPetsSection
                        
                        // Recent Posts section
                        Text("recent_posts".localized())
                        .font(TypographyStyles.h4)
                        .foregroundColor(NewColorPalette.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                        
                        mainPostList
                    }
                    .padding(.top, 20) // Уменьшаем отступ так как заголовок теперь фиксированный
                    .padding(.bottom, 20)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                .zIndex(1)
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingFilters) {
                FeedFilterView(
                    selectedSpecies: $postService.selectedSpecies,
                    searchRadius: $searchRadius
                )
            }
            .sheet(isPresented: $showAllPosts) {
                AllPostsView(posts: postService.posts)
            }
            .onAppear {
                // Request location and load posts
                locationManager.requestLocationUpdate()
                
                // Clear any previous errors
                postService.clearError()
                
                // Load posts from server
                Task {
                    print("🔄 Starting to load posts from server...")
                    await postService.refreshPosts()
                    print("📊 Posts loaded: \(postService.posts.count)")
                    print("🔍 Filtered posts: \(postService.filteredPosts.count)")
                }
                
                // Check available fonts
                checkAvailableFonts()
                
                // Test color
                print("=== COLOR TEST ===")
                print("lightOrange color: \(NewColorPalette.lightOrange)")
                print("=== END COLOR TEST ===")
            }
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    autoScrollIndex = (autoScrollIndex + 1) % 3
                }
            }
        }
    }
    
    // MARK: - Header
    private var navigationHeader: some View {
        HStack {
            Image("Hello ,Human! Search Pet")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 100)
            
            Spacer()
            
            HStack(spacing: 8) {
                // Notification icon
                NavigationLink(destination: NotificationsView()) {
                    Image("Iconring")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.black)
                }
                
                // Profile icon
                                        NavigationLink(destination: ProfileView(postService: postService)) {
                    Image("Iconperson")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(width: 320, height: 100)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image("search")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(NewColorPalette.textSecondary)
            
            TextField("Search", text: $postService.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(Color(red: 0.051, green: 0.051, blue: 0.051))
            
            // Clear button
            if !postService.searchText.isEmpty {
                Button(action: {
                    postService.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(NewColorPalette.textSecondary)
                        .font(.system(size: 16))
                }
            }
            
            Button(action: {
                showingFilters.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(NewColorPalette.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.698, green: 0.878, blue: 0.855))
        .cornerRadius(12)
        .shadow(color: Color.black, radius: 0, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    // MARK: - Species Filter
    private var speciesFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All species button
                Button(action: { 
                    postService.selectedSpecies = nil 
                }) {
                    Text("all".localized())
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(postService.selectedSpecies == nil ? .white : Color.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(postService.selectedSpecies == nil ? Color.black : Color(red: 0.99, green: 0.83, blue: 0.64))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1.0)
                        )
                }
                
                // Individual species buttons
                ForEach(PetSpecies.allCases, id: \.self) { species in
                    Button(action: { 
                        postService.selectedSpecies = species 
                    }) {
                        Text(species.localizedName)
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(postService.selectedSpecies == species ? .white : Color.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(postService.selectedSpecies == species ? Color.black : Color(red: 0.99, green: 0.83, blue: 0.64))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1.0)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Nearby Pets Section
    private var nearbyPetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image("All categories near")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 24)
                    .padding(.top, 8)
                
                Text("Almaty")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(NewColorPalette.textPrimary)
                    .padding(.top, 8)
                
                Spacer()
                
                Button(action: {
                    // Show all posts
                    showAllPosts = true
                }) {
                    Text("All")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(NewColorPalette.textPrimary)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            
            // Nearby pets carousel
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    if locationManager.currentCity != nil {
                        ForEach(postService.filteredPosts.prefix(4)) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                NearbyPetCardView(post: post, postService: postService)
                                    .frame(width: 210, height: 220)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        // Placeholder cards while loading location
                        ForEach(0..<4, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 210, height: 220)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Main Post List
    private var mainPostList: some View {
        VStack(spacing: 12) {
            // Loading state
            if postService.posts.isEmpty && postService.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("loading_posts".localized())
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(NewColorPalette.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else if postService.filteredPosts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "pawprint.circle")
                        .font(.system(size: 60))
                        .foregroundColor(NewColorPalette.textSecondary)
                    
                    Text(postService.selectedSpecies == nil ? 
                        "No \(selectedStatus.rawValue) pets in your area" :
                        "No \(postService.selectedSpecies?.rawValue ?? "") pets found")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(NewColorPalette.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else {
                // Posts grid - 2 columns
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 2), spacing: 24) {
                    ForEach(postService.filteredPosts) { post in
                        ZStack {
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostCardView(post: post, postService: postService)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Отдельная кнопка лайка поверх карточки
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        postService.toggleLike(for: post)
                                    }) {
                                        Image("likeicon")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(postService.isLiked(post: post) ? .black : .white.opacity(0.6))
                                            .background(
                                                Circle()
                                                    .fill(Color.black.opacity(0.3))
                                                    .frame(width: 28, height: 28)
                                            )
                                    }
                                    .padding(.top, 8)
                                    .padding(.trailing, 8)
                                }
                                Spacer()
                            }
                            .allowsHitTesting(true)
                        }
                        .padding(.bottom, 0) // Убираем дополнительный padding, используем только gap
                        .onAppear {
                            if post == postService.posts.last {
                                Task {
                                    await postService.loadMorePosts()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            if postService.isLoading && !postService.posts.isEmpty {
                ProgressView()
                    .padding()
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Full Post List
    private var fullPostList: some View {
        VStack(spacing: 12) {
            // Loading state
            if postService.isLoading && postService.posts.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("loading_posts".localized())
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(NewColorPalette.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else if postService.filteredPosts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "pawprint.circle")
                        .font(.system(size: 60))
                        .foregroundColor(NewColorPalette.textSecondary)
                    
                    Text(postService.selectedSpecies == nil ? 
                        "No \(selectedStatus.rawValue) pets in your area" :
                        "No \(postService.selectedSpecies?.rawValue ?? "") pets found")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(NewColorPalette.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else {
                // Posts list
                LazyVStack(spacing: 12) {
                ForEach(postService.filteredPosts) { post in
                        PostCardView(post: post, postService: postService)
                    .onAppear {
                        if post == postService.posts.last {
                            Task {
                                await postService.loadMorePosts()
                            }
                        }
                    }
                }
                }
                .padding(.horizontal, 20)
            }
            
            if postService.isLoading && !postService.posts.isEmpty {
                ProgressView()
                    .padding()
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func checkAvailableFonts() {
        print("=== AVAILABLE FONTS ===")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            if family.contains("Poppins") {
                print("✅ Found Poppins family: \(family)")
                for name in names {
                    print("   - \(name)")
                }
            }
        }
        print("=== END FONTS ===")
    }
}

// MARK: - Filter View
struct FeedFilterView: View {
    @Binding var selectedSpecies: PetSpecies?
    @Binding var searchRadius: Double
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(languageManager.localizedString(forKey: "search_filters"))
                    .font(.custom("Poppins-Bold", size: 24))
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(languageManager.localizedString(forKey: "animal_type"))
                        .font(.custom("Poppins-SemiBold", size: 18))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        Button(languageManager.localizedString(forKey: "all")) {
                            selectedSpecies = nil
                        }
                        .padding()
                        .background(selectedSpecies == nil ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(selectedSpecies == nil ? .white : .primary)
                        .cornerRadius(8)
                        
                        Button(languageManager.localizedString(forKey: "Dog")) {
                            selectedSpecies = PetSpecies.dog
                        }
                        .padding()
                        .background(selectedSpecies == PetSpecies.dog ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(selectedSpecies == PetSpecies.dog ? .white : .primary)
                        .cornerRadius(8)
                        
                        Button(languageManager.localizedString(forKey: "Cat")) {
                            selectedSpecies = PetSpecies.cat
                        }
                        .padding()
                        .background(selectedSpecies == PetSpecies.cat ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(selectedSpecies == PetSpecies.cat ? .white : .primary)
                        .cornerRadius(8)
                        
                        Button(languageManager.localizedString(forKey: "Bird")) {
                            selectedSpecies = PetSpecies.bird
                        }
                        .padding()
                        .background(selectedSpecies == PetSpecies.bird ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(selectedSpecies == PetSpecies.bird ? .white : .primary)
                        .cornerRadius(8)
                    }
                    
                    Text("\(languageManager.localizedString(forKey: "search_radius")): \(Int(searchRadius)) \(languageManager.localizedString(forKey: "km"))")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .padding(.top)
                    
                    Slider(value: $searchRadius, in: 1...100, step: 1)
                        .accentColor(NewColorPalette.accentTeal)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color.clear.ignoresSafeArea()) // Like FeedView
            .navigationTitle(languageManager.localizedString(forKey: "filters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localizedString(forKey: "Done")) {
                        dismiss()
                    }
                    .foregroundColor(NewColorPalette.accentTeal)
                }
            }
        }
    }
} 