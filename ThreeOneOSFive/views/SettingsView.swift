import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.spanish.rawValue
    @AppStorage("ksensi_login_unlocked") private var isLoggedIn = false
    @AppStorage("oni_akuma_theme_color") private var currentThemeRaw = "cyan"

    private var activeTheme: AppColorTheme {
        AppColorTheme(rawValue: currentThemeRaw) ?? .cyan
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        AppLogo(size: 52)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Dev ~ KSENSI").font(.headline.weight(.bold))
                            Text("Dev ksensi • Zalo: 0865979853")
                                .font(.caption.weight(.semibold).monospaced())
                                .foregroundStyle(activeTheme.primaryColor)
                            Text(language.text("settings.developer_version", appVersion))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Theme Color Customizer
                Section("GIAO DIỆN MÀU SẮC (THEME)") {
                    ForEach(AppColorTheme.allCases) { theme in
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                currentThemeRaw = theme.rawValue
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(theme.primaryColor)
                                    .frame(width: 18, height: 18)
                                    .shadow(color: theme.primaryColor.opacity(0.4), radius: 4)

                                Text(language.text(theme.displayName))
                                    .font(.subheadline.weight(currentThemeRaw == theme.rawValue ? .bold : .regular))
                                    .foregroundStyle(currentThemeRaw == theme.rawValue ? .white : .secondary)

                                Spacer()

                                if currentThemeRaw == theme.rawValue {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(theme.primaryColor)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section(language.text("settings.language")) {
                    Picker(language.text("settings.language"), selection: $languageCode) {
                        ForEach(AppLanguage.allCases) { option in
                            Text(option.nativeName).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Section(language.text("settings.session")) {
                    Button(role: .destructive) {
                        isLoggedIn = false
                        dismiss()
                    } label: {
                        Label(language.text("settings.sign_out"), systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                Section(language.text("common.device")) {
                    LabeledContent(language.text("dashboard.hardware_model"), value: AppInfo.displayMachineName)
                    LabeledContent(language.text("settings.ios_version"), value: "\(AppInfo.osVersion) (\(AppInfo.osBuild))")
                }

                Section("KHAI THÁC LỖ HỔNG HỆ THỐNG") {
                    HStack {
                        Text("Trạng Thái")
                        Spacer()
                        Text(language.text(appState.isSupported ? "Đã Kích Hoạt" : "Sẵn Sàng"))
                            .foregroundStyle(appState.isSupported ? Color.green : activeTheme.primaryColor)
                    }
                    LabeledContent("Nhân Khai Thác", value: "Exploit Kernel By OniAkuma")
                    LabeledContent("iOS 17", value: ExploitSupportPolicy.verifiedIOS17Range)
                    LabeledContent("iOS 18", value: ExploitSupportPolicy.verifiedIOS18Range)
                    LabeledContent("iOS 26", value: ExploitSupportPolicy.verifiedIOS26Range)
                }

                Section("HỖ TRỢ & CỘNG ĐỒNG") {
                    creditsRow(
                        name: "Developer & Hỗ Trợ Zalo (Chính Thức)",
                        role: "Zalo: 0865979853",
                        url: "https://zalo.me/0865979853"
                    )
                    creditsRow(
                        name: "Dev ksensi",
                        role: "Telegram",
                        url: "https://t.me/"
                    )
                    creditsRow(
                        name: "Nhóm Hỗ Trợ & Thảo Luận",
                        role: "Telegram",
                        url: "https://t.me/"
                    )
                }
            }
            .tint(activeTheme.primaryColor)
            .navigationTitle(language.text("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language.text("common.done")) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "AppReleaseDisplayVersion") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.1.1"
    }

    @ViewBuilder
    private func creditsRow(name: String, role: String, url: String) -> some View {
        if let destination = URL(string: url) {
            Link(destination: destination) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(language.text(name))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(language.text(role))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(activeTheme.primaryColor)
                        .frame(width: 28, height: 28)
                }
                .contentShape(Rectangle())
            }
        }
    }

}
