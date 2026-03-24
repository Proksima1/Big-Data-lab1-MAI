INSERT INTO supplier (id, name, contact, email, phone, address, city, country)
SELECT ROW_NUMBER() OVER (
    ORDER BY name, contact, email, phone, address, city, country
    ) AS id,
       name,
       contact,
       email,
       phone,
       address,
       city,
       country
FROM (SELECT TRIM(supplier_name)    AS name,
             TRIM(supplier_contact) AS contact,
             TRIM(supplier_email)   AS email,
             TRIM(supplier_phone)   AS phone,
             TRIM(supplier_address) AS address,
             TRIM(supplier_city)    AS city,
             TRIM(supplier_country) AS country
      FROM input_csv) s;

INSERT INTO customer_pet (id, type, name, breed, category)
SELECT ROW_NUMBER() OVER (
    ORDER BY type, name, breed, category
    ) AS id,
       type,
       name,
       breed,
       category
FROM (SELECT TRIM(customer_pet_type)  AS type,
             TRIM(customer_pet_name)  AS name,
             TRIM(customer_pet_breed) AS breed,
             TRIM(pet_category)       AS category
      FROM input_csv) p;

INSERT INTO customer
(id,
 first_name,
 last_name,
 age,
 email,
 country,
 postal_code,
 customer_pet_id)
SELECT ROW_NUMBER() OVER (
    ORDER BY t.first_name, t.last_name, t.age, t.email, t.country, t.postal_code, t.pet_type, t.pet_name, t.pet_breed, t.pet_category
    )        AS id,
       t.first_name,
       t.last_name,
       t.age,
       t.email,
       t.country,
       t.postal_code,
       cp.id AS customer_pet_id
FROM (SELECT TRIM(s.customer_first_name)              AS first_name,
             TRIM(s.customer_last_name)               AS last_name,
             s.customer_age::INTEGER                  AS age,
             TRIM(s.customer_email)                   AS email,
             TRIM(s.customer_country)                 AS country,
             NULLIF(TRIM(s.customer_postal_code), '') AS postal_code,
             TRIM(s.customer_pet_type)                AS pet_type,
             TRIM(s.customer_pet_name)                AS pet_name,
             TRIM(s.customer_pet_breed)               AS pet_breed,
             TRIM(s.pet_category)                     AS pet_category
      FROM input_csv s) t
         JOIN customer_pet cp
              ON cp.type = t.pet_type
                  AND cp.name = t.pet_name
                  AND cp.breed = t.pet_breed
                  AND cp.category = t.pet_category;

INSERT INTO store
(id,
 name,
 location,
 city,
 state,
 country,
 phone,
 email)
SELECT ROW_NUMBER() OVER (
    ORDER BY name, location, city, state, country, phone, email
    ) AS id,
       name,
       location,
       city,
       state,
       country,
       phone,
       email
FROM (SELECT TRIM(store_name)              AS name,
             TRIM(store_location)          AS location,
             TRIM(store_city)              AS city,
             NULLIF(TRIM(store_state), '') AS state,
             TRIM(store_country)           AS country,
             TRIM(store_phone)             AS phone,
             TRIM(store_email)             AS email
      FROM input_csv) st;


INSERT INTO product
(id,
 name,
 category,
 price,
 available_quantity,
 weight,
 color,
 size,
 brand,
 material,
 description,
 rating,
 reviews,
 release_date,
 expiry_date,
 supplier_id)
SELECT ROW_NUMBER() OVER (
    ORDER BY
        t.name, t.category, t.price, t.available_quantity, t.weight,
        t.color, t.size, t.brand, t.material, t.description,
        t.rating, t.reviews, t.release_date, t.expiry_date,
        t.supplier_name, t.supplier_contact, t.supplier_email,
        t.supplier_phone, t.supplier_address, t.supplier_city, t.supplier_country
    )         AS id,
       t.name,
       t.category,
       t.price,
       t.available_quantity,
       t.weight,
       t.color,
       t.size,
       t.brand,
       t.material,
       t.description,
       t.rating,
       t.reviews,
       t.release_date,
       t.expiry_date,
       sup.id AS supplier_id
