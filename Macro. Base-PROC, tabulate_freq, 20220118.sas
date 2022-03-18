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
2021-09-30	edit dsn1=temp_lvl
	......
20??-??-??	......
****************************************************************************; 


/*
Reference
https://documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=9.4_3.5&docsetId=proc&docsetTarget=p11jxgcqkk8svtn1uu9gtcq3s7cj.htm&locale=en
*/
/*
Variables(s) in list_varname_by NEVER in TABLE statement
*/
/*
%tabulate_freq(); 
	keyword parameter
		opt_tabulate_missing			: "missing" is mandatory

%convert_freq_to_tab(); 
	keyword parameter
		indic_statsMissing				: include Missing in Statistics
			default value: 0
			0	: No, NOT include Missing in Statistics
			1	: Yes, include Missing in Statistics
		indic_classCodeAll_varY			: insert obs with code 990 for varY
			default value: 1
			0	: No, NOT insert obs with code 990 for varY
			1	: Yes, insert obs with code 990 for varY
		list_varname_by					: is redundant, will be generated and overwritten
*/
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
proc contents data=sashelp._all_ out=temp_sashelp_contents noprint; 
run; 

ods select none; 
proc contents data=sashelp._all_; 
   ods output members=temp_sashelp_members; 
run; 
ods select all; 
proc print; 
   where memtype='DATA'; 
run; 
*/
/*
data sashelp_birthwgt; 
	set sashelp.birthwgt; 
run; 
data sashelp_bweight; 
	set sashelp.bweight; 
run; 
data temp_dsn; 
	merge sashelp_birthwgt (drop=Married in=a)	sashelp_bweight (in=b); 

	if a & b; 

	AgeGroup						 = ifn(mod(_N_, 3)=1, ., AgeGroup); 

	Married							 = ifn(mod(_N_, 5)=1, ., Married); 
	Boy								 = ifn(mod(_N_, 5)=2, ., Boy); 
	MomSmoke						 = ifn(mod(_N_, 5)=3, ., MomSmoke); 
	Visit							 = ifn(Visit=0, ., Visit); 
	MomEdLevel						 = ifn(MomEdLevel=3, ., MomEdLevel); 

	drop Weight	MomAge	CigsPerDay	MomWtGain; 
	format _ALL_; 
	informat _ALL_; 
run; 
proc sort; 
*	where also AgeGroup in (1); 
	by LowBirthWgt; 
run; 

ods select none; 
proc tabulate data=temp_dsn out=temp_lvl; 
	class _ALL_; 
	table _ALL_; 
run; 
ods select all; 
data temp_lvl; 
	length _vartype_ 8	_varvaluen_ 8	_varvaluec_$32; 
	set temp_lvl (keep=LowBirthWgt--MomEdLevel); 

	array arr_n LowBirthWgt-NUMERIC-MomEdLevel; 
	array arr_c LowBirthWgt-CHARACTER-MomEdLevel; 
	do over arr_n; 
		if ^missing(arr_n) then do; 
			_varvaluen_ = arr_n; 
			_vartype_ = ifn(vtype(arr_n)='N', 1, ifn(vtype(arr_n)='C', 2, _vartype_)); 
		end; 
	end; 
	do over arr_c; 
		if ^missing(arr_c) then do; 
			_varvaluec_ = cats(arr_c); 
			_vartype_ = ifn(vtype(arr_c)='N', 1, ifn(vtype(arr_c)='C', 2, _vartype_)); 
		end; 
	end; 
run; 

****	AgeGroup	Race	SomeCollege	Married	Boy	MomSmoke	Visit	MomEdLevel; 
%tabulate_freq(dsn=temp_dsn, dsn1=temp_lvl, output=freq, output1=metaParm, output2=metaCode, nameConv_classPerm=0
	, prefix_output=temp_, suffix_output=_dim02, prefix_mvarname=, suffix_mvarname=
	, list_varname_by="LowBirthWgt"
	, tableExpr_page="AgeGroup	Race	SomeCollege"
	, tableExpr_row=
	, tableExpr_col="Married	Boy	MomSmoke	Visit	MomEdLevel"
	, list_stats=n
	); 
%tabulate_freq(dsn=temp_dsn, dsn1=temp_lvl, output=freq, output1=metaParm, output2=metaCode, nameConv_classPerm=0
	, prefix_output=temp_, suffix_output=_dim03, prefix_mvarname=, suffix_mvarname=
	, list_varname_by="LowBirthWgt"
	, tableExpr_page="AgeGroup	Race	SomeCollege"
	, tableExpr_row="Married	Boy	MomSmoke"
	, tableExpr_col="Visit	MomEdLevel"
	, list_stats=n
	); 
%tabulate_freq(dsn=temp_dsn, dsn1=temp_lvl, output=freq, output1=metaParm, output2=metaCode
	, prefix_output=temp_, suffix_output=_dim05, prefix_mvarname=, suffix_mvarname=
	, list_varname_by="LowBirthWgt"
	, tableExpr_page="AgeGroup"
	, tableExpr_row="Race*SomeCollege	Married"
	, tableExpr_col="Boy*(MomSmoke	Visit)	MomEdLevel"
	, list_stats=n
	); 

proc contents data=temp_freq_dim02 varnum; run; 
proc contents data=temp_freq_dim03 varnum; run; 
*proc contents data=temp_freq_dim05 varnum; run; 




data temp_stats_freq_dim02; 
	set temp_freq_dim02; 

	if n(of _classPerm_code_:)=_classComb_rank_; 
	if _classComb_rank_=_mdP_classPerm_dim_; 
run; 
data temp_stats_freq_dim03; 
	set temp_freq_dim03; 

	if n(of _classPerm_code_:)=_classComb_rank_; 
	if _classComb_rank_=_mdP_classPerm_dim_; 
run; 
data temp_stats_freq_dim05; 
	set temp_freq_dim05; 

	if n(of _classPerm_code_:)=_classComb_rank_; 
	if _classComb_rank_=_mdP_classPerm_dim_; 
run; 

%convert_freq_to_tab(dsn=temp_stats_freq_dim02, output=tab, indic_statsMissing=0
	, prefix_output=temp_, suffix_output=_dim02, prefix_mvarname=, suffix_mvarname=
	); 
%convert_freq_to_tab(dsn=temp_stats_freq_dim03, output=tab, indic_statsMissing=0
	, prefix_output=temp_, suffix_output=_dim03, prefix_mvarname=, suffix_mvarname=
	); 
%convert_freq_to_tab(dsn=temp_stats_freq_dim05, output=tab, indic_statsMissing=0
	, prefix_output=temp_, suffix_output=_dim05, prefix_mvarname=, suffix_mvarname=
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


********************************************************************************
********************************************************************************
Acronym/Nomenclature
********************************************************************************; 
/*
classComb	 ~ class Combination, combination of class variable(s) from _classPerm_
classPerm	 ~ class Permutation, class variable(s) in the category that produced the statistic
classVar	 ~ class Variable(s)
varXParm	 ~ column Parameter
varXStats	 ~ column Statistics
mdP			 ~ metadata Parameter
nameConv	 ~ naming Convention
*/
/*
_stats0_	 ~ for _TYPE_	_PAGE_	_TABLE_	N
*/
********************************************************************************
Acronym/Nomenclature
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


%macro tabulate_freq(dsn=, dsn1=, output=freq, output1=metaParm, output2=metaCode, mvarname=
	, 	opt_class						=
	, 	opt_tabulate_missing			=missing
	, 	opt_table						=printmiss
	, 	varname_univClass_all			=all
	, 	nameConv_classPerm				=0
	, 	symboltable=f, modifiers=i
	, 	prefix_output=temp_, suffix_output=, prefix_mvarname=, suffix_mvarname=
	, 	local_prefix_dataname=l0_tmp_, local_prefix_mvarname=l0m_
	, 	list_varname_by					=
	, 	tableExpr_page					=
	, 	tableExpr_row					=
	, 	tableExpr_col					=
	, 	list_stats						=
	); 
/*
data _NULL_; 
	call symputx('dsn'							, 'temp_dsn', 'l'); ****	temp_dsn; 
	call symputx('dsn1'							, 'temp_lvl', 'l'); ****	temp_lvl; 
	call symputx('output'						, 'freq', 'l'); ****	freq	tabulate_freq; 
	call symputx('output1'						, 'metaParm', 'l'); ****	metaParm	tabulate_metaParm; 
	call symputx('output2'						, 'metaCode', 'l'); ****	metaCode	tabulate_metaCode; 
	call symputx('mvarname'						, '', 'l'); 

	call symputx('opt_class'					, '', 'l'); ****	missing; 
	call symputx('opt_tabulate_missing'			, 'missing', 'l'); ****	missing; 
	call symputx('opt_table'					, 'printmiss', 'l'); ****	printmiss; 
	call symputx('varname_univClass_all'		, 'all', 'l'); ****	all; 
*	call symputx('nomenclature_prop_classPerm'	, '1', 'l'); ****	0, 1; 
	call symputx('nameConv_classPerm'			, '1', 'l'); ****	0, 1; 
	call symputx('symboltable'					, 'f', 'l'); 
	call symputx('modifiers'					, 'i', 'l'); 

	call symputx('prefix_output'				, 'temp_', 'l'); 
	call symputx('suffix_output'				, '', 'l'); 
	call symputx('prefix_mvarname'				, '', 'l'); 
	call symputx('suffix_mvarname'				, '', 'l'); 

	call symputx('local_prefix_dataname'		, 'l0_tmp_', 'l'); 
	call symputx('local_prefix_mvarname'		, 'l0m_', 'l'); 

	call symputx('list_varname_by'				, 'LowBirthWgt', 'l'); ****	LowBirthWgt; 
*	call symputx('list_varname_by'				, '', 'l'); ****	LowBirthWgt; 

	call symputx('tableExpr_page'				, quote('AgeGroup	Race	SomeCollege'), 'l'); ****	AgeGroup	Race	SomeCollege; 
	call symputx('tableExpr_row'				, quote('Married	Boy	MomSmoke'), 'l'); ****	Married	Boy	MomSmoke; 
	call symputx('tableExpr_col'				, quote('Visit	MomEdLevel'), 'l'); ****	Visit	MomEdLevel; 

*	call symputx('tableExpr_page'				, quote('AgeGroup'), 'l'); 
*	call symputx('tableExpr_row'				, quote('Race*SomeCollege	Married'), 'l'); 
*	call symputx('tableExpr_col'				, quote('Boy*(MomSmoke	Visit)	MomEdLevel'), 'l'); 

*	call symputx('list_stats'					, 'n	pctn	colpctn	rowpctn	pagepctn	reppctn', 'l'); 
	call symputx('list_stats'					, 'n', 'l'); 
run; 
%put _USER_; 
*/
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			dsn_libname						 $8
			dsn								 $32
			dsn1_libname					 $8
			dsn1							 $32
			output							 $32
			output1							 $32
			output2							 $32
			mvarname						 $32
			prefix_mvarname					 $32
			suffix_mvarname					 $32
		; 

		dsn_libname						 = ifc(find(symget('dsn'), '.')=0, 'work', substrn(symget('dsn'), 1, find(symget('dsn'), '.')-1)); 
		dsn								 = substrn(symget('dsn'), find(symget('dsn'), '.')+1, lengthn(symget('dsn'))-find(symget('dsn'), '.')); 
		dsn1_libname					 = ifc(find(symget('dsn1'), '.')=0, 'work', substrn(symget('dsn1'), 1, find(symget('dsn1'), '.')-1)); 
		dsn1							 = substrn(symget('dsn1'), find(symget('dsn1'), '.')+1, lengthn(symget('dsn1'))-find(symget('dsn1'), '.')); 
	*	output							 = ifc(missing(symget('output')), cats(symget('dsn'), '_freq'), symget('output')); 
	*	mvarname						 = ifc(missing(symget('mvarname')), output, symget('mvarname')); 
	*	prefix_mvarname					 = ifc(missing(symget('prefix_mvarname')), symget('prefix_output'), symget('prefix_mvarname')); 
	*	suffix_mvarname					 = ifc(missing(symget('suffix_mvarname')), symget('suffix_output'), symget('suffix_mvarname')); 
		output							 = coalescec(symget('output'), cats(dsn, '_freq')); 
		output1							 = coalescec(symget('output1'), cats(dsn, '_metaParm')); 
		output2							 = coalescec(symget('output2'), cats(dsn, '_metaCode')); 
		mvarname						 = coalescec(symget('mvarname'), output); 
		prefix_mvarname					 = coalescec(symget('prefix_mvarname'), symget('prefix_output')); 
		suffix_mvarname					 = coalescec(symget('suffix_mvarname'), symget('suffix_output')); 

		call symputx('dsn_libname', dsn_libname, 'l'); 
		call symputx('dsn', dsn, 'l'); 
		call symputx('dsn1_libname', dsn1_libname, 'l'); 
		call symputx('dsn1', dsn1, 'l'); 
		call symputx('output', output, 'l'); 
		call symputx('mvarname', mvarname, 'l'); 
		call symputx('prefix_mvarname', prefix_mvarname, 'l'); 
		call symputx('suffix_mvarname', suffix_mvarname, 'l'); 
	run; 
	data &local_prefix_dataname.dsn; 
		set &dsn_libname..&dsn.; 

		format _ALL_; 
		informat _ALL_; 
	run; 
	****	l0_tmp_dsn, sort by list_varname_by; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		array arr_char_quote$32767 
			local_prefix_dataname
			list_varname_by
		; 
		do over arr_char_quote; 
			arr_char_quote = cats(dequote(symget(vname(arr_char_quote)))); 
		end; 

		if ^missing(list_varname_by) then do; 
			call execute('proc sort data='||cats(local_prefix_dataname, 'dsn')||'; '); 
			call execute('	by '||cats(list_varname_by)||'; '); 
			call execute('run; '); 
		end; 
	run; 
	****	l0_tmp_dsn1; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			dsn1_libname					 $8
			dsn1							 $32
			local_prefix_dataname			 $32
		; 
		array arr_char _CHAR_; 
		do over arr_char; 
			arr_char = cats(symget(cats(vname(arr_char)))); 
		end; 

		if ^missing(dsn1) then do; 
