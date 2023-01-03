DELIMITER $$
create procedure signup(
  in `username_temp` varchar(30),
  in `pass` varchar(30),
  in `address` varchar(30),
  in `first_name` varchar(30),
  in `last_name` varchar(30),
  in `mode` varchar(30),
  in `occupation` varchar(30),
  in `student_id` varchar(30),
  in `instructor_id` varchar(30),
  in `uni_name` varchar(30))
  begin
	declare `pass_temp` binary(16);
    set `pass_temp` =  CAST(`pass` AS BINARY(16));
	if (length(`username_temp`)>=6) AND (length(`pass`)>=8) then
		start transaction;
		if `username_temp` NOT in (select `username` from `System_Info`)  THEN
			insert into `System_Info`(`username`,`password`,`creation_time`) values (`username_temp`,AES_ENCRYPT(`pass_temp`,'kekw'),CURRENT_TIMESTAMP);
            insert into `Personal_Info`(`username`, `address`, `first_name`, `last_name`, `mode`, `occupation`, `student_id`, `uni_name`, `instructor_id`)
				values(`username_temp`, `address`, `first_name`, `last_name`, `mode`, `occupation`, `student_id`, `uni_name`, `instructor_id`);
			insert into `Account`(`username`, `balance`, `creation_date`, `type`) values (`username_temp`, 0, current_timestamp, 'User');
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Account Added!';
			commit;
		else
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Username Exists!';
			rollback;
		end if;
	else
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Username and Password should be alphanumeric and also within 6 and 8 chars.';
	end if;
  END$$
DELIMITER ;

drop procedure signup;
call signup("rohamzn",'12345678', 'Tehran', 'Roham', 'Zendehdel', 'Student', null, '9731088', null, 'Amirkabir');
call signup("rohamzn1",'12345678', 'Tehran', 'Roham', 'Zendehdel1', 'Student', null, '9731088', null, 'Amirkabir');
call signup("rohamzn2",'12345678', 'Tehran', 'Roham', 'Zendehdel2', 'Student', null, '9731088', null, 'Amirkabir');
call signup("rohamzn3",'12345678', 'Tehran', 'Roham', 'Zendehdel3', 'Student', null, '9731088', null, 'Amirkabir');
call signup("rohamzn4",'12345678', 'Tehran', 'Roham', 'Zendehdel4', 'Student', null, '9731088', null, 'Amirkabir');
call signup("rohamzn5",'12345678', 'Tehran', 'Roham', 'Zendehdel5', 'Student', null, '9731088', null, 'Amirkabir');
select * from `System_Info`;
select * from `Personal_Info`;
select * from `Account`;
delete from `System_Info`;
delete from `Personal_Info`;
delete from `account`;