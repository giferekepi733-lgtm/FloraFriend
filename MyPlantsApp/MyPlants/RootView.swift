//
//  RootView.swift
//  MyPlantsApp
//
//  Created by D K on 28.10.2025.
//

import SwiftUI

struct RootView: View {
    // Этот флаг будет автоматически сохраняться в UserDefaults.
    // Как только он станет true, онбординг больше не покажется.
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        // Проверяем, был ли онбординг уже пройден
        if hasCompletedOnboarding {
            // Если да, показываем главный экран приложения
            ContentView()
        } else {
            // Если нет, показываем OnboardingView
            OnboardingView(onComplete: {
                // Это замыкание будет вызвано, когда пользователь нажмет "Get Started"
                self.hasCompletedOnboarding = true
            })
        }
    }
}




// Структура для хранения данных одного экрана онбординга
struct OnboardingPageInfo: Identifiable {
    let id = UUID()
    let primaryIcon: String
    let secondaryIcon: String?
    let title: String
    let description: String
    let color: Color
}

// Основной View для онбординга
struct OnboardingView: View {
    
    // Переменная для отслеживания текущей страницы
    @State private var currentPage = 0
    
    // Замыкание, которое будет вызвано для завершения онбординга
    let onComplete: () -> Void
    
    // Данные для наших трех экранов
    private let pages: [OnboardingPageInfo] = [
        OnboardingPageInfo(
            primaryIcon: "camera.viewfinder",
            secondaryIcon: "leaf.fill",
            title: "Welcome to Flora Friend!",
            description: "Easily identify any plant from a photo. We'll create a profile with all the essential care info.",
            color: .primaryGreen
        ),
        OnboardingPageInfo(
            primaryIcon: "calendar",
            secondaryIcon: "drop.fill",
            title: "Never Forget to Water",
            description: "Get smart watering reminders tailored to each of your plants' needs. Keep them happy and hydrated!",
            color: .accentYellow
        ),
        OnboardingPageInfo(
            primaryIcon: "cross.case.fill",
            secondaryIcon: "sparkles",
            title: "Your Personal Plant Doctor",
            description: "Is your plant looking sick? Use our diagnosis tool to identify issues and get treatment advice.",
            color: .secondaryGreen
        )
    ]
    
    var body: some View {
        VStack {
            // TabView для свайпа между страницами
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(info: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle()) // Стиль с точками-индикаторами
            
            // Кнопка "Next" или "Get Started"
            VStack {
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryGreen)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.backgroundLight)
        .edgesIgnoringSafeArea(.all)
    }
}

// Переиспользуемый View для отображения контента одной страницы
struct OnboardingPageView: View {
    let info: OnboardingPageInfo
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Основная иконка
                Image(systemName: info.primaryIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(info.color.gradient)
                
                // Дополнительная иконка, если она есть
                if let secondaryIcon = info.secondaryIcon {
                    Image(systemName: secondaryIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white, info.color.opacity(0.8))
                        .offset(x: 25, y: 25)
                }
            }
            .padding(.bottom, 50)
            
            Text(info.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.textPrimary)
            
            Text(info.description)
                .font(.headline)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 30)
        }
        .padding()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
