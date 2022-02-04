-- 搜索结果中去重，对于distinct，只有当搜索的列完全一致才会去重
-- 比如说这里如果我们同时搜索vend_id和prod_id
-- 那么只有当两个字段的值都一致才会去重
SELECT DISTINCT vend_id FROM products;

-- LIMIT 5限制MySQL返回的数据不多于5行
-- 要获取下一个5行可以使用LIMIT 5，5
-- 这里第一个5行表示检索开始位置，第二个5行表示要检索的行数
-- 即从第6行开始往后查询5条数据
-- 即带一个参数的LIMIT默认从第一行开始查找，也就是LIMIT 0,5
-- 在MySQL5中支持一种新的语法 LIMIT 4 OFFSET 3; 它等同于 LIMIT 3,4;
SELECT * FROM products;
SELECT prod_name FROM products LIMIT 5;
SELECT prod_name FROM products LIMIT 5,5;

-- mysql的完全限定表名/列名书写方式为表名.列名
-- 这种写法相对于直接书写列名而言更加严谨
SELECT products.prod_name FROM mysqlcc.products LIMIT 5;


-- 一般我们使用order by子句实现对查询数据排序，
-- 但是这里的排序条件可以是查询的列，也可以是未查询的列
SELECT prod_name,prod_id FROM products ORDER BY prod_name;
SELECT prod_name,prod_id FROM products ORDER BY prod_price;

-- 在对结果排序时，我们可以同时对多个列进行排序，
-- 这样实际的执行顺序是第一个先对第一个排序条件进行排序
-- 之后再对第一个条件相同的行按照第二个排序条件排序
SELECT prod_id,prod_name,prod_price FROM products ORDER BY prod_price,prod_name;

-- 除了制定排序的列之外我们还可以指定排序的方向（升序降序），
-- 默认情况下查询列是以升序排列，这里有一个默认的acs值
-- 我们可以在排序的列后面加上desc让该列按照降序排列
-- 如下面的sql中prod_price按照降序排列,prod_name按照升序排列,这里的asc可以省略
-- 对于大多数数据库而言 A和a的排序规则是一致的，如果要区分大小写排序，需要对数据库进行单独设置
SELECT prod_id,prod_name,prod_price FROM products ORDER BY prod_price DESC ,prod_name ASC;

-- LIMIT子句可以和ORDER BY子句组合使用，如下面查询最贵或最便宜的商品价格
-- ORDER BY子句在使用时应保证其位置在from子句之后，
-- LIMIT 子句应保证其位置在order by子句之后
SELECT prod_id,prod_name,prod_price FROM products ORDER BY prod_price DESC LIMIT 1;
SELECT prod_id,prod_name,prod_price FROM products ORDER BY prod_price ASC LIMIT 1;


-- 使用where子句可以实现对数据的过滤
SELECT prod_name,prod_price FROM products WHERE prod_price = 2.5;
-- 使用where子句配合between···and···实现范围查询，下面的sql会查询出所有商品售价在5~10美元之间的商品
-- BETWEEN会匹配范围中所有的值，包括指定的开始值和结束值
SELECT prod_name,prod_price FROM products WHERE prod_price BETWEEN 5 AND 10;
-- 在创建表时，可以指定一个列允许不包含任何值，即该列的值可以使null，这里的null不同于空格或空字符
-- 在where子句中可以使用 IS NULL 或 ISNULL(expr)函数来判断空值
SELECT prod_name,prod_price FROM products WHERE prod_price IS NULL;
SELECT cust_id FROM customers WHERE cust_email IS NULL;
SELECT cust_id FROM customers WHERE ISNULL(cust_email);

-- 使用where组合and使用，同时过滤多个条件
-- 找出同时满足一下两个条件的行
SELECT prod_name,prod_price FROM products WHERE prod_price = 2.5 AND prod_name = 'Carrots';
-- 使用where组合or使用，过滤满足多个条件之一的行
SELECT prod_name,prod_price FROM products WHERE prod_price = 2.5 OR prod_price = 10;

-- 操作符计算顺序
-- 在SQL中，AND的优先级要高于 OR ，因此在计算时会先计算 AND 再计算 OR ，
-- 如果我们需要自己规定运算次序，则可以在sql中使用括号做限定
SELECT * FROM products;
-- 我们实际想要查询的是vend_id等于1002或1003，并且价格大于10的产品
-- 但是sql解析出来的是vend_id等于1002，或者vend_id等于1003并且价格大于10的产品
SELECT vend_id, prod_name, prod_price FROM products WHERE vend_id = 1002 OR vend_id = 1003 AND prod_price >=10;
-- 为了解决上面的问题，我们可以使用括号限定sql执行顺序。在使用and和or时，即使顺序明确最好也都加上括号
SELECT vend_id, prod_name, prod_price FROM products WHERE (vend_id = 1002 OR vend_id = 1003) AND prod_price >=10;

-- WHERE ··· IN指定条件范围中，每个条件都可以生效，IN的合法取值清单都在圆括号中
-- 相对于or来讲，in具有语法清晰易于管理，计算次序容易管理，执行速度快等优点
-- in 操作符可以结合select实现动态的sql查询
SELECT prod_name, prod_price FROM products WHERE vend_id IN (1002,1003) ORDER BY prod_name;

-- NOT在where中可以实现对条件的否定,下面的sql用于查询id不为1002和1003的行
SELECT prod_name, prod_price FROM products WHERE vend_id NOT IN (1002,1003) ORDER BY prod_name;

