import SwiftUI

struct ContentView: View {
    @StateObject private var goalManager = GoalManager()
    @State private var showingAddGoal = false
    @State private var showingStatistics = false
    @State private var showingAchievements = false
    @State private var filterSelection: FilterOption = .all
    @State private var showingTemplates = false
    
    enum FilterOption {
        case all, active, completed, archived
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                StatisticsCard(completionPercentage: goalManager.completionPercentage())
                
                Picker("Filtre", selection: $filterSelection) {
                    Text("Tümü").tag(FilterOption.all)
                    Text("Devam Eden").tag(FilterOption.active)
                    Text("Tamamlanan").tag(FilterOption.completed)
                    Text("Arşiv").tag(FilterOption.archived)
                }
                .pickerStyle(.segmented)
                .padding()
                
                GoalListView(goals: filteredGoals, goalManager: goalManager)
            }
            .navigationTitle("Yılbaşı Hedeflerim")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddGoal = true }) {
                            Label("Yeni Hedef", systemImage: "plus")
                        }
                        Button(action: { showingTemplates = true }) {
                            Label("Şablonlar", systemImage: "doc.text")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { showingStatistics = true }) {
                            Label("İstatistikler", systemImage: "chart.bar.fill")
                        }
                        Button(action: { showingAchievements = true }) {
                            Label("Başarılar", systemImage: "trophy.fill")
                        }
                        NavigationLink(destination: MusicPlayerView()) {
                            Label("Motivasyon Müzikleri", systemImage: "music.note")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goalManager: goalManager)
            }
            .sheet(isPresented: $showingStatistics) {
                NavigationStack {
                    StatisticsView(goalManager: goalManager)
                }
            }
            .sheet(isPresented: $showingAchievements) {
                NavigationStack {
                    AchievementsListView(achievements: Achievement.achievements)
                }
            }
            .sheet(isPresented: $showingTemplates) {
                NavigationStack {
                    GoalTemplatesListView(goalManager: goalManager)
                }
            }
        }
        .background(
            Image("snowflake-pattern")
                .resizable(resizingMode: .tile)
                .opacity(0.1)
        )
    }
    
    var filteredGoals: [Goal] {
        switch filterSelection {
        case .all:
            return goalManager.activeGoals
        case .active:
            return goalManager.activeGoals.filter { !$0.isCompleted }
        case .completed:
            return goalManager.activeGoals.filter { $0.isCompleted }
        case .archived:
            return goalManager.archivedGoals
        }
    }
}

#Preview {
    ContentView()
} 