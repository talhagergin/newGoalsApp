import SwiftUI

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goal: Goal
    @ObservedObject var goalManager: GoalManager
    @State private var showingDeleteAlert = false
    @State private var showingReminderSheet = false
    @State private var showingShareSheet = false
    @State private var showingRecurringReminderSheet = false
    @State private var showingJournalEntry = false
    @State private var newTag = ""
    
    init(goal: Goal, goalManager: GoalManager) {
        _goal = State(initialValue: goal)
        self.goalManager = goalManager
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderSection(goal: goal)
                
                // Streak gösterimi
                if let streak = calculateStreak() {
                    StreakView(consecutiveDays: streak)
                }
                
                ProgressSection(goal: $goal, goalManager: goalManager)
                
                // Motivasyon notu
                MotivationNote()
                
                // İstatistikler
                GoalStatistics(goal: goal)
                
                // Paylaşım kartı
                GoalShareCard(goal: goal)
                
                TagsSection(goal: $goal, newTag: $newTag)
                DetailsSection(goal: goal)
                RemindersSection(
                    goal: goal,
                    showingReminderSheet: $showingReminderSheet,
                    showingRecurringReminderSheet: $showingRecurringReminderSheet
                )
                JournalSection(
                    goal: goal,
                    showingJournalEntry: $showingJournalEntry
                )
                ArchiveButton(goal: goal, goalManager: goalManager, dismiss: dismiss)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .alert("Hedefi Sil", isPresented: $showingDeleteAlert) { deleteAlert }
        .sheet(isPresented: $showingReminderSheet) {
            AddReminderView(goal: goal, goalManager: goalManager)
        }
        .sheet(isPresented: $showingRecurringReminderSheet) {
            NavigationStack {
                RecurringReminderView(goal: goal, goalManager: goalManager)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(goal: goal)
        }
        .sheet(isPresented: $showingJournalEntry) {
            NavigationStack {
                AddJournalEntryView(
                    goal: goal,
                    goalManager: goalManager,
                    onSave: { updatedGoal in
                        goal = updatedGoal
                    }
                )
            }
        }
        .onChange(of: goal) { oldValue, newValue in
            goalManager.updateGoal(newValue)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button(action: { showingReminderSheet = true }) {
                    Label("Hatırlatıcı Ekle", systemImage: "bell")
                }
                Button(action: { showingShareSheet = true }) {
                    Label("Paylaş", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("Sil", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    @ViewBuilder
    private var deleteAlert: some View {
        Button("Sil", role: .destructive) {
            goalManager.deleteGoal(goal)
            dismiss()
        }
        Button("İptal", role: .cancel) {}
    }
    
    private func calculateStreak() -> Int? {
        let streak = goal.calculateStreak(using: goalManager.goals)
        return streak > 0 ? streak : nil
    }
}

// MARK: - Sections
private struct HeaderSection: View {
    let goal: Goal
    
    var body: some View {
        HStack {
            Image(systemName: goal.category.icon)
                .font(.title)
            Text(goal.title)
                .font(.title)
        }
    }
}

private struct ProgressSection: View {
    @Binding var goal: Goal
    let goalManager: GoalManager
    @State private var showingConfetti = false
    
    var body: some View {
        VStack {
            ZStack {
                CircularProgressView(goal: goal)
                
                if showingConfetti {
                    ConfettiView()
                        .frame(width: 300, height: 300)
                        .allowsHitTesting(false)
                }
            }
            
            ProgressStepper(goal: $goal, goalManager: goalManager) { completed in
                if completed {
                    withAnimation {
                        showingConfetti = true
                    }
                    // 3 saniye sonra konfeti animasyonunu kapat
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showingConfetti = false
                        }
                    }
                }
            }
        }
    }
}

private struct CircularProgressView: View {
    let goal: Goal
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    goal.category.color.opacity(0.2),
                    lineWidth: 15
                )
            
            Circle()
                .trim(from: 0, to: CGFloat(goal.currentAmount) / CGFloat(goal.targetAmount))
                .stroke(
                    goal.category.color,
                    style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(Int((Double(goal.currentAmount) / Double(goal.targetAmount)) * 100))%")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(goal.category.color)
                
                Text("\(goal.currentAmount)/\(goal.targetAmount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 200, height: 200)
        .padding()
        .animation(.spring(), value: goal.currentAmount)
    }
}

private struct ProgressStepper: View {
    @Binding var goal: Goal
    let goalManager: GoalManager
    let onComplete: (Bool) -> Void
    
    var body: some View {
        HStack {
            Button(action: decrementProgress) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(goal.category.color)
            }
            .disabled(goal.currentAmount <= 0)
            
            Text("İlerleme: \(goal.currentAmount)")
                .frame(minWidth: 100)
                .font(.headline)
            
            Button(action: incrementProgress) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(goal.category.color)
            }
            .disabled(goal.currentAmount >= goal.targetAmount)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    }
    
    private func incrementProgress() {
        if goal.currentAmount < goal.targetAmount {
            goal.currentAmount += 1
            if goal.currentAmount == goal.targetAmount {
                goal.isCompleted = true
                onComplete(true)
            }
            goalManager.updateGoal(goal)
        }
    }
    
    private func decrementProgress() {
        if goal.currentAmount > 0 {
            let wasCompleted = goal.isCompleted
            goal.currentAmount -= 1
            if wasCompleted && goal.currentAmount < goal.targetAmount {
                goal.isCompleted = false
                onComplete(false)
            }
            goalManager.updateGoal(goal)
        }
    }
}

private struct TagsSection: View {
    @Binding var goal: Goal
    @Binding var newTag: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Etiketler")
                .font(.headline)
            TagInputView(tags: $goal.tags, newTag: $newTag)
        }
        .padding()
    }
}

