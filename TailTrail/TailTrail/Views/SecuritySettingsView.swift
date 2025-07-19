import SwiftUI

struct SecuritySettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack {
                // Custom Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                    }
                    Spacer()
                    Text("Security")
                        .font(.title2.bold())
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0) // For balance
                }
                .padding()
                .background(Color.white)

                // Content can be added here in the future

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct SecuritySettingsView_Previews: PreviewProvider {
    static var previews: some View {
    SecuritySettingsView()
    }
} 