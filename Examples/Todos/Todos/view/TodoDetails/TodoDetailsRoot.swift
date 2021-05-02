//
//  TodoDetailView.swift
//  Todos
//
//  Created by Wellington Soares on 05/04/21.
//

import Combine
import CombineBloc
import SwiftUI

struct TodoDetailsRoot: View {
  @State var editTodoBloc: Bloc<EditTodoEvent, EditTodoState>
  @Environment(\.presentationMode) var presentation
  let todo: Todo?
  let todosState: AnyPublisher<TodosState, Never>
  let add: (Todo) -> Void
  let update: (Todo) -> Void
  let remove: (UUID) -> Void

  init(
    todo: Todo? = nil,
    todosState: AnyPublisher<TodosState, Never>,
    add: @escaping (Todo) -> Void,
    update: @escaping (Todo) -> Void,
    remove: @escaping (UUID) -> Void
  ) {
    self.todo = todo
    self.todosState = todosState
    self.add = add
    self.update = update
    self.remove = remove
    _editTodoBloc = State(initialValue: EditTodoBloc(
      todo: todo,
      todosState: todosState,
      add: add,
      update: update,
      remove: remove
    ))
    editTodoBloc.cancel()
  }

  var body: some View {
    TransitionListener(bloc: editTodoBloc, action: {
      transition in
      if case .RemovedTodo = transition.nextState {
        self.presentation.wrappedValue.dismiss()
      }
    }) {
      StateViewBuilder(bloc: editTodoBloc) {
        mainState in
        VStack {
          switch mainState {
          case let .ValidTodo(state):
            TodoDetailsView(
              state: state,
              toggleIsDone: {
                editTodoBloc.send(.DoneChanged(!state.isDone))
              },
              updateName: { editTodoBloc.send(.NameChanged($0)) },
              save: { editTodoBloc.send(.SaveTodo) },
              remove: { editTodoBloc.send(.RemoveTodo) }
            )
          case .RemovedTodo:
            ProgressView()
          }
        }.onAppear {
          editTodoBloc = EditTodoBloc(
            todo: todo,
            todosState: self.todosState,
            add: add,
            update: update,
            remove: remove
          )
        }.onDisappear {
          self.editTodoBloc.cancel()
        }
      }
    }
  }
}
