create database northwind;	
comment on database northwind is 'Northwind sample data: customer, product, order';

create graph northwind_graph;	
comment on schema northwind_graph is 'Northwind sample data: customer, product, order';

set graph_path=northwind_graph;

-- drop vlabel if exists product;
create vlabel if not exists product;

load from public.products as product_data
create (a:product =to_jsonb(row_to_json(product_data)));
-- match (a:product) return a limit 5;

-- ## update or insert
match (a:product) set 
	a.id = to_json(a.productid), 
    a.name = to_json(a.productname)
;
-- ## rename label properties's key (jsonb)
-- match (a:product) set a = a - 'productid' || jsonb_build_object('id', a->'productid');
/*
product[4.1]{
"id": 1, 
"name": "Chai", 
"productid": 1, 
"unitprice": 18, 
"categoryid": 1, 
"supplierid": 8, 
"productname": "Chai", 
"discontinued": 1, 
"reorderlevel": 10, 
"unitsinstock": 39, 
"unitsonorder": 0, 
"quantityperunit": "10 boxes x 30 bags"
}
*/
-- drop property index if exists idx_product_id;
create property index if not exists idx_product_id on product( id );


-- ===========================================
-- == Vertex: category
-- ===========================================

load from public.categories as category_data
create (a:category =to_jsonb(row_to_json(category_data)));
-- match (a:category) return a limit 5;

-- ## update or insert
match (a:category) set 
	a.id = to_json(a.categoryid), 
    a.name = to_json(a.categoryname)
;
-- drop property index if exists idx_category_id;
create property index if not exists idx_category_id on category( id );


-- ===========================================
-- == Vertex: supplier
-- ===========================================

load from public.suppliers as supplier_data
create (a:supplier =to_jsonb(row_to_json(supplier_data)));
-- match (a:supplier) return a limit 5;

-- ## update or insert
match (a:supplier) set 
	a.id = to_json(a.supplierid), 
    a.name = to_json(a.companyname)
;
-- drop property index if exists idx_supplier_id;
create property index if not exists idx_supplier_id on supplier( id );


-- ===========================================
-- == Edge: part_of
-- ===========================================

-- drop elabel if exists part_of;
MATCH (p:product),(c:category)
WHERE p.categoryid = c.id
CREATE (p)-[:part_of]->(c)
;

-- ===========================================
-- == Edge: SUPPLIES
-- ===========================================

-- drop elabel if exists supplies;
MATCH (p:product),(s:supplier)
WHERE p.supplierID = s.id
CREATE (s)-[:supplies]->(p)
;

-- ===========================================

-- 77 rows
MATCH (s:supplier)-[]->(p:product)-[]->(c:category)
RETURN s.name as s_name, p.name as p_name, c.name as c_name;

-- 5 rows
MATCH (c:category {categoryName:'Produce'})<-[]-(:product)<-[]-(s:supplier)
RETURN DISTINCT s.companyName as ProduceSuppliers
;


-- ===========================================
-- == Vertex: customer
-- ===========================================

load from public.customers as customer_data
create (a:customer =to_jsonb(row_to_json(customer_data)));
-- match (a:customer) return a limit 5;

-- ## update or insert
match (a:customer) set 
	a.id = to_json(a.customerid), 
    a.name = to_json(a.contactname)
;
-- drop property index if exists idx_customer_id;
create property index if not exists idx_customer_id on customer( id );


-- ===========================================
-- == Vertex: order
-- ===========================================

-- **NOTE: order 는 예약어인듯? 그냥은 안되고 (") 붙여야 함!
-- drop vlabel if exists "order";
create vlabel if not exists "order";

load from public.orders as order_data
create (a:"order" =to_jsonb(row_to_json(order_data)));
-- match (a:"order") return a limit 5;

-- ## update or insert
match (a:"order") set 
	a.id = to_json(a.orderid), 
    a.name = to_json('order_||a.orderid')
;
-- drop property index if exists idx_order_id;
create property index if not exists idx_order_id on "order"( id );


-- ===========================================
-- == Edge: PURCHASED
-- ===========================================

-- drop elabel if exists purchased;
MATCH (c:customer),(o:"order")
WHERE c.id = o.customerID
CREATE (c)-[:purchased]->(o)
;


-- ===========================================
-- == Edge: ORDERS
-- ===========================================

-- drop elabel if exists "orders";
create elabel if not exists "orders";

--load from public.order_details as detail_data
--MATCH (p:product), (o:"order")
--WHERE p.id = (detail_data).productid AND o.id = (detail_data).orderid
--CREATE (o)-[d:orders {unitprice:(detail_data).unitprice,quantity:(detail_data).quantityt,discount:(detail_data).discount}]->(p)
-- CREATE (o)-[d:orders =to_jsonb(row_to_json(detail_data))]->(p)
-- set d.quantity = to_json(d.quantity)
-- ******************************************
-- **NOTE: 나중에 set d.quantity = to_json(d.quant) 하는 것은 소용이 없다!!
--         처음에 int로 집어넣어야 인식. 나중에 set 해봐야 sum() 등에서 숫자로 인식 안함 (오류!!)
-- ******************************************
;

load from public.order_details as detail_data
MATCH (p:product), (o:"order")
WHERE p.id = to_jsonb((detail_data).productid) AND o.id = to_jsonb((detail_data).orderid)
CREATE (o)-[d:orders {unitprice: to_jsonb((detail_data).unitprice),quantity: to_jsonb((detail_data).quantity),discount: to_jsonb((detail_data).discount)}]->(p)
;

-- match ()-[d:"orders"]->() return d limit 5;

-- ===========================================

-- **NOTE: jsonb 에 int라고 저장 했어도 SUM(o.quantity::int) 처럼 casting을 해야만 한다
MATCH (cust:customer)-[:PURCHASED]->(:"order")-[o:ORDERS]->(p:product),
      (p)-[:PART_OF]->(c:category {categoryName:'Produce'})
RETURN DISTINCT cust.contactName as CustomerName, SUM(o.quantity) AS TotalProductsPurchased
;

