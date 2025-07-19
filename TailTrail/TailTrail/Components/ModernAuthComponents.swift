import SwiftUI

struct ModernAuthTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(isFocused ? .accentColor : .gray)
                .padding(.leading, 12)
            
            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .focused($isFocused)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.accentColor : Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
} 