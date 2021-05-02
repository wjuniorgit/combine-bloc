//
//  TodosApp.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import Combine
import SwiftUI

@main
struct TodosApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  let todosBloc =
    TodosBloc(repository: MockTodosRepository(savedTodos: [
      Todo(
        id: UUID(),
        name: "homework",
        isDone: false
      ),
      Todo(
        id: UUID(),
        name: "chores",
        isDone: false
      ),
      Todo(
        id: UUID(),
        name: "breakfast",
        isDone: true
      )
    ]))
  var body: some View {
    TodosViewRoot(todosBloc: todosBloc)
  }
}