-- 除了上面的精确搜索之外，还可以使用where···like 实现模糊查询
-- where···like后面的条件一般会使用通配符进行匹配。%通配符不能匹配null值
-- '%'表示任意字符出现任意次数, '_'表示任意字符出现一次。通配符可以出现在条件的任意位置以实现不同条件查询
-- 查找所有以jet开头的产品
SELECT vend_id, prod_name, prod_price FROM products WHERE prod_name LIKE 'jet%';
-- 查找所有包含pack的产品
SELECT vend_id, prod_name, prod_price FROM products WHERE prod_name LIKE '%pack%';
-- 查找所有以s开头e结尾的产品
SELECT vend_id, prod_name, prod_price FROM products WHERE prod_name LIKE 's%e';
-- 使用'_'通配符可以匹配一个字符
SELECT vend_id, prod_name, prod_price FROM products WHERE prod_name LIKE '_etPack 1000';


-- MySQL正则表达式匹配
-- 查询名称包含1000的所有的行
SELECT prod_name FROM products WHERE prod_name REGEXP '1000';
-- 查询名字包含000的产品,'.'表示匹配任意一个字符
SELECT prod_name FROM products WHERE prod_name REGEXP '.000';
-- 在mysql中，正则表达式是不区分大小写的，如果需要正则表达式区分大小写，可以加上binary关键字
SELECT prod_name FROM products WHERE prod_name REGEXP BINARY 'jetPack .000';
-- 使用正则表达式匹配or，下面的sql匹配名称中包含1000或2000的产品，这里还可以添加多个条件
SELECT prod_name FROM products WHERE prod_name REGEXP '1000|2000';
-- 使用正则表达式匹配特定的字符
-- 下面的sql匹配名字中包含1 ton或2 ton 或3 ton的产品，其中'[]'表示匹配其中任意一个字符，等同于[1|2|3]
SELECT prod_name FROM products WHERE prod_name REGEXP '[123] ton';
-- 字符集合可以被否定，只需要在字符集合前面加上'^'即可
-- 下面的sql表示匹配除指定字符之外的行
SELECT prod_name FROM products WHERE prod_name REGEXP '[^123] ton';
-- 正则表达式匹配一个集合范围
-- 在上面的sql中实现了匹配一个集合，如果这个集合的元素很多并且连续，我们可以使用'-'匹配一个集合范围
-- 下面的sql匹配1~5的字符集合
SELECT prod_name FROM products WHERE prod_name REGEXP '[1-5] ton';
SELECT prod_name FROM products WHERE prod_name REGEXP '[1-5] t[m-z]n';
-- 在使用正则匹配特殊字符时，需要对匹配条件做转义，如查找名称包含'.'的产品
-- 下面的sql如果直接使用'.'作为条件匹配，会查出所有的产品，对于mysql的转义，需要用到两个反斜杠
SELECT prod_name FROM products WHERE prod_name REGEXP '\\.';

-- 使用正则表达式匹配多个实例
-- 下面的正则中，'\\('表示匹配'('，'[0-9]'表示匹配0-9的数字，'sticks?'表示匹配'stick'或'sticks'，其中'?'表示前面的字符出现0次或1次
SELECT prod_name FROM products WHERE prod_name REGEXP '\\([0-9] sticks?\\)' ORDER BY prod_name;
-- 下面的sql表示匹配连在一起的4位数字
-- 两个sql表达的意思相同，其中{4}表示前面的字符出现4次
SELECT prod_name FROM products WHERE prod_name REGEXP '[[:digit:]]{4}' ORDER BY prod_name;
SELECT prod_name FROM products WHERE prod_name REGEXP '[0-9]{4}' ORDER BY prod_name;
-- 匹配行的开始，下面的sql匹配名称以'.'开头的产品
SELECT prod_name FROM products WHERE prod_name REGEXP '^\\.' ORDER BY prod_name;
-- 匹配行的结尾，下面的sql匹配名称以'l'结尾的产品
SELECT prod_name FROM products WHERE prod_name REGEXP 'l$' ORDER BY prod_name;
-- 匹配名称中含有以t开头的单词的产品
SELECT prod_name FROM products WHERE prod_name REGEXP '[[:<:]]t' ORDER BY prod_name;
-- 匹配名称中含有以t结尾的单词的产品
SELECT prod_name FROM products WHERE prod_name REGEXP 't[[:>:]]' ORDER BY prod_name;



-- 字段拼接
-- vendors表包含供应商名称及位置。下面的sql会以vend_name(vend_country)的形式返回数据
SELECT CONCAT(vend_name,'(',vend_country,')') FROM vendors ORDER BY vend_name;
-- 去除空格
-- 在上面的sql中，返回的查询结果中的字段的两端可能会存在空格，此时可以使用trim()函数去掉空格
-- 下面的sql中，TRIM可以去除字段两端的空格，LTRIM和RTRIM分别是去除左右边的空格
SELECT CONCAT(TRIM(vend_name),'(',TRIM(vend_country),')') FROM vendors ORDER BY vend_name;
SELECT CONCAT(LTRIM(vend_name),'(',LTRIM(vend_country),')') FROM vendors ORDER BY vend_name;
SELECT CONCAT(RTRIM(vend_name),'(',RTRIM(vend_country),')') FROM vendors ORDER BY vend_name;

-- 使用别名
-- 在上面的sql中，我们查询出了要求的数据，但是查询结果是一个值，在程序中是不能使用的，需要使用'as'为其起别名
SELECT CONCAT(vend_name,'(',vend_country,')') AS vend_title FROM vendors ORDER BY vend_name;

