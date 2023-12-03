﻿--N) 2.3
CREATE PROC Procedure_AdminUpdateStudentStatus @StudentID INT
AS
IF @StudentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
DECLARE @financial_status BIT ;
				SET @financial_status = CASE WHEN Exists (Select * 
												  from (SELECT CASE WHEN CURRENT_TIMESTAMP > i.deadline AND i.status = 'notPaid'  THEN 0 ELSE 1 END as paid
														from Installment i INNER JOIN Payment p on (p.payment_id = i.payment_id 
															AND p.student_id = @StudentID)) as paids 
											      WHERE paids.paid = 0) Then 0 ELSE 1 END
		UPDATE Student
		SET Student.financial_status = @financial_status
		WHERE student_id = @StudentID
END
GO

------------------------------------------2.1----------------------------------------------------
--2)
CREATE PROCEDURE CreateAllTables AS
	CREATE TABLE Course (
	course_id             INT IDENTITY PRIMARY KEY,
	name                  VARCHAR(40),
	major                 VARCHAR(40),
	is_offered            BIT,
	credit_hours          INT,
	semester              INT
	);

	CREATE TABLE Instructor (
	instructor_id        INT IDENTITY PRIMARY KEY,
	name                 VARCHAR(40) ,
	email                VARCHAR(40) UNIQUE,
	faculty              VARCHAR(40),
	office               VARCHAR(40),
	Check(email LIKE '%@%.%') ------------------------------additional constraint e7teyatiiiiii-------
	) ;

	CREATE TABLE Semester (
	semester_code       VARCHAR(40) PRIMARY KEY ,
	start_date          DATE , 
	end_date            DATE
	);

	CREATE TABLE Advisor (
	advisor_id        INT IDENTITY PRIMARY KEY, 
	name              VARCHAR(40),
	email             VARCHAR(40) UNIQUE, 
	office            VARCHAR(40), 
	password          VARCHAR(40),
	Check(email LIKE '%@%.%') ------------------------------additional constraint e7teyatiiiiii-------
	);



	CREATE TABLE Student (
	student_id            INT IDENTITY PRIMARY KEY ,
	f_name                VARCHAR (40) ,
	l_name                VARCHAR (40) , 
	gpa	                  DECIMAL (3,2) , 
	faculty               VARCHAR (40), 
	email                 VARCHAR (40) UNIQUE, 
	major                 VARCHAR (40),
	password              VARCHAR (40), 
	financial_status      BIT  ,		
	semester              INT, 
	acquired_hours        INT, 
	assigned_hours        INT DEFAULT NULL, 
	advisor_id            INT ,
	CONSTRAINT FK_advisor1 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id), --ON DELETE SET NULL
	Check(email LIKE '%@%.%'), ------------------------------additional constraint e7teyatiiiiii-------
	Check (gpa between 0.7 AND 5.0)
	);
	
	CREATE TABLE Student_Phone (
	student_id            INT  ,
	phone_number          VARCHAR(40) ,
	CONSTRAINT PK_Student_Phone PRIMARY KEY (student_id, phone_number),
    CONSTRAINT FK_student1 FOREIGN KEY (student_id) REFERENCES Student (student_id) --ON DELETE CASCADE -- do not truncate
   	);



	CREATE TABLE PreqCourse_course (
	prerequisite_course_id  INT ,
	course_id               INT NOT NULL ,
	CONSTRAINT PK_PreqCourse_course PRIMARY KEY (prerequisite_course_id, course_id),
	CONSTRAINT FK_PreqCourse_course FOREIGN KEY (prerequisite_course_id ) REFERENCES Course (course_id ) ON DELETE CASCADE ,
	CONSTRAINT FK_PreqCourse_course2 FOREIGN KEY (course_id ) REFERENCES Course (course_id)  --ON DELETE CASCADE
	);

	CREATE TABLE Instructor_Course ( 
	course_id            INT ,
	instructor_id        INT ,
	CONSTRAINT PK_Instructor_Course PRIMARY KEY (course_id, instructor_id),
	CONSTRAINT FK_course1 FOREIGN KEY (course_id) REFERENCES Course (course_id), --ON DELETE CASCADE,
	CONSTRAINT FK_instructor1 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)-- ON DELETE CASCADE
	);

	CREATE TABLE Student_Instructor_Course_Take (
	student_id          INT ,
	course_id           INT ,
	instructor_id       INT , 
    semester_code       VARCHAR(40),
	exam_type           VARCHAR(40) DEFAULT 'Normal',
	grade               VARCHAR(40) ,
	CONSTRAINT PK_Student_Instructor_Course_Take PRIMARY KEY (student_id, course_id , semester_code),-- deleted instuctor id
	CONSTRAINT FK_student2 FOREIGN KEY (student_id) REFERENCES Student (student_id), -- ON DELETE CASCADE,
	CONSTRAINT FK_course2 FOREIGN KEY (course_id) REFERENCES Course (course_id) , --ON DELETE CASCADE,
	CONSTRAINT FK_instructor2 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id),--  ON DELETE CASCADE,
	CONSTRAINT FK_semester1 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) ,--ON DELETE CASCADE
	); 

	CREATE TABLE Course_Semester (
	course_id          INT ,
	semester_code      VARCHAR(40) ,
	CONSTRAINT PK_Course_Semester PRIMARY KEY (course_id, semester_code),
	CONSTRAINT FK_course3 FOREIGN KEY (course_id) REFERENCES Course (course_id),-- ON DELETE CASCADE,
	CONSTRAINT FK_semester2 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)-- ON DELETE CASCADE,
	);

	CREATE TABLE Slot (
	slot_id           INT IDENTITY PRIMARY KEY,
	day               VARCHAR(40), 
	time              VARCHAR(40), 
	location          VARCHAR(40), 
	course_id         INT , 
	instructor_id     INT,
	CONSTRAINT FK_course4 FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE SET NULL,
	CONSTRAINT FK_instructor3 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id) ,--ON DELETE SET NULL
	);

	CREATE TABLE Graduation_Plan (
	  plan_id                INT IDENTITY , 
	  semester_code          VARCHAR(40), 
	  semester_credit_hours  INT, 
	  expected_grad_date	 DATE, 
	  advisor_id             INT, 
	  student_id             INT,
	  CONSTRAINT PK_Graduation_Plan PRIMARY KEY (plan_id, semester_code),
	  CONSTRAINT FK_advisor2 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,--ON DELETE SET NULL,
	  CONSTRAINT FK_student3 FOREIGN KEY (student_id) REFERENCES Student (student_id) --ON DELETE CASCADE
	);														   

	CREATE TABLE GradPlan_Course (
	  plan_id                INT, -- Can i make it identity
	  semester_code          VARCHAR(40), 
	  course_id              INT,
	  CONSTRAINT PK_GradPlan_Course PRIMARY KEY (plan_id, semester_code, course_id),
	  CONSTRAINT FK_planSem FOREIGN KEY (plan_id, semester_code) REFERENCES Graduation_Plan (plan_id, semester_code) , --ON DELETE CASCADE,
	  CONSTRAINT FK_semester3 FOREIGN KEY (semester_code)  REFERENCES Semester (semester_code) ,-- ON DELETE CASCADE, -- OR SET NULL???
	  CONSTRAINT FK_course5 FOREIGN KEY (course_id)  REFERENCES Course (course_id),-- ON DELETE CASCADE  -- not FK in schema !!
	);
	/*is type not null since a request is either course or credit hours*/
	CREATE TABLE Request (
	request_id             INT IDENTITY PRIMARY KEY, 
	type                   VARCHAR(40) ,
	comment                VARCHAR(40), 
	status                 VARCHAR(40) DEFAULT 'pending', 
	credit_hours           INT , 
	student_id             INT , 
	advisor_id             INT, 
	course_id              INT ,
	CONSTRAINT FK_student4 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,-- ON DELETE CASCADE , -- ????
	CONSTRAINT FK_advisor3 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id) ,--ON DELETE SET NULL, --??
	CONSTRAINT FK_course6 FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE CASCADE
	);

	CREATE TABLE MakeUp_Exam (
	exam_id        INT IDENTITY PRIMARY KEY, 
	date           DATE, 
	type           VARCHAR(40), 
	course_id      INT ,
	CONSTRAINT FK_course7 FOREIGN KEY (course_id) REFERENCES Course (course_id) ,--ON DELETE CASCADE,
	);

	CREATE TABLE Exam_Student (
	exam_id         INT , 
	student_id      INT , 
	course_id       INT ,
	CONSTRAINT PK_Exam_Student PRIMARY KEY (exam_id ,student_id ,course_id ),
	CONSTRAINT FK_student5 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,--  ON DELETE CASCADE, 
	CONSTRAINT FK_exam FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id),--  ON DELETE CASCADE,
	CONSTRAINT FK_course8 FOREIGN KEY (course_id) REFERENCES Course (course_id)-- ON DELETE CASCADE
	);

	CREATE TABLE Payment(
	payment_id      INT IDENTITY PRIMARY KEY, 
	amount          INT , 
	start_date       DATE,
	deadline        DATE,
	n_installments  INT DEFAULT 0,
	status          VARCHAR(40) DEFAULT 'notPaid',
	fund_percentage DECIMAL(5,2), 
	student_id      INT, 
	semester_code   VARCHAR(40), 
	CONSTRAINT FK_student6 FOREIGN KEY (student_id) REFERENCES Student (student_id) ,-- ON DELETE SET NULL,
	CONSTRAINT FK_semester4 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code) --ON DELETE SET NULL,
	);

	CREATE TABLE Installment (
	payment_id     INT , 
	deadline       DATE, 
	amount         INT, 
	status         VARCHAR(40),
	start_date     DATE ,
	CONSTRAINT PK_Installment PRIMARY KEY (payment_id, deadline),
	CONSTRAINT FK_Payment FOREIGN KEY (payment_id) REFERENCES Payment (payment_id),
	);
