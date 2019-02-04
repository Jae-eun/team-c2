//
//  IntakeServiceTest.swift
//  FineDustTests
//
//  Created by Presto on 04/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

@testable import FineDust
import XCTest
import Foundation

class IntakeServiceTest: XCTestCase {
  
  var intakeService: IntakeService!
  
  let mockHealthKitService: HealthKitServiceType!
  let mockDustInfoService: DustInfoServiceType!
  let mockCoreDataService: CoreDataServiceType!
  
  override func setUp() {
    IntakeService = IntakeService(healthKitService: mockHealthKitService,
                                  dustInfoService: mockDustInfoService,
                                  coreDataService: mockCoreDataService)
  }
  
  func testFetchTodayIntake() {
    intakeService.fetchTodayIntake { fineDust, ultrafineDust, error in
      XCTAssertNil(error)
    }
  }
  
  func testFetchTodayIntakeError() {
    intakeService.fetchTodayIntake { fineDust, ultrafineDust, error in
      XCTAssertNotNil(error)
    }
  }
  
  func testFetchIntakesInWeek() {
    intakeService.fetchIntakesInWeek(since: Date()) { fineDusts, ultrafineDusts, error in
      XCTAssertNil(error)
    }
  }
  
  func testFetchIntakesInWeekError() {
    intakeService.fetchIntakesInWeek(since: Date()) { fineDusts, ultrafineDusts, error in
      XCTAssertNotNil(error)
    }
  }
}
