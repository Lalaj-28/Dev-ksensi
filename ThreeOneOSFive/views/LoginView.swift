import SwiftUI

struct LoginView: View {
    let onUnlock: () -> Void

    @Environment(\.appLanguage) private var language
    @AppStorage("ksensi_login_accent") private var selectedAccentID = "blue"
    @AppStorage("ksensi_login_glow") private var glow = 0.72
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.spanish.rawValue
    @State private var enteredKey = ""
    @State private var isKeyVisible = false
    @State private var showsAppearance = false
    @State private var showsError = false
    @FocusState private var keyFieldFocused: Bool

    private var accent: LoginAccent {
        LoginAccent.all.first { $0.id == selectedAccentID } ?? LoginAccent.all[0]
    }

    var body: some View {
        ZStack {
            Image("SplashLogo")
                .resizable()
                .scaledToFill()
                .blur(radius: 30)
                .overlay(Color.black.opacity(0.72))
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.15), .black.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()

            Circle()
                .fill(accent.color.opacity(glow * 0.24))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 135, y: -265)
                .allowsHitTesting(false)

            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Spacer()
                        languageMenu
                    }

                    VStack(spacing: 14) {
                        Image("SplashLogo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 104, height: 104)
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .stroke(accent.color.opacity(0.8), lineWidth: 1.5)
                            }
                            .shadow(color: accent.color.opacity(glow * 0.8), radius: 26, y: 8)

                        VStack(spacing: 7) {
                            Text("KSENSI")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .tracking(3)
                                .foregroundStyle(.white)

                            Text(language.text("login.subtitle"))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.68))
                        }
                    }
                    .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 16) {
                        Label(language.text("login.key_label"), systemImage: "key.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.86))

                        HStack(spacing: 12) {
                            Group {
                                if isKeyVisible {
                                    TextField(language.text("login.key_placeholder"), text: $enteredKey)
                                        .focused($keyFieldFocused)
                                } else {
                                    SecureField(language.text("login.key_placeholder"), text: $enteredKey)
                                        .focused($keyFieldFocused)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.go)
                            .onSubmit(unlock)
                            .foregroundStyle(.white)

                            Button {
                                isKeyVisible.toggle()
                            } label: {
                                Image(systemName: isKeyVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.white.opacity(0.65))
                                    .frame(width: 36, height: 42)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(language.text(isKeyVisible ? "login.hide_key" : "login.show_key"))
                        }
                        .padding(.horizontal, 15)
                        .frame(height: 54)
                        .background(.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(showsError ? Color.red.opacity(0.85) : .white.opacity(0.12), lineWidth: 1)
                        }

                        if showsError {
                            Text(language.text("login.error"))
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.red.opacity(0.95))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Button(action: unlock) {
                            HStack(spacing: 10) {
                                Text(language.text("login.enter"))
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [accent.color, accent.color.opacity(0.72)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .shadow(color: accent.color.opacity(glow * 0.55), radius: 20, y: 8)
                        }
                        .buttonStyle(.plain)
                        .disabled(enteredKey.isEmpty)
                        .opacity(enteredKey.isEmpty ? 0.55 : 1)
                    }
                    .padding(22)
                    .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(.white.opacity(0.11), lineWidth: 1)
                    }
                    .frame(maxWidth: 440)

                    DisclosureGroup(language.text("login.personalize"), isExpanded: $showsAppearance) {
                        VStack(alignment: .leading, spacing: 17) {
                            HStack(spacing: 13) {
                                ForEach(LoginAccent.all) { option in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedAccentID = option.id
                                        }
                                    } label: {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [option.color, option.color.opacity(0.68)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 30, height: 30)
                                            .overlay {
                                                if option.id == selectedAccentID {
                                                    Image(systemName: "checkmark")
                                                        .font(.caption.bold())
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                            .overlay {
                                                Circle().stroke(.white.opacity(0.32), lineWidth: 1)
                                            }
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(language.text(option.titleKey))
                                }
                            }

                            HStack {
                                Text(language.text("login.intensity"))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.72))
                                Slider(value: $glow, in: 0.2...1)
                                    .tint(accent.color)
                            }
                        }
                        .padding(.top, 12)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.86))
                    .padding(18)
                    .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(maxWidth: 440)

                    Text("Dev ~ KSENSI")
                        .font(.caption.weight(.semibold))
                        .tracking(1.3)
                        .foregroundStyle(.white.opacity(0.48))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private var languageMenu: some View {
        Menu {
            Picker(language.text("login.language"), selection: $languageCode) {
                ForEach(AppLanguage.allCases) { option in
                    Text(option.nativeName).tag(option.rawValue)
                }
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "globe")
                Text(language.nativeName)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.88))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.white.opacity(0.09), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
        }
        .tint(accent.color)
    }

    private func unlock() {
        let cleanedKey = enteredKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedKey == "Ksensi100" else {
            withAnimation(.easeInOut(duration: 0.2)) {
                showsError = true
            }
            return
        }
        showsError = false
        onUnlock()
    }
}

private struct LoginAccent: Identifiable {
    let id: String
    let color: Color
    let titleKey: String

    static let all: [LoginAccent] = [
        LoginAccent(id: "blue", color: .blue, titleKey: "login.color.blue"),
        LoginAccent(id: "cyan", color: .cyan, titleKey: "login.color.cyan"),
        LoginAccent(id: "purple", color: .purple, titleKey: "login.color.violet"),
        LoginAccent(id: "pink", color: .pink, titleKey: "login.color.rose"),
        LoginAccent(id: "green", color: .green, titleKey: "login.color.green")
    ]
}
