import SwiftUI

struct SettingsView: View {
    @AppStorage("layoutStyle") private var layoutStyle: String = "2014"
    var body: some View {
        Form {
            Section("Character Sheet") {
                Picker("Layout", selection: $layoutStyle) {
                    Text("2014").tag("2014")
                    Text("2024").tag("2024")
                }
                .pickerStyle(.segmented)
            }
            Section {
                NavigationLink("About") { AboutView() }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
