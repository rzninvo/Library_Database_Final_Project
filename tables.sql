create table `global`(
	`tag` varchar(100)
);

create table `System_Info`(
    `username` varchar(30) not null,
    `password` binary(32) not null,
    `creation_time` datetime,
    PRIMARY KEY(`username`)
);

create table `Personal_Info`(
    `username` varchar(30),
    `address` varchar(30),
    `first_name` varchar(30) not null,
    `last_name` varchar(30) not null,
    `mode` varchar(30) not null,
    `occupation` varchar(30),
    `student_id` varchar(30),
    `uni_name` varchar(30),
    `instructor_id` varchar(30),
    check (`mode` in ('Person', 'Student', 'Professor')),
    FOREIGN KEY(`username`) REFERENCES `System_Info`(`username`) ON DELETE CASCADE
);

create table `Ban_List`(
	`username` varchar(30),
    `ban_date` datetime
);

create table `Book`(
	`book_id` int not null auto_increment,
    `title` varchar(200),
    `genre` varchar(20),
    `pages` int,
    `price` int,
    `author` varchar(100),
    `part` int,
    `creation_date` datetime,
    `type` varchar(30),
    check (`type` in ('General', 'Academic', 'Reference')),
    PRIMARY KEY (`book_id`)
);

insert into `book`(`title`, `genre`, `pages`, `price`, `author`, `part`, `creation_date`, `type`) values 
	('Kaifuku Jutsushi', 'Psychological', '200', 3000, 'rohamu', 1, current_timestamp, 'Reference')
    , ('Wow', 'Psychological', '200', 2000, 'testo', 1, current_timestamp, 'General')
    ,('Genshin', 'Drama', '300', 1000, 'Hans', 1, current_timestamp, 'General')
    ,('Mathematics I', null, '400', 1500, 'Lele', 1, current_timestamp, 'Academic')
    ,('Mathematics I', null, '400', 1500, 'Lele', 2, current_timestamp, 'Academic')
    ,('Kaifuku Jutsushi', 'psychological', '200', 3000, 'rohamu', 2, current_timestamp, 'Reference');
    
create table `Account`(
	`account_id` int not null AUTO_INCREMENT,
	`username` varchar(30), 
	`balance` int,
    `creation_date` datetime,
    `banned` smallint,
    `type` varchar(30),
	check (`type` in ('User', 'Employee', 'Manager')),
	FOREIGN KEY(`username`) REFERENCES `System_Info`(`username`) ON DELETE CASCADE,
	PRIMARY KEY(`account_id`)
);

create table `System_History`(
	`message_id` int not null auto_increment,
	`message` varchar(200),
    primary key(`message_id`)
);

create table `Return_History`(
	`return_id` int not null auto_increment,
    `username` varchar(30),
    `book_id` int,
    `return_date` datetime,
    `mode` int,
    primary key(`return_id`),
    FOREIGN KEY(`username`) REFERENCES `System_Info`(`username`) ON DELETE CASCADE,
    FOREIGN KEY(`book_id`) REFERENCES `Book`(`book_id`)
);

create table `Requests`(
	`request_id` int not null AUTO_INCREMENT,
	`username` varchar(30),
    `book_id` int,
    `request_date` datetime,
    `due_date` datetime,
    `state` varchar(30),
    primary key(`request_id`),
	check (`state` in ('Success', 'Book not available', 'Insufficient Balance', 'Banned')),
	FOREIGN KEY(`username`) REFERENCES `System_Info`(`username`) ON DELETE CASCADE,
    FOREIGN KEY(`book_id`) REFERENCES `Book`(`book_id`)
);

create table `Warehouse`(
	`book_id` int,
    `book_count` int, 
    `part` int,
     FOREIGN KEY(`book_id`) REFERENCES `Book`(`book_id`) ON DELETE CASCADE
);


delimiter $$
create trigger request_trigger  after INSERT on `requests`
for each row
begin
	declare `temp` varchar(300);
	if (NEW.`state` = 'Success') then
		set `temp` = 'At ';
		set `temp` = concat(`temp`, NEW.`request_date`);
		set `temp` = concat(`temp`, ' User ');
		set `temp` = concat(`temp`, NEW.`username`);
        set `temp` = concat(`temp`, ' requested book ');
        set `temp` = concat(`temp`, NEW.`book_id`);
        set `temp` = concat(`temp`, ' successfuly!');
		insert into `system_history`(`message`)
			values(`temp`);
	end if;
end$$
delimiter ;

delimiter $
create trigger return_trigger  after INSERT on `return_history`
for each row
begin
	declare `temp` varchar(300);
	set `temp` = 'At ';
	set `temp` = concat(`temp`, NEW.`return_date`);
	set `temp` = concat(`temp`, ' User ');
	set `temp` = concat(`temp`, NEW.`username`);
	set `temp` = concat(`temp`, ' returned book ');
	set `temp` = concat(`temp`, NEW.`book_id`);
	set `temp` = concat(`temp`, ' successfuly!');
	insert into `system_history`(`message`)
		values(`temp`);
end$
delimiter ;

insert into `warehouse`(`book_id`, `book_count`, `part`)
	values ( 1, 1000, 1);
insert into `warehouse`(`book_id`, `book_count`, `part`)
	values ( 2, 1000, 1);
select * from `requests`;
select * from `return_history`;
select * from `warehouse`;
select * from `ban_list`;
select * from `system_history`;
select * from `book`;
#delete from `requests`;
#delete from `return_history`;
insert into `System_Info`(`username`,`password`,`creation_time`) values ('admin',AES_ENCRYPT(cast('admin' as binary(16)),'kekw'),CURRENT_TIMESTAMP);
insert into `Personal_Info`(`username`, `address`, `first_name`, `last_name`, `mode`, `occupation`, `student_id`, `uni_name`, `instructor_id`)
	values('admin', 'near_you', 'dulbayop', 'kurshif', 'Person', 'Nothing', null, null, null);
insert into `Account`(`username`, `balance`, `creation_date`, `type`) values ('admin', 0, current_timestamp, 'Manager');