import SwiftUI
import WidgetKit

struct 📚NotesListTab: View {
    @EnvironmentObject var model: 📱AppModel
    var body: some View {
        NavigationStack {
            ScrollViewReader { ⓢcrollViewProxy in
                List {
                    self.randomModeSection()
                    Section {
                        Self.NewNoteOnTopButton()
                        ForEach(self.$model.notes) {
                            📗NoteView(source: $0,
                                       titleFont: .title2,
                                       commentFont: .body,
                                       placement: .notesList)
                            .id($0.id)
                        }
                        .onDelete { self.model.deleteNoteOnNotesList($0) }
                        .onMove { self.model.moveNote($0, $1) }
                    } footer: {
                        self.notesCountTextOnFooter()
                    }
                    .animation(.default, value: self.model.notes)
                }
                .navigationBarTitleDisplayMode(.inline)
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: self.self.model.createdNewNoteID) { ⓢcrollViewProxy.scrollTo($0) }
                .onOpenURL { self.model.scrollTopByNewNoteShortcut($0, ⓢcrollViewProxy) }
                .animation(.default, value: self.model.notes)
                .toolbar {
                    switch UIDevice.current.userInterfaceIdiom {
                        case .phone:
                            📚NotesMenuButton(placement: .topBarLeading)
                        case .pad:
                            ToolbarItem(placement: .bottomBar) {
                                📥NotesImportSheetButton()
                            }
                            self.notesCountTextOnBottomBar()
                            📚NotesMenuButton(placement: .bottomBar)
                        default:
                            ToolbarItem { EmptyView() }
                    }
                    self.editButton(placement: .topBarTrailing)
                }
            }
        }
    }
}

private extension 📚NotesListTab {
    private func randomModeSection() -> some View {
        Section {
            🎛️RandomModeToggle()
                .padding(.vertical, 8)
        } footer: {
            🎛️RandomModeToggle.Caption()
        }
    }
    private struct NewNoteOnTopButton: View {
        @EnvironmentObject var model: 📱AppModel
        @Environment(\.editMode) var editMode
        var body: some View {
            Button(action: self.model.addNewNoteOnTop) {
                Label("New note", systemImage: "plus")
                    .font(.title3.weight(.semibold))
                    .padding(.vertical, 7)
            }
            .id("NewNoteButton")
            .disabled(self.editMode?.wrappedValue == .active)
        }
    }
    private func notesCountTextOnFooter() -> some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone
                && self.model.notes.count > 7 {
                Text("Notes count: \(self.model.notes.count)")
            }
        }
    }
    private func notesCountTextOnBottomBar() -> some ToolbarContent {
        ToolbarItem(placement: .status) {
            Text("Notes count: \(self.model.notes.count)")
                .font(.caption.weight(.light))
                .foregroundStyle(.secondary)
        }
    }
    private func editButton(placement: ToolbarItemPlacement) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            EditButton()
                .disabled(self.model.notes.isEmpty)
        }
    }
}
