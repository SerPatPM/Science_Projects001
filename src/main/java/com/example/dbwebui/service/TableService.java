package com.example.dbwebui.service;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Pattern;

@Service
public class TableService {
  private final JdbcTemplate jdbc;
  private static final Pattern IDENT = Pattern.compile("^[A-Za-z0-9_]+$");

  public TableService(JdbcTemplate jdbc) {
    this.jdbc = jdbc;
  }

  public List<String> listTables() {
    return jdbc.query(
        "SELECT table_name FROM information_schema.tables " +
            "WHERE table_schema = DATABASE() AND table_type='BASE TABLE' " +
            "ORDER BY table_name",
        (rs, rowNum) -> rs.getString("table_name")
    );
  }

  public TableMeta getMeta(String table) {
    String t = validateAndNormalizeTable(table);

    List<ColumnMeta> cols = jdbc.query(
        "SELECT column_name, data_type, is_nullable, column_key, extra " +
            "FROM information_schema.columns " +
            "WHERE table_schema = DATABASE() AND table_name = ? " +
            "ORDER BY ordinal_position",
        (rs, rowNum) -> {
          String name = rs.getString("column_name");
          String dataType = rs.getString("data_type");
          boolean nullable = "YES".equalsIgnoreCase(rs.getString("is_nullable"));
          boolean pk = "PRI".equalsIgnoreCase(rs.getString("column_key"));
          boolean autoInc = Optional.ofNullable(rs.getString("extra"))
              .map(String::toLowerCase)
              .orElse("")
              .contains("auto_increment");
          return new ColumnMeta(name, dataType, nullable, pk, autoInc);
        },
        t
    );

    List<String> pkCols = jdbc.query(
        "SELECT column_name FROM information_schema.key_column_usage " +
            "WHERE table_schema = DATABASE() AND table_name = ? AND constraint_name='PRIMARY' " +
            "ORDER BY ordinal_position",
        (rs, rowNum) -> rs.getString("column_name"),
        t
    );

    return new TableMeta(t, cols, pkCols);
  }

  public Map<String, Object> getRows(String table, int limit, int offset) {
    String t = validateAndNormalizeTable(table);
    int lim = Math.min(Math.max(limit, 1), 500);
    int off = Math.max(offset, 0);

    // Table name cannot be parametrized; safe because we validate identifier + verify exists.
    String sql = "SELECT * FROM " + q(t) + " LIMIT ? OFFSET ?";
    List<Map<String, Object>> rows = jdbc.queryForList(sql, lim, off);

    return Map.of(
        "table", t,
        "limit", lim,
        "offset", off,
        "rows", rows
    );
  }

  public Map<String, Object> insertRow(String table, Map<String, Object> values) {
    String t = validateAndNormalizeTable(table);
    TableMeta meta = getMeta(t);

    Map<String, ColumnMeta> colMap = new HashMap<>();
    for (ColumnMeta c : meta.columns()) colMap.put(c.name(), c);

    // Keep only known columns
    LinkedHashMap<String, Object> clean = new LinkedHashMap<>();
    for (var e : values.entrySet()) {
      String col = e.getKey();
      if (!isIdent(col) || !colMap.containsKey(col)) continue;
      // Skip auto-increment columns if empty
      ColumnMeta cm = colMap.get(col);
      Object v = e.getValue();
      if (cm.autoIncrement() && (v == null || String.valueOf(v).isBlank())) continue;
      clean.put(col, v);
    }

    if (clean.isEmpty()) {
      throw new IllegalArgumentException("No hay columnas válidas para insertar.");
    }

    String cols = String.join(", ", clean.keySet().stream().map(this::q).toList());
    String qs = String.join(", ", Collections.nCopies(clean.size(), "?"));

    String sql = "INSERT INTO " + q(t) + " (" + cols + ") VALUES (" + qs + ")";

    int updated = jdbc.update(sql, clean.values().toArray());
    return Map.of(
        "ok", true,
        "affectedRows", updated
    );
  }

