//
//  TodosView.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import SwiftUI
import Combine
import CombineBloc

typealias AddTodoNavigationLink = (_ isActive: Binding<Bool>, _ label: () -> Button<Text>) -> NavigationLink<Button<Text>, TodoDetails>
typealias EditTodoNavigationLink = (_ todo: Todo) -> NavigationLink<EmptyView, TodoDetails>

struct TodosView: View {
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
                destination: TodoDetails(todo: todo, todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) })) {
                EmptyView()
            }
        }
        self.addTodoNavigation = { isActive, label in
            NavigationLink(
                destination: TodoDetails(todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) }), isActive: isActive, label: label)
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


struct TodosListView: View {
    let todos: [Todo]
    let update: (Todo) -> ()
    let sort: (TodosSortRule) -> ()
    let filter: (TodosFilterRule) -> ()
    let addTodoNavigation: AddTodoNavigationLink
    let editTodoNavigation: EditTodoNavigationLink
    @State private var isShowingAddTodoView = false

    init(todos: [Todo], update: @escaping (Todo) -> (), sort: @escaping(TodosSortRule) -> (), filter: @escaping(TodosFilterRule) -> (), addTodoNavigation: @escaping AddTodoNavigationLink, editTodoNavigation: @escaping EditTodoNavigationLink) {
        self.addTodoNavigation = addTodoNavigation
        self.editTodoNavigation = editTodoNavigation
        self.todos = todos
        self.update = update
        self.sort = sort
        self.filter = filter
    }

    var body: some View {
        VStack {
            List(todos) { todo in
                TodosItemView(todo: todo,
                              buttonAction: { update(todo.copyWith(isDone: !todo.isDone)) },
                              editTodoNavigation: editTodoNavigation
                )
            }.listStyle(GroupedListStyle())
            Spacer()
            HStack { Menu("Sort") {
                    Button("by Done", action: { sort(.done) })
                    Button("by Id", action: { sort(.id) })
                    Button("by Name", action: { sort(.name) })
                }.padding()
                Menu("Filter") {
                    Button("None", action: { filter(.none) })
                    Button("Done", action: { filter(.done) })
                    Button("Undone", action: { filter(.undone) })
                }.padding()
                Spacer()
                addTodoNavigation($isShowingAddTodoView) {
                    Button("Add", action: { isShowingAddTodoView = true })
                }.padding()
            }
        }
    }
}

struct TodosItemView: View {
    let todo: Todo
    let buttonAction: () -> ()
    let editTodoNavigation: EditTodoNavigationLink

    init(todo: Todo, buttonAction: @escaping () -> (),
         editTodoNavigation: @escaping EditTodoNavigationLink) {
        self.editTodoNavigation = editTodoNavigation
        self.todo = todo
        self.buttonAction = buttonAction
    }

    var body: some View {
        HStack {
            Button(action: { buttonAction() }) {
                Image(systemName: todo.isDone ? "checkmark.square" : "square") }
            Text(todo.name)
            Spacer()
            editTodoNavigation(todo)
        }.padding().buttonStyle(PlainButtonStyle())
    }
}

struct TodoDetails: View {
    let todo: Todo?
    let todosState: AnyPublisher<TodosState, Never>
    @State var editTodoBloc: Bloc<EditTodoEvent, EditTodoState>
    @Environment(\.presentationMode) var presentation
    let add: (Todo) -> Void
    let update: (Todo) -> Void
    let remove: (UUID) -> Void

    init(todo: Todo? = nil, todosState: AnyPublisher<TodosState, Never>,
         add: @escaping (Todo) -> Void, update: @escaping (Todo) -> Void, remove: @escaping (UUID) -> Void) {
        self.todo = todo
        self.todosState = todosState
        self.add = add
        self.update = update
        self.remove = remove
        _editTodoBloc = State(initialValue: EditTodoBloc(todo: todo, todosState: todosState, add: add, update: update, remove: remove))
        self.editTodoBloc.cancel()

    }

    var body: some View {

        BlocListener(bloc: editTodoBloc, action: {
            transition in
            if case .RemovedTodo = transition.nextState {
                self.presentation.wrappedValue.dismiss()
            }
        }) {
            BlocViewBuilder(bloc: editTodoBloc) {
                mainState in
                VStack {
                    switch mainState {
                    case .ValidTodo(let state):
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    TextField("Todo Name", text: Binding(get: { state.name }, set: { editTodoBloc.send(.NameChanged($0)) }))
                                        .font(.title)
                                    Text("Please add a Name to your todo").foregroundColor(Color.red)
                                        .font(.caption2)
                                        .opacity(state.isNameValid ? 0.0 : 1.0)
                                }.padding()
                                Spacer()
                            }
                            Spacer()
                            Button(action: { editTodoBloc.send(.DoneChanged(!state.isDone)) }) {
                                Image(systemName: state.isDone ? "checkmark.square" : "square").resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40) }.padding()
                            Spacer()
                            HStack {
                                Button("Save", action: { editTodoBloc.send(.SaveTodo) })
                                    .disabled(state.canSave ? false : true)
                                    .padding()
                                Spacer()
                                Button("Remove", action: { editTodoBloc.send(.RemoveTodo) })
                                    .disabled(state.isSaved ? false : true)
                                    .foregroundColor(Color.red)
                                    .opacity(state.isSaved ? 1.0 : 0.0)
                                    .padding()

                            }
                        }.padding().navigationBarTitle(state.isSaved ? "Edit Todo" : "New Todo")
                    case .RemovedTodo:
                        ProgressView()
                    }
                }.onAppear {
                    editTodoBloc = EditTodoBloc(todo: todo, todosState: self.todosState, add: add, update: update, remove: remove)
                }.onDisappear {
                    self.editTodoBloc.cancel()
                }
            }
        }
    }
}