private struct DetailsSection: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Açıklama:")
                .font(.headline)
            Text(goal.description)
            
            Text("Bitiş Tarihi:")
                .font(.headline)
            Text(goal.dueDate.formatted(date: .long, time: .omitted))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RemindersSection: View {
    let goal: Goal
    @Binding var showingReminderSheet: Bool
    @Binding var showingRecurringReminderSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Hatırlatıcılar")
                    .font(.headline)
                Spacer()
                Menu {
                    Button(action: { showingReminderSheet = true }) {
                        Label("Tek Seferlik", systemImage: "bell")
                    }
                    Button(action: { showingRecurringReminderSheet = true }) {
                        Label("Tekrarlayan", systemImage: "bell.badge")
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            
            if !goal.reminders.isEmpty || !goal.recurringReminders.isEmpty {
                RemindersList(goal: goal)
            }
        }
        .padding()
    }
}

private struct RemindersList: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !goal.reminders.isEmpty {
                Text("Tek Seferlik")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ForEach(goal.reminders) { reminder in
                    Text(reminder.message)
                        .foregroundColor(.secondary)
                }
            }
            
            if !goal.recurringReminders.isEmpty {
                Text("Tekrarlayan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ForEach(goal.recurringReminders) { reminder in
                    HStack {
                        Text(reminder.message)
                        Spacer()
                        Text(reminder.frequency.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

private struct JournalSection: View {
    let goal: Goal
    @Binding var showingJournalEntry: Bool
    @State private var showingJournalList = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Günlük")
                    .font(.headline)
                Spacer()
                Button(action: { showingJournalEntry = true }) {
                    Image(systemName: "square.and.pencil")
                }
            }
            
            if goal.journals.isEmpty {
                Text("Henüz günlük girişi yok")
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                // Son 2 günlük girişini göster
                ForEach(goal.journals.prefix(2)) { entry in
                    JournalEntryView(entry: entry)
                }
                
                if goal.journals.count > 2 {
                    Button(action: { showingJournalList = true }) {
                        Text("Tüm Günlükleri Gör (\(goal.journals.count))")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingJournalList) {
            NavigationStack {
                JournalListView(entries: goal.journals)
                    .navigationTitle("Günlük Girişleri")
            }
        }
    }
}

private struct ArchiveButton: View {
    let goal: Goal
    let goalManager: GoalManager
    let dismiss: DismissAction
    
    var body: some View {
        if !goal.isArchived {
            Button(action: {
                goalManager.archiveGoal(goal)
                dismiss()
            }) {
                Label("Arşivle", systemImage: "archivebox")
            }
            .buttonStyle(.bordered)
        }
    }
} 