-- Membuat basis data
CREATE DATABASE IF NOT EXISTS walmartSales;
use walmartSales;

-- pratinjau data
select * from sales limit 10;

-- Membuat tabel
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12, 4),
    rating FLOAT
);

-- --------------------------------------Feature Engineering--------------------------------------------------------------

-- waktu dalam sehari

-- uji kolom
SELECT time,
	(
		CASE
			WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
			WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
			ELSE "Evening"
		END
    ) AS time_of_day
FROM sales;

-- buat kolom waktu dalam sehari
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- masukkan data ke dalam kolom waktu dalam sehari

UPDATE sales
	SET time_of_day = (
		CASE
			WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
			WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
			ELSE "Evening"
		END
    );
    
-- -------------------------------------------------------------------------------------------------------------

-- nama hari

-- uji kolom
SELECT date,DAYNAME(`date`) AS day_name
FROM sales;

-- buat kolom waktu dalam sehari
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

-- masukkan data ke dalam kolom waktu dalam sehari

UPDATE sales
	SET day_name = DAYNAME(`date`);

-- -------------------------------------------------------------------------------------------------------------

-- nama bulan

-- uji kolom
SELECT date,MONTHNAME(`date`) AS day_name
FROM sales;

-- buat kolom waktu dalam sehari
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

-- masukkan data ke dalam kolom waktu dalam sehari

UPDATE sales
	SET month_name = MONTHNAME(`date`);
    
-- -------------------------------------------------------------------------------------------------------------	
-- EDA

-- Berapa banyak kota unik yang terdapat dalam data tersebut?
SELECT COUNT(DISTINCT city) AS cities FROM sales;

-- Di kota mana masing-masing cabang berada?
SELECT COUNT(DISTINCT branch) AS '#cities' FROM sales;

-- Berapa banyak lini produk unik yang dimiliki data tersebut?
SELECT COUNT(DISTINCT product_line) AS '#products' FROM sales;

-- Apa metode pembayaran yang paling umum?
select payment,count(payment) as count from sales group by payment order by count desc limit 1;

-- Produk mana yang paling laris?
select product_line,count(product_line) as count from sales group by product_line order by count desc limit 1;

-- Berapakah total pendapatan per bulan?
select month_name, sum(total) as total_revenue from sales group by month_name order by total_revenue desc;

-- Bulan apa yang memiliki harga pokok penjualan (COGS) terbesar?
select month_name, max(cogs) as largest_COGS from sales group by month_name order by largest_COGS desc limit 1;


-- Lini produk mana yang menghasilkan pendapatan terbesar?
select product_line, sum(total) as total_revenue from sales group by product_line order by total_revenue desc limit 1;

-- Kota manakah yang memiliki pendapatan terbesar?
select city, sum(total) as total_revenue from sales group by city order by total_revenue desc limit 1;

-- Lini produk mana yang memiliki PPN terbesar?
select product_line, sum(tax_pct) as total_vat from sales group by product_line order by total_vat desc limit 1;

-- Ambil setiap lini produk dan tambahkan kolom pada lini produk tersebut yang menunjukkan "Baik" dan "Buruk". Baik jika penjualannya lebih tinggi dari rata-rata.

select product_line, sum(total) as avg_qnty, (
case
	when  sum(total)> (select avg(total) from sales) then "good"
    else "bad"
end
) as review
from sales group by product_line;

-- Cabang mana yang menjual lebih banyak produk daripada rata-rata penjualan produk?
select branch, sum(quantity) as total_sale_qnty from sales group by branch having total_sale_qnty>(select avg(quantity) from sales);

-- Apa lini produk yang paling umum berdasarkan jenis kelamin? 
(select gender,count(gender)as count,product_line  from sales group by gender,product_line having gender="male" order by count desc limit 1)
union 
(select gender,count(gender)as count,product_line  from sales group by gender,product_line having gender="female" order by count desc limit 1);

-- Berapakah rata-rata peringkat untuk setiap lini produk?
select product_line, round(avg(rating),2) as average_rating from sales group by product_line order by average_rating desc;

-- Number of sales made in each time of the day
select time_of_day, count(total) from sales group by time_of_day;

-- Dari berbagai jenis pelanggan, manakah yang menghasilkan pendapatan terbanyak?
select customer_type, sum(total) as total_revenue from sales group by customer_type order by total_revenue desc limit 1;

-- Kota manakah yang memiliki persentase pajak/PPN (Pajak Pertambahan Nilai) tertinggi?
select city, max(tax_pct) largest_tax from sales group by city order by largest_tax desc limit 1;
 
-- Jenis pelanggan mana yang membayar PPN paling banyak?
select customer_type, round(sum(tax_pct),2) as total_tax from sales group by customer_type order by total_tax desc limit 1;

-- Ada berapa tipe pelanggan unik yang terdapat dalam data tersebut?
select count(distinct customer_type) from sales;

-- Berapa banyak metode pembayaran unik yang dimiliki data tersebut?
select count(distinct payment) from sales;

-- Apa tipe pelanggan yang paling umum?
select customer_type, count(*) as  count from sales group by customer_type order by count desc limit 1;

-- Tipe pelanggan mana yang paling banyak membeli?
select customer_type, sum(quantity) as  count from sales group by customer_type order by count desc limit 1;

-- Apa jenis kelamin sebagian besar pelanggan?
select gender, count(*) as  count from sales group by gender order by count desc limit 1;

-- Bagaimana distribusi gender per cabang?
select branch, gender, count(*) from sales group by gender, branch order by branch;

-- Pada jam berapa pelanggan memberikan peringkat terbanyak?
select time_of_day, round(sum(rating),2) as total_rating from sales group by time_of_day order by total_rating desc limit 1;

-- Pada jam berapa pelanggan memberikan peringkat terbanyak untuk setiap cabang?
select branch, time_of_day, round(sum(rating),2) as total_ratings from sales group by time_of_day, branch order by branch, total_ratings desc;

-- Hari apa dalam seminggu yang memiliki peringkat rata-rata terbaik?
select day_name, avg(rating) as avg_rating from sales group by day_name order by avg_rating desc limit 1;

-- Hari apa dalam seminggu yang memiliki peringkat rata-rata terbaik per cabang?
(select branch,day_name,max(rating) as best_rating from sales group by day_name,branch having branch="A" order by branch,best_rating desc limit 1)
union
(select branch,day_name,max(rating) as best_rating from sales group by day_name,branch having branch="B" order by branch,best_rating desc limit 1)
union
(select branch,day_name,max(rating) as best_rating from sales group by day_name,branch having branch="C" order by branch,best_rating desc limit 1)