GO
EXEC CreateAllTables;
GO
--3)
CREATE PROCEDURE  DropAllTables AS
	DROP TABLE Installment;
	DROP TABLE Payment;
	DROP TABLE Exam_Student;
	DROP TABLE MakeUp_Exam;
	DROP TABLE Request;
    DROP TABLE GradPlan_Course ;
    DROP TABLE Graduation_Plan;
	DROP TABLE Slot;
    DROP TABLE Course_Semester;
	DROP TABLE Student_Instructor_Course_Take;
	DROP TABLE Instructor_Course;
	DROP TABLE PreqCourse_course;
	DROP TABLE Student_Phone;
	DROP TABLE Student;
	DROP TABLE Advisor;
	DROP TABLE Semester;
	DROP TABLE Instructor;
	DROP TABLE Course;

GO
--4)
CREATE PROCEDURE clearAllTables AS
	ALTER TABLE Student DROP CONSTRAINT FK_advisor1
	ALTER TABLE Student_Phone DROP CONSTRAINT FK_student1
	ALTER TABLE PreqCourse_course DROP CONSTRAINT FK_PreqCourse_course
	ALTER TABLE PreqCourse_course DROP CONSTRAINT FK_PreqCourse_course2
	ALTER TABLE Instructor_Course DROP CONSTRAINT FK_course1
	ALTER TABLE Instructor_Course DROP CONSTRAINT FK_instructor1
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_student2
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_course2
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_instructor2
	ALTER TABLE Student_Instructor_Course_Take DROP CONSTRAINT FK_semester1
	ALTER TABLE Course_Semester DROP CONSTRAINT FK_course3
	ALTER TABLE Course_Semester DROP CONSTRAINT FK_semester2
	ALTER TABLE Slot DROP CONSTRAINT FK_course4
	ALTER TABLE Slot DROP CONSTRAINT FK_instructor3
	ALTER TABLE Graduation_Plan DROP CONSTRAINT FK_advisor2
	ALTER TABLE Graduation_Plan DROP CONSTRAINT FK_student3
	ALTER TABLE GradPlan_Course DROP CONSTRAINT FK_planSem
	ALTER TABLE GradPlan_Course DROP CONSTRAINT FK_semester3
	ALTER TABLE GradPlan_Course DROP CONSTRAINT FK_course5
	ALTER TABLE Request DROP CONSTRAINT FK_student4
	ALTER TABLE Request DROP CONSTRAINT FK_advisor3
	ALTER TABLE Request DROP CONSTRAINT FK_course6
	ALTER TABLE MakeUp_Exam DROP CONSTRAINT FK_course7
	ALTER TABLE Exam_Student DROP CONSTRAINT FK_student5
	ALTER TABLE Exam_Student DROP CONSTRAINT FK_exam
	ALTER TABLE Exam_Student DROP CONSTRAINT FK_course8
	ALTER TABLE Payment DROP CONSTRAINT FK_student6
	ALTER TABLE Payment DROP CONSTRAINT FK_semester4
	ALTER TABLE Installment DROP CONSTRAINT FK_Payment

	TRUNCATE TABLE Installment;
	TRUNCATE TABLE Payment
	TRUNCATE TABLE Exam_Student;
	TRUNCATE TABLE MakeUp_Exam;
	TRUNCATE TABLE Request;
    TRUNCATE TABLE GradPlan_Course ;
    TRUNCATE TABLE Graduation_Plan;
	TRUNCATE TABLE Slot;
    TRUNCATE TABLE Course_Semester;
	TRUNCATE TABLE Student_Instructor_Course_Take;
	TRUNCATE TABLE Instructor_Course;
	TRUNCATE TABLE PreqCourse_course;
	TRUNCATE TABLE Student_Phone;
	TRUNCATE TABLE Student ;
	TRUNCATE TABLE Advisor;
	TRUNCATE TABLE Semester;
	TRUNCATE TABLE Instructor;
	TRUNCATE TABLE Course;
	
	ALTER TABLE Student ADD	CONSTRAINT FK_advisor1 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id)
	ALTER TABLE Student_Phone ADD CONSTRAINT FK_student1 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE PreqCourse_course ADD CONSTRAINT FK_PreqCourse_course FOREIGN KEY (prerequisite_course_id ) REFERENCES Course (course_id ) ON DELETE CASCADE
	ALTER TABLE PreqCourse_course ADD CONSTRAINT FK_PreqCourse_course2 FOREIGN KEY (course_id ) REFERENCES Course (course_id)
	ALTER TABLE Instructor_Course ADD CONSTRAINT FK_course1 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Instructor_Course ADD CONSTRAINT FK_instructor1 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_student2 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_course2 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_instructor2 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)
	ALTER TABLE Student_Instructor_Course_Take ADD CONSTRAINT FK_semester1 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)
	ALTER TABLE Course_Semester ADD CONSTRAINT FK_course3 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Course_Semester ADD CONSTRAINT FK_semester2 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)
	ALTER TABLE Slot ADD CONSTRAINT FK_course4 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Slot ADD CONSTRAINT FK_instructor3 FOREIGN KEY (instructor_id) REFERENCES Instructor (instructor_id)
	ALTER TABLE Graduation_Plan ADD CONSTRAINT FK_advisor2 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id)
	ALTER TABLE Graduation_Plan ADD CONSTRAINT FK_student3 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE GradPlan_Course ADD CONSTRAINT FK_planSem FOREIGN KEY (plan_id, semester_code) REFERENCES Graduation_Plan (plan_id, semester_code)
	ALTER TABLE GradPlan_Course ADD CONSTRAINT FK_semester3 FOREIGN KEY (semester_code)          REFERENCES Semester (semester_code)
	ALTER TABLE GradPlan_Course ADD CONSTRAINT FK_course5 FOREIGN KEY (course_id)              REFERENCES Course (course_id)
	ALTER TABLE Request ADD CONSTRAINT FK_student4 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Request ADD CONSTRAINT FK_advisor3 FOREIGN KEY (advisor_id) REFERENCES Advisor (advisor_id)
	ALTER TABLE Request ADD CONSTRAINT FK_course6 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE MakeUp_Exam ADD CONSTRAINT FK_course7 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Exam_Student ADD CONSTRAINT FK_student5 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Exam_Student ADD CONSTRAINT FK_exam FOREIGN KEY (exam_id) REFERENCES MakeUp_Exam (exam_id)
	ALTER TABLE Exam_Student ADD CONSTRAINT FK_course8 FOREIGN KEY (course_id) REFERENCES Course (course_id)
	ALTER TABLE Payment ADD CONSTRAINT FK_student6 FOREIGN KEY (student_id) REFERENCES Student (student_id)
	ALTER TABLE Payment ADD CONSTRAINT FK_semester4 FOREIGN KEY (semester_code) REFERENCES Semester (semester_code)
	ALTER TABLE Installment ADD CONSTRAINT FK_Payment FOREIGN KEY (payment_id) REFERENCES Payment (payment_id)

