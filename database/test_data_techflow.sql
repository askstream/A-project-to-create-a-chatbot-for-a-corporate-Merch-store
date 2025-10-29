-- ================================================================
-- ТЕСТОВЫЕ ДАННЫЕ для магазина TechFlow Solutions Merch Store
-- ================================================================

-- Очистка существующих данных (для тестирования)
TRUNCATE TABLE orders CASCADE;
TRUNCATE TABLE carts CASCADE;
TRUNCATE TABLE products CASCADE;
TRUNCATE TABLE categories CASCADE;
TRUNCATE TABLE faq CASCADE;
TRUNCATE TABLE admins CASCADE;

-- ================================================================
-- 1. КАТЕГОРИИ ТОВАРОВ
-- ================================================================

INSERT INTO categories (id, name, sort_order) VALUES
('apparel', 'Одежда', 1),
('accessories', 'Аксессуары', 2),
('tech', 'Гаджеты', 3),
('office', 'Для офиса', 4);

-- ================================================================
-- 2. ТОВАРЫ
-- ================================================================

-- Категория: Одежда
INSERT INTO products (id, category_id, name, description, price, image_path, is_active, stock) VALUES
('hoodie_navy', 'apparel', 'Худи TechFlow Navy', 
 'Премиальное худи тёмно-синего цвета с вышитым логотипом TechFlow. Состав: 80% хлопок, 20% полиэстер. Плотность 320 г/м². Размеры: XS-XXL',
 3500, 'products/hoodie_navy.jpg', TRUE, 150),

('hoodie_black', 'apparel', 'Худи TechFlow Black Edition', 
 'Лимитированная чёрная серия с оранжевым акцентным логотипом. Oversize крой, унисекс. Размеры: S-XL',
 3800, 'products/hoodie_black.jpg', TRUE, 80),

('tshirt_white', 'apparel', 'Футболка TechFlow Classic White', 
 'Базовая белая футболка с минималистичным логотипом на груди. 100% органический хлопок. Размеры: XS-XXL',
 1200, 'products/tshirt_white.jpg', TRUE, 300),

('tshirt_blue', 'apparel', 'Футболка TechFlow Electric Blue', 
 'Яркая футболка электрик-синего цвета с большим принтом на спине "Code. Build. Deploy.". Размеры: S-XL',
 1400, 'products/tshirt_blue.jpg', TRUE, 200),

('polo_navy', 'apparel', 'Поло TechFlow Corporate', 
 'Деловое поло тёмно-синего цвета с вышивкой логотипа. Идеально для встреч с клиентами. Размеры: S-XXL',
 2200, 'products/polo_navy.jpg', TRUE, 120);

-- Категория: Аксессуары
INSERT INTO products (id, category_id, name, description, price, image_path, is_active, stock) VALUES
('cap_black', 'accessories', 'Бейсболка TechFlow Black', 
 'Классическая чёрная кепка с вышитым логотипом. Регулируемый размер, дышащая ткань',
 800, 'products/cap_black.jpg', TRUE, 250),

('backpack_navy', 'accessories', 'Рюкзак TechFlow Tech Pack', 
 'Городской рюкзак с отделением для ноутбука 15.6", USB-портом для зарядки. Водоотталкивающий материал',
 4500, 'products/backpack_navy.jpg', TRUE, 60),

('tote_white', 'accessories', 'Эко-сумка TechFlow', 
 'Холщовая сумка-шоппер с принтом. Идеально для продуктов и книг. 100% органический хлопок',
 600, 'products/tote_white.jpg', TRUE, 400),

('socks_set', 'accessories', 'Носки TechFlow (3 пары)', 
 'Набор из 3 пар носков с tech-принтами: "Hello World", "404 Not Found", "Git Commit". Размер: 39-45',
 900, 'products/socks_set.jpg', TRUE, 180),

('bottle_steel', 'accessories', 'Термобутылка TechFlow 500ml', 
 'Стальная термобутылка с гравировкой логотипа. Сохраняет температуру 12 часов. Объём: 500 мл',
 1800, 'products/bottle_steel.jpg', TRUE, 150);

-- Категория: Гаджеты
INSERT INTO products (id, category_id, name, description, price, image_path, is_active, stock) VALUES
('powerbank_10k', 'tech', 'Powerbank TechFlow 10000mAh', 
 'Компактный повербанк с логотипом TechFlow. 2 USB-порта, быстрая зарядка. Ёмкость: 10000 мАч',
 2500, 'products/powerbank_10k.jpg', TRUE, 100),

('usb_32gb', 'tech', 'USB-флешка TechFlow 32GB', 
 'Металлическая флешка с гравировкой. USB 3.0, скорость чтения до 150 МБ/с. Объём: 32 ГБ',
 1200, 'products/usb_32gb.jpg', TRUE, 300),

('webcam_cover', 'tech', 'Шторка для веб-камеры (3 шт)', 
 'Набор из 3 шторок для защиты приватности. Подходит для ноутбуков и планшетов. С логотипом TechFlow',
 300, 'products/webcam_cover.jpg', TRUE, 500),

('mousepad_xl', 'tech', 'Коврик для мыши TechFlow XL', 
 'Большой игровой коврик с tech-дизайном и логотипом. Размер: 80x30 см, прорезиненное основание',
 1100, 'products/mousepad_xl.jpg', TRUE, 200);

