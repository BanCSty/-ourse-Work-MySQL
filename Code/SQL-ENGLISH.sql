-- Create DB `library`
-- ------------------------------------------------------------------------------------------------
CREATE DATABASE library CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE library;

DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS LibraryCards;
DROP TABLE IF EXISTS CopyBooks;
DROP TABLE IF EXISTS CopyBooks1;

-- Создание таблицы "Читательские билеты".
-- -----------------------------------------------------------------------------------------------
Create table library.LibraryCards(
    IDLibCards int default '0000' not null,
    FIO varchar(35) not null,
    PhoneNumber varchar(25) default	'0-000-000-00-00' not null,
    GroupNumber varchar(10) default 'TES-000' not null,
    primary key(IDLibCards)
);

INSERT INTO library.LibraryCards 
VALUES (1125, 'Федин Артем Степанович', '8-912-546-18-21', 'ИВТ-301'),
       (1307, 'Арсентьевна Любовь Михайловна', '8-495-872-31-27', 'БУ-201');

-- Создание таблтцы "Книги"
-- ---------------------------------------------------------------------------------------
create table library.Books(
ISBN varchar(20) default '000-0-000-00000' not null,
FIO_Autor varchar(25) not null,
BookName varchar(15) not null,
YearRelease int default '0000' not null,
Price int not null,
primary key(ISBN)
);

Изменяем размерность колонки с названием книги с 25 по 30.
ALTER table library.books 
ADD column BookName varchar(30) not null after FIO_Autor;

INSERT INTO library.books
VALUES ('978-5-388-00003', 'Иванов Сергей Степанович', 'Самоучитель JAVA', 2018, 300),
       ('978-5-699-58103', 'Сидорова Ольга Юрьевна', 'JAVA за 21 день', 2020, 600),
       ('758-3-057-37854', 'Иванов Сергей Степанович', ' Механика ', 2018, 780),
       ('675-3-423-00375', 'Петров Иван Петрович', 'Физика', 2017, 450);

-- Создадим таблицу "Экземпляр книг" по типу "МНОГИЕ КО МНОГИМ"
-- ----------------------------------------------------------------------------------------
create table library.CopyBooks(
ID int not null,
ISBN varchar(30) not null,
IDLibCards int default null,
foreign key(ISBN) references library.Books(ISBN) on update no action,
foreign key(IDLibCards) references library.LibraryCards(IDLibCards) on update no action
);

INSERT INTO library.CopyBooks
VALUES (1112333, '978-5-388-00003', 1125),
       (1112334, '978-5-388-00003', 1307),
       (1112335, '978-5-699-58103', NULL ),
       (1112336, '978-5-699-58103', 1307);

-- Для реализации связи многие ко многим нам нужен некий посредник между двумя рассматриваемыми таблицами. 
-- Он должен хранить два внешних ключа, первый из которых ссылается на первую таблицу, а второй — на вторую.

-- Создадим и заполним таблицу "Экземпляры книг1"
-- -----------------------------------------------------------------------------------------
create table library.CopyBooks1(
ID int not null,
ISBN varchar(30) not null,
IDLibCards int default null,
primary key(ID));

INSERT INTO library.CopyBooks1
VALUES (2323233, '758-3-057-37854', null),
       (2322323, '675-3-423-00375', null);


-- №4 "INSERT INTO – заполнить таблицу «Экземпляры книг» данными из таблицы «Экземпляры книг1»"
-- ------------------------------------------------------------------------------------------
INSERT INTO library.copybooks
SELECT * FROM library.copybooks1;


-- №5 "DROP – удалить таблицу «Экземпляры книг1»."
-- ------------------------------------------------------------------------------------------
DROP table library.copybooks1;


-- №6 "UPDATE – изменить в поле «Цена» таблицы «Книги», стоимость каждой книги на 20%"
-- ------------------------------------------------------------------------------------------
UPDATE library.books 
SET Price = Price + (Price/100*20);

 
-- №7 "DELETE – удалить книгу, ISBN которой равен 675-3-423-00375 из всех таблиц."
-- ------------------------------------------------------------------------------------------
START transaction;
DELETE FROM library.books WHERE ISBN = '675-3-423-00375';
COMMIT;
-- Удаляем только из таблицы "Книги" т.к. эта таблица является родительской

