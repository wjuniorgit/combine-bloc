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
  let selectedSortRule: TodosSortRule
  let selectedFilterRule: TodosFilterRule
  @State private var isShowingAddTodoView = false

  var body: some View {
    VStack {
      if todos.count > 0 {
        List(todos) { todo in
          TodoItemView(
            todo: todo,
            buttonAction: {
              update(todo.copyWith(isDone: !todo.isDone))
            },
            editTodoNavigation: editTodoNavigation
          )
        }.listStyle(GroupedListStyle())
      } else {
        Spacer()
        Text("Empty Todo's list")
      }
      Spacer()
      HStack { Menu("Sort") {
        SortItem(sortRule: .done, selectedSortRule: selectedSortRule) {
          sort($0)
        }
        SortItem(sortRule: .id, selectedSortRule: selectedSortRule) {
          sort($0)
        }
        SortItem(sortRule: .name, selectedSortRule: selectedSortRule) {
          sort($0)
        }
      }.padding()
      Menu("Filter") {
        FilterItem(filterRule: .none, selectedFilterRule: selectedFilterRule) {
          filter($0)
        }
        FilterItem(filterRule: .done, selectedFilterRule: selectedFilterRule) {
          filter($0)
        }
        FilterItem(
          filterRule: .notDone,
          selectedFilterRule: selectedFilterRule
        ) { filter($0) }
      }.padding()
      Spacer()
      addTodoNavigation($isShowingAddTodoView) {
        Button("Add", action: { isShowingAddTodoView = true })
      }.padding()
      }
    }
  }
}