GO

------------------------------Helper for student status------------------------------------------
CREATE FUNCTION CALC_STUDENT_FINANTIAL_STATUS_HELPER (@StudentId INT)
	RETURNS BIT
	BEGIN
		DECLARE @financial_status BIT;

		SET @financial_status = CASE WHEN Exists (Select * 
												  from (SELECT CASE WHEN CURRENT_TIMESTAMP > i.deadline AND i.status = 'notPaid'  THEN 0 ELSE 1 END as paid
														from Installment i INNER JOIN Payment p on (p.payment_id = i.payment_id 
															AND p.student_id = @StudentID)) as paids 
											      WHERE paids.paid = 0) Then 0 ELSE 1 END

	RETURN @financial_status
	END
GO

------------------------------------------2.2----------------------------------------------------
--A)
CREATE VIEW view_Students AS 
SELECT * 
FROM student 
WHERE financial_status = 1;
GO
--B)
CREATE VIEW view_Course_prerequisites AS 
SELECT c.course_id , c.name ,c.credit_hours ,c.is_offered ,c.major ,c.semester ,PC.prerequisite_course_id 
FROM Course c INNER JOIN PreqCourse_course PC on c.course_id = PC.prerequisite_course_id; 
GO
--C)
CREATE VIEW Instructors_AssignedCourses AS
SELECT I.instructor_id ,I.name AS 'Instructor name' ,I.email ,I.faculty ,I.office ,
	  c.course_id , c.name AS 'Course name',c.credit_hours ,c.is_offered ,c.major ,c.semester 
FROM ( Instructor I INNER JOIN Instructor_Course IC on I.instructor_id = IC.instructor_id 
					INNER JOIN Course c ON IC.course_id = c.course_id )
GO
--D)
CREATE VIEW  Student_Payment AS
SELECT P.amount ,P.deadline ,P.fund_percentage ,P.n_installments ,P.payment_id ,P.semester_code ,
		P.start_date ,P.status ,S.f_name ,S.l_name ,S.student_id ,S.email 
FROM Payment P INNER JOIN Student S on S.student_id = P.student_id;
GO 
--E)
CREATE VIEW Courses_Slots_Instructor AS
SELECT c.course_id , c.name AS 'Course name' , S.slot_id , S.day , S.time , S.location , I.name AS 'Instructor name'
FROM (( Course c INNER JOIN Slot S on c.course_id = c.course_id 
                 INNER JOIN Instructor_Course IC on IC.Course_id = c.Course_id)
				 INNER JOIN Instructor I ON I.instructor_id = IC.instructor_id);
GO 
--F)
CREATE VIEW Courses_MakeupExams AS
SELECT c.name , c.semester , ME.course_id ,ME.date ,ME.exam_id ,ME.type
FROM Course c INNER JOIN MakeUp_Exam ME on c.course_id = ME.course_id;

GO
--G)
CREATE VIEW Students_Courses_transcript AS
	SELECT S.student_id , (S.f_name + ' ' +S.l_name) As 'student name' , SC.course_id , c.name AS 'Course name' ,
		   SC.exam_type , SC.grade AS ' course grade' , SC.semester_code AS 'Semester', I.name AS 'Instructor name' 
	FROM (((Student_Instructor_Course_Take SC 
	INNER JOIN Student S on S.student_id = SC.student_id )
	INNER JOIN Course c on SC.course_id = c.course_id )
	INNER JOIN Instructor I on SC.Instructor_id = I.Instructor_id)
	WHERE SC.grade IS NOT NULL
	;
GO
--H)
CREATE VIEW  Semster_offered_Courses AS 
SELECT CS.course_id , c.name AS ' Course name' , CS.semester_code
FROM ((Course_Semester  CS
		INNER JOIN Semester S on S.semester_code = CS.semester_code)
		INNER JOIN course c on c.course_id= CS.course_id );
