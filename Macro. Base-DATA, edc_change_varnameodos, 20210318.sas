****************************************************************************
**PROJECT: 
**PROGRAM NAME: Macro. edc_change_varnameodos.sas
**PURPOSE: transpose from subject-based to eye-based
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
%edc_change_varnameodos(dsn=medicalfindings
	, list_suffix_1="RUN1, RUN2"
	, list_rename_1="
UNCONJHYPERINJOS=CONJHYPERINJOS
, HPYHOD=HYPHOD
, PIPOS=PUPOS
	"); 
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


%macro edc_change_varnameodos(dsn=, id_subj=id_subj, output=, list_varname_by=id_subj	id_eye	id_visitsubj
	, prefix_output=m_edc_, suffix_output=
	, local_prefix_dataname=l_temp_, local_prefix_mvarname=l_temp_
/*	, list_suffix_0="'', '_STD', '_HLGT', '_HLGT_CODE', '_HLT', '_HLT_CODE', '_LLT', '_LLT_CODE', '_PT', '_PT_CODE', '_SOC', '_SOC_CODE'"*/
	, list_suffix_0=", _STD, _HLGT, _HLGT_CODE, _HLT, _HLT_CODE, _LLT, _LLT_CODE, _PT, _PT_CODE, _SOC, _SOC_CODE"
	, list_suffix_1=""
	, list_rename_1=""
	); 
/*
data _NULL_; 
	call symputx('dsn', 'raw_jjsv_mef_100_od'); 
	call symputx('id_subj', 'id_subj'); 
	call symputx('output', ''); 
	call symputx('list_varname_by', 'id_subj	id_eye	FolderSeq	InstanceRepeatNumber'); 
	call symputx('prefix_output', 'm_edc_'); 
	call symputx('suffix_output', ''); 
	call symputx('local_prefix_dataname', 'l_temp_'); 
	call symputx('local_prefix_mvarname', 'm_'); 
*	call symputx('list_suffix_0', quote("'', '_STD', '_HLGT', '_HLGT_CODE', '_HLT', '_HLT_CODE', '_LLT', '_LLT_CODE', '_PT', '_PT_CODE', '_SOC', '_SOC_CODE'")); 
	call symputx('list_suffix_0', quote(", _STD, _HLGT, _HLGT_CODE, _HLT, _HLT_CODE, _LLT, _LLT_CODE, _PT, _PT_CODE, _SOC, _SOC_CODE")); 
	call symputx('list_suffix_1', quote("")); 
	call symputx('list_rename_1', quote("
UNCONJHYPERINJOS=CONJHYPERINJOS, 
HPYHOD=HYPHOD, 
PIPOS=PUPOS
		")); 
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
		call symputx('output', output, 'l'); 
	run; 
	data &local_prefix_dataname.dsn; 
		set &dsn_libname..&dsn.; 
	run; 


	data &local_prefix_dataname.dsn; 
		set &local_prefix_dataname.dsn; 
********************************************************************************
********************************************************************************
****								Comments								****
********************************************************************************
hardcode change varname
********************************************************************************; 
*		&&&local_prefix_mvarname.list_rename_1; 
********************************************************************************
hardcode change varname
********************************************************************************
****								Comments								****
********************************************************************************
********************************************************************************; 
	run; 


	data _NULL_; *_NULL_; 
		length list_suffix$32767; 
		list_suffix = catx(', ', dequote(symget('list_suffix_0')), dequote(symget('list_suffix_1'))); 
		count_suffix = count(list_suffix, ',')+1; 
		call symputx(cats(symget('local_prefix_mvarname'), 'list_suffix'), list_suffix, 'l'); 
		call symputx(cats(symget('local_prefix_mvarname'), 'count_suffix'), count_suffix, 'l'); 
	run; 
*	data &local_prefix_dataname.list_suffix (drop=i); *_NULL_; *1 obs, split list_suffix, including missing; 
*		array varname_suffix_[&&&local_prefix_mvarname.count_suffix.]$32; 
*		do i=1 to symget(cats(symget('local_prefix_mvarname'), 'count_suffix')); 
*			varname_suffix_[i] = scan(symget(cats(symget('local_prefix_mvarname'), 'list_suffix')), i, ',', 'mqr'); 
*		end; 
*	run; 
	data &local_prefix_dataname.list_suffix (drop=i); *_NULL_; *1 obs, split list_suffix, including missing; 
		length list_suffix$32767; 
		list_suffix = symget(cats(symget('local_prefix_mvarname'), 'list_suffix')); 
		count_suffix = symget(cats(symget('local_prefix_mvarname'), 'count_suffix')); 
		array varname_suffix_[&&&local_prefix_mvarname.count_suffix.]$32; 
		do i=1 to count_suffix; 
			varname_suffix_[i] = scan(list_suffix, i, ',', 'mqr'); 
		end; 
	run; 
/*	proc print label; run; */


	proc contents data=&local_prefix_dataname.dsn out=&local_prefix_dataname.contents varnum noprint; 
	run; 
	proc sort; by VARNUM; run; 


	proc sql; 
		create table &local_prefix_dataname.1 as 
		select * from &local_prefix_dataname.contents, &local_prefix_dataname.list_suffix; 
	quit; 
	data &local_prefix_dataname.2; 
		length 
			varname$32 varlabel$256 varname_eye 8 varname_eye_c$2 varname_suffix$32
			temp_varname$32 temp_varlabel$256 temp_varname_suffix$32
			code_varname_od	code_varname_os	code_label	code_drop $32767	
			temp_code_varname	temp_code_label $32767	
		; 
		retain code_:; 
		set &local_prefix_dataname.1 end=last; 
		array arr_suffix varname_suffix_:; 
		array code_varname [*] code_varname_od	code_varname_os; 
		do i=1 to dim(arr_suffix); 
		end; 
		do temp_eye=1 to 2 until (^missing(varname_suffix)); 
			temp_eye_c = choosec(temp_eye, 'OD', 'OS'); 
			do i=1 to dim(arr_suffix) until (^missing(varname_suffix)); 
				temp_varname_suffix = cats(temp_eye_c, arr_suffix[i]); 
				if temp_varname_suffix=substrn(NAME, length(NAME)-length(temp_varname_suffix)+1, length(temp_varname_suffix)) then do; 
					varname_eye = temp_eye; 
					varname_eye_c = temp_eye_c; 
					varname_suffix = arr_suffix[i]; 
				end; 
			end; 
			if ^missing(varname_eye) then do; 
				temp_varname = substrn(NAME, 1, length(NAME)-length(cats(varname_eye_c, varname_suffix))); 
				varname = lowcase(cats(temp_varname, varname_suffix)); 
				varlabel = LABEL; 
				do until(temp_startpos=0); 
					temp_startpos = find(varlabel, cats(varname_eye_c)); 
					if temp_startpos then varlabel = catx(' ', 
						substrn(varlabel, 1, temp_startpos-1), 
						substrn(varlabel, temp_startpos+length(varname_eye_c)*(temp_startpos>0))
						); 
				end; 
				temp_code_varname = cats(varname, '=', NAME); 
				if ^missing(varlabel) then temp_code_label = cats(varname, '=', quote(cats(varlabel))); 
				code_varname[temp_eye] = catx('; ', code_varname[temp_eye], choosec((varname_eye=temp_eye)+1, '', temp_code_varname)); 
			end; 
		end; 
		if ^missing(varname_eye) then do; 
			code_label = catx(' ', code_label, temp_code_label); 
			code_drop = catx(' ', code_drop, NAME); 
		end; 
		if last then do; 
			call symputx(cats("&local_prefix_mvarname.", vname(code_varname_od)), code_varname_od, 'l'); 
			call symputx(cats("&local_prefix_mvarname.", vname(code_varname_os)), code_varname_os, 'l'); 
			call symputx(cats("&local_prefix_mvarname.", vname(code_label)), code_label, 'l'); 
			call symputx(cats("&local_prefix_mvarname.", vname(code_drop)), code_drop, 'l'); 
		end; 
	run; 


	data &local_prefix_dataname.dsn; 
		length id_eye 8 id_eye_c$2; 
		set &local_prefix_dataname.dsn; 
		select; 
			when (^missing(symget("&local_prefix_mvarname.code_drop"))) do; 
				if ^missing(symget(cats(symget('local_prefix_mvarname'), 'code_varname_od'))) then do; 
					id_eye = 1; id_eye_c = 'OD'; 
					&&&local_prefix_mvarname.code_varname_od.; 
					output; 
				end; 
				if ^missing(symget(cats(symget('local_prefix_mvarname'), 'code_varname_os'))) then do; 
					id_eye = 2; id_eye_c = 'OS'; 
					&&&local_prefix_mvarname.code_varname_os.; 
					output; 
				end; 
				drop &&&local_prefix_mvarname.code_drop.; 
				label &&&local_prefix_mvarname.code_label.; 
			end; 
			otherwise do; 
				output; 
			end; 
		end; 
	run; 
	proc sort; by &list_varname_by.; run; 


	data &prefix_output.&output.&suffix_output.; 
		retain &id_subj.; 
		set &local_prefix_dataname.dsn; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend edc_change_varnameodos; 


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



