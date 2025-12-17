package com.example.dbwebui.web;

import com.example.dbwebui.service.TableMeta;
import com.example.dbwebui.service.TableService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiController {
  private final TableService tables;

  public ApiController(TableService tables) {
    this.tables = tables;
  }

  @GetMapping("/tables")
  public List<String> listTables() {
    return tables.listTables();
  }

  @GetMapping("/table/{table}/meta")
  public TableMeta meta(@PathVariable String table) {
    return tables.getMeta(table);
  }

  @GetMapping("/table/{table}/rows")
  public Map<String, Object> rows(
      @PathVariable String table,
      @RequestParam(defaultValue = "100") int limit,
      @RequestParam(defaultValue = "0") int offset
  ) {
    return tables.getRows(table, limit, offset);
  }

  @PostMapping("/table/{table}/insert")
  public Map<String, Object> insert(@PathVariable String table, @RequestBody Map<String, Object> values) {
    return tables.insertRow(table, values);
  }

  @PostMapping("/table/{table}/update")
  public Map<String, Object> update(@PathVariable String table, @RequestBody UpdateRequest req) {
    if (req == null) throw new IllegalArgumentException("Body requerido");
    return tables.updateRow(table, req.pkColumn, req.pkValue, req.values);
  }

  @PostMapping("/query")
  public Map<String, Object> query(@RequestBody QueryRequest req) {
    if (req == null) throw new IllegalArgumentException("Body requerido");
    return tables.runSelect(req.sql);
  }

  @ExceptionHandler(IllegalArgumentException.class)
  public ResponseEntity<Map<String, Object>> badRequest(IllegalArgumentException e) {
    return ResponseEntity.badRequest().body(Map.of(
        "ok", false,
        "error", e.getMessage()
    ));
  }
}
