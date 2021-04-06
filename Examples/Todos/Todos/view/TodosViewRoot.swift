//
//  TodosView.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import SwiftUI
import Combine
import CombineBloc

typealias AddTodoNavigationLink = (_ isActive: Binding<Bool>, _ label: () -> Button<Text>) -> NavigationLink<Button<Text>, TodoDetailsRoot>
typealias EditTodoNavigationLink = (_ todo: Todo) -> NavigationLink<EmptyView, TodoDetailsRoot>

struct TodosViewRoot: View {
    let todosBloc: Bloc<TodosEvent, TodosState>
    let sortedTodosBloc: Bloc<SortedTodosEvent, SortedTodosState>
    let filteredTodosBloc: Bloc<FilteredTodosEvent, FilteredTodosState>
    let addTodoNavigation: AddTodoNavigationLink
    let editTodoNavigation: EditTodoNavigationLink

    init(todosBloc: Bloc<TodosEvent, TodosState>) {
        self.todosBloc = todosBloc
        self.sortedTodosBloc = SortedTodosBloc(todosBloc: todosBloc)
        self.filteredTodosBloc = FilteredTodosBloc(sortedTodosBloc: sortedTodosBloc)
        self.editTodoNavigation = { todo in
            NavigationLink(
                destination: TodoDetailsRoot(todo: todo, todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) })) {
                EmptyView()
            }
        }
        self.addTodoNavigation = { isActive, label in
            NavigationLink(
                destination: TodoDetailsRoot(todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) }), isActive: isActive, label: label)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                BlocViewBuilder(bloc: filteredTodosBloc) {
                    state in
                    switch state.todosState {
                    case .Loading:
                        ProgressView()
                    case .Loaded(let todos):
                        TodosListView(todos: todos,
                                      update: { todosBloc.send(.Update($0)) },
                                      sort: { sortedTodosBloc.send(.UpdateSortRule($0)) },
                                      filter: { filteredTodosBloc.send(.UpdateFilterRule($0)) },
                                      addTodoNavigation: addTodoNavigation,
                                      editTodoNavigation: editTodoNavigation
                        )
                    case .Error:
                        Text("Error")
                    }
                }
            }.navigationBarTitle("Todo's List")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

