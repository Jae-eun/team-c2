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
  
  @IBOutlet private weak var intakeFineDustLable: FDCountingLabel!
  @IBOutlet private weak var intakeUltrafineDustLabel: FDCountingLabel!
  @IBOutlet private weak var distanceLabel: UILabel!
  @IBOutlet private weak var stepCountLabel: UILabel!
  @IBOutlet private weak var timeLabel: UILabel!
  @IBOutlet private weak var locationLabel: UILabel!
  @IBOutlet private weak var gradeLabel: UILabel!
  @IBOutlet private weak var fineDustLabel: FDCountingLabel!
  @IBOutlet private weak var fineDustImageView: UIImageView!
  @IBOutlet private weak var healthKitInfoView: UIView!
  @IBOutlet private weak var locationInfoView: UIView!
  @IBOutlet private weak var currentDistance: UILabel!
  @IBOutlet private weak var currentWalkingCount: UILabel!
  
  // MARK: - Properties
  
  /// 한번만 표시해주기 위한 프로퍼티.
  private var isPresented: Bool = false
  
  /// 미세먼지 애니메이션을 움직이게 할 타이머.
  private var timer: Timer?
  
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
  
  // MARK: IBAction
  
  @IBAction func authorizationButtonDidTap(_ sender: Any) {
    if !healthKitService.isAuthorized {
      UIAlertController.alert(title: "권한이 필요합니다.", message: """
      내안의 먼지를 사용하려면 위치권한과 건강 권한이 필요합니다.
      원하는 버튼을 눌러주세요.
      """, style: .actionSheet)
        .action(title: "Settings", style: .default) { _, _ in
          guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
          }
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
          }
        }.action(title: "Health", style: .default) { _, _ in
          guard let url = URL(string: "x-apple-health://") else {
            return
          }
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
          }
        }
        .action(title: "Cancel", style: .cancel)
        .present(to: self)
    } else {
      UIAlertController.alert(title: "", message: "필요한 권한이 없습니다.")
        .action(title: "확인")
        .present(to: self)
    }
  }
  
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
  
  /// 데이터를 받아오는데 문제가 있으면 코어데이터에 마지막으로 저장된 값을 불러옴.
  func handleIfFail(_ notification: Notification) {
    if let error = notification.locationTaskError {
      coreDataService.requestLastSavedData { lastSaveData, error in
        if let data = lastSaveData {
          DispatchQueue.main.async {
            self.intakeFineDustLable.countFromZero(to: data.todayFineDust,
                                                   unit: .microgram,
                                                   interval: 1.0 /
                                                    Double(data.todayFineDust))
            
            self.intakeUltrafineDustLabel.countFromZero(to: data.todayUltrafineDust,
                                                        unit: .microgram,
                                                        interval: 1.0 /
                                                          Double(data.todayUltrafineDust))
            self.fineDustImageView.image
              = UIImage(named: IntakeGrade(intake: data.todayFineDust + data.todayUltrafineDust)
                .imageName)
            
            self.locationLabel.text = data.address
            self.gradeLabel.text = DustGrade(rawValue: data.grade)?.description
            self.fineDustLabel.countFromZero(to: data.recentFineDust,
                                             unit: .microgram,
                                             interval: 1.0 / Double(data.recentFineDust))
          }
        }
      }
      print(error.localizedDescription)
      Toast.shared.show(error.localizedDescription)
    }
    updateHealthKitInfo()
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
    updateFineDustImageView()
    
    // InfoView들의 둥글 모서리와 shadow 추가
    healthKitInfoView.layer.setBorder(color: Asset.graphBorder.color, width: 1, radius: 10)
    locationInfoView.layer.setBorder(color: Asset.graphBorder.color, width: 1, radius: 10)
    
    // 해상도 별 폰트 크기 조정.
    let size = fontSizeByScreen(size: currentWalkingCount.font.pointSize)
    currentWalkingCount.font = currentWalkingCount.font.withSize(size)
    currentDistance.font = currentDistance.font.withSize(size)
  }
  
  /// HealthKit의 걸음 수, 걸은 거리 값 업데이트하는 메소드.
  private func updateHealthKitInfo() {
    // 걸음 수 label에 표시
    healthKitService.requestTodayStepCount { value, error in
      if let error = error as? HealthKitError, error == .queryNotSearched {
        if self.healthKitService.isAuthorized {
          DispatchQueue.main.async {
            self.stepCountLabel.text = "0 " + "steps".localized
          }
        } else {
          error.presentToast()
        }
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
            if self.healthKitService.isAuthorized {
              DispatchQueue.main.async {
                self.stepCountLabel.text = "\(Int(value)) " + "steps".localized
              }
            }
        }
      }
    }
    
    // 걸은 거리 label에 표시
    healthKitService.requestTodayDistance { value, error in
      if let error = error as? HealthKitError, error == .queryNotSearched {
        if self.healthKitService.isAuthorized {
          DispatchQueue.main.sync {
            self.distanceLabel.text = "0.0 km"
          }
        }
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
        if self.healthKitService.isAuthorized {
          DispatchQueue.main.async {
            self.distanceLabel.text = String(format: "%.1f", value.kilometer) + " km"
          }
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
            .saveLastDustData(SharedInfo.shared.address,
                              info.fineDustGrade.rawValue,
                              info.fineDustValue) { error in
                                if error != nil {
                                  print("마지막으로 요청한 미세먼지 정보가 저장되지 않음")
                                } else {
                                  print("마지막으로 요청한 미세먼지 정보가 성공적으로 저장됨")
                                }
          }
          DispatchQueue.main.async {
            self.fineDustLabel.countFromZero(to: info.fineDustValue,
                                             unit: .microgram,
                                             interval: 1.0 / Double(info.fineDustValue))
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
              .saveLastTodayIntake(fineDust,
                                   ultrafineDust) { error in
                                    if error != nil {
                                      print("마지막으로 요청한 오늘의 먼지 흡입량 정보가 저장되지 않음")
                                    } else {
                                      print("마지막으로 요청한 오늘의 먼지 흡입량 정보가 성공적으로 저장됨")
                                    }
            }
            // 마신 미세먼지양 Label들을 업데이트함.
            DispatchQueue.main.async {
              self.fineDustImageView.image
                = UIImage(named: IntakeGrade(intake: fineDust + ultrafineDust).imageName)
              self.intakeFineDustLable.countFromZero(to: fineDust,
                                                     unit: .microgram,
                                                     interval: 1.0 /
                                                      Double(fineDust))
              self.intakeUltrafineDustLabel.countFromZero(to: ultrafineDust,
                                                          unit: .microgram,
                                                          interval: 1.0 /
                                                            Double(ultrafineDust))
            }
          }
        }
      }
    }
  }
  
  /// 미세먼지 애니메이션
  private func updateFineDustImageView() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5,
                                 repeats: true
    ) { [weak self] _ in
      guard let identity = self?.fineDustImageView.transform.isIdentity else {
        return
      }
      
      if identity {
        self?.fineDustImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
      } else {
        self?.fineDustImageView.transform = .identity
      }
    }
    timer?.fire()
  }
  
  /// 권한이 없을시 권한설정을 도와주는 AlertController.
  private func presentOpenHealthAppAlert() {
    if !healthKitService.isAuthorized && healthKitService.isDetermined {
      UIAlertController
        .alert(title: "Do not have Health App privileges.".localized,
               message: """
                'Dust inside me' need authority to the Health App. Health App -> \
                Data Sources -> Dust inside me -> Allow all write and read permissions.
          """.localized
        )
        .action(title: "Health App".localized, style: .default) { _, _ in
          self.openHealthApp()
        }
        .action(title: "Cancel".localized, style: .cancel)
        .present(to: self)
    }
  }
  
  private func openHealthApp() {
    if let url = URL(string: "x-apple-health://") {
      UIApplication.shared.open(url)
    }
  }
  
  private func fontSizeByScreen(size: CGFloat) -> CGFloat {
    let value = size / 414
    return UIScreen.main.bounds.width * value
  }
}