GO 
--I)
CREATE VIEW Advisors_Graduation_Plan AS
SELECT GP.expected_grad_date ,GP.student_id ,GP.semester_credit_hours , 
	   GP.semester_code ,GP.plan_id  , A.advisor_id , A.name AS 'Advisor name'
FROM Graduation_Plan GP INNER JOIN Advisor A on A.advisor_id = GP.advisor_id;
GO 
------------------------------------------2.3----------------------------------------------------
--A)
CREATE PROCEDURE Procedures_StudentRegistration 
@first_name varchar (40),
@last_name varchar (40), 
@password varchar (40),
@faculty varchar (40),
@email varchar (40), 
@major varchar (40), 
@Semester int,
@student_id INT OUTPUT
AS 
BEGIN 
	INSERT INTO Student(f_name,l_name,password,faculty,email,major,semester)
			VALUES(@first_name,@last_name,@password,@faculty,@email,@major,@Semester)
	SET @student_id = SCOPE_IDENTITY();
END
GO
--B)
CREATE PROC Procedures_AdvisorRegistration
	 @name VARCHAR(40),
	 @password VARCHAR(40), 
	 @email VARCHAR(40), 
	 @office VARCHAR(40),
	 @advisor_id INT OUTPUT
	 AS
	 IF @name IS NULL OR @password IS NULL OR @email IS NULL OR @office IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	 ELSE
		BEGIN 
			 INSERT INTO Advisor(name,password,email,office)
			 VALUES(@name,@password,@email,@office);
			 SET @advisor_id = SCOPE_IDENTITY() ;
		END 
GO
--C)
CREATE PROC Procedures_AdminListStudents
	AS
	SELECT * FROM Student;	
GO 
--D)
CREATE PROC Procedures_AdminListAdvisors
	AS
	SELECT * FROM Advisor;	
GO
--E)
CREATE PROC AdminListStudentsWithAdvisors
	AS
	SELECT Student.f_name,Student.l_name , Advisor.name
	FROM Student INNER JOIN Advisor ON Student.advisor_id = Advisor.advisor_id;
GO
--F)
CREATE PROC AdminAddingSemester 
	@start_date DATE,
	@end_date DATE,
	@semester_code VARCHAR(40)
	AS
	IF @start_date IS NULL OR @end_date IS NULL OR @semester_code IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Semester VALUES(@semester_code,@start_date,@end_date);
		END
GO
--G)
CREATE PROC Procedures_AdminAddingCourse 
	@major VARCHAR (40), 
	@semester INT, 
	@credit_hours INT, 
	@name VARCHAR (40), 
	@is_offered BIT
	AS
	IF @major IS NULL OR @semester IS NULL OR @credit_hours IS NULL OR @name IS NULL OR @is_offered IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE');
		END
	ELSE
		BEGIN
			INSERT INTO Course(name,major,is_offered,credit_hours,semester)
			VALUES(@name,@major,@is_offered,@credit_hours,@semester);
		END
GO
--H)
CREATE PROC Procedures_AdminLinkInstructor -- update or insert ??
	@instructor_id INT,
	@course_id INT,
	@slot_id INT
	AS
	IF @instructor_id IS NULL OR @course_id IS NULL OR @slot_id IS NULL 
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	IF 
		not exists(SELECT instructor_id FROM Instructor WHERE instructor_id=@instructor_id) OR
		not exists(SELECT course_id FROM Course WHERE course_id=@course_id)OR
		not exists(SELECT slot_id FROM Slot WHERE slot_id=@slot_id)
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN ------------- Does instructor teach this course in ||| Instructor_course table ||||
			UPDATE Slot 
			SET instructor_id =@instructor_id , course_id = @course_id
			WHERE slot_id = @slot_id
		END
GO
--I)
CREATE PROC Procedures_AdminLinkStudent
	@instructor_id INT,
	@student_id INT,
	@course_id INT,
	@semester_code VARCHAR(40)
	AS
	IF @instructor_id IS NULL OR @student_id IS NULL OR @course_id IS NULL OR @semester_code IS NULL  
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	IF 
		not exists(SELECT instructor_id FROM Instructor WHERE instructor_id=@instructor_id) OR
		not exists(SELECT course_id FROM Course WHERE course_id=@course_id)OR
		not exists(SELECT student_id FROM Student WHERE student_id=@student_id)OR
		not exists(SELECT semester_code FROM Semester WHERE semester_code=@semester_code)
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Student_Instructor_Course_Take(student_id,course_id,instructor_id,semester_code)
			VALUES(@student_id,@course_id,@instructor_id,@semester_code);
		END	
GO 
--J)
CREATE PROC Procedures_AdminLinkStudentToAdvisor --update or insert ??
	@student_id INT,
	@advisor_id INT
	AS
	IF  @student_id IS NULL OR @advisor_id IS NULL  
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	IF
		not exists(SELECT student_id FROM Student WHERE student_id=@student_id)OR
		not exists(SELECT advisor_id FROM Advisor WHERE advisor_id=@advisor_id)
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			--INSERT INTO Student(student_id,advisor_id) VALUES(@student_id,@advisor_id);
			UPDATE Student
			SET advisor_id = @advisor_id
			WHERE student_id = @student_id
		END
GO 
--K)
CREATE PROC Procedures_AdminAddExam
	@Type VARCHAR (40),
	@date DATE,
	@course_id INT
	AS
	IF @Type IS NULL OR @date IS NULL OR @course_id IS NULL
		BEGIN
			PRINT('CAN''T DO THIS SERVICE')
		END
	ELSE 
		BEGIN
			INSERT INTO MakeUp_Exam(date,type,course_id) 
			VALUES(@date,@Type,@course_id);
		END
GO



--L)
CREATE PROC Procedures_AdminIssueInstallment @paymentID INT --mahmoud mabsoot
AS
IF @paymentID IS NULL OR EXISTS(SELECT * FROM Installment WHERE payment_id = @paymentID)
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DECLARE @num_instalments INT ,
			@i INT ,
			@date DATE ,
			@start_date DATE ,
			@end_date DATE ,
			@amount INT
	SELECT @amount = amount ,
		   @start_date = start_date,
		   @end_date = deadline
	FROM Payment 
	WHERE payment_id = @paymentID
	SET @num_instalments = MONTH(@end_date) - MONTH(@start_date)
	SET @amount = @amount / @num_instalments
	SET @i = 0 

	WHILE @i < @num_instalments
	BEGIN
		SET @end_date = DATEADD(MONTH, 1, @start_date)
		INSERT INTO Installment VALUES(@paymentID ,@end_date ,@amount ,'notPaid',@start_date)
		SET @start_date = DATEADD(MONTH, 1, @start_date)
		SET @i = @i +1
	END
END
GO
--M)
CREATE PROC Procedures_AdminDeleteCourse @courseID INT
AS
IF @courseID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	UPDATE Slot
	SET course_id = NULL
	WHERE course_id = @courseID;

	DELETE
	FROM Course
	WHERE course_id = @courseID;
