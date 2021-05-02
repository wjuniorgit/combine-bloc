//
//  EditTodoBloc.swift
//  Todos
//
//  Created by Wellington Soares on 01/04/21.
//

import Combine
import CombineBloc
import Foundation

struct TodoRemoved: Error, Equatable {}

enum EditTodoEvent: Equatable {
  case NameChanged(String)
  case DescriptionChanged(String)
  case DoneChanged(Bool)
  case TodoUpdated(Result<Todo, TodoRemoved>)
  case SaveTodo
  case RemoveTodo
}

enum EditTodoState: Equatable {
  case ValidTodo(ValidTodoState)
  case RemovedTodo
}

struct ValidTodoState: Equatable {
  let name: String
  let isDone: Bool
  let description: String
  let id: UUID
  let isSaved: Bool
  let isEdited: Bool
  let isNameValid: Bool

  func copyWith(
    name: String? = nil,
    isDone: Bool? = nil,
    description: String? = nil,
    id: UUID? = nil,
    isSaved: Bool? = nil,
    isEdited: Bool? = nil,
    isNameValid: Bool? = nil
  ) -> ValidTodoState {
    let name = name ?? self.name
    let isDone = isDone ?? self.isDone
    let description = description ?? self.description
    let id = id ?? self.id
    let isSaved = isSaved ?? self.isSaved
    let isEdited = isEdited ?? self.isEdited
    let isNameValid = isNameValid ?? self.isNameValid
    return ValidTodoState(
      name: name,
      isDone: isDone,
      description: description,
      id: id,
      isSaved: isSaved,
      isEdited: isEdited,
      isNameValid: isNameValid
    )
  }
}

final class EditTodoBloc: Bloc<EditTodoEvent, EditTodoState> {
  private var cancellable: AnyCancellable?
  private var todo: Todo?
  private let todosState: AnyPublisher<TodosState, Never>

  private static func isNameValid(_ name: String) -> Bool {
    NSPredicate(format: "SELF MATCHES %@", ".{1,}").evaluate(with: name)
  }

  init(
    todo: Todo? = nil,
    todosState: AnyPublisher<TodosState, Never>,
    add: @escaping (Todo) -> Void,
    update: @escaping (Todo) -> Void,
    remove: @escaping (UUID) -> Void
  ) {
    self.todo = todo
    self.todosState = todosState
    let initialValue = EditTodoState
      .ValidTodo(ValidTodoState(
        name: todo?.name ?? "",
        isDone: todo?
          .isDone ??
          false,
        description: todo?.description ?? "",
        id: todo?
          .id ?? UUID(),
        isSaved: todo !=
          nil ? true :
          false,
        isEdited: false,
        isNameValid: true
      ))

    super.init(initialValue: initialValue) { event, state, emit in

      switch event {
      case let .NameChanged(name):
        if case let EditTodoState.ValidTodo(state) = state {
          let isNameValid = EditTodoBloc.isNameValid(name)
          emit(.ValidTodo(
            state
              .copyWith(
                name: name,
                isEdited: true,
                isNameValid: isNameValid
              )
          ))
        }
      case let .DoneChanged(isDone):
        if case let EditTodoState.ValidTodo(state) = state {
          emit(.ValidTodo(
            state
              .copyWith(isDone: isDone, isEdited: true)
          ))
        }
      case let .DescriptionChanged(description):
        if case let EditTodoState.ValidTodo(state) = state {
          emit(.ValidTodo(
            state
              .copyWith(
                description: description,
                isEdited: true
              )
          ))
        }
      case let .TodoUpdated(result):
        switch result {
        case let .success(todo):
          emit(.ValidTodo(ValidTodoState(
            name: todo.name,
            isDone: todo.isDone,
            description: todo.description,
            id: todo.id,
            isSaved: true,
            isEdited: false,
            isNameValid: true
          )))
        case .failure:
          emit(.RemovedTodo)
        }
      case .SaveTodo:
        if case let EditTodoState.ValidTodo(state) = state {
          let todo = Todo(
            id: state.id,
            name: state.name,
            isDone: state.isDone,
            description: state.description
          )
          if state.isSaved {
            update(todo)
          } else {
            add(todo)
          }
        }
      case .RemoveTodo:
        if case let EditTodoState.ValidTodo(state) = state,
           state.isSaved
        {
          remove(state.id)
        }
      }
    }

    cancellable = todosState.sink { newTodosState in

      if case let .ValidTodo(editTodoState) = self.value {
        if case let .Loaded(newTodos) = newTodosState {
          let optionalTodo: Todo? = newTodos.first { todo -> Bool in
            print(newTodosState)
            print("COUNT \(newTodos.count)")
            print("TODO AIDE: \(todo.id)")
            print("STATE AIDE: \(editTodoState.id)")

            return todo.id == editTodoState.id
          }
          if let todo = optionalTodo {
            self.send(.TodoUpdated(Result.success(todo)))
          } else {
            if editTodoState.isSaved {
              self.send(.TodoUpdated(Result.failure(TodoRemoved())))
            }
          }
        }
      }
    }
  }

  override func cancel() {
    cancellable?.cancel()
    super.cancel()
  }
}
