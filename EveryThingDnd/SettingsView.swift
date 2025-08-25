import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
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
