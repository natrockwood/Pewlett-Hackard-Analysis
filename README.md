# Pewlett-Hackard-Analysis

Pewlett Hackard is a company that has a lot of employees, and a lot of those employees may be going into retirement quickly. Bobby, and HR Analyst, is conducting an employee research to see which employees may be retiring, and with that, he has to see how many positions will need to be filled because of those retiring employees.

We are using the data provided to be able to build an Employee Database, since the company never did. With this database, we can help Bobby with the Employee Research and determine who will be retiring in the company and which positions and how many positions need to be filled to keep the company afloat.

In this analysis, there were a series of steps that needed to take place to solve the problem. There were also a couple bumps in the road that were smoothed out after tinkering with the code a little bit.

#### Knowing the data.
The first step in the whole process, is the same as all types of analytical problems—knowing the data. With this step, we can better understand what types of data we’re dealing with.

#### Creating ERDs and relationships between the data.
After we know what kind of data we're dealing with across the board, we can visualize the data with the help of Entity Relationship Diagrams, or ERDs. 

The ERD created for this analysis was created to determine the relationship between the different data types in the CSV data tables provided.

Our diagram shows the following findings:
- Each department has one manager, and many employees
- There are many departments and each department has many employees
- Each employee has a title. Though there are many titles, only one can be assigned to an employee.

![ERD](https://github.com/natrockwood/Pewlett-Hackard-Analysis/blob/master/EmployeeDB.png)

After knowing and creating the physical diagrams for the data, we then load the data into the tables built out in pgAdmin. The code below is the Employees table built out:
```
CREATE TABLE employees (
     emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
```

There were problems in importing some data since I did not have the Primary Keys and Foreign Keys in the right place. Knowing which attributes will be the Foreign Keys and where they’ll be referenced in other tables, helps narrow down the relationship between all tables.

Another good point that I learned when creating tables was that you cannot create the table of the same name if it was already ran. You’d have to drop the table using the DROP method, and re-upload the table that you’d want. This case, you can start from scratch. 

#### The Findings
From the many tables we built out, we can then make relations in between the tables. 

After making relationships between all the different databases we've looked through, we then narrow down current employees that are eligible for retirement. This number was done by determining when each employee was born and when they were hired. However, that just shows *all* employees that were hired between those dates. Some employees may have left the company, so we narrow that data down even more to the number of current employees that are eligible for retirement. 

The number of eligible employees for retirement can be determined from the *retiring_emps* query. The number we get from this is **33,118**.
```
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
```

We also determined the number of employees that are retiring per title. This can be found in the *num_retiring_by_title* table. The Senior Engineers and Senior Staff employees take up the bulk of the people retiring.

Title | Count of Employees
------|-------------------
Assistant Engineer | 251
Engineer | 2,711
Manager | 2
Senior Engineer | 13,651
Senior Staff | 12,872
Staff | 2,022
Technique Leader | 1,609

```
SELECT title,
	COUNT(emp_no)
INTO num_retiring_by_title
FROM retiring_most_recent_title
GROUP BY title
ORDER BY title;
```

Since there are a number of people retiring, we look the number of individuals available for a mentorship role. To qualify, we need to see which employees were born in 1965. We were able to get a list of these employees through the query *mentorship_eligible*. We were able to determine that there are 1,940 current employeees that are eligible for the mentorship program.

```
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
```

Something that would be worth exploring would be which departments had the highest retention rate. From this, we could determine which departments are worth having a lot of employees, and which could afford to have a lot less employees. This could also be determined by knowing the profit being made by the company and to check whether or not having so many employees is a benefit to the company or not.

To conclude, PH has a lot of employees that are retiring, but also, they have a decent amount of employees that can mentor the next wave of employees the company would eventually hire.
