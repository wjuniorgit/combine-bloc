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
        isDone: false,
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
      ),
      Todo(
        id: UUID(),
        name: "chores",
        isDone: false,
        description: "Donec ac commodo lectus. Mauris sit amet libero."
      ),
      Todo(
        id: UUID(),
        name: "breakfast",
        isDone: true,
        description: "In orci felis, ornare pulvinar laoreet eu, congue."
      )
    ]))
  var body: some View {
    TodosViewRoot(todosBloc: todosBloc)
  }
}