END
GO
--N) moved before the Tables creation 
--O)
CREATE VIEW all_Pending_Requests
	AS
	SELECT R.*
		  ,S.f_name
		  ,S.l_name
		  ,A.name
	FROM Request R
		INNER JOIN Student S ON S.student_id = R.student_id
		INNER JOIN Advisor A ON A.advisor_id = R.advisor_id
	WHERE R.status = 'pending'
GO
--P)
CREATE PROC Procedures_AdminDeleteSlots @current_semester VARCHAR(40)
AS
IF @current_semester IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DELETE S
	FROM Slot S
	INNER JOIN Course C ON S.course_id = C.course_id
	INNER JOIN Course_Semester CS ON @current_semester = CS.semester_code
	WHERE C.is_offered = 0
END
GO
--Q)
CREATE FUNCTION FN_AdvisorLogin (
	@ID INT
	,@password VARCHAR(40)
	)
RETURNS BIT
AS
BEGIN
	DECLARE @Success BIT

	IF EXISTS (
			SELECT *
			FROM Advisor
			WHERE Advisor.advisor_id = @ID
				AND Advisor.password = @password
			)
		SET @Success = 1
	ELSE
		SET @Success = 0

	RETURN @Success
END
GO

--R)
--TO BE CHECKED SINCE THE INPUT IS A DATE AND IT SHOULD BE AN INTEGER REPRESENTING THE SEMESTER
--TO BE ASKED IN Q&A
CREATE PROC Procedures_AdvisorCreateGP 
	 @Semestercode VARCHAR(40)
	,@expected_graduation_date DATE
	,@sem_credit_hours INT
	,@advisorid INT
	,@studentid INT
AS
	-- saeed added
	DECLARE @std_acq_hours INT
	SELECT @std_acq_hours= acquired_hours
	FROM Student
	WHERE student_id = @studentid
IF @std_acq_hours <= 157
	BEGIN PRINT 'INVALID ACTION the student dont have enough acquired_hours' END
ELSE IF @Semestercode IS NULL
	OR @expected_graduation_date IS NULL
	OR @sem_credit_hours IS NULL
	OR @advisorid IS NULL
	OR @studentid IS NULL
	BEGIN
		PRINT 'INVALID INPUT'
	END
ELSE
	BEGIN
	
		INSERT INTO Graduation_Plan (
			semester_code
			,semester_credit_hours
			,expected_grad_date
			,advisor_id
			,student_id
			)
		VALUES (
			@Semestercode
			,@sem_credit_hours
			,@expected_graduation_date
			,@advisorid
			,@studentid
			)
	END
GO
--S)
CREATE PROC Procedures_AdvisorAddCourseGP 
	 @student_Id INT
	,@Semester_code VARCHAR(40)
	,@course_name VARCHAR(40)
AS
IF  @student_Id IS NULL
	OR @Semester_code IS NULL
	OR @course_name IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DECLARE @course_id INT

	SELECT @course_id = course_id
	FROM Course
	WHERE Course.name = @course_name

	DECLARE @plan_id INT

	SELECT @plan_id = plan_id
	FROM Graduation_Plan
	WHERE Graduation_Plan.student_id = @student_Id

	INSERT INTO GradPlan_Course (
		plan_id
		,semester_code
		,course_id
		)
	VALUES (
		@plan_id
		,@Semester_code
		,@course_id
		)
END
GO
--T)
CREATE PROC Procedures_AdvisorUpdateGP 
	 @expected_grad_date DATE
	,@studentID INT
AS
IF    @expected_grad_date IS NULL
	OR @studentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN

	UPDATE Graduation_Plan
	SET expected_grad_date = @expected_grad_date
	WHERE Graduation_Plan.student_id = @studentID
END
GO
--U)
CREATE PROC Procedures_AdvisorDeleteFromGP 
	 @studentID INT
	,@semesterCode VARCHAR(40)
	,@courseID INT
AS
IF  @studentID IS NULL
	OR @semesterCode IS NULL
	OR @courseID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DECLARE @planid  INT ;
	SELECT @planid = plan_id
	FROM Graduation_Plan
	WHERE student_id= @studentID
	
	DELETE 
	FROM GradPlan_Course
	WHERE plan_id= @planid AND
		  course_id =@courseID AND
		  semester_code = @semesterCode
END
GO


/* V Handle what to show when type = course and when type = CH*/
CREATE FUNCTION FN_Advisors_Requests (@advisorID INT)
	RETURNS TABLE
	AS
	RETURN (
		SELECT *
		FROM Request
		WHERE advisor_id = @advisorID
	);
GO

/*                     W                          */
Create PROC Procedures_AdvisorApproveRejectCHRequest
	@RequestID int,
	@Current_semester_code varchar (40)
	AS
	Declare @stID INT
	Declare @ch INT
	IF @RequestID IS NULL OR @Current_semester_code IS NULL OR Not EXISTS (Select * from Request WHERE type LIKE 'credit%' AND @RequestID = request_id AND status = 'pending')
		Print 'No such pending request'

	ELSE IF Exists (Select s.student_id from Request R INNER JOIN Student S on r.student_id = s.student_id AND r.type LIKE 'credit%' /*is type like this?*/
		AND @RequestID = request_id And s.gpa <= 3.7 AND r.credit_hours <= 3 And r.credit_hours + s.assigned_hours <= 34) 
	Begin
	----
		UPDATE Request 
		Set status = 'approved'
		where @RequestID = request_id

		------
		SET @stID = (SELECT student_id from Request where @RequestID = request_id)
		SET @ch = (SELECT credit_hours from Request where @RequestID = request_id)
		UPDATE Student
		SET assigned_hours = (SELECT assigned_hours + @ch
							from Student where student_id = @stID)
		where student_id = @stID
		-----
		Declare @InstID1 INT
		Declare @InstID2 DATE
		SELECT TOP 1 @InstID1 = i.payment_id, @InstID2 = i.deadline
				from Installment i JOIN Payment p on i.payment_id = p.payment_id AND p.student_id = @stID 
				AND p.semester_code = @Current_semester_code AND i.status = 'notPaid'
				Order by i.deadline 
		
		UPDATE Installment
		SET amount = amount + @ch*1000
		where payment_id = @InstID1 AND deadline = @InstID2
	End
	ELSE
		UPDATE Request
		Set status = 'rejected'
		where @RequestID = request_id
	GO
/*X*/
CREATE PROC Procedures_AdvisorViewAssignedStudents
	@AdvisorID int,
	@major varchar (40)
	AS
	Select s.student_id as 'Student id', Concat(s.f_name, ' ', s.l_name) as 'Student name' , s.major as 'Student major', c.name as 'Course name'
				from student s INNER JOIN Student_Instructor_Course_Take t on s.student_id = t.student_id
				INNER JOIN Course c on t.course_id = c.course_id
				AND s.advisor_id = @AdvisorID And s.major = @major;
	GO
