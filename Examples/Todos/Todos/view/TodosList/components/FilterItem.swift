//
//  FilterItem.swift
//  Todos
//
//  Created by Wellington Soares on 02/05/21.
//

import SwiftUI

struct FilterItem: View {
  let filterRule: TodosFilterRule
  let selectedFilterRule: TodosFilterRule
  let action: (TodosFilterRule) -> Void

  var body: some View {
    MenuItem(
      title: filterRule == .none ? "No filter" : filterRule == .done ? "Done" :
        "Not done",
      isSelected: filterRule == selectedFilterRule,
      action: { action(filterRule) }
    )
  }
}
