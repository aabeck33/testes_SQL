SELECT IDPROCESS,DTDEADLINEFIELD,NMPROCESS,CDPROCESS,WF_QTHOURS,TYPEUSER,FGTYPEUSER,NMEVALRESULT,CDEVALRESULT,NMUSERSTART,CDUSERSTART,NMROLE,CDROLE,NMSTRUCT,IDSTRUCT,IDSITUATION,FGSTATUS,NMEXECUTEDACTION,IDEXECUTEDACTION,NMPROCESSMODEL,CDPROCESSMODEL,DTEXECUTION,NMOCCURRENCETYPE,CDOCCURRENCETYPE,TYPEUSEREXEC,FGTYPEUSEREXEC,DURATION_WF_DAY,NMUSER,CDUSER,IDDEPTINI,NMDEPTINI,CDDEPTINI,IDDEPTEXEC,NMDEPTEXEC,CDDEPTEXEC,DURATION_WF_HOUR,NMDEADLINE,FGDEADLINE,DURATION_WF_MIN FROM (SELECT IDPROCESS,DTDEADLINEFIELD,NMPROCESS,CDPROCESS,WF_QTHOURS,TYPEUSER,FGTYPEUSER,NMEVALRESULT,CDEVALRESULT,NMUSERSTART,CDUSERSTART,NMROLE,CDROLE,NMSTRUCT,IDSTRUCT,IDSITUATION,FGSTATUS,NMEXECUTEDACTION,IDEXECUTEDACTION,NMPROCESSMODEL,CDPROCESSMODEL,DTEXECUTION,NMOCCURRENCETYPE,CDOCCURRENCETYPE,TYPEUSEREXEC,FGTYPEUSEREXEC,DURATION_WF_DAY,NMUSER,CDUSER,IDDEPTINI,NMDEPTINI,CDDEPTINI,IDDEPTEXEC,NMDEPTEXEC,CDDEPTEXEC,DURATION_WF_HOUR,NMDEADLINE,FGDEADLINE,DURATION_WF_MIN FROM (SELECT 1 AS QTD, WFP.IDPROCESS, WFP.NMPROCESS, WFP.CDPROCESS, COALESCE(PML.NMPROCESS, WFP.NMPROCESSMODEL) AS NMPROCESSMODEL, WFP.CDPROCESSMODEL, COALESCE(ADU.NMUSER, TBEXT.NMUSER) AS NMUSERSTART, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN WFP.CDEXTERNALUSERSTART WHEN WFP.CDUSERSTART IS NOT NULL THEN WFP.CDUSERSTART ELSE NULL END AS CDUSERSTART, GNT.NMGENTYPE AS NMOCCURRENCETYPE, GNT.CDGENTYPE AS CDOCCURRENCETYPE, GNR.NMEVALRESULT, GNR.CDEVALRESULT, COALESCE(PMEL.NMELEMENT, WFS.NMSTRUCT) AS NMSTRUCT, WFS.IDOBJECT AS IDSTRUCT, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN '#{303826}' WHEN WFP.CDUSERSTART IS NOT NULL THEN '#{305843}' ELSE NULL END AS TYPEUSER, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN 2 WHEN WFP.CDUSERSTART IS NOT NULL THEN 1 ELSE NULL END AS FGTYPEUSER, WFS.NMROLE, WFS.CDROLE, CASE WHEN WFS.FGSTATUS=1 THEN '#{114667}' WHEN WFS.FGSTATUS=2 THEN '#{114666}' WHEN WFS.FGSTATUS=3 THEN '#{107507}' WHEN WFS.FGSTATUS=4 THEN '#{108240}' WHEN WFS.FGSTATUS=5 THEN '#{102338}' WHEN WFS.FGSTATUS=6 THEN '#{206049}' WHEN WFS.FGSTATUS=7 THEN '#{214511}' END AS IDSITUATION, WFS.FGSTATUS, CASE WHEN WFS.FGACTAUTOEXECUTED=1 THEN '#{102949}' ELSE WFS.NMUSER END AS NMUSER, CASE WHEN WFS.FGACTAUTOEXECUTED=1 THEN -1 ELSE WFS.CDUSER END AS CDUSER, CASE WHEN WFS.CDEXTERNALUSER IS NOT NULL THEN '#{303826}' WHEN WFS.CDUSER IS NOT NULL AND WFS.NMUSER IS NOT NULL THEN '#{305843}' ELSE NULL END AS TYPEUSEREXEC, CASE WHEN WFS.CDEXTERNALUSER IS NOT NULL THEN 2 WHEN WFS.CDUSER IS NOT NULL AND WFS.NMUSER IS NOT NULL THEN 1 ELSE NULL END AS FGTYPEUSEREXEC, COALESCE(PMAL.NMACTION, WFS.NMEXECUTEDACTION) AS NMEXECUTEDACTION, WFS.IDEXECUTEDACTION, CASE WHEN WFS.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN WFS.FGCONCLUDEDSTATUS=1 THEN '#{100900}' WHEN WFS.FGCONCLUDEDSTATUS=2 THEN '#{100899}' END) ELSE (CASE WHEN WFS.FGTYPE=1 THEN (CASE WHEN (( SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST(<!%TODAY%> AS DATETIME)) OR (SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) IS NULL) THEN '#{100900}' WHEN (((SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT)=CAST(<!%TODAY%> AS DATETIME) AND (SELECT WFPD.NRTIMEESTFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > CAST(<!%TODAY%> AS DATETIME)) THEN '#{201639}' ELSE '#{100899}' END) ELSE (CASE WHEN (WFS.DTESTIMATEDFINISH > DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST(<!%TODAY%> AS DATETIME)) OR WFS.DTESTIMATEDFINISH IS NULL) THEN '#{100900}' WHEN (( WFS.DTESTIMATEDFINISH=CAST(<!%TODAY%> AS DATETIME) AND WFS.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR WFS.DTESTIMATEDFINISH > CAST(<!%TODAY%> AS DATETIME)) THEN '#{201639}' ELSE '#{100899}' END) END) END AS NMDEADLINE, CASE WHEN WFS.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN WFS.FGCONCLUDEDSTATUS=1 THEN 1 WHEN WFS.FGCONCLUDEDSTATUS=2 THEN 3 END) ELSE (CASE WHEN WFS.FGTYPE=1 THEN (CASE WHEN (( SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST(<!%TODAY%> AS DATETIME)) OR (SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) IS NULL) THEN 1 WHEN (((SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT)=CAST(<!%TODAY%> AS DATETIME) AND (SELECT WFPD.NRTIMEESTFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) >= 483) OR (SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > CAST(<!%TODAY%> AS DATETIME)) THEN 2 ELSE 3 END) ELSE (CASE WHEN (WFS.DTESTIMATEDFINISH > DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST(<!%TODAY%> AS DATETIME)) OR WFS.DTESTIMATEDFINISH IS NULL) THEN 1 WHEN (( WFS.DTESTIMATEDFINISH=CAST(<!%TODAY%> AS DATETIME) AND WFS.NRTIMEESTFINISH >= 483) OR WFS.DTESTIMATEDFINISH > CAST(<!%TODAY%> AS DATETIME)) THEN 2 ELSE 3 END) END) END AS FGDEADLINE, CASE WHEN WFS.FGDURATIONUNIT=1 AND WFS.QTHOURS > 0 THEN CAST(FLOOR(WFS.QTHOURS / 60) AS VARCHAR(20)) + LOWER(' #{101173} ') + CAST(WFS.QTHOURS - (FLOOR(WFS.QTHOURS / 60) * 60) AS VARCHAR(20)) + LOWER(' #{101181}') WHEN WFS.FGDURATIONUNIT=2 THEN CAST(FLOOR(WFS.QTHOURS / (60 * 24)) AS VARCHAR(20)) + LOWER(' #{108037}') WHEN WFS.FGDURATIONUNIT=3 THEN CAST(FLOOR(WFS.QTHOURS / (60 * 24 * 7)) AS VARCHAR(20)) + LOWER(' #{101581}') WHEN WFS.FGDURATIONUNIT=4 THEN CAST(FLOOR(WFS.QTHOURS / (60 * 24 * 30)) AS VARCHAR(20)) + LOWER(' #{101583}') ELSE NULL END AS WF_QTHOURS, TBDEPTINI.IDDEPARTMENT AS IDDEPTINI, TBDEPTINI.NMDEPARTMENT AS NMDEPTINI, TBDEPTINI.CDDEPARTMENT AS CDDEPTINI, TBDEPTEXEC.IDDEPARTMENT AS IDDEPTEXEC, TBDEPTEXEC.NMDEPARTMENT AS NMDEPTEXEC, TBDEPTEXEC.CDDEPARTMENT AS CDDEPTEXEC, CASE WHEN WFS.FGSTATUS IN (2, 4, 5, 6, 7) THEN (CAST((CONVERT(datetime, SYSDATETIME()) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 2))) WHEN WFS.FGSTATUS=3 THEN (CAST(((WFS.DTEXECUTION+WFS.TMEXECUTION) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 2))) END AS DURATION_WF_DAY, CASE WHEN WFS.FGSTATUS IN (2, 4, 5, 6, 7) THEN (CAST(CAST((CONVERT(datetime, SYSDATETIME()) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 AS NUMERIC(18, 2))) WHEN WFS.FGSTATUS=3 THEN (CAST(CAST(((WFS.DTEXECUTION + WFS.TMEXECUTION) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 AS NUMERIC(18, 2))) END AS DURATION_WF_HOUR, CASE WHEN WFS.FGSTATUS IN (2, 4, 5, 6, 7) THEN (FLOOR(CAST((CONVERT(datetime, SYSDATETIME()) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 * 60)) WHEN WFS.FGSTATUS=3 THEN (FLOOR(CAST(((WFS.DTEXECUTION + WFS.TMEXECUTION) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 * 60)) END AS DURATION_WF_MIN, dateadd(minute, WFS.NRTIMEESTFINISH, WFS.DTESTIMATEDFINISH) AS DTDEADLINEFIELD, dateadd(minute, WFS.NRTIMEEXECUTION, WFS.DTEXECUTION) AS DTEXECUTION FROM WFPROCESS WFP INNER JOIN WFSTRUCT WFS ON (WFP.IDOBJECT=WFS.IDPROCESS) LEFT JOIN ADUSER ADU ON (WFP.CDUSERSTART=ADU.CDUSER) LEFT JOIN (SELECT ADEU.CDEXTERNALUSER, ADEU.NMUSER, ADC.NMCOMPANY FROM ADEXTERNALUSER ADEU INNER JOIN ADCOMPANY ADC ON (ADEU.CDCOMPANY=ADC.CDCOMPANY)) TBEXT ON (WFP.CDEXTERNALUSERSTART=TBEXT.CDEXTERNALUSER) LEFT JOIN GNEVALRESULTUSED GNRUS ON (WFP.CDEVALRSLTPRIORITY=GNRUS.CDEVALRESULTUSED) LEFT JOIN GNEVALRESULT GNR ON (GNRUS.CDEVALRESULT=GNR.CDEVALRESULT) LEFT JOIN INOCCURRENCE INOCCUR ON (WFP.IDOBJECT=INOCCUR.IDWORKFLOW) LEFT JOIN GNGENTYPE GNT ON (INOCCUR.CDOCCURRENCETYPE=GNT.CDGENTYPE) LEFT JOIN PMACTREVISION PMACT ON (( PMACT.CDACTIVITY=WFP.CDPROCESSMODEL AND PMACT.FGCURRENT=1)) LEFT JOIN PMPROCESSLANGUAGE PML ON (( PML.CDPROCESS=PMACT.CDACTIVITY AND PML.CDREVISION=PMACT.CDREVISION AND PML.FGENABLED=1 AND PML.FGLANGUAGE=2)) LEFT JOIN PMELEMENTLANGUAGE PMEL ON (( PMEL.CDSTRUCT=WFS.CDSTRUCTMODEL AND PMEL.FGLANGUAGE=2 AND PML.FGENABLED=1)) LEFT JOIN WFSTRUCTACTION WFSA ON (WFSA.IDOBJECT=WFS.IDEXECUTEDACTION) LEFT JOIN PMACTIONLANGUAGE PMAL ON (( PMAL.CDSTRUCT=WFSA.CDSTRUCTMODEL AND PMAL.CDACTION=WFSA.CDACTIONMODEL AND PMAL.FGLANGUAGE=2 AND PML.FGENABLED=1)) LEFT JOIN (SELECT ADDEP.CDDEPARTMENT, ADDEP.IDDEPARTMENT, ADDEP.NMDEPARTMENT, ADUDP.CDUSER FROM ADUSERDEPTPOS ADUDP INNER JOIN ADDEPARTMENT ADDEP ON (ADUDP.CDDEPARTMENT=ADDEP.CDDEPARTMENT) WHERE ADUDP.FGDEFAULTDEPTPOS=1) TBDEPTINI ON (TBDEPTINI.CDUSER=WFP.CDUSERSTART) LEFT JOIN (SELECT ADDEP.CDDEPARTMENT, ADDEP.IDDEPARTMENT, ADDEP.NMDEPARTMENT, ADUDP.CDUSER FROM ADUSERDEPTPOS ADUDP INNER JOIN ADDEPARTMENT ADDEP ON (ADUDP.CDDEPARTMENT=ADDEP.CDDEPARTMENT) WHERE ADUDP.FGDEFAULTDEPTPOS=1) TBDEPTEXEC ON (TBDEPTEXEC.CDUSER=WFS.CDUSER) INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON (WF.CDTEAM=TM.CDTEAM) WHERE (WF.FGACCESSTYPE=1 AND TM.CDUSER=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON (WF.CDDEPARTMENT=UDP.CDDEPARTMENT) WHERE (WF.FGACCESSTYPE=2 AND UDP.CDUSER=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON (WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION) WHERE (WF.FGACCESSTYPE=3 AND UDP.CDUSER=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON (WF.CDPOSITION=UDP.CDPOSITION) WHERE (WF.FGACCESSTYPE=4 AND UDP.CDUSER=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE (WF.FGACCESSTYPE=5 AND WF.CDUSER=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE (WF.FGACCESSTYPE=6 AND US.CDUSER=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON (WF.CDROLE=RL.CDROLE) WHERE (WF.FGACCESSTYPE=7 AND RL.CDUSER=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON (WF.IDPROCESS=WFP.IDOBJECT) WHERE (WF.FGACCESSTYPE=30 AND WFP.CDUSERSTART=17260 AND WF.FGACCESSEXCEPTION IS NULL) UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON (WF.IDPROCESS=WFP.IDOBJECT) INNER JOIN ADUSER US ON (WFP.CDUSERSTART=US.CDUSER) WHERE (WF.FGACCESSTYPE=31 AND US.CDLEADER=17260 AND WF.FGACCESSEXCEPTION IS NULL)) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON (PERM.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM.IDPROCESS=GNASSOC.IDPROCESS) WHERE (GNASSOC.CDACCESSROLEFIELD IN (501)) GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON (AUXWFP.IDOBJECT=PERMISSION.IDPROCESS) WHERE (PERMISSION.FGPERMISSION=1 AND AUXWFP.FGSTATUS <= 5 AND (AUXWFP.FGMODELWFSECURITY IS NULL OR AUXWFP.FGMODELWFSECURITY=0)) UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON (PP.CDTEAM=TM.CDTEAM) WHERE (PP.FGACCESSTYPE=1 AND TM.CDUSER=17260) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT) WHERE (PP.FGACCESSTYPE=2 AND UDP.CDUSER=17260) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION) WHERE (PP.FGACCESSTYPE=3 AND UDP.CDUSER=17260) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDPOSITION=UDP.CDPOSITION) WHERE (PP.FGACCESSTYPE=4 AND UDP.CDUSER=17260) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE (PP.FGACCESSTYPE=5 AND PP.CDUSER=17260) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE (PP.FGACCESSTYPE=6 AND US.CDUSER=17260) UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON (PP.CDROLE=RL.CDROLE) WHERE (PP.FGACCESSTYPE=7 AND RL.CDUSER=17260)) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY OBJ ON (GNASSOC.CDPROC=OBJ.CDACTIVITY) INNER JOIN WFPROCESS WFP ON (PERM1.CDPROC=WFP.CDPROCESSMODEL) WHERE (GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) UNION ALL SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON (PP.CDPROC=WFP.CDPROCESSMODEL) WHERE (PP.FGACCESSTYPE=30 AND WFP.CDUSERSTART=17260 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) UNION ALL SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON (PP.CDPROC=WFP.CDPROCESSMODEL) INNER JOIN ADUSER US ON (WFP.CDUSERSTART=US.CDUSER) WHERE (PP.FGACCESSTYPE=31 AND US.CDLEADER=17260 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5)) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY OBJ ON (GNASSOC.CDPROC=OBJ.CDACTIVITY) WHERE (GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL))) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T WHERE (T.FGPERMISSION=1) UNION ALL SELECT PERM.IDOBJECT FROM (SELECT WFP.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON (PM.CDTEAM=TM.CDTEAM) WHERE (PM.FGACCESSTYPE=1 AND TM.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON (PM.CDDEPARTMENT=UDP.CDDEPARTMENT) WHERE (PM.FGACCESSTYPE=2 AND UDP.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON (PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION) WHERE (PM.FGACCESSTYPE=3 AND UDP.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON (PM.CDPOSITION=UDP.CDPOSITION) WHERE (PM.FGACCESSTYPE=4 AND UDP.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM WHERE (PM.FGACCESSTYPE=5 AND PM.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM WHERE (PM.FGACCESSTYPE=6) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON (PM.CDROLE=RL.CDROLE) WHERE (PM.FGACCESSTYPE=7 AND RL.CDUSER=17260)) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON (GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY PMA ON (PERM1.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) WHERE (GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1) UNION ALL SELECT WFP.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) WHERE (PM.FGACCESSTYPE=8 AND PMA.CDCREATEDBY=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSERDEPTPOS DEP1 ON (PMA.CDCREATEDBY=DEP1.CDUSER) INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP1.CDDEPARTMENT=DEP2.CDDEPARTMENT) WHERE (PM.FGACCESSTYPE=9 AND DEP2.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSERDEPTPOS DEP1 ON (PMA.CDCREATEDBY=DEP1.CDUSER) INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP1.CDDEPARTMENT=DEP2.CDDEPARTMENT AND DEP1.CDPOSITION=DEP2.CDPOSITION) WHERE (PM.FGACCESSTYPE=10 AND DEP2.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSERDEPTPOS DEP1 ON (PMA.CDCREATEDBY=DEP1.CDUSER) INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP1.CDPOSITION=DEP2.CDPOSITION) WHERE (PM.FGACCESSTYPE=11 AND DEP2.CDUSER=17260) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN ADUSER US ON (PMA.CDCREATEDBY=US.CDUSER) WHERE (PM.FGACCESSTYPE=12 AND US.CDLEADER=17260)) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON (GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY PMA ON (PERM2.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) WHERE (GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1) UNION ALL SELECT PERM3.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) WHERE (PM.FGACCESSTYPE=30 AND WFP.CDUSERSTART=17260 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON (PM.CDACTTYPE=PMA.CDACTTYPE) INNER JOIN WFPROCESS WFP ON (PMA.CDACTIVITY=WFP.CDPROCESSMODEL) INNER JOIN ADUSER US ON (WFP.CDUSERSTART=US.CDUSER) WHERE (PM.FGACCESSTYPE=31 AND US.CDLEADER=17260 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1)) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON (GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD) INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON (GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD) INNER JOIN PMACTIVITY PMA ON (PERM3.CDACTTYPE=PMA.CDACTTYPE) WHERE (GNCTRL_F.CDRELATEDFIELD IN (501) AND PMA.FGUSETYPEACCESS=1)) PERM UNION ALL SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN WFPROCSECURITYLIST WFLIST ON (AUXWFP.IDOBJECT=WFLIST.IDPROCESS) INNER JOIN WFPROCSECURITYCTRL WFCTRL ON (WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS) WHERE (WFCTRL.CDACCESSROLEFIELD IN (501) AND WFLIST.CDUSER=17260 AND WFLIST.FGACCESSTYPE=5 AND WFLIST.FGACCESSEXCEPTION=1 AND WFLIST.FGPERMISSION=1 AND AUXWFP.FGSTATUS <= 5)) Z) MYPERM ON (WFP.IDOBJECT=MYPERM.IDOBJECT) WHERE (WFS.FGTYPE IN (2,3) AND WFP.CDPRODAUTOMATION=160 AND WFS.FGTYPE IN (2, 3) AND WFS.FGSTATUS IN (2, 3) AND WFP.FGSTATUS <= 5 AND (GNT.CDTYPEROLE IS NULL OR EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.CDTYPEROLE=GNT.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=17260 OR 17260=-1))) AND GNT.CDGENTYPE IN (222))) TEMPTB0) TEMPTB1