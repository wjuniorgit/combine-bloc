//
//  TodosView.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import SwiftUI
import Combine
import CombineBloc

struct TodosView: View {
    let todosBloc: Bloc<TodosEvent, TodosState>
    let sortedTodosBloc: Bloc<SortedTodosEvent, SortedTodosState>
    let filteredTodosBloc: Bloc<FilteredTodosEvent, FilteredTodosState>


    init(todosBloc: Bloc<TodosEvent, TodosState>) {
        self.todosBloc = todosBloc
        self.sortedTodosBloc = SortedTodosBloc(todosBloc: todosBloc)
        self.filteredTodosBloc = FilteredTodosBloc(sortedTodosBloc: sortedTodosBloc)
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
                        TodosListView(todosBloc: todosBloc,
                                      todos: todos,
                                      updateTodo: { todosBloc.send(.Update($0)) },
                                      sort: { sortedTodosBloc.send(.UpdateSortRule($0)) },
                                      filter: { filteredTodosBloc.send(.UpdateFilterRule($0)) })
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
    let updateTodo: (Todo) -> ()
    let sort: (TodosSortRule) -> ()
    let filter: (TodosFilterRule) -> ()
    let todosBloc: Bloc<TodosEvent, TodosState>
    @State private var isShowingAddTodoView = false

    init(todosBloc: Bloc<TodosEvent, TodosState>, todos: [Todo], updateTodo: @escaping (Todo) -> (), sort: @escaping(TodosSortRule) -> (), filter: @escaping(TodosFilterRule) -> ()) {
        self.todosBloc = todosBloc
        self.todos = todos
        self.updateTodo = updateTodo
        self.sort = sort
        self.filter = filter
    }

    var body: some View {
        VStack {
            List(todos) { todo in
                TodosItemView(name: todo.name, isDone: todo.isDone,
                              buttonAction: { updateTodo(todo.copyWith(isDone: !todo.isDone)) },
                              todoDetails: TodoDetails(id: todo.id, todosBloc: todosBloc))
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
                NavigationLink(
                    destination: TodoDetails(todosBloc: todosBloc), isActive: $isShowingAddTodoView) {
                    Button("Add", action: { isShowingAddTodoView = true }).padding() }
            }
        }

    }
}

struct TodosItemView: View {

    let isDone: Bool
    let name: String
    let buttonAction: () -> ()
    let todoDetails: TodoDetails
    //@State private var isShowingTodoDetailsView = false

    init(name: String, isDone: Bool, buttonAction: @escaping () -> (), todoDetails: TodoDetails) {
        self.name = name
        self.isDone = isDone
        self.buttonAction = buttonAction
        self.todoDetails = todoDetails
    }

    var body: some View {
        HStack {
            Button(action: { buttonAction() }) {
                Image(systemName: isDone ? "checkmark.square" : "square") }
            Text(name)
            Spacer()
            NavigationLink(
                destination: todoDetails)
            { EmptyView() }
        }.padding().buttonStyle(PlainButtonStyle())
    }
}

struct TodoDetails: View {
    let todosBloc: Bloc<TodosEvent, TodosState>
    let id: UUID?
    @State var editTodoBloc: Bloc<EditTodoEvent, EditTodoState>
    @Environment(\.presentationMode) var presentation

    init(id: UUID? = nil, todosBloc: Bloc<TodosEvent, TodosState>) {
        self.id = id
        self.todosBloc = todosBloc
        _editTodoBloc = State(initialValue: EditTodoBloc(id: id ?? UUID(), todosBloc: self.todosBloc))
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
                    print("onAppear")
                    editTodoBloc = EditTodoBloc(id: id ?? UUID(), todosBloc: self.todosBloc)
                }.onDisappear {
                    print("onDisappear")
                    self.editTodoBloc.cancel()
                }

            }
        }
    }

}

struct TodosDetailsBody: View {
    let name: String
    let isDone: Bool
    let textFieldUpdate: (String) -> ()

    var body: some View {
        VStack(alignment: .center) {
            Text("Placeholder")
            TextField("Todo", text: Binding(get: { name }, set: { textFieldUpdate($0) }))
            Image(systemName: isDone ? "checkmark.square" : "square")

        }.padding()

    }

}

struct ItemsToolbar: ToolbarContent {
    let add: () -> Void
    let sort: (TodosSortRule) -> Void
    let filter: (TodosFilterRule) -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Add", action: add)
        }

        ToolbarItemGroup(placement: .bottomBar) {
            Menu("Sort") {
                Button("by Done", action: { sort(.done) })
                Button("by Id", action: { sort(.id) })
                Button("by Name", action: { sort(.name) })
            }
            Menu("Filter") {
                Button("None", action: { filter(.none) })
                Button("Done", action: { filter(.done) })
                Button("Undone", action: { filter(.undone) })
            }
        }
    }
}