-- 执行算术计算 mysql支持 '+'、'-'、'*'、'\'四种算术运算
-- orders表中包含所有订单，orderitems表包含每个订单的商品信息
-- 下面的sql查询出orderitems表中某个订单的所有商品价格总和
SELECT prod_id, quantity,item_price,quantity * item_price as expanded_price FROM orderitems WHERE order_num = 20005;

-- SELECT测试计算
-- SELECT可以省略from子句直接计算相关的函数
SELECT NOW(); SELECT 2*3; SELECT TRIM(' abc ');


-- 文本处理函数
-- 文本转大小写可以使用函数UPPER()和LOWER()来实现
SELECT vend_name,UPPER(vend_name) AS vend_name_upper FROM vendors ORDER BY vend_name;
SELECT vend_name,LOWER(vend_name) AS vend_name_lower FROM vendors ORDER BY vend_name;
SELECT SOUNDEX('world');

-- 日期处理函数
-- 一般情况下存储在mysql中的日期格式应该为yyyy-mm-dd，现在假设我们要查询订单日期为2005年9月1日的订单
SELECT cust_id, order_num FROM orders WHERE order_date = '2005-09-01';
-- 上面的sql成功获取了结果，但是有些情况下可能会存在问题，假如说我们存入的订单日期数据是date+time那么上面的查询就会出错
-- 正确的案例应该是使用date()函数实现，同样的我们还可以使用 TIME()函数实现时间查询
SELECT cust_id, order_num FROM orders WHERE DATE(order_date) = '2005-09-01';
-- 同时，mysql还提供了 YEAR()和 MONTH()和 DAY()三个函数分别获取年月日，如我们要查询2005年9月的数据
SELECT cust_id, order_num FROM orders WHERE YEAR(order_date) = 2005 AND MONTH(order_date) = 9;
-- 上面的sql我们也可以使用 BETWEEN AND 来实现，但是这种方法需要知道要查询的月份有几天
SELECT cust_id, order_num FROM orders WHERE DATE(order_date) BETWEEN '2005-09-01' AND '2005-09-30';

-- 数值处理函数
-- 返回数的绝对值
SELECT ABS(-100);

-- 聚集函数
-- 求平均值
SELECT avg(prod_price) AS prod_price_avg FROM products;
-- 统计数目 第一条统计所有的行数，第二条统计有email的行数
SELECT COUNT(*) AS cust_number FROM customers;
SELECT COUNT(cust_email) AS cust_number FROM customers;
-- 求最大值
SELECT MAX(prod_price) AS max_price FROM products;
-- 求最小值
SELECT MIN(prod_price) AS min_price FROM products;
-- 求和
SELECT SUM(prod_price) AS sum_price FROM products;
-- 聚集函数去重
-- 对于聚集函数，可以使用distinct去重，如我们要查询产品价格平均值，但是对于重复的产品价格就只计算一个
-- 在下面的sql中，对于多个重复的价格只会取一个数据用于计算
-- 同样的 DISTINCT也可以用于count，但是用于count函数时不能使用*，即distinct后面只能是具体的列名
-- DISTINCT对于min和max函数使用是没有意义的
SELECT avg(DISTINCT prod_price) AS prod_price_avg FROM products;
-- 上面的各种聚集函数可以组合在一个sql中使用
SELECT count(prod_price) AS count_price,AVG(prod_price) AS price_avg,SUM(prod_price) AS sum_price FROM products;

-- 数据分组
-- 使用 GROUP BY对数据进行分组，分组后可以对每个组进行聚集计算
SELECT * FROM products;
SELECT vend_id ,count(*) AS num_prods FROM products GROUP BY vend_id ;
-- 使用having对分组后的数据进行过滤
SELECT cust_id,count(*)  AS orders FROM orders GROUP BY cust_id HAVING COUNT(*) >= 2;
-- having和where的用法类似，区别在于having过滤的是分组，where过滤的是行
-- where在分组前过滤，having在分组后过滤
-- where可以和having组合使用，即先用where过滤行之后对过滤的数据进行分组，再使用having对分组之后的数据进行过滤
SELECT vend_id,COUNT(*) AS num_prods FROM products WHERE prod_price >=10 GROUP BY vend_id HAVING COUNT(*) >=2;
-- GROUP BY 和 ORDER BY 两者输出的结果顺序不一致，前者是根据指定的排序列及规则输出，后者只对数据进行分组，但是输出的顺序可能不是分组顺序
-- 检索总订单价格大于等于50的订单的订单号和总计订单价格。
SELECT order_num , SUM(quantity * item_price) AS order_total FROM orderitems GROUP BY order_num HAVING SUM(quantity * item_price)>=50;
SELECT order_num , SUM(quantity * item_price) AS order_total 
	FROM orderitems 
	GROUP BY order_num 
	HAVING SUM(quantity * item_price)>=50 ORDER BY order_total;

-- 子查询
-- 查询购买了产品ID为TNT2的产品的所有客户
-- SELECT cust_id FROM orders WHERE order_num IN (SELECT order_num FROM orderitems WHERE prod_id = 'TNT2');
SELECT cust_id,cust_name,cust_contact FROM customers WHERE cust_id IN (
	SELECT cust_id FROM orders WHERE order_num IN (
		SELECT order_num FROM orderitems WHERE prod_id = 'TNT2'
	)
);
-- 作为计算字段使用子查询
SELECT cust_id, cust_name, cust_state,( SELECT count(*) FROM orders WHERE customers.cust_id = orders.cust_id ) AS orders 
FROM
	customers 
