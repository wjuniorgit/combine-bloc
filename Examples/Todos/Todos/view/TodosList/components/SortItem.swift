//
//  SortItem.swift
//  Todos
//
//  Created by Wellington Soares on 02/05/21.
//

import SwiftUI

struct SortItem: View {
  let sortRule: TodosSortRule
  let selectedSortRule: TodosSortRule
  let action: (TodosSortRule) -> Void

  var body: some View {
    MenuItem(
      title: sortRule == .id ? "by Id" : sortRule == .name ? "by Name" :
        "by Done",
      isSelected: sortRule == selectedSortRule,
      action: { action(sortRule) }
    )
  }
}
