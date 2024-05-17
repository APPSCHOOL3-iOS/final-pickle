//
//  NotificationManager.swift
//  Pickle
//
//  Created by 최소정 on 10/10/23.
//

import SwiftUI
import UserNotifications

@MainActor
final class NotificationManager: NSObject,
                                 ObservableObject,
                                 NotificationService {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // 현재 알림 설정 권한 담는 변수
    @Published var isGranted: Bool = false
    
    // 설정탭에서 알림 설정 권장 Alert
    @Published var isAlertOccurred: Bool = false
    
    // MARK: SetNotiView DatePicker 연결
    @Published var notiTime: Date = Date() {
        didSet {
            removeAllNotifications()
            addNotification(with: notiTime)
        }
    }

    init(mediator: Mediator) {
        self.mediator = mediator
        super.init()
        notificationCenter.delegate = self
        self.mediator.manager = self
    }
    
    let mediator: Mediator
    
    func post(notification type: NotiType) async {
        await mediator.notify(notification: type)
    }
    
    func receive(notification type: NotiType) async {
        fatalError("do not call this method")
    }
    
    // 푸시 알림 권한 요청
    func requestNotiAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .alert])
        await getCurrentSetting()
    }
    
    func timerViewPushSetting(_ localNotification: LocalNotification) {
        if self.isGranted {
            self.scheduleNotification( localNotification: localNotification )
        } else {
            self.isAlertOccurred = true
        }
    }
    
    // 현재 알림 설정 확인
    func getCurrentSetting() async {
        let currentSetting = await notificationCenter.notificationSettings()
        isGranted = (currentSetting.authorizationStatus == .authorized)
    }
    
    // MARK: SetNotiView DatePicker 연결
    func addNotification(with time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🍕 현실도 피자~"
        content.body = "현실 도피는 이제 그만!"
        content.sound = UNNotificationSound.default
        
        let dateComponent = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // 알림 타입별 구분
    func scheduleNotification(localNotification: LocalNotification) {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = UNNotificationSound.default
        content.userInfo = localNotification.userInfo
        
        let request = content.makeRequest(localNotification: localNotification)
        
        notificationCenter.add(request)
    }

    func removeAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()        // 전달된 노티피케이션 제거
        notificationCenter.removeAllPendingNotificationRequests()   // 보류중인 노티피케이션 제거
    }
        
    func removeSpecificNotification(id: [String]) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: id)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: id)
        Log.debug("❌ NotificationManager에서 삭제 \(id)")
    }
    
    // 설정 앱으로 이동
    func openSettings() {
        if let bundle = Bundle.main.bundleIdentifier,
           let settings = URL(string: UIApplication.openSettingsURLString + bundle) {
            if UIApplication.shared.canOpenURL(settings) {
                UIApplication.shared.open(settings)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // 앱이 실행중일때 알림이 도착하면 채택하여 구현한 메서드 호출, 사용자에게 배너와 소리로 알림 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        await notificationRouting(userInfo: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                openSettingsFor notification: UNNotification?) {
    }
    
    private func notificationRouting(userInfo: [AnyHashable: Any]) async {
        let info = userInfo.mapToStringKey()
        if let statusString = info[LocalNotification.notiType] as? String {
            let notificationType = NotiType.getValue(value: statusString)
            switch notificationType {
            case .calendar, .health, .time, .wakeUp:
                await post(notification: notificationType)
            case .todo:
                let todo = Todo.init(dic: info)
                await post(notification: .todo(todo))
            }
        }
    }
}

extension UNMutableNotificationContent {
    
    func makeRequest(localNotification: LocalNotification) -> UNNotificationRequest {
        let trigger = makeTrigger(localNotification: localNotification)
        return makeNotificationRequest(identifier: localNotification.identifier, trigger: trigger!)
    }
    
    func makeTrigger(localNotification: LocalNotification) -> UNNotificationTrigger? {
        switch localNotification.type {
            // 특정 날짜 및 시간에 알림 예약
        case .calendar, .health, .wakeUp, .todo:
            guard let dateComponents = localNotification.dateComponents else { return nil }
            return UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                 repeats: localNotification.repeats)
            // 몇 초 후 알림
        case .time:
            guard let timeInterval = localNotification.timeInterval else { return nil }
            return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                     repeats: localNotification.repeats)
        }
    }
    
    func makeNotificationRequest(identifier: String, trigger: UNNotificationTrigger) -> UNNotificationRequest {
        let request = UNNotificationRequest(identifier: identifier,
                                            content: self,
                                            trigger: trigger)
        Log.debug("✅ NotificationManager 안의 등록시 \(identifier)")
        return request
    }
}
    