/*			call execute('proc sort data='||cats(dsn1_libname, '.', dsn1)||' out='||cats(local_prefix_dataname)||'dsn1 nodupkey; '); */
/*			call execute('	by _ALL_; '); */
/*			call execute('run; '); */
			call execute('data '||cats(local_prefix_dataname)||'dsn1; '); 
			call execute('	set '||cats(dsn1_libname, '.', dsn1)||'; '); 
			call execute('run; '); 
		end; 
	run; 
	****	l0_tmp_mdP; 
	data &local_prefix_dataname.mdP; 
	run; 

	****	create local macro variable w/ local_prefix_mvarname from keyword parameter; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		array arr_char_quote$32767 
			opt_class	opt_tabulate_missing	opt_table
			varname_univClass_all
			nameConv_classPerm
			list_varname_by
			tableExpr_page	tableExpr_row	tableExpr_col
			list_stats
		; 
		do over arr_char_quote; 
			arr_char_quote = cats(dequote(symget(vname(arr_char_quote)))); 
			call symputx(cats(symget('local_prefix_mvarname'), vname(arr_char_quote)), arr_char_quote, 'l'); 
	****	delete corresponding keyword parameter; 
			call symdel(vname(arr_char_quote)); 
		end; 
	run; 
	data _NULL_; return = dosubl('%put _USER_; '); run; 




	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			opt_classdata					 $32767
			stmt_by							 $32767
			list_varname_class				 $32767
			tableExpr						 $32767

			opt_tabulate_missing			 $32767
			opt_table						 $32767
			varname_univClass_all			 $32

			list_varname_by					 $32767
			tableExpr_page					 $32767
			tableExpr_row					 $32767
			tableExpr_col					 $32767
			list_stats						 $32767

			temp_str						 $32767
			temp_word						 $32
			temp_position					 8
			temp_length						 8
		; 

		array arr_char 
			opt_tabulate_missing	opt_table
			varname_univClass_all

			list_varname_by
			tableExpr_page	tableExpr_row	tableExpr_col
			list_stats
		; 
		do over arr_char; 
			arr_char = cats(symget(cats(symget('local_prefix_mvarname'), vname(arr_char)))); 
		end; 

	*	opt_classdata = ifc(missing(symget('dsn1')), opt_classdata, cats('classdata=', symget('dsn1'))); 
		opt_classdata = ifc(missing(symget('dsn1')), opt_classdata, 'classdata='||cats(symget('local_prefix_dataname'))||'dsn1'); 

		stmt_by = ifc(missing(list_varname_by), stmt_by, 'by '||cats(list_varname_by)); 

		temp_str = catx(', ', tableExpr_page, tableExpr_row, tableExpr_col); 
	/*
		temp_str = transtrn(temp_str, 'seriesc', '_s22_er7iesc_'); 
		test_count = countw(temp_str); 
		test_word = scan(temp_str, 4); 
	*/
		tableExpr = temp_str; 
	/*	do i=1 to countw(temp_str, '	 !$%&()*+,-./;<^|', 's'); */
		do i=1 to countw(temp_str, , 'kn'); ****	modifier 'kn': all characters that can NOT appear in a SAS variable name as delimiters; 
	*		temp_word = scan(temp_str, i); 
	*		temp_word = scan(temp_str, i, '	 ,', 'rs'); 
	*		temp_word = scan(temp_str, i, '	 ,'); 
	/*		temp_word = scan(temp_str, i, '	 !$%&()*+,-./;<^|', 's'); */
			temp_word = scan(temp_str, i, , 'kn'); ****	modifier 'kn': all characters that can NOT appear in a SAS variable name as delimiters; 
	*		call scan(tableExpr, i, temp_position, temp_length); 
	/*		call scan(tableExpr, i, temp_position, temp_length, '	 !$%&()*+,-./;<^|', 's'); */
			call scan(tableExpr, i, temp_position, temp_length, , 'kn'); ****	modifier 'kn': all characters that can NOT appear in a SAS variable name as delimiters; 

			list_varname_class = catx('	', list_varname_class, temp_word); 
			tableExpr = substrn(tableExpr, 1, temp_position-1)||'('||cats(temp_word)||')'||substrn(tableExpr, temp_position+temp_length); 
		end; 
	*	if lowcase(varname_univClass_all)='all' then tableExpr = transtrn(tableExpr, ')', '	'||cats(quote(cats(varname_univClass_all)), ')')); 
		if ^missing(varname_univClass_all) then tableExpr = transtrn(tableExpr, ')', '	'||cats(quote(cats(varname_univClass_all)), ')')); 
		if ^missing(list_stats) then tableExpr = cats(tableExpr, '*(', list_stats, ')'); 

		call symputx(cats(symget('local_prefix_mvarname'), 'opt_classdata'), opt_classdata, 'l'); 
		call symputx(cats(symget('local_prefix_mvarname'), 'stmt_by'), stmt_by, 'l'); 
		call symputx(cats(symget('local_prefix_mvarname'), 'list_varname_class'), list_varname_class, 'l'); 
		call symputx(cats(symget('local_prefix_mvarname'), 'tableExpr'), tableExpr, 'l'); 
	run; 
	%put _USER_; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_dsn1
		refactor from dsn1
		do NOT use SQL combination and permutation, too beg because exponential obs
	********************************************************************************; 
	****	NO, it's better to report errrrrror, DON'T check inconsistency; 
	*data &local_prefix_dataname.sashelp_vcolumn; 
	*	set sashelp.vcolumn; 
	*	where lowcase(libname) in ('work'); 
	*run; 
	*proc sql; 
	*	create table &local_prefix_dataname.0 (keep=name) as
			select * from &local_prefix_dataname.sashelp_vcolumn (keep=libname	memname	name	type where=(lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'dsn')))) as a
			inner join &local_prefix_dataname.sashelp_vcolumn (keep=libname	memname	name	type where=(lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'dsn1')))) as b
			on lowcase(a.name)=lowcase(b.name) & lowcase(a.type)=lowcase(b.type)
		; 
	*quit; 
	data &local_prefix_dataname.0 (keep=name); 
		merge sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'dsn1')))); 
	run; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			dsn1							 $32
			local_prefix_dataname			 $32
			local_prefix_mvarname			 $32

			list_varname_class				 $32767

			temp_count						 8
			temp_varname					 $32
			temp_dataname					 $32
			temp_str						 $32767
		; 
		array arr_parm 
			dsn1
			local_prefix_dataname	local_prefix_mvarname
		; 
		do over arr_parm; 
			arr_parm = cats(symget(cats(vname(arr_parm)))); 
		end; 

		array arr_local 
			list_varname_class
		; 
		do over arr_local; 
			arr_local = cats(symget(cats(local_prefix_mvarname, vname(arr_local)))); 
		end; 

	/*	temp_count = countw(list_varname_class, '	 !$%&()*+,-./;<^|', 's'); */
		temp_count = countw(list_varname_class, , 'kn'); ****	modifier 'kn': all characters that can NOT appear in a SAS variable name as delimiters; 

		call execute('data '||cats(local_prefix_dataname)||'0; '); 
		call execute('run; '); 
		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.0 end=last; 

			call execute('proc sort data='||cats(local_prefix_dataname)||'dsn1 (keep='||cats(name)||') out='||cats(local_prefix_dataname)||'1 nodupkey; '); 
			call execute('	by '||cats(name)||'; '); 
			call execute('run; '); 
			call execute('data '||cats(local_prefix_dataname)||'0; '); 
			call execute('	set '||cats(local_prefix_dataname)||'0	'||cats(local_prefix_dataname)||'1; '); 
			call execute('run; '); 
		end; 
		call execute('proc sort data='||cats(local_prefix_dataname)||'0 nodupkey; '); 
		call execute('	by _ALL_; '); 
		call execute('run; '); 
		stop; 
	run; 
	data &local_prefix_dataname.dsn1; 
		set &local_prefix_dataname.0; 
	run; 
	********************************************************************************
	l0_tmp_dsn1
		refactor from dsn1
		do NOT use SQL combination and permutation, too beg because exponential obs
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_dsn1
		add levels from dsn, in case dsn1 cannot cover all variables in list_varname_class
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			dsn1							 $32
			local_prefix_dataname			 $32
			local_prefix_mvarname			 $32

			list_varname_class				 $32767

			temp_count						 8
			temp_varname					 $32
			temp_dataname					 $32
			temp_str						 $32767
		; 
		array arr_parm 
			dsn1
			local_prefix_dataname	local_prefix_mvarname
		; 
		do over arr_parm; 
			arr_parm = cats(symget(cats(vname(arr_parm)))); 
		end; 

		array arr_local 
			list_varname_class
		; 
		do over arr_local; 
			arr_local = cats(symget(cats(local_prefix_mvarname, vname(arr_local)))); 
		end; 

	*	list_varname_class = catx('	', list_varname_class, list_varname_class); 
	/*	temp_count = countw(list_varname_class, '	 !$%&()*+,-./;<^|', 's'); */
		temp_count = countw(list_varname_class, , 'kn'); ****	modifier 'kn': all characters that can NOT appear in a SAS variable name as delimiters; 

		call execute('data '||cats(local_prefix_dataname)||'0; '); 
		call execute('	set '||cats(local_prefix_dataname)||'dsn1; '); 
		call execute('run; '); 
		do i=1 to temp_count; 
	/*		temp_varname = scan(list_varname_class, i, '	 !$%&()*+,-./;<^|', 's'); */
			temp_varname = scan(list_varname_class, i, , 'kn'); ****	modifier 'kn': all characters that can NOT appear in a SAS variable name as delimiters; 
			output; 
			call execute('proc sort data='||cats(local_prefix_dataname)||'dsn (keep='||cats(temp_varname)||') out='||cats(local_prefix_dataname)||'1 nodupkey; '); 
			call execute('	by '||cats(temp_varname)||'; '); 
			call execute('run; '); 
			call execute('data '||cats(local_prefix_dataname)||'0; '); 
			call execute('	set '||cats(local_prefix_dataname)||'0	'||cats(local_prefix_dataname)||'1; '); 
			call execute('run; '); 
		end; 
		call execute('proc sort data='||cats(local_prefix_dataname)||'0 nodupkey; '); 
		call execute('	by _ALL_; '); 
		call execute('run; '); 
		stop; 
	run; 
	data &local_prefix_dataname.dsn1; 
		set &local_prefix_dataname.0; 
	run; 
	********************************************************************************
	l0_tmp_dsn1
		add levels from dsn, in case dsn1 cannot cover all variables in list_varname_class
	********************************************************************************
	****								Comments								****
	********************************************************************************; 








	ods select none; 
	proc tabulate data=&local_prefix_dataname.dsn out=&local_prefix_dataname.tabulate &&&local_prefix_mvarname.opt_classdata. &&&local_prefix_mvarname.opt_tabulate_missing.; 
		&&&local_prefix_mvarname.stmt_by.; 
		class &&&local_prefix_mvarname.list_varname_class. / &&&local_prefix_mvarname.opt_class.; 
		table &&&local_prefix_mvarname.tableExpr. / &&&local_prefix_mvarname.opt_table.; 
	run; 
	*proc sql; 
	*	alter table &local_prefix_dataname.tabulate modify _TYPE_ char(32767); 
	*quit; 
	ods select all; 








	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_classVar
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.tabulate (keep=&&&local_prefix_mvarname.list_varname_class. obs=0); 
	run; 
	data &local_prefix_dataname.1; 
		length 
			_varnum_						 8
			_varnumFmtz_					 $32
			_varname_						 $32
			_vartype_						 8
			_varlength_						 8
			_varlabel_						 $256
		; 
		set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), '0')))) end=last; 

		_varnum_						 = varnum; 
	*	_varnumFmtz_					 = ; 
		_varname_						 = cats(name); 
		_vartype_						 = ifc(lowcase(type)='num', 1, 2); 
		_varlength_						 = length; 
		_varlabel_						 = cats(label); 
	run; 
	data &local_prefix_dataname.prop_classVar; 
	*	set &local_prefix_dataname.1 (keep=_varnum_	_varname_	_vartype_	_varlength_	_varlabel_); 
		set &local_prefix_dataname.1 (keep=_var:); 
	run; 
	proc datasets lib=&dsn_libname. memtype=data nolist; 
		modify &local_prefix_dataname.prop_classVar; 
		attrib 
			_ALL_							 format= informat= label=''
		; 
	run; quit; 
	********************************************************************************
	l0_tmp_prop_classVar
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_mdP
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		length 
			_mdP_list_varname_by_			 $32767
			_mdP_list_varname_class_		 $32767
			_mdP_classVar_ct_				 8
			_mdP_classVar_ctStd_			 8
			_mdP_classVar_ctStd_dig_		 8
			_mdP_classPerm_length_			 8
			_mdP_classPerm_lengthStd_		 8
		; 
		retain 
			_mdP_list_varname_class_
			_mdP_classVar_ct_
			_mdP_classPerm_length_
		; 
		set &local_prefix_dataname.prop_classVar end=last; 

		_mdP_list_varname_by_			 = cats(symget(cats(symget('local_prefix_mvarname'), 'list_varname_by'))); 
		_mdP_list_varname_class_		 = catx(' ', _mdP_list_varname_class_, _varname_); 
		_mdP_classVar_ct_				 = max(_varnum_, _mdP_classVar_ct_); 
		_mdP_classPerm_length_			 = max(_varlength_, _mdP_classPerm_length_); 

		if last then do; 
			_mdP_classVar_ctStd_			 = max(256, _mdP_classVar_ct_); 
			_mdP_classVar_ctStd_dig_		 = lengthn(cats(_mdP_classVar_ctStd_)); 
			_mdP_classPerm_lengthStd_		 = max(256, _mdP_classPerm_length_); 
		end; 
		if last; 
	run; 
	*proc sort data=&local_prefix_dataname.prop_classVar out=&local_prefix_dataname.1; 
	*	by descending _vartype_	descending _varlength_; ****	in case NO Character var in _mdP_list_varname_class_; 
	*run; 
	data &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.1 (keep=_mdP_:); *	overwrite with the updated value if available; 
	run; 
	********************************************************************************
	l0_tmp_mdP
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_classVar_ct
			l0m_mdP_classVar_ctStd
			l0m_mdP_classVar_ctStd_dig
			l0m_mdP_list_varname_by
			l0m_mdP_list_varname_class
			l0m_mdP_classPerm_length
			l0m_mdP_classPerm_lengthStd
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_prefix						 $32
			temp_varname					 $32
			temp_pos						 8
			temp_indic						 8
			temp_str						 $256
		; 

		local_prefix_dataname = cats(symget('local_prefix_dataname')); 
		temp_prefix = '_mdP_'; 

		call execute('data _NULL_; '); *_NULL_	&local_prefix_dataname.999; 
		call execute('	set '||cats(local_prefix_dataname)||'mdP; '); 
		do until(last); 
			set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'mdP')))) end=last; 

			if cats(lowcase(substrn(cats(name), 1, lengthn(cats(temp_prefix)))))=cats(lowcase(temp_prefix)); 

			temp_varname = cats(name); 
			temp_pos = find(temp_varname, cats(temp_prefix), 'i'); 
			temp_varname = substrn(temp_varname, temp_pos + lengthn(cats(temp_prefix))); 
			temp_indic = substrn(temp_varname, lengthn(temp_varname))='_'; 
			temp_varname = substrn(temp_varname, 1, lengthn(temp_varname)-temp_indic); 
			temp_str = cats('call symputx(cats(symget('||quote(cats('local_prefix_mvarname'))||'), '||quote(cats('mdP_'))||', '||quote(cats(temp_varname))||'), '||cats(name)||', '||quote(cats('1'))||'); '); 
			call execute(temp_str); 
		end; 
		call execute('run; '); 
		stop; 
	run; 
	%put _USER_; 
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_classVar_ct
			l0m_mdP_classVar_ctStd
			l0m_mdP_classVar_ctStd_dig
			l0m_mdP_list_varname_by
			l0m_mdP_list_varname_class
			l0m_mdP_classPerm_length
			l0m_mdP_classPerm_lengthStd
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	macro variable
		delete
			l0m_list_varname_by
			l0m_list_varname_class
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		call symdel(cats(symget('local_prefix_mvarname'), 'list_varname_by')); 
		call symdel(cats(symget('local_prefix_mvarname'), 'list_varname_class')); 
	run; 
	%put _USER_; 
	********************************************************************************
	macro variable
		delete
			l0m_list_varname_by
			l0m_list_varname_class
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_classVar
		assign value to _varnumFmtz_
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.prop_classVar; 

		_varnumFmtz_					 = cats(put(_varnum_, z&&&local_prefix_mvarname.mdP_classVar_ctStd_dig..)); 
	run; 
	data &local_prefix_dataname.prop_classVar; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_prop_classVar
		assign value to _varnumFmtz_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate
		rename to _stats0_:
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.tabulate (
			drop=
				&&&local_prefix_mvarname.mdP_list_varname_by.
				&&&local_prefix_mvarname.mdP_list_varname_class.
			obs=0
			); 
	run; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_varname					 $32
		; 
		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		call execute('data '||cats(local_prefix_dataname)||'1; '); 
		call execute('	set '||cats(local_prefix_dataname)||'tabulate; '); 
		call execute('	rename '); 
		call missing(last); 
		do until (last); 
			set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), '0')))) end=last; 

			temp_varname = name; 
			temp_varname = ifc(substrn(temp_varname, 1, 1)='_', temp_varname, cats('_', temp_varname)); ****	add prefix '_' if not; 
			temp_varname = ifc(substrn(temp_varname, lengthn(temp_varname))='_', temp_varname, cats(temp_varname, '_')); ****	add suffix '_' if not; 
			temp_varname = cats('_stats0', temp_varname); ****	add prefix '_stats0'; 

			call execute('		'||cats(name)||'='||cats(temp_varname)); 
		end; 
		call execute('	; '); 
		call execute('run; '); 
		stop; 
	run; 
	data &local_prefix_dataname.tabulate; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_tabulate
		rename to _stats0_:
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate
	********************************************************************************; 
	data &local_prefix_dataname.1 (drop=i	temp_:); 
		length 
			temp_position					 8
		; 
	*	retain 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_rank_	_classComb_varnumFmtz_	_classComb_varname_	_classComb_varcodeFmtz_	_classComb_permBin_	_classComb_permDec_
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	*	length 
			_classComb_rank_				 8
			_classComb_varnumFmtz_			 $256
			_classComb_varname_				 $512
			_classComb_varcodeFmtz_			 $256
			_classComb_permBin_				 $256
			_classComb_permDec_				 8
		; 
		length 
			_classComb_rank_				 8
			_classComb_varnumFmtz_			 $256
			_classComb_varname_				 $512
			_classComb_varcodeFmtz_			 $256
			_classComb_permBin_				 $&&&local_prefix_mvarname.mdP_classVar_ctStd.
			_classComb_permDec_				 8
		; 
		set &local_prefix_dataname.tabulate; 
		length 
			_stats_nfreq_					 8
		; 

	*	call missing(_classComb_rank_, _classComb_varnumFmtz_, _classComb_varcodeFmtz_, _classComb_permBin_, _classComb_permDec_); 
	*	call missing(of _classComb_:); 
		_classComb_permBin_				 = cats(_stats0_TYPE_); 

		_classComb_rank_				 = count(_classComb_permBin_, '1'); 
	*	_classComb_varnumFmtz_			 = ; 
		temp_position = 1; 
		do i=1 to _classComb_rank_; 
			temp_position = find(_classComb_permBin_, '1', temp_position); 
			_classComb_varnumFmtz_ = cats(_classComb_varnumFmtz_, '_', put(temp_position, z&&&local_prefix_mvarname.mdP_classVar_ctStd_dig..)); 
			temp_position = temp_position + 1; 
		end; 
	*	_classComb_varname_				 = ; 
	*	_classComb_varcodeFmtz_			 = ; 
	*	_classComb_permDec_				 = input(_classComb_permBin_, binary.); ****	format binary. only convert the first 8 digits; 
	*	_classComb_permDec_				 = input(_classComb_permBin_, binary64.); ****	Range	1–64; 
		do i=1 to lengthn(_classComb_permBin_); 
			_classComb_permDec_				 = sum(_classComb_permDec_, input(substrn(_stats0_TYPE_, i, 1), best12.)*(2**(lengthn(_stats0_TYPE_)-i))); 
		end; 

	*	_stats_nfreq_ = max(0, _stats0_N_); 
		_stats_nfreq_ = coalesce(_stats0_N_, 0); 
	run; 
	data &local_prefix_dataname.2; 
		merge 
			&local_prefix_dataname.1 (keep=&&&local_prefix_mvarname.mdP_list_varname_by.)
			&local_prefix_dataname.1 (keep=_classComb_:)
			&local_prefix_dataname.1 (keep=&&&local_prefix_mvarname.mdP_list_varname_class.)
			&local_prefix_dataname.1
		; 
	run; 
	data &local_prefix_dataname.tabulate; 
		set &local_prefix_dataname.2; 
	run; 
	proc sort nodupkey; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	run; 
	********************************************************************************
	l0_tmp_tabulate
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_code_classVar
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.prop_classVar; 
		length 
			_varcode_						 8
			_varcodeFmtz_					 $32
			_varvaluen_						 8
			_varvaluec_						 $&&&local_prefix_mvarname.mdP_classPerm_lengthStd.
			_varvalue_						 $&&&local_prefix_mvarname.mdP_classPerm_lengthStd.
		; 
	run; 
	proc sort data=&local_prefix_dataname.0 (keep=_vartype_) out=&local_prefix_dataname.1 nodupkey; 
		by _vartype_; 
	run; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			_mdP_list_varname_class_		 $32767
			local_prefix_dataname			 $32
			_varname_pk_					 $32
		; 
		_mdP_list_varname_class_			 = cats(symget(cats(symget('local_prefix_mvarname'), 'mdP_list_varname_class'))); 
		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.1 end=last; 

			****	temporarily use _classComb_permBin_	& _classComb_permDec_ for num & char w/o creating new variables; 
			_varname_pk_						 = choosec(3-_vartype_, '_classComb_permDec_', '_classComb_permBin_'); 

			call execute('data '||cats(local_prefix_dataname)||'2; '); 
			call execute('	merge '); 
			call execute('		'||cats(local_prefix_dataname)||'tabulate (keep='||cats(_varname_pk_)||')'); 
			call execute('		'||cats(local_prefix_dataname)||'tabulate (drop='||cats(choosec(3-_vartype_, '_NUMERIC_', '_CHARACTER_'))||' keep='||cats(_mdP_list_varname_class_)||')'); 
			call execute('	; '); 
			call execute('	'||cats(_varname_pk_)||' = _N_; '); 
			call execute('run; '); 

	/*		call execute('proc transpose out='||cats(local_prefix_dataname)||'3 (keep='||cats(_varname_pk_)||'	_NAME_	COL1 where=(^missing(COL1))); '); */
			call execute('proc transpose out='||cats(local_prefix_dataname)||'3 (keep='||cats(_varname_pk_)||'	_NAME_	COL1); '); ****	include missing; 
			call execute('	by '||cats(_varname_pk_)||'; '); 
			call execute('	var '||cats(choosec(_vartype_, '_NUMERIC_', '_CHARACTER_'))||'; '); 
			call execute('run; '); 

			call execute('proc sort out='||cats(local_prefix_dataname)||'4 (keep=_NAME_	COL1) nodupkey; '); 
			call execute('	by _NAME_	COL1; '); 
			call execute('run; '); 

			call execute('proc sql; '); 
			call execute('	create table '||cats(local_prefix_dataname)||'5 as'); 
			call execute('		select * from '||cats(local_prefix_dataname)||'0 as a'); 
			call execute('		left join '||cats(local_prefix_dataname)||'4 as b'); 
			call execute('		on a._varname_=b._NAME_'); 
			call execute('		order by _varnum_, _varvaluen_, _varvaluec_, _varvalue_, COL1'); 
			call execute('	; '); 
			call execute('run; '); 

			call execute('data '||cats(local_prefix_dataname)||'6 (drop=_NAME_	COL1); '); 
			call execute('	set '||cats(local_prefix_dataname)||'5; '); 
			call execute('	'||cats(choosec(_vartype_, '_varvaluen_', '_varvaluec_'))||'							 = COL1; '); 
			call execute('	_varvalue_							 = ifc(missing(_varvaluen_) & missing(_varvaluec_), _varvalue_, cats(choosec(_vartype_, _varvaluen_, _varvaluec_))); '); 
			call execute('run; '); 

			call execute('data '||cats(local_prefix_dataname)||'0; '); 
			call execute('	set '||cats(local_prefix_dataname)||'6; '); 
			call execute('run; '); 
		end; 
		stop; 
	run; 
	data &local_prefix_dataname.1 (drop=temp_:); 
		retain temp_code; 
		set &local_prefix_dataname.0; 
		by _varnum_	_varvaluen_	_varvaluec_	_varvalue_; 

		if first._varnum_ then call missing(temp_code); 
	*	temp_code + 1; 
		select; 
			when (missing(_varvalue_))		 temp_code = 0; 
			otherwise						 temp_code + 1; 
		end; 
		_varcode_ = temp_code; 
	run; 
	data &local_prefix_dataname.code_classVar; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_code_classVar
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_mdP
		add _mdP_classCode_	_mdP_classCodeStd_	_mdP_classCodeStd_dig_	_mdP_classCodeAll_
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		length 
			_mdP_classCode_					 8
			_mdP_classCodeStd_				 8
			_mdP_classCodeStd_dig_			 8
			_mdP_classCodeAll_				 8
		; 
		retain 
			_mdP_classCode_
		; 
		set &local_prefix_dataname.code_classVar end=last; 

		_mdP_classCode_ = max(_varcode_, _mdP_classCode_); 

		if last then do; 
			_mdP_classCodeStd_ = max(256, temp_varcode); 
			_mdP_classCodeStd_dig_ = lengthn(cats(_mdP_classCodeStd_)); 

			_mdP_classCodeAll_ = 10**_mdP_classCodeStd_dig_-10; ****	990; 
		   ****	test; 
		*	_mdP_classCodeStd_ = 995; 
			select; 
				when (_mdP_classCodeAll_>_mdP_classCodeStd_)		 ; ****	990; 
				when (_mdP_classCodeAll_<=_mdP_classCodeStd_)		 _mdP_classCodeAll_ = 10**(_mdP_classCodeStd_dig_+1)-10; 
				otherwise; 
			end; 
		end; 
		if last; 
	run; 
	data &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.1 (keep=_mdP_:); *	overwrite with the updated value if available; 
	run; 
	********************************************************************************
	l0_tmp_mdP
		add _mdP_classCode_	_mdP_classCodeStd_	_mdP_classCodeStd_dig_	_mdP_classCodeAll_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_classCode
			l0m_mdP_classCodeStd
			l0m_mdP_classCodeStd_dig
			l0m_mdP_classCodeAll
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_prefix						 $32
			temp_varname					 $32
			temp_pos						 8
			temp_indic						 8
			temp_str						 $256
		; 

		local_prefix_dataname = cats(symget('local_prefix_dataname')); 
		temp_prefix = '_mdP_'; 

		call execute('data _NULL_; '); *_NULL_	&local_prefix_dataname.999; 
		call execute('	set '||cats(local_prefix_dataname)||'mdP; '); 
		do until(last); 
			set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'mdP')))) end=last; 

			if cats(lowcase(substrn(cats(name), 1, lengthn(cats(temp_prefix)))))=cats(lowcase(temp_prefix)); 

			temp_varname = cats(name); 
			temp_pos = find(temp_varname, cats(temp_prefix), 'i'); 
			temp_varname = substrn(temp_varname, temp_pos + lengthn(cats(temp_prefix))); 
			temp_indic = substrn(temp_varname, lengthn(temp_varname))='_'; 
			temp_varname = substrn(temp_varname, 1, lengthn(temp_varname)-temp_indic); 
			temp_str = cats('call symputx(cats(symget('||quote(cats('local_prefix_mvarname'))||'), '||quote(cats('mdP_'))||', '||quote(cats(temp_varname))||'), '||cats(name)||', '||quote(cats('1'))||'); '); 
			call execute(temp_str); 
		end; 
		call execute('run; '); 
		stop; 
	run; 
	%put _USER_; 
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_classCode
			l0m_mdP_classCodeStd
			l0m_mdP_classCodeStd_dig
			l0m_mdP_classCodeAll
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_code_classVar
		assign value to _varcodeFmtz_
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.code_classVar; 

		_varcodeFmtz_					 = cats(put(_varcode_, z&&&local_prefix_mvarname.mdP_classCodeStd_dig..)); 
	run; 
	data &local_prefix_dataname.code_classVar; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_code_classVar
		assign value to _varcodeFmtz_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 




	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_mdP
		add _mdP_classPerm_dim_	_mdP_classPerm_dimStd_
	********************************************************************************; 
	proc sort data=&local_prefix_dataname.tabulate (keep=_classComb_rank_ rename=(_classComb_rank_=_mdP_classPerm_dim_)) out=&local_prefix_dataname.1 nodupkey; 
		by descending _mdP_classPerm_dim_; 
	run; 
	data &local_prefix_dataname.2; 
		set &local_prefix_dataname.1 (obs=1); 
		length 
			_mdP_classPerm_dimStd_			 8
		; 

		_mdP_classPerm_dimStd_ = max(3, _mdP_classPerm_dim_); 
	run; 
	data &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.2 (keep=_mdP_:); *	overwrite with the updated value if available; 
	run; 
	********************************************************************************
	l0_tmp_mdP
		add _mdP_classPerm_dim_	_mdP_classPerm_dimStd_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_classPerm_dim
			l0m_mdP_classPerm_dimStd
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_prefix						 $32
			temp_varname					 $32
			temp_pos						 8
			temp_indic						 8
			temp_str						 $256
		; 

		local_prefix_dataname = cats(symget('local_prefix_dataname')); 
		temp_prefix = '_mdP_'; 

		call execute('data _NULL_; '); *_NULL_	&local_prefix_dataname.999; 
		call execute('	set '||cats(local_prefix_dataname)||'mdP; '); 
		do until(last); 
			set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'mdP')))) end=last; 

			if cats(lowcase(substrn(cats(name), 1, lengthn(cats(temp_prefix)))))=cats(lowcase(temp_prefix)); 

			temp_varname = cats(name); 
			temp_pos = find(temp_varname, cats(temp_prefix), 'i'); 
			temp_varname = substrn(temp_varname, temp_pos + lengthn(cats(temp_prefix))); 
			temp_indic = substrn(temp_varname, lengthn(temp_varname))='_'; 
			temp_varname = substrn(temp_varname, 1, lengthn(temp_varname)-temp_indic); 
			temp_str = cats('call symputx(cats(symget('||quote(cats('local_prefix_mvarname'))||'), '||quote(cats('mdP_'))||', '||quote(cats(temp_varname))||'), '||cats(name)||', '||quote(cats('1'))||'); '); 
			call execute(temp_str); 
		end; 
		call execute('run; '); 
		stop; 
	run; 
	%put _USER_; 
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_classPerm_dim
			l0m_mdP_classPerm_dimStd
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_var_classPerm
	********************************************************************************; 
	****	&local_prefix_dataname.var_classPerm; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			temp_str						 $32
			temp_word						 $32
			temp_position					 8
			temp_length						 8

			local_prefix_dataname			 $32
		; 
		set &local_prefix_dataname.mdP (keep=_mdP_classPerm_lengthStd_	_mdP_classPerm_dimStd_); 

		local_prefix_dataname = cats(symget(vname(local_prefix_dataname))); 

		call execute('data '||cats(local_prefix_dataname)||'1; '); 
		call execute('	length '); 
		do i=1 to _mdP_classPerm_dimStd_; 
			temp_str = repeat('0', _mdP_classPerm_dimStd_-1); 
			substr(temp_str, i, 1) = '1'; 

			call execute('		_classPerm_num_'	||cats(temp_str)||'_	 8'); 
			call execute('		_classPerm_name_'	||cats(temp_str)||'_	 $32'); 
			call execute('		_classPerm_type_'	||cats(temp_str)||'_	 8'); 
			call execute('		_classPerm_label_'	||cats(temp_str)||'_	 $256'); 
			call execute('		_classPerm_fmt_'	||cats(temp_str)||'_	 $256'); 
			call execute('		_classPerm_infmt_'	||cats(temp_str)||'_	 $256'); 
			call execute('		_classPerm_code_'	||cats(temp_str)||'_	 8'); 
			call execute('		_classPerm_valuen_'	||cats(temp_str)||'_	 8'); 
			call execute('		_classPerm_valuec_'	||cats(temp_str)||'_	 $'||cats(_mdP_classPerm_lengthStd_)); 
			call execute('		_classPerm_value_'	||cats(temp_str)||'_	 $'||cats(_mdP_classPerm_lengthStd_)); 
			output; 
		end; 
		call execute('	; '); 
		call execute('run; '); 
		call execute('data '||cats(local_prefix_dataname)||'var_classPerm; '); 
		call execute('	set '||cats(local_prefix_dataname)||'1 (obs=1); '); 
		call execute('run; '); 
	run; 
	********************************************************************************
	l0_tmp_var_classPerm
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_classPerm
	********************************************************************************; 
	proc contents data=&local_prefix_dataname.var_classPerm out=&local_prefix_dataname.0 noprint; 
	run; 
	proc sort; 
		by VARNUM; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.1 as 
		select * from 
			&local_prefix_dataname.mdP (keep=_mdP_classPerm_dimStd_)
			, &local_prefix_dataname.0
		; 
	quit; 
	data  &local_prefix_dataname.2; 
		length 
			_mdP_classPerm_dimStd_			 8

			_classPerm_seqN_				 8
			_classPerm_seqBin_				 $32
			_classPerm_seqDec_				 8

			_varnum_						 8
			_varname_						 $32
			_vartype_						 8
			_varlength_						 8
			_varlabel_						 $256

			_varname_1_						 $32
		; 
		set &local_prefix_dataname.1; 

		_varnum_ = VARNUM; _varname_ = cats(NAME); _vartype_ = TYPE; _varlength_ = LENGTH; _varlabel_ = cats(LABEL); 

		_classPerm_seqBin_				 = substrn(_varname_, lengthn(_varname_)-_mdP_classPerm_dimStd_, _mdP_classPerm_dimStd_); 
		_classPerm_seqDec_				 = input(_classPerm_seqBin_, binary.); 
		_classPerm_seqN_				 = log2(_classPerm_seqDec_) + 1; 
		_varname_						 = _varname_; 
		select; 
			when (_varname_=:'_classPerm_num_')		 _varname_1_ = 'num'; 
			when (_varname_=:'_classPerm_name_')	 _varname_1_ = 'name'; 
			when (_varname_=:'_classPerm_type_')	 _varname_1_ = 'type'; 
			when (_varname_=:'_classPerm_label_')	 _varname_1_ = 'label'; 
			when (_varname_=:'_classPerm_fmt_')		 _varname_1_ = 'fmt'; 
			when (_varname_=:'_classPerm_infmt_')	 _varname_1_ = 'infmt'; 
			when (_varname_=:'_classPerm_code_')	 _varname_1_ = 'code'; 
			when (_varname_=:'_classPerm_valuen_')	 _varname_1_ = 'valuen'; 
			when (_varname_=:'_classPerm_valuec_')	 _varname_1_ = 'valuec'; 
			when (_varname_=:'_classPerm_value_')	 _varname_1_ = 'value'; 
			otherwise; 
		end; 
		_varname_1_ = cats('_classPerm_', _classPerm_seqBin_, '_', _varname_1_, '_'); 
	run; 
	data  &local_prefix_dataname.prop_classPerm; 
		set &local_prefix_dataname.2 (keep=_mdP_classPerm_dimStd_	_classPerm_:	_varname_:	_varnum_	_varname_	_vartype_	_varlength_	_varlabel_); 
	********************************************************************************
	cats() all Character variables
	********************************************************************************; 
		array arr_char _CHARACTER_; 
		do over arr_char; 
			arr_char = cats(arr_char); 
		end; 
	********************************************************************************
	cats() all Character variables
	********************************************************************************; 
	run; 
	proc datasets lib=&dsn_libname. memtype=data nolist; 
		modify &local_prefix_dataname.prop_classPerm; 
		attrib 
			_ALL_							 format= informat= label=''
		; 
	run; quit; 
	********************************************************************************
	l0_tmp_prop_classPerm
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_comb_classPerm
	********************************************************************************; 
	data &local_prefix_dataname.1 (drop=i); ****	combinations w/ repetition; 
		length 
			_comb_classPerm_permBin_		 $32
			_comb_classPerm_permDec_		 8
			_comb_classPerm_rank_			 8
		; 
		array element[2] _temporary_ (0 1); 
	*	array element[2] _temporary_ (. 1); 
		array bin_classPerm_[&&&local_prefix_mvarname.mdP_classPerm_dimStd.]; 

		do _N_=0 to dim(element)**dim(bin_classPerm_)-1; 
			do i=1 to dim(bin_classPerm_); 
	*			bin_classPerm_[i] = element[1+mod(int(_N_/(dim(element)**(i-1))), dim(element))]; 
				bin_classPerm_[dim(bin_classPerm_)-i+1] = element[1+mod(int(_N_/(dim(element)**(i-1))), dim(element))]; 
			end; 

			_comb_classPerm_permDec_ = _N_; 
	*		_comb_classPerm_permBin_ = cats(put(_comb_classPerm_permDec_, binary.)); 
			_comb_classPerm_permBin_ = cats(put(_comb_classPerm_permDec_, binary&&&local_prefix_mvarname.mdP_classPerm_dimStd..)); 
			_comb_classPerm_rank_ = count(_comb_classPerm_permBin_, '1'); 
			output; 
		end; 
	run; 
	data &local_prefix_dataname.comb_classPerm; 
		set &local_prefix_dataname.1 (drop=bin_classPerm_:); 
	run; 
	********************************************************************************
	l0_tmp_comb_classPerm
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_var_stats
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		length 
			_varname_						 $32
			_varvaluen_						 8
			_varvaluec_						 $32
		; 
		set &local_prefix_dataname.comb_classPerm; 

		_varvaluen_						 = _comb_classPerm_permDec_; 
		_varvaluec_						 = _comb_classPerm_permBin_; 

		_varname_						 = cats('_stats1_n0_', _varvaluec_, '_'); 
		output; 
		_varname_						 = cats('_stats1_pctn_', _varvaluec_, '_'); 
		output; 
	run; 
	proc transpose data=&local_prefix_dataname.0 out=&local_prefix_dataname.1 (drop=_NAME_	_LABEL_); 
		id _varname_; 
		var _varvaluen_; 
	run; 
	data &local_prefix_dataname.var_stats; 
		set &local_prefix_dataname.1 (obs=0); 
	*	keep _stats1_n0_:	_stats1_pctn_:; 
		keep _stats1_:; 
	run; 
	********************************************************************************
	l0_tmp_var_stats
	********************************************************************************
	****								Comments								****
	********************************************************************************; 




	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate_classPerm
	********************************************************************************; 
	proc sql; 
		create table &local_prefix_dataname.0 as 
		select * from 
			&local_prefix_dataname.tabulate
			, &local_prefix_dataname.mdP (keep=_NUMERIC_)
			, &local_prefix_dataname.var_classPerm
		; 
	quit; 
	data &local_prefix_dataname.1 (drop=i	j	temp_:); 
		length 
			temp_str						 $32
			temp_word						 $32
			temp_position					 8
			temp_length						 8
		; 
		set &local_prefix_dataname.0; 

		array 	arr_classPerm_num				 _classPerm_num_:; 
		array 	arr_classPerm_name				 _classPerm_name_:; 
		array 	arr_classPerm_type				 _classPerm_type_:; 
		array 	arr_classPerm_label				 _classPerm_label_:; 
		array 	arr_classPerm_fmt				 _classPerm_fmt_:; 
		array 	arr_classPerm_infmt				 _classPerm_infmt_:; 
		array 	arr_classPerm_code				 _classPerm_code_:; 
		array 	arr_classPerm_valuen			 _classPerm_valuen_:; 
		array 	arr_classPerm_valuec			 _classPerm_valuec_:; 
		array 	arr_classPerm_value				 _classPerm_value_:; 

		do i=1 to _classComb_rank_; 
			temp_position = lengthn(_classComb_permBin_)+1; 
			do j=1 to i until (temp_position=0); 
				temp_position = find(_classComb_permBin_, '1', -temp_position+1); ****	nth instance from right; 
			end; 
	*		temp_word = scan(_mdP_list_varname_class_, temp_position); 
			temp_word = scan(symget(cats(symget('local_prefix_mvarname'), 'mdP_list_varname_class')), temp_position); 
	*		output; 

			arr_classPerm_num[_mdP_classPerm_dimStd_+1-i]		 = temp_position; 
			arr_classPerm_name[_mdP_classPerm_dimStd_+1-i]		 = vnamex(temp_word); 
			arr_classPerm_type[_mdP_classPerm_dimStd_+1-i]		 = ifn(vtypex(temp_word)='N', 1, ifn(vtypex(temp_word)='C', 2, '')); 
			arr_classPerm_label[_mdP_classPerm_dimStd_+1-i]		 = vlabelx(temp_word); 
	*		arr_classPerm_fmt[_mdP_classPerm_dimStd_+1-i]		 = ; 
	*		arr_classPerm_infmt[_mdP_classPerm_dimStd_+1-i]		 = ; 
	*		arr_classPerm_value[_mdP_classPerm_dimStd_+1-i]		 = ; 
	*		arr_classPerm_valuen[_mdP_classPerm_dimStd_+1-i]	 = ; 
	*		arr_classPerm_valuec[_mdP_classPerm_dimStd_+1-i]	 = ; 
			select(cats(lowcase(vtypex(temp_word)))); 
				when ('n') do; 
					arr_classPerm_value[_mdP_classPerm_dimStd_+1-i]		 = ifc(nmiss(vvaluex(temp_word)), '', cats(vvaluex(temp_word))); 
					arr_classPerm_valuen[_mdP_classPerm_dimStd_+1-i]	 = vvaluex(temp_word); 
				end; 
				when ('c') do; 
					arr_classPerm_value[_mdP_classPerm_dimStd_+1-i]		 = vvaluex(temp_word); 
					arr_classPerm_valuec[_mdP_classPerm_dimStd_+1-i]	 = vvaluex(temp_word); 
				end; 
				otherwise; 
			end; 
		end; 
	run; 
	data &local_prefix_dataname.tabulate_classPerm; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_tabulate_classPerm
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate_classPerm
		l0_tmp_tabulate_classPerm left join l0_tmp_code_classVar
		_classPerm_code_ from _varcode_
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.tabulate_classPerm; 
	run; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
		; 
		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.prop_classPerm (where=(_varname_ like '%_num_%')) end=last; 

			call execute('proc sql; '); 
			call execute('	create table '||cats(local_prefix_dataname)||'1 as'); 
			call execute('		select * from '||cats(local_prefix_dataname)||'0 as a'); 
			call execute('		left join '||cats(local_prefix_dataname)||'code_classVar (keep=_varnum_	_varcode_	_varvaluen_	_varvaluec_) as b'); 
			call execute('		on a._classPerm_num_'||cats(_classPerm_seqBin_)||'_=b._varnum_ & a._classPerm_valuen_'||cats(_classPerm_seqBin_)||'_=b._varvaluen_ & a._classPerm_valuec_'||cats(_classPerm_seqBin_)||'_=b._varvaluec_'); 
			call execute('	; '); 
			call execute('quit; '); 

			call execute('data '||cats(local_prefix_dataname)||'2 (drop=_varnum_	_varcode_	_varvaluen_	_varvaluec_); '); 
			call execute('	set '||cats(local_prefix_dataname)||'1; '); 
			call execute('	_classPerm_code_'||cats(_classPerm_seqBin_)||'_ = coalesce(_classPerm_code_'||cats(_classPerm_seqBin_)||'_, _varcode_); '); 
			call execute('run; '); 

			call execute('data '||cats(local_prefix_dataname)||'0; '); 
			call execute('	set '||cats(local_prefix_dataname)||'2; '); 
			call execute('run; '); 
		end; 
		stop; 
	run; 
	data &local_prefix_dataname.tabulate_classPerm; 
		set &local_prefix_dataname.0; 
	run; 
	proc sort nodupkey; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	run; 
	********************************************************************************
	l0_tmp_tabulate_classPerm
		l0_tmp_tabulate_classPerm left join l0_tmp_code_classVar
		_classPerm_code_ from _varcode_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate_classPerm
		add _classComb_varname_	_classComb_varcodeFmtz_
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		length 
			temp_str						 $32
			temp_varname					 $32
			temp_code						 8
		; 
		set &local_prefix_dataname.tabulate_classPerm; 

		call missing(_classComb_varname_, _classComb_varcodeFmtz_); 
		do i=_classComb_rank_ to 1 by -1; 
			temp_str = put(2**(i-1), binary&&&local_prefix_mvarname.mdP_classPerm_dimStd..); 

			_classComb_varname_ = catx('	', _classComb_varname_, vvaluex(cats('_classPerm_name_', temp_str, '_'))); 

			temp_varname = cats('_classPerm_code_', temp_str, '_'); 
	*		if ^missing(temp_varname) then do; 
			temp_code = vvaluex(temp_varname); 
	*		temp_code = max(0, temp_code); 
			_classComb_varcodeFmtz_ = cats(_classComb_varcodeFmtz_, '_', put(temp_code, z&&&local_prefix_mvarname.mdP_classCodeStd_dig..)); 
	*		end; 
		end; 
	run; 
	data &local_prefix_dataname.tabulate_classPerm; 
		set &local_prefix_dataname.1 (drop=i	temp_:); 
	run; 
	********************************************************************************
	l0_tmp_tabulate_classPerm
		add _classComb_varname_	_classComb_varcodeFmtz_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate
		add _classComb_varcodeFmtz_, write back from l0_tmp_tabulate_classPerm
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.tabulate_classPerm (
			keep=
				&&&local_prefix_mvarname.mdP_list_varname_by.
				_classComb_:
				&&&local_prefix_mvarname.mdP_list_varname_class.
				_stats0_:
				_stats_nfreq_
			)
		; 
	run; 
	data &local_prefix_dataname.tabulate; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_tabulate
		add _classComb_varcodeFmtz_, write back from l0_tmp_tabulate_classPerm
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate_classPerm
	l0_tmp_tabulate_classPerm_1
	********************************************************************************; 
	****	&local_prefix_dataname.tabulate_classPerm; 
	****	&local_prefix_dataname.tabulate_classPerm_1; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			dsn_libname						 $32
			local_prefix_dataname			 $32
			nameConv_classPerm				 8

			_mdP_list_varname_by_			 $32767
			_mdP_list_varname_class_		 $32767
		; 
		set &local_prefix_dataname.mdP (keep=_mdP_list_varname_class_); 

		array arr_char_kp 
			dsn_libname
			local_prefix_dataname
		; 
		do over arr_char_kp; 
			arr_char_kp = cats(symget(vname(arr_char_kp))); 
		end; 
		nameConv_classPerm = symgetn(cats(symget('local_prefix_mvarname'), vname(nameConv_classPerm))); 
		array arr_char_local 
			_mdP_list_varname_by_
		; 
	*	do over arr_char_local; 
	*		arr_char_local = cats(symget(cats(symget('local_prefix_mvarname'), vname(arr_char_local)))); 
	*	end; 
		_mdP_list_varname_by_ = cats(symget(cats(symget('local_prefix_mvarname'), 'mdP_list_varname_by'))); 

		if nameConv_classPerm=1 then do; 
			call execute('data '||cats(local_prefix_dataname)||'tabulate_classPerm_'||cats(nameConv_classPerm)||'; '); *data l0_tmp_tabulate_classPerm_1; 
			call execute('	set '||cats(local_prefix_dataname)||'tabulate_classPerm; '); *	set l0_tmp_tabulate_classPerm; 
			call execute('	rename '); 
			do until(last); 
				set &local_prefix_dataname.prop_classPerm end=last; 
				call execute('		'||cats(_varname_)||'='||cats(vvaluex(cats('_varname_', nameConv_classPerm, '_')))); *		classPerm_num_100=classPerm_100_num; 
			end; 
			call execute('	; '); 
			call execute('run; '); 

			call execute('data '||cats(local_prefix_dataname)||'tabulate_classPerm; '); *data l0_tmp_tabulate_classPerm; 
			call execute('	merge '||cats(local_prefix_dataname)||'tabulate_classPerm	'||cats(local_prefix_dataname)||'tabulate_classPerm_'||cats(nameConv_classPerm)||'; '); *	merge l0_tmp_tabulate_classPerm	l0_tmp_tabulate_classPerm_1; 
			*	by 
					_mdP_list_varname_by_
					_classComb_:
					_mdP_list_varname_class_
				; 
			call execute('	by '); 
			call execute('		'||cats(_mdP_list_varname_by_)); 
			call execute('		_classComb_:'); 
			call execute('		'||cats(_mdP_list_varname_class_)); 
			call execute('	; '); 
			call execute('run; '); 
			stop; 
		end; 
	run; 
	********************************************************************************
	l0_tmp_tabulate_classPerm
	l0_tmp_tabulate_classPerm_1
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate_comb
	********************************************************************************; 
	proc sql; 
		create table &local_prefix_dataname.0 as 
		select * from 
			&local_prefix_dataname.tabulate
			, &local_prefix_dataname.mdP (keep=_mdP_classPerm_dimStd_)
			, &local_prefix_dataname.comb_classPerm
		; 
	*	create table &local_prefix_dataname.0 as 
		select * from 
			&local_prefix_dataname.tabulate_classPerm (keep=
					&&&local_prefix_mvarname.mdP_list_varname_by.
					_classComb_:
					&&&local_prefix_mvarname.mdP_list_varname_class.
					_mdP_classPerm_dimStd_
				)
			, &local_prefix_dataname.comb_classPerm
		; 
	quit; 
	proc sort; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	run; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.0; 

		if _classComb_rank_>=_comb_classPerm_rank_; 
		if 2**_classComb_rank_-1>=_comb_classPerm_permDec_; 
	*	if 2**_classComb_rank_-1>_comb_classPerm_permDec_; 
	run; 
	data &local_prefix_dataname.2 (drop=i	j	temp_:); 
	*	length 
			temp_str						 $32
			temp_word						 $32
			temp_position					 8
			temp_length						 8
		; 
		length 
			temp_str						 $&&&local_prefix_mvarname.mdP_classVar_ctStd.
			temp_word						 $32
			temp_position					 8
			temp_length						 8
		; 
		set &local_prefix_dataname.1; 

		temp_str = _classComb_permBin_; 
		if _classComb_rank_>0 then do; 
			do i=1 to _classComb_rank_; 
				if substrn(_comb_classPerm_permBin_, lengthn(_comb_classPerm_permBin_)+1-i, 1)='0' then do; ****	nth digit from right; 
					temp_position = lengthn(_classComb_permBin_)+1; 
					do j=1 to i until (temp_position=0); 
						temp_position = find(_classComb_permBin_, '1', -temp_position+1); ****	nth instance from right; 
					end; 

					substr(temp_str, temp_position, 1) = '0'; 
				end; 
			end; 
		end; 

	*	length 
			_fk_classComb_permBin_			 $32
			_fk_classComb_permDec_			 8
		; 
		length 
			_fk_classComb_permBin_			 $&&&local_prefix_mvarname.mdP_classVar_ctStd.
			_fk_classComb_permDec_			 8
		; 
		call missing(_fk_classComb_permDec_, _fk_classComb_permBin_); 
		_fk_classComb_permBin_ = temp_str; 
	*	_fk_classComb_permDec_ = input(temp_str, binary.); 
		do i=1 to lengthn(temp_str); 
			_fk_classComb_permDec_ = sum(_fk_classComb_permDec_, input(substrn(temp_str, i, 1), best12.)*(2**(lengthn(temp_str)-i))); 
		end; 
	run; 
	data &local_prefix_dataname.tabulate_comb; 
		set &local_prefix_dataname.2; 
	run; 
	********************************************************************************
	l0_tmp_tabulate_comb
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_null_merge
	********************************************************************************; 
	proc sort data=&local_prefix_dataname.tabulate_comb (keep=_fk_:) out=&local_prefix_dataname.0 nodupkey; 
		by _fk_classComb_permBin_; 
	run; 
	data &local_prefix_dataname.1 (drop=i); 
		length 
			_mdP_list_varname_by_			 $32767
			_mdP_list_varname_class_		 $32767
		; 
		set &local_prefix_dataname.0; 

		_mdP_list_varname_by_ = cats(symget(cats(symget('local_prefix_mvarname'), 'mdP_list_varname_by'))); 
	*	_mdP_list_varname_by_ = catx('	', '_fk_classComb_permBin_', _mdP_list_varname_by_); 
		_mdP_list_varname_class_ = cats(symget(cats(symget('local_prefix_mvarname'), 'mdP_list_varname_class'))); 

		do i=1 to countw(_mdP_list_varname_class_); 
			if substrn(_fk_classComb_permBin_, i, 1)='1' then do; 
				_mdP_list_varname_by_ = catx('	', _mdP_list_varname_by_, scan(_mdP_list_varname_class_, i)); 
			end; 
		end; 
	run; 
	data &local_prefix_dataname.null_merge; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_null_merge
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate_comb_n0
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.tabulate_comb; 
		length 
			_stats1_n0_						 8
		; 
	run; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
		; 
		set &local_prefix_dataname.null_merge; 

		local_prefix_dataname = cats(symget('local_prefix_dataname')); 

		call execute('proc sort data='||cats(local_prefix_dataname)||'0; '); 
		call execute('	by _fk_classComb_permBin_	'||cats(_mdP_list_varname_by_)||'; '); 
		call execute('run; '); 
		call execute('proc sort '); 
		call execute('	data='||cats(local_prefix_dataname)||'tabulate ('); 
		call execute('		keep='); 
		call execute('			'||cats(_mdP_list_varname_by_)); 
		call execute('			_classComb_:'); 
		call execute('			_stats_nfreq_'); 
		call execute('		rename=(_classComb_permBin_=_fk_classComb_permBin_	_stats_nfreq_=_fk_stats1_n0_)'); 
		call execute('		where=(_fk_classComb_permBin_='||cats(quote(cats(_fk_classComb_permBin_)))||')'); 
		call execute('		)'); 
		call execute('	out='||cats(local_prefix_dataname)||'1'); 
		call execute('	; '); 
		call execute('	by _fk_classComb_permBin_	'||cats(_mdP_list_varname_by_)||'; '); 
		call execute('run; '); 
		call execute('data '||cats(local_prefix_dataname)||'0 (drop=_fk_stats1_n0_); '); 
		call execute('	merge '||cats(local_prefix_dataname)||'0'||' (in=a)	'||cats(local_prefix_dataname)||'1 (in=b); '); 
		call execute('	by _fk_classComb_permBin_	'||cats(_mdP_list_varname_by_)||'; '); 
		call execute('	if a; '); 
		call execute('	if b then _stats1_n0_ = _fk_stats1_n0_; '); 
		call execute('run; '); 
	run; 
	data &local_prefix_dataname.tabulate_comb_n0; 
		set &local_prefix_dataname.0; 
	run; 
	proc sort; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	run; 
	********************************************************************************
	l0_tmp_tabulate_comb_n0
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabulate_stats
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		length 
			_varname_stats_					 $32
		; 
		_varname_stats_ = '_stats1_n0_'; 
		output; 
		_varname_stats_ = '_stats1_pctn_'; 
		output; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.1 as 
		select * from 
			&local_prefix_dataname.0
			, &local_prefix_dataname.tabulate_comb_n0
		; 
	quit; 
	data &local_prefix_dataname.2; 
		set &local_prefix_dataname.1; 

		if cats(lowcase(_varname_stats_) in ('_stats1_pctn_')) then do; 
			select; 
				when (_stats1_n0_) _stats1_n0_ = _stats_nfreq_/_stats1_n0_; 
				otherwise call missing(_stats1_n0_); 
			end; 
		end; 
		_varname_stats_ = cats(_varname_stats_, _comb_classPerm_permBin_, '_'); 
	run; 
	proc sort out=&local_prefix_dataname.3; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	run; 
	proc transpose out=&local_prefix_dataname.4 (drop=_NAME_	_LABEL_); 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
		id _varname_stats_; 
		var _stats1_n0_; 
	run; 
	data &local_prefix_dataname.5; 
		merge 
			&local_prefix_dataname.4 (drop=_stats1_:)
			&local_prefix_dataname.var_stats
			&local_prefix_dataname.4
		; 
	run; 
	data &local_prefix_dataname.tabulate_stats; 
		set &local_prefix_dataname.5; 
	run; 
	********************************************************************************
	l0_tmp_tabulate_stats
	********************************************************************************
	****								Comments								****
	********************************************************************************; 




	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_stats
	********************************************************************************; 
	*data &local_prefix_dataname.tabulate_var; 
	*	merge 
			&local_prefix_dataname.tabulate_classPerm
			&local_prefix_dataname.var_stats
		; 
	*run; 
	data &local_prefix_dataname.0; 
	*	merge 
			&local_prefix_dataname.tabulate
			&local_prefix_dataname.tabulate_var
			&local_prefix_dataname.tabulate_stats
		; 
		merge 
			&local_prefix_dataname.tabulate_classPerm (drop=_classPerm_:)
			&local_prefix_dataname.tabulate_stats
			&local_prefix_dataname.tabulate_classPerm
		; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	run; 
	data &local_prefix_dataname.stats; 
		set &local_prefix_dataname.0; 
	run; 
	********************************************************************************
	l0_tmp_stats
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	add to l0_tmp_stats
		_stats_n0_col_	_stats_pctn_col_
		_stats_n0_row_	_stats_pctn_row_
		_stats_n0_page_	_stats_pctn_page_
	********************************************************************************; 
	data &local_prefix_dataname.1 (drop=temp_:	i); 
		length 
			temp_comb_classPerm_permDec		 8
			temp_comb_classPerm_permBin		 $32

			_stats_n0_col_					 8
			_stats_pctn_col_				 8
			_stats_n0_row_					 8
			_stats_pctn_row_				 8
			_stats_n0_page_					 8
			_stats_pctn_page_				 8
		; 
		set &local_prefix_dataname.stats; 

		array 	arr_stats_n0					 _stats_n0_col_	_stats_n0_row_	_stats_n0_page_; 
		array 	arr_stats_pctn					 _stats_pctn_col_	_stats_pctn_row_	_stats_pctn_page_; 
		do i=1 to dim(arr_stats_n0); 
			call missing(temp_comb_classPerm_permDec, temp_comb_classPerm_permBin); 
	*		temp_comb_classPerm_permDec = (2**_classComb_rank_-1)-(2**(i-1)); 
	/*
	page		row			col
	100 (4)		110 (6)		101 (5)
	111-11		111-1		111-10
	7-3			7-1			7-2
	*/
			select; 
				when (i=1) 	temp_comb_classPerm_permDec = (2**_classComb_rank_-1)-2; 
				otherwise 	temp_comb_classPerm_permDec = (2**_classComb_rank_-1)-(2**(i-1)-1); 
			end; 
			temp_comb_classPerm_permDec = ifn(temp_comb_classPerm_permDec>=0, temp_comb_classPerm_permDec, .); 
			if temp_comb_classPerm_permDec>=0 then do; 
				temp_comb_classPerm_permBin = cats(put(temp_comb_classPerm_permDec, binary32.)); 
				temp_comb_classPerm_permBin = substrn(temp_comb_classPerm_permBin, lengthn(temp_comb_classPerm_permBin)+1-max(3, _mdP_classPerm_dimStd_), max(3, _mdP_classPerm_dimStd_)); 

				arr_stats_n0[i] = vvaluex(cats('_stats1_n0_', temp_comb_classPerm_permBin, '_')); 
				arr_stats_pctn[i] = vvaluex(cats('_stats1_pctn_', temp_comb_classPerm_permBin, '_')); 
			end; 
		end; 
	run; 
	data &local_prefix_dataname.2; 
	*	merge 
			&local_prefix_dataname.1 (drop=_stats_n0_:	_stats_pctn_:)
			&local_prefix_dataname.1
		; 
	*	merge 
			&local_prefix_dataname.1 (keep=&&&local_prefix_mvarname.mdP_list_varname_by.	_classComb_:	_stats_nfreq_)
			&local_prefix_dataname.1 (drop=&&&local_prefix_mvarname.mdP_list_varname_class.	_stats_n0_0:	_stats_pctn_0:	_stats_n0_1:	_stats_pctn_1:)
			&local_prefix_dataname.1
		; 
		merge 
			&local_prefix_dataname.1 (drop=_stats_n0_:	_stats_pctn_:	_stats1_:	_classPerm_:)
			&local_prefix_dataname.1
		; 
	*	by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
	run; 
	data &local_prefix_dataname.stats; 
		set &local_prefix_dataname.2; 
	run; 
	********************************************************************************
	add to l0_tmp_stats
		_stats_n0_col_	_stats_pctn_col_
		_stats_n0_row_	_stats_pctn_row_
		_stats_n0_page_	_stats_pctn_page_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	add to l0_tmp_stats
		_stats_nmiss_col_
		_stats_nmiss_row_
		_stats_nmiss_page_
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		length 
			_stats_n0_col_					 8
			_stats_nmiss_col_				 8
			_stats_pctn_col_				 8
			_stats_n0_row_					 8
			_stats_nmiss_row_				 8
			_stats_pctn_row_				 8
			_stats_n0_page_					 8
			_stats_nmiss_page_				 8
			_stats_pctn_page_				 8
		; 
	run; 
	data &local_prefix_dataname.var_stats_xyz; ****	col	row	page; 
		set &local_prefix_dataname.1 (obs=0); 
		keep _stats_n0_:	_stats_nmiss_:	_stats_pctn_:; 
	run; 

	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			_classPerm_seqBin_col_			 $32
			_classPerm_seqBin_row_			 $32
			_classPerm_seqBin_page_			 $32
			list_varname_by_nmiss_col		 $32767
			list_varname_by_nmiss_row		 $32767
			list_varname_by_nmiss_page		 $32767
		; 
		set &local_prefix_dataname.prop_classPerm; 

		local_prefix_dataname = cats(symget('local_prefix_dataname')); 

		array arr_classPerm_seqBin _classPerm_seqBin_col_	_classPerm_seqBin_row_	_classPerm_seqBin_page_; 
		array arr_list_varname_by list_varname_by_:; 

			do i=1 to 3; ****	NOT _mdP_classPerm_dimStd_; 
			****	!!!do NOT include _classComb_varcodeFmtz_; 
			arr_list_varname_by[i] = catx('	'
					, '&&&local_prefix_mvarname.mdP_list_varname_by.	_classComb_rank_	_classComb_varnumFmtz_	_classComb_permBin_	_classComb_permDec_'
					, arr_list_varname_by[i]
				); 
		end; 
		do until(last); 
			set &local_prefix_dataname.prop_classPerm end=last; 
	*		where also (_varname_ like '%_classPerm%_num_%') | (_varname_ like '%_classPerm%_valuen_%') | (_varname_ like '%_classPerm%_valuec_%') | (_varname_ like '%_classPerm%_value_%'); 
			where also (_varname_ like '%_classPerm%_num_%') | (_varname_ like '%_classPerm%_code_%'); 
			do i=1 to 3; ****	NOT _mdP_classPerm_dimStd_; 
				if log2(_classPerm_seqDec_)+1=i then arr_classPerm_seqBin[i] = _classPerm_seqBin_; 
				select; 
					when (find(_varname_, '_classPerm_num_', 'i'))	 arr_list_varname_by[i] = catx('	', arr_list_varname_by[i], _varname_); 
					when (log2(_classPerm_seqDec_)+1>=3)				 arr_list_varname_by[i] = catx('	', arr_list_varname_by[i], _varname_); 
					when (log2(_classPerm_seqDec_)+1=i)				 arr_list_varname_by[i] = catx('	', arr_list_varname_by[i], _varname_); 
	*				otherwise	 arr_list_varname_by[i] = catx('	', arr_list_varname_by[i], _varname_); 
					otherwise										 ; 
				end; 
			end; 
		end; 
	*	stop; 

		****	l0_tmp_nmiss_col; 
		call execute('data '||cats(local_prefix_dataname)||'nmiss_col; '); 
		call execute('	set '||cats(local_prefix_dataname)||'stats (where=(^missing(_classPerm_num_'||cats(_classPerm_seqBin_row_)||'_) & missing(_classPerm_value_'||cats(_classPerm_seqBin_row_)||'_))); '); 
		call execute('	keep _stats_nfreq_	'||cats(list_varname_by_nmiss_col)||'; '); 
		call execute('	rename _stats_nfreq_=_stats_nmiss_col_; '); 
		call execute('run; '); 
		call execute('proc sort; by '||cats(list_varname_by_nmiss_col)||'; run; '); 

		****	l0_tmp_nmiss_row; 
		call execute('data '||cats(local_prefix_dataname)||'nmiss_row; '); 
		call execute('	set '||cats(local_prefix_dataname)||'stats (where=(^missing(_classPerm_num_'||cats(_classPerm_seqBin_col_)||'_) & missing(_classPerm_value_'||cats(_classPerm_seqBin_col_)||'_))); '); 
		call execute('	keep _stats_nfreq_	'||cats(list_varname_by_nmiss_row)||'; '); 
		call execute('	rename _stats_nfreq_=_stats_nmiss_row_; '); 
		call execute('run; '); 
		call execute('proc sort; by '||cats(list_varname_by_nmiss_row)||'; run; '); 

		****	l0_tmp_nmiss_page; 
		call execute('data '||cats(local_prefix_dataname)||'nmiss_page; '); 
		call execute('	retain _stats_nmiss_page_	temp_nmiss; '); 
		call execute('	length _stats_nmiss_page_				 8; '); 
		call execute('	set '||cats(local_prefix_dataname)||'nmiss_col	'||cats(local_prefix_dataname)||'nmiss_row end=last; '); 
		call execute('	by '||cats(list_varname_by_nmiss_page)||'; '); 
		call execute('	if first._classPerm_code_'||cats(_classPerm_seqBin_page_)||'_ then call missing(_stats_nmiss_page_); '); 
	/*	call execute('	if n(_classPerm_code_'||cats(_classPerm_seqBin_row_)||'_, _classPerm_code_'||cats(_classPerm_seqBin_col_)||'_)=0 then temp_nmiss = sum(_stats_nmiss_col_, _stats_nmiss_row_); '); */
		call execute('	if sum(_classPerm_code_'||cats(_classPerm_seqBin_row_)||'_, _classPerm_code_'||cats(_classPerm_seqBin_col_)||'_)=0 then temp_nmiss = sum(_stats_nmiss_col_, _stats_nmiss_row_); '); 
		call execute('	_stats_nmiss_page_ + sum(_stats_nmiss_col_, _stats_nmiss_row_); '); 
		call execute('	if last._classPerm_code_'||cats(_classPerm_seqBin_page_)||'_ then do; '); 
		call execute('		_stats_nmiss_page_ = sum(_stats_nmiss_page_, -temp_nmiss); '); 
		call execute('		output; '); 
		call execute('	end; '); 
		call execute('	keep _stats_nmiss_page_	'||cats(list_varname_by_nmiss_page)||'; '); 
		call execute('run; '); 
		call execute('proc sort; by '||cats(list_varname_by_nmiss_page)||'; run; '); 

		****	merge back; 
		call execute('proc sort data='||cats(local_prefix_dataname)||'stats out='||cats(local_prefix_dataname)||'1; '); 
		call execute('	by '||cats(list_varname_by_nmiss_col)||'; '); 
		call execute('run; '); 
		call execute('data '||cats(local_prefix_dataname)||'2; '); 
		call execute('	merge '||cats(local_prefix_dataname)||'1	'||cats(local_prefix_dataname)||'nmiss_col; '); 
		call execute('	by '||cats(list_varname_by_nmiss_col)||'; '); 
		call execute('run; '); 
		call execute('proc sort out='||cats(local_prefix_dataname)||'3; '); 
		call execute('	by '||cats(list_varname_by_nmiss_row)||'; '); 
		call execute('run; '); 
		call execute('data '||cats(local_prefix_dataname)||'4; '); 
		call execute('	merge '||cats(local_prefix_dataname)||'3	'||cats(local_prefix_dataname)||'nmiss_row; '); 
		call execute('	by '||cats(list_varname_by_nmiss_row)||'; '); 
		call execute('run; '); 
		call execute('proc sort out='||cats(local_prefix_dataname)||'5; '); 
		call execute('	by '||cats(list_varname_by_nmiss_page)||'; '); 
		call execute('run; '); 
		call execute('data '||cats(local_prefix_dataname)||'6; '); 
		call execute('	merge '||cats(local_prefix_dataname)||'5	'||cats(local_prefix_dataname)||'nmiss_page; '); 
		call execute('	by '||cats(list_varname_by_nmiss_page)||'; '); 
		call execute('	if nmiss(_stats_nmiss_col_, _stats_nmiss_row_)>0 then call missing(_stats_nmiss_page_); '); 
		call execute('run; '); 
	run; 
	proc sort data=&local_prefix_dataname.6 out=&local_prefix_dataname.7; 
	*	by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname.mdP_list_varname_class.
		; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
	data &local_prefix_dataname.8; 
		merge 
			&local_prefix_dataname.7 (keep=&&&local_prefix_mvarname.mdP_list_varname_by.	_classComb_:	_stats_nfreq_)
			&local_prefix_dataname.var_stats_xyz
			&local_prefix_dataname.7 (keep=_mdP_:	_classPerm_:)
			&local_prefix_dataname.7
		; 

		array 	arr_stats_n0 					_stats_n0_col_	_stats_n0_row_	_stats_n0_page_; 
		array 	arr_stats_nmiss 				_stats_nmiss_col_	_stats_nmiss_row_	_stats_nmiss_page_; 
		array 	arr_stats_pctn 					_stats_pctn_col_	_stats_pctn_row_	_stats_pctn_page_; 
		do over arr_stats_n0; 
			arr_stats_nmiss = ifn(missing(arr_stats_n0), arr_stats_nmiss, coalesce(arr_stats_nmiss, 0)); 
		end; 
	run; 
	data &local_prefix_dataname.stats; 
		set &local_prefix_dataname.8; 
	run; 
	********************************************************************************
	add to l0_tmp_stats
		_stats_nmiss_col_
		_stats_nmiss_row_
		_stats_nmiss_page_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	data &prefix_output.&output.&suffix_output. (compress=binary); 
		set &local_prefix_dataname.stats; 
	run; 
	proc sort; 
	*	by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			&&&local_prefix_mvarname._mdP_list_varname_class_.
		; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
