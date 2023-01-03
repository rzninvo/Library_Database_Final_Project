DELIMITER $$
create procedure insert_book(
	`title_t` varchar(200),
    `genre_t` varchar(20),
    `pages_t` int,
    `price_t` int,
    `creation_date_t` datetime,
    `type_t` varchar(30),
    `author_t` varchar(200),
    `part_t` int,
    `amount` int
)
begin
	declare `user` varchar(30);
    declare `id` int;
	if not exists (select `tag` from `global`) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
	else
		set `user` = left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1));
        set `id` = (select `book_id` from `book` where `title` = `title_t` and `author` = `author_t` and `part` = `part_t`);
		if not ((select `type` from `account` where `username` = `user`) = 'User') then 
            if exists(select `book_id` from `book` where `title` = `title_t` and `author` = `author_t` and `part` = `part_t`) then 
				if exists (select `book_id` from `warehouse` where `book_id` = `id`) then
					update `warehouse`
					set `book_count` = `book_count` + `amount`
					where `book_id` = `id`;
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Books added to warehouse';
				else
					insert into `warehouse`(`book_id`, `part`, `book_count`) 
						values(`id`, `part_t`, `amount`);
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book row added to warehouse';
				end if;
			else
				insert into `book`(`title`, `genre`, `pages`, `price`, `author`, `part`, `creation_date`, `type`) 
					values (`title_t`, `genre_t`, `pages_t`, `price_t`, `author_t`, `part_t`, `creation_date_t`, `type_t`);
				insert into `warehouse`(`book_id`, `part`, `book_count`) 
						values(`id`, `part_t`, `amount`);
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book Added!';
            end if;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied!';
		end if;
    end if;
end$$
delimiter ;

call insert_book('test', 'test', '200', 3000, current_timestamp, 'general', 'test', 1, 200);
call insert_book('test', 'test', '200', 3000, current_timestamp, 'general', 'test', 2, 200);
drop procedure insert_book;