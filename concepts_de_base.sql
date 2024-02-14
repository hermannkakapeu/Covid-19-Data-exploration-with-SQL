/*
CREATE Table ... ()
Insert into ... Values()
Drop table if exists ...

Select statement
*, TOP, Distinct, count, As, Max, Min, Avg
*/

/*
Where statement
=, <>, <, >, And, Or, Like{%}, is Null,is Not Null, In
*/

/*
Group by ... , ...   
Order by ... asc/desc, ... asc/desc
les trois points peuvent etre remplacés par des noms de colonne ou par leur numero
exemble : Order by FirstName, 5
*/

select *
from EmployeeDemographics 
where LastName like 'S%'

select Gender, count(LastName)
from EmployeeDemographics
group by Gender

/*
JOINS :
		Select *
		from X inner join Y
		ON X.col1 = Y.col2

Inner Join, Full Outer Join, Left Outer Join, Right Outer Join
équiv python : pd.merge(df1, df2, on='Columns')
		  On : pd.merge(df1, df2, left_on='col1', right_on='col2')
*/

select *
from EmployeeDemographics inner join EmployeeSalary
on EmployeeDemographics.Employee_ID=EmployeeSalary.EmployeeID

/*
UNION : c est un peu l equiv des concatenations
suivant la verticale en python.
équiv python : pd.concat([df1, df2], axis=1)
*/

select Employee_ID, FirstName, Age 
from SQLtutorial.dbo.EmployeeDemographics
UNION
select *
from SQLtutorial.dbo.EmployeeSalary

/*
Case statement :
				CASE 
					WHEN ... THEN
					WHEN ... THEN
					ELSE ...
*/
select FirstName, LastName, Age,
case 
	When Age <=22 then 'baby'
	else 'Adulte'
end
FROM EmployeeDemographics

select FirstName, Age, JobTitle, Salary,
	Case
		when JobTitle IN ('Director', 'HR') then Salary + (Salary* .15)
		when JobTitle = 'Acountant' then Salary + (Salary* .10)
		Else Salary + (Salary* .05)
	end as Incresed_salary
from EmployeeDemographics as D join EmployeeSalary as S
	ON D.Employee_ID=S.EmployeeID
Order by Incresed_salary DESC

/*
Having Statement :
	il vient generalement après 'Group by'
	pour mettre une condition sur les valeurs de l'aggregation
*/

select Gender, count(LastName)
from EmployeeDemographics
group by Gender 
having count(LastName) < 3

/*
Udating : remplacer ou actualiser une entrée
Deleting : Supprimer une entrée
*/
select * 
from EmployeeDemographics
order by Employee_ID 

update EmployeeDemographics
set Employee_ID=10
where FirstName='Hermann'

update EmployeeDemographics
set Age=22, Gender='Malesss'
where FirstName = 'Hermann'

DELETE 
from EmployeeDemographics
where FirstName = 'Hermann'

/*
Alliasing : change the names of columns or tables to get more flexibility
*/

/*
Partition by : similaire a Group by, 
sauf qu il ne reduit pas les ligne mais met les resultats du cluster
sur toutes les lignes
*/

Select FirstName, LastName, Gender,salary,
	count(Gender) over (Partition by Gender) as totalGender
from EmployeeDemographics D join EmployeeSalary S
	On D.Employee_ID=S.EmployeeID

/*
CTEs (Common Table Expression) : une sorte de sous-requete équivalente aux variables
	   en python ou lon stoque des donnees, ici c est des requets
	   qui son stoquées
*/

with CTE_emplyee as 
(Select FirstName, LastName, Gender,salary,
	count(Gender) over (Partition by Gender) as totalGender
from EmployeeDemographics D join EmployeeSalary S
	On D.Employee_ID=S.EmployeeID)

select *
from CTE_emplyee

/*
Temp TABLEs : c est des tables comme les autres sauf que ces tables 
			  sont temporarires et son stockées qqpart 

it can be used for processing speed and much more
*/

create table #temp_Employee(
LastName varchar(50), 
Gender varchar(50),
salary int,
totalGender int
)

select *
from #temp_Employee

Insert into #temp_Employee
Select  LastName, Gender,salary,
	count(Gender) over (Partition by Gender) as totalGender
from EmployeeDemographics D join EmployeeSalary S
	On D.Employee_ID=S.EmployeeID

select *
from #temp_Employee

/*
String Functions : TRIM, LTRIM, RTRIM, 
REPLACE(col. 'str', 'NewStr'), SUBSTRING(col, n, m) --> python : str[n,m]
upper, Lower
NB: ces fonction agissent sur les colonnes
*/

/*
Store Procedures: c est aussi comme les tables temporelles
				les procedures stoquent les requetes select

	NB: une fois une procedure créée, il faut actualiser le dossier Programmabilite->procedures stockées
*/


create PROCEDURE TEST
as
Select  LastName, Gender,salary,
	count(Gender) over (Partition by Gender) as totalGender
from EmployeeDemographics D join EmployeeSalary S
	On D.Employee_ID=S.EmployeeID

EXEC TEST
