-- ============================================================
-- V82: Composite indexes for the revenue report.
--
--     Every revenue-report query filters by is_removed and a
--     created_at range (sales_orders, return_orders), or by
--     movement_type and a created_at range (stock_movements, for COGS).
--     The existing single-column IX_so_created_at cannot skip removed
--     rows, and return_orders / stock_movements had no date index at all.
--
--     Guarded with information_schema checks, same as V20.
-- ============================================================

SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'sales_orders'
      AND INDEX_NAME = 'IX_so_removed_created_status'
);
SET @sql := IF(@idx_exists = 0,
    'CREATE INDEX IX_so_removed_created_status ON sales_orders (is_removed, created_at, order_status)',
    'DO 0');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'return_orders'
      AND INDEX_NAME = 'IX_ro_removed_created'
);
SET @sql := IF(@idx_exists = 0,
    'CREATE INDEX IX_ro_removed_created ON return_orders (is_removed, created_at)',
    'DO 0');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'stock_movements'
      AND INDEX_NAME = 'IX_sm_type_created'
);
SET @sql := IF(@idx_exists = 0,
    'CREATE INDEX IX_sm_type_created ON stock_movements (movement_type, created_at)',
    'DO 0');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
