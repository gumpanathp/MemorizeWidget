
import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var 📱: 📱AppModel
    @State private var 🔖Tab: 🔖TabTag = .notesList
    var body: some View {
        TabView(selection: $🔖Tab) {
            🗃NotesListTab()
                .tag(🔖TabTag.notesList)
                .tabItem { Label("Notes", systemImage: "text.justify.leading") }
            🔩OptionTab()
                .tag(🔖TabTag.option)
                .tabItem { Label("Option", systemImage: "gearshape") }
            ℹ️AboutAppTab()
                .tag(🔖TabTag.about)
                .tabItem { Label("About App", systemImage: "questionmark") }
        }
        .onChange(of: 📱.🚩RandomMode) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onOpenURL { 🔗 in
            if !📱.🗃Notes.isEmpty && (🔗.description != "NewItemShortcut") {
                📱.🚩ShowImportSheet = false
                📱.🚩ShowWidgetNote = true
                📱.🆔OpenedNoteID = 🔗.description
            }
            🔖Tab = .notesList
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .sheet(isPresented: $📱.🚩ShowWidgetNote) {
            🪧WidgetNoteSheet()
        }
        .sheet(isPresented: $📱.🚩ShowImportSheet) {
            📂FileImportSheet()
        }
        .onChange(of: 📱.🗃Notes) { _ in
            📱.💾SaveNotes()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    enum 🔖TabTag {
        case notesList, option, about
    }
}


struct 🗃NotesListTab: View {
    @EnvironmentObject var 📱: 📱AppModel
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: 📱.$🚩RandomMode) {
                        Label("Random mode", systemImage: "shuffle")
                            .padding(.vertical, 12)
                    }
                } footer: {
                    Text("Change the note per 5 minutes.")
                }
                
                Button {
                    📱.🆕AddNewNote()
                } label: {
                    Label("New note", systemImage: "plus")
                }
                .onOpenURL { 🔗 in
                    if 🔗.description == "NewItemShortcut" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            📱.🆕AddNewNote()
                        }
                    }
                }
                
                ForEach($📱.🗃Notes) { ⓝote in
                    📓NoteRow(ⓝote)
                }
                .onDelete { ⓘndexSet in
                    📱.🗃Notes.remove(atOffsets: ⓘndexSet)
                }
                .onMove { ⓘndexSet, ⓘnt in
                    📱.🗃Notes.move(fromOffsets: ⓘndexSet, toOffset: ⓘnt)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: 📱.🗃Notes)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        📱.🚩ShowImportSheet.toggle()
                    } label: {
                        Label("Import TSV file", systemImage: "arrow.down.doc")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    struct 📓NoteRow: View {
        @EnvironmentObject var 📱: 📱AppModel
        @FocusState private var 🔍Focus: 🄵ocusPattern?
        @Binding var ⓝote: 📓Note
        var 🎨Thin: Bool { !📱.🚩RandomMode && 📱.🗃Notes.first != ⓝote }
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("+ title", text: $ⓝote.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(🎨Thin ? .tertiary : .primary)
                        .focused($🔍Focus, equals: .title)
                        .onSubmit {
                            UISelectionFeedbackGenerator().selectionChanged()
                            if !ⓝote.title.isEmpty {
                                🔍Focus = .comment
                            }
                        }
                    TextField("+ comment", text: $ⓝote.comment)
                        .font(.footnote)
                        .foregroundStyle(🎨Thin ? .tertiary : .secondary)
                        .opacity(0.8)
                        .focused($🔍Focus, equals: .comment)
                        .onSubmit {
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                }
                .padding(8)
                .padding(.vertical, 8)
                
                Menu {
                    Button {
                        📱.🆔OpenedNoteID = ⓝote.id.description
                        📱.🚩ShowWidgetNote = true
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        Label("Detail", systemImage: "doc.plaintext")
                    }
                    Button {
                        guard let ⓘndex = 📱.🗃Notes.firstIndex(of: ⓝote) else { return }
                        📱.🆕AddNewNote(ⓘndex + 1)
                    } label: {
                        Label("New note", systemImage: "text.append")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                        .padding(8)
                }
                .foregroundStyle(.secondary)
            }
            .onAppear {
                if ⓝote.title == "" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        🔍Focus = .title
                    }
                }
            }
            .onChange(of: 🔍Focus) { ⓝewValue in
                if ⓝewValue == nil {
                    if ⓝote.title == "" {
                        📱.🗃Notes.removeAll(where: { $0 == ⓝote })
                    }
                }
            }
        }
        init(_ ⓝote: Binding<📓Note>) {
            self._ⓝote = ⓝote
        }
        enum 🄵ocusPattern {
            case title, comment
        }
    }
}


