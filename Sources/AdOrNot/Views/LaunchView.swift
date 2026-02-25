import SwiftUI

struct LaunchView: View {
    @State private var isActive = false
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var logoRotation: Double = -10

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: Theme.spacingLG) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                        .rotationEffect(.degrees(logoRotation))
                        .shadow(color: Theme.brandBlue.opacity(0.5), radius: 20, y: 8)

                    VStack(spacing: Theme.spacingSM) {
                        Text("AdOrNot")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Test your ad blocker")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .opacity(textOpacity)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                    iconScale = 1.0
                    iconOpacity = 1.0
                    logoRotation = 0
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                    textOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchView()
        .modelContainer(.preview)
}
