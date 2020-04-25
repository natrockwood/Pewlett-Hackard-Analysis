-- Create and import data tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no)
);

CREATE TABLE employees (
	 emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(20) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no,title,from_date)
);

CREATE TABLE dept_employees (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

-- # of emps eligible for retirement: 41,380 employees
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring: 41,380 employees
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--Table 1A: number of current employees who are about to retire
-- Create new table for retiring employees: 33,118
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO retiring_emps
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_employees as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND de.to_date = ('9999-01-01')

SELECT * FROM retiring_emps;

--Table 1B: current employees grouped by job title: 443,308
SELECT emp.emp_no,
	emp.first_name,
	emp.last_name,
	ti.title,
	ti.from_date,
	ti.to_date,
	s.salary
--INTO current_emps_title
FROM employees AS emp
	INNER JOIN titles AS ti
		ON (emp.emp_no = ti.emp_no)
	INNER JOIN salaries AS s
		ON (emp.emp_no = s.emp_no)
		
--Table 1C: retiring employees grouped by job title: 54,772
SELECT re.emp_no,
	re.first_name,
	re.last_name,
	ti.title,
	ti.from_date,
	ti.to_date,
	s.salary
INTO retiring_emps_title
FROM retiring_emps AS re
	INNER JOIN titles AS ti
		ON (re.emp_no = ti.emp_no)
	INNER JOIN salaries AS s
		ON (re.emp_no = s.emp_no)

SELECT * FROM retiring_emps_title;

--Table 1D: Partitioning: 33,118 Retiring Employees (24k duplicate/switched positions)
SELECT emp_no,
 first_name,
 last_name,
 from_date,
 to_date,
 title,
 salary
INTO retiring_most_recent_title
FROM
 (SELECT emp_no,
 first_name,
 last_name,
 from_date,
 to_date,
 title,
 salary,
  ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM retiring_emps_title
 ) tmp WHERE rn = 1
ORDER BY emp_no;

SELECT * FROM retiring_most_recent_title;

--Table 1E: Emp Count - Retiring by Title
SELECT title,
	COUNT(emp_no)
INTO num_retiring_by_title
FROM retiring_most_recent_title
GROUP BY title
ORDER BY title;

SELECT * FROM num_retiring_by_title;

--Table 2: Mentorship Eligibilty: 1,940
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31')

--Table 2A: Current employees elibigle for mentorship
SELECT emp.emp_no,
	emp.first_name,
	emp.last_name,
	ti.title,
	ti.from_date,
	ti.to_date
INTO mentorship_eligible
FROM employees AS emp
INNER JOIN titles AS ti
ON emp.emp_no = ti.emp_no
WHERE (emp.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
AND ti.to_date = ('9999-01-01');

SELECT * FROM mentorship_eligible;