/*
	proc contents data=&prefix_output.&output.&suffix_output. varnum; run; 
*/

	data &prefix_output.&output1.&suffix_output. (compress=binary); 
		set &local_prefix_dataname.mdP; 
	run; 
	data &prefix_output.&output2.&suffix_output. (compress=binary); 
		set &local_prefix_dataname.code_classVar; 
	run; 

	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend tabulate_freq; 


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


%macro convert_freq_to_tab(dsn=, dsn1=, dsn2=, output=tab, mvarname=
	, 	nameConv_varXStats				=0
	, 	indic_statsMissing				=0
	, 	indic_classCodeAll_varY			=1
	, 	symboltable=f, modifiers=i
	, 	prefix_output=temp_, suffix_output=, prefix_mvarname=, suffix_mvarname=
	, 	local_prefix_dataname=l0_tmp_, local_prefix_mvarname=l0_tmp_
	, 	list_varname_by					=
	, 	list_stats						=
	); 
/*
data temp_dsn; 
*	set temp_stats_freq_dim03; 
	set temp_freq_dim03; 

*	if _classComb_rank_; ****	mandatory; 
*	if _classComb_rank_=_mdP_classPerm_dim_; 
run; 
*data temp_dsn1; 
*	set temp_metaParm_dim03; 
*run; 
*data temp_dsn2; 
*	set temp_metaCode_dim03; 
*run; 
data _NULL_; 
	call symputx('dsn'							, 'temp_dsn', 'l'); ****	temp_dsn; 
	call symputx('dsn1'							, '', 'l'); ****	temp_dsn1	temp_metaParm_dim03; 
	call symputx('dsn2'							, '', 'l'); ****	temp_dsn2	temp_metaCode_dim03; 
	call symputx('output'						, 'tab', 'l'); ****	tab	tabulate_tab; 
	call symputx('mvarname'						, '', 'l'); 

	call symputx('nameConv_varXStats'			, '0', 'l'); ****	Naming Convention: 0, 1; 
	call symputx('indic_statsMissing'			, '0', 'l'); ****	include Missing in Statistics: 0, 1; 
	call symputx('indic_classCodeAll_varY'		, '1', 'l'); ****	insert obs with code 990 for varY: 0, 1; 
	call symputx('symboltable'					, 'f', 'l'); 
	call symputx('modifiers'					, 'i', 'l'); 

	call symputx('prefix_output'				, 'temp_', 'l'); 
	call symputx('suffix_output'				, '', 'l'); 
	call symputx('prefix_mvarname'				, '', 'l'); 
	call symputx('suffix_mvarname'				, '', 'l'); 

	call symputx('local_prefix_dataname'		, 'l0_tmp_', 'l'); 
	call symputx('local_prefix_mvarname'		, 'l0m_', 'l'); 

*	call symputx('list_varname_by'				, 'LowBirthWgt', 'l'); ****	LowBirthWgt; 
	call symputx('list_varname_by'				, '', 'l'); ****	LowBirthWgt; 
run; 
%put _USER_; 
*/
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			dsn_libname						 $8
			dsn								 $32
			dsn1_libname					 $8
			dsn1							 $32
			dsn2_libname					 $8
			dsn2							 $32
			output							 $32
			mvarname						 $32
			prefix_mvarname					 $32
			suffix_mvarname					 $32
		; 

		dsn_libname						 = ifc(find(symget('dsn'), '.')=0, 'work', substrn(symget('dsn'), 1, find(symget('dsn'), '.')-1)); 
		dsn								 = substrn(symget('dsn'), find(symget('dsn'), '.')+1, lengthn(symget('dsn'))-find(symget('dsn'), '.')); 
		dsn1_libname					 = ifc(find(symget('dsn1'), '.')=0, 'work', substrn(symget('dsn1'), 1, find(symget('dsn1'), '.')-1)); 
		dsn1							 = substrn(symget('dsn1'), find(symget('dsn1'), '.')+1, lengthn(symget('dsn1'))-find(symget('dsn1'), '.')); 
		dsn2_libname					 = ifc(find(symget('dsn2'), '.')=0, 'work', substrn(symget('dsn2'), 1, find(symget('dsn2'), '.')-1)); 
		dsn2							 = substrn(symget('dsn2'), find(symget('dsn2'), '.')+1, lengthn(symget('dsn2'))-find(symget('dsn2'), '.')); 
		output							 = coalescec(symget('output'), cats(dsn, '_tab')); 
		mvarname						 = coalescec(symget('mvarname'), output); 
		prefix_mvarname					 = coalescec(symget('prefix_mvarname'), symget('prefix_output')); 
		suffix_mvarname					 = coalescec(symget('suffix_mvarname'), symget('suffix_output')); 

		call symputx('dsn_libname', dsn_libname, 'l'); 
		call symputx('dsn', dsn, 'l'); 
		call symputx('dsn1_libname', dsn1_libname, 'l'); 
		call symputx('dsn1', dsn1, 'l'); 
		call symputx('dsn2_libname', dsn2_libname, 'l'); 
		call symputx('dsn2', dsn2, 'l'); 
		call symputx('output', output, 'l'); 
		call symputx('mvarname', mvarname, 'l'); 
		call symputx('prefix_mvarname', prefix_mvarname, 'l'); 
		call symputx('suffix_mvarname', suffix_mvarname, 'l'); 
	run; 
	%put _USER_; 
	****	l0_tmp_dsn; 
	data &local_prefix_dataname.dsn; 
		set &dsn_libname..&dsn.; 
		where _classComb_rank_; 
	run; 
	****	l0_tmp_mdP; 
	data &local_prefix_dataname.mdP; 
	*	set &dsn1_libname..&dsn1.; 
	run; 
	****	l0_tmp_code_classVar; 
	*data &local_prefix_dataname.code_classVar; 
	*	set &dsn2_libname..&dsn2.; 
	*run; 

	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		array arr_char_quote$32767 
			list_varname_by
		; 
		do over arr_char_quote; 
			arr_char_quote = cats(dequote(symget(vname(arr_char_quote)))); 
			call symputx(cats(symget('local_prefix_mvarname'), vname(arr_char_quote)), arr_char_quote, 'l'); 
		end; 
	run; 
	data _NULL_; return = dosubl('%put _USER_; '); run; 




	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_mdP
		add _mdP_list_varname_by_
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		length 
			_mdP_list_varname_by_			 $32767
		; 
		retain 
			_mdP_list_varname_by_
		; 
		set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'dsn')))) end=last; 

		select; 
			when (lowcase(name)=lowcase('_classComb_rank_') & varnum=1)		 do; ****	in case _mdP_list_varname_by_ is missing, otherwise 0 obs for l0_tmp_mdP; 
				output; 
				stop; 
			end; 
			when (lowcase(name)=lowcase('_classComb_rank_'))				 do; 
	*		when (lowcase(name)=lowcase('_stats_nfreq_'))					 do; 
				stop; 
			end; 
			otherwise														 do; 
				_mdP_list_varname_by_ = catx('	', _mdP_list_varname_by_, name); 
				output; 
			end; 
		end; 
	run; 
	data &local_prefix_dataname.2; 
		set &local_prefix_dataname.1 end=last; 

		if last; 
	run; 
	data &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.2 (keep=_mdP_:); *	overwrite with the updated value if available; 
	run; 
	********************************************************************************
	l0_tmp_mdP
		add _mdP_list_varname_by_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_list_varname_by
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_prefix						 $32
			temp_varname					 $32
			temp_pos						 8
			temp_indic						 8
			temp_str						 $256
		; 

		local_prefix_dataname = cats(symget('local_prefix_dataname')); 
		temp_prefix = '_mdP_'; 

		call execute('data _NULL_; '); *_NULL_	&local_prefix_dataname.999; 
		call execute('	set '||cats(local_prefix_dataname)||'mdP; '); 
		do until(last); 
			set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'mdP')))) end=last; 

			if cats(lowcase(substrn(cats(name), 1, lengthn(cats(temp_prefix)))))=cats(lowcase(temp_prefix)); 

			temp_varname = cats(name); 
			temp_pos = find(temp_varname, cats(temp_prefix), 'i'); 
			temp_varname = substrn(temp_varname, temp_pos + lengthn(cats(temp_prefix))); 
			temp_indic = substrn(temp_varname, lengthn(temp_varname))='_'; 
			temp_varname = substrn(temp_varname, 1, lengthn(temp_varname)-temp_indic); 
			temp_str = cats('call symputx(cats(symget('||quote(cats('local_prefix_mvarname'))||'), '||quote(cats('mdP_'))||', '||quote(cats(temp_varname))||'), '||cats(name)||', '||quote(cats('1'))||'); '); 
			call execute(temp_str); 
		end; 
		call execute('run; '); 
		stop; 
	run; 
	%put _USER_; 
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_list_varname_by
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_mdP
		add _mdP_list_varname_class_
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn (
			drop=
				&&&local_prefix_mvarname.mdP_list_varname_by.
				_classComb_:
				_stats_:
				_mdP_:
				_classPerm_:
				_stats0_:
				_stats1_:
			obs=0
			); 
	run; 
	data &local_prefix_dataname.1; 
		length 
			_mdP_list_varname_class_		 $32767
		; 
		retain 
			_mdP_list_varname_class_
		; 
		set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), '0')))) end=last; 

		_mdP_list_varname_class_ = catx('	', _mdP_list_varname_class_, name); 
	run; 
	data &local_prefix_dataname.2; 
		set &local_prefix_dataname.1 end=last; 

		if last; 
	run; 
	data &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.2 (keep=_mdP_:); *	overwrite with the updated value if available; 
	run; 
	********************************************************************************
	l0_tmp_mdP
		add _mdP_list_varname_class_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_mdP
		add _NUMERIC_
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.dsn (keep=_mdP_: obs=1); 
	run; 
	data &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.mdP; 
		set &local_prefix_dataname.1 (keep=_mdP_:); *	overwrite with the updated value if available; 
	run; 
	********************************************************************************
	l0_tmp_mdP
		add _NUMERIC_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_list_varname_class
			_NUMERIC_
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_prefix						 $32
			temp_varname					 $32
			temp_pos						 8
			temp_indic						 8
			temp_str						 $256
		; 

		local_prefix_dataname = cats(symget('local_prefix_dataname')); 
		temp_prefix = '_mdP_'; 

		call execute('data _NULL_; '); *_NULL_	&local_prefix_dataname.999; 
		call execute('	set '||cats(local_prefix_dataname)||'mdP; '); 
		do until(last); 
			set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), 'mdP')))) end=last; 

			if cats(lowcase(substrn(cats(name), 1, lengthn(cats(temp_prefix)))))=cats(lowcase(temp_prefix)); 

			temp_varname = cats(name); 
			temp_pos = find(temp_varname, cats(temp_prefix), 'i'); 
			temp_varname = substrn(temp_varname, temp_pos + lengthn(cats(temp_prefix))); 
			temp_indic = substrn(temp_varname, lengthn(temp_varname))='_'; 
			temp_varname = substrn(temp_varname, 1, lengthn(temp_varname)-temp_indic); 
			temp_str = cats('call symputx(cats(symget('||quote(cats('local_prefix_mvarname'))||'), '||quote(cats('mdP_'))||', '||quote(cats(temp_varname))||'), '||cats(name)||', '||quote(cats('1'))||'); '); 
			call execute(temp_str); 
		end; 
		call execute('run; '); 
		stop; 
	run; 
	%put _USER_; 
	********************************************************************************
	macro variable
		recreate all from data l0_tmp_mdP, new below: 
			l0m_mdP_list_varname_class
			_NUMERIC_
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_dsn
		update _mdP_:
	********************************************************************************; 
	proc sql; 
		create table &local_prefix_dataname.0 as 
		select * from 
			&local_prefix_dataname.dsn (drop=_mdP_:)
			, &local_prefix_dataname.mdP (keep=_NUMERIC_)
		; 
	quit; 
	data &local_prefix_dataname.1; 
		merge 
			&local_prefix_dataname.0 (keep=&&&local_prefix_mvarname.mdP_list_varname_by.	_classComb_:	_stats_:)
			&local_prefix_dataname.mdp (keep=_NUMERIC_ obs=0)
			&local_prefix_dataname.0
		; 
	run; 
	data &local_prefix_dataname.dsn; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_dsn
		update _mdP_:
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_dsn
		indic_statsMissing
			include Missing in Statistics: 0, 1
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.dsn; 

		array 	arr_stats_n0 					_stats_n0_col_	_stats_n0_row_	_stats_n0_page_; 
		array 	arr_stats_nmiss 				_stats_nmiss_col_	_stats_nmiss_row_	_stats_nmiss_page_; 
		array 	arr_stats_pctn 					_stats_pctn_col_	_stats_pctn_row_	_stats_pctn_page_; 

		array	arr_classPerm_code				_classPerm_code_:; 

		select (input(symget('indic_statsMissing'), best12.)); 
	*	select (0); ****	test; 
			when (0)	 do; 
				do over arr_stats_n0; 
					arr_stats_n0 = arr_stats_n0 - arr_stats_nmiss; 
	*				arr_stats_pctn = _stats_nfreq_/arr_stats_n0; 
					if arr_stats_n0 then arr_stats_pctn = _stats_nfreq_/arr_stats_n0; 
				end; 

				****	when _classPerm_code_001=0 (value is missing), set missing to percentage; 
				if (arr_classPerm_code[_mdP_classPerm_dimStd_]=0)	 then call missing(_stats_pctn_row_, _stats_pctn_page_); 
				****	when _classPerm_code_010=0 (value is missing), set missing to percentage; 
				if (arr_classPerm_code[_mdP_classPerm_dimStd_-1]=0)	 then call missing(_stats_pctn_col_, _stats_pctn_page_); 
			end; 
			when (1)	 do; 
			end; 
			otherwise; 
		end; 
	run; 
	data &local_prefix_dataname.dsn; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_dsn
		indic_statsMissing
			include Missing in Statistics: 0, 1
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_varXAll
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn; 
	run; 
	data &local_prefix_dataname.1; 
		length 
			temp_classComb_varcodeFmtz		 $256
			temp_str						 $32
		; 
		set &local_prefix_dataname.0; 

		temp_classComb_varcodeFmtz = cats(reverse(_classComb_varcodeFmtz_)); ****	XXX_YYY_ZZZ_; 
		temp_classComb_varcodeFmtz = substrn(temp_classComb_varcodeFmtz, find(temp_classComb_varcodeFmtz, '_')+1); ****	YYY_ZZZ_; 
		temp_classComb_varcodeFmtz = cats(reverse(temp_classComb_varcodeFmtz)); ****	_ZZZ_YYY; 
		temp_classComb_varcodeFmtz = cats(temp_classComb_varcodeFmtz, '_', _mdP_classCodeAll_); ****	_ZZZ_YYY_990; 
		_classComb_varcodeFmtz_ = temp_classComb_varcodeFmtz; 

		array	arr_classPerm_code				_classPerm_code_:; 
		arr_classPerm_code[_mdP_classPerm_dimStd_] = _mdP_classCodeAll_; 
	run; 
	proc sort out=&local_prefix_dataname.2 (drop=temp_:) nodupkey; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
	data &local_prefix_dataname.3; 
		set &local_prefix_dataname.2; 

		_stats_nfreq_ = _stats_n0_row_; 
		_stats_n0_col_ = _stats_n0_page_; 
		_stats_nmiss_col_ = _stats_nmiss_page_; 
	*	_stats_pctn_col_ = _stats_nfreq_/_stats_n0_col_; ****	errrrrror; 
		if _stats_n0_col_ then _stats_pctn_col_ = _stats_nfreq_/_stats_n0_col_; 
	*	_stats_n0_row_ = ; 
	*	_stats_nmiss_row_ = ; 
	*	call missing(_stats_pctn_row_); 
		if _stats_n0_row_ then _stats_pctn_row_ = _stats_nfreq_/_stats_n0_row_; 
	*	_stats_n0_page_ = ; 
	*	_stats_nmiss_page_ = ; 
	*	_stats_pctn_page_ = _stats_nfreq_/_stats_n0_page_; ****	errrrrror; 
		if _stats_n0_page_ then _stats_pctn_page_ = _stats_nfreq_/_stats_n0_page_; 
	run; 
	data &local_prefix_dataname.varXAll; ****	_ZZZ_YYY_990 (_ZZZ_000_990, _ZZZ_001_990, ...); 
		set &local_prefix_dataname.3; 
	run; 
	********************************************************************************
	l0_tmp_varXAll
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_varYAll
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn; 
	run; 
	data &local_prefix_dataname.1; 
		length 
			temp_classComb_varcodeFmtz		 $256
			temp_str						 $32
		; 
		set &local_prefix_dataname.0; 
		where _classComb_rank_>=2; 

		temp_classComb_varcodeFmtz = cats(reverse(_classComb_varcodeFmtz_)); ****	XXX_YYY_ZZZ_; 
		temp_str = reverse(substrn(temp_classComb_varcodeFmtz, 1, find(temp_classComb_varcodeFmtz, '_'))); ****	_XXX; 
		temp_classComb_varcodeFmtz = substrn(temp_classComb_varcodeFmtz, find(temp_classComb_varcodeFmtz, '_')+1); ****	YYY_ZZZ_; 
		temp_classComb_varcodeFmtz = substrn(temp_classComb_varcodeFmtz, find(temp_classComb_varcodeFmtz, '_')+1); ****	ZZZ_; 
		temp_classComb_varcodeFmtz = cats(reverse(temp_classComb_varcodeFmtz)); ****	_ZZZ; 
		temp_classComb_varcodeFmtz = cats(temp_classComb_varcodeFmtz, '_', _mdP_classCodeAll_); ****	_ZZZ_990; 
		temp_classComb_varcodeFmtz = cats(temp_classComb_varcodeFmtz, temp_str); ****	_ZZZ_990_XXX; 
		_classComb_varcodeFmtz_ = temp_classComb_varcodeFmtz; 

		array	arr_classPerm_code				_classPerm_code_:; 
		arr_classPerm_code[_mdP_classPerm_dimStd_-1] = _mdP_classCodeAll_; 
	run; 
	proc sort out=&local_prefix_dataname.2 (drop=temp_:) nodupkey; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
	data &local_prefix_dataname.3; 
		set &local_prefix_dataname.2; 

		_stats_nfreq_ = _stats_n0_col_; 
		*_stats_n0_col_ = ; 
		*_stats_nmiss_col_ = ; 
	*	call missing(_stats_pctn_col_); 
		if _stats_n0_col_ then _stats_pctn_col_ = _stats_nfreq_/_stats_n0_col_; 
		_stats_n0_row_ = _stats_n0_page_; 
		_stats_nmiss_row_ = _stats_nmiss_page_; 
	*	_stats_pctn_row_ = _stats_nfreq_/_stats_n0_row_; ****	errrrrror; 
		if _stats_n0_row_ then _stats_pctn_row_ = _stats_nfreq_/_stats_n0_row_; 
	*	_stats_n0_page_ = ; 
	*	_stats_nmiss_page_ = ; 
	*	_stats_pctn_page_ = _stats_nfreq_/_stats_n0_page_; ****	errrrrror; 
		if _stats_n0_page_ then _stats_pctn_page_ = _stats_nfreq_/_stats_n0_page_; 
	run; 
	data &local_prefix_dataname.varYAll; ****	_ZZZ_990_XXX (_ZZZ_990_000, _ZZZ_990_001, ...); 
		set &local_prefix_dataname.3; 
	run; 
	********************************************************************************
	l0_tmp_varYAll
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_varZAll
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn; 
	run; 
	data &local_prefix_dataname.1; 
		length 
			temp_classComb_varcodeFmtz		 $256
			temp_str						 $32
		; 
		set &local_prefix_dataname.0; 
		where _classComb_rank_>=2; 

		temp_classComb_varcodeFmtz = cats(reverse(_classComb_varcodeFmtz_)); ****	XXX_YYY_ZZZ_; 
		temp_classComb_varcodeFmtz = substrn(temp_classComb_varcodeFmtz, find(temp_classComb_varcodeFmtz, '_')+1); ****	YYY_ZZZ_; 
		temp_classComb_varcodeFmtz = substrn(temp_classComb_varcodeFmtz, find(temp_classComb_varcodeFmtz, '_')+1); ****	ZZZ_; 
		temp_classComb_varcodeFmtz = cats(reverse(temp_classComb_varcodeFmtz)); ****	_ZZZ; 
		temp_classComb_varcodeFmtz = cats(temp_classComb_varcodeFmtz, '_', _mdP_classCodeAll_); ****	_ZZZ_990; 
		temp_classComb_varcodeFmtz = cats(temp_classComb_varcodeFmtz, '_', _mdP_classCodeAll_); ****	_ZZZ_990_990; 
		_classComb_varcodeFmtz_ = temp_classComb_varcodeFmtz; 

		array	arr_classPerm_code				_classPerm_code_:; 
		arr_classPerm_code[_mdP_classPerm_dimStd_-1] = _mdP_classCodeAll_; 
		arr_classPerm_code[_mdP_classPerm_dimStd_] = _mdP_classCodeAll_; 
	run; 
	proc sort out=&local_prefix_dataname.2 (drop=temp_:) nodupkey; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
	data &local_prefix_dataname.3; 
		set &local_prefix_dataname.2; 

		_stats_nfreq_ = _stats_n0_page_; 
		_stats_n0_col_ = _stats_n0_page_; 
		_stats_nmiss_col_ = _stats_nmiss_page_; 
	*	call missing(_stats_pctn_col_); 
		if _stats_n0_col_ then _stats_pctn_col_ = _stats_nfreq_/_stats_n0_col_; 
		_stats_n0_row_ = _stats_n0_page_; 
		_stats_nmiss_row_ = _stats_nmiss_page_; 
	*	call missing(_stats_pctn_row_); 
		if _stats_n0_row_ then _stats_pctn_row_ = _stats_nfreq_/_stats_n0_row_; 
	*	_stats_n0_page_ = ; 
	*	_stats_nmiss_page_ = ; 
	*	call missing(_stats_pctn_page_); 
		if _stats_n0_page_ then _stats_pctn_page_ = _stats_nfreq_/_stats_n0_page_; 
	run; 
	data &local_prefix_dataname.varZAll; ****	_ZZZ_990_990; 
		set &local_prefix_dataname.3; 
	run; 
	********************************************************************************
	l0_tmp_varZAll
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_dsn
		add _ZZZ_YYY_990	_ZZZ_990_XXX	_ZZZ_990_990
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		merge 
			&local_prefix_dataname.dsn
			&local_prefix_dataname.varXAll
			&local_prefix_dataname.varYAll
			&local_prefix_dataname.varZAll
		; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
	data &local_prefix_dataname.dsn; 
		set &local_prefix_dataname.0; 
	run; 
	********************************************************************************
	l0_tmp_dsn
		add _ZZZ_YYY_990	_ZZZ_990_XXX	_ZZZ_990_990
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_dsn
		indic_statsMissing
			set missing to percentage
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.dsn; 

		array 	arr_stats_n0 					_stats_n0_col_	_stats_n0_row_	_stats_n0_page_; 
		array 	arr_stats_nmiss 				_stats_nmiss_col_	_stats_nmiss_row_	_stats_nmiss_page_; 
		array 	arr_stats_pctn 					_stats_pctn_col_	_stats_pctn_row_	_stats_pctn_page_; 

		array	arr_classPerm_code				_classPerm_code_:; 

		select (input(symget('indic_statsMissing'), best12.)); 
	*	select (0); ****	test; 
			when (0)	 do; 
				****	when _classPerm_code_001=0 (value is missing), set missing to percentage; 
				if (arr_classPerm_code[_mdP_classPerm_dimStd_]=0)	 then call missing(_stats_pctn_row_, _stats_pctn_page_); 
				****	when _classPerm_code_010=0 (value is missing), set missing to percentage; 
				if (arr_classPerm_code[_mdP_classPerm_dimStd_-1]=0)	 then call missing(_stats_pctn_col_, _stats_pctn_page_); 
			end; 
			when (1)	 do; 
			end; 
			otherwise; 
		end; 
	run; 
	data &local_prefix_dataname.dsn; 
		set &local_prefix_dataname.1; 
	run; 
	********************************************************************************
	l0_tmp_dsn
		indic_statsMissing
			set missing to percentage
	********************************************************************************
	****								Comments								****
	********************************************************************************; 




	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_classPerm
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn (keep=_classPerm_: obs=0); 
	run; 
	data &local_prefix_dataname.1; 
		length 
			_classPerm_seqN_				 8
			_classPerm_seqBin_				 $32
			_classPerm_seqDec_				 8

			_varnum_						 8
			_varname_						 $32
			_vartype_						 8
			_varlength_						 8
			_varlabel_						 $256
		; 
		set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), '0')))) end=last; 

		_varnum_						 = varnum; 
		_varname_						 = cats(name); 
		_vartype_						 = ifc(lowcase(type)='num', 1, 2); 
		_varlength_						 = length; 
		_varlabel_						 = cats(label); 

		_classPerm_seqBin_				 = cats(compress(_varname_, '', 'kd')); 
		_classPerm_seqDec_				 = input(_classPerm_seqBin_, binary32.); 
		_classPerm_seqN_				 = log2(_classPerm_seqDec_) + 1; 
	run; 
	data &local_prefix_dataname.prop_classPerm; 
		set &local_prefix_dataname.1 (keep=_classPerm_:	_var:); 
	run; 
	proc datasets lib=&dsn_libname. memtype=data nolist; 
		modify &local_prefix_dataname.prop_classPerm; 
		attrib 
			_ALL_							 format= informat= label=''
		; 
	run; quit; 
	********************************************************************************
	l0_tmp_prop_classPerm
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_classVar
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn (keep=&&&local_prefix_mvarname.mdP_list_varname_class. obs=0); 
	run; 
	data &local_prefix_dataname.1; 
		length 
			_varnum_						 8
			_varnumFmtz_					 $32
			_varname_						 $32
			_vartype_						 8
			_varlength_						 8
			_varlabel_						 $256
		; 
		set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), '0')))) end=last; 

		_varnum_						 = varnum; 
		_varnumFmtz_					 = cats(put(_varnum_, z&&&local_prefix_mvarname.mdP_classVar_ctStd_dig..)); 
		_varname_						 = cats(name); 
		_vartype_						 = ifc(lowcase(type)='num', 1, 2); 
		_varlength_						 = length; 
		_varlabel_						 = cats(label); 
	run; 
	data &local_prefix_dataname.prop_classVar; 
		set &local_prefix_dataname.1 (keep=_var:); 
	run; 
	proc datasets lib=&dsn_libname. memtype=data nolist; 
		modify &local_prefix_dataname.prop_classVar; 
		attrib 
			_ALL_							 format= informat= label=''
		; 
	run; quit; 
	********************************************************************************
	l0_tmp_prop_classVar
	********************************************************************************
	****								Comments								****
	********************************************************************************; 
	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_classVar_varX
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
		; 
		set &local_prefix_dataname.prop_classPerm; 
		where also _classPerm_seqDec_=1; 
		where also _varname_ like '%_classPerm_num_%'; 

		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		call execute('proc sort data='||cats(local_prefix_dataname)||'dsn (keep='||cats(_varname_)||') out='||cats(local_prefix_dataname)||'1 nodupkey; '); 
		call execute('	by '||cats(_varname_)||'; '); 
		call execute('run; '); 
		call execute('data '||cats(local_prefix_dataname)||'2; '); 
		call execute('	merge '); 
		call execute('		'||cats(local_prefix_dataname)||'prop_classVar'); 
		call execute('		'||cats(local_prefix_dataname)||'1 (in=b rename=('||cats(_varname_)||'=_varnum_))'); 
		call execute('	; '); 
		call execute('	by _varnum_; '); 
		call execute('	if b; '); 
		call execute('run; '); 
	run; 
	data &local_prefix_dataname.prop_classVar_varX; 
		set &local_prefix_dataname.2; 
	run; 
	********************************************************************************
	l0_tmp_prop_classVar_varX
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_code_classVar_varX
	********************************************************************************; 
	****	l0_tmp_0; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_varname					 $32
		; 
		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		call execute('proc sort '); 
		call execute('	data='||cats(local_prefix_dataname)||'dsn ('); 
		call execute('		keep='); 
		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.prop_classPerm (where=(_classPerm_seqN_=1)) end=last; 
			call execute('			'||cats(_varname_)); 
		end; 
		call execute('		)'); 
		call execute('	out='||cats(local_prefix_dataname)||'0 ('); 
		call execute('		rename=('); 
		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.prop_classPerm (where=(_classPerm_seqN_=1)) end=last; 
			temp_varname = substrn(_varname_, 1, find(_varname_, cats(_classPerm_seqBin_))-1); 
			temp_varname = transtrn(temp_varname, '_classPerm_', '_var'); 
			call execute('			'||cats(_varname_)||'='||cats(temp_varname)); 
		end; 
		call execute('			)'); 
		call execute('		)'); 
		call execute('	nodupkey'); 
		call execute('; '); 
		call execute('	by '); 
		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.prop_classPerm (where=(_classPerm_seqN_=1)) end=last; 
			call execute('			'||cats(_varname_)); 
		end; 
		call execute('	; '); 
		call execute('	'); 
		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.prop_classPerm end=last; 

		end; 
		call execute('run; '); 
		stop; 
	run; 
	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.prop_classVar_varX; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.2 as 
			select * from &local_prefix_dataname.1 as a
			left join &local_prefix_dataname.0 (keep=_varnum_	_varcode_) as b
			on a._varnum_=b._varnum_
			order by _varnum_, _varcode_
		; 
	quit; 
	data &local_prefix_dataname.3; 
		set &local_prefix_dataname.2; 
		length 
			_varcode_						 8
			_varcodeFmtz_					 $32
			_varvaluen_						 8
			_varvaluec_						 $&&&local_prefix_mvarname.mdP_classPerm_lengthStd.
			_varvalue_						 $&&&local_prefix_mvarname.mdP_classPerm_lengthStd.
		; 
	run; 
	data &local_prefix_dataname.4; 
		update 
			&local_prefix_dataname.3
			&local_prefix_dataname.0
		; 
		by _varnum_	_varcode_; 

		_varcodeFmtz_					 = cats(put(_varcode_, z&&&local_prefix_mvarname.mdP_classCodeStd_dig..)); 
	run; 
	data &local_prefix_dataname.code_classVar_varX; 
		set &local_prefix_dataname.4; 
	run; 
	********************************************************************************
	l0_tmp_code_classVar_varX
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_stats
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn (keep=_stats_: obs=0); 
	run; 
	data &local_prefix_dataname.1; 
		length 
			_varnum_						 8
			_varname_						 $32
			_vartype_						 8
			_varlength_						 8
			_varlabel_						 $256
		; 
		set sashelp.vcolumn (where=(lowcase(libname) in ('work') & lowcase(memname)=lowcase(cats(symget('local_prefix_dataname'), '0')))) end=last; 

		_varnum_						 = varnum; 
		_varname_						 = cats(name); 
		_vartype_						 = ifc(lowcase(type)='num', 1, 2); 
		_varlength_						 = length; 
		_varlabel_						 = cats(label); 
	run; 
	data &local_prefix_dataname.prop_stats; 
		set &local_prefix_dataname.1 (keep=_var:); 
	run; 
	proc datasets lib=&dsn_libname. memtype=data nolist; 
		modify &local_prefix_dataname.prop_stats; 
		attrib 
			_ALL_							 format= informat= label=''
		; 
	run; quit; 
	********************************************************************************
	l0_tmp_prop_stats
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_prop_tabAttr
	********************************************************************************; 
	data &local_prefix_dataname.0 (keep=_var:); 
		set 
			&local_prefix_dataname.prop_classPerm (where=(_classPerm_seqDec_=1 & ((_varname_ like '%_classPerm_code_%') | (_varname_ like '%_classPerm_value%_%'))))
			&local_prefix_dataname.prop_stats (in=b)
		; 

		_varnum_ = _N_; 
	*	_varname_ = transtrn(_varname_, '_classPerm_', '_varXParm_var'); 
		select; 
			when (^missing(_classPerm_seqBin_))	 do; 
				_varname_ = transtrn(_varname_, '_classPerm_', '_varXParm_'); 
				_varname_ = substrn(_varname_, 1, find(_varname_, cats(_classPerm_seqBin_), 'i')-1); 
			end; 
			when (missing(_classPerm_seqBin_))	 do; 
			end; 
			otherwise; 
		end; 

	*	rename 
			_varnum_						=_attrNum_
			_varname_						=_attrName_
			_vartype_						=_attrType_
			_varlength_						=_attrLength_
			_varlabel_						=_attrLabel_
		; 
	run; 
	proc sort data=&local_prefix_dataname.code_classVar_varX out=&local_prefix_dataname.1 (keep=_varcode_	_varcodeFmtz_) nodupkey; 
		by _varcode_	_varcodeFmtz_; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.2 as 
			select * from 
				&local_prefix_dataname.1
				, &local_prefix_dataname.0
		; 
	quit; 
	data &local_prefix_dataname.3; 
		set &local_prefix_dataname.2; 
		*length 
			_attrNum_						 8
			_attrName_						 $32
			_attrType_						 8
			_attrLength_					 8
			_attrLabel_						 $256
			nameConv_varXStats				 8
			_attrName0_						 $32
			_attrName1_						 $32
		; 
		length 
			nameConv_varXStats				 8
			_varname0_						 $32
			_varname1_						 $32
		; 

		nameConv_varXStats = symget('nameConv_varXStats'); 

	****	need unique _varname_, use proc sort nodupkey; 
		select; 
	*		when (cats(lowcase(_varname_)) in ('_stats_n0_row_', '_stats_nmiss_row_'))		 delete; 
	*		when (cats(lowcase(_varname_)) in ('_stats_n0_page_', '_stats_nmiss_page_'))	 do; 
			when (cats(lowcase(_varname_)) in ('_stats_n0_row_', '_stats_nmiss_row_', '_stats_n0_page_', '_stats_nmiss_page_'))	 do; 
				_varname0_ = cats(_varname_); 
				_varname1_ = cats(_varname_); 
				call missing(_varcode_, _varcodeFmtz_); 
			end; 
			otherwise	 do; 
				_varname0_ = cats(_varname_, 'code', _varcodeFmtz_, '_'); 
				_varname1_ = cats('_', 'code', _varcodeFmtz_, _varname_); 
			end; 
		end; 
		_varname_ = cats(vvaluex(cats('_varname', nameConv_varXStats, '_'))); 
	run; 
	proc sort out=&local_prefix_dataname.4 nodupkey; 
		by _varcode_	_varnum_; 
	run; 
	data &local_prefix_dataname.5; 
		set &local_prefix_dataname.4; 

		_varnum_ = _N_; 
	run; 
	data &local_prefix_dataname.prop_tabAttr; 
		set &local_prefix_dataname.5; 
	run; 
	********************************************************************************
	l0_tmp_prop_tabAttr
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_var_tabAttr
	********************************************************************************; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
			temp_str						 $256
		; 
		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		call execute('data '||cats(local_prefix_dataname)||'1; '); 
		call execute('	length '); 
		call missing(last); 
		do until (last); 
			set &local_prefix_dataname.prop_tabAttr end=last; 
			temp_str = _varname_||cats(choosec(_vartype_, ' ', '$'), _varlength_); 
			call execute('		'||cats(temp_str)); 
		end; 
		call execute('	; '); 
		call execute('run; '); 
		stop; 
	run; 
	data &local_prefix_dataname.var_tabAttr; 
		set &local_prefix_dataname.1 (obs=0); 
	run; 
	********************************************************************************
	l0_tmp_var_tabAttr
	********************************************************************************
	****								Comments								****
	********************************************************************************; 




	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabAttr
	********************************************************************************; 
	data &local_prefix_dataname.0; 
		set &local_prefix_dataname.dsn (
			keep=
				&&&local_prefix_mvarname.mdP_list_varname_by.
				_classComb_:
				_stats_:
				_mdP_:
				_classPerm_:
			); 
	run; 
	proc transpose out=&local_prefix_dataname.1; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			_mdP_:
			_classPerm_:
		; 
		var _stats_:; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.2 as 
			select * from &local_prefix_dataname.prop_stats as a
			inner join &local_prefix_dataname.1 as b
			on lowcase(a._varname_)=lowcase(b._NAME_)
		; 
	quit; 
	data &local_prefix_dataname.3; 
		length 
			_varcode_						 8
			_varcodeFmtz_					 $32
			nameConv_varXStats				 8
			_varname0_						 $32
			_varname1_						 $32
		; 
		set &local_prefix_dataname.2; 

		array	arr_varnum						_classPerm_num_:; 
		array	arr_varname						_classPerm_name_:; 
		array	arr_vartype						_classPerm_type_:; 
		array	arr_varlabel					_classPerm_label_:; 
		array	arr_varfmt						_classPerm_fmt_:; 
		array	arr_varinfmt					_classPerm_infmt_:; 
		array	arr_varcode						_classPerm_code_:; 
		array	arr_varvaluen					_classPerm_valuen_:; 
		array	arr_varvaluec					_classPerm_valuec_:; 
		array	arr_varvalue					_classPerm_value_:; 

		_varcode_						 = arr_varcode[_mdP_classPerm_dimStd_]; 
		_varcodeFmtz_					 = cats(put(_varcode_, z&&&local_prefix_mvarname.mdP_classCodeStd_dig..)); 

		nameConv_varXStats				 = symget('nameConv_varXStats'); 

	****	need unique _varname_, use proc sort nodupkey; 
		select; 
	*		when (cats(lowcase(_varname_)) in ('_n0_row_', '_nmiss_row_', '_n0_page_', '_nmiss_page_'))	 do; 
			when (cats(lowcase(_varname_)) in ('_stats_n0_row_', '_stats_nmiss_row_', '_stats_n0_page_', '_stats_nmiss_page_'))	 do; 
				_varname0_ = cats(_varname_); 
				_varname1_ = cats(_varname_); 
				call missing(_varcode_, _varcodeFmtz_); 
			end; 
			otherwise																					 do; 
				_varname0_ = cats(_varname_, 'code', _varcodeFmtz_, '_'); 
				_varname1_ = cats('_', 'code', _varcodeFmtz_, _varname_); 
			end; 
		end; 
		_varname_ = cats(vvaluex(cats('_varname', nameConv_varXStats, '_'))); 
	run; 
	data &local_prefix_dataname.4 (drop=i); ****	_classComb_varcodeFmtz_ w/o code of _classPerm_code_001; 
		length 
			temp_varname					 $32
			temp_varcode					 8
			temp_varcodeFmtz				 $32
			temp_classComb_varcodeFmtz		 $256
			temp_str						 $32
		; 
		set &local_prefix_dataname.3; 

	*	do i=_classComb_rank_ to 2 by -1; 
	*		temp_str = put(2**(i-1), binary&&&local_prefix_mvarname.mdP_classPerm_dimStd..); 
	*		temp_varname = cats('_classPerm_code_', temp_str, '_'); 

	*		temp_varcode = vvaluex(temp_varname); 
	*		temp_varcodeFmtz = put(temp_varcode, z&&&local_prefix_mvarname.mdP_classCodeStd_dig..); 
	*		temp_classComb_varcodeFmtz = cats(temp_classComb_varcodeFmtz, '_', temp_varcodeFmtz); 
	*	end; 
		temp_classComb_varcodeFmtz = cats(reverse(_classComb_varcodeFmtz_)); 
		temp_classComb_varcodeFmtz = substrn(temp_classComb_varcodeFmtz, find(temp_classComb_varcodeFmtz, '_')+1); 
		temp_classComb_varcodeFmtz = cats(reverse(temp_classComb_varcodeFmtz)); 
		temp_classComb_varcodeFmtz = cats(temp_classComb_varcodeFmtz, '_', repeat('x', _mdP_classCodeStd_dig_-1)); 
		_classComb_varcodeFmtz_ = temp_classComb_varcodeFmtz; 
	run; 
	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
		; 
		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		****	drop _classPerm_code_001_	_classPerm_valuen_001_	_classPerm_valuec_001_	_classPerm_value_001_; 
		call execute('data '||cats(local_prefix_dataname)||'5; '); 
		call execute('	set '||cats(local_prefix_dataname)||'4 ('); 
		call execute('		drop='); 
		call execute('			temp_:'); 
		do until (last); 
			set &local_prefix_dataname.prop_classPerm (where=(_classPerm_seqDec_=1 & (_varname_ like '%_code_%' | _varname_ like '%_value%'))) end=last; 
			call execute('			'||cats(_varname_)); 
		end; 
		call execute('		); '); 
		call execute('run; '); 
		stop; 
	run; 
	proc sort out=&local_prefix_dataname.6 nodupkey; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			_mdP_:
			_classPerm_:
			_varcode_	_varnum_	_varname_
		; 
	run; 
	proc transpose out=&local_prefix_dataname.7 (drop=_NAME_	_LABEL_); 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
			_mdP_:
			_classPerm_:
		; 
		id _varname_; 
	*	idlabel _varlabel_; 
		var COL1; 
	run; 
	data &local_prefix_dataname.tabAttr; 
		set &local_prefix_dataname.7; 
	run; 
	********************************************************************************
	l0_tmp_tabAttr
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_code_varXParm
	********************************************************************************; 
	*proc sql; 
	*	create table &local_prefix_dataname.0 as 
			select * from &local_prefix_dataname.code_classVar as a
			left join &local_prefix_dataname.prop_tabAttr (
				keep=_varcode_	_varname_
				rename=(_varname_=_attrName_)
				where=(_attrName_ like '%_varXParm_code_%' | _attrName_ like '%_varXParm_value%_%')
				) as b
			on a._varcode_=b._varcode_
			order by _varnum_, _varcode_
		; 
	*quit; 
	data &local_prefix_dataname.0; 
		set 
			&local_prefix_dataname.prop_tabAttr (
				keep=_varcode_	_varnum_	_varname_
				rename=(_varnum_=_attrNum_	_varname_=_attrName_)
				where=(_attrName_ like '%_varXParm_code_%' | _attrName_ like '%_varXParm_value%_%')
				); 
		length 
			_NAME_							 $32
		; 

		select; 
			when (find(_attrName_, '_varXParm_code_', 'i'))		 _NAME_ = cats('_varcode_'); 
			when (find(_attrName_, '_varXParm_valuen_', 'i'))	 _NAME_ = cats('_varvaluen_'); 
			when (find(_attrName_, '_varXParm_valuec_', 'i'))	 _NAME_ = cats('_varvaluec_'); 
			when (find(_attrName_, '_varXParm_value_', 'i'))	 _NAME_ = cats('_varvalue_'); 
			otherwise; 
		end; 
	run; 

	proc transpose data=&local_prefix_dataname.code_classVar_varX out=&local_prefix_dataname.1; 
		by _varnum_	_varname_	_vartype_	_varlength_	_varlabel_	_varcode_; 
		var _varcode_	_varvaluen_; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.2 as 
			select * from &local_prefix_dataname.1 as a
			left join &local_prefix_dataname.0 as b
			on a._varcode_=b._varcode_ & lowcase(a._NAME_)=lowcase(b._NAME_)
			order by _varnum_, _varcode_, _attrNum_
		; 
	quit; 
	proc transpose out=&local_prefix_dataname.3 (drop=_NAME_	_LABEL_); 
		by _varnum_	_varname_	_vartype_	_varlength_	_varlabel_; 
		id _attrName_; 
		var COL1; 
	run; 
	data &local_prefix_dataname.code_varXParm; 
		merge 
			&local_prefix_dataname.3
		; 
		by _varnum_	_varname_	_vartype_	_varlength_	_varlabel_; 
	run; 

	proc transpose data=&local_prefix_dataname.code_classVar_varX out=&local_prefix_dataname.1; 
		by _varnum_	_varname_	_vartype_	_varlength_	_varlabel_	_varcode_; 
		var _varvaluec_	_varvalue_; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.2 as 
			select * from &local_prefix_dataname.1 as a
			left join &local_prefix_dataname.0 as b
			on a._varcode_=b._varcode_ & lowcase(a._NAME_)=lowcase(b._NAME_)
			order by _varnum_, _varcode_, _attrNum_
		; 
	quit; 
	proc transpose out=&local_prefix_dataname.3 (drop=_NAME_	_LABEL_); 
		by _varnum_	_varname_	_vartype_	_varlength_	_varlabel_; 
		id _attrName_; 
		var COL1; 
	run; 
	data &local_prefix_dataname.code_varXParm; 
		merge 
			&local_prefix_dataname.code_varXParm
			&local_prefix_dataname.3
		; 
		by _varnum_	_varname_	_vartype_	_varlength_	_varlabel_; 
	run; 

	data _NULL_; *_NULL_	&local_prefix_dataname.999; 
		length 
			local_prefix_dataname			 $32
		; 
		local_prefix_dataname				 = cats(symget(vname(local_prefix_dataname))); 

		****	keep %_varXParm_%; 
		call execute('data '||cats(local_prefix_dataname)||'1; '); 
		call execute('	merge '); 
	*	call execute('		'||cats(local_prefix_dataname)||'prop_classVar'); 
		call execute('		'||cats(local_prefix_dataname)||'var_tabAttr ('); 
		call execute('			keep='); 
		do until (last); 
			set &local_prefix_dataname.prop_tabAttr (keep=_varname_ where=(_varname_ like '%_varXParm_code_%' | _varname_ like '%_varXParm_value%_%')) end=last; 
			call execute('				'||cats(_varname_)); 
		end; 
		call execute('			)'); 
		call execute('	; '); 
		call execute('run; '); 
		stop; 
	run; 
	data &local_prefix_dataname.2; 
		merge 
			&local_prefix_dataname.code_varXParm (drop=_varXParm_:)
			&local_prefix_dataname.1
			&local_prefix_dataname.code_varXParm
		; 
	run; 
	data &local_prefix_dataname.code_varXParm; 
		set &local_prefix_dataname.2; 
	run; 
	********************************************************************************
	l0_tmp_code_varXParm
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	l0_tmp_tabAttr
		add _varXParm_:
			_varXParm_code_code:
			_varXParm_valuen_code:
			_varXParm_valuec_code:
			_varXParm_value_code:
	********************************************************************************; 
	data &local_prefix_dataname.1; 
		length 
			_fk_varnum_						 8
		; 
		set &local_prefix_dataname.tabAttr; 

		array	arr_varnum						_classPerm_num_:; 
		_fk_varnum_						 = arr_varnum[_mdP_classPerm_dimStd_]; 
	run; 
	proc sql; 
		create table &local_prefix_dataname.2 as 
			select * from &local_prefix_dataname.1 as a
			left join &local_prefix_dataname.code_varXParm (keep=_varnum_	_varXParm_: rename=(_varnum_=_fk_varnum_)) as b
			on a._fk_varnum_=b._fk_varnum_
		; 
	quit; 
	proc sort out=&local_prefix_dataname.3 (drop=_fk_:); 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
	data &local_prefix_dataname.4; 
		merge 
			&local_prefix_dataname.3 (
				keep=
					&&&local_prefix_mvarname.mdP_list_varname_by.
					_classComb_:
					_mdP_:
					_classPerm_:
				)
			&local_prefix_dataname.var_tabAttr
			&local_prefix_dataname.3
		; 
	run; 
	data &local_prefix_dataname.tabAttr; 
		set &local_prefix_dataname.4; 
	run; 
	********************************************************************************
	l0_tmp_tabAttr
		add _varXParm_:
			_varXParm_code_code:
			_varXParm_valuen_code:
			_varXParm_valuec_code:
			_varXParm_value_code:
	********************************************************************************
	****								Comments								****
	********************************************************************************; 


	data &prefix_output.&output.&suffix_output. (compress=binary); 
		set &local_prefix_dataname.tabAttr; 

	*	drop 
			_classPerm_fmt_:	_classPerm_infmt_:
		; 
	run; 
	proc sort; 
		by 
			&&&local_prefix_mvarname.mdP_list_varname_by.
			_classComb_:
		; 
	run; 
/*
	proc contents data=&prefix_output.&output.&suffix_output. varnum; run; 
*/
	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend convert_freq_to_tab; 


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



