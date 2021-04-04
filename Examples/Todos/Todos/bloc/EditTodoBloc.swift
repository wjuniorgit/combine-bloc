//
//  EditTodoBloc.swift
//  Todos
//
//  Created by Wellington Soares on 01/04/21.
//

import Foundation
import Combine
import CombineBloc


struct TodoRemoved: Error, Equatable {
}

enum EditTodoEvent: Equatable {
    case NameChanged(String)
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
    let id: UUID
    let isSaved: Bool
    let canSave: Bool
    let isNameValid: Bool

    func copyWith(name: String? = nil, isDone: Bool? = nil, id: UUID? = nil, isSaved: Bool? = nil, canSave: Bool? = nil, isNameValid: Bool? = nil) -> ValidTodoState {
        let name = name ?? self.name
        let isDone = isDone ?? self.isDone
        let id = id ?? self.id
        let isSaved = isSaved ?? self.isSaved
        let canSave = canSave ?? self.canSave
        let isNameValid = isNameValid ?? self.isNameValid
        return ValidTodoState(name: name, isDone: isDone, id: id, isSaved: isSaved, canSave: canSave, isNameValid: isNameValid)
    }
}



final class EditTodoBloc: Bloc<EditTodoEvent, EditTodoState> {

    private var cancellable: AnyCancellable?
    private let todosBloc: Bloc<TodosEvent, TodosState>
    private var id: UUID

    private static func isNameValid(_ name: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", ".{1,}").evaluate(with: name)
    }

    private static func todoFromState(id: UUID?, todosState: TodosState) -> Todo? {
        var optionalTodo: Todo?
        if case let TodosState.Loaded(todos) = todosState {
            let todoInList: Todo? = todos.first { todo -> Bool in
                todo.id == id
            }
            optionalTodo = todoInList
        }
        return optionalTodo
    }

    init(id: UUID = UUID(), todosBloc: Bloc<TodosEvent, TodosState>) {
        self.todosBloc = todosBloc
        self.id = id

        let optionalTodo: Todo? = EditTodoBloc.todoFromState(id: id, todosState: todosBloc.value)
        let isSaved: Bool = optionalTodo != nil ? true : false

        let initialValue = EditTodoState.ValidTodo(ValidTodoState(name: optionalTodo?.name ?? "",
                                                                  isDone: optionalTodo?.isDone ?? false,
                                                                  id: id, isSaved: isSaved, canSave: false, isNameValid: true))

        super.init(initialValue: initialValue)
        { event, state, emit in

            switch event {
            case .NameChanged(let name):
                if case let EditTodoState.ValidTodo(state) = state {
                    let isNameValid = EditTodoBloc.isNameValid(name)
                    emit(.ValidTodo(state.copyWith(name: name, canSave: isNameValid, isNameValid: isNameValid))) }
            case .DoneChanged(let isDone):
                if case let EditTodoState.ValidTodo(state) = state {
                    emit(.ValidTodo(state.copyWith(isDone: isDone, canSave: true))) }
            case .TodoUpdated(let result):
                switch result {
                case .success(let todo):
                    emit(.ValidTodo(ValidTodoState(name: todo.name, isDone: todo.isDone, id: todo.id, isSaved: true, canSave: false, isNameValid: true)))
                case.failure(_):
                 emit(.RemovedTodo)
                }
            case .SaveTodo:
                if case let EditTodoState.ValidTodo(state) = state {
                    if state.isSaved {
                        todosBloc.send(.Update(Todo(id: state.id, name: state.name, isDone: state.isDone)))
                    } else {
                        todosBloc.send(.Add(Todo(id: state.id, name: state.name, isDone: state.isDone)))
                    }
                }
            case .RemoveTodo:
                if case let EditTodoState.ValidTodo(state) = state, state.isSaved {
                    todosBloc.send(.Remove(state.id))
                }
            }
        }


        cancellable = todosBloc.publisher.sink { todosState in
            let optionalTodo = EditTodoBloc.todoFromState(id: self.id, todosState: todosState)
            if let todo = optionalTodo {
                Just(.TodoUpdated(Result.success(todo))).subscribe(self.subscriber)
            } else {
                if case let EditTodoState.ValidTodo(state) = self.value, state.isSaved {
                    Just(.TodoUpdated(Result.failure(TodoRemoved()))).subscribe(self.subscriber)
                }
            }
        }
    }

    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }

}
