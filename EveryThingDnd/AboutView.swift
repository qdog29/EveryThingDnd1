import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("About")
                    .font(.largeTitle)
                Text("This work includes material taken from the System Reference Document 5.1 (\"SRD 5.1\") by Wizards of the Coast LLC and available at https://dnd.wizards.com/resources/systems-reference-document. The SRD 5.1 is licensed under the Creative Commons Attribution 4.0 International License available at https://creativecommons.org/licenses/by/4.0/.")
                Link("Creative Commons Attribution 4.0 License", destination: URL(string: "https://creativecommons.org/licenses/by/4.0/")!)
            }
            .padding()
        }
    }
}

#Preview {
    AboutView()
}
