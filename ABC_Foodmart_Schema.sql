-- ABC Foodmart relational database schema


CREATE TABLE stores (
    store_id       INTEGER,
    store_name     VARCHAR(100) NOT NULL,
    address        VARCHAR(150) NOT NULL,
    borough        VARCHAR(50) NOT NULL,
    phone          VARCHAR(20),
    opening_date   DATE,
    store_status   VARCHAR(20) NOT NULL DEFAULT 'Active',

    PRIMARY KEY (store_id),
    CHECK (store_status IN ('Active', 'Planned', 'Closed'))
);

CREATE TABLE positions (
    position_id      INTEGER,
    position_title   VARCHAR(80) NOT NULL UNIQUE,
    hourly_rate      DECIMAL(8,2) NOT NULL,

    PRIMARY KEY (position_id),
    CHECK (hourly_rate >= 0)
);

CREATE TABLE vendors (
    vendor_id       INTEGER,
    vendor_name     VARCHAR(150) NOT NULL,
    contact_name    VARCHAR(150),
    contact_phone   VARCHAR(30),
    vendor_status   VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    PRIMARY KEY (vendor_id),
    CHECK (vendor_status IN ('ACTIVE', 'INACTIVE'))
);

CREATE TABLE customers (
    customer_id      INTEGER,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    phone            VARCHAR(20),
    email            VARCHAR(100),
    loyalty_number   VARCHAR(30) UNIQUE,
    loyalty_status   VARCHAR(20) NOT NULL DEFAULT 'Non-Member',
    created_date     DATE NOT NULL DEFAULT CURRENT_DATE,

    PRIMARY KEY (customer_id),
    CHECK (loyalty_status IN ('Non-Member', 'Active', 'Inactive'))
);



CREATE TABLE departments (
    department_id     INTEGER,
    store_id          INTEGER NOT NULL,
    department_name   VARCHAR(80) NOT NULL,
    
    PRIMARY KEY (department_id),
    FOREIGN KEY (store_id) REFERENCES stores,
    CONSTRAINT uq_departments_store_name
        UNIQUE (store_id, department_name)
);

