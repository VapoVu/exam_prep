libname orion 'C:\Users\LukasHalim\Documents\My SAS Files\ECPRG3';

/*Options to see resource time STIMER (on by default) and FULLSTIMER*/
OPTIONS STIMER|NOSTIMER;
OPTIONS FULLSTIMER|NOFULLSTIMER;

options fullstimer;
   data categories(keep=Salary Category);
   length Category $6;
   set orion.employee_payroll;
   if Salary<40000 then Category="Low";
   if Salary in (40000:100000) then Category="Middle";
   if Salary>100000 then Category="High";
run;


/*Dates can be stored in 4 bytes*/
/*Don't use length statement for decimal values - only for integers*/

/*EXAMPLE OF TRUNCATION*/
data test;
   length x 4;
   x=1/10;
   y=1/10;
   put x=;
   put y=;
run;

data _null_;
   set test;
   put x=;
   put y=;
run;
/*SAS doesn't truncate the values in the PDV, but only when writing to a SAS data set.*/
/*When SAS reads truncated numeric values to the PDV, it pads them with zeros to make*/
/*them normal length*/

/*COMPRESSION: Saves disk space and I/O, but increases CPU time*/
/*CHAR uses the RLE algo, Binary is the RDC algo*/

/*  Create uncompressed employees data set */

/***************INDEXES**********/
/*indexes increase storage space, but decrease IO and CPU*/
/*Add an index to a new data step, use the data step with the index= option*/
options compress=no;
/*Because we added msglevel=i, we get this in the log:
NOTE: Composite index SalesID has been defined.
NOTE: Simple index Customer_ID has been defined.*/
options msglevel=i;
data orion.sales_history(INDEX=(Customer_ID SalesID=(Order_ID Product_id)/unique/nomiss));
	set orion.history;
	value_cost = costprice_per_unit*quantity;
run;
proc contents data=orion.sales_history;
run;
/*data step does not carry over indexes from input data sets*/
proc datasets library=orion NOLIST;
	MODIFY sales_history;
	INDEX DELETE SalesID;
	INDEX CREATE SalesIDNew=(Order_ID Product_id)/unique nomiss;
run;
proc contents data=orion.sales_history;
run;

/*ERROR: An index named Customer_ID with the same definition already exists for file*/
/*       ORION.SALES_HISTORY.DATA.*/
/*This won't work if index already exists*/
proc sql;
	create unique index Customer_ID
		on orion.sales_history(Customer_id);
	create index SaleID
		on orion.sales_history(Customer_id, Product_ID);
quit;
proc sql;
	drop index SaleID from orion.sales_history;
run;

/*SUBSETTING IF will not use index because indexes determine which records
are read from the SAS input data set, but the subsetting if is executed
later, after the input data is read into the PDV the subsetting IF determines
which rows in the PDV go to the output.*/
/*IDXWHERE=YES - use best index*/
/*IDXWHERE=NO - don't use an index*/
/*IDXNAME=<index-name>*/

/*
FORCE
sorts and replaces an indexed data set when the OUT= option is not specified. 
Without the FORCE option, PROC SORT does not sort and replace an indexed data set because sorting destroys user-created indexes for the data set. When you specify FORCE, PROC SORT sorts and replaces the data set and destroys all user-created indexes for the data set. 
Indexes that were created or required by integrity constraints are preserved.*/
/*To sort with an index, you can also use out=<new-data-set-name>(index=(column-name))*/


options msglevel=I;

/*Since the index is set, we get this in the log:*/
/*INFO: Index Customer_ID selected for WHERE clause optimization.*/
proc print data=orion.sales_history;
   where Customer_ID=12727;
run;
proc sql;
	Drop index customer_id from orion.sales_history;
quit;
/*No index used, higher CPU time*/
proc print data=orion.sales_history;
   where Customer_ID=12727;
run;

data compare;
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
           
title;

