import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color FED3A4
                Color(hex: "FED3A4")
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Welcome image in center
                    Image("welcometo ")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Pet image at bottom
                    Image("PetsAsset")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .padding(.bottom, 20)
                    
                    // Login and Register buttons
                    HStack(spacing: 40) {
                        Button(action: {
                            showLogin = true
                        }) {
                            ZStack {
                                Image("login")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                
                                Text("login".localized())
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        Button(action: {
                            showRegister = true
                        }) {
                            ZStack {
                                Image("register")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                
                                Text("register".localized())
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Terms Support
                    Text("terms_support".localized())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegistrationView()
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(LanguageManager.shared)
} 