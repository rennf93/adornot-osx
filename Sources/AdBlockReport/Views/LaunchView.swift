import SwiftUI

struct LaunchView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack(spacing: 16) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)
                Text("AdBlock Report")
                    .font(.title.bold())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
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
