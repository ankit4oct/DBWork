import Foundation
import RealmSwift

/// Value-type snapshot of a `Person` for SwiftUI.
///
/// Views render snapshots instead of live thread-confined Realm objects, which
/// keeps the UI layer concurrency-safe (Swift 6) and free of write-transaction
/// crashes. The store re-resolves live objects by primary key on every write.
struct PersonItem: Identifiable, Equatable {
    let id: Int64
    let name: String
    let createdAt: Date
}

/// Observable data layer for `Person` objects.
///
/// Replaces the force-unwrapped, view-controller-embedded Realm calls with a
/// single store using the `@Observable` macro (SwiftUI / iOS 17+).
/// Every mutation re-reads from Realm, so `people` is always fresh without any
/// notification-token threading concerns. All state is main-thread confined:
/// the store never shares live Realm instances across threads (only the
/// `Sendable` configuration is kept), so it stays clean under Swift 6 strict
/// concurrency.
@Observable
final class PersonStore {
    /// Newest-first snapshot of every `Person` in the Realm.
    private(set) var people: [PersonItem] = []

    /// Set when the last operation failed; the UI presents it as an alert.
    var errorMessage: String?

    @ObservationIgnored private var realmConfiguration: Realm.Configuration?

    init() {
        refresh()
    }

    /// Test/preview entry point backed by an isolated in-memory Realm.
    convenience init(inMemoryIdentifier: String, seed: [(id: Int64, name: String)] = []) {
        self.init()
        var config = Realm.Configuration(inMemoryIdentifier: inMemoryIdentifier)
        config.objectTypes = [Person.self]
        realmConfiguration = config
        do {
            let realm = try Realm(configuration: config)
            if !seed.isEmpty {
                try realm.write {
                    for person in seed {
                        realm.add(Person(id: person.id, name: person.name), update: .modified)
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        refresh()
    }

    // MARK: - Create

    func create(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            let realm = try openRealm()
            try realm.write {
                realm.add(Person(id: Self.makeID(), name: trimmed), update: .modified)
            }
            refresh()
        } catch {
            errorMessage = "Couldn't save \"\(trimmed)\": \(error.localizedDescription)"
        }
    }

    // MARK: - Update

    func update(id: Int64, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            let realm = try openRealm()
            guard let live = realm.object(ofType: Person.self, forPrimaryKey: id) else { return }
            try realm.write {
                live.name = trimmed
            }
            refresh()
        } catch {
            errorMessage = "Couldn't update entry: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete

    func delete(id: Int64) {
        do {
            let realm = try openRealm()
            guard let live = realm.object(ofType: Person.self, forPrimaryKey: id) else { return }
            try realm.write {
                realm.delete(live)
            }
            refresh()
        } catch {
            errorMessage = "Couldn't delete entry: \(error.localizedDescription)"
        }
    }

    func deleteAll() {
        do {
            let realm = try openRealm()
            let all = realm.objects(Person.self)
            try realm.write {
                realm.delete(all)
            }
            refresh()
        } catch {
            errorMessage = "Couldn't clear entries: \(error.localizedDescription)"
        }
    }

    // MARK: - Private

    private func openRealm() throws -> Realm {
        if let realmConfiguration {
            return try Realm(configuration: realmConfiguration)
        }
        return try Realm()
    }

    private func refresh() {
        do {
            let realm = try openRealm()
            people = realm.objects(Person.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
                .map { PersonItem(id: $0.id, name: $0.name, createdAt: $0.createdAt) }
        } catch {
            errorMessage = "Couldn't open database: \(error.localizedDescription)"
        }
    }

    /// Millisecond-precision timestamp, matching the legacy `ct()` helper.
    private static func makeID() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}

// MARK: - Previews

extension PersonStore {
    static var preview: PersonStore {
        PersonStore(
            inMemoryIdentifier: "preview",
            seed: [(id: 1, name: "Ada Lovelace"), (id: 2, name: "Grace Hopper")]
        )
    }
}
