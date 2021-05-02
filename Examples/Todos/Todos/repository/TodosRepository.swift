//
//  TodosRepository.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import Combine
import Foundation

struct Todo: Equatable, Identifiable, Hashable {
  let id: UUID
  let name: String
  let isDone: Bool
  let description: String

  func copyWith(
    name: String? = nil,
    isDone: Bool? = nil,
    description: String? = nil
  ) -> Todo {
    let name = name ?? self.name
    let isDone = isDone ?? self.isDone
    let description = description ?? self.description
    return Todo(id: id, name: name, isDone: isDone, description: description)
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
  var todos: AnyPublisher<Result<[Todo], TodosRepositoryError>, Never> {
    get
  }
}

final class MockTodosRepository: TodosRepository {
  private var savedTodos: [Todo] {
    didSet {
      cancellable = Just(Result.success(savedTodos))
        .assign(to: \.subject.value, on: self)
    }
  }

  private func loadTodos(delay: Int, mustFail: Bool) {
    if mustFail {
      cancellable = Just(Result.failure(.connectionError)).delay(
        for: .init(integerLiteral: TimeInterval(delay)),
        scheduler: RunLoop.main
      ).assign(to: \.subject.value, on: self)
    } else { cancellable = Just(Result.success(savedTodos)).delay(
      for: .init(integerLiteral: TimeInterval(delay)),
      scheduler: RunLoop.main
    ).assign(to: \.subject.value, on: self)
    }
  }

  init(savedTodos: [Todo], delay: Int = 2, mustFail: Bool = false) {
    self.savedTodos = savedTodos
    loadTodos(delay: delay, mustFail: mustFail)
  }

  var todos: AnyPublisher<Result<[Todo], TodosRepositoryError>, Never> {
    subject.eraseToAnyPublisher()
  }

  private var subject = CurrentValueSubject<
    Result<[Todo], TodosRepositoryError>,
    Never
  >(Result.failure(TodosRepositoryError.loading))

  private var cancellable: AnyCancellable?

  func add(_ todo: Todo) {
    savedTodos.append(todo)
  }

  func remove(_ id: UUID) {
    if let index = savedTodos.firstIndex(where: { $0.id == id }) {
      savedTodos.remove(at: index)
    }
  }

  func update(_ todo: Todo) {
    if let index = savedTodos.firstIndex(where: { $0.id == todo.id }) {
      savedTodos[index] = todo
    }
  }
}
