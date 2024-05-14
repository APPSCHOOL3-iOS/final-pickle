//
//  SetNotiView.swift
//  Pickle
//
//  Created by 최소정 on 10/10/23.
//

import SwiftUI

struct SettingNotiicationView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    
    @AppStorage(STORAGE.onboarding.id, store: .group)
    var isOnboardingViewActive: Bool = true
    
    @Binding var isShowingOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            VStack(spacing: 4) {
                Text("🍕")
                    .font(.system(size: 50))
                    .padding()
                
                Group {
                    Text("피자를 놓치지 않도록")
                    Text("현실도 피자").bold() + Text("에서 알림을 보내드려요.")
                  
                }
                .font(.nanumRg)
            }
            
            VStack(alignment: .trailing) {
                VStack(spacing: .zero) {
                    VStack {
                        Text("'현실도 피자'에서 알림을")
                        Text("보내고자 합니다.")
                    }
                    .bold()
                    .frame(height: 99)
                    
                    Rectangle()
                        .frame(width: 301, height: 1)
                        .foregroundStyle(.tertiary)
                    
                    HStack(spacing: .zero) {
                        Spacer()
                        
                        Text("허용 안 함")
                            .frame(width: 150)
                            .foregroundStyle(.secondary)
                        
                        Rectangle()
                            .frame(width: 1, height: 50)
                            .foregroundStyle(.tertiary)
                        
                        Text("허용")
                            .frame(width: 150)
                            .bold()
                            .foregroundStyle(Color.pickle)
                        
                        Spacer()
                    }
                    .frame(height: 50)
                }
                .frame(width: 301, height: 150)
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.tertiary, lineWidth: 1)
                )
                
                Text("👆")
                    .font(.system(size: 40))
                    .offset(x: -45)
      
            }
            
        Text("원활한 서비스 이용을 위해 ") + Text("알림을 허용").bold() + Text("해주세요!")
            Spacer()
            
            Button {
                Task {
                    try? await notificationManager.requestNotiAuthorization()
                    if notificationManager.isGranted {
                        isOnboardingViewActive = false
                        notificationManager.scheduleNotification(
                            localNotification: LocalNotification(identifier: UUID().uuidString,
                                                                 title: "현실도 피자",
                                                                 body: "환영합니다!",
                                                                 timeInterval: 1,
                                                                 repeats: false,
                                                                 type: .time)
                        )
                    } else {
                        notificationManager.isAlertOccurred = true
                    }
                }
            } label: {
                Text("확인")
                    .primaryButtonModifier(frame: 300)
            }
        }
        .padding()
        .alert("원활한 서비스 이용을 위해 설정탭에서 알림을 허용해주세요.", isPresented: $notificationManager.isAlertOccurred) {
            Button {
                notificationManager.isAlertOccurred = false
                isOnboardingViewActive = false
            } label: {
                Text("확인")
            }
        }
    }
}

#Preview {
    SettingNotiicationView(isShowingOnboarding: .constant(true))
        .environmentObject(NotificationManager(mediator: NotiMediator()))
}
