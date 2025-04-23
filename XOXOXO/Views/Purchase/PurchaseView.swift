import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Binding var isPvPUnlocked: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var isProcessing = false
    @State private var appearAnimation = false
    
    private var isDark: Bool {
        colorScheme == .dark
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Title
            Text("Unlock Player vs Player Mode")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 20)
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.5),
                                        Color.purple.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .background(
                        Circle()
                            .fill(isDark ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
                            .blur(radius: 10)
                    )
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .opacity(appearAnimation ? 1 : 0)
                    .scaleEffect(appearAnimation ? 1 : 0.8)
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
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 20)
            
            Spacer()
            
            // Purchase button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isProcessing = true
                }
                
                // Here you would have real StoreKit code for purchase
                // Simulating a successful purchase after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    purchaseManager.unlockPvP()
                    isPvPUnlocked = true
                    isProcessing = false
                    
                    // Sound effect for successful purchase
                    SoundManager.shared.playSound(.win)
                    SoundManager.shared.playHeavyHaptic()
                    
                    // Close the sheet with animation
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dismiss()
                    }
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.8),
                                        Color.purple.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
            }
            .disabled(isProcessing)
            .scaleEffect(isProcessing ? 0.95 : 1)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 20)
            
            // Back button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    dismiss()
                }
            }) {
                Text("Maybe Later")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
            .opacity(appearAnimation ? 1 : 0)
        }
        .padding()
        .background(
            ZStack {
                if isDark {
                    Color.black.opacity(0.7)
                } else {
                    Color.white.opacity(0.7)
                }
                
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()
        )
        .onAppear {
            // Check if already unlocked
            if UserDefaults.standard.bool(forKey: "isPvPUnlocked") {
                isPvPUnlocked = true
                dismiss()
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    appearAnimation = true
                }
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
                .foregroundColor(.blue)
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