struct 🪧WidgetNoteSheet: View {
    @EnvironmentObject var 📱: 📱AppModel
    @EnvironmentObject var 🛒: 🛒StoreModel
    @Environment(\.dismiss) var ﹀Dismiss: DismissAction
    var 🔢NoteIndex: Int? {
        📱.🗃Notes.firstIndex { $0.id.uuidString == 📱.🆔OpenedNoteID }
    }
    var body: some View {
        ZStack {
            Color.clear
            VStack {
                Spacer()
                if let 🔢NoteIndex {
                    TextField("No title", text: $📱.🗃Notes[🔢NoteIndex].title)
                        .font(.title3.bold())
                    TextField("No comment", text: $📱.🗃Notes[🔢NoteIndex].comment)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 32) {
                        Button(role: .destructive) {
                            📱.🗃Notes.remove(at: 🔢NoteIndex)
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        } label: {
                            Image(systemName: "trash")
                                .font(.title3.bold())
                                .foregroundStyle(.secondary)
                        }
                        .tint(.red)
                        📗SystemDictionaryButton(🔢NoteIndex)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.tertiary)
                        🔍SearchButton(🔢NoteIndex)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.top, 64)
                } else {
                    VStack(spacing: 24) {
                        Label("Deleted.", systemImage: "checkmark")
                        Image(systemName: "trash")
                    }
                    .imageScale(.small)
                    .font(.largeTitle)
                }
                Spacer()
                ZStack {
                    Color.clear
                    if 🛒.🚩ADisActive {
                        📣ADView()
                            .padding()
                            .transition(.opacity)
                    }
                }
                .frame(height: 100)
                .animation(.default, value: 🛒.🚩Purchased)
            }
        }
        .animation(.default.speed(1.5), value: 🔢NoteIndex)
        .padding(24)
        .overlay(alignment: .topTrailing) {
            Button {
                ﹀Dismiss.callAsFunction()
                UISelectionFeedbackGenerator().selectionChanged()
            } label: {
                Image(systemName: "chevron.down")
                    .padding(24)
            }
            .tint(.secondary)
            .accessibilityLabel("Dismiss")
        }
    }
}


struct 🔩OptionTab: View {
    @EnvironmentObject var 📱: 📱AppModel
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: 📱.$🚩ShowComment) {
                        Label("Show comment on widget", systemImage: "text.append")
                            .padding(.vertical, 8)
                    }
                    .onChange(of: 📱.🚩ShowComment) { _ in
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    VStack(spacing: 16) {
                        🏞BeforeAfterImage("homeSmall_commentOff", "homeSmall_commentOn")
                        if #available(iOS 16.0, *) {
                            🏞BeforeAfterImage("lockscreen_commentOff", "lockscreen_commentOn")
                        }
                    }
                    .padding()
                    .frame(maxHeight: 500)
                }
                
                🔍SearchCustomizeSection()
                
                if #available(iOS 16.0, *) {
                    Section {
                        Text("If lock screen widgets don't update, please close this app or switch to another app.")
                    } header: {
                        Text("Directions")
                    }
                }
                
                📣ADMenuLink()
                
                Menu {
                    Button(role: .destructive) {
                        📱.🗃Notes.removeAll()
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    } label: {
                        Label("OK, delete all notes.", systemImage: "trash")
                    }
                } label: {
                    ZStack {
                        Color.clear
                        Label("Delete all notes.", systemImage: "trash")
                            .foregroundColor(📱.🗃Notes.isEmpty ? nil : .red)
                    }
                }
                .disabled(📱.🗃Notes.isEmpty)
            }
            .navigationTitle("Option")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    struct 🏞BeforeAfterImage: View {
        var ⓑefore: String
        var ⓐfter: String
        var body: some View {
            HStack {
                Image(ⓑefore)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .rotationEffect(.degrees(1))
                Image(systemName: "arrow.right")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Image(ⓐfter)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .rotationEffect(.degrees(1))
            }
        }
        init(_ ⓑefore: String, _ ⓐfter: String) {
            self.ⓑefore = ⓑefore
            self.ⓐfter = ⓐfter
        }
    }
    struct 🔍SearchCustomizeSection: View {
        @EnvironmentObject var 📱: 📱AppModel
        var ⓛeading: String { 📱.🔗Leading.isEmpty ? "https://duckduckgo.com/?q=" : 📱.🔗Leading }
        var body: some View {
            Section {
                Text(ⓛeading + "NOTETITLE" + 📱.🔗Trailing)
                    .italic()
                    .font(.system(.footnote, design: .monospaced))
                    .padding(8)
                    .frame(minHeight: 100)
                    .animation(.default, value: 📱.🔗Leading.isEmpty)
                TextField("URL scheme", text: $📱.🔗Leading)
                TextField("Trailing component", text: $📱.🔗Trailing)
                    .font(.caption)
            } header: {
                Label("Customize search", systemImage: "magnifyingglass")
            }
            .headerProminence(.increased)
        }
    }
}


