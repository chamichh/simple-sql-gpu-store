CREATE USER administrator PASSWORD 'admin123' IN GROUP admins;
CREATE USER manager PASSWORD 'managerQWERTY' IN GROUP manager;
CREATE USER owner PASSWORD 'OWNER123' IN GROUP admins
GRANT SELECT, INSERT, DELETE ON manager.* TO ‘manager’;
GRANT ALL ON TABLE orders TO administrator;
GRANT ALL PRIVILEGES ON *.* TO owner;

--1

CREATE TABLE IF NOT EXISTS Customer 
(
Customer_id int PRIMARY KEY,
Customer_email varchar(225) NOT NULL,
Customer_firstname varchar(20) NOT NULL,
Customer_lastname varchar(20) NOT NULL,
Customer_phone int NOT NULL,
Customer_city varchar(15) NOT NULL,
Customer_address varchar(80) NOT NULL
);


INSERT INTO Customer(Customer_id, Customer_email, Customer_firstname, Customer_lastname,
					Customer_phone,Customer_city,Customer_address) 
VALUES
(1, 'janis.kreslins@gmail.com', 'Jānis', 'Krēsliņš', '26839572', 'Rīga','Ieriķu iela 20'),
(2, 'tenis.lielais@gmail.com', 'Tenis', 'Lielais', '29385718', 'Rīga', 'Dārzciema iela 87b'),
(3, 'maija.zobens@gmail.com', 'Maija', 'Zobens', '28530827', 'Rīga', 'Līču iela 2');


--2

CREATE TABLE IF NOT EXISTS Make 
(
Make_id int PRIMARY KEY,
Make_name varchar(60) NOT NULL
);

INSERT INTO Make (Make_id, Make_name) VALUES
(1, 'Nvidia'),
(2, 'AMD Radeon');


--3

CREATE TABLE IF NOT EXISTS Distributor 
(
Distributor_id int PRIMARY KEY,
Distributor_name varchar(60) NOT NULL
);


INSERT INTO Distributor (Distributor_id,Distributor_name) VALUES
(1, 'AUSUS'),
(2, 'MSI'),
(3, 'Gigabyte');



--4

CREATE TABLE IF NOT EXISTS GPU 
(
GPU_id varchar(20) PRIMARY KEY,
GPU_model varchar(50) DEFAULT NULL,
GPU_price int NOT NULL,
Make_id int NOT NULL,
Distributor_id int NOT NULL,
FOREIGN KEY (Make_id) REFERENCES Make(Make_id),
FOREIGN KEY (Distributor_id) REFERENCES Distributor(Distributor_id)
);



INSERT INTO GPU (GPU_id, GPU_model, GPU_year, GPU_price, Make_id, Distributor_id) VALUES
('978-0-321-94786-4', 'TUF-RTX 3090-24G GAMING', '2021', '3500', 1, 1),
('978-0-7303-1484-4', 'RX 6900 XT Gaming X Trio 16G', '2021', '2500', 2, 2),
('978-1-118-94924-5', 'RX 6800 Gaming OC 16GB', '2021', '1700',  2, 3),
('978-1-118-94924-6', 'RTX 3080 Ti GAMING X TRIO 12G', '2021', '2500',  1, 3),
('978-1-118-94924-7', 'RTX 3070 Ti GAMING X TRIO 8G ', '2021', '1500',  1, 2);



--5

CREATE TABLE IF NOT EXISTS ShoppingBasket 
(
ShoppingBasket_id int PRIMARY KEY,
Customer_id int NOT NULL,
FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id)
);


INSERT INTO ShoppingBasket (ShoppingBasket_id,  GPU_id,Customer_id) 
VALUES
(1, 1),
(2, 2),
(3, 3);


--6

CREATE TABLE IF NOT EXISTS Orders 
(
Order_id int PRIMARY KEY,
Order_count decimal(6,2) DEFAULT NULL,
GPU_id varchar(20) NOT NULL,
ShoppingBasket_id int NOT NULL,
FOREIGN KEY (GPU_id) REFERENCES GPU(GPU_id),
FOREIGN KEY (ShoppingBasket_id) REFERENCES ShoppingBasket(ShoppingBasket_id)
);



INSERT INTO orders(Order_id,Order_count,GPU_id,ShoppingBasket_id) VALUES
(1, 1, '978-0-321-94786-4', 1),
(2, 2, '978-1-118-94924-5', 2),
(3, 3, '978-1-118-94924-5', 3),
(4, 1, '978-0-321-94786-4', 3);


    
--7
    
CREATE TABLE IF NOT EXISTS Warehouse 
(
Warehouse_code int PRIMARY KEY,
Warehouse_phone int NOT NULL,
Warehouse_adress varchar(60) NOT NULL
);
    

	
INSERT INTO Warehouse (Warehouse_code,Warehouse_phone,Warehouse_adress) VALUES
(174893, '28395728','Lanas iela 86'),
(178584, '27484496', 'Lubānas iela 294');


--8

CREATE TABLE IF NOT EXISTS Warehouse_GPU 
(
Warehouse_code int NOT NULL,
GPU_id varchar(20) NOT NULL,
GPU_count int NOT NULL CHECK(GPU_count >= 0),
FOREIGN KEY (Warehouse_code) REFERENCES Warehouse(Warehouse_code),
FOREIGN KEY (GPU_id) REFERENCES GPU(GPU_id)
);
    
   
INSERT INTO Warehouse_GPU(Warehouse_code, GPU_id, GPU_count) VALUES
(174893, '978-0-7303-1484-4',1),
(178584, '978-1-118-94924-7', 1);



--indexes

CREATE INDEX index_order_gpu
ON orders (GPU_id);

CREATE INDEX index_customer_name
ON Customer (Customer_firstname);


--triggers
--1
create or replace FUNCTION new_order_count() RETURNS TRIGGER
as $$ begin
	update Warehouse_GPU set GPU_count=(select GPU_count + 1 from Warehouse_GPU where gpu_id in (select distinct GPU_id from Orders))
	where GPU_id in (select distinct GPU_id from Orders);
	RETURN NEW;
commit;
end;$$
language plpgsql 


create trigger new_order_count
after insert on Orders
FOR EACH ROW
execute procedure new_order_count();

--2

create or replace function delete_order_count() RETURNS TRIGGER
as $$ begin
	update Warehouse_GPU set GPU_count=(select GPU_count - 1 from Warehouse_GPU where gpu_id in (select distinct GPU_id from Orders))
	where GPU_id in (select distinct GPU_id from Orders);
	RETURN NEW;
commit;
end;$$
language plpgsql

create trigger delete_order_count
after delete on Orders
FOR EACH ROW
execute procedure delete_order_count();

