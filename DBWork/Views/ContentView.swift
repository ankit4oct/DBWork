import SwiftUI

/// Root view: searchable list of people with add / edit / delete.
///
/// Replaces the legacy `ViewController` (UIKit + `Main.storyboard` outlets and
/// `IBAction`s) with a `NavigationStack`-based SwiftUI view driven by
/// `PersonStore`. String-interpolated predicates and force-unwraps are gone;
/// search filters in-memory snapshots instead.
struct ContentView: View {
    @State private var store: PersonStore
    @State private var searchText = ""
    @State private var isAdding = false
    @State private var personToEdit: PersonItem?
    @State private var personToDelete: PersonItem?
    @State private var isConfirmingClearAll = false

    init(store: PersonStore? = nil) {
        _store = State(initialValue: store ?? PersonStore())
    }

    private var visiblePeople: [PersonItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.people }
        return store.people.filter {
            $0.name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.people.isEmpty {
                    ContentUnavailableView(
                        "No People Yet",
                        systemImage: "person.2",
                        description: Text("Tap + to add your first entry.")
                    )
                } else if visiblePeople.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(visiblePeople) { person in
                            Button {
                                personToEdit = person
                            } label: {
                                PersonRow(item: person)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    personToDelete = person
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("People")
            .searchable(text: $searchText, prompt: "Search by name")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !store.people.isEmpty {
                        Button("Clear All", role: .destructive) {
                            isConfirmingClearAll = true
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAdding = true
                    } label: {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAdding) {
                PersonEditorView(title: "New Person") { name in
                    store.create(name: name)
                }
            }
            .sheet(item: $personToEdit) { person in
                PersonEditorView(title: "Edit Person", initialName: person.name) { name in
                    store.update(id: person.id, name: name)
                }
            }
            .confirmationDialog(
                "Delete this entry?",
                isPresented: Binding(
                    get: { personToDelete != nil },
                    set: { if !$0 { personToDelete = nil } }
                ),
                presenting: personToDelete
            ) { person in
                Button("Delete", role: .destructive) {
                    store.delete(id: person.id)
                }
            } message: { person in
                Text(person.name)
            }
            .confirmationDialog(
                "Delete all entries?",
                isPresented: $isConfirmingClearAll,
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    store.deleteAll()
                }
            }
            .alert(
                "Database Error",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.errorMessage = nil } }
                ),
                presenting: store.errorMessage
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }
}

/// Single row in the people list.
private struct PersonRow: View {
    let item: PersonItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            Text("ID \(item.id) · \(item.createdAt, format: .dateTime)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView(store: .preview)
}
