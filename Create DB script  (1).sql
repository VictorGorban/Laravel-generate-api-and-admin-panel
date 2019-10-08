create table city_addresses
(
id         int auto_increment
primary key,
identifier varchar(100) not null
);
create table city_names
(
id         int auto_increment
primary key,
identifier varchar(255) not null
);
create table counters
(
products        int default 0 not null,
customers       int default 0 not null,
customer_orders int default 0 not null,
product_reviews int default 0 not null
);
create table country
(
id         int auto_increment
primary key,
identifier varchar(100) not null
);
create table city
(
id         int auto_increment
primary key,
identifier varchar(100) not null,
country_id int          null,
constraint city_country_fk
foreign key (country_id) references country (id)
on update cascade on delete set null
);
create index city_index
on cities (identifier);
create table customer_contact
(
id            int auto_increment
primary key,
customer_name varchar(100) not null,
city_id       int          null comment 'Ссылка на таблицу городов',
city_address  varchar(100) not null comment 'Адрес в городе. В формате "ул. Речная д.64/2 кв. 56"',
phone         varchar(20)  not null,
email         varchar(50)  null,
constraint customer_city_fk
foreign key (city_id) references cities (id)
on update cascade on delete set null
);
create index customer_contact_fio_index
on contact (customer_name);
create table customer_emails
(
identifier varchar(50) not null,
id         int auto_increment
primary key
);
create table customer_group
(
id         int auto_increment
primary key,
identifier varchar(50) not null
);
create table customer_log
(
id             int auto_increment
primary key,
customer_login varchar(100)                        not null,
action         text                                not null,
time_change    timestamp default CURRENT_TIMESTAMP not null
);
create table customer_names
(
id         int auto_increment
primary key,
identifier varchar(100) not null
);
create table customer_phones
(
identifier varchar(20) not null,
id         int auto_increment
primary key
);
create table customer_status
(
id         int auto_increment
primary key,
identifier varchar(50) not null
);
create table customer
(
id                  int auto_increment
primary key,
login               varchar(100) default 'UNSET' not null,
password            varchar(256)                 null,
customer_group_id   int          default 1       not null,
customer_contact_id int                          not null,
customer_status_id  int          default 1       not null,
discount            int          default 0       not null comment 'кол-во скидочных баллов',
constraint contact_fk
foreign key (customer_contact_id) references contact (id),
constraint group_fk
foreign key (customer_group_id) references customer_group (id),
constraint status_fk
foreign key (customer_status_id) references customer_status (id)
);
create definer = mysql@`%` trigger decrease_count_customers
after DELETE
on customer
for each row
BEGIN
update counters set customers = customers - 1;
END;
create definer = mysql@`%` trigger encrypt_customer_password_on_insert
before INSERT
on customer
for each row
BEGIN
SET new.password = md5(new.password);
END;
create definer = mysql@`%` trigger encrypt_customer_password_on_update
before UPDATE
on customer
for each row
BEGIN
insert into temp_log(message) value (concat(new.password, ' ', old.password));
if (new.password != old.password) then
SET new.password = md5(new.password);
insert into temp_log(message) value ('!=');
else
insert into temp_log(message) value ('=');
end if;
END;
create definer = mysql@`%` trigger increase_count_customers
after INSERT
on customer
for each row
BEGIN
update counters set customers = customers + 1;
END;
create definer = mysql@`%` trigger log_customer_on_delete
before DELETE
on customer
for each row
BEGIN
set @action_text = 'deleted';
insert into customer_log(customer_login, action, customer_log.time_change) values (old.login, @action_text, now());
END;
create definer = mysql@`%` trigger log_customer_on_insert
after INSERT
on customer
for each row
BEGIN
set @action_text = 'added';
insert into customer_log(customer_login, action, customer_log.time_change) values (new.login, @action_text, now());
END;
create definer = mysql@`%` trigger log_customer_on_update
after UPDATE
on customer
for each row
BEGIN
set @action_text = '';
if (old.login != new.login) then
set @action_text = concat(@action_text, 'login from ', old.login, ' to ', new.login);
end if;
if (old.password != new.password) then
set @action_text = concat(@action_text, 'password from ', old.password, ' to ', new.password);
end if;
if (old.customer_group_id != new.customer_group_id) then
set @action_text =
concat(@action_text, 'customer_group_id from ', old.customer_group_id, ' to ', new.customer_group_id);
end if;
if (old.customer_contact_id != new.customer_contact_id) then
set @action_text = concat(@action_text, 'customer_contact_id from ', old.customer_contact_id, ' to ',
new.customer_contact_id);
end if;
if (old.customer_status_id != new.customer_status_id) then
set @action_text = concat(@action_text, 'customer_status_id from ', old.customer_status_id, ' to ',
new.customer_status_id);
end if;
if (old.discount != new.discount) then
set @action_text = concat(@action_text, 'discount from ', old.discount, ' to ', new.discount);
end if;
insert into customer_log(customer_login, action, customer_log.time_change) values (new.login, @action_text, now());
END;
create table delivery_method
(
id         int auto_increment
primary key,
identifier varchar(255) not null
);
create table logins
(
id         int auto_increment
primary key,
identifier varchar(50) not null
);
create table `option`
(
color_id int not null,
shape_id int not null,
primary key (color_id, shape_id),
constraint option_color_fk
foreign key (color_id) references pokemon_colors (id)
on update cascade,
constraint option_shape_fk
foreign key (shape_id) references pokemon_shapes (id)
on update cascade
);
create table order_comments
(
id         int auto_increment
primary key,
identifier text not null
);
create table order_status
(
id         int auto_increment
primary key,
identifier varchar(50) not null
);
create table passwords
(
id         int auto_increment
primary key,
identifier varchar(200) not null
);
create table payment_method
(
id         int auto_increment
primary key,
identifier varchar(100) not null
);
create table customer_order
(
id                  int auto_increment
primary key,
customer_id         int           null,
customer_login      varchar(100)  null,
customer_contact_id int           not null comment 'Id в таблице контактов. Если пользователь зарегистирован, то сюда ставятся его контакты',
delivery_method_id  int default 1 null comment 'Id способа доставки. Должна быть таблица где-то',
status              int default 1 not null comment 'Статус заказа. Ожидает выполнения, в обработке, выполнен.',
comment             text          null comment 'Заполняется пользователем при заполнении заказа',
payment_method_id   int           null,
constraint customer_order__to_order_status
foreign key (status) references order_status (id),
constraint customer_order_customer_contact_fk
foreign key (customer_contact_id) references contact (id)
on update cascade,
constraint customer_order_delivery_method_fk
foreign key (delivery_method_id) references delivery_method (id)
on update cascade on delete set null,
constraint customer_order_ibfk_1
foreign key (payment_method_id) references payment_method (id)
on update cascade on delete set null,
constraint customer_order_to_customer
foreign key (customer_id) references customer (id)
on update cascade on delete cascade
);
create index payment_method_id
on `order` (payment_method_id);
create definer = root@`%` trigger customer_order_fill_customer_contact_on_insert
before INSERT
on `order`
for each row
BEGIN
if new.customer_id is not null then
set @contact_id = (select customer.customer_contact_id from customer where id = new.customer_id);
set new.customer_contact_id = @contact_id;
end if;
END;
create definer = root@`%` trigger customer_order_fill_customer_name_on_insert
before INSERT
on `order`
for each row
BEGIN
if new.customer_id is not null then
set @login = (select login from customer where id = new.customer_id);
set new.customer_login = @login;
end if;
END;
create definer = mysql@`%` trigger decrease_order_count
after DELETE
on `order`
for each row
BEGIN
update counters set customer_orders = customer_orders - 1;
END;
create definer = mysql@`%` trigger increase_order_count
after INSERT
on `order`
for each row
BEGIN
update counters set customer_orders = customer_orders + 1;
END;
create table product_category
(
id                 int auto_increment
primary key,
name               varchar(50)   not null,
description        text          null,
images             text          null comment 'Изображения в ввиде ссылок через запятую или другой разделитель
',
products_amount    int default 0 null,
parent_category_id int           null,
level              int default 1 null,
constraint product_category_ibfk_1
foreign key (parent_category_id) references product_category (id)
on update cascade on delete set null
);
create index parent_category_id
on product_category (parent_category_id);
create index product_category_name_index
on product_category (name);
create definer = mysql@`%` trigger update_category_level_on_insert
before INSERT
on product_category
for each row
BEGIN
set @parent = new.parent_category_id;
if (@parent != null)
then
set @parent_level = (select level from product_category where id = @parent);
set new.level = @parent_level + 1;
end if;
END;
create definer = mysql@`%` trigger update_category_level_on_update
before UPDATE
on product_category
for each row
BEGIN
set @parent = new.parent_category_id;
if (@parent != null)
then
set @parent_level = (select level from product_category where id = @parent);
set new.level = @parent_level + 1;
end if;
END;
create definer = mysql@`%` trigger update_category_name_table_on_delete
after DELETE
on product_category
for each row
BEGIN
delete from product_category_name where id = old.id;
END;
create definer = mysql@`%` trigger update_category_name_table_on_insert
after INSERT
on product_category
for each row
BEGIN
insert into product_category_name(id, name) values (new.id, new.name);
END;
create definer = mysql@`%` trigger update_category_name_table_on_update
after UPDATE
on product_category
for each row
BEGIN
replace product_category_name(id, name) VALUES (new.id, new.name);
END;
create table product_category_name
(
id   int auto_increment
primary key,
name varchar(100) null
);
create definer = mysql@`%` trigger product_category_name_restrict_update_name
before UPDATE
on product_category_name
for each row
BEGIN
if (new.name != old.name) then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update locked record';
end if;
END;
create table product_descriptions
(
id         int auto_increment
primary key,
identifier text not null
);
create table product_images
(
id         int auto_increment
primary key,
identifier text not null
);
create table product_names
(
id         int auto_increment
primary key,
identifier text not null
);
create table product_producer
(
id              int auto_increment
primary key,
name            varchar(50)   not null,
description     text          null,
logo            varchar(1024) null,
products_amount int default 0 null
);
create table product
(
id             int auto_increment
primary key,
category_id    int        default 1                 null,
producer_id    int                                  null,
name           varchar(100)                         not null,
images         text                                 null comment 'Ссылки на изображения через запятую. Или сериализовать массив и совать его сюда, опять же в виде строки.',
price          decimal(15, 6)                       not null,
flag_avaliable tinyint(1) default 1                 not null,
amount         int        default 1                 not null,
description    text                                 null,
time_add       timestamp  default CURRENT_TIMESTAMP not null,
constraint product_category_fk
foreign key (category_id) references product_category (id)
on update cascade on delete set null,
constraint product_product_producer_id_fk
foreign key (producer_id) references product_producer (id)
on update cascade on delete set null
);
create index index_name_and_category
on product (name, category_id);
create index name
on product (name);
create index product_name_name_index
on product (name);
create index product_producer_fk
on product (producer_id);
create definer = mysql@`%` trigger decrease_category_products_count
after DELETE
on product
for each row
BEGIN
update product_category set products_amount = products_amount - 1 where id = old.category_id;
END;
create definer = root@`%` trigger decrease_producer_products_count_on_delete
after DELETE
on product
for each row
BEGIN
update product_producer set products_amount = products_amount - 1 where id = old.producer_id;
END;
create definer = mysql@`%` trigger decrease_products_count
before DELETE
on product
for each row
BEGIN
update counters set products = products - 1;
END;
create definer = mysql@`%` trigger increase_category_products_count
after INSERT
on product
for each row
BEGIN
update product_category set products_amount = products_amount + 1 where id = NEW.category_id;
END;
create definer = mysql@`%` trigger increase_producer_products_count
after INSERT
on product
for each row
BEGIN
update product_producer set products_amount = products_amount + 1 where id = NEW.producer_id;
END;
create definer = mysql@`%` trigger increase_products_count
before INSERT
on product
for each row
BEGIN
update counters set products = products + 1;
END;
create definer = mysql@`%` trigger update_category_if_set_null
before UPDATE
on product
for each row
BEGIN
if new.category_id is null then
set new.category_id = 1;
update product_category set products_amount = products_amount + (new.amount) where id = new.category_id;
update product_category set products_amount = products_amount - (new.amount) where id = old.category_id;
end if;
END;
create definer = mysql@`%` trigger update_category_product_count_on_changing_amount
after UPDATE
on product
for each row
BEGIN
update product_category set products_amount = products_amount + (new.amount) where id = new.category_id;
update product_category set products_amount = products_amount - (new.amount) where id = old.category_id;
END;
create definer = mysql@`%` trigger update_product_availability_on_changing_amount
before UPDATE
on product
for each row
BEGIN
if (new.amount != old.amount) then
if NEW.amount > 0 then
set new.flag_avaliable = true;
else
set new.flag_avaliable = false;
end if;
end if;
END;
create definer = mysql@`%` trigger update_producer_name_table_on_delete
after DELETE
on product_producer
for each row
BEGIN
delete from product_producer_name where id = old.id;
END;
create definer = mysql@`%` trigger update_producer_name_table_on_insert
after INSERT
on product_producer
for each row
BEGIN
insert into product_producer_name(id, name) values (new.id, new.name);
END;
create definer = mysql@`%` trigger update_producer_name_table_on_update
after UPDATE
on product_producer
for each row
BEGIN
replace product_producer_name(id, name) VALUES (new.id, new.name);
END;
create table product_producer_name
(
id   int auto_increment
primary key,
name varchar(100) null
);
create definer = mysql@`%` trigger product_producer_name_restrict_update_name
before UPDATE
on product_producer_name
for each row
BEGIN
if (new.name != old.name) then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update locked record';
end if;
END;
create table product_review
(
id               int auto_increment
primary key,
product_id       int                                 not null,
rating           int       default 5                 not null,
userName         varchar(100)                        not null,
review_text      text                                not null,
parent_review_id int                                 null,
level            int       default 1                 null,
time_add         timestamp default CURRENT_TIMESTAMP not null,
time_edit        timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
constraint parent_fk
foreign key (parent_review_id) references product_review (id)
on update cascade on delete set null,
constraint product_review_ibfk_1
foreign key (product_id) references product (id)
on update cascade on delete cascade
);
create index product_review_rating_index
on product_review (rating);
create definer = mysql@`%` trigger check_rating_on_insert
before INSERT
on product_review
for each row
BEGIN
set @rating = new.rating;
if @rating < 1 or @rating > 5 then
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Ошибка. Рейтинг должен быть от 1 до 5!';
end if;
END;
create definer = mysql@`%` trigger check_rating_on_update
before UPDATE
on product_review
for each row
BEGIN
set @rating = new.rating;
if @rating < 1 or @rating > 5 then
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Ошибка. Рейтинг должен быть от 1 до 5!';
end if;
END;
create definer = mysql@`%` trigger set_level_number_on_insert
before INSERT
on product_review
for each row
BEGIN
if new.parent_review_id is not null then
set new.level = (select level from product_review parent where parent.id = new.parent_review_id limit 1) + 1;
end if;
END;
create definer = mysql@`%` trigger set_level_number_on_update
before UPDATE
on product_review
for each row
BEGIN
if (new.parent_review_id != old.parent_review_id) and (new.parent_review_id is not null) then
set new.level = (select level from product_review where product_review.id = new.parent_review_id limit 1) + 1;
end if;
END;
create definer = mysql@`%` trigger update_reviews_count_on_delete
after DELETE
on product_review
for each row
BEGIN
update counters set product_reviews = product_reviews - 1;
END;
create definer = mysql@`%` trigger update_reviews_count_on_insert
after INSERT
on product_review
for each row
BEGIN
update counters set product_reviews = product_reviews + 1;
END;
create table product_to_order
(
id         int auto_increment
primary key,
id_product int not null,
id_order   int not null,
amount     int not null comment 'кол-во единиц товара',
constraint order_fk
foreign key (id_order) references `order` (id)
on update cascade on delete cascade,
constraint product_fk
foreign key (id_product) references product (id)
on update cascade on delete cascade
);
create table reviews_dummies
(
id         int auto_increment
primary key,
identifier text not null
);
create table temp_log
(
id      int auto_increment
primary key,
message text not null
);
create definer = admin48@`%` view city_count_view as -- missing source code
;
create definer = root@`%` view city_full_view as
select `cookie_shop`.`city`.`id`         AS `id города`,
`cookie_shop`.`city`.`identifier` AS `Город`,
`c`.`identifier`                  AS `Страна`
from (`cookie_shop`.`city`
join `cookie_shop`.`country` `c` on ((`cookie_shop`.`city`.`country_id` = `c`.`id`)));
create definer = mysql@`%` view customer_contact_from_deleted_cities_view as -- missing source code
;
-- comment on column customer_contact_from_deleted_cities_view.Адрес not supported: Адрес в городе. В формате "ул. Речная д.64/2 кв. 56"
create definer = root@`%` view customer_contact_full_view as
select `cookie_shop`.`customer_contact`.`id`            AS `id`,
`cookie_shop`.`customer_contact`.`customer_name` AS `ФИО`,
`c`.`identifier`                                 AS `Город`,
`cookie_shop`.`customer_contact`.`city_address`  AS `Адрес`,
`cookie_shop`.`customer_contact`.`phone`         AS `Телефон`,
`cookie_shop`.`customer_contact`.`email`         AS `email`
from (`cookie_shop`.`customer_contact`
join `cookie_shop`.`city` `c` on ((`cookie_shop`.`customer_contact`.`city_id` = `c`.`id`)));
-- comment on column customer_contact_full_view.Адрес not supported: Адрес в городе. В формате "ул. Речная д.64/2 кв. 56"
create definer = root@`%` view customer_full_view as
select `cookie_shop`.`customer`.`id`       AS `id`,
`cookie_shop`.`customer`.`login`    AS `Логин`,
`cookie_shop`.`customer`.`password` AS `Пароль`,
`cg`.`identifier`                   AS `Группа`,
`cc`.`customer_name`                AS `ФИО`,
`cs`.`identifier`                   AS `Статус`,
`cookie_shop`.`customer`.`discount` AS `Процент скидки`
from (((`cookie_shop`.`customer` join `cookie_shop`.`customer_contact` `cc` on ((`cookie_shop`.`customer`.`customer_contact_id` = `cc`.`id`))) join `cookie_shop`.`customer_group` `cg` on ((`cookie_shop`.`customer`.`customer_group_id` = `cg`.`id`)))
join `cookie_shop`.`customer_status` `cs` on ((`cookie_shop`.`customer`.`customer_status_id` = `cs`.`id`)));
-- comment on column customer_full_view.`Процент скидки` not supported: кол-во скидочных баллов
create definer = mysql@`%` view customer_order_full_view as -- missing source code
;
-- comment on column customer_order_full_view.Комментарий not supported: Заполняется пользователем при заполнении заказа
create definer = root@`%` view full_customer_view as
select `cookie_shop`.`customer`.`id`       AS `id`,
`cookie_shop`.`customer`.`login`    AS `Логин`,
`cookie_shop`.`customer`.`password` AS `Пароль`,
`cg`.`identifier`                   AS `Группа`,
`cc`.`customer_name`                AS `ФИО`,
`cs`.`identifier`                   AS `Статус`,
`cookie_shop`.`customer`.`discount` AS `Процент скидки`
from (((`cookie_shop`.`customer` join `cookie_shop`.`customer_contact` `cc` on ((`cookie_shop`.`customer`.`customer_contact_id` = `cc`.`id`))) join `cookie_shop`.`customer_group` `cg` on ((`cookie_shop`.`customer`.`customer_group_id` = `cg`.`id`)))
join `cookie_shop`.`customer_status` `cs` on ((`cookie_shop`.`customer`.`customer_status_id` = `cs`.`id`)));
-- comment on column full_customer_view.`Процент скидки` not supported: кол-во скидочных баллов
create definer = admin48@`%` view product_category_full_view as -- missing source code
;
-- comment on column product_category_full_view.Изображения not supported: Изображения в ввиде ссылок через запятую или другой разделитель
create definer = mysql@`%` view product_full_view as -- missing source code
;
-- comment on column product_full_view.Изображения not supported: Ссылки на изображения через запятую. Или сериализовать массив и совать его сюда, опять же в виде строки.
create definer = admin48@`%` view product_producer_editable_view as -- missing source code
;
create definer = admin48@`%` view product_producer_full_view as -- missing source code
;
create definer = mysql@`%` view product_review_full_view as -- missing source code
;
create definer = root@`%` view product_to_order_full_view as
select `cookie_shop`.`product_to_order`.`id`     AS `id товара`,
`co`.`customer_login`                     AS `Логин пользователя`,
`p`.`name`                                AS `Продукт`,
`cookie_shop`.`product_to_order`.`amount` AS `Кол-во`
from ((`cookie_shop`.`product_to_order` join `cookie_shop`.`customer_order` `co` on ((`cookie_shop`.`product_to_order`.`id_order` = `co`.`id`)))
join `cookie_shop`.`product` `p` on ((`cookie_shop`.`product_to_order`.`id_product` = `p`.`id`)));
-- comment on column product_to_order_full_view.`Кол-во` not supported: кол-во единиц товара
create definer = admin48@`%` view query_aggregate_also_2_view as -- missing source code
;
create definer = root@`%` view query_aggregate_also_view as
select sum(`cookie_shop`.`product`.`price`)                    AS `Общая цена`,
sum((case
when (`cookie_shop`.`product`.`flag_avaliable` = FALSE)
then `cookie_shop`.`product`.`price` end)) AS `Общая цена недоступных`
from `cookie_shop`.`product`;
create definer = admin48@`%` view query_in_view as -- missing source code
;
create definer = admin48@`%` view query_last_view as -- missing source code
;
create definer = admin48@`%` view query_not_in_view as -- missing source code
;
create definer = mysql@`%` view query_query_left_join_view as -- missing source code
;
create definer = admin48@`%` view query_u_view as -- missing source code
;
create definer = mysql@`%` view quick_week_review_and_rating5_view as -- missing source code
;
create definer = mysql@`%` view quick_week_review_view as -- missing source code
;
create definer = root@`%` view users_with_roles_view as
select `mysql`.`default_roles`.`USER` AS `Пользователь`, `mysql`.`default_roles`.`DEFAULT_ROLE_USER` AS `Роль`
from `mysql`.`default_roles`;
create
definer = root@`%` procedure add_city_routine(IN _city_name varchar(255), IN _country_id int)
begin
insert into cities(identifier, country_id) value (_city_name, _country_id);
end;
create
definer = root@`%` procedure add_customer_contact_routine(IN _customer_name varchar(255), IN _city_id int,
IN _city_address varchar(255), IN _phone varchar(255),
IN _email varchar(255))
begin
insert into contact(customer_name, city_id, city_address, phone, email)
value (_customer_name, _city_id, _city_address, _phone, _email);
end;
create
definer = root@`%` procedure add_customer_order_routine(IN _customer_id int, IN _customer_login varchar(255),
IN _customer_contact_id int, IN _delivery_method_id int,
IN _status int, IN _comment text, IN _payment_method_id int)
begin
insert into `order`(customer_id, customer_login, customer_contact_id, delivery_method_id, status, comment,
                    payment_method_id)