ORDER BY
	cust_id;
	
-- 联结
-- 创建联结查询, 这里从两张表中查询了数据，在where中根据两张表的vend_id进行关联
-- 这里的where是一个过滤条件，如果没有where，则mysql会把两个表的所有数据全部关联起来
SELECT
	prod_id,
	prod_name,
	prod_price,
	vend_name 
FROM
	products AS p,
	vendors AS v 
WHERE
	p.vend_id = v.vend_id 
ORDER BY
	p.vend_id;
-- 内部联结
-- 上面的联结方式又称为等值联结，它是基于两个表的相等测试。这种联结方式也被称为内部联结。在MySQL语法中，还可以使用 ··· INNER JOIN ··· ON ···来实现内部联结
-- 下面的sql中联结了两张表，这里两张表的联结关系是from子句的组成部分，在使用这种联结方式时，联结条件是使用on给定的，但是这里on的条件和前面的where条件一致
SELECT
	prod_id,
	prod_name,
	prod_price,
	vend_name 
FROM
	products
	INNER JOIN vendors ON vendors.vend_id =products.vend_id; 
-- 联结多个表
-- SQL对联结的表的数目没有做限制，在一条sql里面可以联结多个表，创建联结的基本规则也相同
SELECT
	o.order_num,
	o.item_price,
	p.prod_id,
	p.prod_name,
	v.vend_id,
	v.vend_name 
FROM
	orderitems o,
	products p,
	vendors v 
WHERE
	o.prod_id = p.prod_id 
	AND p.vend_id = v.vend_id;
-- 使用 INNER JOIN 联结多张表
SELECT
	orderitems.order_num,
	orderitems.item_price,
	products.prod_id,
	products.prod_name,
	vendors.vend_id,
	vendors.vend_name 
FROM
	orderitems
	INNER JOIN products
	INNER JOIN vendors ON orderitems.prod_id = products.prod_id 
	AND products.vend_id = vendors.vend_id;

--  自联结
-- 查询 products表中产品名称为DTNTR的产品的供应商的其他产品
-- 使用子查询
SELECT
	prod_id,
	prod_name 
FROM
	products 
WHERE
	vend_id = ( SELECT vend_id FROM products WHERE prod_id = 'DTNTR' );
-- 使用联结查询
SELECT
	p1.prod_id,
	p1.prod_name 
FROM
	products p1,
	products p2 
WHERE
	p1.vend_id = p2.vend_id 
	AND p2.prod_id = 'DTNTR';
	
-- 外部联结
-- 查询所有客户的订单，包括那些没有订单的客户
-- LEFT JOIN用于显示左边表中所有数据，右边的为空就显示null
-- RIGHT JOIN 用于显示右边表中的所有数据，右边表里面没有就不显示
SELECT c.cust_id,	c.cust_name,	o.order_num FROM	customers AS c LEFT OUTER JOIN orders AS o ON c.cust_id = o.cust_id;
SELECT c.cust_id,	c.cust_name,	o.order_num FROM	customers AS c RIGHT OUTER JOIN orders AS o ON c.cust_id = o.cust_id;
-- 带聚合函数的联结
-- 使用cust_id对返回数据进行分组，所以得到的是每一个cust_id的订单总数，如果没有分组，查询结果就是返回结果的总数
SELECT
	customers.cust_id,
	customers.cust_name,
	COUNT( orders.order_num ) AS num_ord 
FROM
	customers
	INNER JOIN orders ON customers.cust_id = orders.cust_id 
GROUP BY
	customers.cust_id;
SELECT
	customers.cust_id,
	customers.cust_name,
	COUNT( orders.order_num ) AS num_ord 
FROM
	customers
	LEFT JOIN orders ON customers.cust_id = orders.cust_id 
GROUP BY
	customers.cust_id;
	
-- 组合查询
-- 组合查询是将多个不同的查询sql的结果组合到一起
-- 查询产品价格小于等于5或者供应商为1001和1002的产品 分别使用where和组合查询实现
-- where查询
SELECT
	products.prod_id,
	products.prod_name 
FROM
	products 
WHERE
	prod_price <= 5 
	OR products.vend_id IN ( '1001', '1002' );
-- 组合查询
SELECT
	products.prod_id,
	products.prod_name 
FROM
	products 
WHERE
	prod_price <= 5 UNION
SELECT
	products.prod_id,
	products.prod_name 
FROM
	products 
WHERE
	products.vend_id IN ( '1001', '1002' );
-- 在上面的union中，两个select返回的数据中有一条是重复数据，但是union会自动过滤掉重复的数据，如果要显示所有的数据，可以使用union all
-- 这也是union 和where的一点区别，使用where总是会过滤掉重复的数据
SELECT
	products.prod_id,
	products.prod_name 
FROM
	products 
WHERE
	prod_price <= 5 UNION ALL
SELECT
	products.prod_id,
	products.prod_name 
FROM
	products 
WHERE
	products.vend_id IN ( '1001', '1002' );

-- 对组合查询结果进行排序
-- 可以使用order by对组合查询结果进行排序，但是排序子句只能出现在最后一个select中，
-- 虽然看起来是只对最后一个查询做排序，但是实际上mysql会把order by应用到整个查询出来的结果集上
SELECT
	products.prod_id,
	products.prod_name 
FROM
	products 
WHERE
	prod_price <= 5 UNION
SELECT
	products.prod_id,
	products.prod_name 