  public Map<String, Object> updateRow(String table, String pkColumn, Object pkValue, Map<String, Object> values) {
    String t = validateAndNormalizeTable(table);
    TableMeta meta = getMeta(t);

    if (pkColumn == null || pkColumn.isBlank()) {
      throw new IllegalArgumentException("pkColumn es requerido.");
    }
    if (!isIdent(pkColumn)) {
      throw new IllegalArgumentException("pkColumn inválido.");
    }

    Set<String> pkSet = new HashSet<>(meta.primaryKeyColumns());
    if (!pkSet.contains(pkColumn)) {
      throw new IllegalArgumentException("La columna indicada no es PK en esta tabla.");
    }

    Map<String, ColumnMeta> colMap = new HashMap<>();
    for (ColumnMeta c : meta.columns()) colMap.put(c.name(), c);

    LinkedHashMap<String, Object> clean = new LinkedHashMap<>();
    for (var e : values.entrySet()) {
      String col = e.getKey();
      if (!isIdent(col) || !colMap.containsKey(col)) continue;
      if (pkSet.contains(col)) continue; 
      clean.put(col, e.getValue());
    }

    if (clean.isEmpty()) {
      throw new IllegalArgumentException("No hay columnas válidas para actualizar.");
    }

    String setClause = String.join(", ", clean.keySet().stream().map(c -> q(c) + " = ?").toList());
    String sql = "UPDATE " + q(t) + " SET " + setClause + " WHERE " + q(pkColumn) + " = ?";

    List<Object> params = new ArrayList<>(clean.values());
    params.add(pkValue);

    int updated = jdbc.update(sql, params.toArray());
    return Map.of(
        "ok", true,
        "affectedRows", updated
    );
  }

  public Map<String, Object> runSelect(String sql) {
    if (sql == null) throw new IllegalArgumentException("Pon algo amore.");
    String s = sql.trim();
    if (s.isEmpty()) throw new IllegalArgumentException("Pon algo amore.");

    // Very simple "only SELECT" guard.
    String low = s.toLowerCase(Locale.ROOT);
    if (!low.startsWith("select")) {
      throw new IllegalArgumentException("No sabes leer o q?");
    }
    // Block multi-statement and obvious dangerous keywords
    if (low.contains(";") || low.matches("(?s).*\\b(insert|update|delete|drop|alter|create|truncate|grant|revoke)\\b.*")) {
      throw new IllegalArgumentException("te dije q sin ';' amore.");
    }

    // Limit rows by wrapping, to avoid freezing the UI.
    String limited = "SELECT * FROM (" + s + ") AS t LIMIT 200";

    try {
      List<Map<String, Object>> rows = jdbc.queryForList(limited);
      return Map.of(
          "ok", true,
          "rows", rows,
          "note", "Consulta lista :3."
      );
    } catch (DataAccessException e) {
      throw new IllegalArgumentException("Error SQL: " + rootMessage(e));
    }
  }

  private String validateAndNormalizeTable(String table) {
    if (table == null || table.isBlank()) throw new IllegalArgumentException("Está vacía tu tabla amor.");
    if (!isIdent(table)) throw new IllegalArgumentException("No sabes usar SQL ;(.");

    // Verify it exists in current schema
    List<String> tables = listTables();
    for (String t : tables) {
      if (t.equalsIgnoreCase(table)) return t; // keep canonical case
    }
    throw new IllegalArgumentException("Esa tabla ni está we.");
  }

  private boolean isIdent(String s) {
    return s != null && IDENT.matcher(s).matches();
  }

  private String q(String ident) {
    // Safe because we validate to [A-Za-z0-9_]+
    return "`" + ident + "`";
  }

  private String rootMessage(Throwable t) {
    Throwable cur = t;
    while (cur.getCause() != null) cur = cur.getCause();
    return cur.getMessage();
  }
}
