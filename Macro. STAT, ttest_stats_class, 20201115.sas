****************************************************************************
**PROJECT: 
**PROGRAM NAME: Macro. Stats, proc_ttest.sas
**PURPOSE: proc ttest
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
data temp_dsn; 
	set eye_ept; 
	if nom_iol in (3,5); 
	if bin_sx; 
run; 
%ttest_stats_class(dsn=temp_dsn, varname_class=nom_iol, output=ttest, opt_ttest_order=mixed
	, list_varname="&list_varname_cs_monoc."
	, list_varname_by="ord_phase	ord_phase_c"
	); 


data temp_dsn; 
	set eye_ept; 
	if nom_iol in (3,5); 
	if bin_sx; 
run; 
proc sort; 
	by ord_phase	ord_phase_c	descending nom_iol; 
run; 
%ttest_stats_class(dsn=temp_dsn, varname_class=nom_iol, output=ttest, opt_ttest_order=data
	, list_varname="&list_varname_cs_monoc."
	, list_varname_by="ord_phase	ord_phase_c"
	); 
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


%macro ttest_stats_class(dsn=, varname_class=, output=stats
	, opt_ttest_order=mixed
	, alpha_equality=0.05
	, mvarname=, symboltable=f, modifiers=i
	, prefix_output=temp_, suffix_output=, prefix_mvarname=, suffix_mvarname=
	, local_prefix_dataname=l_temp_, local_prefix_mvarname=l_temp_
	, list_varname=""
	, list_varname_by=""
	, list_suffix_0=""
	, list_suffix_1=""
	, list_str_0=""
	, list_str_1=""
	, list_rename_1=""
	); 
/*
data _NULL_; 
	call symputx('dsn', 						'temp_dsn', 'l'); 
	call symputx('id_subj', 					'subjid', 'l'); 
	call symputx('varname_class', 				'nom_iol', 'l'); 
*	call symputx('varname_class', 				'nom_iol_c', 'l'); 
	call symputx('opt_ttest_order', 			'mixed', 'l'); 
	call symputx('alpha_equality', 				'0.05', 'l'); 
	call symputx('output', 						'medfind', 'l'); 
	call symputx('output_sortby', 				'subjid	eye	visit_subj', 'l'); 
	call symputx('mvarname', 					'list_varname', 'l'); 
	call symputx('symboltable', 				'f', 'l'); 

	call symputx('dsn_1', 						'info_medfind', 'l'); 
	call symputx('output_1', 					'n_medfind', 'l'); 

	call symputx('prefix_output', 				'temp_', 'l'); 
	call symputx('suffix_output', 				'', 'l'); 
	call symputx('prefix_mvarname', 			'', 'l'); 
	call symputx('suffix_mvarname', 			'', 'l'); 
	call symputx('local_prefix_dataname', 		'l_temp_', 'l'); 
	call symputx('local_prefix_mvarname', 		'l_temp_', 'l'); 

	call symputx('modifiers', 					'i', 'l'); 
	call symputx('prefix_mvarname', 			'', 'l'); 
	call symputx('suffix_mvarname', 			'', 'l'); 

	call symputx('list_varname', 				quote(symget('list_varname_cs_monoc')), 'l'); 
	call symputx('list_varname_by', 			'ord_phase	ord_phase_c', 'l'); 
	call symputx('list_suffix_0', 				quote(", _STD, _HLGT, _HLGT_CODE, _HLT, _HLT_CODE, _LLT, _LLT_CODE, _PT, _PT_CODE, _SOC, _SOC_CODE"), 'l'); 
	call symputx('list_suffix_1', 				quote(""), 'l'); 
	call symputx('list_str_0', 					quote("'<B/>', '</B>', '<I/>', '</I>', ': (display value)', '(display value)', 'Coded Value'"), 'l'); 
	call symputx('list_str_1', 					quote(""), 'l'); 
	call symputx('list_rename_1', quote("
		UNCONJHYPERINJOS=CONJHYPERINJOS
		, HPYHOD=HYPHOD
		, PIPOS=PUPOS
		"), 'l'); 
run; 
%put _USER_; 
*/
	data _NULL_; 
		dsn_libname = ifc(find(symget('dsn'), '.')=0, 'work', substrn(symget('dsn'), 1, find(symget('dsn'), '.')-1)); 
		dsn = substrn(symget('dsn'), find(symget('dsn'), '.')+1, length(symget('dsn'))-find(symget('dsn'), '.')); 
		call symputx('dsn_libname', dsn_libname, 'l'); 
		call symputx('dsn', dsn, 'l'); 
	run; 
	data _NULL_; 
		output = ifc(missing(symget('output')), symget('dsn'), symget('output')); 
		mvarname = ifc(missing(symget('mvarname')), output, symget('mvarname')); 
		prefix_mvarname = ifc(missing(symget('prefix_mvarname')), symget('prefix_output'), symget('prefix_mvarname')); 
		suffix_mvarname = ifc(missing(symget('suffix_mvarname')), symget('suffix_output'), symget('suffix_mvarname')); 
		call symputx('output', output, 'l'); 
		call symputx('mvarname', mvarname, 'l'); 
		call symputx('prefix_mvarname', prefix_mvarname, 'l'); 
		call symputx('suffix_mvarname', suffix_mvarname, 'l'); 
	run; 
	data &local_prefix_dataname.dsn; 
		set &dsn_libname..&dsn.; 
	run; 
