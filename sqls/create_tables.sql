-- Create table for the main car brand
CREATE TABLE car_brand
(
    bid              uuid PRIMARY KEY,
    name             VARCHAR(255) NOT NULL,
    country          VARCHAR(255),
    country_code     VARCHAR(10),
    country_logo_url VARCHAR(255),
    brand_logo_url   VARCHAR(255),
    year             VARCHAR(50)
);

-- Create table for car series
CREATE TABLE car_series
(
    sid          uuid PRIMARY KEY,
    name         VARCHAR(255) NOT NULL,
    year         VARCHAR(50),
    img_url      VARCHAR(255),
    seats        VARCHAR(50),
    chassis      VARCHAR(50),
    engine_types VARCHAR(255),
    category     VARCHAR(50),
    bid          uuid         NOT NULL,
    FOREIGN KEY (bid) REFERENCES car_brand (bid)
);
