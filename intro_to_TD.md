# Teradata Database Features
      
The Teradata database is a high-performance database system that processes enormous quantities of detail data that are beyond the capability of conventional systems.
The system is specifically designed for large data warehouses. From the beginning, the Teradata database was created to store, access and manage large amounts of data.

Hundreds of terabytes of storage capacity are currently available, making it an ideal solution for enterprise data warehouses and even for smaller data marts.

Parallel processing distributes data across multiple processors evenly. The system is designed such that the components divide the work up into approximately equal pieces. This keeps all the parts busy all the time and enables the system to accommodate a larger number of users and/or more data.

Open architecture adapts readily to new technology. As higher-performance industry standard computer chips and disk drives are made available, they are easily incorporated into the architecture. Teradata runs on industry standard operating systems as well.

Linear scalability enables the system to grow to support more users/data/queries/query complexity, without experiencing performance degradation. As the configuration grows, performance increase is linear, slope of 1.

The Teradata database currently runs as a database server on a variety of hardware platforms for single node or Symmetric Multi-Processor (SMP) systems, and on Teradata hardware for multi-node Massively Parallel Processing (MPP) systems.

# Relational Databases

A column is an attribute of the entity that a table represents. A column always contains like data, such as part name, supplier name, or employee number. In the example below, the column named LAST NAME contains last name and never anything else. Columns should contain atomic data, so a phone number might be divided into three columns; area code, prefix, and suffix, so drill-down analysis can be performed. Column position in the table is arbitrary. Missing data values are represented by "nulls", or the absence of a value.

A row is one instance of all the columns of a table. It is a single occurrence of an entity in the table. In our example, all information about a single employee is in one row. The sequence of the rows in a table is arbitrary.

In a relational database, tables are defined as a named collection of one or more named columns that can have zero or many rows of related information. Notice that the information in each row of the table refers to only one person. There are no rows with data on two people, nor are there rows with information on anything other than people. This may seem obvious, but the concept underlying it is very important.

Each row represents an occurrence of an entity defined by the table. An entity is defined as a person, place, thing, or event about which the table contains information. In this case, the entity is the employee.

Note: In relational math we use the term:

- Table to mean a relation.
- Row to mean a tuple.
- Column to mean an attribute.

# Normalized Data Model vs. Star Schema Model
      
As a model is refined, it passes through different states which can be referred to as normal forms. A normalized model includes:

- Entities - One record in a table
- Attributes - Columns
-Relationships - Between tables

First normal form (1NF) rules state that each and every attribute within an entity instance has one and only one value. No repeating groups are allowed within entities.

Second normal form (2NF) requires that the entity must conform to the first normal form rules. Every non-key attribute within an entity is fully dependent upon the entire key (key attributes) of the entity, not a subset of the key.

Third normal form (3NF) requires that the entity must conform to the first and second normal form rules. In addition, no non-key attributes within an entity is functionally dependent upon another non-key attribute within the same entity.

While the Teradata database can support any data model that can be processed via SQL; an advantage of a normalized data model is the ability to support previously unknown (ad-hoc) questions.

## Star Schema

The star schema (sometimes referenced as star join schema) is the simplest style of data warehouse schema. The star schema consists of a few fact tables (possibly only one, justifying the name) referencing any number of dimension tables. The star schema is considered an important special case of the snowflake schema.
Some characteristics of a Star Schema model include:

- They tend to have fewer entities
- They advocate a greater level of denormalization

# Primary Keys
      
Tables are made up of rows and columns and represent entities and attributes. Entities are the people, places, things, or events that the tables model. A Primary Key is required for every logical model version of a table, because each entity holds only one type of tuple (i.e., a row about a person, place, thing or event), and each tuple is uniquely identified within an entity by a Primary Key (PK).

| EMPLOYEE NUMBER | MANAGER EMPLOYEE NUMBER | DEPARTMENT NUMBER | JOB CODE | LAST NAME | FIRST NAME | HIRE DATE | BIRTH DATE | SALARY AMOUNT |
|-----------------|-------------------------|-------------------|----------|-----------|------------|-----------|------------|---------------|
|        PK       |                         |                   |          |           |            |           |            |               |
| 1006            | 1019                    | 301               | 312101   | Stein     | John       | 861015    | 631015     | 3945000       |
| 1008            | 1019                    | 301               | 312102   | Kanieski  | Carol      | 870201    | 680517     | 3925000       |
| 1005            | 0801                    | 403               | 431100   | Ryan      | Loretta    | 861015    | 650910     | 4120000       |
| 1004            | 1003                    | 401               | 412101   | Johnson   | Darlene    | 861015    | 560423     | 4630000       |
| 1007            |                         |                   |          | Villegas  | Arnando    | 870102    | 470131     | 5970000       |
| 1003            | 0801                    | 401               | 411100   | Trader    | James      | 860731    | 570619     | 4785000       |

