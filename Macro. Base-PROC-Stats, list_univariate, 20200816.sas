****************************************************************************
**PROJECT: 
**PROGRAM NAME: 
**PURPOSE: 
**LOCATION: izhaopro\
****************************************************************************
**PROGRAMMED BY: izhaopro
**CREATED ON: 
**INPUTS: 
**OUTPUTS: 
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
%list_univariate(dsn=subj_ept, output=list_univariate, output_1=temp_normal, prefix_output=, suffix_output=
	, list_varname=&list_varname., list_varname_class=&list_varname_class.); 
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


%macro list_univariate(dsn=, id_subj=subjid, output=, output_sortby=subjid	eye	visit_subj
	, output_1=
	, prefix_output=temp_, suffix_output=
	, local_prefix_dataname=l_temp_, local_prefix_macrovarname=l_temp_
	, modifiers=i
	, list_varname="&list_varname."
	, list_varname_class="&list_varname_class."
	); 
/*
data _NULL_; 
	call symputx('dsn', 						'subj_ept', 'l'); 
	call symputx('id_subj', 					'subjid', 'l'); 
	call symputx('output', 						'univariate', 'l'); 
	call symputx('output_sortby', 				'subjid	eye	visit_subj', 'l'); 

	call symputx('dsn_1', 						'info_medfind', 'l'); 
	call symputx('output_1', 					'n_medfind', 'l'); 

	call symputx('prefix_output', 				'temp_', 'l'); 
	call symputx('suffix_output', 				'', 'l'); 
	call symputx('local_prefix_dataname', 		'l_temp_', 'l'); 
	call symputx('local_prefix_macrovarname', 	'l_temp_', 'l'); 
run; 
%put _USER_; 
*/
	data _NULL_; 
		dsn_libname = choosec((find(symget('dsn'), '.')=0)+1, substrn(symget('dsn'), 1, find(symget('dsn'), '.')-1), 'work'); 
		dsn = substrn(symget('dsn'), find(symget('dsn'), '.')+1, length(symget('dsn'))-find(symget('dsn'), '.')); 
		call symputx('dsn_libname', dsn_libname, 'l'); 
		call symputx('dsn', dsn, 'l'); 
	run; 
	data _NULL_; 
		output = choosec(missing(symget('output'))+1, symget('output'), symget('dsn')); 
		call symputx('output', output, 'l'); 
	run; 
	data &local_prefix_dataname.dsn; 
		set &dsn_libname..&dsn.; 
	run; 
