//
//  ViewController.swift
//  FineDust
//
//  Created by Presto on 21/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet private weak var intakeFineDustLable: UILabel!
  @IBOutlet private weak var intakeUltrafineDustLabel: UILabel!
  @IBOutlet private weak var distanceLabel: UILabel!
  @IBOutlet private weak var stepCountLabel: UILabel!
  @IBOutlet private weak var timeLabel: UILabel!
  @IBOutlet private weak var locationLabel: UILabel!
  @IBOutlet private weak var gradeLabel: UILabel!
  @IBOutlet private weak var fineDustLabel: UILabel!
  
  // MARK: - Properties
  
  ///한번만 표시해주기 위한 프로퍼티
  private var isPresented: Bool = false
  
  private let coreDataService = CoreDataService()
  private let healthKitService = HealthKitService(healthKit: HealthKitManager())
  private let dustInfoService = DustInfoService(dustManager: DustInfoManager())
  private let intakeService = IntakeService()
  
  /// 오전(후) 시 : 분 으로 나타내주는 프로퍼티.
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "a hh : mm"
    return formatter
  }()
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !isPresented {
      isPresented.toggle()
      updateHealthKitInfo()
      updateAPIInfo()
    }
  }
  
  deinit {
    unregisterLocationObserver()
    unregisterHealthKitAuthorizationObserver()
  }
}

// MARK: - LocationObserver

extension MainViewController: LocationObserver {
  func handleIfSuccess(_ notification: Notification) {
    updateAPIInfo()
  }
}

// MARK: - HealthKitAuthorizationObserver

extension MainViewController: HealthKitAuthorizationObserver {
  func authorizationSharingAuthorized(_ notification: Notification) {
    updateHealthKitInfo()
    updateAPIInfo()
  }
}

// MARK: - Methods

extension MainViewController {
  /// MainViewController 초기 설정 메소드.
  private func setUp() {
    registerLocationObserver()
    registerHealthKitAuthorizationObserver()
    timeLabel.text = dateFormatter.string(from: Date())
    presentOpenHealthAppAlert()
  }
  
  /// HealthKit의 걸음 수, 걸은 거리 값 업데이트하는 메소드.
  private func updateHealthKitInfo() {
    // 걸음 수 label에 표시
    healthKitService.requestTodayStepCount { value, error in
      if let error = error as? ServiceErrorType {
        error.presentToast()
        return
      }
      if let value = value {
        self.coreDataService
          .saveLastSteps(Int(value)) { error in
            if error != nil {
              print("마지막으로 요청한 걸음수가 저장되지 않음")
            } else {
              print("마지막으로 요청한 걸음수가 성공적으로 저장됨")
            }
          }
        DispatchQueue.main.async {
          self.stepCountLabel.text = "\(Int(value)) 걸음"
        }
      }
    }
    
    // 걸은 거리 label에 표시
    healthKitService.requestTodayDistance { value, error in
      if let error = error as? ServiceErrorType {
        error.presentToast()
        return
      }
      if let value = value {
        self.coreDataService
          .saveLastDistance(value) { error in
            if error != nil {
              print("마지막으로 요청한 걸음거리가 저장되지 않음")
            } else {
              print("마지막으로 요청한 걸음거리가 성공적으로 저장됨")
            }
          }
        DispatchQueue.main.async {
          self.distanceLabel.text = String(format: "%.1f", value.kilometer) + " km"
        }
      }
    }
  }
  
  /// 미세먼지량과 위치정보 같은 API정보들을 업데이트 하는 메소드.
  private func updateAPIInfo() {
    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let self = self else { return }
      // 위치에 관련된 Label들을 업데이트함.
      self.dustInfoService.requestRecentTimeInfo { info, error in
        if let error = error as? ServiceErrorType {
          error.presentToast()
          return
        }
        if let info = info {
          self.coreDataService
            .saveLastDustData(
              (address: SharedInfo.shared.address,
               grade: info.fineDustGrade.rawValue,
               recentFineDust: info.fineDustValue)) { error in
                if error != nil {
                  print("마지막으로 요청한 미세먼지 정보가 저장되지 않음")
                } else {
                  print("마지막으로 요청한 미세먼지 정보가 성공적으로 저장됨")
                }
          }
          DispatchQueue.main.async {
            self.fineDustLabel.text = "\(info.fineDustValue)µg"
            self.locationLabel.text = SharedInfo.shared.address
            self.gradeLabel.text = info.fineDustGrade.description
          }
        }
      }
    }
    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let self = self else { return }
      self.intakeService.requestTodayIntake { fineDust, ultrafineDust, error in
        if let error = error as? ServiceErrorType {
          error.presentToast()
          return
        }
        if let fineDust = fineDust, let ultrafineDust = ultrafineDust {
          if self.healthKitService.isAuthorized {
            self.coreDataService
              .saveLastTodayIntake(
                (todayFineDust: fineDust,
                 todayUltrafineDust: ultrafineDust)) { error in
                  if error != nil {
                    print("마지막으로 요청한 오늘의 먼지 흡입량 정보가 저장되지 않음")
                  } else {
                    print("마지막으로 요청한 오늘의 먼지 흡입량 정보가 성공적으로 저장됨")
                  }
            }
            DispatchQueue.main.async {
              self.intakeFineDustLable.text = "\(fineDust)µg"
              self.intakeUltrafineDustLabel.text = "\(ultrafineDust)µg"
            }
          }
        }
      }
    }
    // 마신 미세먼지양 Label들을 업데이트함.
  }
  
  /// 권한이 없을시 권한설정을 도와주는 AlertController.
  private func presentOpenHealthAppAlert() {
    if !healthKitService.isAuthorized {
      UIAlertController
        .alert(title: "건강 App 권한이 없습니다.",
               message: """
          내안의먼지는 건강 App에 대한 권한이 필요합니다. 건강 App-> 데이터소스 -> 내안의먼지 -> 모든 쓰기, 읽기 권한을 \
          허용해주세요.
          """
        )
        .action(title: "건강 App", style: .default) { _, _ in
          UIApplication.shared.open(URL(string: "x-apple-health://")!)
        }
        .action(title: "취소", style: .cancel)
        .present(to: self)
    }
  }
}
