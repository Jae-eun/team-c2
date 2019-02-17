//
//  HealthKitError.swift
//  FineDust
//
//  Created by zun on 15/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

enum HealthKitError: ServiceErrorType {
  var localizedDescription: String {
    switch self {
    case .notMatchingArguments:
      return "HealthKit 메소드의 입력인자가 서로 맞지 않습니다."
    case .unexpectedIdentifier:
      return "예상치 못한 HealthKit identifier가 들어왔습니다."
    case .queryNotValid:
      return "query문이 유효하지 않습니다.(권한이 설정되지 않았을 경우에도 발생)"
    case .queryNotSearched:
      return "query문의 검색결과가 없습니다.(권한이 없을 경우에도 발생)"
    case .queryExecutedFailed:
      return "query문 실행이 실패했습니다."
    }
  }
  
  /// HealthKitManager의 파라미터 값들이 .stepCount - .count() 와
  /// .distanceWalkingRunning - .meter() 짝으로 오지 않을때 에러.
  case notMatchingArguments
  
  /// HealthKitManager의 indentifier 인자 값이 예상치 못한 값이 들어올때의 에러.
  case unexpectedIdentifier
  
  case queryNotValid
  
  case queryExecutedFailed
  
  case queryNotSearched
}
