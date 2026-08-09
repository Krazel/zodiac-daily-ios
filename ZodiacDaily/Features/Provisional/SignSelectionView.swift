import SwiftUI
import ZodiacDailyCore

/// PROVISIONAL internal implementation. Its final layout and art remain gated
/// on a complete Sign Selection image and explicit owner approval.
struct SignSelectionView: View {
    @EnvironmentObject private var model: AppModel
    let requiresSelection: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(ZodiacSign.allCases, id: \.self) { sign in
                Button {
                    model.select(sign)
                    if !requiresSelection {
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 18) {
                        Text(sign.symbol)
                            .font(.largeTitle)
                            .frame(width: 48)
                        Text(sign.displayName)
                            .font(.title3)
                        Spacer()
                        if model.selectedSign == sign {
                            Image(systemName: "checkmark")
                                .foregroundStyle(ZodiacPalette.gold)
                        }
                    }
                    .frame(minHeight: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose \(sign.displayName)")
                .accessibilityValue(model.selectedSign == sign ? "Selected" : "Not selected")
                .accessibilityAddTraits(model.selectedSign == sign ? .isSelected : [])
            }
            .scrollContentBackground(.hidden)
            .background(MidnightBackground())
            .navigationTitle(requiresSelection ? "Choose your sign" : "Change sign")
            .toolbar {
                if !requiresSelection {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
        .interactiveDismissDisabled(requiresSelection)
    }
}
