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
    on city (identifier);

create table customer
(
    id                  int auto_increment
        primary key,
    login               varchar(100) default 'UNSET' not null,
    password            varchar(256)                 null,
    customer_group_id   int          default 1       not null,
    customer_contact_id int                          not null,
    customer_status_id  int          default 1       not null,
    discount            int          default 0       not null comment 'кол-во скидочных баллов'
);

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
    on customer_contact (customer_name);

create table customer_order
(
    id                  int auto_increment
        primary key,
    customer_contact_id int           not null comment 'Id в таблице контактов. Если пользователь зарегистирован, то сюда ставятся его контакты',
    delivery_method_id  int default 1 null comment 'Id способа доставки. Должна быть таблица где-то',
    status              int default 1 not null comment 'Статус заказа. Ожидает выполнения, в обработке, выполнен.',
    comment             text          null comment 'Заполняется пользователем при заполнении заказа',
    payment_method_id   int           null
);

create index payment_method_id
    on customer_order (payment_method_id);

create table delivery_method
(
    id         int auto_increment
        primary key,
    identifier varchar(255) not null
);

create table order_status
(
    id         int auto_increment
        primary key,
    identifier varchar(50) not null
);

create table payment_method
(
    id         int auto_increment
        primary key,
    identifier varchar(100) not null
);

create table product
(
    id             int auto_increment
        primary key,
    category_id    int        default 1                   null,
    producer_id    int                                    null,
    name           varchar(100)                           not null,
    images         text                                   null comment 'Ссылки на изображения через запятую. Или сериализовать массив и совать его сюда, опять же в виде строки.',
    price          decimal(15, 6)                         not null,
    flag_avaliable tinyint(1) default 1                   not null,
    amount         int        default 1                   not null,
    description    text                                   null,
    time_add       timestamp  default current_timestamp() not null
);

create index index_name_and_category
    on product (name, category_id);

create index name
    on product (name);

create index product_name_name_index
    on product (name);

create table product_category
(
    id                 int auto_increment
        primary key,
    name               varchar(50)   not null,
    description        text          null,
    images             text          null comment 'Изображения в ввиде ссылок через запятую или другой разделитель',
    products_amount    int default 0 null,
    parent_category_id int           null,
    level              int default 1 null
);

create index parent_category_id
    on product_category (parent_category_id);

create index product_category_name_index
    on product_category (name);

create table product_images
(
    id         int auto_increment
        primary key,
    identifier text not null
);

create table product_producer
(
    id          int auto_increment
        primary key,
    name        varchar(50)   not null,
    description text          null,
    logo        varchar(1024) null
);

create table product_to_order
(
    id         int auto_increment
        primary key,
    id_product int not null,
    id_order   int not null,
    amount     int not null comment 'кол-во единиц товара'
);


