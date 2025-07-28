import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 10)
                
                Group {
                    Text("Last updated: July 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("1. Information We Collect")
                        .font(.headline)
                    
                    Text("We collect information you provide directly to us, such as when you create an account, post about lost or found pets, or contact us for support. This may include:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Email address and password for account creation")
                        Text("• Pet information (name, breed, age, photos)")
                        Text("• Location data to show nearby pets")
                        Text("• Contact information for pet owners")
                        Text("• Messages sent through the chat feature")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("2. How We Use Your Information")
                        .font(.headline)
                    
                    Text("We use the information we collect to:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Provide and maintain our pet finding service")
                        Text("• Connect pet owners with people who found their pets")
                        Text("• Send notifications about relevant posts")
                        Text("• Improve our app and user experience")
                        Text("• Respond to your support requests")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("3. Location Services")
                        .font(.headline)
                    
                    Text("TailTrail uses your device's location to show you nearby lost or found pets. You can control location access in your device settings. We only access location when the app is actively being used.")
                        .font(.body)
                    
                    Text("4. Photo and Media")
                        .font(.headline)
                    
                    Text("When you upload photos of pets, we store them securely on our servers to help identify lost pets. Photos are only shared with other users through the app's posting system.")
                        .font(.body)
                    
                    Text("5. Data Sharing")
                        .font(.headline)
                    
                    Text("We do not sell, trade, or rent your personal information to third parties. We may share information only in these limited circumstances:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• With your explicit consent")
                        Text("• To comply with legal obligations")
                        Text("• To protect our rights and safety")
                        Text("• With service providers who help us operate the app")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("6. Data Security")
                        .font(.headline)
                    
                    Text("We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.")
                        .font(.body)
                    
                    Text("7. Your Rights")
                        .font(.headline)
                    
                    Text("You have the right to:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Access your personal information")
                        Text("• Update or correct your information")
                        Text("• Delete your account and data")
                        Text("• Opt out of certain communications")
                        Text("• Request data portability")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("8. Children's Privacy")
                        .font(.headline)
                    
                    Text("TailTrail is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you are a parent and believe your child has provided us with personal information, please contact us.")
                        .font(.body)
                    
                    Text("9. Changes to This Policy")
                        .font(.headline)
                    
                    Text("We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the app and updating the 'Last updated' date.")
                        .font(.body)
                    
                    Text("10. Contact Us")
                        .font(.headline)
                    
                    Text("If you have any questions about this Privacy Policy, please contact us at:")
                        .font(.body)
                    
                    Text("Email: assellyzh@gmail.com")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Text("© 2025 TailTrail. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyPolicyView()
        }
    }
} 