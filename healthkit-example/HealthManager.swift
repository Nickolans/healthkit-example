//
//  dataManager.swift
//  healthkit-example
//
//  Created by Nickolans Griffith on 3/16/22.
//

import Foundation
import HealthKit

struct HealthManager {
    
    static func setup() {
        HealthManager.isAvailable {
            HealthManager.requestAuthForIdentifiers(forQuantities: [.stepCount], forCharacteristics: [.activityMoveMode]) { authorized, error in
                guard authorized else {
                    return
                }
                
                // Do what we need to do
                do {
                    let mode = try HealthManager.getActivityMode()
                    print("Mode: \(mode)")
                } catch {
                    print("Error: fetching activity mode")
                }
            }
        }
    }
    
    /**
    Checks whether the user has allowed access to health data
    */
    static func isAvailable(_ completion: (()->())) {
        if HKHealthStore.isHealthDataAvailable() {
            completion()
        }
    }
    
    /**
    Requests authorization to access certain quantity and characteristic types. Quantity types are essentially data sets while characteristic types are only a single value.
    */
    static func requestAuthForIdentifiers(forQuantities quantityValues: [HKQuantityTypeIdentifier], forCharacteristics characteristicValues: [HKCharacteristicTypeIdentifier], _ completion: @escaping ((Bool, Error?)->())) {
        
        // 1. Define empty type sets
        var quanTypes: Set<HKSampleType> = []
        var charTypes: Set<HKObjectType> = []
        
        // 2. Grab sample type for quantity identities
        for (_, quan) in quantityValues.enumerated() {
            if let value = HKObjectType.quantityType(forIdentifier: quan) {
                quanTypes.update(with: value)
            }
        }
        
        // 3. Grab object type for characteristic identities
        for (_, charac) in characteristicValues.enumerated() {
            if let value = HKObjectType.characteristicType(forIdentifier: charac) {
                charTypes.update(with: value)
            }
        }
        
        // 4. Request authorization
        HKHealthStore().requestAuthorization(toShare: quanTypes, read: charTypes) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: Methods based off requested read identifiers
    
    /**
    Retrieves the current activity mode. Since activity mode is not a data set, we do not have to query it.
    */
    static func getActivityMode() throws -> HKActivityMoveMode {
        
        // 1. Initialize store
        let store = HKHealthStore()
        
        // 2. Retrieve current activity mode
        do {
            let mode = try store.activityMoveMode()
            let value = mode.activityMoveMode
            
            return (value)
        }
    }
    
    // MARK: Request data that isn't biological data
    
    /**
    Retrieves the most recent step count. A method like this grabs data that needs to be queried and isn't easily fetched like biological data or data that is rarely updated.
    */
    static func getRecentStepCount( _ completion: @escaping ((HKQuantitySample?, Error?)->())) {
        
        // 1. Define date range to retrieve data
        let predicate = HKQuery.predicateForSamples(withStart: .distantPast, end: .now, options: .strictEndDate)
        
        // 2. Define how data is sorted
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // 3. Define quantity type to search
        guard let type = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        // 4. Create sample with above definitions
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { query, sample, error in
            DispatchQueue.main.async {
                guard let recentSample = sample?.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                
                completion(recentSample, nil)
            }
        }
        
        // 5. Execute query
        HKHealthStore().execute(sampleQuery)
    }
}
