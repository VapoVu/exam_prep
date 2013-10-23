#Advanced SAS Certification

http://catalog.lib.ncsu.edu/record/NCSU2810341

##Intro

###Benchmarking 

`OPTIONS STIMER | NOSTIMER` - Shows CPU, Real Time stats in the log 

`OPTIONS FULLSTIMER | NOFULLSTIMER` - writes all available sys performance to log

##Controlling IO & Data Storage Space

Input Raw Data - File caching is good if you are reading data multiple times.

IO Steps

- Input Buffer (one file block moved into memory at a time)
- Loads 1 record at a time into PDV 
- SAS stores numeric values as floating point (scientific notation). It is a representation if comes from infile statement (instead of SAS data set)
- Costs more CPU time 
- Write to output buffer  

Reducing IO

- Reducing the number of variables - only use what is necessary
- Reducing the number of times that data is processed
- Controlling length of numeric variables
 - Dates can usually fit in 4 bytes
 - Only use length for integers, not for decimals (if you want precision)
 - SAS doesn't truncate the values in the PDV. Truncation occurs when outputting to the data set.
- `SASFILE` reduces IO but costs extra memory. Loads entire SAS data set into memory. Submit a second one to close it out of memory
 - `SASFILE 'SAS-data set' LOAD;`
 - `SASFILE 'SAS-data set' CLOSE;`

###Compression 
 
- Additional overhead per observation
- Each observation can have a different length. Consecutive repeating characters, numbers are reduced in size.
- Reuse deleted observations if `reuse=yes` option is enabled
- Requires less disc storage space (and I/O), but increases CPU time

**Creating Compressed Data Set**

- `Compress = NO | YES | CHAR | BINARY`
- `REUSE = NO | YES` - SAS can reuse deleted space (by adding new observations anywhere there is space.  If you are appending/deleting many observations, set this option to NO because it is less 
- `POINTOBS = YES | NO` - allow random access of observations w/n compressed data sets (instead of sequentially). Mutually exclusive with Reuse. (only can use one).  Adds some CPU overhead.  
- Compression Algorithms
 - Run-Length Encoding (Char - repeated characters, blanks)
 - Ross Data Compression (Binary - patterns, integers, or obs w/ more than 1000 bytes)
- These options can be used as a system option or a data-step option right after naming the data set)  

**Tradeoffs**

Compression is NOT good for...

 - few repeated characters
 - short text strings
 - few missing values

All of these add overhead that is greater than the savings. SAS can turn off Compression automatically if it doesn't make sense, but you shouldn't trust it. 

##Indexes

###Benefits

- Access small subsets
- return observations in sorted order 
- perform table lookups
- join & modify observations

Guidelines for Indexing

 - Retrieve a small subset of observations from a large data set
 - Index on variables that are discriminating (unique values). Make the first key variable the most discriminating.
 - Create an index when the data set is used frequently
 - Sort data first, then index it

###Index Details

Simple vs. Composite Index

 - Simple:  Key Variables = Index Name
 - Composite: Multiple Key Variables = Concatenated into one Index Name
 
Tips
 
- Don't delete index files. It will damage the data set because the data set is expecting there to be an index.


**Creating an Index**

- Create a *new* data set and creating an index via `DATA STEP`
  - Simple: `(Index=(index-specification1 ...)) ` on output data set
  - Composite:`(Index=(index-specification1 salesID=(varId1 varId2)...))`
- Creating an index on an *existing* data set
 - `PROC SQL` or `PROC DATASETS`

Additional Options

- `OPTIONS MSGLEVEL=N|I` where N is no and I shows in log that index was created
- `UNIQUE` excludes duplicate values from index
- `NOMISS`excludes obs w/ missing values
 -  `(Index=(index-specification1) / unique / nomiss))`

**PROC DATASETS Notes**

<pre><code>PROC DATASETS Library=libref NOLIST;
	MODIFY SAS-Data-Set-Name;
		Index Delete Sales_ID;
		Index Create Product_ID / unique nomiss;
run;</pre></code>

 - Don't need second slash. Both are only needed in data step
 - Can't modify existing indexes in `PROC DATASETS`. You need to Delete and Recreate. 

**PROC SQL Notes**

View index properties in the Explorer Window -> Properties -> Index

