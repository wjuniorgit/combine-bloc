//
//  TodosItemView.swift
//  Todos
//
//  Created by Wellington Soares on 05/04/21.
//

import SwiftUI

struct TodoItemView: View {
    let todo: Todo
    let buttonAction: () -> ()
    let editTodoNavigation: EditTodoNavigationLink


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
