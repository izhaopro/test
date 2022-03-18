****************************************************************************
**PROJECT: 
**PROGRAM NAME: Macro. edc_change_label.sas
**PURPOSE: delete redundant info from label
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
%edc_change_label(dsn=opdata, list_str_1="'</,''I>'"); 
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


%macro edc_change_label(dsn=, output=, prefix_output=
	, local_prefix_dataname=l_temp_, local_prefix_mvarname=l_temp_, modifiers=i
	, list_str_0="
		'<B/>', '</B>', '<B>'
		, '<BR>', '<BR/>', '</BR>'
		, '</FONT>'
		, '<I/>', '</I>', '</', 'I>'
		, '</U>', '<U>'
		, ': (display value)', '(display value)'
		, 'Coded Value'
		, ': (describe)', '(describe)'
		"
	, list_str_1=""
	); 
/*
data _NULL_; 
	call symputx('dsn', 'opdata'); 
	call symputx('output', ''); 
	call symputx('prefix_output', 'm_edc_'); 
	call symputx('local_prefix_dataname', 'l_temp_'); 
	call symputx('local_prefix_mvarname', ''); 
	call symputx('modifiers', 'i'); 
	call symputx('list_str_0', "'<B/>', '</B>', '<I/>', '</I>'"); 
	call symputx('list_str_1', "'</,''I>'"); 
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


	proc contents data=&local_prefix_dataname.dsn out=&local_prefix_dataname.contents varnum noprint; 
	run; 
	proc sort; by VARNUM; run; 


	data _NULL_; 
		length word	temp_code	code_list_str_1 $ 10000	string $ 1000; 
		retain code_:; 
	*	string = catx(', ', dequote(symget('list_str_0')), dequote(symget('list_str_1'))); *remove list_str_0 first; 
		string = catx(', ', dequote(symget('list_str_1')), dequote(symget('list_str_0'))); *remove list_str_1 first; 
		do until (missing(word)); 
			count + 1; 
			word = scan(string, count, ',', 'qr'); 
			if ^missing(word) then do; 
				temp_code = cats('temp_char', count, '=', quote(cats(word)), '; '); 
				code_list_str_1 = catx(' ', code_list_str_1, temp_code); 
				call symputx(cats(symget('local_prefix_mvarname'), vname(code_list_str_1)), code_list_str_1, 'l'); 
				call symputx(cats(symget('local_prefix_mvarname'), 'n_temp_char'), count, 'l'); 
				output; 
			end; 
		end; 
	run; 


	data _NULL_; *_NULL_; 
		length 
			varlabel $ 256	temp_varlabel $ 1000	code_varlabel $ 10000	
			temp_char1-temp_char&&&local_prefix_mvarname.n_temp_char. $ 1000
		; 
		retain code:; 
		set &local_prefix_dataname.contents; 
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
****																		****
****								Comments								****
****																		****
********************************************************************************
set temp_chars
********************************************************************************; 
		&&&local_prefix_mvarname.code_list_str_1; 
********************************************************************************
set temp_chars
********************************************************************************
****																		****
****								Comments								****
****																		****
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************; 
		varlabel = LABEL; 
		array temp_char[*] temp_char1-temp_char&&&local_prefix_mvarname.n_temp_char.; 
		array temp_pos[*] temp_pos1-temp_pos&&&local_prefix_mvarname.n_temp_char.; 
	*	do until(temp_startpos=0); 
	*		do i=1 to dim(temp_char); 
	*			temp_pos[i] = find(varlabel, cats(temp_char[i]), "&modifiers."); 
	*		end; 
	*		temp_startpos = max(0, of temp_pos1-temp_pos&&&local_prefix_mvarname.n_temp_char.); 
	*		if temp_startpos then do i=1 to dim(temp_char); 
	*			if temp_startpos=temp_pos[i] then do; 
	*				varlabel = catx(' ', 
	*					substrn(varlabel, 1, temp_startpos-1), 
	*					substrn(varlabel, temp_startpos+length(temp_char[i])*(temp_startpos>0))
	*					); 
	*			end; 
	*		end; 
	*	end; 
		do i=1 to dim(temp_char); 
			do until(temp_startpos=0); 
				temp_startpos = find(varlabel, cats(temp_char[i]), "&modifiers."); 
				if temp_startpos then varlabel = catx(' ', 
					substrn(varlabel, 1, temp_startpos-1), 
					substrn(varlabel, temp_startpos+length(temp_char[i])*(temp_startpos>0))
					); 
			end; 
		end; 
		if ^missing(varlabel) then temp_varlabel = cats(NAME, '=', quote(cats(varlabel))); 
		code_varlabel = catx(' ', code_varlabel, temp_varlabel); 
		call symputx(cats("&local_prefix_mvarname.", vname(code_varlabel)), code_varlabel, 'l'); 
	run; 


	data &local_prefix_dataname.dsn; 
		set &local_prefix_dataname.dsn; 
		label &&&local_prefix_mvarname.code_varlabel.; 
	run; 


	data &prefix_output.&output.; 
		set &local_prefix_dataname.dsn; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend edc_change_label; 


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



