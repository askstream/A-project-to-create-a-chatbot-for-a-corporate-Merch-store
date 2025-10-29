-- ==================================================
-- MVP Store: Корпоративный мерч — Полная схема v3.3
-- ==================================================

-- 1. Таблица категорий
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INT DEFAULT 0
);

-- 2. Таблица товаров
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price INT NOT NULL CHECK (price >= 0),
  image_url TEXT,
  image_path TEXT,  -- Добавлено новое поле
  is_active BOOLEAN DEFAULT TRUE,
  stock INT DEFAULT 999
);

-- 3. FAQ (часто задаваемые вопросы)
CREATE TABLE IF NOT EXISTS faq (
  id SERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  sort_order INT DEFAULT 0
);

-- 4. Корзины (черновики)
CREATE TABLE IF NOT EXISTS carts (
  tg_user_id BIGINT PRIMARY KEY,
  items JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Заказы
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_no TEXT UNIQUE NOT NULL,
  tg_user BIGINT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'confirmed',
  conversation_history JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Позиции заказа
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  name TEXT NOT NULL,
  qty INT NOT NULL CHECK (qty > 0),
  price_per_unit INT NOT NULL,
  total_price INT NOT NULL
);

-- 7. История общения
CREATE TABLE IF NOT EXISTS conversation_history (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    chat_id TEXT NOT NULL,
    role TEXT NOT NULL, -- 'user', 'assistant', 'system'
    content TEXT,
    tool_calls JSONB,
    tool_call_id TEXT,
	sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 8. Администраторы
CREATE TABLE IF NOT EXISTS public.admins
(
    tg_user_id bigint NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'admin'::text,
    is_active boolean DEFAULT true,
    CONSTRAINT admins_pkey PRIMARY KEY (tg_user_id)
)
-- ==================================================
-- Индексы
-- ==================================================
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_orders_tg_user ON orders(tg_user);
CREATE INDEX IF NOT EXISTS idx_carts_tg_user_id ON carts(tg_user_id);
CREATE INDEX idx_chat_history ON conversation_history(chat_id, created_at);

-- ==================================================
-- Последовательность для номеров заказов
-- ==================================================
CREATE SEQUENCE IF NOT EXISTS order_seq START 1;

-- ==================================================
-- Вспомогательные функции
-- ==================================================

-- 1. Получить корзину
CREATE OR REPLACE FUNCTION get_cart(p_tg_user_id BIGINT)
RETURNS JSONB AS $$
DECLARE
  v_cart JSONB;
BEGIN
  SELECT COALESCE(items, '[]'::JSONB) INTO v_cart
  FROM carts WHERE tg_user_id = p_tg_user_id;
  RETURN v_cart;
END;
$$ LANGUAGE plpgsql;

-- 2. Добавить/обновить товар в корзине (ИСПРАВЛЕНО)
CREATE OR REPLACE FUNCTION add_item_to_cart(
  p_tg_user_id BIGINT,
  p_product_id TEXT,
  p_qty INT
)
RETURNS JSONB AS $$
DECLARE
  v_cart JSONB;
  v_product RECORD;
  v_new_items JSONB := '[]'::JSONB;
  v_found BOOLEAN := FALSE;
  item RECORD;
BEGIN
  -- Проверка товара
  SELECT id, name, price INTO v_product
  FROM products
  WHERE id = p_product_id AND is_active = TRUE;
  
  IF v_product.id IS NULL THEN
    RAISE EXCEPTION 'Товар не найден или неактивен: %', p_product_id;
  END IF;
  
  -- Получить текущую корзину с блокировкой
  SELECT items INTO v_cart FROM carts WHERE tg_user_id = p_tg_user_id FOR UPDATE;
  
  IF v_cart IS NULL THEN
    -- Создать новую корзину
    INSERT INTO carts (tg_user_id, items)
    VALUES (p_tg_user_id, jsonb_build_array(
      jsonb_build_object(
        'product_id', p_product_id,
        'name', v_product.name,
        'qty', p_qty,
        'price', v_product.price
      )))
    RETURNING items INTO v_cart;
  ELSE
    -- Обновить существующую корзину
    FOR item IN SELECT * FROM jsonb_array_elements(v_cart) LOOP
      IF (item.value)->>'product_id' = p_product_id THEN
        v_new_items := v_new_items || jsonb_set(item.value, '{qty}', p_qty::TEXT::JSONB);
        v_found := TRUE;
      ELSE
        v_new_items := v_new_items || item.value;
      END IF;
    END LOOP;
    
    -- Если товар не найден, добавить новый
    IF NOT v_found THEN
      v_new_items := v_new_items || jsonb_build_object(
        'product_id', p_product_id,
        'name', v_product.name,
        'qty', p_qty,
        'price', v_product.price
      );
    END IF;
    
    UPDATE carts SET items = v_new_items, updated_at = NOW()
    WHERE tg_user_id = p_tg_user_id RETURNING items INTO v_cart;
  END IF;
  
  RETURN v_cart;
END;
$$ LANGUAGE plpgsql;

-- 3. Удалить товар из корзины
CREATE OR REPLACE FUNCTION remove_item_from_cart(p_tg_user_id BIGINT, p_product_id TEXT)
RETURNS JSONB AS $$
DECLARE
  v_cart JSONB;
  v_new_items JSONB := '[]'::JSONB;
  item RECORD;
BEGIN
  SELECT items INTO v_cart FROM carts WHERE tg_user_id = p_tg_user_id FOR UPDATE;
  
  IF v_cart IS NOT NULL THEN
    FOR item IN SELECT * FROM jsonb_array_elements(v_cart) LOOP
      IF (item.value)->>'product_id' != p_product_id THEN
        v_new_items := v_new_items || item.value;
      END IF;
    END LOOP;
    
    UPDATE carts SET items = v_new_items, updated_at = NOW()
    WHERE tg_user_id = p_tg_user_id RETURNING items INTO v_cart;
  END IF;
  
  RETURN COALESCE(v_cart, '[]'::JSONB);
END;
$$ LANGUAGE plpgsql;

-- 4. Оформить заказ из корзины
CREATE OR REPLACE FUNCTION confirm_order_from_cart(
  p_tg_user_id BIGINT,
  p_phone TEXT,
  p_address TEXT
)
RETURNS TEXT AS $$
DECLARE
  v_cart JSONB;
  v_order_no TEXT;
  v_order_id UUID;
  v_conversation_history JSONB;
  item RECORD;
BEGIN
  SELECT get_cart(p_tg_user_id) INTO v_cart;
  
  IF jsonb_array_length(v_cart) = 0 THEN
    RAISE EXCEPTION 'Корзина пуста';
  END IF;
  
  -- Получаем историю разговора для этого пользователя
  SELECT jsonb_agg(
    jsonb_build_object(
      'role', role,
      'content', content,
      'tool_calls', tool_calls,
      'timestamp', created_at
    ) ORDER BY created_at
  )
  INTO v_conversation_history
  FROM conversation_history
  WHERE user_id = p_tg_user_id
    AND created_at >= NOW() - INTERVAL '24 hours'; -- Последние 24 часа
  
  -- Генерация номера заказа
  v_order_no := 'MERCH-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(NEXTVAL('order_seq')::TEXT, 4, '0');
  
  -- Создание заказа с историей разговора
  INSERT INTO orders (order_no, tg_user, phone, address, conversation_history)
  VALUES (v_order_no, p_tg_user_id, p_phone, p_address, v_conversation_history)
  RETURNING id INTO v_order_id;
  
  -- Добавление позиций заказа
  FOR item IN SELECT * FROM jsonb_array_elements(v_cart) LOOP
    INSERT INTO order_items (order_id, product_id, name, qty, price_per_unit, total_price)
    VALUES (
      v_order_id,
      (item.value)->>'product_id',
      (item.value)->>'name',
      ((item.value)->>'qty')::INT,
      ((item.value)->>'price')::INT,
      ((item.value)->>'qty')::INT * ((item.value)->>'price')::INT
    );
  END LOOP;
  
  -- Очистка корзины
  DELETE FROM carts WHERE tg_user_id = p_tg_user_id;
  
  -- Опционально: очистка истории разговора после оформления заказа
  DELETE FROM conversation_history WHERE user_id = p_tg_user_id;
  
  RETURN v_order_no;
END;
$$ LANGUAGE plpgsql;


-- 5. Очистить корзину
CREATE OR REPLACE FUNCTION cancel_cart(p_tg_user_id BIGINT)
RETURNS JSONB AS $$
BEGIN
  DELETE FROM carts WHERE tg_user_id = p_tg_user_id;
  RETURN '[]'::JSONB;
END;
$$ LANGUAGE plpgsql;


-- 6. ить сообщение в Историю
CREATE OR REPLACE FUNCTION add_message_to_history(
    p_user_id BIGINT,
    p_chat_id TEXT,
    p_role TEXT,
    p_content TEXT,
    p_tool_calls JSONB DEFAULT NULL,
    p_tool_call_id TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    INSERT INTO conversation_history (user_id, chat_id, role, content, tool_calls, tool_call_id)
    VALUES (p_user_id, p_chat_id, p_role, p_content, p_tool_calls, p_tool_call_id);
END;
$$ LANGUAGE plpgsql;

-- 7. Поучить последние N сообщений
CREATE OR REPLACE FUNCTION get_conversation_history(
    p_chat_id TEXT,
    p_limit INT DEFAULT 10
)
RETURNS TABLE (
    role TEXT,
    content TEXT,
    tool_calls JSONB,
    tool_call_id TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT ch.role, ch.content, ch.tool_calls, ch.tool_call_id
    FROM conversation_history ch
    WHERE ch.chat_id = p_chat_id
    ORDER BY ch.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;


-- Представление для публичного каталога
CREATE OR REPLACE VIEW v_products_public AS
SELECT p.id, p.name, p.description, p.price, p.image_url, p.image_path, c.name AS category
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.is_active = TRUE
ORDER BY c.sort_order, p.name;
