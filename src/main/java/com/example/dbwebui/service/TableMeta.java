package com.example.dbwebui.service;

import java.util.List;

public record TableMeta(
    String table,
    List<ColumnMeta> columns,
    List<String> primaryKeyColumns
) {
  public String primaryKeySingleOrNull() {
    return primaryKeyColumns != null && primaryKeyColumns.size() == 1 ? primaryKeyColumns.get(0) : null;
  }
}