/*	data _NULL_; *_NULL_	&local_prefix_dataname.1; */
/*		array char_quote$32767 list_varname	list_varname_class; */
/*		do over char_quote; char_quote = cats(dequote(symget(vname(char_quote)))); call symputx(cats(symget('local_prefix_macrovarname'), vname(char_quote)), char_quote, 'l'); end; */
/*	run; */
/*	data _NULL_; return = dosubl('%put _USER_; '); run; */

	proc transpose data=&local_prefix_dataname.dsn (keep=&list_varname. obs=1) out=&local_prefix_dataname.1; 
		var _NUMERIC_; 
	run; 
	data &local_prefix_dataname.2 (keep=varnum	varname	varlabel); 
		length varnum 8	varname$32	varlabel$256; 
		set &local_prefix_dataname.1; 
		varnum + 1; 
		varname = _NAME_; 
		varlabel = _LABEL_; 
	run; 
	proc sort out=&local_prefix_dataname.info_var; 
		by varname; 
	run; 


	ods select none; 
	proc univariate data=&local_prefix_dataname.dsn normal; 
		class &list_varname_class.; 
		var	&list_varname.; 
	ods output 
		Moments				=&local_prefix_dataname.01_moments
		BasicMeasures		=&local_prefix_dataname.02_basicmeasures
		TestsForLocation	=&local_prefix_dataname.03_location
		Quantiles			=&local_prefix_dataname.04_quantiles
		ExtremeObs			=&local_prefix_dataname.05_extremeobs

		TestsForNormality	=&local_prefix_dataname.normal
	; 
	run; 
	ods select all; 


	proc sort data=&local_prefix_dataname.01_moments out=&local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
	run; 
	data &local_prefix_dataname.2; 
		length 	stats_ord 8; 
		set &local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
		if first.varname then call missing(stats_ord); 
		stats_ord + 1; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_1; 
		by &list_varname_class.	varname	stats_ord; 
		var Label1	Label2; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_2; 
		by &list_varname_class.	varname	stats_ord; 
		var nValue1	nValue2; 
	run; 
	data &local_prefix_dataname.3; 
		length 	temp_ord 8	varname$32	stats_ord 8	stats_name$32	stats_label$256	stats_value 8; 
		merge &local_prefix_dataname.2_1 (drop=_NAME_ rename=(COL1=stats_label))	&local_prefix_dataname.2_2 (rename=(COL1=stats_value)); 
		by &list_varname_class.	varname	stats_ord; 
		if first.stats_ord then call missing(temp_ord); 
		temp_ord + 1; 
		stats_ord = 100*stats_ord+temp_ord; 
		stats_name = _NAME_; 
	run; 
	data &local_prefix_dataname.01; 
		set &local_prefix_dataname.3 (drop=temp_:	_NAME_); 
	run; 

	proc sort data=&local_prefix_dataname.02_basicmeasures out=&local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
	run; 
	data &local_prefix_dataname.2; 
		length 	stats_ord 8; 
		set &local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
		if first.varname then call missing(stats_ord); 
		stats_ord + 1; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_1; 
		by &list_varname_class.	varname	stats_ord; 
		var LocMeasure	VarMeasure; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_2; 
		by &list_varname_class.	varname	stats_ord; 
		var LocValue	VarValue; 
	run; 
	data &local_prefix_dataname.3; 
		length 	temp_ord 8	varname$32	stats_ord 8	stats_name$32	stats_label$256	stats_value 8; 
		merge &local_prefix_dataname.2_1 (drop=_NAME_ rename=(COL1=stats_label))	&local_prefix_dataname.2_2 (rename=(COL1=stats_value)); 
		by &list_varname_class.	varname	stats_ord; 
		if first.stats_ord then call missing(temp_ord); 
		temp_ord + 1; 
		stats_ord = 100*stats_ord+temp_ord; 
		stats_name = _NAME_; 
	run; 
	data &local_prefix_dataname.02; 
		set &local_prefix_dataname.3 (drop=temp_:	_NAME_	_LABEL_ where=(^missing(stats_label))); 
	run; 

	proc sort data=&local_prefix_dataname.03_location out=&local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
	run; 
	data &local_prefix_dataname.2; 
		length 	stats_ord 8; 
		set &local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
		if first.varname then call missing(stats_ord); 
		stats_ord + 1; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_1; 
		by &list_varname_class.	varname	stats_ord	Test; 
		var Testlab	pType; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_2; 
		by &list_varname_class.	varname	stats_ord	Test; 
		var Stat	pValue; 
	run; 
	data &local_prefix_dataname.3; 
		length 	temp_ord 8	varname$32	stats_ord 8	stats_name$32	stats_label$256	stats_value 8; 
		merge &local_prefix_dataname.2_1 (drop=_NAME_	_LABEL_ rename=(COL1=stats_label))	&local_prefix_dataname.2_2 (rename=(COL1=stats_value)); 
		by &list_varname_class.	varname	stats_ord	Test; 
		if first.stats_ord then call missing(temp_ord); 
		temp_ord + 1; 
		stats_ord = 100*stats_ord+temp_ord; 
		stats_name = _NAME_; 
		stats_label = catx(' ', _LABEL_, cats('(', stats_label), 'of', cats(Test, ')')); 
	run; 
	data &local_prefix_dataname.03; 
		set &local_prefix_dataname.3 (drop=temp_:	Test	_NAME_	_LABEL_); 
	run; 

	proc sort data=&local_prefix_dataname.04_quantiles out=&local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
	run; 
	data &local_prefix_dataname.2; 
		length 	varname$32	stats_ord 8	stats_name$32	stats_label$256	stats_value 8; 
		set &local_prefix_dataname.1 (keep=VarName	&list_varname_class.	Quantile	Estimate rename=(Quantile=stats_label	Estimate=stats_value)); 
		by &list_varname_class.	varname; 
		if first.varname then call missing(stats_ord); 
		stats_ord + 1; 
		stats_name = vlabel(stats_value); 
	*	stats_label = catx(': ', vlabel(stats_value), stats_label); 
	run; 
	data &local_prefix_dataname.04; 
		set &local_prefix_dataname.2; 
	run; 

	proc sort data=&local_prefix_dataname.05_extremeobs out=&local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
	run; 
	data &local_prefix_dataname.2; 
		length 	stats_ord 8; 
		set &local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
		if first.varname then call missing(stats_ord); 
		stats_ord + 1; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_1; 
		by &list_varname_class.	varname	stats_ord; 
		var Low	High; 
	run; 
	proc transpose data=&local_prefix_dataname.2 out=&local_prefix_dataname.2_2; 
		by &list_varname_class.	varname	stats_ord; 
		var LowObs	HighObs; 
	run; 
	data &local_prefix_dataname.3; 
		length 	temp_ord	temp_num 8	varname$32	stats_ord 8	stats_name$32	stats_label$256	stats_value 8; 
		merge &local_prefix_dataname.2_1 (drop=_NAME_ rename=(COL1=temp_num))	&local_prefix_dataname.2_2 (rename=(COL1=stats_value)); 
		by &list_varname_class.	varname	stats_ord; 
		_LABEL_ = transtrn(_LABEL_, 'Observation Number', 'n'); 
		stats_label = catx(' ', _LABEL_, temp_num); 
		if first.stats_ord then call missing(temp_ord); 
		temp_ord + 1; 
		stats_ord = 100*stats_ord+temp_ord; 
		stats_name = _NAME_; 
	run; 
	data &local_prefix_dataname.05; 
		set &local_prefix_dataname.3 (drop=temp_:	_NAME_	_LABEL_); 
	run; 


	data &local_prefix_dataname.1; 
		length 	varnum 8	varname$32	varlabel$256	opt_ord 8	opt_name$32	opt_label$256	stats_ord 8	stats_name$32	stats_label$256	stats_value 8; 
		set 
			&local_prefix_dataname.01 (in=in_moments)
			&local_prefix_dataname.02 (in=in_basicmeasures)
			&local_prefix_dataname.03 (in=in_location)
			&local_prefix_dataname.04 (in=in_quantiles)
			&local_prefix_dataname.05 (in=in_extremeobs)
		; 
		select; 
			when (in_moments) 		do; opt_ord = 1; 
				opt_name = 'Moments'; opt_label = 'Moments'; 
			end; 
			when (in_basicmeasures) do; opt_ord = 2; 
				opt_name = 'BasicMeasures'; opt_label = 'Basic Measures'; *opt_label = 'Basic Measures of Location and Variability'; ; 
			end; 
			when (in_location) 		do; opt_ord = 3; 
				opt_name = 'TestsForLocation'; opt_label = 'Location'; *opt_label = 'Tests For Location'; ; 
			end; 
			when (in_quantiles) 	do; opt_ord = 4; 
				opt_name = 'Quantiles'; opt_label = 'Quantiles'; 
			end; 
			when (in_extremeobs) 	do; opt_ord = 5; 
				opt_name = 'ExtremeObs'; opt_label = 'Extreme Observations'; 
			end; 

	*		when () 	do; 
	*			opt_ord = ; 
	*			opt_name = 'TestsForNormality'; 
	*			opt_label = 'Tests For Normality'; 
	*		end; 
			otherwise; 
		end; 
	run; 
	proc sort out=&local_prefix_dataname.2; 
		by varname; 
	run; 
	data &local_prefix_dataname.3; 
		length id$32	idlabel$256; 
		merge &local_prefix_dataname.info_var	&local_prefix_dataname.2 (drop=varnum	varlabel in=b); 
		by varname; 
		if b; 
		id = catx('_', 'stats', opt_ord, stats_ord); 
		idlabel = catx('. ', opt_label, stats_label); 
	run; 
	proc sort out=&local_prefix_dataname.4; 
		by varnum	&list_varname_class.	opt_ord	stats_ord; 
	run; 
	data &local_prefix_dataname.5; 
		retain varnum	varname	varlabel	&list_varname_class.; 
		merge &local_prefix_dataname.4; 
		by varnum	&list_varname_class.	opt_ord	stats_ord; 
	run; 

	data &prefix_output.&output.&suffix_output.; 
		set &local_prefix_dataname.5; 
		format stats_value best12.; 
		label stats_label=' '	stats_value=' '; 
	run; 


	proc sort data=&local_prefix_dataname.normal out=&local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
	run; 
	data &local_prefix_dataname.2; 
		length 	stats_ord 8; 
		set &local_prefix_dataname.1; 
		by &list_varname_class.	varname; 
		if first.varname then call missing(stats_ord); 
		stats_ord + 1; 
	run; 
	proc sort out=&local_prefix_dataname.3; 
		by varname	&list_varname_class.; 
	run; 
	data &local_prefix_dataname.4; 
		retain varnum	varname	varlabel	&list_varname_class.; 
		merge &local_prefix_dataname.info_var	&local_prefix_dataname.3 (in=b); 
		by varname; 
		if b; 
	run; 
	proc sort out=&local_prefix_dataname.5; 
		by varnum	varname	varlabel	&list_varname_class.; 
	run; 

	data &prefix_output.&output_1.&suffix_output.; 
		set &local_prefix_dataname.5; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend list_univariate; 


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



