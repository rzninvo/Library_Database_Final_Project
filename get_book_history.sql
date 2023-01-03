DELIMITER $$
create procedure get_book_history(
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
		if not ((select `type` from `account` where `username` = `user`) = 'User') then
			if exists(select `book_id` from `book` where `title` = `title_t` and `author` = `author_t` and `part` = `part_t`) then 
				select * from ((select * from `requests` where `book_id` = `id` and `state` = 'Success') 
                as T natural join (select * from `return_history` where `book_id` = `id`) as B) order by(`request_date`);
			else
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book doesnt exist!';
			end if;
        else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied';
        end if;
    end if;
end$$
delimiter ;

drop procedure get_book_history;
call get_book_history('Wow', 'testo', 1);