<pre><code>PROC SQL;
	Create index Customer_ID
		ON data-set-name(CUSTOMER_ID)
	Create unique index SalesID 
		ON data-set-name(Order_ID, Sales_ID)
	Drop Index Customer_ID 
		from data-set-name; 
quit;</pre></code>

**Basic Index Usage**

 - When Where expressions are in use
 - Never uses indexes for... 
  - subsetting IF in a data step because IF subsetting occurs after the data has been read into the PDV. Indexes determine which records are read into the PDV.
  - Any function besides trim or substring used in `Where`
  - substr searches for any character besides the first
  - sounds like appears in where
- Compound Optimization can be used when...
	- AND operator 
	- OR - must specify the same variable for both parts of OR
	- `=` or `in` must be used once
- `IDXWHERE=NO | YES` - only really use No option when you know that the index won't optimize it. 
- `(IDXNAME=<Index-Name>)` - use if you know which index would be better. Insert right after data set name. 

Adding data via `PROC APPEND` to a data set that already has an index:

- `PROC APPEND`: SAS does not update the index until all observations are added to the data set. After the append, SAS internally sorts the observations and inserts the data into the index sequentially.

**Maintaining an Index**
 
- `PROC SORT` w/ `FORCE` option allows sorting on an indexed data set, and it deletes user-created indexes. To maintain the index, use `out=new-data-set-name(index=(Customer_ID)`
- `PROC CPORT`: If you need to transfer SAS libraries, catalogs, or data sets from one environment to another or to another version of SAS, you use `PROC CPORT`.  You can specify `index=yes` to transport indexes with the associated data sets. 

**Cons of indexes**

 - extra memory and disk space are required

##Using Lookup Tables to Match Data: Arrays


<pre><code>data compare;
   drop Month1-Month12 Statistic;
   array mon{12} Month1-Month12;
   if _n_=1 then set orion.retail_information
     (where=(Statistic='Median_Retail_Price'));
   set orion.retail;
   Month=month(Order_Date);
   Median_Retail_Price=mon{Month};
   format Median_Retail_Price dollar8.2;
run;
        
proc print data=compare(obs=8);
   title 'Partial Compare Data Set';
run;
           
title;</pre></code>

##Using Lookup Tables to Match Data: Hash Tables

Hash

- In memory storage and retrieval. 
- Doesn't require sorting.
- Exists for the duration of a data step
- Can download hash into a SAS data step 

Key : Data Components

- Key can be numeric, character, or composite
- Data can have multiple columns
- Data set doesn't need to be sorted or indexed
- FIND Method does the key lookup (to return the corresponding data)

SYNTAX: <pre><code> data dataSetName;
	if _n_ = 1 then 
		do;
			declare hash hashName(arg_tag1: value1, dataset: orion.orders, hashexp:10, ordered: 'ascending');
			hashName.definekey('code');
			hashName.defineData('MemberType');
			hashName.defineDone();
	end;
	rc=hashName.FIND(Key: keyValue1, key:ThisYrType);
		if rc1=0 then THisYrMember=MemberType;
	run;	
</pre></code>

- `hashexp:10` identifies 10 data columns
- `ordered:'ascending'` outputs the data in sorted order
- `object.method (arg_tag1:value1)` syntax for hash definition
- `Find` method must be the same variable type as the define key method.
- `if rc=0` indicates there was a match between the hash table and the other table

Misc Tips:

- `CALL MISSING` initializes the key and variables to missing so that warning messages aren't shown in the log.   
 - SYNTAX: `CALL MISSING(keyName, dataName);` 
- Set Length of variables: Need to set the length of the variables (in the PDV) before setting up the hash.
 - `length var1 $ 2` length statement
 - Non executing `SET` statement w/n do loop: `if 0 then set orion.supplier;` which is false but the variables are created during compilation. Note: Don't need `call missing` option if using non-executing set statement.	

**HITER**

HITER (Hash Iterator) - iterating through the hash object without going through sequentially.

Apply after the Hash Object : `DECLARE hiter hashName('Customer')`

Methods for iterating:

 - SYNTAX: `hashName.method();`
 - `name.first()`
 - `name.last()`
 - `name.next()` - starts at first item in hash table if .first wasn't specified
 - `name.prev()` (previous)
 

rc=hashName.Last();

NOTE: SQL could look up these values in a similar manner.

Full Example

