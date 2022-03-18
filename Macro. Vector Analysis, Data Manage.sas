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
convert to "plus cylinder notation" (edit axis first because cylinder will be changed)
for OS only (adjusted axis = 180°-original axis)
**HISTORY OF MODIFICATIONS: 
**    DATE:          PROGRAMMER:          CHANGE: 
****************************************************************************; 


/*
Reference: 
Standardized Analyses of Correction of Astigmatism by Laser Systems That Reshape the Cornea
http://www.hicsoap.com/publications/100%20Standardized%20analyses%20of%20correction%20of%20astigmatism%20by%20laser%20systems%20that%20reshape%20the%20cornea%20JCRS2006.pdf
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
%create_vector(dsn=efficacy, prefix_output=temp_, output=1, pre_cyl=pre_mrc, pre_axis=pre_mra, post_cyl=mrc, post_axis=mra); 
%create_vector(dsn=efficacy, prefix_output=eye_, pre_cyl=pre_mrc, pre_axis=pre_mra, post_cyl=mrc, post_axis=mra); 
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


/*
data _NULL_; 
	call symputx('dsn', 'efficacy'); 
	call symputx('output', '1'); 
	call symputx('prefix_output', 'temp_'); 
	call symputx('local_prefix_dataname', 'macro_temp_'); 
	call symputx('local_prefix_macrovarname', ''); 
	call symputx('pre_cyl', 'pre_mrc'); 
	call symputx('pre_axis', 'pre_mra'); 
	call symputx('post_cyl', 'mrc'); 
	call symputx('post_axis', 'mra'); 
run; 
*/


%macro create_vector(dsn=, output=vector, prefix_output=temp_
	, local_prefix_dataname=macro_temp_, local_prefix_macrovarname=
	, pre_cyl=, pre_axis=, post_cyl=, post_axis=
	); 
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
********************************************************************************
****								Comments								****
********************************************************************************
convert to "plus cylinder notation" (edit axis first because cylinder will be changed)
********************************************************************************; 
/*		&pre_axis. 	= mod(&pre_axis.+(.<&pre_cyl.<0)*90, 180); */
/*		&pre_cyl. 	= abs(&pre_cyl.); *edit axis first, cylinder is changed; */
/*		&post_axis. = mod(&post_axis.+(.<&post_cyl.<0)*90, 180); */
/*		&post_cyl. 	= abs(&post_cyl.); *edit axis first, cylinder is changed; */
********************************************************************************
convert to "plus cylinder notation" (edit axis first because cylinder will be changed)
********************************************************************************
****								Comments								****
********************************************************************************; 
	run; 


	data &local_prefix_dataname.1; 
		set &local_prefix_dataname.dsn; 

		pi			= 4*atan(1); 
		x_preop		= &pre_cyl.*cos(2*(&pre_axis./(180/pi))); 
		y_preop		= &pre_cyl.*sin(2*(&pre_axis./(180/pi))); 
		x_postop	= &post_cyl.*cos(2*(&post_axis./(180/pi))); 
		y_postop	= &post_cyl.*sin(2*(&post_axis./(180/pi))); 

		/* irc */
		/* target is emmetropia */
		x_irc		= x_preop; 
		y_irc		= y_preop; 
		irc_cyl		= &pre_cyl.; 
		irc_axis	= &pre_axis.; 

		/* sirc */
		x_sirc = x_preop-x_postop; 
		y_sirc = y_preop-y_postop; 
		sirc_cyl=sqrt(x_sirc**2 + y_sirc**2); 
********************************************************************************
****								Comments								****
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************; 
		sirc_cyl_05 = 0; sirc_cyl_10 = 0; 
		if .<sirc_cyl<=0.5	 then sirc_cyl_05 = 1; 
		if .<sirc_cyl<=1	 then sirc_cyl_10 = 1; 
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************
****								Comments								****
********************************************************************************; 
		if x_sirc^=0 then sirc_theta = 0.5*(atan(y_sirc/x_sirc)*(180/pi)); 
		if y_sirc>=0 & x_sirc>0 then sirc_axis = sirc_theta; 
		if y_sirc<0 & x_sirc>0 then sirc_axis = sirc_theta+180; 
		if x_sirc<0 then sirc_axis = sirc_theta+90; 
		if x_sirc=0 & y_sirc>0 then sirc_axis = 45; 
		if x_sirc=0 & y_sirc<0 then sirc_axis = 135; 

********************************************************************************
****								Comments								****
********************************************************************************
2015-10-27	axis SIRC, sirc_axis
********************************************************************************; 
		if (x_sirc=0 & y_sirc=0) then sirc_axis = 0; 
