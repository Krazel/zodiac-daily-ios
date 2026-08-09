import SwiftUI

/// PROVISIONAL internal implementation. Settings/About remains a system Form
/// until its final screen image is explicitly approved.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showsSignSelection = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Your sign") {
                    Button("Change zodiac sign") {
                        showsSignSelection = true
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "Zodiac Daily")
                    LabeledContent("Language", value: "English")
                }

                Section("Privacy") {
                    Text("Your selected sign and saved cards remain on this iPhone. Zodiac Daily has no account, analytics, advertising, or network service.")
                }

                Section("Please note") {
                    Text("Horoscope readings are provided for entertainment and reflection.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showsSignSelection) {
            SignSelectionView(requiresSelection: false)
        }
    }
}
