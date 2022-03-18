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
css=css	cv=cv	kurt=kurt	lclm=lclm	max=max	mean=mean	min=min	mode=mode	n=n
nmiss=nmiss	range=range	skew=skew	std=std	stderr=stderr	sum=sum	sumwgt=sumwgt	uclm=uclm	uss=uss	var=var
p1=p1	p5=p5	p10=p10	p20=p20	q1=q1	p30=p30	p40=p40	median=median
p60=p60	p70=p70	q3=q3	p80=p80	p90=p90	p95=p95	p99=p99	qrange=qrange
probt=probt	t=t
*/
/*
data sashelp_cars; 
	set sashelp.cars; 
run; 
data temp_dsn; 
	set sashelp_cars; 
	format _ALL_; 
	informat _ALL_; 
run; 
proc sort; 
	by Type; 
run; 

%means_stats(dsn=temp_dsn, output=means, opt_means_missing=missing
	, prefix_output=temp_, suffix_output=, prefix_mvarname=, suffix_mvarname=
	, list_varname_by=Type
	, list_varname_class=Origin	DriveTrain
	, list_varname=MSRP	Invoice	EngineSize	Horsepower	MPG_City	MPG_Highway	Weight	Wheelbase	Length
	, list_stats="n mean std median min max lclm uclm"
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


%macro means_stats(dsn=, dsn_1=, output=, mvarname=
	, opt_means_missing=missing
	, opt_class=
	, symboltable=f, modifiers=i
	, prefix_output=temp_, suffix_output=, prefix_mvarname=, suffix_mvarname=
	, local_prefix_dataname=l0_tmp_, local_prefix_mvarname=l0_tmp_
	, list_varname_by=
	, list_varname_class=
	, list_varname=
	, list_stats=" "
	); 
/*
data _NULL_; 
	call symputx('dsn', 						'temp_dsn', 'l'); ****	temp_dsn; 
	call symputx('dsn_1', 						'', 'l'); ****	temp_lvl; 
	call symputx('output', 						'means', 'l'); 
	call symputx('mvarname', 					'', 'l'); 

	call symputx('opt_means_missing', 			'missing', 'l'); ****	missing; 
	call symputx('opt_class', 					'', 'l'); ****	missing; 
	call symputx('symboltable', 				'f', 'l'); 
	call symputx('modifiers', 					'i', 'l'); 

	call symputx('prefix_output', 				'temp_', 'l'); 
	call symputx('suffix_output', 				'', 'l'); 
	call symputx('prefix_mvarname', 			'', 'l'); 
	call symputx('suffix_mvarname', 			'', 'l'); 

	call symputx('local_prefix_dataname', 		'l0_tmp_', 'l'); 
	call symputx('local_prefix_mvarname', 		'l0_tmp_', 'l'); 

*	call symputx('list_varname_by', 			'Make', 'l'); 
	call symputx('list_varname_by', 			'', 'l'); 
	call symputx('list_varname_by', 			'Type', 'l'); 
*	call symputx('list_varname_class', 			'Type	Origin	DriveTrain', 'l'); 
	call symputx('list_varname_class', 			'Origin	DriveTrain', 'l'); 
*	call symputx('list_varname_class', 			'', 'l'); 
	call symputx('list_varname', 				'MSRP	Invoice	EngineSize	Horsepower	MPG_City	MPG_Highway	Weight	Wheelbase	Length', 'l'); 

*	call symputx('list_stats', 					'n mean std median min max lclm uclm', 'l'); 
*	call symputx('list_stats', 					'n mean std p50=median min max lclm uclm', 'l'); 
	call symputx('list_stats', 					quote('n mean= std p50=median min max lclm uclm'), 'l'); 
*	call symputx('list_stats', 					quote(' '), 'l'); 
run; 
%put _USER_; 
*/
	data _NULL_; *_NULL_	&local_prefix_dataname.1; 
		length 
			dsn_libname						 $32
			dsn								 $32
			dsn_1_libname					 $32
			dsn_1							 $32
			output							 $32
			mvarname						 $32
			prefix_mvarname					 $32
			suffix_mvarname					 $32
		; 

		dsn_libname						 = ifc(find(symget('dsn'), '.')=0, 'work', substrn(symget('dsn'), 1, find(symget('dsn'), '.')-1)); 
		dsn								 = substrn(symget('dsn'), find(symget('dsn'), '.')+1, length(symget('dsn'))-find(symget('dsn'), '.')); 
	*	dsn_1							 = cats(symget(vname(dsn_1))); 
		dsn_1_libname					 = ifc(find(symget('dsn_1'), '.')=0, 'work', substrn(symget('dsn_1'), 1, find(symget('dsn_1'), '.')-1)); 
		dsn_1							 = substrn(symget('dsn_1'), find(symget('dsn_1'), '.')+1, length(symget('dsn_1'))-find(symget('dsn_1'), '.')); 
		output							 = ifc(missing(symget('output')), cats(symget('dsn'), '_freq'), symget('output')); 
		mvarname						 = ifc(missing(symget('mvarname')), output, symget('mvarname')); 
		prefix_mvarname					 = ifc(missing(symget('prefix_mvarname')), symget('prefix_output'), symget('prefix_mvarname')); 
		suffix_mvarname					 = ifc(missing(symget('suffix_mvarname')), symget('suffix_output'), symget('suffix_mvarname')); 

		call symputx('dsn_libname', dsn_libname, 'l'); 
		call symputx('dsn', dsn, 'l'); 
		call symputx('dsn_1_libname', dsn_1_libname, 'l'); 
		call symputx('dsn_1', dsn_1, 'l'); 
		call symputx('output', output, 'l'); 
		call symputx('mvarname', mvarname, 'l'); 
		call symputx('prefix_mvarname', prefix_mvarname, 'l'); 
		call symputx('suffix_mvarname', suffix_mvarname, 'l'); 
	run; 
	data &local_prefix_dataname.dsn; 
		set &dsn_libname..&dsn.; 
	run; 
	*data &local_prefix_dataname.dsn_1; 
	*	set &dsn_1_libname..&dsn_1.; 
	*run; 

	data _NULL_; *_NULL_	&local_prefix_dataname.1; 
		array arr_char_quote$32767 
			list_varname_by
			list_varname_class
			list_varname
			list_stats
		; 
		do over arr_char_quote; 
			arr_char_quote = cats(dequote(symget(vname(arr_char_quote)))); 
			call symputx(cats(symget('local_prefix_mvarname'), vname(arr_char_quote)), arr_char_quote, 'l'); 
		end; 
	run; 
	data _NULL_; return = dosubl('%put _USER_; '); run; 




	data _NULL_; *_NULL_	&local_prefix_dataname.1; 
		length 
			local_prefix_dataname			 $32767
			local_prefix_mvarname			 $32767

			list_varname_by					 $32767
		; 

		array arr_char_kp 
			local_prefix_dataname
			local_prefix_mvarname
		; 
		do over arr_char_kp; 
			arr_char_kp = cats(symget(vname(arr_char_kp))); 
		end; 

		array arr_char_local 
			list_varname_by
		; 
		do over arr_char_local; 
			arr_char_local = cats(symget(cats(symget('local_prefix_mvarname'), vname(arr_char_local)))); 
		end; 

		if ^missing(list_varname_by) then do; 
			call execute('proc sort data='||cats(local_prefix_dataname)||'dsn; '); *proc sort data=l0_tmp_dsn;; 
			call execute('	by '||cats(list_varname_by)||'; '); *	by list_varname_by; 
			call execute('run; '); *run; 
		end; 
	run; 




	data &local_prefix_dataname.list_var; retain &list_varname.; 
		set &local_prefix_dataname.dsn (keep=&list_varname. obs=0); 
	run; 
	proc contents out=&local_prefix_dataname.list_var varnum noprint; run; 
	proc sort out=&local_prefix_dataname.list_var; by VARNUM; run; 
	data &local_prefix_dataname.list_var (keep=varnum	varname	vartype	varlength	varlabel); 
		length varnum 8	varname$32	vartype 8	varlength 8	varlabel$256; 
		set &local_prefix_dataname.list_var; 
		varname = cats(NAME); vartype = TYPE; varlength = LENGTH; varlabel = cats(LABEL); 
	run; 

	data &local_prefix_dataname.list_var_class; retain &list_varname_class.; 
		set &local_prefix_dataname.dsn (keep=&list_varname_class. obs=0); 
	run; 
	proc contents out=&local_prefix_dataname.list_var_class varnum noprint; run; 
	proc sort out=&local_prefix_dataname.list_var_class; by VARNUM; run; 
	data &local_prefix_dataname.list_var_class (keep=varnum	varname	vartype	varlength	varlabel); 
		length varnum 8	varname$32	vartype 8	varlength 8	varlabel$256; 
		set &local_prefix_dataname.list_var_class; 
		varname = cats(NAME); vartype = TYPE; varlength = LENGTH; varlabel = cats(LABEL); 
	run; 
	data _NULL_; *_NULL_; 
		set &local_prefix_dataname.list_var_class end=last; 
		if last then call symputx(cats(symget('local_prefix_mvarname'), 'dim_var_class'), varnum, 'l'); 
	run; 

	data _NULL_; *_NULL_; 
		length list_varname$32767; 
		retain list_varname; 
		set &local_prefix_dataname.list_var (keep=varname) end=last; 
	*	list_varname = catx('	', list_varname, varname); 
		list_varname = catx(' ', list_varname, varname); 
		if last then call symputx(cats(symget('local_prefix_mvarname'), 'list_varname'), list_varname, 'l'); 
	run; 
	%put _USER_; 
	data _NULL_; *_NULL_; 
		length stmt_means_by $32767; 

		length list_varname_by$32767; 
		list_varname_by = cats(symget(cats(symget('local_prefix_mvarname'), vname(list_varname_by)))); 
		stmt_means_by = ifc(missing(list_varname_by), stmt_means_by, 'by '||cats(list_varname_by)); 

		call symputx(cats(symget('local_prefix_mvarname'), 'stmt_means_by'), stmt_means_by, 'l'); 
	run; 
	%put _USER_; 
	/*
	css=css	cv=cv	kurt=kurt	lclm=lclm	max=max	mean=mean	min=min	mode=mode	n=n
	nmiss=nmiss	range=range	skew=skew	std=std	stderr=stderr	sum=sum	sumwgt=sumwgt	uclm=uclm	uss=uss	var=var
	p1=p1	p5=p5	p10=p10	p20=p20	q1=q1	p30=p30	p40=p40	median=median
	p60=p60	p70=p70	q3=q3	p80=p80	p90=p90	p95=p95	p99=p99	qrange=qrange
	probt=probt	t=t
	*/
	data _NULL_; *_NULL_; 
		length output_stats_spec$32767	list_stats$32767; 
		length stats_spec$256	stats_kw$32	stats_varname$32; 
		list_stats = cats(dequote(symget(cats(symget('local_prefix_mvarname'), 'list_stats')))); 

		list_stats = ifc(^missing(list_stats), list_stats, '
			css=css, cv=cv, kurt=kurt, lclm=lclm, max=max, mean=mean, min=min, mode=mode, n=n
			, nmiss=nmiss, range=range, skew=skew, std=std, stderr=stderr, sum=sum, sumwgt=sumwgt, uclm=uclm, uss=uss, var=var
			, p1=p1, p5=p5, p10=p10, p20=p20, q1=q1, p30=p30, p40=p40, median=median
			, p60=p60, p70=p70, q3=q3, p80=p80, p90=p90, p95=p95, p99=p99, qrange=qrange
			, probt=probt, t=t
			'); ****	!!!!delimiter: use Space+Comma not Tab w/in macro!!!!; 
		list_stats = cats(list_stats); 
		do _N_=1 to countw(list_stats); 
			stats_spec = scan(list_stats, _N_, '	 ,', 'rs'); *delimiter: tab+space+comma; 
	*		stats_spec = scan(list_stats, _N_); 
			stats_kw = scan(stats_spec, 1, '='); 
			stats_varname = scan(stats_spec, 2, '='); 
			stats_varname = ifc(missing(stats_varname), stats_kw, stats_varname); 
			output_stats_spec = catx('	', output_stats_spec, cats(stats_kw, '=', stats_varname)); 
			output; 
		end; 

	/*	select; */
	/*		when (missing(list_stats)) do; */
	/*			output_stats_spec = '*/
	/*				css=css	cv=cv	kurt=kurt	lclm=lclm	max=max	mean=mean	min=min	mode=mode	n=n*/
	/*				nmiss=nmiss	range=range	skew=skew	std=std	stderr=stderr	sum=sum	sumwgt=sumwgt	uclm=uclm	uss=uss	var=var*/
	/*				p1=p1	p5=p5	p10=p10	p20=p20	q1=q1	p30=p30	p40=p40	median=median*/
	/*				p60=p60	p70=p70	q3=q3	p80=p80	p90=p90	p95=p95	p99=p99	qrange=qrange*/
	/*				probt=probt	t=t*/
	/*				'; */
	/*			output; */
	/*		end; */
	/*		otherwise do _N_=1 to countw(list_stats); */
	/*			stats_spec = scan(list_stats, _N_, '	 ,', 'rs'); *delimiter: tab+space+comma; */
	/*			stats_kw = scan(stats_spec, 1, '='); */
	/*			stats_varname = scan(stats_spec, 2, '='); */
	/*			stats_varname = ifc(missing(stats_varname), stats_kw, stats_varname); */
	/*			output_stats_spec = catx('	', output_stats_spec, cats(stats_kw, '=', stats_varname)); */
	/*			output; */
	/*		end; */
	/*	end; */
		call symputx(cats(symget('local_prefix_mvarname'), 'output_stats_spec'), output_stats_spec, 'l'); 
	run; 
	%put _USER_; 




	data &local_prefix_dataname.comb_bin_var_class (drop=i); ****	combinations w/ repetition; 
		length comb_type 8; 
	*	array element[2] _temporary_ (0 1); 
		array element[2] _temporary_ (. 1); 
		array bin_var_class_[&&&local_prefix_mvarname.dim_var_class.]; 

	********************************************************************************
	****								Comments								****
	********************************************************************************
	!!!!	if no CLASS variable
	********************************************************************************; 
		if ^(countw(symget('list_varname_class'))=0); 
		if countw(symget('list_varname_class'))=0 then do; 
			drop bin_var_class_:; 
		end; 
	********************************************************************************
	!!!!	if no CLASS variable
	********************************************************************************
	****								Comments								****
	********************************************************************************; 

		do _N_=0 to dim(element)**dim(bin_var_class_)-1; 
			do i=1 to dim(bin_var_class_); 
	*			bin_var_class_[i] = element[1+mod(int(_N_/(dim(element)**(i-1))), dim(element))]; 
				bin_var_class_[dim(bin_var_class_)-i+1] = element[1+mod(int(_N_/(dim(element)**(i-1))), dim(element))]; 
			end; 
			comb_type = _N_; 
			output; 
		end; 
	run; 


	/*
	css=css	cv=cv	kurt=kurt	lclm=lclm	max=max	mean=mean	min=min	mode=mode	n=n
	nmiss=nmiss	range=range	skew=skew	std=std	stderr=stderr	sum=sum	sumwgt=sumwgt	uclm=uclm	uss=uss	var=var
	p1=p1	p5=p5	p10=p10	p20=p20	q1=q1	p30=p30	p40=p40	median=median
	p60=p60	p70=p70	q3=q3	p80=p80	p90=p90	p95=p95	p99=p99	qrange=qrange
	probt=probt	t=t
	*/
	data _NULL_; *_NULL_; 
		length code$32767; 
		set &local_prefix_dataname.list_var; 

		length dsn$32	opt_means_missing$32	stmt_means_by$32767	list_varname_class$32767	output$32	output_stats_spec$32767; 
		dsn = cats(symget('local_prefix_dataname'), 'dsn'); 
		opt_means_missing = cats(symget('opt_means_missing')); 
		stmt_means_by = symget(cats(symget('local_prefix_mvarname'), 'stmt_means_by')); 
		list_varname_class = symget(cats(symget('local_prefix_mvarname'), 'list_varname_class')); 
		output = cats(symget('local_prefix_dataname'), 'means', '_', varnum); 
		output_stats_spec = symget(cats(symget('local_prefix_mvarname'), 'output_stats_spec')); 

		code = 
			'proc means data='||cats(dsn)||' '||cats(opt_means_missing)||' noprint; '
				||cats(stmt_means_by)||'; '
				||'class '||cats(list_varname_class)||'; '
				||'var '||cats(varname)||'; '
				||'output out='||cats(output)||' '||cats(output_stats_spec)||' / '||'noinherit'||'; '
			||'run; '
		; 
		call execute(code); 
	run; 
	data _NULL_; *_NULL_; 
		output = cats(symget('local_prefix_dataname'), 'means'); 
		call execute('data '||cats(output)||'; '); 
		call execute('	length varnum 8; '); 
		call execute('	set '); 

		call missing(last); 
		do until(last); 
			set &local_prefix_dataname.list_var end=last; 
			dsn = cats(symget('local_prefix_dataname'), 'means', '_', varnum); 
			bin_in = cats('in_', varnum); 
			call execute('		'||cats(dsn)||' (in='||cats(bin_in)||')'); 
		end; 
		call execute('	; '); 

		call missing(last); 
		do until(last); 
			set &local_prefix_dataname.list_var end=last; 
			bin_in = cats('in_', varnum); 
			call execute('	'||'if '||cats(bin_in)||' then varnum = '||cats(varnum)||'; '); 
		end; 
		call execute('run; '); 
		stop; 
	run; 

	data &local_prefix_dataname.1; 
		retain &&&local_prefix_mvarname.list_varname_class.; 
		merge &local_prefix_dataname.list_var (keep=varnum	varname	varlabel)	&local_prefix_dataname.means; 
		by varnum; 
	run; 
	proc sort out=&local_prefix_dataname.2; 
		by _TYPE_	&&&local_prefix_mvarname.list_varname_class.	varnum; 
	run; 
	data &local_prefix_dataname.3; 
		merge &local_prefix_dataname.comb_bin_var_class	&local_prefix_dataname.2 (in=b rename=(_TYPE_=comb_type)); 
		by comb_type; 
		if b; 
	run; 
	proc sort out=&local_prefix_dataname.4; 
		by &&&local_prefix_mvarname.list_varname_by.	comb_type	&&&local_prefix_mvarname.list_varname_class.	varnum; 
	run; 


	data &prefix_output.&output.&suffix_output.; 
		retain &&&local_prefix_mvarname.list_varname_by.; 
		set &local_prefix_dataname.4; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
		modify &prefix_output.&output.&suffix_output.; 
			attrib varnum	varname	varlabel label=' '; 
	run; quit; 
%mend means_stats; 


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



