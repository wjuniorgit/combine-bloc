//
//  todosBloc.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import Combine
import CombineBloc
import Foundation

enum TodosEvent: Equatable {
  case Add(Todo)
  case Remove(UUID)
  case Update(Todo)
  case ListUpdated(Result<[Todo], TodosRepositoryError>)
}

enum TodosState: Equatable {
  case Loading
  case Loaded([Todo])
  case Error
}

final class TodosBloc: Bloc<TodosEvent, TodosState> {
  private var cancellable: AnyCancellable?
  private let repository: TodosRepository

  init(repository: TodosRepository) {
    self.repository = repository

    super.init(initialValue: TodosState.Loading, mapEventToState: {
      event, _, emit in
      switch event {
      case let .ListUpdated(result):
        switch result {
        case let .failure(error):
          switch error {
          case .connectionError:
            emit(.Error)
          case .loading:
            emit(.Loading)
          }
        case let .success(todos):
          emit(.Loaded(Array(todos)))
        }
      case let .Add(todo):
        repository.add(todo)
      case let .Remove(id):
        repository.remove(id)
      case let .Update(todo):
        repository.update(todo)
      }

    })

    cancellable = repository.todos.sink { todosResult in
      self.send(.ListUpdated(todosResult))
    }
  }

  override func cancel() {
    cancellable?.cancel()
    super.cancel()
  }
}
