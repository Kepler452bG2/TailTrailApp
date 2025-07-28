import SwiftUI

struct LocalizedOfflineBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
            Text("you_are_offline".localized())
                .foregroundColor(.white)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.orange)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 100) // Avoid tab bar
    }
}

struct LocalizedErrorBanner: View {
    let message: String
    let onRetry: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.white)
                Text("error".localized())
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            HStack {
                Button("retry".localized()) {
                    onRetry()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(6)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.red)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 100) // Avoid tab bar
    }
} 