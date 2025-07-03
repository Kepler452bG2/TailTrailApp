import SwiftUI
import MapKit

struct PostDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var locationManager = LocationManager()
    
    let post: Post
    @State private var isLiked = false

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Beige Background
            Color.theme.background.ignoresSafeArea()
            
            ScrollView {
                // 2. Main Content Card
                mainContentCard
                    .padding(.top, 160) // Space for the overlapping image
            }
            
            NavigationLink(destination: FullScreenImageView(imageNames: post.imageNames)) {
                floatingImageHeader
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .overlay(backButton, alignment: .topLeading)
    }
    
    private var mainContentCard: some View {
        VStack(spacing: 16) {
            petInfoHeader.padding(.top, 80)
            infoGrid
            petStorySection
            
            // New bottom section combining author and contact button
            HStack {
                postedBySection
                Spacer()
                contactButton
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 35))
        .overlay(
            RoundedRectangle(cornerRadius: 35)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
        )
        .padding()
    }

    private var floatingImageHeader: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.6))
                .frame(width: 230, height: 230)
                .shadow(radius: 10)

            TabView {
                ForEach(post.imageNames, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 210, height: 210)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 5))
            .tabViewStyle(PageTabViewStyle())
        }
        .offset(y: 40)
    }
    
    private var petInfoHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.largeTitle.bold())
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("\(post.locationName) (\(distance(to: post)))")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            Spacer()
            Button(action: { isLiked.toggle() }) {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(isLiked ? .red : .pink.opacity(0.3))
                    .padding()
                    .background(Color.pink.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .foregroundColor(.black)
    }
    
    private var infoGrid: some View {
        HStack(spacing: 12) {
            InfoBox(label: "Age", value: "\(Int(post.age)) months")
            InfoBox(label: "Color", value: post.color)
            InfoBox(label: "Weight", value: post.weight.rawValue)
        }
        .frame(height: 60)
        .padding(.vertical)
    }

    private var petStorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pet Story")
                .font(.title2.bold())
            Text(post.description)
                .font(.body)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
    }
    
    private var postedBySection: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
            VStack(alignment: .leading) {
                Text("Posted by")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Nannie Barker")
                    .fontWeight(.semibold)
            }
        }
        .foregroundColor(.black)
    }
    
    private var contactButton: some View {
        NavigationLink(destination: ChatDetailView(session: findChatSession())) {
            Text("Contact Me")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(16)
        }
    }

    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.title2.bold())
                .padding()
                .background(.thinMaterial)
                .foregroundColor(.primary)
                .clipShape(Circle())
        }
        .padding()
    }
    
    private func distance(to post: Post) -> String {
        guard let userLocation = locationManager.location else { return "N/A" }
        let postLocation = CLLocation(latitude: post.coordinate.latitude, longitude: post.coordinate.longitude)
        let distanceInMeters = userLocation.distance(from: postLocation)
        
        let formatter = LengthFormatter()
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter.string(fromMeters: distanceInMeters)
    }
    
    private func findChatSession() -> ChatSession {
        // Find the helper associated with the post author
        guard let helper = MockData.topHelpers.first(where: { $0.id == post.authorId }) else {
            // Return a default/empty session if no match is found
            return ChatSession(participantName: "Unknown", participantAvatar: "person.crop.circle", messages: [], unreadCount: 0, isOnline: false)
        }
        
        // Find the chat session that includes the helper's name
        if let session = MockData.chatSessions.first(where: { $0.participantName.contains(helper.name) }) {
            return session
        }
        
        // If no existing session, create a new one
        return ChatSession(participantName: helper.name, participantAvatar: helper.avatarName, messages: [], unreadCount: 0, isOnline: helper.isVerified)
    }
}

private struct InfoBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(white: 0.95))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .foregroundColor(.black)
    }
}

#Preview {
    NavigationView {
        PostDetailView(post: MockData.posts[0])
    }
} 