data customer_coupons;
   array pct{3,6} _temporary_ 
      (10, 10, 15, 20, 20, 25, 
      10, 15, 20, 25, 25, 30, 
      10, 15, 15, 20, 25, 25);
   set orion.order_fact(keep=Customer_ID Order_Type Quantity);
   Coupon_Value=pct(Order_Type,Quantity);
run;


proc print data=customer_coupons(obs=5);
   title 'The Coupon Value';
run;


data customer_coupons;
   drop OT Quant Value i;
   array pct{3,6} _temporary_ ;
   if _n_=1 then 
      do i=1 to all;
         set orion.coupon_pct nobs=all;
         pct{OT,Quant}=Value;
      end;
   set orion.order_fact(keep=Customer_ID Order_Type Quantity);
   Coupon_Value=pct(Order_Type,Quantity);
run;
 
proc print data=customer_coupons(obs=10);
   title 'The Coupon Value';
run;



data orders;
   length Sale_Type $40;
   keep Order_ID Order_Type Sale_Type;
   if _N_=1 then 
      do;
         declare hash Product();
         Product.definekey('Order_Type');
         Product.definedata('Sale_Type');
         Product.definedone();
         Product.add(key:1, data:'Retail Sale');
         Product.add(key:2, data:'Catalog Sale');
         Product.add(key:3, data:'Internet Sale');
         call missing(Sale_Type);
      end;
   set orion.orders;
   rc=Product.find();
   if rc=0; 
run;
 
proc print data=orders(obs=5);
   title 'Using the ADD Method to Create a Hash Object with a Single Key';
run;

/*creating hash*/
data customers;
   length Customer_Type $40;
   keep Customer_ID Customer_Type_ID Customer_Type;
   if _N_=1 then 
      do;
         declare hash Customer(dataset:'orion.customer_type');
         Customer.definekey('Customer_Type_ID');
         Customer.definedata('Customer_Type');
         Customer.definedone();
         call missing(Customer_Type);
      end;
   set orion.customer;
   if Customer.find()=0;
run;
 
data expensive least_expensive;
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
run;

title;


/*FORMATS*/
/*cntlin= means from a data set into a format*/
/*cntlout= means from a format to a data set*/



/*Level 1 Practice: Merging or Joining Three Data Sets*/
proc sql outobs=5;
	select * from orion.order_fact as o, orion.product_dim as p, orion.customer_dim as c
		where o.product_id=p.product_id and o.customer_id=c.customer_id
		order by product_id;
run;

/*NOTE THAT THE "in=" is the data step way of doing an inner join*/
proc sort data=orion.order_fact(keep=Customer_ID Product_ID)
          out=order_fact;
   by Customer_ID;
run;
 
data temp;
   merge order_fact(in=O) 
         orion.customer_dim(keep=Customer_ID Customer_Name in=C);
   by Customer_ID;
   if O and C;
run;

/*_IORC_ Input Output Return Code*/

proc contents data=Orion.Organization_Dim;
run;

data Sales_Emps;
	set orion.salesstaff;
	set orion.organization_dim key=Employee_id;
	if _IORC_ = 0;
run;

/*Example of using calculation in proc sql*/
proc sql;
   create table age_dif as
   select mean(Customer_Age) as AvgAge, 
          Customer_ID,
	      Customer_Age,
          Customer_Age - calculated AvgAge as Age_Difference
      from orion.customer_dim;
quit;

proc options option=cpucount;
run;

/*Log states - NOTE: Input data set is already sorted; it has been copied to the output data set.*/
proc sort data=orion.holidays out=holidays presorted;
   by Date;
run;
/*Log states - NOTE: Input data set is not in sorted order.*/
proc sort data=orion.holidays out=holidays presorted;
   by Holiday_Name;
run;


data cc_donations / view=cc_donations;
   set orion.employee_donations;
   length Donation_Category $15;
   where Paid_By='Credit Card';
   Total_Donations=sum(of Qtr1-Qtr4);
   if Total_Donations >= 100 then Donation_Category='$100 or more';
   else Donation_Category='Less than $100';
run;

proc means data=cc_donations sum n nonobs maxdec=2;
   class Donation_Category;
   var Total_Donations;
run;
