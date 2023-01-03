DELIMITER $$
create procedure get_successful_requests(
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
					OVER() AS row_num from `requests` where `state` = 'Success') as T
            where row_num between ((`page` - 1) * 5 + 1) and ((`page`) * 5) order by(`request_date`) desc;
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied';
        end if;
    end if;
end$$
delimiter ;

drop procedure get_successful_requests;
call get_successful_requests(2);