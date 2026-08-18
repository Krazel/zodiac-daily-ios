import SwiftUI
import ZodiacDailyCore

/// Measured implementation candidate for the owner-approved C2 Today reference.
struct TodayView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.locale) private var locale
    @State private var showsSettings: Bool
    @State private var showsSignSelection = false

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
        .fullScreenCover(isPresented: $showsSignSelection) {
            SignSelectionView(requiresSelection: false)
        }
    }

    private var todayLayout: some View {
        VStack(spacing: 0) {
            masthead

            signMenu

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
                    .background(ZodiacPalette.midnight.opacity(0.58), in: Circle())
                    .overlay {
                        Circle().stroke(ZodiacPalette.gold.opacity(0.82), lineWidth: 0.9)
                    }
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
                .font(.custom("Didot", size: 22, relativeTo: .title2))
                .tracking(1.8)
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
    private var signMenu: some View {
        if let selectedSign = model.selectedSign {
            Menu {
                ForEach(ZodiacSign.allCases, id: \.self) { sign in
                    Button {
                        model.select(sign)
                    } label: {
                        Label(
                            sign.localizedDisplayName(locale: locale),
                            systemImage: sign == selectedSign ? "checkmark" : "circle"
                        )
                    }
                }

                Divider()

                Button("About & Settings", systemImage: "gearshape") {
                    showsSettings = true
                }
            } label: {
                HStack(spacing: 14) {
                    Text(selectedSign.symbol)
                        .font(.system(size: 40, weight: .ultraLight))
                    Text(selectedSign.localizedDisplayName(locale: locale).uppercased(with: locale))
                        .font(.custom("Didot", size: 18, relativeTo: .title3).weight(.semibold))
                        .tracking(2)
                        .minimumScaleFactor(0.62)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(ZodiacPalette.paleGold)
                .padding(.horizontal, 20)
                .frame(width: 225, height: 51)
                .background(ZodiacPalette.midnight.opacity(0.72), in: Capsule())
                .overlay {
                    Capsule().stroke(ZodiacPalette.gold, lineWidth: 1)
                }
                .contentShape(Capsule())
            } primaryAction: {
                showsSignSelection = true
            }
            .padding(.top, 22)
            .accessibilityLabel(
                String(
                    format: appLocalized("today.selected_sign_format", locale: locale),
                    selectedSign.localizedDisplayName(locale: locale)
                )
            )
            .accessibilityHint(
                appLocalized("Double-tap to choose another sign", locale: locale)
            )
            .accessibilityAction(
                named: Text(appLocalized("Open Settings", locale: locale))
            ) {
                showsSettings = true
            }
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        switch model.dailyState {
        case .idle, .loading:
            ProgressView("Preparing today’s card…")
                .tint(ZodiacPalette.gold)
                .foregroundStyle(ZodiacPalette.text)
                .frame(maxWidth: 328, minHeight: 456)
                .padding(.top, 39)

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
            .frame(maxWidth: 328, minHeight: 456)
            .padding(.top, 39)
            .accessibilityElement(children: .contain)

        case .loaded(let horoscope):
            VStack(spacing: 10) {
                FlippableDailyCard(
                    horoscope: horoscope,
                    initiallyShowingBack: AppModel.visualQAState == .todayBack
                )

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
            .padding(.top, 18)
        }
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
