use [master];


IF EXISTS(SELECT name FROM sys.databases WHERE (name = 'CTF'))
     DROP DATABASE [CTF];

CREATE DATABASE [CTF];

use [CTF];



create table UserList(
	user_id varchar(50) PRIMARY KEY NOT NULL,
	user_pw varchar(33) NOT NULL,
	user_email varchar(50) NOT NULL,
	user_point int NOT NULL,
	user_type varchar(3) NOT NULL,
);

CREATE TABLE ProblemList(
	prob_id int primary key identity(1,1) not null,
	prob_title varchar(50) not null,
	prob_context text,
	prob_point int not null,
	prob_answer varchar(33),
);

CREATE TABLE HintList(
	hint_id int primary key identity(1,1) not null,
	prob_id int references ProblemList(prob_id) not null,
	hint_context text not null,
	hint_cost int not null,
);

CREATE TABLE SolveList(
	solv_id int primary key identity(1,1) not null,
	prob_id int references ProblemList(prob_id) not null,
	user_id varchar(50) references UserList(user_id) not null,
	solve_time DATETIME not null,
);

CREATE TABLE HintUseList(
	use_id int primary key identity(1, 1) not null,
	hint_id int references HintList(hint_id) not null,
	user_id varchar(50) references UserList(user_id) not null,
	use_time DATETIME not null,
);

Go
CREATE PROCEDURE proc_solv(
	@P_prob_id INT,
	@P_user_name varchar(50),
	@P_solve_time DATETIME
)
WITH ENCRYPTION
AS
	INSERT INTO SolveList VALUES(@P_prob_id, @P_user_name, @P_solve_time);
	UPDATE UserList SET user_point += (SELECT prob_point FROM ProblemList WHERE prob_id = @P_prob_id) WHERE user_id = @P_user_name;
GO

CREATE PROCEDURE proc_hint(
	@P_hint_id INT,
	@P_user_name varchar(50),
	@P_hint_time DATETIME
)

AS
	INSERT INTO HintUseList VALUES (@P_hint_id, @P_user_name, @P_hint_time);
	UPDATE UserList SET user_point -= (SELECT hint_cost FROM HintList WHERE hint_id = @P_hint_id) WHERE user_id = @P_user_name;

GO

CREATE TRIGGER congraturation
	ON SolveList
	AFTER INSERT
	AS
	BEGIN
		select '문제를 풀었습니다.';
END;
GO

CREATE NONCLUSTERED INDEX ix_Hint ON HintList (prob_id);

INSERT INTO UserList VALUES('C0L4', '3A70163A7D6D00626DFD83E8FF893CF0', '0816i@naver.com', 0, 'M');
INSERT INTO UserList VALUES('fishsoup', '3A70163A7D6D00626DFD83E8FF893CF0', 'admin@fishsoup.kr', 0, 'J');
INSERT INTO UserList VALUES('starbox', '3A70163A7D6D00626DFD83E8FF893CF0', 'starbox@gamil.com', 0, 'J');
INSERT INTO UserList VALUES('kdw', '3A70163A7D6D00626DFD83E8FF893CF0', 'kdw@kdw.kr', 0, 'J');
INSERT INTO UserList VALUES('No_Named', '3A70163A7D6D00626DFD83E8FF893CF0', 'no@nonamer.com', 0, 'J');

INSERT INTO ProblemList VALUES('MicCheck', '<p>대회를 시작하기 전, 대회의 시스템을 점검하기 위한 문제입니다. 이 문자열을 디코딩해서 인증하세요!</p> <h2>6W?O%87cURDdQ7NG@*^:7R);</h2>', 100,'6477ad33252920eb3bd8edf16e89a8f8');
INSERT INTO ProblemList VALUES('Hard_Prob', '<p>아마 이 문제를 풀이하기 위해선 엄청난 해킹지식이 필요할 것입니다! 아마 힌트를 사용해야 될지도 모르겠군요! <a href="/somewhere">문제 풀러가기!</a></p>', 200,'5e6fcaa3ef32491189d947c81e7f4daf');
INSERT INTO ProblemList VALUES('Wrong_Prob', '<p>잘못 만들어진 문제입니다. 곧 삭제될 예정이니 절대 풀이하지 마세요!</p>', 999, 'dfa08328e174056a452327a8c4f645ab');

INSERT INTO HintList VALUES(2, '엄청난 해킹지식이 담겨있는 내용입니다! 도움이 되었길 빕니다!', 50);
INSERT INTO HintList VALUES(3, '잘못 만들어진 문제의 잘못된 힌트입니다! 도움은.. 되지 않습니다!', 90);
INSERT INTO HintList VALUES(3, '잘못 만들어진 문제의 또다른 잘못된 힌트입니다! 도움은.. 되지 않습니다!', 90);

EXEC proc_solv 1, 'fishsoup', '2020-06-25 14:09:45';
EXEC proc_solv 1, 'starbox', '2020-06-25 14:10:45';
INSERT INTO SolveList VALUES(1, 'kdw', '2020-06-25 14:10:48.245');
UPDATE UserList SET user_point += (SELECT prob_point FROM ProblemList WHERE prob_id = 1) WHERE user_id = 'kdw';
INSERT INTO SolveList VALUES(1, 'No_Named', '2020-06-25 14:19:48');
UPDATE UserList SET user_point += (SELECT prob_point FROM ProblemList WHERE prob_id = 1) WHERE user_id = 'No_Named';

EXEC proc_hint 1, "No_Named", '2020-06-25 14:20:25';

INSERT INTO SolveList VALUES(2, 'No_Named', '2020-06-25 14:30:59');
UPDATE UserList SET user_point += (SELECT prob_point FROM ProblemList WHERE prob_id = 2) WHERE user_id = 'No_Named';
INSERT INTO SolveList VALUES(2, 'starbox', '2020-06-25 15:00:00');
UPDATE UserList SET user_point += (SELECT prob_point FROM ProblemList WHERE prob_id = 2) WHERE user_id = 'starbox';

INSERT INTO SolveList VALUES(3, 'fishsoup', '2020-06-25 16:00:00');
UPDATE UserList SET user_point += (SELECT prob_point FROM ProblemList WHERE prob_id = 3) WHERE user_id = 'fishsoup';

UPDATE UserList Set user_point -= (SELECT prob_point FROM ProblemList WHERE prob_id = 3) WHERE user_id IN(select user_id from SolveList where prob_id = 3);

DELETE FROM HintUseList WHERE hint_id IN (SELECT hint_id from HintList where prob_id = 3);
delete from HintList where prob_id = 3;
delete from SolveList where prob_id = 3;
delete from ProblemList where prob_id = 3;

select * from UserList order by user_point desc;
select * from ProblemList;
select * from SolveList;
select * from HintUseList;

go
create view vw_email_solve (user_email, prob_id, solve_time)
as select us.user_email, prob.prob_id, prob.solve_time
from UserList us, SolveList prob
where us.user_id = prob.user_id;

go
select * from vw_email_solve;
