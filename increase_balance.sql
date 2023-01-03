DELIMITER $$
create procedure increase_balance(
	`amount` int
)
begin
	declare `user` varchar(30);
	if not exists (select `tag` from `global`) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
	else
		set `user` = left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1));
        if (not amount > 0) then
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount should be more than zero!';
		else
			update `account`
            set `balance` = `balance` + `amount`
            where `username` = `user`;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Balance Increased!';
		end if;
	end if;
END$$
DELIMITER ;

call increase_balance(200);