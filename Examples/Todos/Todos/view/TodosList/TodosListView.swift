//
//  TodosListView.swift
//  Todos
//
//  Created by Wellington Soares on 05/04/21.
//

import SwiftUI

struct TodosListView: View {
    let todos: [Todo]
    let update: (Todo) -> Void
    let sort: (TodosSortRule) -> Void
    let filter: (TodosFilterRule) -> Void
    let addTodoNavigation: AddTodoNavigationLink
    let editTodoNavigation: EditTodoNavigationLink
    @State private var isShowingAddTodoView = false

    var body: some View {
        VStack {
            List(todos) { todo in
                TodoItemView(todo: todo,
                             buttonAction: { update(todo.copyWith(isDone: !todo.isDone)) },
                             editTodoNavigation: editTodoNavigation)
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
                Button("Undone", action: { filter(.notDone) })
            }.padding()
            Spacer()
            addTodoNavigation($isShowingAddTodoView) {
                Button("Add", action: { isShowingAddTodoView = true })
            }.padding()
            }
        }
    }
}
