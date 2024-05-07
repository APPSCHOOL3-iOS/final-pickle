//
//  HealthKit.swift
//  Pickle
//
//  Created by Suji Jang on 10/16/23.
//

import Foundation
import HealthKit

class HealthKitStore: ObservableObject {

    @Published var stepCount: Int?
    private let healthStore: HKHealthStore? = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            completion(false)
            return
        }

        healthStore?.requestAuthorization(toShare: nil, read: [stepType]) { success, _ in
            completion(success)
        }
    }

    func fetchStepCount(_ completion: @escaping () -> Void = {}) {
        guard let healthStore = healthStore else {
            Log.warning("fetchStepCount 초기 실행 실패")
            completion()
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion()
            Log.error("걸음수 QuantityType 가져오기 실패")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, result, error in
            if let result = result, let sum = result.sumQuantity() {
                let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                DispatchQueue.main.async {
                    self.stepCount = stepCount
                    completion()
                }
            } else if let error = error {
                // 그냥 self.stepCount = 0 으로 넣어주면
                // Publishing changes from background threads is not allowed
                // make sure to publish values from the main thread
                // (via operators like receive(on:)) on model updates.
                // 위의 에러가 발생함 -> DispatchQue.main.async를 사용해서 넣어주면서 해결
                DispatchQueue.main.async {
                    self.stepCount = 0
                }
                Log.error("걸음 수 가져오기 실패: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.stepCount = 0
                }
                Log.warning("fetchStepCount 에서 예상치 못한 error 발생 ")
            }
        }
        healthStore.execute(query)
    }
}
