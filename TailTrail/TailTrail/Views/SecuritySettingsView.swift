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
                        Image("backicon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                    Text("Security")
                        .font(.title2.bold())
                    Spacer()
                    Image("backicon").opacity(0) // For balance
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