﻿GO
----------------------------------
CREATE PROC Procedures_AdvisorRegistration
	 @name VARCHAR(40),
	 @password VARCHAR(40), 
	 @email VARCHAR(40), 
	 @office VARCHAR(40),
	 @advisor_id INT OUTPUT
	 AS
	 IF @name IS NULL OR @password IS NULL OR @email IS NULL OR @office IS NULL 
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	 ELSE
		BEGIN 
			 SELECT @advisor_id = MAX(advisor_id) + 1 FROM Advisor;
			 INSERT INTO Advisor(advisor_id,name,password,email,office) VALUES(@advisor_id,@name,@password,@email,@office);
		END
	 GO
	 DECLARE 
	 @result INT;
	 EXEC Procedures_AdvisorRegistration 
	 @name = 'RAED',
	 @password = 'JOUMAA',
	 @email = 'HOTMAIL',
	 @office = 'C6205',
	 @advisor_id = @result OUTPUT;


GO
CREATE PROC Procedures_AdminListStudents
	AS
	SELECT * FROM Student;
	GO
	EXEC Procedures_AdminListStudents;

GO 
CREATE PROC Procedures_AdminListAdvisors
	AS
	SELECT * FROM Advisor;
	GO
	EXEC Procedures_AdminListAdvisors;

GO
CREATE PROC AdminListStudentsWithAdvisors
	AS
	SELECT Student.f_name,Student.l_name , Advisor.name
	FROM Student INNER JOIN Advisor ON Student.advisor_id = Advisor.advisor_id;
	GO
	EXEC AdminListStudentsWithAdvisors

GO
CREATE PROC AdminAddingSemester 
	@start_date DATE,
	@end_date DATE,
	@semester_code VARCHAR(40)
	AS
	IF @start_date IS NULL OR @end_date IS NULL OR @semester_code IS NULL 
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Semester VALUES(@semester_code,@start_date,@end_date);
		END
	GO
	EXEC AdminAddingSemester
	@start_date = '2003-01-24',
	@end_date = '2075-01-24' ,
	@semester_code = '';

GO
-----------------------
CREATE PROC Procedures_AdminAddingCourse 
	@major VARCHAR (40), 
	@semester INT, 
	@credit_hours INT, 
	@name VARCHAR (40), 
	@is_offered BIT
	AS
	DECLARE @courseID INT;
	SELECT @courseID = MAX(course_id) + 1 FROM Course;

	IF @major IS NULL OR @semester IS NULL OR @credit_hours IS NULL OR @name IS NULL OR @is_offered IS NULL 
		BEGIN
			PRINT('CAN T DO THIS SERVICE');
		END
	ELSE
		BEGIN
			INSERT INTO Course(course_id,name,major,is_offered,credit_hours,semester) VALUES(@courseID,@name,@major,@is_offered,@credit_hours,@semester);
		END
	GO
	EXEC Procedures_AdminAddingCourse
	@major = '',
	@semester = 1,
	@credit_hours = 4,
	@name ='',
	@is_offered =0;
	

GO
CREATE PROC Procedures_AdminLinkInstructor
	@instructor_id INT,
	@course_id INT,
	@slot_id INT
	AS
	IF @instructor_id IS NULL OR @course_id IS NULL OR @slot_id IS NULL 
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	IF 
		not exists(SELECT instructor_id FROM Instructor WHERE instructor_id=@instructor_id) OR
		not exists(SELECT course_id FROM Course WHERE course_id=@course_id)OR
		not exists(SELECT slot_id FROM Slot WHERE slot_id=@slot_id)
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Slot(slot_id,course_id,instructor_id) VALUES(@slot_id,@course_id,@instructor_id);
		END
	
	GO
	EXEC Procedures_AdminLinkInstructor
	@instructor_id = 1,
	@course_id = 1,
	@slot_id = 1;

GO 
CREATE PROC Procedures_AdminLinkStudent
	@instructor_id INT,
	@student_id INT,
	@course_id INT,
	@semester_code VARCHAR(40)
	AS
	IF @instructor_id IS NULL OR @student_id IS NULL OR @course_id IS NULL OR @semester_code IS NULL  
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	IF 
		not exists(SELECT instructor_id FROM Instructor WHERE instructor_id=@instructor_id) OR
		not exists(SELECT course_id FROM Course WHERE course_id=@course_id)OR
		not exists(SELECT student_id FROM Student WHERE student_id=@student_id)OR
		not exists(SELECT semester_code FROM Semester WHERE semester_code=@semester_code)
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Student_Instructor_Course_Take(student_id,course_id,instructor_id,semester_code) VALUES(@student_id,@course_id,@instructor_id,@semester_code);
		END
	GO
	EXEC Procedures_AdminLinkStudent
	@instructor_id = 1,
	@student_id = 1,
	@course_id = 1,
	@semester_code = '';

GO 
CREATE PROC Procedures_AdminLinkStudentToAdvisor
	@student_id INT,
	@advisor_id INT
	AS
	IF  @student_id IS NULL OR @advisor_id IS NULL  
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	IF
		not exists(SELECT student_id FROM Student WHERE student_id=@student_id)OR
		not exists(SELECT advisor_id FROM Advisor WHERE advisor_id=@advisor_id)
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	ELSE
		BEGIN
			INSERT INTO Student(student_id,advisor_id) VALUES(@student_id,@advisor_id);
		END
	GO
	EXEC Procedures_AdminLinkStudentToAdvisor
	@student_id =1,
	@advisor_id =1;

GO
-------------------------------
CREATE PROC Procedures_AdminAddExam
	@Type VARCHAR (40),
	@date DATETIME,
	@course_id INT
	AS
	IF @Type IS NULL OR @date IS NULL OR @course_id IS NULL
		BEGIN
			PRINT('CAN T DO THIS SERVICE')
		END
	ELSE 
		BEGIN
			INSERT INTO MakeUp_Exam(date,type,course_id) VALUES(@date,@Type,@course_id);
		END
	GO
	EXEC Procedures_AdminAddExam 
	@Type = '',
	@date = '',
	@course_id =1;