<pre><code>data expensive least_expensive;
   drop i;
   if 0 then 
        set orion.shoe_sales;
   if _N_=1 then 
      do;
         declare hash shoes(dataset:'orion.shoe_sales',
                 ordered:'descending');
         shoes.definekey('Total_Retail_Price');
         shoes.definedata('Total_Retail_Price',
                          'Product_ID', 'Product_Name');
         shoes.definedone();
         declare hiter s('shoes');
      end;

      s.first();
      do i=1 to 5;
         output expensive;
         s.next();
      end;

      s.last();
      do i=1 to 5;
        output least_expensive;
        s.prev();
      end; 
      stop;
run;


proc print data=expensive;
  title "The Five Most Expensive Shoes";
run;

proc print data=least_expensive;
  title "The Five Least Expensive Shoes";
run;</pre></code>

##Using Lookup Tables to Match Data: Formats

###`PROC FORMAT`

<pre><code>PROC FORMAT; 
	Value format-name value-or-range=`formatted-value1'...; 
	run;
</pre></code>

- Remember to use a . after a custom format reference in your programs.
- Formats are stored in work.formats catalog by default.  
- Add `library=libref<.catalogName>;` to the `PROC FORMAT`statement 
- Telling SAS where to look for custom formats. `OPTIONS FMTSEARCH=(catalog-specification)`
 - Note: unless you specify `work` in the list of catalog specifications, SAS will search `work` and `library` before searching for catalog specifications you specify.  
- Print format documentation `PROC FORMAT Library=libref FMTLIB;`

Checking contents of format:

<pre><code>PROC Catalog Catalog=libref.formats;
	contents;
run;</pre></code>

###Using a data set to create a format (and vice versa)

- `cntlin=data-set-name` means from a data set to a format
- `cntlout=data-set-name` means from a format to a data set 
- Data set must have the following attributes:
  - FmtName
  - Start
  - Label
  - End (same value as start if not using a range)
  - Type

**Checking your format creation**

<pre><code> proc format library=orion.formats cntlin=country fmtlib;	
	select $country;
run; </pre></code>

Nesting a format within a format to handle missing values

<pre><code>proc format library=orion.formats;
	value $extra
			' '='Unknown'
			other=[$country30.];
	run;</pre></code>

###Maintaining Formats

 - Create a data set using CNTLOUT=option
 - Edit the data set
 - Re-create the format via CNTLIN=option

Using PROC SQL to update the format

<pre><code>proc sql;
	insert into countryFmt (FmtName, Start, End, Label)
		values('$country', 'BR','BR','Brazil')
		values('$country', 'BR','BR','Brazil');
	quit;</pre></code>

###Using formats as Lookup Tables

 - FORMAT Statements
 - Format=options
 - PUT statements
 - PUT functions

Examples:

<pre><code>data supplier_country;
	set orion.shoe_vendors;
	country_name=put(supplier_country,$country.);
run;

PROC FREQ data =orion.supplier_country;
	tables country;
	format country $extra.;
run;</pre></code>

Turn off Error messages for format

`OPTIONS FMTERR|NOFMTERR`


##Using Lookup Tables to Match Data: Combining Data Horizontally

DATA Step  
 
- Set 
 - Concatenate horizontally by using multiple `SET` statements (not multiple data sets in one `SET` statement 
 - Need to be sorted and have a 1:1 relationship
 - Data step must be indexed on By variables
 - 1:1 and 1:many work well and produce the same results as `PROC SQL`
 - When there are missing rows in one or both data sets, use SQL
- Merge
 - BY VARIABLES are the Keys to the Look up
- Update, Modify statements

SQL Joins

 - Inner, Outer, Left, Right Joins
 - Resides in disc instead of memory?

###Using an Index to Combine Data Sets

- changes from sequential to direct access 
  - `set dataSetName key=indexName`
- `_IORC_` sets a variable if SAS finds the observation
- if `_IORC_ = 0`, SAS only uses the matches when joining data sets (not normal for boolean values)

###Combining Summary and Detail Data

`PROC MEANS` automatically creates a report
`PROC SUMMARY` Route statistics to output data set via output out=

<pre><code> Proc Summary data=DataSet;
	var varName
	output out=ouputData;
run;</pre></code>

##Sorting SAS DATA Sets

To see how many CPU cores you have...

<pre><code>proc options  option=cpucount;
run;</pre></code> 

Controlling Threaded Processing

- `Options Threads | No Threads`
- `Proc Sort data=SASDataSET Threads | NoThreads TAGSORT` 
  - `TAGSORT` only stores the by variables and observations from by sort.  Then uses tags to order the observations. Doesn't work with multi-threading.

Controlling the number of processors...

- `Options CPUCOUNT = ACTUAL | 1-1024`

**Sort Space Reqs**

- Need ~4 times the size of the data set for not sorting in place
- Threaded sorts..  
 - take less space
 - require 3 times the size of the data
- `Sortsize=n |nK \NM ` improves speed by not swapping data from memory to disk. Default is 64 MB. Value should be smaller than the available physical memory. 

Sorting Big Data Sets & Changing Sort Algo

- Lots of options...SORTPGM
- 'noequals` will not keep the sort order of the original sort if a second variable is the new sort variable.

