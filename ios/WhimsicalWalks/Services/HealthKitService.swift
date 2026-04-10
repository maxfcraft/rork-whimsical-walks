import Foundation
import HealthKit

@Observable
@MainActor
class HealthKitService {
    var todaySteps: Int = 0
    var isAuthorized: Bool = false

    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isAvailable else { return }
        let typesToRead: Set<HKObjectType> = [stepType]
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            isAuthorized = true
            await fetchTodaySteps()
        } catch {
            isAuthorized = false
        }
    }

    func fetchTodaySteps() async {
        guard isAvailable, isAuthorized else { return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .now, options: .strictStartDate)

        let steps = await withCheckedContinuation { (continuation: CheckedContinuation<Int, Never>) in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(value))
            }
            healthStore.execute(query)
        }
        todaySteps = steps
    }

    func fetchSteps(for date: Date) async -> Int {
        guard isAvailable, isAuthorized else { return 0 }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let steps = await withCheckedContinuation { (continuation: CheckedContinuation<Int, Never>) in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(value))
            }
            healthStore.execute(query)
        }
        return steps
    }
}
