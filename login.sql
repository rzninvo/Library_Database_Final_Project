DELIMITER $$
create procedure login(
  in `username_temp` varchar(30),
  in `pass` varchar(30))
begin
    declare `pass_temp` binary(16);
    declare `recent_date` datetime;
    set `pass_temp` =  CAST(`pass` AS BINARY(16));
    if `username_temp` NOT in (select `username` from `System_Info`) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username does not exist!';
    else
        if AES_ENCRYPT(`pass_temp`,'kekw') NOT in (select `password` from `System_info` where `username` = `username_temp`) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'password does not match!';
        else
            if exists (select `tag` from `global` where `tag` like concat(`username_temp`,'%')) then
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have already logged in!';
            else
                delete from `global`;
                insert into `global`(`tag`) values (concat(`username_temp`, CURRENT_TIMESTAMP));
                if (select `banned` from `account` where `username` = `username_temp`) = 1 then
					set `recent_date` = (with T(`username`, `ban_date`) as (
					select * from `ban_list` where `username` = `username_temp`)
					select `ban_date` from T where `ban_date` > all(select `ban_date` from T));
                    if MONTH(current_timestamp - `recent_date`) >= 1 then
						update `account`
                        set `banned` = 0
                        where `username` = `user_temp`;
					end if;
                end if;
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Log in success!';
            end if;
        end if;
    end if;
END$$
DELIMITER ;

drop procedure login;
call login("rohamzn",'12345678');
call login("rohamzn1",'12345678');
call login('admin','admin');
select * from `global`;

DELIMITER $$
create procedure get_my_personal_info()
begin
    if not exists (select `tag` from `global`) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
    else
		select * from `Personal_Info` where `username` = (left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1))); 
    end if;
END$$
DELIMITER ;

DELIMITER $$
create procedure get_my_system_info()
begin
    if not exists (select `tag` from `global`) then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not logged in!';
    else
		select `username`
		from `System_Info` where `username` = (left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1)))
        union
		select AES_DECRYPT((select `password` from `System_Info`  where `username` = (left((select `tag` from `global`), (REGEXP_INSTR((select `tag` from `global`), '2021') - 1))))
					, 'kekw') as `password`;
    end if;
END$$
DELIMITER ;

drop procedure get_my_personal_info;
call get_my_personal_info();
drop procedure get_my_system_info;
call get_my_system_info();