import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Binding var isPvPUnlocked: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 25) {
            // Title
            Text("Unlock Player vs Player Mode")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Illustration
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 180, height: 180)

                Image(systemName: "person.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
            }
            .padding(.vertical, 20)

            // Description
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "checkmark.circle.fill", text: "Play against a friend on the same device")
                FeatureRow(icon: "checkmark.circle.fill", text: "Take turns making moves")
                FeatureRow(icon: "checkmark.circle.fill", text: "Enjoy competitive gameplay")
                FeatureRow(icon: "checkmark.circle.fill", text: "One-time purchase")
            }
            .padding(.horizontal)

            Spacer()

            // Purchase button
            Button(action: {
                isProcessing = true

                // Here you would have real StoreKit code for purchase
                // Simulating a successful purchase after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isPvPUnlocked = true
                    isProcessing = false

                    // Save the state
                    UserDefaults.standard.set(true, forKey: "isPvPUnlocked")

                    // Sound effect for successful purchase
                    SoundManager.shared.playSound(.win)
                    SoundManager.shared.playHeavyHaptic()

                    // Close the sheet
                    dismiss()
                }
            }) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 10)
                    }

                    Text(isProcessing ? "Processing..." : "Unlock for $0.99")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .disabled(isProcessing)

            // Back button
            Button(action: {
                dismiss()
            }) {
                Text("Maybe Later")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
        }
        .padding()
        .onAppear {
            // Check if already unlocked
            if UserDefaults.standard.bool(forKey: "isPvPUnlocked") {
                isPvPUnlocked = true
                dismiss()
            }
        }
    }
}

struct FeatureRow: View {
    var icon: String
    var text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.system(size: 22))

            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPvPUnlocked = false

        var body: some View {
            PurchaseView(isPvPUnlocked: $isPvPUnlocked)
        }
    }

    return PreviewWrapper()
}