FROM
	products 
WHERE
	products.vend_id IN ( '1001', '1002' ) 
ORDER BY
	prod_id,
	prod_name;

-- 全文搜索
-- 一般在建表的时候启用全文搜索支持，在创建表的sql中添加 FULLTEXT子句，它给出一个被索引的列的逗号分隔的列表。FULLTEXT(c1,c2)
-- 可以在创建表的时候指定 FULLTEXT，也可以在后面导入数据的时候指定。一般如果要在导入数据的时候指定，则最好是先导入数据再指定索引。
-- 使用全文搜索 Match()指示MySQL对指定的列进行搜索,Against()指示要搜索的值。这里的搜索是不区分大小写的
SELECT note_text FROM productnotes WHERE Match(note_text) Against('rabbit');
-- 上面的全文搜索同样可以使用like来实现，但是使用like返回的数据顺序是没有意义的，而使用全文搜索会为数据按照一定的规则计算出一个等级，根据等级对数据做展示。
SELECT note_text , Match(note_text) Against('rabbit') AS rank FROM productnotes ;
-- mysql根据行中词的数目，唯一词的数目，整个索引中词的总数以及包含该词的行的数目计算出来的。

-- 插入数据
-- 插入完整地行，不安全
insert into customers value (null,'name','address','city','stat','1234','us',null,null);
-- 插入完整地行，安全
INSERT INTO `mysqlcc`.`customers` (`cust_id`, `cust_name`, `cust_address`, `cust_city`, `cust_state`, `cust_zip`, `cust_country`, `cust_contact`) VALUES (NULL, '1', '1', '1', '1', '1', '1', '1');
-- 可以只设置部分列
INSERT INTO `mysqlcc`.`customers` (`cust_id`, `cust_name`) VALUES (NULL,'name');
-- 插入搜索的数据
-- 通过select语句查询数据之后将查询到的数据插入到数据库中，
-- 在这种操作下会将要插入的字段和查询到的数据值按照顺序匹配插入到数据库，如果查询到多条数据则会将全部查询到的数据都写入到数据库
INSERT INTO customers(customers.cust_name,customers.cust_address,customers.cust_city,customers.cust_country,customers.cust_state,customers.cust_contact) 
SELECT customers_new.cust_name,customers_new.cust_address,customers_new.cust_city,customers_new.cust_country,customers_new.cust_state,customers_new.cust_contact from customers_new;


-- 更新和删除数据
-- 更新数据
-- update 表名 set 表名.列名='xxx' where 条件
update customers set cust_address = 'beijing' where cust_id = '10016';
-- 删除数据
-- delete FROM 表名 where 条件
delete FROM customers WHERE customers.cust_id > '10016';

-- 创建和操作表
-- 创建表
-- 在创建表之前需要确保数据库中不存在同名的表，因此可以先执行删除语句，当存在同名的数据表时删除同名表
-- 或者在建表语句之后添加 IF NOT EXISTS ，这中情况下只会当表不存在时才执行建表语句
DROP TABLE IF EXISTS customers_new;
CREATE TABLE /** IF NOT EXISTS **/  customers_new (
	cust_id int NOT NULL AUTO_INCREMENT,
	cust_name VARCHAR(50) NULL,
	cust_age int NOT NULL DEFAULT 0, 
	cust_address VARCHAR(100) NULL,
	PRIMARY KEY (cust_id)
)ENGINE=InnoDB;
-- 主键 在建表时可以通过 PRIMARY KEY (cust_id)制定主键，在括号里面可以指定多个列值
-- 自增 由于主键需要保持唯一，所以对于cust_id我们要保证它的值每次都不同，所以在插入数据的时候或者查询当前最大值之后加一或者使其自增
-- 默认值 通过DEFAULT 指定某一字段的默认值
-- 存储引擎 通过 ENGINE=xxx 可以指定当前表的默认引擎，对于mysql 8.0版本，如果没有设置存储引擎则默认设置为InnoDB
	-- 可以在启动MySQL服务时通过 --default-storage-engine 指定默认存储引擎，或者在my.cnf 文件中通过 default-storage-engine 指定
	
-- 更新表
-- 新增字段
ALTER TABLE customers_new ADD cust_temp VARCHAR(20);
-- 更新字段
ALTER table customers_new MODIFY cust_temp VARCHAR(10);
-- 删除字段

-- 删除表
-- DROP TABLE IF EXISTS customers_new;

-- 重命名表
RENAME TABLE customers_new TO customers_new_rename;



-- 视图
-- 视图是一张虚拟的表，不存储具体数据，只是通过视图关联一条sql语句。通过视图可以将数据的访问权限控制到数据库中一张表的某一列数据。可以对数据库用户隐藏具体的表结构。
-- 删除视图
DROP VIEW IF EXISTS PORDUCTCUSOTMER;

-- 使用视图简化复杂的联结或控制权限
-- 下面案例中创建视图的查询sql中添加了prod_id，这种情况下视图中返回了生产所有产品的数据，通过该视图可以查询全部生产所有产品的客户数据而不仅限于prod_id为 `TNT2`的客户数据
select cust_name,cust_contact from customers, orders, orderitems WHERE customers.cust_id = orders.cust_id and orderitems.order_num = orders.order_num and prod_id = 'TNT2';
-- 创建视图。可以添加 or replace 语句，如果视图不存在就直接创建，否则就使用新的语句替换原有视图
creaTE /** OR REPLACE **/ VIEW PORDUCTCUSOTMER AS select cust_name,cust_contact,prod_id from customers, orders, orderitems WHERE customers.cust_id = orders.cust_id and orderitems.order_num = orders.order_num;		
-- 从视图中查询数据
SELECT cust_name,cust_contact FROM PORDUCTCUSOTMER WHERE prod_id = 'TNT2';
		
