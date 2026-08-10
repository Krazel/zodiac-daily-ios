import SwiftUI
import ZodiacDailyCore

/// Final visual implementation of the owner-approved C2 Today reference.
struct TodayView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showsSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        masthead
                        signMenu
                        dailyContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 34)
                    .frame(maxWidth: 650)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await model.refreshDailyCard()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView()
        }
    }

    private var masthead: some View {
        VStack(spacing: 9) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.45))
                    .frame(width: 42, height: 1)
                Text("✦")
                    .foregroundStyle(ZodiacPalette.gold)
                    .font(.title2)
                    .accessibilityHidden(true)
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.45))
                    .frame(width: 42, height: 1)
            }

            Text("ZODIAC DAILY")
                .font(.system(.largeTitle, design: .serif, weight: .medium))
                .tracking(3)
                .foregroundStyle(ZodiacPalette.paleGold)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            Text(formattedDay)
                .font(.subheadline.weight(.medium))
                .tracking(4)
                .foregroundStyle(ZodiacPalette.lavender)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var signMenu: some View {
        if let selectedSign = model.selectedSign {
            Menu {
                ForEach(ZodiacSign.allCases, id: \.self) { sign in
                    Button {
                        model.select(sign)
                    } label: {
                        Label(sign.displayName, systemImage: sign == selectedSign ? "checkmark" : "circle")
                    }
                }

                Divider()

                Button("About & Settings", systemImage: "gearshape") {
                    showsSettings = true
                }
            } label: {
                HStack(spacing: 18) {
                    Text(selectedSign.symbol)
                        .font(.system(size: 39, weight: .light))
                    Text(selectedSign.displayName.uppercased())
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                    Image(systemName: "chevron.down")
                        .font(.body.weight(.medium))
                }
                .foregroundStyle(ZodiacPalette.paleGold)
                .padding(.horizontal, 24)
                .frame(minHeight: 64)
                .background(ZodiacPalette.midnight.opacity(0.72), in: Capsule())
                .overlay {
                    Capsule().stroke(ZodiacPalette.gold, lineWidth: 1)
                }
                .contentShape(Capsule())
            }
            .accessibilityLabel("Selected sign, \(selectedSign.displayName)")
            .accessibilityHint("Double-tap to choose another sign or open settings")
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        switch model.dailyState {
        case .idle, .loading:
            ProgressView("Preparing today’s card…")
                .tint(ZodiacPalette.gold)
                .foregroundStyle(ZodiacPalette.text)
                .frame(minHeight: 360)

        case .failed(let message):
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(ZodiacPalette.gold)
                    .accessibilityHidden(true)
                Text("Card unavailable")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                Button("Try Again") {
                    Task { await model.refreshDailyCard() }
                }
                .buttonStyle(.borderedProminent)
                .tint(ZodiacPalette.gold)
            }
            .foregroundStyle(ZodiacPalette.text)
            .padding(.horizontal, 24)
            .frame(minHeight: 360)
            .accessibilityElement(children: .contain)

        case .loaded(let horoscope):
            VStack(spacing: 20) {
                DailyCardView(horoscope: horoscope)

                Button {
                    Task { await model.toggleCurrentCardSaved() }
                } label: {
                    Label(
                        model.isCurrentCardSaved ? "Saved" : "Save Card",
                        systemImage: model.isCurrentCardSaved ? "bookmark.fill" : "bookmark"
                    )
                    .font(.headline)
                    .textCase(.uppercase)
                    .tracking(2.3)
                    .frame(maxWidth: 270, minHeight: 54)
                }
                .buttonStyle(.plain)
                .foregroundStyle(ZodiacPalette.gold)
                .background(ZodiacPalette.midnight.opacity(0.9), in: Capsule())
                .overlay {
                    Capsule().stroke(ZodiacPalette.gold, lineWidth: 1)
                }
                .contentShape(Capsule())
                .accessibilityHint(
                    model.isCurrentCardSaved
                        ? "Removes this card from Saved"
                        : "Keeps an offline copy of this card in Saved"
                )

                if let message = model.persistenceMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("Save error: \(message)")
                }
            }
        }
    }

    private var formattedDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        formatter.dateFormat = "EEEE  ·  MMMM d"
        let date: Date
        if case .loaded(let horoscope) = model.dailyState,
           let editionDate = horoscope.day.startDate(in: .current) {
            date = editionDate
        } else {
            date = Date()
        }
        return formatter.string(from: date).uppercased()
    }
}