**Validating that data is sorted...**

- `OPTIONS SORTVALIDATE;`
- `PROC SORT data=dataset presorted; var varName run;`
 - presorted validates the data is sorted and sorts if it is not;

**Sorting Numbers when in Character Variables...**

<pre><code>proc sort data=datasetname sortseq=linguistic(Numeric_collation=on); 
	var varName; Run; </pre></code> 

- `Numeric_collation=on` sorts 9 before 21
- `linguistic` sorts by the locale option

##Comparing Methods (Arrays, Hash Tables, Formats, Data Sets) to Join

 - Arrays: Fastest, objects should be in order
 - Hash Tables: Flexible, keys don't need to be consecutive
 - Formats: Easy to maintain across programs because if a format changes you only need to change it in one place and it will affect all the programs.  Also, the format data doesn't have to be sorted. 

##Enhancing Programmer Efficiency

Tips for improving programming speed

- Use macros
- Passing an argument to a macro that contains a list of arguments via `%str(1,2,3)`

###Writing Flexible Programs

 - Write the program quickly
 - Add language elements (i.e. pulling SAS date system function)
 - Make the program efficient (i.e. via macros)

**Example of flexibility using the Filename statement**

- Simple Version: `Filename fileref(external-file-name1);` - files must have same layout 
- Dynamic Version: `Infile file-specification FILEVAR=variable`
- Example of constructing the file name automatically and reading in the files: 
- <pre><code>`NextFile= cats("mon,I,.dat"); 
	Infile dataSet FILEVAR=NextFile dlm=','</pre></code>

**Referencing DATES in future / past**- `INTNX`

 - `INTNX('interval', start-from, increment, <alignment>)`
 - `MidMon=month(intnx('month', today(), -1));`

###SAS Views

 - Specify the fileref when it is being used (i.e. in PROC PRINT) and not in the data step. 

**Data Step** 

<pre><code>Data DataSet / View=view-name;
 	Infile fileref
	input variable
	set...
run;</pre></code>

**SQL** 

<pre><code> Proc sql; create view view-name as
select ...
	from...
	where...
	using libname orion "path";
quit;</pre></code>

`using` doesn't affect the global libname statement that is in effect. It just changes the libname while that code is executed. 

####Advantages of Views

 - Combining data frequently
 - Data is changing frequently
 - Storing complex code
 - Avoid creating intermediate copies of data (i.e. no output

Choosing Between a View and a Data File

 - use data step if a data set is used multiple times
 - Avoid creating views on files where the structure changes often so that your code doesn't break
 - Can't update using a PROC SQL View

Choosing Between Data Step Views and PROC SQL Views

 - **Data Step**
  - perform complex computations
  - reading data from many different file formats (SQL can only use SAS data sets or Relational DB)
 - **PROC SQL**
  - read and update data (But only single data set can be used; no joins)
  - subset data before using the view
  - Assigning a libref in a view via using clause
  - supports where statements in subqueries
  - Connect to component in DBMS (SQL pass through facility)

###Using File and PUT Statements to Create (Automated) SAS Programs

Write 1 SAS program that creates another SAS data set;

<pre><code>data _null_;
	<data step statements>
	FILE file-spec;	
	PUT @n variable1 format... @n variable-n format;
run;</pre></code>

EX: `FILE 'jobs.sas` use filename, fileref, or print keyword. Without the file, will just print the `PUT` message to the SAS log

**Running a program w/o opening it via** `%include` 

- Syntax: `%include 'file' /source2` 
- `/source2` prints the actual program that was executed in the log
- More flexibility for generating code