## Primary Key Rules

- A Primary Key uniquely identifies each tuple within an entity. A Primary Key is required, because each tuple within an entity must be able to be uniquely identified.
- No duplicate values are allowed. The Primary Key for the EMPLOYEE table is the employee number, because no two employees can have the same number.
- Because it is used for identification, the Primary Key cannot be null. There must be something in that field to uniquely identify each occurrence.
- Primary Key values should not be changed. Historical information, as well as relationships with other entities, may be lost if a PK value is changed or re-used.
- Primary Key can include more than one attribute. In fact, there is no limit to the number of attributes allowed in the PK.
- Only one Primary Key is allowed per entity.

# Evolution of Data Processing
      
Traditionally, data processing has been divided into two categories: On-Line Transaction Processing (OLTP) and Decision Support Systems (DSS). For either, requests are handled as transactions. A transaction is a logical unit of work, such as a request to update an account.

## Traditional

A transaction is a logical unit of work.

### On-Line Transaction Processing (OLTP)

OLTP is typified by a small number of rows (or records) or a few of many possible tables being accessed in a matter of seconds or less. Very little I/O processing is required to complete the transaction. This type of transaction takes place when we take out money at an ATM. Once our card is validated, a debit transaction takes place against our current balance to reflect the amount of cash withdrawn. This type of transaction also takes place when we deposit money into a checking account and the balance gets updated. We expect these transactions to be performed quickly. They must occur in real time.

### Decision Support Systems (DSS)

Decision support systems include batch reports, which roll-up numbers to give business the big picture, and over time, have evolved. Instead of pre-written scripts, users now require the ability to do ad hoc queries, analysis, and predictive what-if type queries that are often complex and unpredictable in their processing. These types of questions are essential for long range, strategic planning. DSS systems often process huge volumes of detail data and rely less on summary data.

## Today

Functional Trends Rankings

### On-line Analytical Processing (OLAP)

OLAP is a modern form of analytic processing within a DSS environment. OLAP tools (e.g., from companies like MicroStrategy and Cognos) provide an easy to use Graphical User Interface to allow "slice and dice" analysis along multiple dimensions (e.g., products, locations, sales teams, inventories, etc.). With OLAP, the user may be looking for historical trends, sales rankings or seasonal inventory fluctuations for the entire corporation. Usually, this involves a lot of detail data to be retrieved, processed and analyzed. Therefore, response time can be in seconds or minutes.

### Data Mining (DM)

DM (predictive modeling) involves analyzing moderate to large amounts of detailed historical data to detect behavioral patterns (e.g., buying, attrition, or fraud patterns) that are used to predict future behavior. An "analytic model" is built from the historical data (Phase 1: minutes to hours) incorporating the detected patterns. The model is then run against current detail data ("scoring") to predict likely outcomes (Phase 2: seconds or less). Likely outcomes, for example, include scores on likelihood of purchasing a product, switching to a competitor, or being fraudulent.

|     Type    |                                                                      Examples                                                                      |              Number of Rows Accessed             |                    Response Time                   |
|:-----------:|:--------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------:|:--------------------------------------------------:|
| OLTP        | Update a checking account to reflect a deposit. Debit transaction takes place against current balance to reflect amount of money withdrawn at ATM. | Small                                            | Seconds                                            |
| DSS         | How many child size blue jeans were sold across all of our Eastern stores in the month of March? What were the monthly sale shoes for retailer X?  | Large                                            | Seconds or minutes                                 |
| OLAP        | Show the top ten selling items across all stores for 1997. Show a comparison of sales from this week to last week.                                 | Large of detail rows or moderate of summary rows | Seconds or minutes                                 |
| Data Mining | Which customers are most likely to leave? Which customers are most likely to respond to this promotion?                                            | Moderate to large detailed historical rows       | Phase 1: Minutes or hours Phase 2: Seconds or less |

# Data Warehouse Usage Evolution
      
There is an information evolution happening in the data warehouse environment today. Changing business requirements have placed demands on data warehousing technology to do more things faster. Data warehouses have moved from back room strategic decision support systems to operational, business-critical components of the enterprise. As your company evolves in its use of the data warehouse, what you need from the data warehouse evolves too.

