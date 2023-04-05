import Foundation

enum 💾UserDefaults {
    static var appGroup: UserDefaults {
        if let ⓥalue = UserDefaults(suiteName: "group.net.aaaakkkkssssttttnnnn.MemorizeWidget") {
            return ⓥalue
        } else {
            assertionFailure(); return .standard
        }
    }
    static func save(_ ⓝotes: 📚Notes) {
        do {
            let ⓓata = try JSONEncoder().encode(ⓝotes)
            Self.appGroup.set(ⓓata, forKey: "Notes")
        } catch {
            print("🚨", error); assertionFailure()
        }
    }
    
    static func loadNotes() -> 📚Notes? {
        guard let ⓓata = 💾UserDefaults.appGroup.data(forKey: "Notes") else { return nil }
        do {
            return try JSONDecoder().decode(📚Notes.self, from: ⓓata)
        } catch {
            print("🚨", error); assertionFailure()
            return []
        }
    }
}

extension UserDefaults {
    static var ⓐppGroup: UserDefaults { 💾UserDefaults.appGroup }
}