-- 使用视图格式化数据
-- 使用视图返回组装好的用户信息。这里的concat函数可以根据实际需求返回任意函数
select * from customers ;
CREATE OR REPLACE VIEW cust_info AS select customers.cust_id  CONCAT('id = ',customers.cust_id,' :: name = ',customers.cust_name, ' :: address = ',customers.cust_address) FROM customers;
SELECT * FROM cust_info WHERE cust_id = '10001';

-- 使用视图过滤数据
-- 使用视图过滤掉cust_zip字段值为空的数据
select * from customers;
CREATE OR REPLACE VIEW cust_filter AS SELECT * FROM customers WHERE customers.cust_zip IS NOT NULL;
SELECT * FROM cust_filter ;



-- 存储过程
-- 存储过程就是为以后的使用而保存的一条或多条MySql语句的集合。可将其视为批文件，虽然他们的作用不仅限于批处理。

-- 创建存储过程
-- 创建一个名为 productpricing 的存储过程，实现从products中查询prod_price的平均值
-- 在mysql命令行中默认使用分号作为语句结束符，但是在存储过程中可能存在分号是存储过程的一部分的情况，这时候需要使用 DEMITILER 临时更改语句结束符
-- DELIMITER //
CREATE PROCEDURE productpricing()
BEGIN
	SELECT AVG(prod_price) AS priceaverage FROM products;
END;
-- DELIMITER ;

-- 调用存储过程
CALL productpricing();

-- 删除存储过程
-- 删除存储过程语句中存储过程名后面没有括号，如果被删除的存储过程不存在语句执行会报错，可以在语句中添加 if exists 使只当其存在时才删除
DROP PROCEDURE IF EXISTS productpricing;

-- 使用参数
-- 存储过程中添加参数方式为在存储过程名后面的括号中指定，格式为 传输类型 参数名 参数类型
-- MySQL支持IN、OUT、INOUT三种类型参数 IN：传递参数给存储过程 OUT：从存储过程中输出参数 INOUT：对存储过程输入和输出
-- OUT
-- DELIMITER //
CREATE PROCEDURE productpricing(
	OUT pl DECIMAL(8,2),
	OUT ph DECIMAL(8,2),
	OUT pa DECIMAL(8,1)
)
BEGIN
	SELECT Min(prod_price) INTO pl FROM products;
	SELECT MAX(prod_price) INTO ph FROM products;
	SELECT AVG(prod_price) INTO pa FROM products;
END;
-- DELIMITER ;

-- 输出类型参数调用
-- 所有MySQL变量必须以@开始。这里在调用存储过程时传入了3个变量作为参数，存储过程调用结果会保存在这三个变量中，调用存储过程之后通过select语句查询三个变量值即为存储过程返回值
CALL productpricing(@procelow, @privehigh, @priceverage);
SELECT @procelow, @privehigh, @priceverage;

-- IN 
-- 参数中指定了输入和输出参数，输入参数传入值，输出参数传入一个MySQL变量用于存储返回结果
CREATE PROCEDURE ordertotal(
	IN onumber INT,
	OUT ototal DECIMAL(8,2)
)
BEGIN
	SELECT SUM(item_price * quantity) FROM orderitems WHERE order_num = onumber INTO ototal;
END;
-- 输入类型参数调用
CALL ordertotal(20005, @total);
select @total AS total_order;

-- 存储过程应用(建立智能存储过程)
-- Name:orderTotal
-- Parameters: 	onumber = order number
-- 						 	taxable = 0 if not taxable, 1 of taxable
-- 							ototal = order total varable
DROP PROCEDURE IF EXISTS ordertotal;
CREATE PROCEDURE ordertotal(
	IN onumber INT,
	IN taxable BOOLEAN,
	OUT ototal DECIMAL(8,2)
) COMMENT 'Obtain order total,optionally adding tax'
BEGIN
	-- declare variable for total
	DECLARE total DECIMAL(8,2);
	-- declare tax percentage
	DECLARE taxrate INT DEFAULT 6;
	
	-- get the order total
	SELECT SUM(item_price * quantity) FROM orderitems WHERE order_num = onumber INTO total;
	
	-- is the taxable
	IF taxable /** != 0 **/ THEN
		SELECT total+(total/100*taxrate) INTO total;
	END IF;
	
	-- finally, save result to variable
	SELECT total INTO ototal;
END;
-- 调用
CALL ordertotal(20005, 0, @total);
SELECT @total;
--
CALL ordertotal(20005, 1, @total);
SELECT @total;

-- 查询存储过程的创建语句
SHOW CREATE PROCEDURE ordertotal;
-- 查询存储过程状态
SHOW PROCEDURE STATUS LIKE 'ordertotal';


-- 触发器
-- 触发器可以实现当某个表发生变更时自动执行指定的操作。可以在 DELETE、UPDATE、INSERT 语句执行之前或执行之后自动执行一条sql语句。
-- mysql要求触发器名在表中唯一，但是不要求在数据库中唯一，即在一个数据库中不同的两张变可以存在同名的触发器，但是在实际使用时建议确保触发器名在数据库中唯一
-- 一个表最多支持6个触发器，分别为增删改的before和after，单一触发器不能和多个事件或多个表关联，因此如果需要对insert和update执行触发器操作则需要创建多个触发器
-- 如果为某种操作创建了before触发器并且before触发器执行失败了，那么后续的sql语句将不会被执行