/*
data _NULL_; *_NULL_	&local_prefix_dataname.1; 
	array char_quote$32767 list_varname	define; 
	do over char_quote; 
		char_quote = cats(dequote(symget(vname(char_quote)))); 
		call symputx(cats(symget('local_prefix_mvarname'), vname(char_quote)), char_quote, 'l'); 
	end; 
run; 
data _NULL_; return = dosubl('%put _USER_; '); run; 
*var &&&local_prefix_mvarname.list_varname.	var &&&local_prefix_mvarname.define.; 
*/
	data _NULL_; *_NULL_	&local_prefix_dataname.1; 
		array char_quote$32767 list_varname	list_varname_by	list_suffix_1	list_str_1; 
		do over char_quote; char_quote = cats(dequote(symget(vname(char_quote)))); call symputx(cats(symget('local_prefix_mvarname'), vname(char_quote)), char_quote, 'l'); end; 
	run; 
	data _NULL_; return = dosubl('%put _USER_; '); run; 




	proc contents data=&local_prefix_dataname.dsn out=&local_prefix_dataname.contents_dsn noprint; 
	run; 
	proc sort; 
		by NAME; 
	run; 


	proc sort data=&local_prefix_dataname.dsn; 
		by &&&local_prefix_mvarname.list_varname_by.; 
	run; 

	ods select none; 
	proc ttest data=&local_prefix_dataname.dsn plots=none order=&opt_ttest_order.; *order=data | formatted | freq | internal | mixed; 
		by &&&local_prefix_mvarname.list_varname_by.; 
		class &varname_class.; 
		var &&&local_prefix_mvarname.list_varname.; 
		ods output 
			Statistics=&local_prefix_dataname.ods_statistics
			ConfLimits=&local_prefix_dataname.ods_conflimits
			TTests=&local_prefix_dataname.ods_ttests
			Equality=&local_prefix_dataname.ods_equality
		; 
	run; 
	ods select all; 
