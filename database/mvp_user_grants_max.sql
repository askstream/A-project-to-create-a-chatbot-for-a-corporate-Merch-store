-- ==================================================
-- Предоставление прав пользователю mvp
-- ==================================================

-- 1. Создать пользователя (если не существует)
-- Замените 'your_password' на надежный пароль
CREATE USER mvp WITH PASSWORD 'your_password';

-- 2. Предоставить права на подключение к базе данных
-- Замените 'your_database_name' на название вашей БД
GRANT CONNECT ON DATABASE your_database_name TO mvp;

-- 3. Предоставить права на схему public
GRANT USAGE ON SCHEMA public TO mvp;
GRANT CREATE ON SCHEMA public TO mvp;

-- 4. Предоставить права на все существующие таблицы
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO mvp;

-- 5. Предоставить права на все будущие таблицы
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO mvp;

-- 6. Предоставить права на последовательности (sequences)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO mvp;

-- 7. Предоставить права на будущие последовательности
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT USAGE, SELECT ON SEQUENCES TO mvp;

-- 8. Предоставить права на функции
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO mvp;

-- 9. Предоставить права на будущие функции
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT EXECUTE ON FUNCTIONS TO mvp;

-- 10. Проверить предоставленные права
\du mvp
\dp
