DELIMITER $$
create procedure get_book(
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
        if ((select `mode` from `Personal_Info` where `username` = `user`) = 'Professor') 
			OR ((select `mode` from `Personal_Info` where `username` = `user`) = 'Student' AND ((select `type` from `book` where `book_id` = `id`) = 'General' OR 
            (select `type` from `book` where `book_id` = `id`) = 'Academic'))
			OR ((select `mode` from `Personal_Info` where `username` = `user`) = 'Student' AND (select `type` from `book` where `book_id` = `id`) = 'General')
		then
			if not exists (select * from `book` where `title` = `title_t` and `author` = `author_t` and `part` = `part_t`) then
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book Doesnt Exist!';
            else
					if (select `banned` from `account` where `username` = `user`) = 1 then
						insert into `requests`(`username`, `book_id`, `request_date`, `due_date`, `state`)
									values(`user`, `id`, current_timestamp, null, 'Banned');
						SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are banned';
					else
						if (select `book_count` from `warehouse` where `book_id` = `id`) > 0 then
							if ((select `price` from `book` where `book_id` = `id`) / 20) <= (select `balance` from `account` where  `username` = `user`) then
								update `Warehouse`
									set `book_count` = `book_count` - 1
								where `book_id` = `id`;
								update `account` 
								set `balance` = `balance` - ((select `price` from `book`where`book_id` = `id`) / 20) 
								where `username` = `user`;
								insert into `requests`(`username`, `book_id`, `request_date`, `due_date`, `state`)
									values(`user`, `id`, current_timestamp, DATE_ADD(current_timestamp, INTERVAL 2 MONTH), 'Success');
							else
								insert into `requests`(`username`, `book_id`, `request_date`, `due_date`, `state`)
									values(`user`, `id`, current_timestamp, null, 'Insufficient Balance');
								SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not Enough Balance!';
							end if;
						else
							insert into `requests`(`username`, `book_id`, `request_date`, `due_date`, `state`)
									values(`user`, `id`, current_timestamp, null, 'Book not available');
							SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No more of this book in the warehouse';
						end if;
					end if;
            end if;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cant access this book';
        end if;
    end if;
END$$
DELIMITER ;

drop procedure get_book;
call get_book('Wow', 'testo', 1);
delete from `requests`