/*                              Y              */
CREATE PROC Procedures_AdvisorApproveRejectCourseRequest
	@RequestID int,
	@current_semester_code varchar(40)
	AS
	IF @RequestID IS NULL OR @current_semester_code IS NULL OR Not EXISTS (Select * from Request WHERE type = 'course' AND @RequestID = request_id AND status='pending')
	BEGIN
		Print 'ERROR' 
		RETURN
	END
	DECLARE @prereq_taken BIT
	SET @prereq_taken = CASE
		WHEN EXISTS (
			SELECT p.prerequisite_course_id
			FROM PreqCourse_course p
			INNER JOIN Request r ON p.course_id = r.course_id AND r.request_id = @RequestID
			LEFT JOIN Student_Instructor_Course_Take sic ON p.prerequisite_course_id = sic.course_id AND sic.student_id = r.student_id
			WHERE sic.course_id IS NULL OR sic.grade IS NULL OR sic.grade = 'FA'
		) THEN 0
		ELSE 1
		END;
	Declare @enough_hours BIT
	SET @enough_hours  = CASE
		WHEN EXISTS ( Select c.credit_hours from Request r JOIN Course c on r.course_id = c.course_id AND r.request_id = @RequestID
			JOIN Student s on r.student_id = s.student_id AND s.assigned_hours >= c.credit_hours
			) THEN 1
			ELSE 0
			END;
	Declare @already_taken BIT 
	SET @already_taken= CASE 
				WHEN EXISTS (Select * from Request r JOIN Student_Instructor_Course_Take sic 
				on r.student_id = sic.student_id AND r.course_id = sic.course_id AND r.request_id = @RequestID
				AND sic.semester_code = @current_semester_code) THEN 1 ELSE 0 END
	Declare @studentID INT
	Declare @course_hours INT
	Declare @courseID INT
	Select @studentID = r.student_id, @course_hours = c.credit_hours, @courseID = c.course_id
	from Request r JOIN Course c on r.course_id = c.course_id AND r.request_id = @RequestID

	IF @prereq_taken = 1 AND @enough_hours = 1 AND @already_taken = 0
	BEGIN
		UPDATE Request
		SET status = 'approved'
		WHERE @RequestID = request_id

		UPDATE Student
		SET assigned_hours = assigned_hours - @course_hours
		WHERE student_id = @studentID

		INSERT INTO Student_Instructor_Course_Take(student_id, course_id, semester_code) VALUES
		(@studentID, @courseID, @current_semester_code)
	END
	ELSE
	BEGIN
		UPDATE Request
		SET status = 'rejected'
		WHERE @RequestID = request_id
	END

	GO
/*Z*/
CREATE PROC Procedures_AdvisorViewPendingRequests
	@AdvisorID int
	AS
	Select * from request 
		where status = 'pending' AND student_id in (Select student_id from student where advisor_id = @AdvisorID);
	GO


/* AA  */
CREATE FUNCTION  FN_StudentLogin(@StudentID int, @password varchar (40))
	RETURNS BIT
	AS
	BEGIN
		RETURN CASE WHEN EXISTS (SELECT 1 from Student
							WHERE student_id = @StudentID AND password = @password)
			   THEN 1 ELSE 0 END
	END;
GO

/*BB*/
CREATE PROC Procedures_StudentaddMobile
	@StudentID int, 
	@mobile_number varchar (40)
	AS
	IF NOT EXISTS(Select student_id from student where student_id = @StudentID) OR  @StudentID IS NULL OR @mobile_number IS NULL
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
		INSERT INTO Student_Phone values(@StudentID ,@mobile_number);
	END
	GO
/*CC*/
CREATE FUNCTION FN_SemsterAvailableCourses (@semester_code varchar (40))
	RETURNS TABLE
	AS
	RETURN (
		Select c.* ----- basss????
		from Course c JOIN Course_Semester cs on c.course_id = cs.course_id AND cs.semester_code = @semester_code AND c.is_offered = 1
	);
GO
/*DD*/
CREATE PROC Procedures_StudentSendingCourseRequest
	@StudentID int, 
	@courseID int, 
	@type varchar (40),
	@comment varchar (40) 
	AS
	IF @StudentID IS NULL OR @courseID IS NULL OR @type NOT LIKE 'course%'
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
		INSERT INTO request (student_id, course_id, type, comment) values (@StudentID ,@courseID ,@type ,@comment) 
	END
	GO
/*EE*/
CREATE PROC Procedures_StudentSendingCHRequest
	@StudentID int, 
	@credit_hours int, 
	@type varchar (40),
	@comment varchar (40) 
	AS
	IF @StudentID IS NULL OR @credit_hours IS NULL OR @type NOT LIKE 'credit%'
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
		INSERT INTO request (student_id, credit_hours, type, comment) values (@StudentID ,@credit_hours ,@type ,@comment) 
	END
	GO

---------------------------------------------------------------HELPER FUNCTIONS-------------------------------------------------------
GO
CREATE FUNCTION FN_IS_COURSE_OFFERED_HELPER (@CourseID INT , @Current_Semester_Code VARCHAR(40) )
	RETURNS BIT 
	AS
	BEGIN 
	DECLARE @Is_offered BIT ,
			@course_semester INT 
		SELECT @course_semester=semester  FROM Course WHERE course_id = @CourseID
		IF( @course_semester % 2 = 0 AND( @Current_Semester_Code LIKE 'Spring%' OR @Current_Semester_Code LIKE '%Round 2%'  OR @Current_Semester_Code LIKE '%R2%' OR @Current_Semester_Code LIKE 'S%[^R]%') )
			BEGIN  SET @Is_offered = 1 END
		ELSE IF( @course_semester % 2 <> 0 AND( @Current_Semester_Code LIKE 'Winter%' OR @Current_Semester_Code LIKE '%Round 1%' OR @Current_Semester_Code LIKE '%R1%' OR @Current_Semester_Code LIKE 'W%' ) )
		    BEGIN  SET @Is_offered = 1 END
		ELSE
			BEGIN  SET @Is_offered  = 0 END
	RETURN @Is_offered ;
END
GO
CREATE FUNCTION FN_IS_prerequisite_Courses_TAKEN_HELPER (@StudentID INT , @CourseID INT ) 
	RETURNS BIT 
	AS
	BEGIN 
	DECLARE @Is_ALL_PRE_TAKEN BIT ,
			@num_pre_courses_not_taken INT 
		SELECT @num_pre_courses_not_taken =COUNT(*)
		FROM (
				(SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
				FROM PreqCourse_course PC INNER JOIN Course c ON PC.course_id = c.course_id  WHERE c.course_id = @CourseID)
				EXCEPT
				(SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
				FROM ( PreqCourse_course PC INNER JOIN Course c ON PC.course_id = c.course_id
											INNER JOIN Student_Instructor_Course_Take SC ON SC.course_id = PC.prerequisite_course_id )
				WHERE SC.student_id  = @StudentID AND
					  c.course_id = @CourseID ) 
		      )T_Pre_Courses_Not_Taken
		
		IF @num_pre_courses_not_taken <> 0  --if didnt take all prerequisites
			BEGIN SET @Is_ALL_PRE_TAKEN =0 END
		ELSE	
			BEGIN SET @Is_ALL_PRE_TAKEN =1 END
										
		
	RETURN @Is_ALL_PRE_TAKEN ;
	END ;
