CREATE TABLE FACTORIES (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
main_location VARCHAR2(255)
);
CREATE TABLE WORKERS_FACTORY_1 (
id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
first_name VARCHAR2(100), last_name VARCHAR2(100), age NUMBER,
first_day DATE,
last_day DATE
);
CREATE TABLE WORKERS_FACTORY_2 (
worker_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
first_name VARCHAR2(100), last_name VARCHAR2(100), start_date DATE,
end_date DATE
);
CREATE TABLE SUPPLIERS (
supplier_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
name VARCHAR2(100)
);
CREATE TABLE SPARE_PARTS (
id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
color VARCHAR2(10) CHECK(color in ('red', 'gray', 'black', 'blue', 'silver')), name VARCHAR2(100)
);
CREATE TABLE SUPPLIERS_BRING_TO_FACTORY_1 (
supplier_id NUMBER REFERENCES suppliers(supplier_id), spare_part_id NUMBER REFERENCES spare_parts(id), delivery_date DATE,
quantity NUMBER CHECK(quantity > 0)
);
CREATE TABLE SUPPLIERS_BRING_TO_FACTORY_2 (
supplier_id NUMBER REFERENCES suppliers(supplier_id) NOT NULL,
spare_part_id NUMBER REFERENCES spare_parts(id) NOT NULL,
delivery_date DATE,
quantity NUMBER CHECK(quantity > 0), recipient_worker_id NUMBER REFERENCES workers_factory_2(worker_id) NOT NULL );
CREATE TABLE ROBOTS (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
model VARCHAR2(50)
);
CREATE TABLE ROBOTS_HAS_SPARE_PARTS (
robot_id NUMBER REFERENCES robots(id), spare_part_id NUMBER REFERENCES spare_parts(id)
);
CREATE TABLE ROBOTS_FROM_FACTORY (
robot_id NUMBER REFERENCES robots(id), factory_id NUMBER REFERENCES factories(id)
);
CREATE TABLE AUDIT_ROBOT (
robot_id NUMBER REFERENCES robots(id), created_at DATE
);

CREATE VIEW ALL_WORKERS AS
SELECT w1.last_name, 
       w1.first_name, 
       w1.age, 
       w2.start_date
FROM factories f
JOIN workers_factory_1 w1 ON f.id = w1.id
JOIN workers_factory_2 w2 ON w1.id = w2.worker_id
WHERE w2.end_date IS NULL
ORDER BY w2.start_date DESC;

CREATE VIEW ALL_WORKERS_ELAPSED AS
SELECT last_name, 
       first_name, 
       age, 
       start_date,
       TRUNC(SYSDATE - start_date) AS days_elapsed
FROM ALL_WORKERS;

CREATE VIEW BEST_SUPPLIERS AS
SELECT s.name AS supplier_name,
       SUM(sb1.quantity + sb2.quantity) AS total_quantity_delivered
FROM suppliers s
LEFT JOIN suppliers_bring_to_factory_1 sb1 ON s.supplier_id = sb1.supplier_id
LEFT JOIN suppliers_bring_to_factory_2 sb2 ON s.supplier_id = sb2.supplier_id
GROUP BY s.supplier_id, s.name
HAVING SUM(sb1.quantity + sb2.quantity) > 1000
ORDER BY total_quantity_delivered DESC;

CREATE VIEW ROBOTS_FACTORIES AS
SELECT r.id AS robot_id, r.model, rf.factory_id, f.main_location AS factory_main_location
FROM robots r
JOIN robots_from_factory rf ON r.id = rf.robot_id
JOIN factories f ON rf.factory_id = f.id;