-- 创建触发器
-- 创建触发器时如果执行查询操作需要将查询结果保存在一个MySQL变量中，否则会返回 1415 - Not allowed to return a result set from a trigger
-- DELIMITER \\
CREATE TRIGGER insertproduct 	-- 创建一个名为insertproduct的触发器
AFTER INSERT ON products  		-- 触发条件为after insert，关联 product 表
FOR EACH ROW									-- 对每个插入行都执行
/* 触发器被触发时执行的操作 */
BEGIN
 SELECT 'product added' INTO @result;
END;
-- DELIMITER ;

INSERT INTO products VALUE('test','1003','zhangsan','123','insert test');
SELECT @result;
DELETE FROM products WHERE prod_id = 'test';

-- 删除触发器
DROP TRIGGER /* IF EXISTS */ insertproduct;

-- 使用触发器
-- insert触发器
-- 在insert触发器中，可以引用一个名为 `NEW` 的虚拟表访问被插入的行
-- 在before insert中可以更新 NEW 中的值，即可以在before insert中修改要写入的值。
-- 对于自增的列，在before时new中的值为0，在after时值为生成的新值
DROP TRIGGER IF EXISTS neworder;
CREATE TRIGGER neworder 
AFTER INSERT ON orders 
FOR EACH ROW 
BEGIN 
	SELECT NEW.order_num INTO @order_num;
END;
DELETE FROM orders WHERE order_num = '1';
INSERT INTO orders (order_date,cust_id) VALUE (NOW(),'10001');
SELECT @order_num;

-- delete触发器
-- 在delete触发器中可以引用一个名为 `OLD` 的虚拟表访问被删除的行
-- OLD 中的值是只读的不能被更新
-- 使用 before DELETE 触发器可以保证存档和删除动作的原子性
DROP TRIGGER IF EXISTS deleteorder;
CREATE TRIGGER deleteorder
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
	INSERT INTO archive_orders(order_num, order_date, cust_id) VALUES(OLD.order_num, OLD.order_date, OLD.cust_id);
END;

-- update触发器
-- 在update触发器中，可以引用一个`OLD`虚拟表用来访问之前的数据，引用`NEW`虚拟表访问新写入的数据
-- OLD虚拟表中的数据是只读的，NEW虚拟表中的数据是可以修改的
DROP TRIGGER IF EXISTS updatevendor;
CREATE TRIGGER updatevendor 
BEFORE UPDATE ON vendors 
FOR EACH ROW
BEGIN
	SET NEW.vend_state = UPPER(NEW.vend_state);
END;

-- 使用before update 触发器
UPDATE vendors SET vendors.vend_state = 'bj' WHERE vend_id = '1005';



-- 管理事务
-- MySQL中两种较为常用的存储引擎中，MyISAM不支持明确的事务处理，InnoDB支持事务。因此在建表的时候如果需要支持事务，则存储引擎需要选择InnoDB
-- 事务处理（transaction processing）可以用来维护数据库的完整性，它保证成批的MySQL操作要么完全执行，要么完全不执行
	-- 事务（ transaction ）指一组SQL语句；
	-- 回退（ rollback ）指撤销指定SQL语句的过程；
	-- 提交（ commit ）指将未存储的SQL语句结果写入数据库表；
	-- 保留点（ savepoint ）指事务处理中设置的临时占位符（place-holder），你可以对它发布回退（与回退整个事务处理不同）。

-- MySQL中默认是自动提交所有更改的，即语句执行之后立即生效。如果需要设置MySQL不自动提交更改，需要使用 SET autocommit=0 来关闭默认提交行为
-- SET autocommit=0 是针对连接而不是针对服务器，即该设置只会对当前连接生效
SET autocommit=0;
DELETE FROM vendors WHERE vend_id='1007';
UPDATE vendors SET vend_name='name' WHERE vend_id='1008';
commit;
select * from vendors WHERE vend_id = '1008';
SET autocommit=1;

-- 使用 START TRANSACTION 开启事务
START TRANSACTION;
INSERT INTO `mysqlcc`.`vendors` (`vend_name`, `vend_address`, `vend_city`, `vend_state`, `vend_zip`, `vend_country`) VALUES ('test01', 't', 't', 't', 't', 't');
COMMIT;
-- 一个 START TRANSACTION 对应一次commit或rollback，前面的事务开启后提交了，在往后需要开启事务需要重新执行 START TRANSACTION 
START TRANSACTION;
UPDATE vendors SET `vend_name` = 'name01' WHERE `vend_id` = '1010';
ROLLBACK;

-- 使用保留点
-- 默认情况下，事务撤销会将开启事务到执行撤销操作之间的所有sql全部撤销，但是有些时候可能需要部分撤销或提交，可以通过使用保留点实现部分撤销
-- 保留点在事务执行完成之后会自动释放。同时也可以使用 RELEASE SAVEPOINT 手动释放
START TRANSACTION;
INSERT INTO `mysqlcc`.`vendors` (`vend_name`, `vend_address`, `vend_city`, `vend_state`, `vend_zip`, `vend_country`) VALUES ('test01', 't', 't', 't', 't', 't');
SAVEPOINT updatename;
UPDATE vendors SET `vend_name` = 'name01' WHERE `vend_id` = '1010';
ROLLBACK TO updatename;
commit;		-- 前面回滚到保留点之后，在保留点之前的sql需要执行提交操作才会生效