GO
CREATE FUNCTION FN_FIND_REQ_Courses_HELPER (@Student_ID int  , @Current_semester_code Varchar (40) , @CourseID INT) 
	RETURNS TABLE
	AS
	RETURN 
		 SELECT c1.course_id , c1.name , c1.major ,c1.is_offered ,c1.credit_hours ,c1.semester
		 FROM ( Course c1 INNER JOIN Student_Instructor_Course_Take SC ON c1.course_id = SC.course_id
						  INNER JOIN Student S ON SC.student_id = S.student_id )
		 WHERE  S.student_id = @Student_ID AND
				c1.course_id = @CourseID AND
				c1.semester <= S.semester AND
				( SC.grade = 'F' OR SC.grade ='FF' OR SC.grade='FA' OR SC.grade IS NULL ) AND               -- check for grade
				dbo.FN_IS_COURSE_OFFERED_HELPER(c1.course_id , @Current_semester_code) = 1 	
GO

CREATE FUNCTION FN_FIND_OPTIONAL_Courses_HELPER (@Student_ID int  , @Current_semester_code Varchar (40) , @CourseID Varchar (40) ) 
	RETURNS TABLE
	AS
	RETURN 
	SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
	FROM Course c 
	WHERE dbo.FN_IS_COURSE_OFFERED_HELPER(c.course_id , @Current_semester_code) = 1 AND  -- course is offered 
		  dbo.FN_IS_prerequisite_Courses_TAKEN_HELPER(@Student_ID , c.course_id) =1 AND  -- Took all prerequisite
		  NOT EXISTS  ( SELECT * FROM dbo.FN_FIND_REQ_Courses_HELPER (@Student_ID   , @Current_semester_code  , c.course_id) )
GO

CREATE FUNCTION FN_num_of_falied_courses_HELPER (@Season1 VARCHAR(40) , @Season4 VARCHAR(40), @Season2 VARCHAR(40) , @Season3 VARCHAR(40),@CourseID INT , @StudentID INT)
	RETURNS INT
	AS
	BEGIN
	DECLARE @Num_of_falied_courses INT
			
		SELECT @Num_of_falied_courses=COUNT(*)
		FROM   Student_Instructor_Course_Take 
		WHERE	course_id = @CourseID AND
				student_id = @StudentID AND
				(semester_code LIKE @Season1 OR semester_code LIKE @Season2  OR semester_code LIKE @Season3 OR
				semester_code LIKE @Season4) AND  
				(grade = 'F' OR grade = 'FF')

	RETURN @Num_of_falied_courses ;
	END
GO
-------------------------------------------------------------------------------------------------------------------------------------------
--FF) 
CREATE FUNCTION FN_StudentViewGP (@student_ID int) 
RETURNS TABLE
AS
RETURN
    SELECT 
		S.student_id                    AS 'Student Id',
		CONCAT(S.f_name, ' ', S.l_name) AS 'Student_name', 
		GP.plan_id                      AS 'graduation Plan Id', 
		c.course_id                     AS 'Course id',
		c.name                          AS 'Course name', 
		GP.semester_code                AS 'Semester code', 
		GP.expected_grad_date           AS 'expected graduation date',
		GP.semester_credit_hours        AS 'Semester credit hours', 
		GP.advisor_id                   AS 'advisor id'
    FROM (Student S INNER JOIN Graduation_Plan GP ON S.student_id = GP.student_id
					INNER JOIN GradPlan_Course GPC ON (GP.plan_id = GPC.plan_id AND GP.semester_code = GPC.semester_code ) )
					INNER JOIN Course c ON GPC.course_id = c.course_id
	WHERE S.student_id = @student_ID

-- GG)
GO
CREATE FUNCTION FN_StudentUpcoming_installment (@StudentID INT)
	RETURNS DATE 
	AS
	BEGIN 
	DECLARE @first_instalment_deadline DATE

	SELECT @first_instalment_deadline  = MIN(I.deadline)
	FROM Payment P INNER JOIN Installment I ON P.payment_id = I.payment_id 
	WHERE P.student_id = @StudentID AND
		  P.status = 'notPaid' AND
		  I.status = 'notPaid'
	RETURN @first_instalment_deadline ;
END


--HH)
GO
CREATE FUNCTION  FN_StudentViewSlot (@CourseID INT , @InstructorID INT) 
RETURNS TABLE
AS
RETURN
    SELECT SL.slot_id AS 'Slot ID', 
			SL.location AS'location', 
			SL.time AS'time', 
			SL.day AS 'day' , 
		    c.name AS'course name' ,
		    ISC.name AS'Instructor name' 
    FROM (Course c INNER JOIN Slot SL ON c.course_id = SL.course_id
				   INNER JOIN Instructor ISC ON SL.instructor_id = ISC.instructor_id)
	WHERE c.course_id = @CourseID AND
		  ISC.instructor_id = @InstructorID

GO
--II) what is the date of first or secound makeup
CREATE PROCEDURE   Procedures_StudentRegisterFirstMakeup
	@StudentID int, 
	@courseID int, 
	@studentCurrentsemester varchar (40)
	AS
	DECLARE @InstructorID INT ,
			@Grade_Normal_Exam VARCHAR(40) ,
			@IF_course_firstMakeup INT

		SELECT @IF_course_firstMakeup=COUNT(*)
		FROM  Student_Instructor_Course_Take 
		WHERE course_id = @CourseID AND
			  student_id = @StudentID AND
			  semester_code = @studentCurrentsemester AND
			  exam_type LIKE '%makeup%'
		IF @IF_course_firstMakeup <> 0
			BEGIN PRINT ('YOU CANT REGISTER FOR THE FIRST MAKEUP YOU REGISTERED BEFOR FOR A MAKEUP EXAM') END
		ELSE 
			BEGIN
				SELECT @Grade_Normal_Exam = grade 
				FROM Student_Instructor_Course_Take
				WHERE student_id = @StudentID AND
					  course_id = @courseID AND
					  exam_type = 'Normal' AND
					  semester_code = @studentCurrentsemester 
				IF @Grade_Normal_Exam <> 'FF' OR @Grade_Normal_Exam <> 'F' OR @Grade_Normal_Exam <> 'NULL'
					BEGIN PRINT('YOUR GRADE NOT FF OR F TO REGISTER ON THIS EXAM') END
				ELSE
					BEGIN
						Declare @nextSemester VARCHAR(40)
						SET @nextSemester =  (SELECT TOP 1 semester_code
											FROM Semester Where semester_code <> @studentCurrentsemester AND 
											start_date >= (SELECT end_date FROM Semester WHERE semester_code=@studentCurrentsemester)
											ORDER BY start_date ASC)
						SELECT  @InstructorID = instructor_id 
						FROM Student_Instructor_Course_Take
						WHERE course_id = @courseID  AND
							  student_id = @StudentID
			
						INSERT INTO Student_Instructor_Course_Take (student_id ,course_id ,instructor_id ,semester_code ,exam_type ,grade) 
							   VALUES (@StudentID ,@CourseID , @InstructorID ,@nextSemester , 'First_makeup' ,  NULL ) ;
					END
			END
