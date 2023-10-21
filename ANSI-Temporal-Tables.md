# ANSI Temporal Tables

Temporal tables are generally used to represent states of an object (as distinct from events).

 

State tables define the state of an object.

 

Example: When an employee changes department, add a new row and update valid and transaction times for the employee to reflect the change.

 

Teradata temporal tables are often used to implement "state of" processing:

Identified by a time period
Identified by slowly changing states
 

Event tables define the occurrence of an event.

 

Example: When a stock falls below a given price, log it and trigger a sale of some shares.

 

Teradata queue tables are used to implement event processing:

Identified by an instance, such as timestamp.
Characterized by quickly changing events that may require some action.
 

Two events describe the begin and end of an object state. Another way to think about it is that the state of an object is delimited by beginning and ending events.