-- 全球化和本地化
-- 字符集 为字母和符号的集合；
-- 编码 为某个字符集成员的内部表示；
-- 校对 为规定字符如何比较的指令。

-- 查看MySQL支持的完整的字符集列表
SHOW CHARACTER SET;

-- 查看所支持校对的完整列表
SHOW COLLATION ;

-- 查看数据库使用的字符集和校对
SHOW VARIABLES LIKE 'character%';
SHOW VARIABLES LIKE 'COLLATION%';

-- 通过create table 可以为表设置字符集和校对顺序
CREATE TABLE testtable(
	column01 INT,
	column02 varchar(2)
)DEFAULT CHARACTER SET utf8mb4 COLLATION utf8mb4_general_ci;

-- 设置指定列的字符集
CREATE TABLE testtable(
	column01 INT,
	column02 varchar(2) CHARACTER SET utf8mb4 COLLATION utf8mb4_general_ci
)DEFAULT CHARACTER SET utf8mb4 COLLATION utf8mb4_general_ci;

-- 校对在对用 ORDER BY子句检索出来的数据排序时起重要的作用。如果你需要用与创建表时不同的校对顺序排序特定的 SELECT 语句，可以在 SELECT 语句自身中进行
select * from customers ORDER BY cust_name,cust_city COLLATE utf8mb4_general_ci;



-- 安全管理
-- MySQL服务器的安全基础是：用户应该对他们需要的数据具有适当的访问权，既不能多也不能少
use mysql;
-- 查看当前全部用户
select user from user;
-- 创建用户
-- 创建一个名为test01的用户，设置密码为test01
CREATE USER test01 IDENTIFIED BY 'test01';
-- 修改用户名
RENAME USER test01 TO test02;
RENAME USER test02 TO test01;
-- 删除用户
DROP USER test01;

-- 查询用户权限
SHOW GRANTS FOR test01;
SHOW GRANTS FOR root@'localhost';
-- 用户授权
-- 授权 test01用户在musqlcc上的查询权限。如果test01执行更新语句则会返回权限不足。
	-- mysql> update vendors set vend_name = 'ttttttttt' where vend_id = '1010';
	-- 1142 - UPDATE command denied to user 'test01'@'localhost' for table 'vendors'
GRANT SELECT ON mysqlcc.* TO test01;
SHOW GRANTS FOR test01;
-- 撤销授权
-- GRANT 的反操作为 REVOKE ，用它来撤销特定的权限。被撤销的权限要求必须存在，否则会报错
	-- 执行撤销权限之后 test01 用户无法访问 mysqlcc 数据库
REVOKE SELECT ON mysqlcc.* FROM test01;
-- GRANT 和 REVOKE 可在几个层次上控制访问权限：
--   整个服务器，使用 GRANT ALL 和 REVOKE ALL；
--   整个数据库，使用 ON database.*；
--   特定的表，使用 ON database.table；
--   特定的列；
--   特定的存储过程。

/*
--  可以授予或撤销的每个权限  --

ALL                         除GRANT OPTION外的所有权限
ALTER                       使用ALTER TABLE
ALTER ROUTINE  							使用ALTER PROCEDURE和DROP PROCEDURE
CREATE                      使用CREATE TABLE
CREATE ROUTINE  		    		使用CREATE PROCEDURE
CREATE TEMPORARY TABLES			使用CREATE TEMPORARY TABLE
CREATE USER                 使用CREATE USER、DROP USER、RENAME USER和REVOKE ALL PRIVILEGES
CREATE VIEW                 使用CREATE VIEW
DELETE                      使用DELETE
DROP                        使用DROP TABLE
EXECUTE                     使用CALL和存储过程
FILE                        使用SELECT INTO OUTFILE和LOAD DATA INFILE
GRANT OPTION                使用GRANT和REVOKE
INDEX                       使用CREATE INDEX和DROP INDEX
INSERT                      使用INSERT
LOCK TABLES                 使用LOCK TABLES
PROCESS                     使用SHOW FULL PROCESSLIST
RELOAD                      使用FLUSH
REPLICATION CLIENT          服务器位置的访问
REPLICATION SLAVE           由复制从属使用
SELECT                      使用SELECT
SHOW DATABASES              使用SHOW DATABASES
SHOW VIEW                   使用SHOW CREATE VIEW
SHUTDOWN                    使用mysqladmin shutdown（用来关闭MySQL）
SUPER                       使用CHANGE MASTER、KILL、LOGS、PURGE、MASTER和SET GLOBAL。还允许mysqladmin调试登录
UPDATE                      使用UPDATE
USAGE                       无访问权限

*/

-- 修改用户密码
-- 指定用户
SET PASSWORD FOR test01 = PASSWORD('test01');
-- 不指定用户，默认修改当前用户密码
-- SET PASSWORD = PASSWORD('test01');

use mysqlcc;
show tables;


-- 数据库维护
--  ANALYZE TABLE 用来检查表键是否正确
ANALYZE TABLE orders;
--  CHECK TABLE 用来针对许多问题对表进行检查
CHECK TABLE orders;
-- 如果 MyISAM 表访问产生不正确和不一致的结果，可能需要用REPAIR TABLE 来修复相应的表。这条语句不应该经常使用，如果需要经常使用，可能会有更大的问题要解决。
-- 如果从一个表中删除大量数据，应该使用 OPTIMIZE TABLE 来收回所用的空间，从而优化表的性能。