value (_customer_id, _customer_login, _customer_contact_id, _delivery_method_id, _status, _comment,
_payment_method_id);
end;
create
definer = root@`%` procedure add_customer_routine(IN _login varchar(255), IN _password varchar(255),
IN _customer_group_id int, IN _customer_contact_id int,
IN _customer_status_id int, IN _discount int)
begin
insert into customer(login, password, customer_group_id, customer_contact_id, customer_status_id, discount)
value (_login, _password, _customer_group_id, _customer_contact_id, _customer_status_id, _discount);
end;
create
definer = root@`%` procedure add_product_category_routine(IN _name varchar(255), IN _description varchar(255),
IN _images text, IN _parent_category_id int)
begin
insert into product_category(name, description, images, parent_category_id)
value (_name, _description, _images, _parent_category_id);
end;
create
definer = root@`%` procedure add_product_producer_routine(IN _name varchar(255), IN _description varchar(255), IN _logo text)
begin
insert into product_producer(name, description, logo)
value (_name, _description, _logo);
end;
create
definer = root@`%` procedure add_product_review_routine(IN _product_id int, IN _rating int,
IN _userName varchar(255), IN _review_text text,
IN _parent_review_id int, IN _time_add varchar(255),
IN _time_edit varchar(255))
begin
insert into product_review(product_id, rating, userName, review_text, parent_review_id, time_add, time_edit)
value (_product_id, _rating, _userName, _review_text, _parent_review_id, str_to_date(_time_add, '%d.%m.%Y %T'),
str_to_date(_time_edit, '%d.%m.%Y %T'));
end;
create
definer = root@`%` procedure add_product_routine(IN _category_id int, IN _producer_id int, IN _name varchar(255),
IN _images text, IN _price decimal, IN _flag_avaliable tinyint(1),
IN _amount int, IN _description text, IN _time_add varchar(255))
begin
insert into product(category_id, producer_id, name, images, price, flag_avaliable, amount, description, time_add)
value (_category_id, _producer_id, _name, _images, _price, _flag_avaliable, _amount, _description,
str_to_date(_time_add, '%d.%m.%Y %T'));
end;
create
definer = root@`%` procedure add_product_to_order_routine(IN _id_product int, IN _id_order int, IN _amount int)
begin
insert into product_to_order(id_product, id_order, amount)
value (_id_product, _id_order, _amount);
end;
create
definer = root@`%` procedure edit_city_routine(IN _id int, IN _city_name varchar(255), IN _country_id int)
begin
update cities set identifier = _city_name, country_id = _country_id where id = _id;
end;
create
definer = root@`%` procedure edit_customer_contact_routine(IN _id int, IN _customer_name varchar(255),
IN _city_id int, IN _city_address varchar(255),
IN _phone varchar(255), IN _email varchar(255))
begin
update contact
set customer_name = _customer_name,
city_id       = _city_id,
city_address  = _city_address,
phone         = _phone,
email         = _email
where id = _id;
end;
create
definer = root@`%` procedure edit_customer_no_password_routine(IN _id int, IN _login varchar(255),
IN _customer_group_id int,
IN _customer_contact_id int,
IN _customer_status_id int, IN _discount int)
begin
update customer
set login=_login,
customer_group_id= _customer_group_id,
customer_contact_id =_customer_contact_id,
customer_status_id =_customer_status_id,
discount= _discount
where id = _id;
end;
create
definer = root@`%` procedure edit_customer_order_routine(IN _id int, IN _customer_id int,
IN _customer_login varchar(255),
IN _customer_contact_id int, IN _delivery_method_id int,
IN _status int, IN _comment text,
IN _payment_method_id int)
begin
update `order`
set customer_id         = _customer_id,
customer_login      = _customer_login,
customer_contact_id = _customer_contact_id,
delivery_method_id  = _delivery_method_id,
status              = _status,
comment             = _comment,
payment_method_id   = _payment_method_id
where id = _id;
end;
create
definer = root@`%` procedure edit_customer_routine(IN _id int, IN _login varchar(255), IN _password varchar(255),
IN _customer_group_id int, IN _customer_contact_id int,
IN _customer_status_id int, IN _discount int)
begin
update customer
set login=_login,
password=_password,
customer_group_id= _customer_group_id,
customer_contact_id =_customer_contact_id,
customer_status_id =_customer_status_id,
discount= _discount
where id = _id;
end;
create
definer = root@`%` procedure edit_product_category_routine(IN _id int, IN _name varchar(255),
IN _description varchar(255), IN _images text,
IN _parent_category_id int)
begin
update product_category
set name               = _name,
description        =_description,
images             = _images,
parent_category_id = _parent_category_id
where id = _id;
end;
create
definer = root@`%` procedure edit_product_producer_routine(IN _id int, IN _name varchar(255),
IN _description varchar(255), IN _logo text)
begin
update product_producer
set name        = _name,
description =_description,
logo        = _logo
where id = _id;
end;
create
definer = root@`%` procedure edit_product_review_routine(IN _id int, IN _product_id int, IN _rating int,
IN _userName varchar(255), IN _review_text text,
IN _parent_review_id int, IN _time_add varchar(255),
IN _time_edit varchar(255))
begin
update product_review
set product_id       = _product_id,
rating           =_rating,
userName         = _userName,
review_text      = _review_text,
parent_review_id = _parent_review_id,
time_add         =str_to_date(_time_add, '%d.%m.%Y %T'),
time_edit        =str_to_date(_time_edit, '%d.%m.%Y %T')
where id = _id;
end;
create
definer = root@`%` procedure edit_product_routine(IN _id int, IN _category_id int, IN _producer_id int,
IN _name varchar(255), IN _images text, IN _price decimal,
IN _flag_avaliable tinyint(1), IN _amount int,
IN _description text, IN _time_add varchar(255))
begin
update product
set category_id    = _category_id,
producer_id    = _producer_id,
name           = _name,
images         = _images,
price          = _price,
flag_avaliable = _flag_avaliable,
amount         = _amount,
description    = _description,
time_add       =str_to_date(_time_add, '%d.%m.%Y %T')
where id = _id;
end;
create
definer = root@`%` procedure edit_product_to_order_routine(IN _id int, IN _id_product int, IN _id_order int, IN _amount int)
begin
update product_to_order
set id_product =_id_product,
id_order   = _id_order,
amount     = _amount
where id = _id;
end;
create
definer = root@`%` procedure fill_city_table_routine(IN n int)
begin
declare i int default 1;
set @start_city_name_number = (select id from city_names order by id limit 1);
set @city_name_count = (select count(*) from city_names);
set @start_country_number = (select id from country order by id limit 1);
set @country_count = (select count(*) from country);
set i = 1;
while i <= n do
set @city_name_id = round(rand() * (@city_name_count - 1)) + 0 + @start_city_name_number;
set @city_name = (select identifier from city_names where id = @city_name_id);
set @country_id = round(rand() * (@country_count - 1)) + 0 + @start_country_number;
insert into cities(identifier, country_id)
VALUES (@city_name, @country_id);
set i = i + 1;
END WHILE;
end;
create
definer = root@`%` procedure fill_customer_contact_table_routine(IN n int)
begin
declare i int default 1;
set @start_customer_names_number = (select id from customer_names order by id limit 1);
set @customer_names_count = (select count(*) from customer_names);
set @start_city_number = (select id from cities order by id limit 1);
set @city_count = (select count(*) from cities);
set @start_address_number = (select id from city_addresses order by id limit 1);
set @address_count = (select count(*) from city_addresses);
set @start_phone_number = (select id from customer_phones order by id limit 1);
set @phone_count = (select count(*) from customer_phones);
set @start_email_number = (select id from customer_emails order by id limit 1);
set @email_count = (select count(*) from customer_emails);
set i = 1;
while i <= n do
set @customer_names_id = round(rand() * (@customer_names_count - 1)) + 0 + @start_customer_names_number;
set @city_id = round(rand() * (@city_count - 1)) + 0 + @start_city_number;
set @address_id = round(rand() * (@address_count - 1)) + 0 + @start_address_number;
set @phone_id = round(rand() * (@phone_count - 1)) + 0 + @start_phone_number;
set @email_id = round(rand() * (@email_count - 1)) + 0 + @start_email_number;
set @customer_name = (select identifier from customer_names where id = @customer_names_id);
set @city = (select identifier from cities where id = @city_id);
set @address = (select identifier from city_addresses where id = @address_id);
set @phone = (select identifier from customer_phones where id = @phone_id);
set @email = (select identifier from customer_emails where id = @email_id);
insert into contact(customer_name, city_id, city_address, phone, email)
VALUES (@customer_name, @city_id, @address, @phone, @email);
set i = i + 1;
END WHILE;
end;
create
definer = root@`%` procedure fill_customer_order_table_routine(IN n int)
begin
declare i int default 1;
declare j int default 1;
# login и contact_id заполняются через: триггер на вставку customer_id
# вся инфа о продуктах = json, т.к. order не изменияется (кроме статуса).
set @start_customer_id = (select min(id)
from customer);
set @customer_count = (select customers
from counters);
set @start_delivery_method_id = (select min(id)
from delivery_method);
set @delivery_method_count = (select count(*)
from delivery_method);
set @start_status_id = (select min(id)
from order_status);
set @status_count = (SELECT count(*)
from order_status);
set @start_comment_id = (select min(id)
from order_comments);
set @comment_count = (SELECT count(*)
from order_comments);
set @start_product_id = (select min(id)
from product);
set @product_count = (SELECT products
from counters);
set @status_str = '';
set i = 1;
while i <= n do
set @customer_id = round(rand() * (@customer_count - 1)) + @start_customer_id ;
set @delivery_method_id = round(rand() * (@delivery_method_count - 1)) + @start_delivery_method_id ;
set @comment_id = round(rand() * (@comment_count - 1)) + @start_comment_id ;
set @comment = (select identifier from order_comments where id = @comment_id);
set @product_in_order = json_array();
set @status_id = round(rand() * (@status_count - 1)) + @start_status_id ;
set @status_str = concat(@status_str, ' ', @status_id);
#     product_in_order : 1-10 продуктов, 1-10 единиц в каждом.
set @max_product_amount = 10;
set @product_amount = round(rand() * (@max_product_amount - 1)) + 1;
set j = 1;
insert into `order`(customer_id, delivery_method_id, status, comment)
VALUES (@customer_id, @delivery_method_id, @status_id, @comment);
set i = i + 1;
END WHILE;
end;
create
definer = mysql@`%` procedure fill_customer_table_routine(IN n int)
begin
declare i int default 1;
set @start_login_number = (select count(*)
from customer);
set @customer_group_start_number = (select id from customer_group order by id limit 1);
set @customer_group_count = (SELECT count(*)
from customer_group);
set @customer_contact_start_number = (select id from contact order by id limit 1);
set @customer_contact_count = (SELECT count(*)
from contact);
set @customer_status_start_number = (select id from customer_status order by id limit 1);
set @customer_status_count = (SELECT count(*)
from customer_status);
set i = 1;
while i <= n do
set @val_customer_group_id = round(rand() * (@customer_group_count - 1)) + @customer_group_start_number;
set @val_customer_contact_id = round(rand() * (@customer_contact_count - 1)) + @customer_contact_start_number;
set @val_customer_status_id = round(rand() * (@customer_status_count - 1)) + @customer_status_start_number;
set @current_login_number = @start_login_number + i;
set @val_login = (select concat('user', @current_login_number));
set @val_password = 'user';
set @val_discount = round(rand() * (25)); # discount от 0 до 25%
insert into customer(login, password, customer_group_id, customer_contact_id, customer_status_id, discount)
VALUES (@val_login, @val_password, @val_customer_group_id, @val_customer_contact_id, @val_customer_status_id,
@val_discount);
set i = i + 1;
END WHILE;
end;
create
definer = root@`%` procedure fill_product_category_table_routine(IN dummy varchar(255))
begin
set @start_category_id = (select id from product_category order by id limit 1);
INSERT INTO cookie_shop.product_category (name, description, images, products_amount, parent_category_id, level)
VALUES ('Категория не указана', 'Сюда попадают все товары без указанной категории', null, 0, null, 1);
INSERT INTO cookie_shop.product_category (name, description, images, products_amount, parent_category_id, level)
VALUES ('Печенье овсяное',
'выпускается из сдобного теста различной рецептуры, характеризуется большим количеством сахара, жиров и яиц. Сдобное печенье может быть песочно-выемным, песочно-отсадным, сбивным, овсяным, ореховым.',
null, 0, null, 1);
INSERT INTO cookie_shop.product_category (name, description, images, products_amount, parent_category_id, level)
VALUES ('Печенье овсяное',
'Овсяное печенье также имеет отдельную группу. Принято считать, что оно полезно для здоровья т.к. в состав входят овсяные хлопья.',
'https:
INSERT INTO cookie_shop.product_category (name, description, images, products_amount, parent_category_id, level)
VALUES ('Печенье сахарное',
'Сахарное печенье – вырабатывается из пластичного теста, характеризуется хрупкостью и пористостью, имеет рисунок на пищевой поверхности.',
'https:
0, null, 1);
INSERT INTO cookie_shop.product_category (name, description, images, products_amount, parent_category_id, level)
VALUES ('Печенье бисквитное', '', null, 0, null, 1);
INSERT INTO cookie_shop.product_category (name, description, images, products_amount, parent_category_id, level)
VALUES ('Печенье слоеное', '', null, 0, null, 1);
INSERT INTO cookie_shop.product_category (name, description, images, products_amount, parent_category_id, level)
VALUES ('Печенье песочное',
'Пеcочное печенье готовится из эластичного теста, сахара и жира. Ему свойственна рассыпчатая структура: «листики», «песочное», «ромашка», «суворовское».',
'https:
end;
create
definer = root@`%` procedure fill_product_producer_table_routine(IN dummy varchar(255))
begin
INSERT INTO cookie_shop.product_producer (name, description, logo, products_amount)
VALUES ('Кондитерский цех «Фаворит»',
'Кондитерский цех "Фаворит" ИП Половинко Ю.В. приглашает к сотрудничеству розничных и оптовых покупателей.',
'https:
INSERT INTO cookie_shop.product_producer (name, description, logo, products_amount)
VALUES ('Кондитерская фабрика «Брянконфи»',
'Компания-производитель, г.Брянск, приглашает к сотрудничеству оптовых покупателей и дилеров.',
'https:
INSERT INTO cookie_shop.product_producer (name, description, logo, products_amount)
VALUES ('Кондитерская фабрика «Мирослада»', 'Функционируем в сегменте с 1994 года.
Фирма выпускает и реализует кондитерскую продукцию.',
'https:
INSERT INTO cookie_shop.product_producer (name, description, logo, products_amount)
VALUES ('Фабрика печенья «Кременкульская»',
'Фабрика печенья «Кременкульская» основана в 1998 году в городе Челябинске. В 2006 году предприятие открыло новую производственную площадку в пригороде.',
'https:
INSERT INTO cookie_shop.product_producer (name, description, logo, products_amount)
VALUES ('ОАО «Благовещенская кондитерская фабрика «Зея»',
'ОАО «Благовещенская кондитерская фабрика «Зея» работает в городе Благовещенске Амурской области с тридцатых годов ХХ века. В прошлом выпускала сухари для армейских пайков.',
'https:
0);
end;
create
definer = mysql@`%` procedure fill_product_review_table_routine(IN n int)
begin
declare i int default 1;
set @start_review_number = (select id from product_review order by id asc limit 1);
set @review_count = (SELECT count(*)
from product_review);
set @start_product_number = (select id from product order by id limit 1);
set @product_count = (select count(*) from product);
set @start_text_number = (select id from reviews_dummies order by id limit 1);
set @text_count = (SELECT count(*)
from reviews_dummies);
set i = 1;
while i <= n do
set @rating = round(rand() * (5 - 1)) + 1; # from 1 to 5
set @login = concat('userName', i); # from 1 to 5
set @product_id = round(rand() * (@product_count - 1)) + @start_product_number;
set @review_text_id = round(rand() * (@text_count - 1)) + @start_text_number;
set @review_text = (select identifier
from reviews_dummies
where id = @review_text_id);
set @parent_review_id = round(rand() * (@review_count - 1)) + @start_review_number;
if (@parent_review_id = 0) then
set @parent_review_id = null;
end if;
insert into product_review(product_id, parent_review_id, rating, userName, review_text)
VALUES (@product_id, @parent_review_id, @rating, @login, @review_text);
set i = i + 1;
END WHILE;
end;
create
definer = root@`%` procedure fill_product_table_routine(IN n int)
begin
declare i int default 1;
set @start_product_category_number = (select id from product_category order by id limit 1);
set @product_category_count = (select count(*) from product_category);
set @start_product_producer_number = (select id from product_producer order by id limit 1);
set @product_producer_count = (select count(*) from product_producer);
set @start_product_names_number = (select id from product_names order by id limit 1);
set @product_names_count = (select count(*) from product_names);
set @start_product_description_number = (select id from product_descriptions order by id limit 1);
set @product_description_count = (select count(*) from product_descriptions);
set @images_count = 0;
set i = 1;
while i <= n do
set @category_id = round(rand() * (@product_category_count - 1)) + @start_product_category_number;
set @producer_id = round(rand() * (@product_producer_count - 1)) + @start_product_producer_number;
set @product_name_id = round(rand() * (@product_names_count - 1)) + @start_product_names_number;
set @price = round(rand() * (500 - 1)) + 1;
select rand() * 1 into @rand_is_avail; # 100% от 0 до 1
# чтобы товаров в наличии было побольше
set @rand_is_avail = @rand_is_avail + 0.3; # почему 0.5 дает потом все 1???
set @is_available = round(@rand_is_avail * 1); # от 0 до 1
set @amount = round(rand() * (1000 - 1)) + 1; # от 1 до 1000, включительно
set @product_description_id = round(rand() * (@product_description_count - 1)) + @start_product_description_number;
set @product_name = (
select identifier
from product_names
where id = @product_name_id);
set @product_description =
(select identifier
from product_descriptions
where id = @product_description_id);
-- Получение изображений
set @images_start_id = (select min(id) from product_images);
set @images_count = round(rand() * 5 - 1) + 1; # от 1 до 5 img
set @j = 1;
set @images = '';
WHILE @j <= @images_count
DO
SET @image_id = round(rand() * (@images_count - 1)) + @images_start_id;
SELECT identifier
FROM product_images
where id = @image_id
INTO @image_link;
SELECT concat(@images, ', ', @image_link) into @images;
SET @j = @j + 1;
END WHILE;
insert into product(category_id, producer_id, name, images, price, flag_avaliable, amount, description)
values (@category_id, @producer_id, @product_name, @images, @price, @is_available, @amount,
@product_description);
set i = i + 1;
END WHILE;
end;
create
definer = admin48@`%` procedure fill_product_to_order_table_routine(IN n int)
begin
declare i int default 1;
set @start_product_number = (select id from product order by id limit 1);
set @product_count = (select count(*) from product);
set @start_order_number = (select id from customer_order order by id limit 1);
set @order_count = (select count(*) from customer_order);
set i = 1;
while i <= n do
set @product_id = round(rand() * (@product_count - 1)) + 0 + @start_product_number;
set @order_id = round(rand() * (@order_count - 1)) + 0 + @start_order_number;
set @amount = round(rand() * (100 - 1)) + 1; # 1-100?
insert into product_to_order(id_product, id_order, amount)
VALUES (@product_id, @order_id, @amount);
set i = i + 1;
END WHILE;
end;
create
definer = admin48@`%` procedure get_city_count_routine()
begin
select * from city_count_view;
end;
create
definer = root@`%` procedure get_city_full_routine()
BEGIN
select * from city_full_view;
end;
create
definer = root@`%` procedure get_city_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from city_full_view where Город like @`like`;
end;
create
definer = admin48@`%` procedure get_completed_orders_routine(IN _order_status varchar(255))
begin
select customer_order.id             'id заказа',
cc.customer_name              'ФИО заказчика',
customer_order.customer_login 'Логин заказчика',
os.identifier                 'Статус'
from customer_order
join customer_contact cc on customer_order.customer_contact_id = cc.id
join order_status os on customer_order.status = os.id
where os.identifier = _order_status;
end;
create
definer = admin48@`%` procedure get_customer_contact_from_deleted_cities_routine()
begin
select * from customer_contact_from_deleted_cities_view;
end;
create
definer = admin48@`%` procedure get_customer_contact_full_routine()
begin
select * from customer_contact_full_view;
end;
create
definer = root@`%` procedure get_customer_contact_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from customer_contact_full_view where ФИО like @`like`;
end;
create
definer = admin48@`%` procedure get_customer_full_routine()
begin
select * from customer_full_view;
end;
create
definer = admin48@`%` procedure get_customer_order_full_routine()
begin
select * from customer_order_full_view;
end;
create
definer = root@`%` procedure get_customer_order_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from customer_order_full_view where ФИО like @`like`;
end;
create
definer = root@`%` procedure get_customer_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from customer_full_view where ФИО like @`like`;
end;
create
definer = mysql@`%` procedure get_new_products_routine(IN days int, IN count int)
BEGIN
select products_full.id,
products_full.name,
products_full.category,
products_full.producer,
products_full.images,
products_full.price,
products_full.flag_avaliable,
products_full.amount,
products_full.description,
products_full.options,
products_full.tags,
products_full.time_add,
product.id,
product.category_id,
product.producer_id,
product.name,
product.images,
product.price,
product.flag_avaliable,
product.amount,
product.description,
product.options,
product.tags,
product.time_add
from products_full
join product on to_days(products_full.time_add) + days >= to_days(now())
order by products_full.time_add desc
limit count;
END;
create
definer = mysql@`%` procedure get_newest_products_routine(IN count int)
BEGIN
select * from products_full order by time_add desc limit count;
END;
create
definer = admin48@`%` procedure get_orders_with_specified_delivery_method_routine(IN _delivery_method varchar(255))
begin
select customer_order.id             'id заказа',
cc.customer_name              'ФИО заказчика',
customer_order.customer_login 'Логин заказчика',
dm.identifier                 'Способ доставки'
from customer_order
join customer_contact cc on customer_order.customer_contact_id = cc.id
join delivery_method dm on customer_order.delivery_method_id = dm.id
where dm.identifier = _delivery_method;
end;
create
definer = mysql@`%` procedure get_product_categories_short_routine()
BEGIN
select * from product_categories_short;
END;
create
definer = admin48@`%` procedure get_product_category_full_routine()
begin
select * from product_category_full_view;
end;
create
definer = mysql@`%` procedure get_product_category_routine(IN category_id int)
BEGIN
select id, name, products_amount, `parent category`, level from full_product_categories where id = category_id;
END;
create
definer = root@`%` procedure get_product_category_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from product_category_full_view where Название like @`like`;
end;
create
definer = admin48@`%` procedure get_product_full_routine()
begin
select * from product_full_view;
end;
create
definer = admin48@`%` procedure get_product_producer_full_routine()
begin
select * from product_producer_full_view;
end;
create
definer = root@`%` procedure get_product_producer_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from product_producer_full_view where Название like @`like`;
end;
create
definer = admin48@`%` procedure get_product_review_full_routine()
begin
select * from product_review_full_view;
end;
create
definer = root@`%` procedure get_product_review_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from product_review_full_view where Продукт like @`like`;
end;
create
definer = mysql@`%` function get_product_reviews_count_routine() returns int
BEGIN
set @result = (select product_reviews from counters limit 1); # по идее, всегда 1
RETURN @result;
END;
create
definer = mysql@`%` procedure get_product_routine(IN product_id int)
BEGIN
select `p`.`id`             AS `id`,
`p`.`name`           AS `name`,
`cat`.`name`         AS `category`,
`prod`.`name`        AS `producer`,
`p`.`images`         AS `images`,
`p`.`price`          AS `price`,
`p`.`flag_avaliable` AS `flag_avaliable`,
`p`.`amount`         AS `amount`,
`p`.`description`    AS `description`,
`p`.`options`        AS `options`,
`p`.`tags`           AS `tags`
from ((`cookie_shop`.`product` `p` join `cookie_shop`.`product_category` `cat` on ((`p`.`category_id` = `cat`.`id`)))
join `cookie_shop`.`product_producer` `prod` on ((`p`.`producer_id` = `prod`.`id`)))
where p.id = product_id;
END;
create
definer = root@`%` procedure get_product_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from product_full_view where Название like @`like`;
end;
create
definer = root@`%` procedure get_product_to_order_full_routine()
BEGIN
select * from product_to_order_full_view;
end;
create
definer = root@`%` procedure get_product_to_order_search_routine(IN str varchar(255))
begin
set @like = concat(str, '%');
select * from product_to_order_full_view where Продукт like @`like`;
end;
create
definer = mysql@`%` procedure get_products_in_category_routine(IN category_id int, IN count_on_page int,
IN page int, IN asc_or_desc varchar(10))
BEGIN
if
(lower(asc_or_desc) = 'asc')
then # handling as default
set asc_or_desc = 'asc'; # потому что в prepared statement заменить можно только полный order by, а не один его ASC|DESC.
else
set asc_or_desc = 'desc';
end if;
if
(! page > 0)
then
set page = 1;
end if;
if
(count_on_page is null or count_on_page <= 0)
then
set count_on_page = 2147483647; # int max value
end if;
set @category_id = category_id;
set @limit_number = count_on_page;
set @page_number = page - 1;
set @offset_number = @limit_number * @page_number;
set @asc_or_desc = asc_or_desc;
set @statement =
concat('SELECT p.id,
p.name,
cat.name  `category`,
prod.name `producer`,
p.images,
p.price,
p.flag_avaliable,
p.amount,
p.description,
p.options
FROM product p
INNER JOIN product_category cat ON cat.id = ?
INNER JOIN product_producer prod ON prod.id = p.producer_id
ORDER BY id ', @asc_or_desc, '
limit ? offset ?');
prepare prepared from @statement;
EXECUTE prepared USING @category_id, @limit_number, @offset_number;
DEALLOCATE PREPARE prepared;
END;
create
definer = admin48@`%` procedure get_query_aggregate_also_2_routine()
begin
select * from query_aggregate_also_2_view;
end;
create
definer = admin48@`%` procedure get_query_aggregate_also_routine()
begin
select * from query_aggregate_also_view;
end;
create
definer = admin48@`%` procedure get_query_in_routine()
begin
select * from query_in_view;
end;
create
definer = admin48@`%` procedure get_query_last_routine()
begin
select * from query_last_view;
end;
create
definer = admin48@`%` procedure get_query_not_in_routine()
begin
select * from query_not_in_view;
end;
create
definer = admin48@`%` procedure get_query_query_left_join_routine()
begin
select * from query_query_left_join_view;
end;
create
definer = admin48@`%` procedure get_query_u_routine()
begin
select * from query_u_view;
end;
create
definer = admin48@`%` procedure get_quick_week_review_and_rating5_routine()
begin
select * from quick_week_review_and_rating5_view;
end;
create
definer = admin48@`%` procedure get_quick_week_review_routine()
begin
select * from quick_week_review_view;
end;
create
definer = mysql@`%` function get_total_customers_count_routine() returns int
BEGIN
set @result = (select customers from counters limit 1); # по идее, всегда 1
RETURN @result;
END;
create
definer = mysql@`%` function get_total_order_count() returns int
BEGIN
set @result = (select customer_orders from counters limit 1); # по идее, всегда 1
RETURN @result;
END;
create
definer = mysql@`%` function get_total_product_count() returns int
BEGIN
set @result = (select products from counters limit 1); # по идее, всегда 1
RETURN @result;
END;
create
definer = mysql@`%` procedure query_ac_g1_routine(IN name_contains varchar(100))
begin
set @name_like = concat('%', name_contains, '%');
#    o	все товары, в названии которых есть «с предсказаниями» с группировкой по имени
select name 'Продукт', avg(price) 'Сред. цена'
from product
where name like @name_like
group by name;
end;
create
definer = mysql@`%` procedure query_ac_g2_routine(IN name_contains varchar(100), IN avg_price_more_than int)
begin
set @name_like = concat('%', name_contains, '%');
#   	все товары, в названии которых есть «с предсказаниями» с группировкой по имени
select name 'Продукт', avg(price) as 'Сред. цена'
from product
where name like @name_like
group by name
having `Сред. цена` > avg_price_more_than;
end;
create
definer = mysql@`%` procedure query_ac_ni1_routine(IN price_from int, IN price_to int)
begin
select avg(amount) 'Сред. цена' from product p where p.price between price_from and price_to;
end;
create
definer = mysql@`%` procedure query_ac_ni2_routine(IN val varchar(255))
begin
set @mask = concat('%', val, '%');
select avg(price) 'сред. цена за единицу' from product p where name like @mask;
end;
create
definer = mysql@`%` procedure query_ac_wi1_routine(IN category_name varchar(50))
begin
select sum(price) 'общ. цена', c.name 'Категория'
from product
join product_category c on c.name = category_name
group by c.name;
end;
create
definer = mysql@`%` procedure query_ac_wi2_routine(IN product_name_like varchar(50))
begin
set product_name_like = concat('%', product_name_like, '%');
select sum(price) 'Общ. цена', p.name 'Название'
from product p
where p.name like product_name_like
group by p.name;
end;
create
definer = mysql@`%` procedure query_aqq_routine(IN amount_less_than int, IN avg_price_more_than int)
begin
#   	все товары, в названии которых есть «с предсказаниями» с группировкой по имени
select name 'Товар', amount 'Кол-во', avg(price) as 'Сред. цена'
from product
where (select sum(product.amount)) < amount_less_than
group by name, amount
having `Сред. цена` > avg_price_more_than;
end;
create
definer = mysql@`%` procedure query_qql_routine(IN cg_like varchar(20))
begin
set cg_like = concat('%', cg_like, '%');
#     юзеры с группой с именем типа “customer”… И другие
select cg.identifier 'group', c.login
from customer_group cg
left join customer c
on c.customer_group_id in (select id from customer_group where cg.identifier like cg_like)
group by `group`, login
order by login is null desc;
end;
create
definer = mysql@`%` procedure query_qqq_case_routine(IN id_or_producer_id varchar(20))
begin
if (id_or_producer_id != 'producer_id') then
set id_or_producer_id = 'id';
end if;
# товары без отзывов
select p.id, p.name, p.producer_id
from product p
where p.id not in (select product_id from product_review)
ORDER BY CASE
WHEN id_or_producer_id = 'id'
THEN p.id
ELSE p.producer_id END;
end;
create
definer = mysql@`%` procedure query_u_routine(IN name_like1 varchar(50), IN name_like2 varchar(50),
IN avg_price_more_than int)
begin
#   	все товары, в названии которых есть «с предсказаниями» с группировкой по имени
set name_like1 = concat('%', name_like1, '%');
set name_like2 = concat('%', name_like2, '%');
select name, avg(price) as 'avg_price'
from product
where name like name_like1
group by name
having avg_price > avg_price_more_than
union
(select name, avg(price) as 'avg_price' from product where name like name_like2 group by name);
end;
