DELIMITER $$
create procedure get_overdue_requests(
)
begin
	declare `user` varchar(30);
	if not exists (select `tag` from `global`) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
	else
		set `user` = left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1));
		if not ((select `type` from `account` where `username` = `user`) = 'User') then
		select * from `return_history` where `username` = `user` AND `mode` = 0;
        else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Access Denied';
        end if;
    end if;
end$$
delimiter ;

drop procedure get_overdue_requests;
call get_overdue_requests();