/*
№8 SELECT – вывести на экран записи, содержащие следующие поля: 
ISBN, ФИО автора, Название книги, Цена для книг, цены которых находится в диапазоне от 400 до 700 рублей.
*/
-- ------------------------------------------------------------------------------------------S
SELECT ISBN, FIO_Autor as 'ФИО Автора', BookName as 'Название книги', Price as 'Цена' from library.books
where Price between 400 and 700;

-- №9 SELECT – после задания № читательского билета, вывести на экран записи, содержащие следующие поля: 
-- № читательского билета, ФИО читателя, № группы, ISBN, Название книги, Цена по каждой книге, взятой этим читателем.
-- ------------------------------------------------------------------------------------------
SET @n = 1307;
SELECT LL.IDLibCards as '№ читательского билета', LL.FIO as 'ФИО', LL.GroupNumber as '№ группы', LB.ISBN, LB.BookName as 'Название книги', LB.Price as 'Цена' FROM library.librarycards as LL
JOIN library.copybooks as LC ON LC.IDLibCards = LL.IDLibCards
JOIN library.books as LB ON LB.ISBN = LC.ISBN
WHERE LL.IDLibCards = @n;


-- №10 "SELECT – вывести на экран записи, содержащие следующие поля: ISBN, ФИО автора, Название книги, Цена, для книг которые находятся в библиотеке."
-- ------------------------------------------------------------------------------------------
SELECT LB.ISBN, LB.FIO_Autor as 'ФИО Автора', LB.BookName as 'Название книги', LB.Price as 'Цена' from library.books as LB 
JOIN library.copybooks as LC ON LB.ISBN = (SELECT LC.ISBN as LC where LC.IDLibCards is null);

-- №11 "SELECT – вывести на экран записи, содержащие следующие поля: 
-- № читатель-ского билета, ФИО читателя, № группы, Количество книг, которое находятся у этого читателя на руках, если это количество не меньше двух"
-- ------------------------------------------------------------------------------------------
SELECT LL.IDLibCards as '№ читатель-ского билета', LL.FIO as 'ФИО Автора', LL.GroupNumber as '№ группы',
(SELECT COUNT(*) from library.copybooks as LC WHERE LL.IDLibCards = LC.IDLibCards Group BY LC.IDLibCards) as COUNT
FROM library.librarycards as LL
GROUP BY LL.IDLibCards HAVING COUNT > 1

-- №12 "SELECT – вывести на экран запись – ISBN, ФИО автора c максимальным количеством экземпляров книг в библиотеке"
-- ------------------------------------------------------------------------------------------
CREATE view S111 as 
 SELECT LB.ISBN, LB.FIO_Autor as 'ФИО автора', count(ID) as COUNTE
 From library.books as LB 
 JOIN library.copybooks as LC ON LB.ISBN = LC.ISBN
 WHERE LC.IDLibCards IS NULL
 Group by LB.ISBN;
 SELECT * FROM S111
 Where S111.COUNTE = (SELECT MAX(COUNTE) FROM S111);

-- №13 "SELECT – вывести на экран записи, содержащие следующие поля: ISBN, ФИО автора, Название книги, Цена, Количество читателей, которые взяли эту книгу."
-- -------------------------------------------------------------------------------------------
SELECT LB.ISBN, LB.FIO_Autor as 'ФИО автора', LB.BookName as 'Название книги', LB.Price as 'Цена', 
(SELECT COUNT(*) FROM library.copybooks as LC where LC.IDLibCards IS NOT NULL AND LC.ISBN = LB.ISBN) as COUNT
from library.books as LB
GROUP BY COUNT, LB.FIO_Autor;

-- №14 "SELECT - вывести на экран запись, содержащую следующие поля: 
-- № читатель-ского билета, ФИО читателя, № группы, Количество взятых книг для читателей, которые взяли их максимальное количество"
-- --------------------------------------------------------------------------------------------
CREATE view library.Test14 as
SELECT LL.IDLibCards as '№ читательского билета', LL.FIO As 'ФИО Читателя', LL.GroupNumber as '№ группы', COUNT(LC.IDLibCards)
FROM library.librarycards as LL
JOIN library.copybooks as LC ON LC.IDLibCards = LL.IDLibCards;

SELECT * FROM Test14
Where Test14.COUNT = (Select MAX(COUNT) FROM Test14);