-- JJ) 
GO
CREATE FUNCTION  FN_StudentCheckSMEligiability (@CourseID INT, @StudentID INT)
	RETURNS BIT 
	AS
	BEGIN
	DECLARE @IS_Eligible BIT ,
			@num_failed_courses_Even INT ,
			@num_failed_courses_Odd INT ,
			@IF_course_firstMakeup INT ,
			@CurrentSemesterCode VARCHAR(40)
			
		SELECT @CurrentSemesterCode=semester_code FROM Course_Semester WHERE course_id = @CourseID

		SET  @num_failed_courses_Even  = dbo.FN_num_of_falied_courses_HELPER ('Spring%' ,'S%[^R]%' ,'%Round 2%'  ,'%R2%' ,  @CourseID  , @StudentID )
		SET  @num_failed_courses_Odd   = dbo.FN_num_of_falied_courses_HELPER ('Winter%'  ,'W%','%Round 1%'  ,'%R1%', @CourseID , @StudentID )

		SELECT @IF_course_firstMakeup=COUNT(*)
		FROM  Student_Instructor_Course_Take 
		WHERE course_id = @CourseID AND
			  student_id = @StudentID AND
			  semester_code = @CurrentSemesterCode AND
			  exam_type = 'First_makeup' AND
			  (NOT (grade IS NULL OR grade
   					 LIKE 'FF' OR grade LIKE 'F' OR grade LIKE 'FA'))
 
		IF @IF_course_firstMakeup <> 0

			BEGIN SET @IS_Eligible =0 END

		ELSE IF ( @CurrentSemesterCode LIKE 'Spring%' OR @CurrentSemesterCode LIKE '%Round 2%' OR 
				  @CurrentSemesterCode LIKE '%R2%' OR @CurrentSemesterCode LIKE 'S%[^R]%' )
		BEGIN
			IF ( @num_failed_courses_Even < 2  )
				BEGIN SET @IS_Eligible = 1 END
			ELSE 
				BEGIN   
					SET @IS_Eligible = 0 
				END
		END
		ELSE IF ( @CurrentSemesterCode LIKE 'Winter%' OR @CurrentSemesterCode LIKE '%Round 1%' 
				OR @CurrentSemesterCode LIKE '%R1%' )
		BEGIN
			IF ( @num_failed_courses_Odd < 2  )
				BEGIN SET @IS_Eligible = 1 END
			ELSE 
				BEGIN 
					SET @IS_Eligible = 0 
				END
		END
    RETURN @IS_Eligible ;
END;

-- KK)
GO
CREATE PROCEDURE  Procedures_StudentRegisterSecondMakeup
	@StudentID int, 
	@courseID int, 
	@Student_Current_Semester Varchar (40)
	AS
	DECLARE @IS_SecoundMakeup_Eligible BIT 
	SET @IS_SecoundMakeup_Eligible = dbo.FN_StudentCheckSMEligiability(@courseID,@StudentID  )

	IF @IS_SecoundMakeup_Eligible = 0
		BEGIN PRINT('YOU CANT REGISTER FOR THE SECOUND MAKEUP ') END
	ELSE
		BEGIN

			IF @Student_Current_Semester IN (SELECT semester_code
			FROM Student_Instructor_Course_Take
			WHERE student_id = @StudentID AND
				  exam_type = 'First_makeup' AND
				  course_id = @courseID     ) 
			BEGIN PRINT('YOU CANT TAKE TWO MAKEUPS IN THE SAME SEMESTER') END
			ELSE
			BEGIN
				UPDATE Student_Instructor_Course_Take
			SET exam_type = 'Second_makeup' ,
				grade = NULL
			WHERE semester_code = @Student_Current_Semester AND
				  student_id = @StudentID AND
				  course_id = @courseID AND 
				  exam_type = 'First_makeup'
			END
		
		END	
--------------------------------------------------Courses Procedures---------------------------------------------------------------------------
-- LL) 
GO
CREATE PROCEDURE  Procedures_ViewRequiredCourses
	 @Student_ID int,
	 @Current_semester_code Varchar (40)
	 AS 
	 SELECT c1.course_id , c1.name , c1.major ,c1.is_offered ,c1.credit_hours ,c1.semester
	 FROM ( Course c1 INNER JOIN Student_Instructor_Course_Take SC ON c1.course_id = SC.course_id
					  INNER JOIN Student S ON SC.student_id = S.student_id )
	 WHERE  S.student_id = @Student_ID AND
			c1.semester <= S.semester AND
		    ( SC.grade = 'F' OR SC.grade ='FF' OR SC.grade = 'FA' OR  SC.grade IS NULL ) AND               -- check for grade
			dbo.FN_IS_COURSE_OFFERED_HELPER(c1.course_id , @Current_semester_code) = 1 --check if course offered in current semester
GO 
-- MM) Check again
CREATE PROCEDURE Procedures_ViewOptionalCourse
	 @Student_ID int,
	 @Current_semester_code Varchar(40)
	AS
	SELECT c.course_id , c.name , c.major ,c.is_offered ,c.credit_hours ,c.semester
	FROM Course c 
	WHERE dbo.FN_IS_COURSE_OFFERED_HELPER(c.course_id , @Current_semester_code) = 1 AND  -- course is offered 
		  dbo.FN_IS_prerequisite_Courses_TAKEN_HELPER(@Student_ID , c.course_id) =1 AND  -- Took all prerequisite
		  NOT EXISTS  ( SELECT * FROM dbo.FN_FIND_REQ_Courses_HELPER (@Student_ID   , @Current_semester_code  , c.course_id))  --not required
GO
-- NN) 
CREATE PROCEDURE Procedures_ViewMS
	@StudentID int
	AS
	(SELECT c.* FROM Course c INNER JOIN Student S ON c.major = S.major ) 
	EXCEPT 
	(SELECT c1.*
	 FROM   Student_Instructor_Course_Take SC INNER JOIN Student S ON S.student_id = SC.student_id 
											  INNER JOIN Course c1 ON c1.course_id = SC.course_id
	 WHERE  SC.student_id = @StudentID AND
			c1.major = S.major
	)
GO
-- OO)
CREATE PROCEDURE Procedures_ChooseInstructor
	 @StudentID int, 
	 @InstructorID int,
	 @CourseID int ,
	 @current_semester_code varchar(40) 
	 AS
	 UPDATE Student_Instructor_Course_Take
	 SET instructor_id = @InstructorID
	 WHERE student_id =@StudentID AND course_id = @CourseID AND semester_code = @current_semester_code

