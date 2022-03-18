****************************************************************************
**PROJECT: 
**PROGRAM NAME: Macro. edc_accountability_status.sas
**PURPOSE: decide accountability status
**LOCATION: izhaopro\
****************************************************************************
**PROGRAMMED BY: izhaopro
**CREATED ON: 
**INPUTS: See Code
**OUTPUTS: See Code
****************************************************************************
**COMMENTS: 
**HISTORY OF MODIFICATIONS: 
**    DATE:          PROGRAMMER:          CHANGE: 
****************************************************************************; 


********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
****																		****
****								Comments								****
****																		****
********************************************************************************
example
********************************************************************************; 
/*
%edc_accountability_status(dsn=eye_account, prefix_output=); 
*/
********************************************************************************
example
********************************************************************************
****																		****
****								Comments								****
****																		****
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************; 


/*		########
	############
################
################
		########
		########
		########
		########
		########
		########
		########
		########
		########
		########
########################
########################*/


%macro edc_accountability_status(dsn=, prefix_output=macro_edc_
	, local_prefix_dataname=macro_temp_, local_prefix_macrovarname=, hardcode1=
	); 
/*
data _NULL_; 
run; 

%put _USER_; 
*/
data _NULL_; 
	temp_dsn = symget('dsn'); 
	select(find(temp_dsn, '.')); 
		when (0) dsn_libname = 'work'; 
		otherwise dsn_libname = substrn(temp_dsn, 1, find(temp_dsn, '.')-1); 
	end; 
	dsn = substrn(temp_dsn, find(temp_dsn, '.')+1, length(temp_dsn)-find(temp_dsn, '.')); 
	call symputx('dsn_libname', dsn_libname, 'l'); 
	call symputx('dsn', dsn, 'l'); 
run; 
data &local_prefix_dataname.dsn; 
	set &dsn_libname..&dsn.; 
run; 


data &local_prefix_dataname.1; 
	set &local_prefix_dataname.dsn; 
	date_cutoff = input(symget('date_cutoff'), yymmdd10.); 
	array cat [11]; 
	select; 
********************************************************************************
****								Comments								****
********************************************************************************
confirm "3. Out of Interval" first
	based on calculation, might be inconsistent with "subjnotavail=2"
********************************************************************************; 
		when (eye & VISITID & date & diff_vo>0) cat3 = 1; *3. Out of Interval; 
********************************************************************************
confirm "3. Out of Interval" first
	based on calculation, might be inconsistent with "subjnotavail=2"
********************************************************************************
****								Comments								****
********************************************************************************; 
		when (eye & VISITID & date & missing(subjnotavail)) cat2 = 1; *2. In Interval (included in analysis); 
		otherwise do; 
			select(subjnotavail); 
				when (1) cat6 = 1; *6. Missed visit; 
				when (2) cat3 = 1; *3. Out of Interval; 
				otherwise do; 
					select; 
						when (subjnotavail=3 | .=date<date_exit) do; 
							select(termstatus); 
								when (3) cat8 = 1; *8. Lost-to-follow-up; 
								when (4) cat5 = 1; *5. Discontinued; 
								otherwise; 
							end; 
						end; 
						otherwise do; 
							select; 
								when (missing(date)) do; 
									select(sum(date_cutoff, -base_date)<visitinterval_lower); 
										when (1) cat10 = 1; *10. Active (not yet in visit interval); 
										when (0) cat11 = 1; *11. In interval or Past interval (form not yet received); 
										otherwise; 
									end; 
								end; 
*								otherwise; 
********************************************************************************
****								Comments								****
********************************************************************************
counted as "7. Not seen but accounted for"
	if not in any other categories
********************************************************************************; 
								otherwise cat7 = 1; *7. Not seen but accounted for; 
********************************************************************************
counted as "7. Not seen but accounted for"
	if not in any other categories
********************************************************************************
****								Comments								****
********************************************************************************; 
							end; 
						end; 
					end; 
				end; 
			end; 
		end; 
	end; 
	select; 
		when (sum(cat2, cat3)) cat1 = 1; *1. Available for Analysis; 
		when (sum(of cat5-cat8)) cat4 = 1; *4. Missing Eyes; 
		when (sum(cat10, cat11)) cat9 = 1; *9. Active; 
		otherwise; 
	end; 
	do i=1 to dim(cat); 
		if missing(cat[i]) then cat[i] = 0; 
	end; 
	drop i; 
	format date_cutoff yymmdd10.; 
	label 
		date_cutoff = "Cutoff Date"
		cat1	= "Available for Analysis"
		cat2	= "--In Interval (included in analysis)"
		cat3	= "--Out of Interval (included in analysis)"
		cat4	= "Missing Eyes"
		cat5	= "--Discontinued "
		cat6	= "--Missed visit"
		cat7	= "--Not seen but accounted for"
		cat8	= "--Lost-to-follow-up"
		cat9	= "Active"
		cat10	= "--Active (not yet in visit interval)"
		cat11	= "--In interval or Past interval (form not yet received)"
	; 
run; 


data &prefix_output.&dsn.; 
	set &local_prefix_dataname.1; 
run; 
proc datasets lib=work memtype=data nolist; 
	delete &local_prefix_dataname.:; 
run; quit; 
%mend edc_accountability_status; 


/*		########
	################
  ########    ########
########		########
########		########
				######
			  ######
			######
		  ######
		######
	  ######
	######
  ######
######
########################
########################*/




/*		########
	################
  ########	  ########
########		########
########		########
				######
			  ######
		  ########
		  ########
			  ######
				######
########		########
########		########
  ########	  ########
	################
		########*/



