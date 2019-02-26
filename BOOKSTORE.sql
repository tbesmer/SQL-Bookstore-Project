-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema bookstore
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema bookstore
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `bookstore` DEFAULT CHARACTER SET utf8 ;
USE `bookstore` ;

-- -----------------------------------------------------
-- Table `bookstore`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`customer` (
  `idcustomer` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cfirstname` VARCHAR(373) NOT NULL COMMENT 'The longest first name is 373 characters long.',
  `clastname` VARCHAR(765) NOT NULL COMMENT 'The longest last name extant is 764 characters long.',
  `cphone` VARCHAR(15) NULL COMMENT '15 characters to account for 1 800 and international phone numbers.',
  `cemail` VARCHAR(255) NULL COMMENT '255 is the longest an email can be. It is this long so the email isn\'t truncated.',
  PRIMARY KEY (`idcustomer`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`employee` (
  `employeeid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `fname` VARCHAR(373) NOT NULL,
  `lname` VARCHAR(765) NOT NULL,
  `salary` DOUBLE NOT NULL COMMENT 'Money should be really handled by decimal but a 1 cent difference in salary is inconsequential.',
  PRIMARY KEY (`employeeid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`location`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`location` (
  `addressid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `city` VARCHAR(60) NOT NULL COMMENT 'The longest city name in english is 58 letters.',
  `state` VARCHAR(2) NOT NULL COMMENT 'The two letter abbreviation of the state.',
  `street` VARCHAR(100) NOT NULL COMMENT 'The longest street name in english is 85 chacacters long. Addign 15 characters for street, avenue, boulevard etc.',
  PRIMARY KEY (`addressid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`status` (
  `idstatus` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `status_of_order` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idstatus`),
  UNIQUE INDEX `status_of_order_UNIQUE` (`status_of_order` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`payment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`payment` (
  `idpayment` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Creditcardnumber` INT UNSIGNED NOT NULL,
  `expiredate` DATE NOT NULL,
  `nameoncard` VARCHAR(2000) NOT NULL,
  `verifcatitiondigit` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`idpayment`))
ENGINE = InnoDB;
 

-- -----------------------------------------------------
-- Table `bookstore`.`order`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`order` (
  `idorder` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `employee_employeeid` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'If the employee is deleted it will be set to default at int 1. This would be a row that holds orders until a program can divvy accumulated employeeless orders.',
  `customer_idcustomer` INT UNSIGNED NOT NULL,
  `employee_employeeid_manager` INT UNSIGNED NULL COMMENT 'The relational database can not enforce the business rule that a order is given a manager. ',
  `location_billing_id` INT UNSIGNED NOT NULL DEFAULT 1,
  `location_shipping_id` INT UNSIGNED NOT NULL DEFAULT 1,
  `status_idstatus` INT UNSIGNED NOT NULL DEFAULT 1,
  `payment_idpayment` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`idorder`),
  INDEX `fk_order_employee1_idx` (`employee_employeeid` ASC),
  INDEX `fk_order_customer1_idx` (`customer_idcustomer` ASC),
  INDEX `fk_order_employee2_idx` (`employee_employeeid_manager` ASC),
  INDEX `fk_order_location1_idx` (`location_billing_id` ASC),
  INDEX `fk_order_location2_idx` (`location_shipping_id` ASC),
  INDEX `fk_order_status1_idx` (`status_idstatus` ASC),
  UNIQUE INDEX `employee_employeeid_UNIQUE` (`employee_employeeid` ASC),
  INDEX `fk_order_payment1_idx` (`payment_idpayment` ASC),
  CONSTRAINT `fk_order_employee1`
    FOREIGN KEY (`employee_employeeid`)
    REFERENCES `bookstore`.`employee` (`employeeid`)
    ON DELETE restrict 
    ON UPDATE cascade, #Inno db does not allow default on delete. Thus we will restict delete and have a program delete the parent after the program updates all children
  CONSTRAINT `fk_order_customer1`
    FOREIGN KEY (`customer_idcustomer`)
    REFERENCES `bookstore`.`customer` (`idcustomer`)
    ON DELETE cascade
    ON UPDATE cascade,## Deleting the customer will also delete the order. Changeing the customer will change the customer stored in order
  CONSTRAINT `fk_order_employee2`
    FOREIGN KEY (`employee_employeeid_manager`)
    REFERENCES `bookstore`.`employee` (`employeeid`)
    ON DELETE set null
    ON UPDATE cascade,## As we have to manually add managers to orders anyway when we delete we set it to null. When we update employee we also update employee in this table
  CONSTRAINT `fk_order_location1`
    FOREIGN KEY (`location_billing_id`)
    REFERENCES `bookstore`.`location` (`addressid`)
    ON DELETE restrict
    ON UPDATE cascade,#We can not delete the location as we are billing it currently. We can update it though
  CONSTRAINT `fk_order_location2`
    FOREIGN KEY (`location_shipping_id`)
    REFERENCES `bookstore`.`location` (`addressid`)
    ON DELETE restrict
    ON UPDATE cascade,#Restrict deleting this location as we are shipping it there
  CONSTRAINT `fk_order_status1`
    FOREIGN KEY (`status_idstatus`)
    REFERENCES `bookstore`.`status` (`idstatus`)
    ON DELETE restrict
    ON UPDATE cascade,#We do not allow deletion as there is important information we do not want to lose.
  CONSTRAINT `fk_order_payment1`
    FOREIGN KEY (`payment_idpayment`)
    REFERENCES `bookstore`.`payment` (`idpayment`)
    ON DELETE restrict
    ON UPDATE cascade)##We do not want to lose payment iformation. We wait until we have nw information before deleting it.
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`book` (
  `isbn` INT UNSIGNED NOT NULL COMMENT 'Unsigned because there exists no isbn that is negative. Number constraint can not be give because isbn varys in length. Isbn is primary key because it is unique to every book.',
  `title` VARCHAR(4805) NOT NULL COMMENT 'The reason for 4805 is because that is the longest book title extant.',
  `edition` VARCHAR(100) NULL,
  `quantity` INT NOT NULL,
  `price` DECIMAL(8,2) NOT NULL COMMENT 'This is because double can\'t accuratly record monetary numbers. Ideally in a real bookstore price would also be held in the table linking book and order.',
  `year` YEAR NOT NULL,
  PRIMARY KEY (`isbn`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`author`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`author` (
  `authorid` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `fname` VARCHAR(373) NOT NULL,
  `lname` VARCHAR(765) NOT NULL,
  PRIMARY KEY (`authorid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`cart`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`cart` (
  `cartID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `datecreated` DATE NOT NULL,
  `datelastupdated` DATE NULL,
  `customer_idcustomer` INT UNSIGNED NOT NULL,
  `location_billing_id` INT UNSIGNED NOT NULL DEFAULT 1,
  `location_shipping_id` INT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`cartID`),
  INDEX `fk_cart_customer1_idx` (`customer_idcustomer` ASC),
  INDEX `fk_cart_location1_idx` (`location_billing_id` ASC),
  INDEX `fk_cart_location2_idx` (`location_shipping_id` ASC),
  CONSTRAINT `fk_cart_customer1`
    FOREIGN KEY (`customer_idcustomer`)
    REFERENCES `bookstore`.`customer` (`idcustomer`)
   ON DELETE cascade
    ON UPDATE cascade,## Deleting the customer will also delete the order. Changeing the customer will change the customer stored in cart
  CONSTRAINT `fk_cart_location1`
    FOREIGN KEY (`location_billing_id`)
    REFERENCES `bookstore`.`location` (`addressid`)
    ON DELETE restrict
    ON UPDATE cascade,
  CONSTRAINT `fk_cart_location2`
    FOREIGN KEY (`location_shipping_id`)
    REFERENCES `bookstore`.`location` (`addressid`)
    ON DELETE restrict
    ON UPDATE cascade)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`book_has_author`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`book_has_author` (
  `book_isbn` INT UNSIGNED NOT NULL,
  `author_authorid` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`book_isbn`, `author_authorid`),
  INDEX `fk_book_has_author_book1_idx` (`book_isbn` ASC),
  INDEX `fk_book_has_author_author1_idx` (`author_authorid` ASC),
  CONSTRAINT `fk_book_has_author_book1`
    FOREIGN KEY (`book_isbn`)
    REFERENCES `bookstore`.`book` (`isbn`)
    ON DELETE restrict
    ON UPDATE cascade,
  CONSTRAINT `fk_book_has_author_author1`
    FOREIGN KEY (`author_authorid`)
    REFERENCES `bookstore`.`author` (`authorid`)
    ON DELETE restrict
    ON UPDATE cascade)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`book_has_order`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`book_has_order` (
  `book_isbn` INT UNSIGNED NOT NULL,
  `order_idorder` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`book_isbn`, `order_idorder`),
  INDEX `fk_book_has_order_order1_idx` (`order_idorder` ASC),
  INDEX `fk_book_has_order_book1_idx` (`book_isbn` ASC),
  CONSTRAINT `fk_book_has_order_book1`
    FOREIGN KEY (`book_isbn`)
    REFERENCES `bookstore`.`book` (`isbn`)
    ON DELETE restrict
    ON UPDATE cascade,
  CONSTRAINT `fk_book_has_order_order1`
    FOREIGN KEY (`order_idorder`)
    REFERENCES `bookstore`.`order` (`idorder`)
    ON DELETE cascade
    ON UPDATE cascade)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`book_has_cart1`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`book_has_cart1` (
  `book_isbn` INT UNSIGNED NOT NULL,
  `cart_cartID` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`book_isbn`, `cart_cartID`),
  INDEX `fk_book_has_cart1_cart1_idx` (`cart_cartID` ASC),
  INDEX `fk_book_has_cart1_book1_idx` (`book_isbn` ASC),
  CONSTRAINT `fk_book_has_cart1_book1`
    FOREIGN KEY (`book_isbn`)
    REFERENCES `bookstore`.`book` (`isbn`)
    ON DELETE cascade
    ON UPDATE cascade,##cart is not important enough to restrict deleting the book
  CONSTRAINT `fk_book_has_cart1_cart1`
    FOREIGN KEY (`cart_cartID`)
    REFERENCES `bookstore`.`cart` (`cartID`)
    ON DELETE cascade
    ON UPDATE cascade)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`category` (
  `idcategory` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`idcategory`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`publisher`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`publisher` (
  `idpublisher` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `publisher_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idpublisher`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`category_has_book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`category_has_book` (
  `category_idcategory` INT UNSIGNED NOT NULL,
  `book_isbn` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`category_idcategory`, `book_isbn`),
  INDEX `fk_category_has_book_book1_idx` (`book_isbn` ASC),
  INDEX `fk_category_has_book_category1_idx` (`category_idcategory` ASC),
  CONSTRAINT `fk_category_has_book_category1`
    FOREIGN KEY (`category_idcategory`)
    REFERENCES `bookstore`.`category` (`idcategory`)
    ON DELETE restrict
    ON UPDATE cascade,##Book is important enough to restrict deleting categories
  CONSTRAINT `fk_category_has_book_book1`
    FOREIGN KEY (`book_isbn`)
    REFERENCES `bookstore`.`book` (`isbn`)
    ON DELETE cascade
    ON UPDATE cascade)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`publisher_has_book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookstore`.`publisher_has_book` (
  `publisher_idpublisher` INT UNSIGNED NOT NULL,
  `book_isbn` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`publisher_idpublisher`, `book_isbn`),
  INDEX `fk_publisher_has_book_book1_idx` (`book_isbn` ASC),
  INDEX `fk_publisher_has_book_publisher1_idx` (`publisher_idpublisher` ASC),
  CONSTRAINT `fk_publisher_has_book_publisher1`
    FOREIGN KEY (`publisher_idpublisher`)
    REFERENCES `bookstore`.`publisher` (`idpublisher`)
    ON DELETE restrict
    ON UPDATE cascade,##Book is important enough to restrict the deletion of it's publisher 
  CONSTRAINT `fk_publisher_has_book_book1`
    FOREIGN KEY (`book_isbn`)
    REFERENCES `bookstore`.`book` (`isbn`)
    ON DELETE cascade
    ON UPDATE cascade)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;






select * from publisher;





INSERT INTO publisher (idpublisher, publisher_name) VALUES (NULL, 'AAA'),(NULL, 'BBB'),(NULL, 'CCC'),(NULL, 'DDD');

select * from publisher;
select * from employee;

INSERT INTO employee (employeeid, fname, lname, salary) VALUES (null,'John','Jameson',50000),(null,'Alex','Johan',45000),(null,'Max','Von Hapsburg',50000),(null,'Jacob','Jingleheimer',500000),(null,'Jon','Wilson',55000);

select * from publisher;


select * from category;
INSERT INTO category (idcategory, category) VALUES (NULL, 'Fantasy'),(NULL, 'Nonfiction'),(NULL, 'Romance'),(NULL, 'Adventure');

select * from book;
INSERT INTO `bookstore`.`book` (`isbn`, `title`, `edition`, `quantity`, `price`, `year`) VALUES ('12422', 'A tale of three and a half cities', 'first edition', '45', '400', 1996);

select * from book;
INSERT INTO `bookstore`.`book` (`isbn`, `title`, `edition`, `quantity`, `price`, `year`) VALUES ('12434', 'Cat in the hat', 'first edition', '121', '40.50', 1996);
INSERT INTO `bookstore`.`book` (`isbn`, `title`, `edition`, `quantity`, `price`, `year`) VALUES ('58879', 'Romeo, Juliet, and Chuck Testa', 'Third Edition, Revised', '2000', '2000.14', 2016);
INSERT INTO `bookstore`.`book` (`isbn`, `title`, `edition`, `quantity`, `price`, `year`) VALUES ('49960', 'Famous Chicken and more chicken', 'Chicken Edition', '2', '1.99', 2015);
INSERT INTO `bookstore`.`book` (`isbn`, `title`, `edition`, `quantity`, `price`, `year`) VALUES ('30059', 'War and Peace', 'Pacifist Edition', '0', '1.21', 1914);
INSERT INTO `bookstore`.`book` (`isbn`, `title`, `edition`, `quantity`, `price`, `year`) VALUES ('06954', 'Peasant of the Necklace', 'Blatant Rip off Edition', '2', '19.99', 2004);

select * from customer;

INSERT INTO `bookstore`.`customer` (`idcustomer`, `cfirstname`, `clastname`, `cphone`, `cemail`) VALUES (null, 'Charles ', 'Carmal', '7043434343', 'realJackBlack@aol.com');
INSERT INTO `bookstore`.`customer` (`idcustomer`, `cfirstname`, `clastname`, `cphone`, `cemail`) VALUES (null, 'Jimmy', 'Carter', '35422443', 'Jimmy@us.gov');
INSERT INTO `bookstore`.`customer` (`idcustomer`, `cfirstname`, `clastname`, `cphone`, `cemail`) VALUES (null, 'Ronald', 'Reagan', '30598585', 'RR@heaven.hv');
INSERT INTO `bookstore`.`customer` (`idcustomer`, `cfirstname`, `clastname`, `cphone`, `cemail`) VALUES (null, 'Gerald', 'Ford', '384868', 'GF@heaven.hv');


select * from author;
INSERT INTO `bookstore`.`author` (`fname`, `lname`) VALUES ('Jacob', 'Lawrence');
INSERT INTO `bookstore`.`author` (`fname`, `lname`) VALUES ('Barry', 'Goldwater');

select * from payment;
INSERT INTO `bookstore`.`payment` (`Creditcardnumber`, `expiredate`, `nameoncard`, `verifcatitiondigit`) VALUES ('234567', '2017-02-01', 'Jim Jacob', '453');
INSERT INTO `bookstore`.`payment` (`Creditcardnumber`, `expiredate`, `nameoncard`, `verifcatitiondigit`) VALUES ('345434', '2018-05-01', 'Alexander Bell', '123');
INSERT INTO `bookstore`.`payment` (`Creditcardnumber`, `expiredate`, `nameoncard`, `verifcatitiondigit`) VALUES ('315155', '4001-11-01', 'Zeus', '445');

select * from location;
INSERT INTO `bookstore`.`location` (`city`, `state`, `street`) VALUES ('Charlotte', 'NC', 'Jacob St');
INSERT INTO `bookstore`.`location` (`city`, `state`, `street`) VALUES ('Rockhill', 'SC', 'Vierra St');
INSERT INTO `bookstore`.`location` (`city`, `state`, `street`) VALUES ('Concord', 'NC', 'Lexington Rd');
INSERT INTO `bookstore`.`location` (`city`, `state`, `street`) VALUES ('Lexington', 'NC', 'Mary Alexander Avenue');

select * from category;
select * from book;
select * from category_has_book;
INSERT INTO `bookstore`.`category_has_book` (`category_idcategory`, `book_isbn`) VALUES ('1', '6954');
INSERT INTO `bookstore`.`category_has_book` (`category_idcategory`, `book_isbn`) VALUES ('2', '12434');
INSERT INTO `bookstore`.`category_has_book` (`category_idcategory`, `book_isbn`) VALUES ('1', '30059');
INSERT INTO `bookstore`.`category_has_book` (`category_idcategory`, `book_isbn`) VALUES ('2', '49960');
INSERT INTO `bookstore`.`category_has_book` (`category_idcategory`, `book_isbn`) VALUES ('3', '58879');
INSERT INTO `bookstore`.`category_has_book` (`category_idcategory`, `book_isbn`) VALUES ('1', '58879');

select * from book;
select * from publisher;
select * from publisher_has_book;
INSERT INTO `bookstore`.`publisher_has_book` (`publisher_idpublisher`, `book_isbn`) VALUES ('1', '6954');
INSERT INTO `bookstore`.`publisher_has_book` (`publisher_idpublisher`, `book_isbn`) VALUES ('3', '12434');
INSERT INTO `bookstore`.`publisher_has_book` (`publisher_idpublisher`, `book_isbn`) VALUES ('2', '30059');
INSERT INTO `bookstore`.`publisher_has_book` (`publisher_idpublisher`, `book_isbn`) VALUES ('3', '49960');
INSERT INTO `bookstore`.`publisher_has_book` (`publisher_idpublisher`, `book_isbn`) VALUES ('2', '58879');

select * from book;
select * from author;
select * from book_has_author;
INSERT INTO `bookstore`.`book_has_author` (`book_isbn`, `author_authorid`) VALUES ('6954', '1');
INSERT INTO `bookstore`.`book_has_author` (`book_isbn`, `author_authorid`) VALUES ('12434', '2');
INSERT INTO `bookstore`.`book_has_author` (`book_isbn`, `author_authorid`) VALUES ('30059', '2');
INSERT INTO `bookstore`.`book_has_author` (`book_isbn`, `author_authorid`) VALUES ('49960', '1');
INSERT INTO `bookstore`.`book_has_author` (`book_isbn`, `author_authorid`) VALUES ('58879', '2');

select * from customer;
select * from location;
select * from cart;
INSERT INTO `bookstore`.`cart` (`datecreated`, `datelastupdated`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`) VALUES ('2016-06-12', NULL, '6', '3', '3');
INSERT INTO `bookstore`.`cart` (`datecreated`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`) VALUES ('1998-08-05', '4', '1', '1');
INSERT INTO `bookstore`.`cart` (`datecreated`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`) VALUES ('1997-08-04', '5', '2', '2');
INSERT INTO `bookstore`.`cart` (`datecreated`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`) VALUES ('2003-04-19', '7', '4', '4');
##We can update carts
UPDATE `bookstore`.`cart` SET `datelastupdated`='2016-11-11' WHERE `cartID`='3';

select * from status;
INSERT INTO `bookstore`.`status` (`status_of_order`) VALUES ('Delivered');
INSERT INTO `bookstore`.`status` (`status_of_order`) VALUES ('Back Order');
INSERT INTO `bookstore`.`status` (`status_of_order`) VALUES ('Out of Stock');
INSERT INTO `bookstore`.`status` (`status_of_order`) VALUES ('Cancelled');
INSERT INTO `bookstore`.`status` (`status_of_order`) VALUES ('Alien Invasion -- ON HOLD');

select * from `order`;
select * from employee;
select * from cart;
select * from payment;
INSERT INTO `bookstore`.`order` (`employee_employeeid`, `customer_idcustomer`, `employee_employeeid_manager`, `location_billing_id`, `location_shipping_id`, `status_idstatus`, `payment_idpayment`) VALUES ('3', '7', '1', '3', '3', '3', '3');
INSERT INTO `bookstore`.`order` (`employee_employeeid`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`, `status_idstatus`, `payment_idpayment`) VALUES ('5', '5', '1', '1', '2', '2');
INSERT INTO `bookstore`.`order` (`employee_employeeid`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`, `status_idstatus`, `payment_idpayment`) VALUES ('2', '4', '2', '2', '4', '3');
INSERT INTO `bookstore`.`order` (`employee_employeeid`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`, `status_idstatus`, `payment_idpayment`) VALUES ('4', '6', '4', '4', '1', '1');

select * from book_has_order;
INSERT INTO `bookstore`.`book_has_order` (`book_isbn`, `order_idorder`) VALUES ('6954', '3');
INSERT INTO `bookstore`.`book_has_order` (`book_isbn`, `order_idorder`) VALUES ('12434', '4');
INSERT INTO `bookstore`.`book_has_order` (`book_isbn`, `order_idorder`) VALUES ('30059', '1');
INSERT INTO `bookstore`.`book_has_order` (`book_isbn`, `order_idorder`) VALUES ('30059', '2');

#Able to show prices.
select * 
from book
where price>100;
#Shows quantity
select title, quantity 
from book
where price > 20;

##List book information (e.g., title, author, price) 
select *
from book
left outer join book_has_author
on book.isbn = book_has_author.book_isbn
left outer join author
on book_has_author.author_authorid = author.authorid
where fname= 'jacob';

##List information about those orders assigned to him/her (Employee) in this case employee id number 3
select *
from `order`
left outer join location
on location.addressid = `order`.location_billing_id and location.addressid = `order`.location_shipping_id
left outer join payment
on payment.idpayment = `order`.payment_idpayment
left outer join `status`
on `status`.idstatus = `order`.status_idstatus
where employee_employeeid = 3;

## Shows that we can update order status
select * from `order`;
update `order`
set status_idstatus = 1
where idorder = 1;
select * from `order`;

##Adding books to a shopping cart is as simple as inserting a relation into cart_has_book


##Creating new empty cart
Select * from cart;
INSERT INTO `bookstore`.`cart` (`datecreated`, `customer_idcustomer`, `location_billing_id`, `location_shipping_id`) VALUES ('2016-12-12', '1', '1', '1');
Select * from cart;

## Merge shopping cart
## I would merge shopping carts in java. I would select all information from the row that would be absorbed. Store that in the java program. Delete the absorbed row. Insert any books that need to be inserted in the absorbing row.

## I would use java to create new orders from cart. I would select the cart id and insert a new order with the values from that cart and the cart has orders that it has.


##I would use a program like java to handle new user creation, login and updates.

## I would use a program to insert new books it would look the same as the inserts into book above.alter

##I would have a program monitor the price of orders so that managers would be assigned to orders there is no way that I know of to do that in a relational database. 