FROM (SELECT TRIM(s.product_name)                          AS name,
             TRIM(s.product_category)                      AS category,
             s.product_price::NUMERIC(10, 2)               AS price,
             s.product_quantity::INTEGER                   AS available_quantity,
             s.product_weight::NUMERIC(10, 1)              AS weight,
             TRIM(s.product_color)                         AS color,
             TRIM(s.product_size)                          AS size,
             TRIM(s.product_brand)                         AS brand,
             TRIM(s.product_material)                      AS material,
             TRIM(s.product_description)                   AS description,
             s.product_rating::NUMERIC(2, 1)               AS rating,
             s.product_reviews::INTEGER                    AS reviews,
             TO_DATE(s.product_release_date, 'MM/DD/YYYY') AS release_date,
             TO_DATE(s.product_expiry_date, 'MM/DD/YYYY')  AS expiry_date,
             TRIM(s.supplier_name)                         AS supplier_name,
             TRIM(s.supplier_contact)                      AS supplier_contact,
             TRIM(s.supplier_email)                        AS supplier_email,
             TRIM(s.supplier_phone)                        AS supplier_phone,
             TRIM(s.supplier_address)                      AS supplier_address,
             TRIM(s.supplier_city)                         AS supplier_city,
             TRIM(s.supplier_country)                      AS supplier_country
      FROM input_csv s) t
         JOIN supplier sup
              ON sup.name = t.supplier_name
                  AND sup.contact = t.supplier_contact
                  AND sup.email = t.supplier_email
                  AND sup.phone = t.supplier_phone
                  AND sup.address = t.supplier_address
                  AND sup.city = t.supplier_city
                  AND sup.country = t.supplier_country;

INSERT INTO seller
(id,
 first_name,
 last_name,
 email,
 country,
 postal_code)
SELECT ROW_NUMBER() OVER (
    ORDER BY t.first_name, t.last_name, t.email, t.country, t.postal_code
    ) AS id,
       t.first_name,
       t.last_name,
       t.email,
       t.country,
       t.postal_code
FROM (SELECT DISTINCT TRIM(s.seller_first_name)              AS first_name,
                      TRIM(s.seller_last_name)               AS last_name,
                      TRIM(s.seller_email)                   AS email,
                      TRIM(s.seller_country)                 AS country,
                      NULLIF(TRIM(s.seller_postal_code), '') AS postal_code
      FROM input_csv s) t;

INSERT INTO sales_fact
(id,
 customer_id,
 seller_id,
 store_id,
 product_id,
 date,
 sale_quantity,
 total_price)
SELECT ROW_NUMBER() OVER (
    ORDER BY
        t.sale_date,
        t.customer_first_name, t.customer_last_name, t.customer_email,
        t.seller_first_name, t.seller_last_name, t.seller_email,
        t.product_name, t.product_description,
        t.store_name, t.store_location, t.store_city,
        t.sale_quantity, t.total_price
    )        AS id,
       c.id  AS customer_id,
       se.id AS seller_id,
       st.id AS store_id,
       p.id  AS product_id,
       t.sale_date,
       t.sale_quantity,
       t.total_price
