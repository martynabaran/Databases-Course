\i 1-ascii.sql;
\i 3-ascii.sql;


\o exercise1.txt
EXPLAIN ANALYZE SELECT * FROM orders WHERE composition_id='buk1';
CREATE INDEX idx_composition ON orders USING hash (composition_id);
EXPLAIN SELECT * FROM orders WHERE composition_id='buk1';
\o

\o exercise2.txt
DROP INDEX idx_composition;
CREATE INDEX tree_idx_composition ON orders(composition_id);
EXPLAIN ANALYZE SELECT * FROM orders WHERE composition_id='buk1';
EXPLAIN ANALYZE SELECT * FROM orders WHERE composition_id < 'c%';
EXPLAIN ANALYZE SELECT * FROM orders WHERE composition_id >= 'c%';
set enable_seqscan to off;
EXPLAIN ANALYZE SELECT * FROM orders WHERE composition_id < 'c%';
EXPLAIN ANALYZE SELECT * FROM orders WHERE composition_id >= 'c%';
\o

\o exercise3.txt
DROP INDEX tree_idx_composition;
create index idx_remarks on orders(remarks);
explain analyze select * from orders where remarks like 'do%';
drop index idx_remarks;
CREATE INDEX orders_remarks_idx ON orders (remarks varchar_pattern_ops);
explain analyze select * from orders where remarks like 'do%';
\o

\o exercise4.txt
drop index orders_remarks_idx;
create index idx_multicolumn on orders (client_id, recipient_id, composition_id);

explain analyze select * from orders where client_id='bzameck' and recipient_id =8 and composition_id='ko4';
explain analyze select * from orders where client_id='bzameck' or recipient_id =8 or composition_id='ko4';
explain analyze select * from orders where composition_id='buk1';
drop index idx_multicolumn;

create index idx_client on orders(client_id);
create index idx_recipient on orders (recipient_id);
create index idx_composition on orders(composition_id);
explain analyze select * from orders where client_id='bzameck' and recipient_id =8 and composition_id='ko4';
explain analyze select * from orders where client_id='bzameck' or recipient_id =8 or composition_id='ko4';
explain analyze select * from orders where composition_id='buk1';
\o

\o exercise5.txt
explain analyze select * from orders order by composition_id;
drop index idx_composition;
explain analyze select * from orders order by composition_id;
drop index idx_recipient, idx_client;
\o

\o exercise6.txt
create index idx_client on orders(client_id) where paid=true;


explain analyze select * from orders where client_id='ztylutek' and paid = true;
explain analyze select * from orders where client_id= 'ztylutek' and paid = false;
explain analyze select count(*) from orders where client_id='ztylutek' and paid=false;
drop index idx_client;
\o

\o exercise7.txt
create index idx_livin on clients (lower(city) text_pattern_ops);
explain analyze select * from clients where city like 'krak%';
\o

\o exercise8.txt
ALTER TABLE orders ADD COLUMN location point;
UPDATE orders SET location=point(random()*100, random()*100);
EXPLAIN ANALYZE SELECT * FROM orders
WHERE sqrt(power(location[0] - 50, 2) + power(location[1] - 50, 2)) <= 10;
explain ANALYZE SELECT *
FROM orders
WHERE location[0] <=50 and location[1]<=50;
create index idx_gist on orders using gist(location);
EXPLAIN ANALYZE SELECT * FROM orders
WHERE sqrt(power(location[0] - 50, 2) + power(location[1] - 50, 2)) <= 10;
explain ANALYZE SELECT *
FROM orders
WHERE location[0] <=50 and location[1]<=50;
DROP INDEX idx_gist;
\o