********************************************************************************
2015-10-27	axis SIRC, sirc_axis
********************************************************************************
****								Comments								****
********************************************************************************; 

		/* absolute (non-vector) cylinder change */
		change_cyl_abs = abs(&post_cyl.-&pre_cyl.); 
********************************************************************************
****								Comments								****
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************; 
		change_cyl_abs_05 = 0; change_cyl_abs_10 = 0; 
		if .<change_cyl_abs<=0.5 then change_cyl_abs_05 = 1; 
		if .<change_cyl_abs<=1	 then change_cyl_abs_10 = 1; 
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************
****								Comments								****
********************************************************************************; 

		/* em & ea */
		em = sqrt(x_irc**2 + y_irc**2) - sirc_cyl; 
********************************************************************************
****								Comments								****
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************; 
		em_abs = abs(em); 
		em_abs_05 = 0; em_abs_10 = 0; 
		if .<em_abs<=0.5 then em_abs_05 = 1; 
		if .<em_abs<=1	 then em_abs_10 = 1; 
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************
****								Comments								****
********************************************************************************; 
		if abs(sirc_axis-irc_axis)<90 then ea = sirc_axis-irc_axis; 
		if sirc_axis-irc_axis>90 then ea = sirc_axis-irc_axis-180; 
		if sirc_axis-irc_axis<-90 then ea = sirc_axis-irc_axis+180; 
		if abs(sirc_axis-irc_axis)=90 then ea = 0; 
		if em=0 then ea = 0; 
********************************************************************************
****								Comments								****
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************; 
		select; 
			when (abs(ea)<=15) ea_cat1 = 1; 
			when (15<ea) ea_cat1 = 2; 
			when (.<ea<-15) ea_cat1 = 3; 
			otherwise ea_cat1 = 0; 
		end; 
********************************************************************************
XXXXXXXXXXXXXXXXXXXX
********************************************************************************
****								Comments								****
********************************************************************************; 

		/* ev */
		x_ev = x_irc-x_sirc; 
		y_ev = y_irc-y_sirc; 
		ev_cyl = sqrt(x_ev**2 + y_ev**2); 
		if x_ev^=0 then ev_theta = 0.5*(atan(y_ev/x_ev)*(180/pi)); 
		if y_ev>=0 & x_ev>0 then ev_axis = ev_theta; 
		if y_ev<0 & x_ev>0 then ev_axis = ev_theta+180; 
		if x_ev<0 then ev_axis = ev_theta+90; 
		if x_ev=0 & y_ev>0 then ev_axis = 45; 
		if x_ev=0 & y_ev<0 then ev_axis = 135; 
		if ev_cyl=0 then ev_axis = 0; 

		/* nev */
		x_nev = ev_cyl*(cos(2*(ev_axis-irc_axis)/(180/pi))); 
		y_nev = ev_cyl*(sin(2*(ev_axis-irc_axis)/(180/pi))); 
		nev_cyl = sqrt(x_nev**2 + y_nev**2); 
		if x_nev^=0 then nev_theta = 0.5*(atan(y_nev/x_nev)*(180/pi)); 
		if y_nev>=0 & x_nev>0 then nev_axis = nev_theta; 
		if y_nev<0 & x_nev>0 then nev_axis = nev_theta+180; 
		if x_nev<0 then nev_axis = nev_theta+90; 
		if x_nev=0 & y_nev>0 then nev_axis = 45; 
		if x_nev=0 & y_nev<0 then nev_axis = 135; 
		if nev_cyl=0 then nev_axis = 0; 

		/* tev */
		x_tev = em*cos(2*ea/(180/pi)); 
		y_tev = em*sin(2*ea/(180/pi)); 
		tev_cyl = sqrt(x_tev**2 + y_tev**2); 
		if em<0 & 0<=ea<=90 then tev_axis = ea+90; 
		if em<0 & -90<=ea<0 then tev_axis = (180+ea)-90; 
		if em>=0 & 0<=ea<=90 then tev_axis = ea; 
		if em>=0 & -90<=ea<0 then tev_axis = (180+ea); 

		/* as, er, cr */
		as = &post_axis.-&pre_axis.; 
		if irc_cyl^=0 then do; 
			er = ev_cyl/irc_cyl; 
			cr = sirc_cyl/irc_cyl; 
		end; 
	run; 

	data &prefix_output.&output.; 
		set &local_prefix_dataname.1; 
	run; 
	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend create_vector; 


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



