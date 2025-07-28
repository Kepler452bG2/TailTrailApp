import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 10)
                
                Group {
                    Text("Last updated: July 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    
                    Text("By downloading, installing, or using the TailTrail mobile application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.")
                        .font(.body)
                    
                    Text("2. Description of Service")
                        .font(.headline)
                    
                    Text("TailTrail is a social networking platform designed to help pet owners find their lost pets and connect with people who have found animals. The service allows users to:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Create posts about lost or found pets")
                        Text("• Upload photos and information about pets")
                        Text("• Communicate with other users through chat")
                        Text("• View posts from nearby locations")
                        Text("• Report and block inappropriate content")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("3. User Accounts")
                        .font(.headline)
                    
                    Text("To use certain features of TailTrail, you must create an account. You are responsible for:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Maintaining the confidentiality of your account")
                        Text("• All activities that occur under your account")
                        Text("• Providing accurate and complete information")
                        Text("• Notifying us immediately of any unauthorized use")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("4. User Content")
                        .font(.headline)
                    
                    Text("You retain ownership of content you post, but grant TailTrail a license to use, display, and distribute your content for the purpose of providing the service. You agree not to post:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• False or misleading information")
                        Text("• Content that violates others' rights")
                        Text("• Inappropriate, offensive, or harmful content")
                        Text("• Spam or commercial advertisements")
                        Text("• Personal information of others without consent")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("5. Prohibited Activities")
                        .font(.headline)
                    
                    Text("You agree not to:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Use the service for illegal purposes")
                        Text("• Harass, abuse, or harm other users")
                        Text("• Attempt to gain unauthorized access to the service")
                        Text("• Interfere with the proper functioning of the app")
                        Text("• Use automated systems to access the service")
                    }
                    .font(.body)
                    .padding(.leading, 20)
                    
                    Text("6. Privacy")
                        .font(.headline)
                    
                    Text("Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the service, to understand our practices.")
                        .font(.body)
                    
                    Text("7. Location Services")
                        .font(.headline)
                    
                    Text("TailTrail uses location services to show you relevant posts from your area. You can control location access in your device settings. By using the app, you consent to the collection and use of location data as described in our Privacy Policy.")
                        .font(.body)
                    
                    Text("8. Intellectual Property")
                        .font(.headline)
                    
                    Text("The TailTrail app, including its design, features, and content, is owned by TailTrail and protected by intellectual property laws. You may not copy, modify, or distribute any part of the service without our permission.")
                        .font(.body)
                    
                    Text("9. Disclaimers")
                        .font(.headline)
                    
                    Text("TailTrail is provided 'as is' without warranties of any kind. We do not guarantee that the service will be uninterrupted, secure, or error-free. We are not responsible for the accuracy of user-generated content.")
                        .font(.body)
                    
                    Text("10. Limitation of Liability")
                        .font(.headline)
                    
                    Text("To the maximum extent permitted by law, TailTrail shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.")
                        .font(.body)
                    
                    Text("11. Termination")
                        .font(.headline)
                    
                    Text("We may terminate or suspend your account at any time for violations of these terms. You may also delete your account at any time through the app settings.")
                        .font(.body)
                    
                    Text("12. Changes to Terms")
                        .font(.headline)
                    
                    Text("We may update these Terms of Service from time to time. We will notify you of any changes by posting the new terms in the app. Your continued use of the service after changes constitutes acceptance of the new terms.")
                        .font(.body)
                    
                    Text("13. Governing Law")
                        .font(.headline)
                    
                    Text("These terms are governed by the laws of the jurisdiction where TailTrail operates. Any disputes will be resolved in the appropriate courts of that jurisdiction.")
                        .font(.body)
                    
                    Text("14. Contact Information")
                        .font(.headline)
                    
                    Text("If you have any questions about these Terms of Service, please contact us at:")
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
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsOfServiceView()
        }
    }
} 