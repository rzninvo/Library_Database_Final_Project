DELIMITER $$
create procedure search_book(
    `title_t` varchar(200),
    `author_t` varchar(200),
    `part_t` int,
    `creation_date_t` datetime
	)
begin
	if not exists (select `tag` from `global`) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
	else
		select * from `book` 
		where `title` = `title_t` or `author` = `author_t` or `part` = `part_t` or `creation_date` = `creation_date_t`
		order by `title`;
	end if;
END$$
DELIMITER ;

call search_book('wow', null, null, null);
delete from warehouse;
drop procedure search_book;