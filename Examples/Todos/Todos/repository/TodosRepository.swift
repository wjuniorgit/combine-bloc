//
//  TodosRepository.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import Foundation
import Combine

struct Todo: Equatable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let isDone: Bool

    func copyWith(name: String? = nil, isDone: Bool? = nil) -> Todo {
        let name = name ?? self.name
        let isDone = isDone ?? self.isDone
        return Todo(id: self.id, name: name, isDone: isDone)
    }
}


enum TodosRepositoryError: Error, Equatable {
    case connectionError
    case loading
}


protocol TodosRepository {
    func add(_ todo: Todo)
    func remove(_ id: UUID)
    func update(_ todo: Todo)
    var todos: AnyPublisher<Result<Set<Todo>, TodosRepositoryError>, Never> { get }
}

final class MockTodosRepository: TodosRepository {

    private var savedTodos: Set<Todo> {
        didSet {
            cancellable = Just(Result.success(savedTodos)).assign(to: \.subject.value, on: self)
        }
    }

    private func loadTodos() {
        cancellable = Just(Result.success(savedTodos)).delay(for: 2, scheduler: RunLoop.main).assign(to: \.subject.value, on: self)
    }

    init() {
        savedTodos = [Todo(id: UUID(), name: "homework", isDone: false),
                      Todo(id: UUID(), name: "chores", isDone: false),
                      Todo(id: UUID(), name: "breakfast", isDone: true)]
        loadTodos()
    }

    var todos: AnyPublisher<Result<Set<Todo>, TodosRepositoryError>, Never> {
        subject.eraseToAnyPublisher()
    }

    private var subject = CurrentValueSubject<Result<Set<Todo>, TodosRepositoryError>, Never>(Result.failure(TodosRepositoryError.loading))

    private var cancellable: AnyCancellable?

    func add(_ todo: Todo) {
        savedTodos.insert(todo)

    }
    func remove(_ id: UUID) {
        if let index = savedTodos.firstIndex(where: { $0.id == id }) {
            savedTodos.remove(at: index)
        }

    }
    func update(_ todo: Todo) {
        self.remove(todo.id)
        self.add(todo)

    }
}
