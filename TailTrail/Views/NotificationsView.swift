import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = NotificationsViewModel()
    @State private var selectedFilter: NotificationFilter = .all
    
    enum NotificationFilter {
        case all, petAlerts, messages, likes
    }
    
    private var filteredNotifications: [AppNotification] {
        switch selectedFilter {
        case .all:
            return viewModel.notifications
        case .petAlerts:
            return viewModel.notifications.filter { $0.type == .newAlert || $0.type == .petFound }
        case .messages:
            return viewModel.notifications.filter { $0.type == .newMessage }
        case .likes:
            return viewModel.notifications.filter { $0.type == .postLiked }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                filterButtons
                notificationList
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
            }
            
            Spacer()
            
            Text("Notifications")
                .font(.largeTitle.bold())
            
            Spacer()
        }
        .padding()
        .foregroundColor(.black)
    }

    private var filterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                FilterButton(title: "All", filter: .all, selection: $selectedFilter)
                FilterButton(title: "Pet Alerts", filter: .petAlerts, selection: $selectedFilter)
                FilterButton(title: "Messages", filter: .messages, selection: $selectedFilter)
                FilterButton(title: "Likes", filter: .likes, selection: $selectedFilter)
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }

    private var notificationList: some View {
        List(filteredNotifications) { notification in
            NotificationRowView(notification: notification)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding(.vertical, 4)
                .foregroundColor(.black)
        }
        .listStyle(.plain)
    }
}

// MARK: - Subviews

private struct FilterButton: View {
    let title: String
    let filter: NotificationsView.NotificationFilter
    @Binding var selection: NotificationsView.NotificationFilter

    var isSelected: Bool { filter == selection }

    var body: some View {
        Button(action: {
            withAnimation(.bouncy) { selection = filter }
        }) {
            Text(title)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? .black : Color.white)
                .foregroundColor(isSelected ? .white : .black)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.black, lineWidth: 1.5))
        }
    }
}

#Preview {
    NotificationsView()
} 