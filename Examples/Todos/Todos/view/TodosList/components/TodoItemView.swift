//
//  TodosItemView.swift
//  Todos
//
//  Created by Wellington Soares on 05/04/21.
//

import SwiftUI

struct TodoItemView: View {
  let todo: Todo
  let buttonAction: () -> Void
  let editTodoNavigation: EditTodoNavigationLink

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Button(action: { buttonAction() }) {
          Image(systemName: todo.isDone ? "checkmark.square" : "square")
        }
        Text(todo.name).strikethrough(todo.isDone)
      }.buttonStyle(PlainButtonStyle())
      if todo.description != "" {
        Spacer(minLength: 4)
        Text(todo.description)
          .font(.caption)
      }
      editTodoNavigation(todo)
    }.padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
  }
}
