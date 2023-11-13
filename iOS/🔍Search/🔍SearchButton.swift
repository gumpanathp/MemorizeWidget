import SwiftUI

struct 🔍SearchButton: View {
    @EnvironmentObject var appModel: 📱AppModel
    @StateObject private var searchModel: 🔍SearchModel = .init()
    private var query: String
    private var padding: CGFloat
    var body: some View {
        Button {
            let ⓤrl = self.searchModel.generateURL(self.query)
            self.appModel.presentSheet(.search(ⓤrl))
        } label: {
            Label("Search", systemImage: "magnifyingglass")
                .padding(self.padding)
        }
        .hoverEffect()
    }
    init(_ ⓝote: 📗Note, padding: CGFloat = 0) {
        self.query = ⓝote.title
        self.padding = padding
    }
}
