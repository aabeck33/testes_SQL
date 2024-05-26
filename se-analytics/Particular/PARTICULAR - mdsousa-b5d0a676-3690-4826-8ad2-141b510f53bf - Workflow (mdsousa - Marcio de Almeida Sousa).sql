SELECT IDPROCESS,DTDEADLINEFIELD,NMPROCESS,WF_QTHOURS,TYPEUSER,FGTYPEUSER,NMEVALRESULT,NMUSERSTART,NMROLE,NMSTRUCT,IDSITUATION,FGSTATUS,NMEXECUTEDACTION,NMPROCESSMODEL,DTEXECUTION,NMOCCURRENCETYPE,TYPEUSEREXEC,FGTYPEUSEREXEC,DURATION_WF_DAY,NMUSER,FGUSER,IDDEPTINI,NMDEPTINI,IDDEPTEXEC,NMDEPTEXEC,DURATION_WF_HOUR,NMDEADLINE,FGDEADLINE,DURATION_WF_MIN FROM (SELECT IDPROCESS,DTDEADLINEFIELD,NMPROCESS,WF_QTHOURS,TYPEUSER,FGTYPEUSER,NMEVALRESULT,NMUSERSTART,NMROLE,NMSTRUCT,IDSITUATION,FGSTATUS,NMEXECUTEDACTION,NMPROCESSMODEL,DTEXECUTION,NMOCCURRENCETYPE,TYPEUSEREXEC,FGTYPEUSEREXEC,DURATION_WF_DAY,NMUSER,FGUSER,IDDEPTINI,NMDEPTINI,IDDEPTEXEC,NMDEPTEXEC,DURATION_WF_HOUR,NMDEADLINE,FGDEADLINE,DURATION_WF_MIN FROM (SELECT 1 AS QTD, WFP.IDPROCESS, WFP.NMPROCESS, WFP.NMPROCESSMODEL, WFP.NMUSERSTART, (SELECT GNT.NMGENTYPE FROM GNGENTYPE GNT WHERE WFP.CDWORKFLOWTYPE=GNT.CDGENTYPE) AS NMOCCURRENCETYPE, GNR.NMEVALRESULT, WFS.NMSTRUCT, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN '#{303826}' WHEN WFP.CDUSERSTART IS NOT NULL THEN '#{305843}' ELSE NULL END AS TYPEUSER, CASE WHEN WFP.CDEXTERNALUSERSTART IS NOT NULL THEN 2 WHEN WFP.CDUSERSTART IS NOT NULL THEN 1 ELSE NULL END AS FGTYPEUSER, WFS.NMROLE, CASE WHEN WFS.FGSTATUS=1 THEN '#{114667}' WHEN WFS.FGSTATUS=2 THEN '#{114666}' WHEN WFS.FGSTATUS=3 THEN '#{107507}' WHEN WFS.FGSTATUS=4 THEN '#{108240}' WHEN WFS.FGSTATUS=5 THEN '#{102338}' WHEN WFS.FGSTATUS=6 THEN '#{206049}' WHEN WFS.FGSTATUS=7 THEN '#{214511}' END AS IDSITUATION, WFS.FGSTATUS AS FGSTATUS, CASE WHEN WFS.FGACTAUTOEXECUTED=1 THEN '#{102949}' ELSE WFS.NMUSER END AS NMUSER, CASE WHEN WFS.FGACTAUTOEXECUTED=1 THEN -1 ELSE WFS.CDUSER END AS FGUSER, CASE WHEN WFS.CDEXTERNALUSER IS NOT NULL THEN '#{303826}' WHEN WFS.CDUSER IS NOT NULL AND WFS.NMUSER IS NOT NULL THEN '#{305843}' ELSE NULL END AS TYPEUSEREXEC, CASE WHEN WFS.CDEXTERNALUSER IS NOT NULL THEN 2 WHEN WFS.CDUSER IS NOT NULL AND WFS.NMUSER IS NOT NULL THEN 1 ELSE NULL END AS FGTYPEUSEREXEC, WFS.NMEXECUTEDACTION, CASE WHEN WFS.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN WFS.FGCONCLUDEDSTATUS=1 THEN '#{100900}' WHEN WFS.FGCONCLUDEDSTATUS=2 THEN '#{100899}' END) ELSE (CASE WHEN WFS.FGTYPE=1 THEN (CASE WHEN (((SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > (DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME)))) OR (( SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) IS NULL)) THEN '#{100900}' WHEN (((SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT)=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND (SELECT WFPD.NRTIMEESTFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (( SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME))) THEN '#{201639}' ELSE '#{100899}' END) ELSE (CASE WHEN (( WFS.DTESTIMATEDFINISH > (DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST(<!%TODAY%> AS DATETIME)))) OR (WFS.DTESTIMATEDFINISH IS NULL)) THEN '#{100900}' WHEN (( WFS.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND WFS.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (WFS.DTESTIMATEDFINISH > CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME))) THEN '#{201639}' ELSE '#{100899}' END) END) END AS NMDEADLINE, CASE WHEN WFS.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN WFS.FGCONCLUDEDSTATUS=1 THEN 1 WHEN WFS.FGCONCLUDEDSTATUS=2 THEN 3 END) ELSE (CASE WHEN WFS.FGTYPE=1 THEN (CASE WHEN (((SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > (DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME)))) OR (( SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) IS NULL)) THEN 1 WHEN (((SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT)=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND (SELECT WFPD.NRTIMEESTFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (( SELECT WFPD.DTESTIMATEDFINISH FROM WFSTRUCT STRUCT INNER JOIN WFSUBPROCESS SUB ON STRUCT.IDOBJECT=SUB.IDOBJECT INNER JOIN WFPROCESS WFPD ON WFPD.IDOBJECT=SUB.IDSUBPROCESS WHERE STRUCT.IDOBJECT=WFS.IDOBJECT) > CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME))) THEN 2 ELSE 3 END) ELSE (CASE WHEN (( WFS.DTESTIMATEDFINISH > (DATEADD(DAY, COALESCE((SELECT QTDAYS FROM ADMAILTASKEXEC WHERE CDMAILTASKEXEC=(SELECT TASK.CDAHEAD FROM ADMAILTASKREL TASK WHERE TASK.CDMAILTASKREL=(SELECT TBL.CDMAILTASKSETTINGS FROM CONOTIFICATION TBL))), 0), CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME)))) OR (WFS.DTESTIMATEDFINISH IS NULL)) THEN 1 WHEN (( WFS.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND WFS.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (WFS.DTESTIMATEDFINISH > CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME))) THEN 2 ELSE 3 END) END) END AS FGDEADLINE, TBDEPTINI.IDDEPARTMENT AS IDDEPTINI, TBDEPTINI.NMDEPARTMENT AS NMDEPTINI, TBDEPTEXEC.IDDEPARTMENT AS IDDEPTEXEC, TBDEPTEXEC.NMDEPARTMENT AS NMDEPTEXEC, CASE WHEN WFS.FGDURATIONUNIT=1 AND WFS.QTHOURS > 0 THEN CAST(FLOOR(WFS.QTHOURS / 60) AS VARCHAR(20)) + LOWER(' #{101173} ') + CAST(WFS.QTHOURS - (FLOOR(WFS.QTHOURS / 60) * 60) AS VARCHAR(20)) + LOWER(' #{101181}') WHEN WFS.FGDURATIONUNIT=2 THEN CAST(FLOOR(WFS.QTHOURS / (60 * 24)) AS VARCHAR(20)) + LOWER(' #{108037}') WHEN WFS.FGDURATIONUNIT=3 THEN CAST(FLOOR(WFS.QTHOURS / (60 * 24 * 7)) AS VARCHAR(20)) + LOWER(' #{101581}') WHEN WFS.FGDURATIONUNIT=4 THEN CAST(FLOOR(WFS.QTHOURS / (60 * 24 * 30)) AS VARCHAR(20)) + LOWER(' #{101583}') ELSE NULL END AS WF_QTHOURS, CASE WHEN WFS.FGSTATUS IN (2, 4, 5, 6, 7) THEN (CAST((CONVERT(datetime, SYSDATETIME()) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 2))) WHEN WFS.FGSTATUS=3 THEN (CAST(((WFS.DTEXECUTION + WFS.TMEXECUTION) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 2))) END AS DURATION_WF_DAY, CASE WHEN WFS.FGSTATUS IN (2, 4, 5, 6, 7) THEN (CAST(CAST((CONVERT(datetime, SYSDATETIME()) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 AS NUMERIC(18, 2))) WHEN WFS.FGSTATUS=3 THEN (CAST(CAST(((WFS.DTEXECUTION + WFS.TMEXECUTION) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 AS NUMERIC(18, 2))) END AS DURATION_WF_HOUR, CASE WHEN WFS.FGSTATUS IN (2, 4, 5, 6, 7) THEN (FLOOR(CAST((CONVERT(datetime, SYSDATETIME()) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 * 60)) WHEN WFS.FGSTATUS=3 THEN (FLOOR(CAST(((WFS.DTEXECUTION + WFS.TMEXECUTION) - (WFS.DTENABLED + WFS.TMENABLED)) AS NUMERIC(18, 8)) * 24 * 60)) END AS DURATION_WF_MIN, dateadd(minute, WFS.NRTIMEESTFINISH, WFS.DTESTIMATEDFINISH) AS DTDEADLINEFIELD, dateadd(minute, WFS.NRTIMEEXECUTION, WFS.DTEXECUTION) AS DTEXECUTION FROM WFPROCESS WFP INNER JOIN WFSTRUCT WFS ON (WFP.IDOBJECT=WFS.IDPROCESS) LEFT OUTER JOIN GNEVALRESULTUSED GNRUS ON (WFP.CDEVALRSLTPRIORITY=GNRUS.CDEVALRESULTUSED) LEFT OUTER JOIN GNEVALRESULT GNR ON (GNRUS.CDEVALRESULT=GNR.CDEVALRESULT) LEFT OUTER JOIN (SELECT ADDEPARTMENT.IDDEPARTMENT, ADDEPARTMENT.NMDEPARTMENT, ADUSERDEPTPOS.CDUSER FROM ADUSERDEPTPOS INNER JOIN ADDEPARTMENT ON ADUSERDEPTPOS.CDDEPARTMENT=ADDEPARTMENT.CDDEPARTMENT WHERE ADUSERDEPTPOS.FGDEFAULTDEPTPOS=1) TBDEPTINI ON (TBDEPTINI.CDUSER=WFP.CDUSERSTART) LEFT OUTER JOIN (SELECT ADDEPARTMENT.IDDEPARTMENT, ADDEPARTMENT.NMDEPARTMENT, ADUSERDEPTPOS.CDUSER FROM ADUSERDEPTPOS INNER JOIN ADDEPARTMENT ON ADUSERDEPTPOS.CDDEPARTMENT=ADDEPARTMENT.CDDEPARTMENT WHERE ADUSERDEPTPOS.FGDEFAULTDEPTPOS=1) TBDEPTEXEC ON (TBDEPTEXEC.CDUSER=WFS.CDUSER) INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON WF.CDTEAM=TM.CDTEAM WHERE WF.FGACCESSTYPE=1 AND TM.CDUSER=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE WF.FGACCESSTYPE=2 AND UDP.CDUSER=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=3 AND UDP.CDUSER=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=4 AND UDP.CDUSER=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE WF.FGACCESSTYPE=5 AND WF.CDUSER=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE WF.FGACCESSTYPE=6 AND US.CDUSER=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON RL.CDROLE=WF.CDROLE WHERE WF.FGACCESSTYPE=7 AND RL.CDUSER=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS WHERE WF.FGACCESSTYPE=30 AND WFP.CDUSERSTART=26 AND WF.FGACCESSEXCEPTION IS NULL UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE WF.FGACCESSTYPE=31 AND US.CDLEADER=26 AND WF.FGACCESSEXCEPTION IS NULL) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON (GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST AND GNASSOC.IDPROCESS=PERM.IDPROCESS) WHERE GNASSOC.CDACCESSROLEFIELD IN (501) GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON PERMISSION.IDPROCESS=AUXWFP.IDOBJECT WHERE PERMISSION.FGPERMISSION=1 AND AUXWFP.FGSTATUS <= 5 AND (AUXWFP.FGMODELWFSECURITY IS NULL OR AUXWFP.FGMODELWFSECURITY=0) UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE PP.FGACCESSTYPE=1 AND TM.CDUSER=26 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PP.FGACCESSTYPE=2 AND UDP.CDUSER=26 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION) WHERE PP.FGACCESSTYPE=3 AND UDP.CDUSER=26 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE PP.FGACCESSTYPE=4 AND UDP.CDUSER=26 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE PP.FGACCESSTYPE=5 AND PP.CDUSER=26 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE PP.FGACCESSTYPE=6 AND US.CDUSER=26 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE PP.FGACCESSTYPE=7 AND RL.CDUSER=26) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE PP.FGACCESSTYPE=30 AND WFP.CDUSERSTART=26 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PP.FGACCESSTYPE=31 AND US.CDLEADER=26 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T WHERE T.FGPERMISSION=1 UNION ALL SELECT PERM.IDOBJECT FROM (SELECT WFP.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE PM.FGACCESSTYPE=1 AND TM.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PM.FGACCESSTYPE=2 AND UDP.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=3 AND UDP.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=4 AND UDP.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM WHERE PM.FGACCESSTYPE=5 AND PM.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM WHERE PM.FGACCESSTYPE=6 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE PM.FGACCESSTYPE=7 AND RL.CDUSER=26) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT WFP.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE PM.FGACCESSTYPE=8 AND PMA.CDCREATEDBY=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE PM.FGACCESSTYPE=9 AND DEP2.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION) WHERE PM.FGACCESSTYPE=10 AND DEP2.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE PM.FGACCESSTYPE=11 AND DEP2.CDUSER=26 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE PM.FGACCESSTYPE=12 AND US.CDLEADER=26) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PERM3.IDOBJECT FROM (SELECT PM.CDACTTYPE, PM.CDACCESSLIST, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE PM.FGACCESSTYPE=30 AND WFP.CDUSERSTART=26 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PM.CDACTTYPE, PM.CDACCESSLIST, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PM.FGACCESSTYPE=31 AND US.CDLEADER=26 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND PMA.FGUSETYPEACCESS=1) PERM UNION ALL SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN WFPROCSECURITYLIST WFLIST ON (AUXWFP.IDOBJECT=WFLIST.IDPROCESS) INNER JOIN WFPROCSECURITYCTRL WFCTRL ON (WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS) WHERE WFCTRL.CDACCESSROLEFIELD IN (501) AND WFLIST.CDUSER=26 AND WFLIST.FGACCESSTYPE=5 AND WFLIST.FGACCESSEXCEPTION=1 AND WFLIST.FGPERMISSION=1 AND AUXWFP.FGSTATUS <= 5) Z) MYPERM ON (WFP.IDOBJECT=MYPERM.IDOBJECT) WHERE (WFP.CDPRODAUTOMATION NOT IN (160, 202, 275) AND WFS.FGTYPE IN (2, 3) AND WFS.FGSTATUS IN (2, 3)) AND WFP.FGSTATUS <= 5 AND (EXISTS( SELECT 1 FROM DYNITSM FRMFILTER1 WHERE FRMFILTER1.OID IN (SELECT AREG.OIDENTITYREG FROM GNASSOCFORMREG AREG WHERE AREG.CDASSOC=WFP.CDASSOCREG) AND ((FRMFILTER1.ITSM035 LIKE '%SAPMM%'))))) TEMPTB0) TEMPTB1