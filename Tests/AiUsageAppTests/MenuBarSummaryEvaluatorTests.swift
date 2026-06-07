import Foundation
import Testing
@testable import AiUsageApp

struct MenuBarSummaryEvaluatorTests {
    private func makeSnapshot(provider: ProviderID, metrics: [UsageMetric]) -> ProviderSnapshot {
        ProviderSnapshot(
            provider: provider,
            authState: .authenticated,
            fetchState: .ok,
            fetchedAtUTC: Date(),
            metrics: metrics,
            errorDescription: nil
        )
    }

    private func makeMetric(kind: UsageMetricKind, remainingFraction: Double?) -> UsageMetric {
        UsageMetric(
            kind: kind,
            remainingFraction: remainingFraction,
            remainingValue: remainingFraction.map { $0 * 100 },
            totalValue: 100,
            unit: .percentage,
            resetAtUTC: nil,
            lastUpdatedAtUTC: Date(),
            detailText: nil
        )
    }

    @Test
    func codexFallsBackToFiveHourWhenWeeklyHasNoData() {
        let snapshot = makeSnapshot(provider: .codex, metrics: [
            makeMetric(kind: .codexWeekly, remainingFraction: nil),
            makeMetric(kind: .codexFiveHour, remainingFraction: 0.54),
        ])
        var prefs = DisplayPreferences.default
        prefs.codexMenuBarMetric = .weekly

        let result = MenuBarSummaryEvaluator.remainingFraction(for: .codex, snapshot: snapshot, preferences: prefs)

        #expect(result == 0.54)
    }

    @Test
    func codexReturnsPreferredMetricWhenDataIsPresent() {
        let snapshot = makeSnapshot(provider: .codex, metrics: [
            makeMetric(kind: .codexWeekly, remainingFraction: 0.80),
            makeMetric(kind: .codexFiveHour, remainingFraction: 0.54),
        ])
        var prefs = DisplayPreferences.default
        prefs.codexMenuBarMetric = .weekly

        let result = MenuBarSummaryEvaluator.remainingFraction(for: .codex, snapshot: snapshot, preferences: prefs)

        #expect(result == 0.80)
    }

    @Test
    func codexReturnsNilWhenBothMetricsHaveNoData() {
        let snapshot = makeSnapshot(provider: .codex, metrics: [
            makeMetric(kind: .codexWeekly, remainingFraction: nil),
            makeMetric(kind: .codexFiveHour, remainingFraction: nil),
        ])
        var prefs = DisplayPreferences.default
        prefs.codexMenuBarMetric = .weekly

        let result = MenuBarSummaryEvaluator.remainingFraction(for: .codex, snapshot: snapshot, preferences: prefs)

        #expect(result == nil)
    }
}
