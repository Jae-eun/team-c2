//
//  DustInfoManagerTest.swift
//  FineDustTests
//
//  Created by Presto on 12/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

@testable import FineDust
import Foundation
import XCTest

class TestDustInfoManager: XCTestCase {
  
  let mockNetworkManager = MockNetworkManager()
  
  var dustInfoManager: DustInfoManager!
  
  override func setUp() {
    dustInfoManager = DustInfoManager(networkManager: mockNetworkManager)
  }
  
  func test_request() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = nil
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      XCTAssertNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }

  func test_request_noDataError() {
    mockNetworkManager.data = nil
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = NSError(domain: "", code: 0, userInfo: nil)
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNil(response)
      XCTAssertNotNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_httpError() {
    mockNetworkManager.data = nil
    mockNetworkManager.httpStatusCode = HTTPStatusCode.default
    mockNetworkManager.error = HTTPError.default
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNil(response)
      if let error = error as? HTTPError {
        XCTAssertEqual(error, HTTPError.default)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError1() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.accessDenied
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.accessDenied)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError2() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.applicationError
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.applicationError)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError3() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.dbError
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.dbError)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError4() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.default
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.default)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError5() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.exceededRequestLimit
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.exceededRequestLimit)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError6() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.expiredServiceKey
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.expiredServiceKey)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError7() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.httpError
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.httpError)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError8() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.invalidRequestParameter
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.invalidRequestParameter)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError9() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.noData
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.noData)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError10() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.noRequiredRequestParameter
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.noRequiredRequestParameter)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError11() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.noServiceOrDeprecated
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.noServiceOrDeprecated)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError12() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.serviceTimeOut
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.serviceTimeOut)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError13() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.unregisteredDomainOfIPAddress
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.unregisteredDomainOfIPAddress)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_dustError14() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.unregisteredServiceKey
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? DustError {
        XCTAssertEqual(error, DustError.unregisteredServiceKey)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_xmlError1() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.attributeDeserializationFailed("", .init(name: "", text: ""))
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? XMLError {
        XCTAssertEqual(error, XMLError.attributeDeserializationFailed("", .init(name: "", text: "")))
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_requesetObservatory_xmlError2() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.attributeDoesNotExist(.init(name: "", options: .init()), "")
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? XMLError {
        XCTAssertEqual(error, XMLError.attributeDoesNotExist(.init(name: "", options: .init()), ""))
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_xmlError3() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.default
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? XMLError {
        XCTAssertEqual(error, XMLError.default)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_xmlError4() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.implementationIsMissing("")
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? XMLError {
        XCTAssertEqual(error, XMLError.implementationIsMissing(""))
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_xmlError5() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.nodeHasNoValue
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? XMLError {
        XCTAssertEqual(error, XMLError.nodeHasNoValue)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_xmlError6() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.nodeIsInvalid(.element(.init(name: "", options: .init())))
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? XMLError {
        XCTAssertEqual(error, XMLError.nodeIsInvalid(.element(.init(name: "", options: .init()))))
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_request_xmlError7() {
    mockNetworkManager.data = DummyNetworkManager.dustInfoResponse.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.typeConversionFailed("", .init(name: "", options: .init()))
    let expect = expectation(description: "test")
    dustInfoManager.request(dataTerm: .daily, numberOfRows: 1, pageNumber: 1) { response, error in
      XCTAssertNotNil(response)
      if let error = error as? XMLError {
        XCTAssertEqual(error, XMLError.typeConversionFailed("", .init(name: "", options: .init())))
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
}
