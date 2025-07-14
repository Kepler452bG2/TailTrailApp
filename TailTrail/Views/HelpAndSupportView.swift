import SwiftUI

struct HelpAndSupportView: View {
    var body: some View {
        Form {
            Section(header: Text("Contact Us")) {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Support Email")
                    Spacer()
                    Link("support@tailtrail.com", destination: URL(string: "mailto:support@tailtrail.com")!)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Image(systemName: "globe")
                    Text("Website")
                    Spacer()
                    Link("www.tailtrail.com", destination: URL(string: "https://www.tailtrail.com")!)
                        .foregroundColor(.blue)
                }
            }
            
            Section(header: Text("Frequently Asked Questions")) {
                Text("How do I report a post?")
                Text("How do I block a user?")
                Text("How can I change my password?")
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HelpAndSupportView()
    }
} 