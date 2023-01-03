DELIMITER $$
create procedure return_book(
	`title_t` varchar(200),
    `author_t` varchar(200),
    `part_t` int
)
begin
	declare `user` varchar(30);
    declare `id` int;
	if not exists (select `tag` from `global`) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
	else
		set `user` = left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1));
        set `id` = (select `book_id` from `book` where `title` = `title_t` and `author` = `author_t` and `part` = `part_t`);
        if exists (select `request_id` from `requests` where `username` = `user` and `book_id` = `id` and `state` = 'Success') then
			if (current_timestamp > (select `due_date` from `requests` where `username` = `user` and `book_id` = `id` and `state` = 'Success')) then
				insert into `return_history`(`username`, `book_id`, `return_date`, `mode`) 
					values (`user`, `id`, current_timestamp, 0);
				update `Warehouse`
				set `book_count` = `book_count` + 1
				where `book_id` = `id`;
				if ((select count(`return_id`) from `return_history` where (`username` = `user`) AND (`mode` = 0) AND
                (MONTH(`return_date` - current_timestamp) > 2)) > 4) then
					update `account`
					set `banned` = 1
					where `username` = `user_temp`;
                    insert into `ban_list`(`username`,`ban_date`) values (`user`, current_timestamp);
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have been banned!';
                else
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book returned with a warning!';
				end if;
			else
				insert into `return_history`(`username`, `book_id`, `return_date`, `mode`) 
					values (`user`, `id`, current_timestamp, 1);
				update `Warehouse`
				set `book_count` = `book_count` + 1
				where `book_id` = `id`;
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book returned!';
            end if;
        else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You havent borrowed this book';
        end if;
    end if;
END$$
DELIMITER ;

call return_book('wow', 'testo', 1);
drop procedure return_book;