struct ℹ️AboutAppTab: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    ZStack {
                        Color.clear
                        VStack(spacing: 12) {
                            Image("ClipedIcon")
                                .resizable()
                                .shadow(radius: 4, y: 1)
                                .frame(width: 100, height: 100)
                            VStack(spacing: 6) {
                                Text("MemorizeWidget")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .tracking(1.5)
                                    .opacity(0.75)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                Text("Application for iPhone / iPad")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        }
                        .padding(48)
                    }
                }
                
                Section {
                    Link(destination: 🔗AppStoreProductURL) {
                        HStack {
                            Label("Open AppStore page", systemImage: "link")
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .imageScale(.small)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        ℹ️AboutAppMenu()
                    } label: {
                        Label("About App", systemImage: "doc")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct 📂FileImportSheet: View {
    @EnvironmentObject var 📱: 📱AppModel
    @State private var 🚩ShowFileImporter: Bool = false
    @State private var 📓ImportedNotes: [📓Note] = []
    var body: some View {
        NavigationView {
            List {
                if 📓ImportedNotes.isEmpty {
                    Button {
                        🚩ShowFileImporter.toggle()
                    } label: {
                        Label("Import TSV file", systemImage: "arrow.down.doc")
                            .font(.title2.weight(.semibold))
                            .padding(.vertical, 8)
                    }
                    
                    Section {
                        HStack {
                            Image("tsvImport_before")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .shadow(radius: 2)
                            Image(systemName: "arrow.right")
                                .font(.title2.weight(.semibold))
                            Image("tsvImport_after")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .shadow(radius: 2)
                        }
                        .frame(maxHeight: 400)
                        .padding(.horizontal, 8)
                        .padding(.vertical)
                        
                        Image("numbers_tsv_export")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding()
                            .frame(maxHeight: 250)
                    }
                }
                
                ForEach(📓ImportedNotes) { ⓝote in
                    VStack(alignment: .leading) {
                        Text(ⓝote.title)
                        Text(ⓝote.comment)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !📓ImportedNotes.isEmpty {
                        Button(role: .cancel) {
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            📓ImportedNotes = []
                        } label: {
                            Label("Cancel", systemImage: "xmark")
                                .font(.body.weight(.semibold))
                        }
                        .tint(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !📓ImportedNotes.isEmpty {
                        Button {
                            📱.🚩ShowImportSheet = false
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                📱.🗃Notes.insert(contentsOf: 📓ImportedNotes, at: 0)
                                📓ImportedNotes = []
                            }
                        } label: {
                            Label("Done", systemImage: "checkmark")
                                .font(.body.weight(.semibold))
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button {
                        📱.🚩ShowImportSheet = false
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.quaternary)
                            .grayscale(1.0)
                            .padding(8)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
        }
        .animation(.default, value: 📓ImportedNotes)
        .fileImporter(isPresented: $🚩ShowFileImporter, allowedContentTypes: [.tabSeparatedText]) { 📦Result in
            📓ImportedNotes = 📂ImportTSVFile(📦Result)
        }
    }
}


struct 📗SystemDictionaryButton: View {
    @EnvironmentObject var 📱: 📱AppModel
    @State private var 🚩ShowSystemDictionary: Bool = false
    var 🔢NoteIndex: Int
    var body: some View {
        Button {
            🚩ShowSystemDictionary = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Label("Dictionary", systemImage: "character.book.closed")
                .labelStyle(.iconOnly)
        }
        .sheet(isPresented: $🚩ShowSystemDictionary) {
            📗SystemDictionarySheet(term: 📱.🗃Notes[🔢NoteIndex].title)
        }
    }
    init(_ 🔢NoteIndex: Int) {
        self.🔢NoteIndex = 🔢NoteIndex
    }
    struct 📗SystemDictionarySheet: View {
        var ⓣerm: String
        var body: some View {
            🄳ictinaryView(term: ⓣerm)
                .ignoresSafeArea()
        }
        struct 🄳ictinaryView: UIViewControllerRepresentable {
            var ⓣerm: String
            func makeUIViewController(context: Context) ->  UIReferenceLibraryViewController {
                UIReferenceLibraryViewController(term: ⓣerm)
            }
            func updateUIViewController(_ uiViewController: UIReferenceLibraryViewController, context: Context) {}
            init(term: String) {
                ⓣerm = term
            }
        }
        init(term: String) {
            ⓣerm = term
        }
    }
}


struct 🔍SearchButton: View {
    @EnvironmentObject var 📱: 📱AppModel
    @Environment(\.openURL) var ⓞpenURL: OpenURLAction
    var 🔢NoteIndex: Int
    var body: some View {
        Button {
            let ⓛeading = 📱.🔗Leading.isEmpty ? "https://duckduckgo.com/?q=" : 📱.🔗Leading
            let ⓣext = ⓛeading + 📱.🗃Notes[🔢NoteIndex].title + 📱.🔗Trailing
            guard let ⓔncodedText = ⓣext.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            guard let ⓤrl = URL(string: ⓔncodedText) else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            ⓞpenURL.callAsFunction(ⓤrl)
        } label: {
            Label("Custom search", systemImage: "magnifyingglass")
                .labelStyle(.iconOnly)
        }
    }
    init(_ 🔢NoteIndex: Int) {
        self.🔢NoteIndex = 🔢NoteIndex
    }
}
