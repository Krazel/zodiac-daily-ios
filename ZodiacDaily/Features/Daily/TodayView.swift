import SwiftUI
import ZodiacDailyCore

/// Stationary implementation of the owner-approved C6 Today composition.
struct TodayView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.locale) private var locale
    @State private var showsSettings: Bool

    init() {
        _showsSettings = State(initialValue: AppModel.visualQAState == .settings)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MidnightBackground(dimming: 0.35)

                // Today has no scroll container at regular text sizes. The
                // approved composition scales as one piece on shorter devices
                // so the card and Save action remain visible without dragging.
                StationaryFittedVerticalView {
                    todayLayout
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView()
        }
    }

    private var todayLayout: some View {
        VStack(spacing: 0) {
            masthead
            dailyContent
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .frame(maxWidth: 430)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            Button {
                showsSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(ZodiacPalette.gold)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(appLocalized("common.settings", locale: locale))
            .accessibilityHint(appLocalized("Opens app settings", locale: locale))
            .padding(.trailing, 4)
            .offset(y: -1)
        }
    }

    private var masthead: some View {
        VStack(spacing: 5) {
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
                .font(ZodiacTypography.editorial(22))
                .tracking(1.4)
                .foregroundStyle(ZodiacPalette.paleGold)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            Text(formattedDay)
                .font(.system(size: 12, weight: .medium))
                .tracking(3.2)
                .foregroundStyle(ZodiacPalette.lavender)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var dailyContent: some View {
        switch model.dailyState {
        case .idle, .loading:
            ProgressView("Preparing today’s card…")
                .tint(ZodiacPalette.gold)
                .foregroundStyle(ZodiacPalette.text)
                .frame(maxWidth: 346, minHeight: 560)
                .padding(.top, 14)

        case .failed:
            VStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(ZodiacPalette.gold)
                    .accessibilityHidden(true)
                Text("Card unavailable")
                    .font(.headline)
                Text(appLocalized("app.error.daily_unavailable", locale: locale))
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
            .frame(maxWidth: 346, minHeight: 560)
            .padding(.top, 14)
            .accessibilityElement(children: .contain)

        case .loaded(let horoscope):
            VStack(spacing: 12) {
                ViewThatFits(in: .horizontal) {
                    dailyCard(horoscope: horoscope, width: 346, height: 560, artworkHeight: 324)
                    dailyCard(horoscope: horoscope, width: 332, height: 538, artworkHeight: 312)
                    dailyCard(horoscope: horoscope, width: 288, height: 467, artworkHeight: 270)
                }

                Button {
                    Task { await model.toggleCurrentCardSaved() }
                } label: {
                    Label(
                        model.isCurrentCardSaved
                            ? appLocalized("Saved", locale: locale)
                            : appLocalized("Save Card", locale: locale),
                        systemImage: model.isCurrentCardSaved ? "bookmark.fill" : "bookmark"
                    )
                    .font(.system(size: 13, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(2.2)
                    .frame(width: 172, height: 40)
                }
                .buttonStyle(.plain)
                .foregroundStyle(ZodiacPalette.gold)
                .background(ZodiacPalette.midnight.opacity(0.9), in: Capsule())
                .overlay {
                    Capsule().stroke(ZodiacPalette.gold, lineWidth: 1)
                }
                .contentShape(Capsule())
                .frame(minHeight: 44)
                .accessibilityHint(
                    model.isCurrentCardSaved
                        ? "Removes this card from Saved"
                        : "Keeps an offline copy of this card in Saved"
                )

                if model.persistenceMessage != nil {
                    Text(appLocalized("app.error.persistence", locale: locale))
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel(
                            appLocalized("app.error.persistence", locale: locale)
                        )
                }
            }
            .padding(.top, 14)
        }
    }

    private func dailyCard(
        horoscope: DailyHoroscope,
        width: CGFloat,
        height: CGFloat,
        artworkHeight: CGFloat
    ) -> some View {
        FlippableDailyCard(
            horoscope: horoscope,
            initiallyShowingBack: AppModel.visualQAState == .todayBack,
            width: width,
            height: height,
            artworkHeight: artworkHeight
        )
    }

    private var formattedDay: String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = .current
        formatter.dateFormat = "EEEE  ·  MMMM d"
        let date: Date
        if case .loaded(let horoscope) = model.dailyState,
           let editionDate = horoscope.day.startDate(in: .current) {
            date = editionDate
        } else {
            date = Date()
        }
        return formatter.string(from: date).uppercased(with: locale)
    }

}