CREATE TABLE products (
    product_id       INTEGER,
    product_name     VARCHAR(150) NOT NULL,
    category         VARCHAR(50) NOT NULL,
    vendor_id        INTEGER NOT NULL,
    measure_unit     VARCHAR(20) NOT NULL,
    selling_price    NUMERIC(10,2) NOT NULL,
    product_status   VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    
    PRIMARY KEY (product_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (selling_price >= 0),
    CHECK (product_status IN ('ACTIVE', 'INACTIVE', 'DISCONTINUED'))
);

CREATE TABLE employees (
    employee_id       INTEGER,
    department_id     INTEGER NOT NULL,
    position_id       INTEGER NOT NULL,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    hire_date         DATE NOT NULL,
    employment_type   VARCHAR(20) NOT NULL,
    employee_status   VARCHAR(20) NOT NULL DEFAULT 'Active',
    
    PRIMARY KEY (employee_id),
    FOREIGN KEY (department_id) REFERENCES departments,
    FOREIGN KEY (position_id) REFERENCES positions,
    CHECK (employment_type IN ('Full-Time', 'Part-Time')),
    CHECK (employee_status IN ('Active', 'Inactive', 'Terminated'))
);



CREATE TABLE inventory (
    inventory_id       INTEGER,
    store_id           INTEGER NOT NULL,
    product_id         INTEGER NOT NULL,
    quantity_on_hand   NUMERIC(12,3) NOT NULL DEFAULT 0,
    reorder_point      NUMERIC(12,3) NOT NULL DEFAULT 0,
    last_updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (inventory_id),
    FOREIGN KEY (store_id) REFERENCES stores
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_inventory_store_product
        UNIQUE (store_id, product_id),
    CHECK (quantity_on_hand >= 0),
    CHECK (reorder_point >= 0)
);

CREATE TABLE purchase_orders (
    purchase_order_id       INTEGER,
    vendor_id               INTEGER NOT NULL,
    store_id                INTEGER NOT NULL,
    order_date              DATE NOT NULL,
    order_status            VARCHAR(20) NOT NULL,
    expected_delivery_date  DATE,
    
    PRIMARY KEY (purchase_order_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (store_id) REFERENCES stores
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (order_status IN
            ('DRAFT', 'SUBMITTED', 'APPROVED', 'PARTIALLY_RECEIVED',
             'RECEIVED', 'CANCELLED')),
    CHECK (expected_delivery_date IS NULL
               OR expected_delivery_date >= order_date)
);

CREATE TABLE purchase_order_items (
    purchase_order_item_id  INTEGER,
    purchase_order_id       INTEGER NOT NULL,
    product_id              INTEGER NOT NULL,
    order_quantity          NUMERIC(12,4) NOT NULL,
    unit_cost               NUMERIC(12,4) NOT NULL,
    line_total              NUMERIC(14,2) NOT NULL,
    PRIMARY KEY (purchase_order_item_id),
    FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_orders
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (product_id) 
		REFERENCES products
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_purchase_order_items_order_product
        UNIQUE (purchase_order_id, product_id),
    CHECK (order_quantity > 0),
    CHECK (unit_cost >= 0),
    CHECK (line_total >= 0)
);

CREATE TABLE deliveries (
    delivery_id        INTEGER,
    purchase_order_id  INTEGER NOT NULL,
    store_id           INTEGER NOT NULL,
    delivery_time      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_status    VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    
    PRIMARY KEY (delivery_id),
    FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_orders
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (store_id) REFERENCES stores
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (delivery_status IN
            ('PENDING', 'IN_TRANSIT', 'PARTIALLY_RECEIVED',
             'RECEIVED', 'REJECTED', 'CANCELLED'))
);



CREATE TABLE employee_shifts (
    shift_id       INTEGER,
    employee_id    INTEGER NOT NULL,
    shift_start    TIMESTAMP NOT NULL,
    shift_end      TIMESTAMP NOT NULL,
    shift_status   VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    
    PRIMARY KEY (shift_id),
    FOREIGN KEY (employee_id) REFERENCES employees,
    CHECK (shift_end > shift_start),
    CHECK (shift_status IN
            ('Scheduled', 'Completed', 'Absent', 'Cancelled')),
    CONSTRAINT uq_employee_shift
        UNIQUE (employee_id, shift_start)
);

CREATE TABLE time_off_records (
    time_off_id      INTEGER,
    employee_id      INTEGER NOT NULL,
    time_off_start   TIMESTAMP NOT NULL,
    time_off_end     TIMESTAMP NOT NULL,
    
    PRIMARY KEY (time_off_id),
    FOREIGN KEY (employee_id) REFERENCES employees,
    CHECK (time_off_end > time_off_start),
    CONSTRAINT uq_employee_time_off
        UNIQUE (employee_id, time_off_start, time_off_end)
);

CREATE TABLE operating_expenses (
    expense_id     INTEGER,
    store_id       INTEGER NOT NULL,
    expense_date   DATE NOT NULL,
    expense_type   VARCHAR(80) NOT NULL,
    amount         DECIMAL(12,2) NOT NULL,
    description    VARCHAR(200),
   
    PRIMARY KEY (expense_id),
    FOREIGN KEY (store_id) REFERENCES stores,
    CHECK (amount >= 0)
);



CREATE TABLE promotions (
    promotion_id       INTEGER,
    promotion_name     VARCHAR(100) NOT NULL,
    product_id         INTEGER,
    discount_type      VARCHAR(20) NOT NULL,
    discount_value     DECIMAL(8,2) NOT NULL,
    start_date         DATE NOT NULL,
    end_date           DATE NOT NULL,
    promotion_status   VARCHAR(20) NOT NULL DEFAULT 'Active',
   
    PRIMARY KEY (promotion_id),
    FOREIGN KEY (product_id) REFERENCES products,
    CHECK (discount_type IN ('Percentage', 'Amount')),
    CHECK (discount_value >= 0),
    CHECK (discount_type <> 'Percentage' OR discount_value <= 100),
    CHECK (end_date >= start_date),
    CHECK (promotion_status IN ('Active', 'Inactive', 'Expired'))
);

CREATE TABLE sales (
    sale_id            INTEGER,
    store_id           INTEGER NOT NULL,
    customer_id        INTEGER,
    sale_datetime      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    register_number    VARCHAR(20),
    payment_method     VARCHAR(30) NOT NULL,
    payment_amount     DECIMAL(12,2) NOT NULL,
    total_amount       DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (sale_id),
    FOREIGN KEY (store_id) REFERENCES stores,
    FOREIGN KEY (customer_id) REFERENCES customers,
    CHECK (payment_method IN
            ('Cash', 'Credit Card', 'Debit Card', 'Mobile Payment', 'Gift Card')),
   
    CHECK (payment_amount >= 0),
    CHECK (total_amount >= 0)
);

CREATE TABLE sale_items (
    sale_item_id      INTEGER,
    sale_id           INTEGER NOT NULL,
    product_id        INTEGER NOT NULL,
    promotion_id      INTEGER,
    quantity          INTEGER NOT NULL,
    unit_price        DECIMAL(10,2) NOT NULL,
    discount_amount   DECIMAL(10,2) NOT NULL DEFAULT 0,
    line_total        DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (sale_item_id),
    FOREIGN KEY (sale_id) REFERENCES sales
        ON DELETE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products,
    FOREIGN KEY (promotion_id) REFERENCES promotions,
	CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    CHECK (discount_amount >= 0
               AND discount_amount <= quantity * unit_price),
    CHECK (line_total >= 0)
);

CREATE TABLE returns (
    return_id        INTEGER,
    sale_item_id     INTEGER NOT NULL,
    customer_id      INTEGER,
    return_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    return_quantity  INTEGER NOT NULL,
    return_reason    VARCHAR(100),
    refund_method    VARCHAR(30) NOT NULL,
    refund_amount    DECIMAL(12,2) NOT NULL,
    return_status    VARCHAR(20) NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (return_id),
    FOREIGN KEY (sale_item_id) REFERENCES sale_items,
    FOREIGN KEY (customer_id) REFERENCES customers,
    CHECK (return_quantity > 0),
    CHECK (refund_method IN
            ('Cash', 'Credit Card', 'Debit Card', 'Mobile Payment',
             'Gift Card', 'Store Credit')),
    CHECK (refund_amount >= 0),
    CHECK (return_status IN ('Pending', 'Approved', 'Rejected', 'Completed'))
);


CREATE INDEX ix_departments_store_id ON departments(store_id);
CREATE INDEX ix_employees_department_id ON employees(department_id);
CREATE INDEX ix_employees_position_id ON employees(position_id);
CREATE INDEX ix_inventory_product_id ON inventory(product_id);
CREATE INDEX ix_purchase_orders_vendor_id ON purchase_orders(vendor_id);
CREATE INDEX ix_purchase_orders_store_date ON purchase_orders(store_id, order_date);
CREATE INDEX ix_purchase_order_items_product_id ON purchase_order_items(product_id);
CREATE INDEX ix_deliveries_purchase_order_id ON deliveries(purchase_order_id);
CREATE INDEX ix_deliveries_store_id ON deliveries(store_id);
CREATE INDEX ix_employee_shifts_employee_id ON employee_shifts(employee_id);
CREATE INDEX ix_time_off_records_employee_id ON time_off_records(employee_id);
CREATE INDEX ix_operating_expenses_store_date ON operating_expenses(store_id, expense_date);
CREATE INDEX ix_promotions_product_id ON promotions(product_id);
CREATE INDEX ix_sales_store_datetime ON sales(store_id, sale_datetime);
CREATE INDEX ix_sales_customer_id ON sales(customer_id);
CREATE INDEX ix_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX ix_sale_items_product_id ON sale_items(product_id);
CREATE INDEX ix_sale_items_promotion_id ON sale_items(promotion_id);
CREATE INDEX ix_returns_sale_item_id ON returns(sale_item_id);
CREATE INDEX ix_returns_customer_id ON returns(customer_id);
