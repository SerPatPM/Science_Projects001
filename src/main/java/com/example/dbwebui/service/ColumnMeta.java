package com.example.dbwebui.service;

public record ColumnMeta(
    String name,
    String dataType,
    boolean nullable,
    boolean primaryKey,
    boolean autoIncrement
) {}
