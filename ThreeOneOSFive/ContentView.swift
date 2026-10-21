import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject private var systemStatus = SystemStatusService.shared
    @AppStorage("ksensi_login_unlocked") private var isLoggedIn = false
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashLoadingView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isShowingSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            } else {
                Group {
                    if systemStatus.isSystemMaintenance {
                        SystemMaintenanceGateView()
                    } else if isLoggedIn {
                        MainInjectorView()
                    } else {
                        LoginView {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
                                isLoggedIn = true
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
    }
}
