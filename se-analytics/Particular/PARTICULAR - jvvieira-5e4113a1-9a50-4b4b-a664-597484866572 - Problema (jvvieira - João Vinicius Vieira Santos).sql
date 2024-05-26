SELECT DTDEADLINEFIELD,DTSTART,IDLEVEL,IDPROCESS,IDREVISIONSTATUS,IDSITUATION,IDSLASTATUS,NMDEADLINE,NMEVALRESULT,NMOCCURRENCETYPE,NMPROCESS,NMPROCESSMODEL,NMREVISIONSTATUS,NMUSERSTART,TYPEUSER,FGSTATUS,FGSLASTATUS,FGDEADLINE,CDEVALRESULT,CDOCCURRENCETYPE,CDPROCESS,CDPROCESSMODEL,CDREVISIONSTATUS,CDUSERSTART,FGTYPEUSER,DURATION_WF,T0__DE007_2,T0__DE001_6,T0__DE006_2,T0__DE003_5,T0__DE013_1,T0__DE008_1,T0__DE009_1,T0__DE004_1,T0__DE010_2,T0__DE011_2,T0__DE005_1,T0__DE012_3,T0__DE002_1,T0_R0_DE001_1,T0_R1_DE001_1,T0_R2_SIMNAO_1,T0_R3_TBS001_1,T0_R4_SIMNAO_1,T0_R5_SIMNAO_1,T0_R6_DE001_1 FROM (SELECT DTDEADLINEFIELD,DTSTART,IDLEVEL,IDPROCESS,IDREVISIONSTATUS,IDSITUATION,IDSLASTATUS,NMDEADLINE,NMEVALRESULT,NMOCCURRENCETYPE,NMPROCESS,NMPROCESSMODEL,NMREVISIONSTATUS,NMUSERSTART,TYPEUSER,FGSTATUS,FGSLASTATUS,FGDEADLINE,CDEVALRESULT,CDOCCURRENCETYPE,CDPROCESS,CDPROCESSMODEL,CDREVISIONSTATUS,CDUSERSTART,FGTYPEUSER,DURATION_WF,T0__DE007_2,T0__DE001_6,T0__DE006_2,T0__DE003_5,T0__DE013_1,T0__DE008_1,T0__DE009_1,T0__DE004_1,T0__DE010_2,T0__DE011_2,T0__DE005_1,T0__DE012_3,T0__DE002_1,T0_R0_DE001_1,T0_R1_DE001_1,T0_R2_SIMNAO_1,T0_R3_TBS001_1,T0_R4_SIMNAO_1,T0_R5_SIMNAO_1,T0_R6_DE001_1 FROM (SELECT 1 AS QTD, WFP.IDPROCESS, WFP.NMPROCESS, WFP.FGSLASTATUS, WFP.FGSTATUS, WFP.CDPROCESS, WFP.CDPROCESSMODEL, COALESCE(ADU.NMUSER, TBEXT.NMUSER) AS NMUSERSTART, GNT.NMGENTYPE AS NMOCCURRENCETYPE, GNT.CDGENTYPE AS CDOCCURRENCETYPE, GNRS.IDREVISIONSTATUS, GNRS.NMREVISIONSTATUS, GNRS.CDREVISIONSTATUS, GNR.NMEVALRESULT, GNR.CDEVALRESULT, COALESCE(PML.NMPROCESS, WFP.NMPROCESSMODEL) AS NMPROCESSMODEL, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN WFP.CDEXTERNALUSERSTART WHEN WFP.CDUSERSTART IS NOT NULL THEN WFP.CDUSERSTART ELSE NULL END AS CDUSERSTART, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN '#{303826}' WHEN WFP.CDUSERSTART IS NOT NULL THEN '#{305843}' ELSE NULL END AS TYPEUSER, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN 2 WHEN WFP.CDUSERSTART IS NOT NULL THEN 1 ELSE NULL END AS FGTYPEUSER, CASE WHEN WFP.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN WFP.FGCONCLUDEDSTATUS=1 THEN '#{100900}' WHEN WFP.FGCONCLUDEDSTATUS=2 THEN '#{100899}' END) ELSE (CASE WHEN (WFP.DTESTIMATEDFINISH > DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST(<!%TODAY%> AS DATETIME)) OR WFP.DTESTIMATEDFINISH IS NULL) THEN '#{100900}' WHEN (( WFP.DTESTIMATEDFINISH=CAST(<!%TODAY%> AS DATETIME) AND WFP.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR WFP.DTESTIMATEDFINISH > CAST(<!%TODAY%> AS DATETIME)) THEN '#{201639}' ELSE '#{100899}' END) END AS NMDEADLINE, CASE WHEN WFP.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN WFP.FGCONCLUDEDSTATUS=1 THEN 1 WHEN WFP.FGCONCLUDEDSTATUS=2 THEN 3 END) ELSE (CASE WHEN (WFP.DTESTIMATEDFINISH > DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST(<!%TODAY%> AS DATETIME)) OR WFP.DTESTIMATEDFINISH IS NULL) THEN 1 WHEN (( WFP.DTESTIMATEDFINISH=CAST(<!%TODAY%> AS DATETIME) AND WFP.NRTIMEESTFINISH >= 814) OR WFP.DTESTIMATEDFINISH > CAST(<!%TODAY%> AS DATETIME)) THEN 2 ELSE 3 END) END AS FGDEADLINE, CASE WFP.FGSLASTATUS WHEN 10 THEN '#{218492}' WHEN 30 THEN '#{218493}' WHEN 40 THEN '#{218494}' END AS IDSLASTATUS, CASE WFP.FGSTATUS WHEN 1 THEN '#{103131}' WHEN 2 THEN '#{107788}' WHEN 3 THEN '#{104230}' WHEN 4 THEN '#{100667}' WHEN 5 THEN '#{200712}' END AS IDSITUATION, (SELECT MAX(SLAHIST.IDLEVEL) FROM GNSLACTRLHISTORY SLAHIST WHERE (SLAHIST.CDSLACONTROL=WFP.CDSLACONTROL AND SLAHIST.FGCURRENT=1)) AS IDLEVEL, DATEADD(minute, WFP.NRTIMEESTFINISH, WFP.DTESTIMATEDFINISH) AS DTDEADLINEFIELD, CONVERT(DATETIME, WFP.DTSTART + ' ' + WFP.TMSTART, 120) AS DTSTART, CASE WHEN WFP.FGSTATUS IN (1,2,3,5) THEN (CAST(FLOOR(CAST((GETDATE()-(WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))) AS VARCHAR) + LOWER(' #{108037} ') + CAST(FLOOR((CAST((GETDATE()-(WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))))*24) AS VARCHAR) + LOWER(' #{101173} ') + CAST(FLOOR((((CAST((GETDATE()-(WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))))*24) - FLOOR((CAST((GETDATE()-(WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))))*24))*60) AS VARCHAR) + LOWER(' #{101181} ')) WHEN WFP.FGSTATUS=4 THEN (CAST(FLOOR(CAST(((WFP.DTFINISH+' '+WFP.TMFINISH) - (WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))) AS VARCHAR) + LOWER(' #{108037} ') + CAST(FLOOR((CAST(((WFP.DTFINISH+' '+WFP.TMFINISH) - (WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((WFP.DTFINISH+' '+WFP.TMFINISH) - (WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))))*24) AS VARCHAR) + LOWER(' #{101173} ') + CAST(FLOOR((((CAST(((WFP.DTFINISH+' '+WFP.TMFINISH) - (WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((WFP.DTFINISH+' '+WFP.TMFINISH) - (WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))))*24) - FLOOR((CAST(((WFP.DTFINISH+' '+WFP.TMFINISH) - (WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((WFP.DTFINISH+' '+WFP.TMFINISH) - (WFP.DTSTART+' '+WFP.TMSTART)) AS NUMERIC(18,8))))*24))*60) AS VARCHAR) + LOWER(' #{101181} ')) END AS DURATION_WF, T0_OUTER.T0__DE007_2, T0_OUTER.T0__DE001_6, T0_OUTER.T0__DE006_2, T0_OUTER.T0__DE003_5, T0_OUTER.T0__DE013_1, T0_OUTER.T0__DE008_1, T0_OUTER.T0__DE009_1, T0_OUTER.T0__DE004_1, T0_OUTER.T0__DE010_2, T0_OUTER.T0__DE011_2, T0_OUTER.T0__DE005_1, T0_OUTER.T0__DE012_3, T0_OUTER.T0__DE002_1, T0_OUTER.T0_R0_DE001_1, T0_OUTER.T0_R1_DE001_1, T0_OUTER.T0_R2_SIMNAO_1, T0_OUTER.T0_R3_TBS001_1, T0_OUTER.T0_R4_SIMNAO_1, T0_OUTER.T0_R5_SIMNAO_1, T0_OUTER.T0_R6_DE001_1 FROM WFPROCESS WFP INNER JOIN INOCCURRENCE INOCCUR ON (INOCCUR.IDWORKFLOW=WFP.IDOBJECT AND INOCCUR.FGOCCURRENCETYPE=2) LEFT JOIN GNGENTYPE GNT ON (GNT.CDGENTYPE=INOCCUR.CDOCCURRENCETYPE) LEFT JOIN GNREVISION GNREV ON (GNREV.CDREVISION=WFP.CDREVISION) LEFT JOIN ADUSER ADU ON (ADU.CDUSER=WFP.CDUSERSTART) LEFT JOIN (SELECT ADEU.CDEXTERNALUSER, ADEU.NMUSER, ADC.NMCOMPANY FROM ADEXTERNALUSER ADEU INNER JOIN ADCOMPANY ADC ON (ADEU.CDCOMPANY=ADC.CDCOMPANY)) TBEXT ON (TBEXT.CDEXTERNALUSER=WFP.CDEXTERNALUSERSTART) LEFT JOIN GNREVISIONSTATUS GNRS ON (GNRS.CDREVISIONSTATUS=WFP.CDSTATUS) LEFT JOIN GNEVALRESULTUSED GNRUS ON (GNRUS.CDEVALRESULTUSED=WFP.CDEVALRSLTPRIORITY) LEFT JOIN GNEVALRESULT GNR ON (GNR.CDEVALRESULT=GNRUS.CDEVALRESULT) LEFT JOIN PMACTREVISION PMACT ON (( PMACT.CDACTIVITY=WFP.CDPROCESSMODEL AND PMACT.FGCURRENT=1)) LEFT JOIN PMPROCESSLANGUAGE PML ON (( PML.CDPROCESS=PMACT.CDACTIVITY AND PML.CDREVISION=PMACT.CDREVISION AND PML.FGENABLED=1 AND PML.FGLANGUAGE=2)) INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON (WF.CDTEAM=TM.CDTEAM) WHERE (WF.FGACCESSTYPE=1 AND TM.CDUSER=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON (WF.CDDEPARTMENT=UDP.CDDEPARTMENT) WHERE (WF.FGACCESSTYPE=2 AND UDP.CDUSER=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON (WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION) WHERE (WF.FGACCESSTYPE=3 AND UDP.CDUSER=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON (WF.CDPOSITION=UDP.CDPOSITION) WHERE (WF.FGACCESSTYPE=4 AND UDP.CDUSER=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE (WF.FGACCESSTYPE=5 AND WF.CDUSER=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE (WF.FGACCESSTYPE=6 AND US.CDUSER=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON (WF.CDROLE=RL.CDROLE) WHERE (WF.FGACCESSTYPE=7 AND RL.CDUSER=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON (WF.IDPROCESS=WFP.IDOBJECT) WHERE (WF.FGACCESSTYPE=30 AND WFP.CDUSERSTART=10108 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON (WF.IDPROCESS=WFP.IDOBJECT) INNER JOIN ADUSER US ON (WFP.CDUSERSTART=US.CDUSER) WHERE (WF.FGACCESSTYPE=31 AND US.CDLEADER=10108 AND WF.FGACCESSEXCEPTION IS NULL)) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON (PERM.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM.IDPROCESS=GNASSOC.IDPROCESS) WHERE (GNASSOC.CDACCESSROLEFIELD IN (501)) GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON (AUXWFP.IDOBJECT=PERMISSION.IDPROCESS) WHERE (PERMISSION.FGPERMISSION=1 AND AUXWFP.FGSTATUS <= 5 AND (AUXWFP.FGMODELWFSECURITY IS NULL OR AUXWFP.FGMODELWFSECURITY=0)) UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON (PP.CDTEAM=TM.CDTEAM) WHERE (PP.FGACCESSTYPE=1 AND TM.CDUSER=10108) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT) WHERE (PP.FGACCESSTYPE=2 AND UDP.CDUSER=10108) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION) WHERE (PP.FGACCESSTYPE=3 AND UDP.CDUSER=10108) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDPOSITION=UDP.CDPOSITION) WHERE (PP.FGACCESSTYPE=4 AND UDP.CDUSER=10108) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE (PP.FGACCESSTYPE=5 AND PP.CDUSER=10108) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE (PP.FGACCESSTYPE=6 AND US.CDUSER=10108) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON (PP.CDROLE=RL.CDROLE) WHERE (PP.FGACCESSTYPE=7 AND RL.CDUSER=10108)) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY OBJ ON (GNASSOC.CDPROC=OBJ.CDACTIVITY) INNER JOIN WFPROCESS WFP ON (PERM1.CDPROC=WFP.CDPROCESSMODEL) WHERE (GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) UNION ALL SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON (PP.CDPROC=WFP.CDPROCESSMODEL) WHERE (PP.FGACCESSTYPE=30 AND WFP.CDUSERSTART=10108 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) UNION ALL SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON (PP.CDPROC=WFP.CDPROCESSMODEL) INNER JOIN ADUSER US ON (WFP.CDUSERSTART=US.CDUSER) WHERE (PP.FGACCESSTYPE=31 AND US.CDLEADER=10108 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5)) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY OBJ ON (GNASSOC.CDPROC=OBJ.CDACTIVITY) WHERE (GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL))) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T WHERE (T.FGPERMISSION=1) UNION ALL SELECT PERM.IDOBJECT FROM (SELECT WFP.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON (PM.CDTEAM=TM.CDTEAM) WHERE (PM.FGACCESSTYPE=1 AND TM.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON (PM.CDDEPARTMENT=UDP.CDDEPARTMENT) WHERE (PM.FGACCESSTYPE=2 AND UDP.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON (PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION) WHERE (PM.FGACCESSTYPE=3 AND UDP.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON (PM.CDPOSITION=UDP.CDPOSITION) WHERE (PM.FGACCESSTYPE=4 AND UDP.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM WHERE (PM.FGACCESSTYPE=5 AND PM.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM WHERE (PM.FGACCESSTYPE=6) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON (PM.CDROLE=RL.CDROLE) WHERE (PM.FGACCESSTYPE=7 AND RL.CDUSER=10108)) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON (GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY PMA ON (PERM1.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) WHERE (GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1) UNION ALL SELECT WFP.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) WHERE (PM.FGACCESSTYPE=8 AND PMA.CDCREATEDBY=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSERDEPTPOS DEP1 ON (PMA.CDCREATEDBY=DEP1.CDUSER) INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP1.CDDEPARTMENT=DEP2.CDDEPARTMENT) WHERE (PM.FGACCESSTYPE=9 AND DEP2.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSERDEPTPOS DEP1 ON (PMA.CDCREATEDBY=DEP1.CDUSER) INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP1.CDDEPARTMENT=DEP2.CDDEPARTMENT AND DEP1.CDPOSITION=DEP2.CDPOSITION) WHERE (PM.FGACCESSTYPE=10 AND DEP2.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSERDEPTPOS DEP1 ON (PMA.CDCREATEDBY=DEP1.CDUSER) INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP1.CDPOSITION=DEP2.CDPOSITION) WHERE (PM.FGACCESSTYPE=11 AND DEP2.CDUSER=10108) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSER US ON (PMA.CDCREATEDBY=US.CDUSER) WHERE (PM.FGACCESSTYPE=12 AND US.CDLEADER=10108)) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON (GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY PMA ON (PERM2.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) WHERE (GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1) UNION ALL SELECT PERM3.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) WHERE (PM.FGACCESSTYPE=30 AND WFP.CDUSERSTART=10108 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) INNER JOIN ADUSER US ON (WFP.CDUSERSTART=US.CDUSER) WHERE (PM.FGACCESSTYPE=31 AND US.CDLEADER=10108 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1)) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON (GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY PMA ON (PERM3.CDACTTYPE=PMA.CDACTTYPE) WHERE (GNCTRL_F.CDRELATEDFIELD IN (501) AND PMA.FGUSETYPEACCESS=1)) PERM UNION ALL SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN WFPROCSECURITYLIST WFLIST ON (AUXWFP.IDOBJECT=WFLIST.IDPROCESS) INNER JOIN WFPROCSECURITYCTRL WFCTRL ON (WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS) WHERE (WFCTRL.CDACCESSROLEFIELD IN (501) AND WFLIST.CDUSER=10108 AND WFLIST.FGACCESSTYPE=5 AND WFLIST.FGACCESSEXCEPTION=1 AND WFLIST.FGPERMISSION=1 AND AUXWFP.FGSTATUS <= 5)) Z) MYPERM ON (WFP.IDOBJECT=MYPERM.IDOBJECT) LEFT JOIN (SELECT FORMREG.CDASSOC, T0.DE007 AS T0__DE007_2, T0.DE001 AS T0__DE001_6, T0.DE006 AS T0__DE006_2, CAST(T0.DE003 AS NUMERIC(19)) * 1000 AS T0__DE003_5, T0.DE013 AS T0__DE013_1, T0.DE008 AS T0__DE008_1, T0.DE009 AS T0__DE009_1, T0.DE004 AS T0__DE004_1, T0.DE010 AS T0__DE010_2, T0.DE011 AS T0__DE011_2, T0.DE005 AS T0__DE005_1, T0.DE012 AS T0__DE012_3, T0.DE002 AS T0__DE002_1, R0.DE001 AS T0_R0_DE001_1, R1.DE001 AS T0_R1_DE001_1, R2.SIMNAO AS T0_R2_SIMNAO_1, R3.TBS001 AS T0_R3_TBS001_1, R4.SIMNAO AS T0_R4_SIMNAO_1, R5.SIMNAO AS T0_R5_SIMNAO_1, R6.DE001 AS T0_R6_DE001_1 FROM GNASSOCFORMREG FORMREG INNER JOIN DYNdesvti T0 ON (T0.OID=FORMREG.OIDENTITYREG) LEFT JOIN DYNareadeti R0 ON (T0.OIDABCYZZJ1ZK47WW0=R0.OID) LEFT JOIN DYNareadeti R1 ON (T0.OIDABCADWBCJ8G93AH=R1.OID) LEFT JOIN DYNsimnao R2 ON (T0.OIDABCSKOVH2R3P09Q=R2.OID) LEFT JOIN DYNtbs001 R3 ON (T0.OIDABCO296K5JKDB9S=R3.OID) LEFT JOIN DYNsimnao R4 ON (T0.OIDABCF30VGC6HCS8G=R4.OID) LEFT JOIN DYNsimnao R5 ON (T0.OIDABC5E3NINY89MP3=R5.OID) LEFT JOIN DYNdetisistpro R6 ON (T0.OIDABCEFZNVUTCXGUJ=R6.OID)) T0_OUTER ON (T0_OUTER.CDASSOC=WFP.CDASSOCREG) WHERE (WFP.CDPRODAUTOMATION=202 AND WFP.FGSTATUS <= 5 AND WFP.FGSTATUS IN (1, 5) AND (GNT.CDTYPEROLE IS NULL OR EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.CDTYPEROLE=GNT.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=10108 OR 10108=-1))) AND GNT.CDGENTYPE IN (201))) TEMPTB0) TEMPTB1