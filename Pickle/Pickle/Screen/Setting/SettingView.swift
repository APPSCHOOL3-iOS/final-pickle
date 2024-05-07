//
//  SettingView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI
import UniformTypeIdentifiers
import WebKit

enum SchemeType: Int, Identifiable, CaseIterable {
    var id: Self { self }
    case system
    case light
    case dark
}

extension SchemeType {
    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var notificationManager: NotificationManager
    
    @AppStorage("systemTheme") private var systemTheme: Int = SchemeType.allCases.first!.rawValue
    @AppStorage("is24HourClock") var is24HourClock: Bool = true
    
    @State private var isShowingMoveToSettingAlert: Bool = false
    @State private var isShowingEmailAlert: Bool = false
    
    @State private var isShowingSafari: Bool = false
    private var appInformationWebViewSite =  "https://ahshch.notion.site/e899a56e18e9429bae8ce390181e42e4?pvs=4"
    
    var notificationStatus: String { notificationManager.isGranted ? "ON" : "OFF"}
    
    var selectedScheme: ColorScheme? {
        guard let theme = SchemeType(rawValue: systemTheme) else { return nil }
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return nil
        }
    }
    
    let pasteboard = UIPasteboard.general
    
    var body: some View {
        List {
            Section("앱 설정") {
                HStack {
                    Image(systemName: "clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.secondary)
                        .padding(.trailing)
                    
                    Toggle("24시간제", isOn: $is24HourClock)
                }
                
                HStack {
                    Image(systemName: "bell.badge")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.secondary)
                        .padding(.trailing)
                    
                    Text("알림")
                    
                    Spacer()
                    
                    Text("\(notificationStatus)")
                        .foregroundStyle(notificationManager.isGranted ? Color.pickle : Color.secondary)
                        .onTapGesture {
                            isShowingMoveToSettingAlert = true
                        }
                }
                
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.secondary)
                        .padding(.trailing)
                    
                    Picker(selection: $systemTheme) {
                        ForEach(SchemeType.allCases) { item in
                            Text(item.title)
                                .tag(item.rawValue)
                        }
                    } label: {
                        Text("테마")
                    }
                }
            }
            
            Section("앱 정보") {
//                NavigationLink {
//                    // MARK: 가이드
//                } label: {
//                    HStack {
//                        Image(systemName: "questionmark.circle")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(.secondary)
//                            .padding(.trailing)
//                        
//                        Text("가이드")
//                    }
//                }
                
                Button {
                    // MARK: 앱 정보
                    isShowingSafari = true
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                        
                        Text("앱 정보")
                            .foregroundColor(.primary)
                    }
                    
                }
                
                Button {
                    copyToClipboard()
                    isShowingEmailAlert = true
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                        
                        Text("문의")
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("설정")
        .preferredColorScheme(selectedScheme)
        .task { await notificationManager.getCurrentSetting() }
        .sheet(isPresented: $isShowingSafari, content: {
            WKWebViewPractice(url: appInformationWebViewSite)
        })
        .alert("설정 앱으로 이동하여 알림 권한을 변경합니다.", isPresented: $isShowingMoveToSettingAlert) {
            Button {
                dismiss()
            } label: {
                Text("취소")
            }
            Button {
                notificationManager.openSettings()
            } label: {
                Text("확인")
            }
        }
        .alert("이메일 주소가 복사되었습니다.", isPresented: $isShowingEmailAlert) {
            Button {
                dismiss()
            } label: {
                Text("확인")
            }
        }
    }
    
    func copyToClipboard() {
        pasteboard.string = "realdo.pizza.app@gmail.com"
        
    }
}

struct WKWebViewPractice: UIViewRepresentable {
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: url) else {
            return WKWebView()
        }
        let webView = WKWebView()
        
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<WKWebViewPractice>) {
        guard let url = URL(string: url) else { return }
        
        webView.load(URLRequest(url: url))
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingView()
                .environmentObject(NotificationManager(mediator: NotiMediator()))
        }
    }
}
