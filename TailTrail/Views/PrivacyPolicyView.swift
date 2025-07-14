import SwiftUI

struct PrivacyPolicyView: View {
    private let privacyPolicyText = """
    **Last Updated: July 13, 2025**

    Welcome to TailTrail! Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

    **1. Information We Collect**

    We may collect information about you in a variety of ways. The information we may collect via the Application includes:

    - **Personal Data:** Personally identifiable information, such as your name, shipping address, email address, and telephone number, and demographic information, such as your age, gender, hometown, and interests, that you voluntarily give to us when you register with the Application.
    
    - **Geo-Location Information:** We may request access or permission to and track location-based information from your mobile device, either continuously or while you are using the Application, to provide location-based services.

    - **User-Generated Content:** We collect content that you submit to the app, including photos, comments, and posts.

    **2. Use of Your Information**

    Having accurate information permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:

    - Create and manage your account.
    - Email you regarding your account or order.
    - Enable user-to-user communications.
    - Monitor and analyze usage and trends to improve your experience with the Application.

    **3. Disclosure of Your Information**

    We may share information we have collected about you in certain situations. Your information may be disclosed as follows:

    - **By Law or to Protect Rights:** If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies...

    **Contact Us**

    If you have questions or comments about this Privacy Policy, please contact us at: support@tailtrail.com
    """

    var body: some View {
        ScrollView {
            Text(.init(privacyPolicyText)) // Using AttributedString for Markdown
                .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
} 