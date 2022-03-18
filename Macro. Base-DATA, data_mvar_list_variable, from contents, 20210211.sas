****************************************************************************
**PROJECT: 
**PROGRAM NAME: 
**PURPOSE: 
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
%data_mvar_list_variable(dsn=temp_dsn, output=list_var, mvarname=list_varname, symboltable=f, prefix_output=temp_, suffix_output=_test); 




data temp_dsn; 
	set subj_prvsq (keep=prvsq_: obs=0); 
	keep _NUMERIC_; 
run; 
data temp_dsn; 
	retain 
		eye	ord_eye_sx	nom_model	nom_model_paired
		eye_sx_subj	eye_1st	eye_2nd	nom_model_1st	nom_model_2nd
		visit_eye	visit_subj
	; 
	merge attr_: (obs=0)	visit_: (obs=0); 
	keep 
		eye	ord_eye_sx	nom_model	nom_model_paired
		eye_sx_subj	eye_1st	eye_2nd	nom_model_1st	nom_model_2nd
		visit_eye	visit_subj
	; 
run; 

data _NULL_; *_NULL_; 
	mvarname = 'list_varname'; prefix_mvarname = ' '; suffix_mvarname = '_test'; 
	call symputx(cats(prefix_mvarname, mvarname, suffix_mvarname), ' ', 'l'); 
run; 
%data_mvar_list_variable(dsn=temp_dsn, symboltable=f, prefix_output=, suffix_output=_test); 
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


%macro data_mvar_list_variable(dsn=, output=prop_var, mvarname=list_varname, symboltable=f
	, prefix_output=, suffix_output=, prefix_mvarname=, suffix_mvarname=
	, local_prefix_dataname=l_temp_, local_prefix_mvarname=l_temp_
	); 
/*
data _NULL_; 
	call symputx('dsn', 						'temp_dsn', 'l'); 
	call symputx('output', 						'list_var', 'l'); 
	call symputx('mvarname', 					'list_varname', 'l'); 
	call symputx('symboltable', 				'f', 'l'); 

	call symputx('prefix_output', 				'', 'l'); 
	call symputx('suffix_output', 				'', 'l'); 
	call symputx('prefix_mvarname', 			'', 'l'); 
	call symputx('suffix_mvarname', 			'', 'l'); 
	call symputx('local_prefix_dataname', 		'l_temp_', 'l'); 
	call symputx('local_prefix_mvarname', 		'l_temp_', 'l'); 

	call symputx('modifiers', 					'i', 'l'); 
	call symputx('prefix_mvarname', 			'', 'l'); 
	call symputx('suffix_mvarname', 			'', 'l'); 

	call symputx('list_varname', 				quote(symget('list_varname')), 'l'); 
run; 

%put _USER_; 
*/
	data _NULL_; *_NULL_; 
		dsn_libname = ifc(find(symget('dsn'), '.')=0, 'work', substrn(symget('dsn'), 1, find(symget('dsn'), '.')-1)); 
		dsn = substrn(symget('dsn'), find(symget('dsn'), '.')+1, length(symget('dsn'))-find(symget('dsn'), '.')); 
		call symputx('dsn_libname', dsn_libname, 'l'); 
		call symputx('dsn', dsn, 'l'); 
	run; 
	data _NULL_; *_NULL_; 
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


	proc contents data=&local_prefix_dataname.dsn out=&local_prefix_dataname.1 varnum noprint; 
	run; 
	proc sort out=&local_prefix_dataname.2; 
		by VARNUM; 
	run; 
	data &local_prefix_dataname.3 (keep=varnum	varname	vartype	varlength	varlabel); 
		length varnum 8	varname$32	vartype 8	varlength 8	varlabel$256; 
		set &local_prefix_dataname.2; 
		varname = cats(NAME); 
		vartype = TYPE; 
		varlength = LENGTH; 
		varlabel = cats(LABEL); 
	run; 

	data &prefix_output.&output.&suffix_output.; 
		set &local_prefix_dataname.3; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		modify &prefix_output.&output.&suffix_output.; 
		attrib _ALL_ format= informat= label=' '; 
	run; quit; 

	data _NULL_; *_NULL_; 
		length list_varname$32767; 
		retain list_varname; 
		set &prefix_output.&output.&suffix_output. (keep=varname) end=last; 
		list_varname = catx('	', list_varname, varname); 
		if last then call symputx(cats(symget('prefix_mvarname'), symget('mvarname'), symget('suffix_mvarname')), list_varname, symget('symboltable')); 
	run; 
/*	%put _USER_; */
/*	%put _GLOBAL_; */
	%put _LOCAL_; 

	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend data_mvar_list_variable; 


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



