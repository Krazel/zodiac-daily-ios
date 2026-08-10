import SwiftUI
import ZodiacDailyCore

/// Final visual implementation of the owner-approved C2 Today reference.
struct TodayView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showsSettings: Bool

    init() {
        _showsSettings = State(initialValue: AppModel.visualQAState == .settings)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground()

                ScrollView {
                    VStack(spacing: 0) {
                        masthead

                        signMenu

                        dailyContent
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                    .frame(maxWidth: 430)
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
        VStack(spacing: 8) {
            HStack(spacing: 11) {
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.45))
                    .frame(width: 34, height: 0.75)
                Image(systemName: "sparkle")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(ZodiacPalette.gold)
                    .accessibilityHidden(true)
                Rectangle()
                    .fill(ZodiacPalette.gold.opacity(0.45))
                    .frame(width: 34, height: 0.75)
            }

            Text("ZODIAC DAILY")
                .font(.custom("Didot", size: 28, relativeTo: .title))
                .tracking(2.8)
                .foregroundStyle(ZodiacPalette.paleGold)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            Text(formattedDay)
                .font(.system(size: 13, weight: .medium))
                .tracking(3.6)
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
                        .font(.system(size: 34, weight: .ultraLight))
                    Text(selectedSign.displayName.uppercased())
                        .font(.custom("Didot", size: 20, relativeTo: .title3).weight(.semibold))
                        .tracking(2.2)
                        .minimumScaleFactor(0.62)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(ZodiacPalette.paleGold)
                .padding(.horizontal, 22)
                .frame(width: 232)
                .frame(minHeight: 52)
                .background(ZodiacPalette.midnight.opacity(0.72), in: Capsule())
                .overlay {
                    Capsule().stroke(ZodiacPalette.gold, lineWidth: 1)
                }
                .contentShape(Capsule())
            }
            .padding(.top, 12)
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
                .frame(maxWidth: 330, minHeight: 420)
                .padding(.top, 24)

        case .failed(let message):
            VStack(spacing: 10) {
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
            .frame(maxWidth: 330, minHeight: 420)
            .padding(.top, 24)
            .accessibilityElement(children: .contain)

        case .loaded(let horoscope):
            VStack(spacing: 6) {
                DailyCardView(horoscope: horoscope)
                    .frame(maxWidth: 330)

                Button {
                    Task { await model.toggleCurrentCardSaved() }
                } label: {
                    Label(
                        model.isCurrentCardSaved ? "Saved" : "Save Card",
                        systemImage: model.isCurrentCardSaved ? "bookmark.fill" : "bookmark"
                    )
                    .font(.system(size: 14, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(2.5)
                    .frame(width: 176)
                    .frame(minHeight: 45)
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
            .padding(.top, 6)
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
