DELIMITER $$
create procedure search_user(
	`first_name_t` varchar(200),
    `page` int
)
begin
	declare `user` varchar(30);
	if not exists (select `tag` from `global`) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
	else
		set `user` = left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1));
		if not ((select `type` from `account` where `username` = `user`) = 'User') then
			select * from (select *, row_number()
					OVER() AS row_num from `personal_info` where `first_name` = `first_name_t`) as T 
			where row_num between ((`page` - 1) * 5 + 1) and ((`page`) * 5) order by(`last_name`) desc;
        else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied';
        end if;
    end if;
end$$
delimiter ;

drop procedure search_user;
call search_user('roham', 2);