-- Категория: Для офиса
INSERT INTO products (id, category_id, name, description, price, image_path, is_active, stock) VALUES
('notebook_a5', 'office', 'Блокнот TechFlow A5', 
 'Премиальный блокнот в кожаной обложке с тиснением логотипа. 120 листов, линейка',
 800, 'products/notebook_a5.jpg', TRUE, 250),

('pen_set', 'office', 'Набор ручек TechFlow (3 шт)', 
 'Металлические шариковые ручки с гравировкой. Чернила синие, корпус матовый',
 1500, 'products/pen_set.jpg', TRUE, 150),

('stickers_pack', 'office', 'Стикерпак TechFlow (20 шт)', 
 'Набор виниловых стикеров с IT-мемами и логотипом компании. Водостойкие, для ноутбуков',
 400, 'products/stickers_pack.jpg', TRUE, 600),

('mug_ceramic', 'office', 'Кружка TechFlow Ceramic 350ml', 
 'Керамическая кружка с принтом "Coffee > Sleep". Объём: 350 мл, можно в микроволновку',
 700, 'products/mug_ceramic.jpg', TRUE, 300),

('lanyard_blue', 'office', 'Ланъярд TechFlow', 
 'Синий ланъярд с логотипом и карабином для бейджа. Длина: 90 см',
 200, 'products/lanyard_blue.jpg', TRUE, 1000);

-- ================================================================
-- 3. FAQ (Часто задаваемые вопросы)
-- ================================================================

INSERT INTO faq (question, answer, sort_order) VALUES
('Как оформить заказ?', 
 'Выберите товары, добавьте в корзину и напишите "оформить заказ". Мы попросим указать ваш телефон и адрес доставки.',
 1),

('Какие способы оплаты доступны?', 
 'Принимаем оплату картой онлайн (Visa, MasterCard, МИР) и по счёту для корпоративных клиентов.',
 2),

('Сколько стоит доставка?', 
 'Доставка по Москве — бесплатно при заказе от 3000₽. По России — 300₽ (Boxberry, СДЭК). Доставка занимает 3-7 рабочих дней.',
 3),

('Можно ли вернуть товар?', 
 'Да, вы можете вернуть товар в течение 14 дней с момента получения, если он не был в использовании. Возврат средств — в течение 5 рабочих дней.',
 4),

('Есть ли таблица размеров?', 
 'Да! Одежда TechFlow соответствует стандартным европейским размерам. Подробная таблица доступна в описании каждого товара.',
 5),

('Как получить скидку?', 
 'Сотрудники TechFlow получают 20% скидку автоматически. Для партнёров действует промокод PARTNER10 на 10% скидку.',
 6),

('Делаете ли вы корпоративные заказы?', 
 'Да! Для заказов от 50 единиц предоставляем индивидуальные условия и возможность нанесения логотипа клиента. Свяжитесь с нами: merch@techflow.ru',
 7),

('Когда появятся новые коллекции?', 
 'Мы выпускаем новые коллекции 2 раза в год — весной и осенью. Следите за анонсами в нашем Telegram-канале!',
 8);

-- ================================================================
-- 4. АДМИНИСТРАТОРЫ (для уведомлений о заказах)
-- ================================================================

INSERT INTO admins (tg_user_id, name, role, is_active) VALUES
(123456789, 'Анна Смирнова', 'Менеджер по мерчу', TRUE),
(987654321, 'Дмитрий Петров', 'Логистика', TRUE);

-- ================================================================
-- 5. ТЕСТОВЫЕ КОРЗИНЫ (для демонстрации)
-- ================================================================

INSERT INTO carts (tg_user_id, items) VALUES
(111222333, '[
  {"id": "hoodie_navy", "name": "Худи TechFlow Navy", "price": 3500, "quantity": 1},
  {"id": "tshirt_white", "name": "Футболка TechFlow Classic White", "price": 1200, "quantity": 2}
]'::jsonb);

-- ================================================================
-- 6. ТЕСТОВЫЕ ЗАКАЗЫ (для демонстрации истории)
-- ================================================================

-- Сначала нужно создать order_items для каждого заказа
INSERT INTO orders (order_no, tg_user, phone, address, status) VALUES
('TF-20251028-001', 444555666, '+79991234567', 'Москва, ул. Ленина, д. 10, кв. 25', 'confirmed'),
('TF-20251027-042', 777888999, '+79167654321', 'Санкт-Петербург, Невский пр., д. 100, офис 5', 'confirmed');

-- Теперь добавляем позиции заказов
INSERT INTO order_items (order_id, product_id, name, qty, price_per_unit, total_price) VALUES
-- Для заказа TF-20251028-001
((SELECT id FROM orders WHERE order_no = 'TF-20251028-001'), 'backpack_navy', 'Рюкзак TechFlow Tech Pack', 1, 4500, 4500),
((SELECT id FROM orders WHERE order_no = 'TF-20251028-001'), 'powerbank_10k', 'Powerbank TechFlow 10000mAh', 1, 2500, 2500),
-- Для заказа TF-20251027-042
((SELECT id FROM orders WHERE order_no = 'TF-20251027-042'), 'hoodie_black', 'Худи TechFlow Black Edition', 2, 3800, 7600);

-- ================================================================
-- КОНЕЦ ТЕСТОВЫХ ДАННЫХ
-- ================================================================