FROM (SELECT TO_DATE(s.sale_date, 'MM/DD/YYYY')            AS sale_date,
             s.sale_quantity::INTEGER                      AS sale_quantity,
             s.sale_total_price::NUMERIC(12, 2)            AS total_price,

             TRIM(s.customer_first_name)                   AS customer_first_name,
             TRIM(s.customer_last_name)                    AS customer_last_name,
             s.customer_age::INTEGER                       AS customer_age,
             TRIM(s.customer_email)                        AS customer_email,
             TRIM(s.customer_country)                      AS customer_country,
             NULLIF(TRIM(s.customer_postal_code), '')      AS customer_postal_code,
             TRIM(s.customer_pet_type)                     AS customer_pet_type,
             TRIM(s.customer_pet_name)                     AS customer_pet_name,
             TRIM(s.customer_pet_breed)                    AS customer_pet_breed,
             TRIM(s.pet_category)                          AS pet_category,

             TRIM(s.seller_first_name)                     AS seller_first_name,
             TRIM(s.seller_last_name)                      AS seller_last_name,
             TRIM(s.seller_email)                          AS seller_email,
             TRIM(s.seller_country)                        AS seller_country,
             NULLIF(TRIM(s.seller_postal_code), '')        AS seller_postal_code,

             TRIM(s.product_name)                          AS product_name,
             TRIM(s.product_category)                      AS product_category,
             s.product_price::NUMERIC(10, 2)               AS product_price,
             s.product_quantity::INTEGER                   AS product_quantity,
             s.product_weight::NUMERIC(10, 1)              AS product_weight,
             TRIM(s.product_color)                         AS product_color,
             TRIM(s.product_size)                          AS product_size,
             TRIM(s.product_brand)                         AS product_brand,
             TRIM(s.product_material)                      AS product_material,
             TRIM(s.product_description)                   AS product_description,
             s.product_rating::NUMERIC(2, 1)               AS product_rating,
             s.product_reviews::INTEGER                    AS product_reviews,
             TO_DATE(s.product_release_date, 'MM/DD/YYYY') AS product_release_date,
             TO_DATE(s.product_expiry_date, 'MM/DD/YYYY')  AS product_expiry_date,

             TRIM(s.supplier_name)                         AS supplier_name,
             TRIM(s.supplier_contact)                      AS supplier_contact,
             TRIM(s.supplier_email)                        AS supplier_email,
             TRIM(s.supplier_phone)                        AS supplier_phone,
             TRIM(s.supplier_address)                      AS supplier_address,
             TRIM(s.supplier_city)                         AS supplier_city,
             TRIM(s.supplier_country)                      AS supplier_country,

             TRIM(s.store_name)                            AS store_name,
             TRIM(s.store_location)                        AS store_location,
             TRIM(s.store_city)                            AS store_city,
             NULLIF(TRIM(s.store_state), '')               AS store_state,
             TRIM(s.store_country)                         AS store_country,
             TRIM(s.store_phone)                           AS store_phone,
             TRIM(s.store_email)                           AS store_email
      FROM input_csv s) t
         JOIN customer_pet cp
              ON cp.type = t.customer_pet_type
                  AND cp.name = t.customer_pet_name
                  AND cp.breed = t.customer_pet_breed
                  AND cp.category = t.pet_category
         JOIN customer c
              ON c.first_name = t.customer_first_name
                  AND c.last_name = t.customer_last_name
                  AND c.age = t.customer_age
                  AND c.email = t.customer_email
                  AND c.country = t.customer_country
                  AND c.postal_code IS NOT DISTINCT FROM t.customer_postal_code
                  AND c.customer_pet_id = cp.id
         JOIN seller se
              ON se.first_name = t.seller_first_name
                  AND se.last_name = t.seller_last_name
                  AND se.email = t.seller_email
                  AND se.country = t.seller_country
                  AND se.postal_code IS NOT DISTINCT FROM t.seller_postal_code
         JOIN supplier sup
              ON sup.name = t.supplier_name
                  AND sup.contact = t.supplier_contact
                  AND sup.email = t.supplier_email
                  AND sup.phone = t.supplier_phone
                  AND sup.address = t.supplier_address
                  AND sup.city = t.supplier_city
                  AND sup.country = t.supplier_country
         JOIN product p
              ON p.name = t.product_name
                  AND p.category = t.product_category
                  AND p.price = t.product_price
                  AND p.available_quantity = t.product_quantity
                  AND p.weight = t.product_weight
                  AND p.color = t.product_color
                  AND p.size = t.product_size
                  AND p.brand = t.product_brand
                  AND p.material = t.product_material
                  AND p.description = t.product_description
                  AND p.rating = t.product_rating
                  AND p.reviews = t.product_reviews
                  AND p.release_date = t.product_release_date
                  AND p.expiry_date = t.product_expiry_date
                  AND p.supplier_id = sup.id
         JOIN store st
              ON st.name = t.store_name
                  AND st.location = t.store_location
                  AND st.city = t.store_city
                  AND st.state IS NOT DISTINCT FROM t.store_state
                  AND st.country = t.store_country
                  AND st.phone = t.store_phone
                  AND st.email = t.store_email;