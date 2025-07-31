import SwiftUI

struct HelpAndSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Custom header with back button
            HStack {
                Button(action: { 
                    dismiss()
                }) {
                    Image("backicon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Help & Support")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            
            Form {
                Section(header: Text("CONTACT US")) {
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
                
                Section(header: Text("FREQUENTLY ASKED QUESTIONS")) {
                    Text("How do I report a post?")
                    Text("How do I block a user?")
                    Text("How can I change my password?")
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        HelpAndSupportView()
    }
} 