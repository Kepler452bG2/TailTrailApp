import SwiftUI

struct RecentCaseCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading) {
            header
            
            Spacer()
            
            Text(post.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.primaryText)
            
            Text(post.locationName)
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
            
            footer
        }
        .padding()
        .frame(width: 220, height: 180)
        .background(Color.theme.cardBackground)
        .cornerRadius(20)
    }
    
    private var header: some View {
        HStack {
            Text(post.status.rawValue)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (post.status == .lost ? Color.red : Color.green).opacity(0.2)
                )
                .foregroundColor(post.status == .lost ? .red : .green)
                .cornerRadius(8)
            
            Spacer()
            
            Image(systemName: post.species.iconName)
                .foregroundColor(Color.theme.secondaryText)
            
            Text(post.timeAgo.components(separatedBy: " ").prefix(2).joined(separator: " "))
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
        }
    }
    
    private var footer: some View {
        HStack {
            Image(systemName: "magnifyingglass.circle") // Placeholder for status icon
            Text(post.status == .lost ? "Active search" : "Owner contacted")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
        }
    }
}

#Preview {
    RecentCaseCardView(post: MockData.posts[0])
        .padding()
        .background(Color.theme.background)
        .preferredColorScheme(.dark)
} 