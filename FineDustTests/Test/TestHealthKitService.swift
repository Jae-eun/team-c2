//
//  HealthKitServiceTest.swift
//  FineDustTests
//
//  Created by 이재은 on 01/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

@testable import FineDust
import XCTest
import Foundation

class TestHealthKitService: XCTestCase {
  
  var healthKitService: HealthKitServiceType?
  let mockHealthKitManager = MockHealthKitManager()
  
  override func setUp() {
    healthKitService = HealthKitService(healthKit: mockHealthKitManager)
  }
  
  /// 오늘 걸음 수 데이터 받아오는 함수 테스트
  func testRequestTodayStepCount() {
    let expect = expectation(description: "Request today step count")
    healthKitService?.requestTodayStepCount { result, error in
      XCTAssertEqual(result, self.mockHealthKitManager.stepCount)
      XCTAssertNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 오늘 걸은 거리 데이터 받아오는 함수 테스트
  func testRequestTodayDistance() {
    let expect = expectation(description: "Request today distance")
    healthKitService?.requestTodayDistance { result, error in
      XCTAssertEqual(result, self.mockHealthKitManager.distance)
      XCTAssertNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 오늘 걸음 수 데이터 받아오는 함수 에러 테스트
  func testRequestTodayStepCountError() {
    let expect = expectation(description: "Request error")
    mockHealthKitManager.error = HealthKitError.queryExecutedFailed
    healthKitService?.requestTodayStepCount { result, error in
      XCTAssertEqual(result, 0.0)
      XCTAssertNotNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 오늘 걸은 거리 데이터 받아오는 함수 에러 테스트
  func testRequestTodayDistanceError() {
    let expect = expectation(description: "Request error")
    mockHealthKitManager.error = HealthKitError.queryExecutedFailed
    healthKitService?.requestTodayDistance { result, error in
      XCTAssertEqual(result, 0.0)
      XCTAssertNotNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testRequestTodayDistancePerHour() {
    let expect = expectation(description: "request error")
    mockHealthKitManager.error = HealthKitError.queryExecutedFailed
    var mockHourIntakePair = HourIntakePair()
    for hour in 0...23 {
      mockHourIntakePair[Hour(rawValue: hour) ?? .default] = 0
    }
    healthKitService?.requestTodayDistancePerHour { hourIntakePair in
      XCTAssertEqual(mockHourIntakePair, hourIntakePair)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
}
