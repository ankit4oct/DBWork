import Foundation
import RealmSwift

/// Realm model object.
///
/// Modernized from the Swift 3 / Realm 2.x declaration
/// (`dynamic var` + `override class func primaryKey()`).
///
/// - `@Persisted` replaces `dynamic var` (Realm 10+).
/// - `@Persisted(primaryKey:)` replaces the `primaryKey()` override.
/// - `ObjectKeyIdentifiable` gives SwiftUI `ForEach` a stable identity.
final class Person: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: Int64 = 0
    @Persisted var name: String = ""
    @Persisted var createdAt: Date = Date()

    convenience init(id: Int64, name: String) {
        self.init()
        self.id = id
        self.name = name
        self.createdAt = Date()
    }
}
