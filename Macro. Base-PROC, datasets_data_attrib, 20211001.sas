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
%datasets_data_attrib(dsn=temp_dsn); 
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


%macro datasets_data_attrib(dsn=, output=, mvarname=, symboltable=f
	, prefix_output=, suffix_output=, prefix_mvarname=, suffix_mvarname=
	, local_prefix_dataname=l_temp_, local_prefix_mvarname=l_temp_
	); 
/*
data _NULL_; 
	call symputx('dsn', 						'temp_dsn', 'l'); 
	call symputx('output', 						'', 'l'); 
	call symputx('mvarname', 					'', 'l'); 
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
/*	data &local_prefix_dataname.dsn; */
/*		set &dsn_libname..&dsn.; */
/*	run; */


/*	data &prefix_output.&output.&suffix_output.; */
/*		set &local_prefix_dataname.dsn; */
/*	run; */
/*	proc datasets lib=work memtype=data nolist; */
/*		modify &prefix_output.&output.&suffix_output.; */
	proc datasets lib=&dsn_libname. memtype=data nolist; 
		modify &dsn.; 
*		attrib 
			_ALL_							 format= informat=
		; 
		attrib 
			id_proj							 label='Project ID'
			id_proj_c						 label='Project ID'
			id_date_cutoff					 label='Cut-Off Date'
			id_edc							 label='EDC System ID'
			id_edc_c						 label='EDC System ID'

			id_site							 label='Site ID'
			id_site_c						 label='Site ID'
			id_subj							 label='Subject ID'
			id_eye							 label='Eye ID'
			id_eye_c						 label='Eye ID'
			id_visitsubj					 label='Visit ID (by Subject)'
			id_visitsubj_c 					 label='Visit ID (by Subject)'
			id_visiteye						 label='Visit ID (by Eye)'
			id_visiteye_c					 label='Visit ID (by Eye)'
			id_inst							 label='Instance ID'
			id_inst_c						 label='Instance ID'
			id_rec							 label='Record ID'
			id_rec_c						 label='Record ID'
		; 
		attrib 
			pkeye_bin_exit					 label='(Binary) Exited (by Eye)'
			pkeye_bin_opr					 label='(Binary) Operated (by Eye)'
			pkeye_bin_ssi					 label='(Binary) SSI (by Eye)'
			pkeye_biom_acd					 label='Anterior Chamber Depth'
			pkeye_biom_al					 label='Axial Length'
			pkeye_biom_lp					 label='Lens Power'
			pkeye_biom_lp_c					 label='Lens Power'
			pkeye_biom_lp_opr				 label='Lens Power, Op'
			pkeye_biom_lp_opr_c				 label='Lens Power, Op'
			pkeye_biom_lp_pre				 label='Lens Power, Preop'
			pkeye_biom_lp_pre_c				 label='Lens Power, Preop'
			pkeye_cat_arm					 label='Arm'
			pkeye_cat_arm_c					 label='Arm'
			pkeye_cat_arm_paired			 label='Arm, Paired Eye'
			pkeye_cat_arm_paired_c			 label='Arm, Paired Eye'
			pkeye_cat_rand					 label='Randomization'
			pkeye_cat_rand_c				 label='Randomization'
			pkeye_date_exit					 label='Date, Exit'
			pkeye_date_opr					 label='Date, Op'
			pkeye_date_opr_paired			 label='Date, Op, Paired Eye'
			pkeye_date_pre					 label='Date, Preop'
			pkeye_date_ssi					 label='Date, SSI'
			pkeye_eye_paired				 label='Paired Eye'
			pkeye_eye_paired_c				 label='Paired Eye'
			pkeye_nom_grp_model				 label='Model Group'
			pkeye_nom_grp_model_c			 label='Model Group'
			pkeye_nom_model					 label='Model'
			pkeye_nom_model_c				 label='Model'
			pkeye_nom_model_paired			 label='Model, Paired Eye'
			pkeye_nom_model_paired_c		 label='Model, Paired Eye'
			pkeye_nom_model_spec			 label='Model Specify'
			pkeye_ord_eye_opr				 label='Eye Surgery Sequence'
			pkeye_ord_eye_opr_c				 label='Eye Surgery Sequence'
			pkeye_ord_phase					 label='Phase (by Eye)'
			pkeye_ord_phase_c				 label='Phase (by Eye)'
			pkeye_refr_cyl_tgt				 label='Target Refraction, Cylinder'
			pkeye_refr_cyl_tgt_opr			 label='Target Refraction, Cylinder, Op'
			pkeye_refr_cyl_tgt_pre			 label='Target Refraction, Cylinder, Preop'
			pkeye_refr_se_tgt				 label='Target Refraction, SE'
			pkeye_refr_se_tgt_opr			 label='Target Refraction, SE, Op'
			pkeye_refr_se_tgt_pre			 label='Target Refraction, SE, Preop'
			pkeye_ssi_visiteye_lastby		 label='Last Visit (by Eye) by SSI'
			pkeye_ssi_visiteye_lastby_c		 label='Last Visit (by Eye) by SSI'
			pkeye_ssi_visitsubj_lastby		 label='Last Visit (by Subject) by SSI'
			pkeye_ssi_visitsubj_lastby_c	 label='Last Visit (by Subject) by SSI'
			pkeye_surg_name					 label='Surgeon'

			pkpd_date						 label='Date, PD'
			pkpd_eye						 label='Eye, PD'
			pkpd_eye_c						 label='Eye, PD'
			pkpd_type						 label='Protocol Deviation Type'
			pkpd_type_c						 label='Protocol Deviation Type'
			pkpd_type_spec					 label='Protocol Deviation Type, Specification'

			pksite_info						 label='Site Info'
			pksite_investigator				 label='Site Investigator'
			pksite_investigator_lastname	 label='Site Investigator Last Name'

			pksubj_bin_exit					 label='(Binary) Exited (by Subject)'
			pksubj_cat_age_tens				 label='Age Group, by 10s'
			pksubj_cat_age_tens_c			 label='Age Group, by 10s'
			pksubj_date_exit				 label='Date, Exit'
			pksubj_date_opr_1st				 label='Date, Op 1st Eye'
			pksubj_date_opr_2nd				 label='Date, Op 2nd Eye'
			pksubj_date_pre					 label='Date, Preop'
			pksubj_demo_age					 label='Age'
			pksubj_demo_ethnicity			 label='Ethnicity'
			pksubj_demo_ethnicity_c			 label='Ethnicity'
			pksubj_demo_iris				 label='Iris Color'
			pksubj_demo_iris_c				 label='Iris Color'
			pksubj_demo_race				 label='Race'
			pksubj_demo_race_c				 label='Race'
			pksubj_demo_race_spec			 label='Race Specification'
			pksubj_demo_sex					 label='Sex'
			pksubj_demo_sex_c				 label='Sex'
			pksubj_exit_rsn					 label='Exit Reason'
			pksubj_exit_rsn_c				 label='Exit Reason'
			pksubj_exit_spec				 label='Exit Specification'
			pksubj_exit_status				 label='Exit Status'
			pksubj_exit_status_c			 label='Exit Status'
			pksubj_eye_1st					 label='Eye, 1st'
			pksubj_eye_1st_c				 label='Eye, 1st'
			pksubj_eye_2nd					 label='Eye, 2nd'
			pksubj_eye_2nd_c				 label='Eye, 2nd'
			pksubj_eye_opr					 label='Eye Operated (by Subject)'
			pksubj_eye_opr_c				 label='Eye Operated (by Subject)'
			pksubj_nom_model_1st			 label='Model, 1st Eye'
			pksubj_nom_model_1st_c			 label='Model, 1st Eye'
			pksubj_nom_model_2nd			 label='Model, 2nd Eye'
			pksubj_nom_model_2nd_c			 label='Model, 2nd Eye'
			pksubj_ord_phase				 label='Phase (by Subject)'
			pksubj_ord_phase_c				 label='Phase (by Subject)'

			pkve_date						 label='Visit Date (by Eye)'
			pkve_acct_bin_01				 label='Available for Analysis'
			pkve_acct_bin_02				 label='--In Interval (included in analysis)'
			pkve_acct_bin_03				 label='--Out of Interval (included in analysis)'
			pkve_acct_bin_04				 label='Missing Eyes'
			pkve_acct_bin_05				 label='--Discontinued '
			pkve_acct_bin_06				 label='--Missed visit'
			pkve_acct_bin_07				 label='--Not seen but accounted for'
			pkve_acct_bin_08				 label='--Lost-to-follow-up'
			pkve_acct_bin_09				 label='Active'
			pkve_acct_bin_10				 label='--Active (not yet in visit interval)'
			pkve_acct_bin_11				 label='--In interval or Past interval (form not yet received)'

			pkvs_date						 label='Visit Date (by Subject)'
			pkvs_eye						 label='Eye Evaluated'
			pkvs_eye_c						 label='Eye Evaluated'
			pkvs_nom_status					 label='Visit Status'
			pkvs_nom_status_c				 label='Visit Status'
		; 
		attrib 
			date_cutoff						 label='Cutoff Date'
			diff_se_mr_tgt					 label='MRSE - Target SE'
			ker_k_cyl						 label='K Cylinder'
			ker_k_flat						 label='Flat K'
			ker_k_steep						 label='Steep K'
			ker_k_value						 label='K Value'
			mr_mra							 label='MRA'
			mr_mrc							 label='MRC'
			mr_mrc_adj_cplane				 label='MRC (Corneal Plane)'
			mr_mrs							 label='MRS'
			mr_mrs_adj_cplane				 label='MRS (Corneal Plane)'
			mr_mrse							 label='MRSE'
			mr_mrse_adj_cplane				 label='MRSE (Corneal Plane)'
			va_bcdva_letter					 label='BCDVA Letter'
			va_bcdva_logmar					 label='BCDVA LogMAR'
			va_bcdva_snellen				 label='BCDVA Snellen'
			va_bcdva_snellen_c				 label='BCDVA Snellen'
			va_bcdva_decimal				 label='BCDVA Decimal'
			va_bscva_letter					 label='BSCVA Letter'
			va_bscva_logmar					 label='BSCVA LogMAR'
			va_bscva_snellen				 label='BSCVA Snellen'
			va_bscva_snellen_c				 label='BSCVA Snellen'
			va_bscva_decimal				 label='BSCVA Decimal'
			va_ucdva_letter					 label='UCDVA Letter'
			va_ucdva_logmar					 label='UCDVA LogMAR'
			va_ucdva_snellen				 label='UCDVA Snellen'
			va_ucdva_snellen_c				 label='UCDVA Snellen'
			va_ucdva_decimal				 label='UCDVA Decimal'
		; 
		attrib 
			date_:							 format=yymmdd10.
			id_date_:						 format=yymmdd10.
			pkeye_date:						 format=yymmdd10.
			pkinst_date:					 format=yymmdd10.
			pkpd_date:						 format=yymmdd10.
			pkrec_date:						 format=yymmdd10.
			pksae_date:						 format=yymmdd10.
			pksubj_date:					 format=yymmdd10.
			pkve_date:						 format=yymmdd10.
			pkvs_date:						 format=yymmdd10.
		; 
	run; quit; 

	proc datasets lib=work memtype=data nolist; 
		delete &local_prefix_dataname.:; 
	run; quit; 
%mend datasets_data_attrib; 


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