Stage 1 - Reporting: The initial stage typically focuses on reporting from a single source of data to drive decision-making across functional and/or product boundaries. They are typically pre-defined reports, so questions are usually known in advance, such as a weekly sales report.

Stage 2 - Analyzing: Focus on why something happened, such as why sales went down or discovering patterns in customer buying habits. Users perform ad hoc analysis, slicing and dicing the data at a detail level, and questions are not known in advance.

Stage 3 - Predicting: Sophisticated analysts heavily utilize the system to leverage information to predict what will happen next in the business to proactively manage the organization's strategy. This stage requires data mining tools and building predictive models using historical detail. As an example, users can model customer demographics for target marketing.

Stage 4 - Operationalizing: Providing access to information for immediate decision-making in the field enters the realm of Active Data Warehousing. Stages 1 to 3 focus on strategic decision-making within an organization. Stage 4 focuses on tactical decision support. Tactical decision support is not focused on developing corporate strategy, but rather on supporting the people in the field who execute it. Examples: 1) Inventory management with just-in-time replenishment, 2) Scheduling and routing for package delivery, 3) Altering a campaign based on current results.

Stage 5 - Active Warehousing: The larger the role an ADW plays in the operational aspects of decision support, the more incentive the business has to automate the decision processes. You can automate decision-making when a customer interacts with a web site. Interactive customer relationship management (CRM) on a web site or at an ATM is about making decisions to optimize the customer relationship through individualized product offers, pricing, content delivery and so on. As technology evolves, more and more decisions become executed with event-driven triggers to initiate fully automated decision processes. Example: Determine the best offer for a specific customer based on a real-time event, such as a significant ATM deposit.

# Teradata Database Objects
      
A "database" or "user" in Teradata database systems is a collection of objects such as tables, views, macros, triggers, stored procedures, user-defined functions, or indexes (join and hash). Database objects are created and accessed using standard Structured Query Language or SQL. Starting with Teradata Release 14.10, extended object names feature, allows object names to be up to 128 characters where prior it was a 30-byte limit.
All database object definitions are stored in a system database called the Data Dictionary/Directory (DD/D).

Databases provide a logical grouping for information. They are also the foundation for space allocation and access control.

## Tables

A table is the logical structure of data in a relational database. It is a two-dimensional structure made up of columns and rows.

## Views

A view is a pre-defined subset of one of more tables or other views. It does not exist as a real table, but serves as a reference to existing tables or views. One way to think of a view is as a virtual table. Views have definitions in the data dictionary, but do not contain any physical rows. Views can be used to implement security and control access to the underlying tables. They can hide columns from users, insulate applications from changes, and simplify or standardize access techniques. They provide a mechanism to include a locking modifier. Views provide a well-defined and tested high performance access to data. X-Views are special Views that limit the display of data to the user who accesses them.

## Macros

A macro is a predefined, stored set of one or more SQL commands and optionally, report formatting commands. Macros are used to simplify the execution of frequently used SQL commands. Macros may also be used to limit user access to data.

## Triggers

A trigger is a set of SQL statements usually associated with a column or a table and when that column changes, the trigger is fired - effectively executing the SQL statements.

## Stored Procedures

A stored procedure is a program that is stored within Teradata and executes within the Teradata database. A stored procedure uses permanent disk space and may be used to limit a user's access to data.

## User Defined Functions (UDF)
A User-Defined Function (UDF) allows authorized users to write external functions. Teradata allows users to create scalar functions to return single value results, aggregate functions to return summary results, and table functions to return tables. UDFs may be used to protect sensitive data such as personally identifiable information (PII), even from the DBA(s).

# Teradata Database Space
      
There are three types of space within the Teradata database:

1. Perm Space

All databases and users have a defined upper limit of Permanent Space. Permanent Space is used for storing the data rows of tables. Perm Space is not pre-allocated. It represents a maximum limit.

2. Spool Space
All databases also have an upper limit of Spool Space. If there is no limit defined for a particular database or user, limits are inherited from parents. Theoretically, a user could use all of the unallocated space in the system for their query. Spool Space is unused Perm Space that is used to hold intermediate query results or formatted answer sets for queries. Once the query is complete, the Spool Space is released.
Example: You have a database with total disk space of 100GB. You have 10GB of user data and an additional 10GB of overhead. What is the maximum amount of Spool Space available for queries?

Answer: 80GB. All of the remaining space in the system is available for spool.

3. Temp Space
The third type of space is Temporary Space. Temp Space is used for global temporary tables, and these results remain available to the user until their session is terminated. Tables created in Temp Space will survive a restart. Temp Space is permanent space currently not used.