/*
	proc contents data=&local_prefix_dataname.ods_statistics varnum; run; 
	proc contents data=&local_prefix_dataname.ods_conflimits varnum; run; 
	proc contents data=&local_prefix_dataname.ods_ttests varnum; run; 
	proc contents data=&local_prefix_dataname.ods_equality varnum; run; 
*/

	data &local_prefix_dataname.ods_statistics; 
		ord_ttest_stats + 1; 
		set &local_prefix_dataname.ods_statistics; 
	run; 
	proc sort; 
		by &&&local_prefix_mvarname.list_varname_by.	Variable	Method	ord_ttest_stats;
	run; 

	proc sort data=&local_prefix_dataname.ods_conflimits; 
		by &&&local_prefix_mvarname.list_varname_by.	Variable	Method; 
	run; 
	proc sort data=&local_prefix_dataname.ods_ttests; 
		by &&&local_prefix_mvarname.list_varname_by.	Variable	Method; 
	run; 
	proc sort data=&local_prefix_dataname.ods_equality; 
		by &&&local_prefix_mvarname.list_varname_by.	Variable	Method; 
	run; 


	data &local_prefix_dataname.1; 
		merge &local_prefix_dataname.ods_ttests	&local_prefix_dataname.ods_equality (rename=(Method=method_equality)); 
		by &&&local_prefix_mvarname.list_varname_by.	Variable; 
		if (cats(Variances)='Equal' & &alpha_equality.<ProbF<=1) | (cats(Variances)='Unequal' & 0<=ProbF<=&alpha_equality.); 
	run; 
	data &local_prefix_dataname.2; 
		merge &local_prefix_dataname.ods_statistics	&local_prefix_dataname.1 (in=b); 
		by &&&local_prefix_mvarname.list_varname_by.	Variable	Method; 
		if missing(Method) | b; 
	run; 
	data &local_prefix_dataname.stats_ttests; 
		set &local_prefix_dataname.2; 
	run; 

	data &local_prefix_dataname.1; 
		length var_varname$32	class_varname$32	ord_ttest_class_lvl 8; 
		set &local_prefix_dataname.stats_ttests; 
		by &&&local_prefix_mvarname.list_varname_by.	Variable	Method; 

		var_varname = cats(Variable); 
		class_varname = cats(vlabel(Class)); 
		if first.Variable then call missing(ord_ttest_class_lvl); 
		ord_ttest_class_lvl + 1; 
	run; 
	proc sort out=&local_prefix_dataname.2; 
		by var_varname; 
	run; 
	data &local_prefix_dataname.3; 
		length var_varname$32	var_varlabel$256; 
		merge 
			&local_prefix_dataname.contents_dsn (keep=NAME	LABEL rename=(NAME=var_varname	LABEL=var_varlabel))
			&local_prefix_dataname.2 (in=b)
		; 
		by var_varname; 
		if b; 
	run; 
	proc sort out=&local_prefix_dataname.4; 
		by class_varname; 
	run; 
	data &local_prefix_dataname.5; 
		length 
			var_varname$32	var_varlabel$256
			class_varname$32	class_vartype 8	class_varlabel$256
			ord_ttest_class_lvl 8	ord_ttest_class_varvalue_n 8	ord_ttest_class_varvalue_c$256
		; 
		merge 
			&local_prefix_dataname.contents_dsn (keep=NAME	TYPE	LABEL rename=(NAME=class_varname	TYPE=class_vartype	LABEL=class_varlabel))
			&local_prefix_dataname.4 (in=b)
		; 
		by class_varname; 
		if b; 

		select(class_vartype); 
			when (1) do; *Numeric; 
				select(ord_ttest_class_lvl); 
					when (1,2) 	ord_ttest_class_varvalue_n = input(cats(Class), best12.); 
					when (3) 	ord_ttest_class_varvalue_c = 'Difference'; 
					otherwise; 
				end; 
			end; 
			when (2) do; *Character; 
				ord_ttest_class_varvalue_c = ifc(ord_ttest_class_lvl=3, 'Difference', cats(Class)); 
			end; 
			otherwise; 
		end; 
	run; 
	proc sort out=&local_prefix_dataname.6; 
		by ord_ttest_stats; 
	run; 
	data &local_prefix_dataname.7; 
		merge 
			&local_prefix_dataname.6 (keep=ord_ttest_stats--Variable)
			&local_prefix_dataname.6 (keep=ord_ttest_stats	var_:)
			&local_prefix_dataname.6 (keep=ord_ttest_stats	Class)
			&local_prefix_dataname.6 (keep=ord_ttest_stats	class_:)
			&local_prefix_dataname.6
		; 
		by ord_ttest_stats; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		modify &local_prefix_dataname.7; 
			attrib var_varname	var_varlabel	Class	class_varname	class_vartype	class_varlabel format= informat= label=' '; 
	run; quit; 

	data &prefix_output.&output.&suffix_output.; 
		set &local_prefix_dataname.7; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend ttest_stats_class; 


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



