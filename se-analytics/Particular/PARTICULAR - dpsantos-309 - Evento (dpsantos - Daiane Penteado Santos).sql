SELECT ID_PROCESS,NMPROCESS,QTD_BI,IDSLASTATUS,DTSTART,NMUSERSTART,NMEVALRESULT,NMOCCURRENCETYPE,NMDEADLINE,IDSITUATION,NMREVISIONSTATUS,IDREVISIONSTATUS,DTDEADLINEFIELD,DTFINISH,DTSLAFINISH,TDS038TDS012,TDS038TDS013,TDS038TDS001,TDS038TDS002,TDS038TDS003,TDS038TDS004,TDS038TDS005,TDS038TDS006,TDS038TDS007,TDS038TDS008,TDS038TDS009,TDS038TDS010,TDS038TDS011 FROM (SELECT ID_PROCESS,NMPROCESS,QTD_BI,IDSLASTATUS,DTSTART,NMUSERSTART,NMEVALRESULT,NMOCCURRENCETYPE,NMDEADLINE,IDSITUATION,NMREVISIONSTATUS,IDREVISIONSTATUS,DTDEADLINEFIELD,DTFINISH,DTSLAFINISH,TDS038TDS012,TDS038TDS013,TDS038TDS001,TDS038TDS002,TDS038TDS003,TDS038TDS004,TDS038TDS005,TDS038TDS006,TDS038TDS007,TDS038TDS008,TDS038TDS009,TDS038TDS010,TDS038TDS011 FROM (SELECT CAST(ENT01.tds012 AS TEXT) AS TDS038TDS012, ENT01.tds013 AS TDS038TDS013, ENT01.tds001 AS TDS038TDS001, ENT01.tds002 AS TDS038TDS002, ENT01.tds003 AS TDS038TDS003, ENT01.tds004 AS TDS038TDS004, ENT01.tds005 AS TDS038TDS005, CAST(ENT01.tds006 AS TEXT) AS TDS038TDS006, CAST(ENT01.tds007 AS TEXT) AS TDS038TDS007, CAST(ENT01.tds008 AS TEXT) AS TDS038TDS008, CAST(ENT01.tds009 AS TEXT) AS TDS038TDS009, CAST(ENT01.tds010 AS TEXT) AS TDS038TDS010, ENT01.tds011 AS TDS038TDS011, 1 AS QTD_BI, P.IDOBJECT, P.IDPROCESS AS ID_PROCESS, P.NMPROCESS, P.CDPROCESSMODEL, P.CDREVISION, P.IDPROCESSMODEL, P.NMPROCESSMODEL, P.FGSTATUS AS FGSTATUS,CONVERT(DATETIME, P.DTSTART + ' ' + P.TMSTART, 120) AS DTSTART,CONVERT(DATETIME, P.DTFINISH + ' ' + P.TMFINISH, 120) AS DTFINISH,SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(SLACTRL.BNSLAFINISH AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-02:00') AS DTSLAFINISH, P.TMSTART, P.TMFINISH, P.CDUSERSTART, ADU.NMUSER AS NMUSERSTART, P.CDFAVORITE, P.FGSLASTATUS, CASE P.FGSTATUS WHEN 1 THEN 'Andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edi��o' END AS IDSITUATION, CASE P.FGSLASTATUS WHEN 10 THEN 'Play' WHEN 30 THEN 'Pause' WHEN 40 THEN 'Stop' END AS IDSLASTATUS, CASE WHEN P.VLTIMEFINISH IS NULL THEN 9999999999 ELSE P.VLTIMEFINISH END AS VLTIMEFINISH, GREV.IDREVISION, SLACTRL.BNSLAFINISH, PT.CDACTTYPE, PT.IDACTTYPE, PT.NMACTTYPE, PP.NMACTIVITY AS PROCESSMODEL, GNRS.IDREVISIONSTATUS, GNRS.NMREVISIONSTATUS, GNRS.CDREVISIONSTATUS, GNRS.FGLOGO AS FGLOGOREVISIONSTATUS, GNRUS.VLEVALRESULT, GNR.NMEVALRESULT, GNR.FGSYMBOL, CASE WHEN GNR.NRORDER IS NULL THEN -999999999 ELSE GNR.NRORDER END AS NRORDERPRIORITY, dateadd(minute, P.NRTIMEESTFINISH, P.DTESTIMATEDFINISH) AS DTDEADLINEFIELD, P.NRTIMEESTFINISH AS NRHRDEADLINEFIELD, CAST('VLTIMEFINISH' AS VARCHAR(50)) AS NRDEADLINEFIELD_IMG, CAST('VLTIMEFINISH' AS VARCHAR(50)) AS DEADLINEFIELD_DT, (SELECT TOP 1 1 FROM WFPROCDOCUMENT T_QTD_DOC WHERE T_QTD_DOC.IDPROCESS=P.IDOBJECT) AS QTD_DOC, (SELECT TOP 1 1 FROM WFPROCATTACHMENT T_QTD_ATT WHERE T_QTD_ATT.IDPROCESS=P.IDOBJECT AND T_QTD_ATT.CDUSER IS NOT NULL) AS QTD_ATT, ROW_NUMBER() OVER (ORDER/**/ BY P.IDPROCESS ASC) AS ROW_NUM, CASE WHEN P.FGSTATUS IN (1,2,3,5) THEN (CAST(FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))) AS VARCHAR) + ' dia(s) ' + CAST(FLOOR((CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) AS VARCHAR) + ' hora(s) ' + CAST(FLOOR((((CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) - FLOOR((CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24))*60) AS VARCHAR) + ' minuto(s)') WHEN P.FGSTATUS=4 THEN (CAST(FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))) AS VARCHAR) + ' dia(s) ' + CAST(FLOOR((CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) AS VARCHAR) + ' hora(s) ' + CAST(FLOOR((((CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) - FLOOR((CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24))*60) AS VARCHAR) + ' minuto(s)') END AS DURATION_WF, CASE WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN P.FGCONCLUDEDSTATUS=1 THEN 1 WHEN P.FGCONCLUDEDSTATUS=2 THEN 3 END) ELSE (CASE WHEN (( P.DTESTIMATEDFINISH > CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME)) OR (P.DTESTIMATEDFINISH IS NULL)) THEN 1 WHEN (( P.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND P.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (P.DTESTIMATEDFINISH=CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME))) THEN 2 ELSE 3 END) END AS FGDEADLINE, CASE WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN P.FGCONCLUDEDSTATUS=1 THEN 1 WHEN P.FGCONCLUDEDSTATUS=2 THEN 3 END) ELSE (CASE WHEN (( P.DTESTIMATEDFINISH > CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME)) OR (P.DTESTIMATEDFINISH IS NULL)) THEN 1 WHEN (( P.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND P.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (P.DTESTIMATEDFINISH=CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME))) THEN 2 ELSE 3 END) END AS FGDEADLINE2, CASE WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN P.FGCONCLUDEDSTATUS=1 THEN 'Em dia' WHEN P.FGCONCLUDEDSTATUS=2 THEN 'Em atraso' END) ELSE (CASE WHEN (( P.DTESTIMATEDFINISH > CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME)) OR (P.DTESTIMATEDFINISH IS NULL)) THEN 'Em dia' WHEN (( P.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND P.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (P.DTESTIMATEDFINISH=CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME))) THEN 'Pr�ximo do vencimento' ELSE 'Em atraso' END) END AS NMDEADLINE ,P.QTHOURS AS QTHOURS, P.FGDURATIONUNIT AS FGDURATIONUNIT, P.CDPROCESS, GNT.IDGENTYPE AS IDOCCURRENCETYPE, GNT.NMGENTYPE AS NMOCCURRENCETYPE, INCID.CDOCCURRENCETYPE AS CDOCCURRENCETYPE, GNT.FGLOGO AS FGLOGOOCCURRENCETYPE FROM WFPROCESS P LEFT OUTER JOIN GNREVISION GREV ON (P.CDREVISION=GREV.CDREVISION) LEFT OUTER JOIN GNSLACONTROL SLACTRL ON (P.CDSLACONTROL=SLACTRL.CDSLACONTROL) LEFT OUTER JOIN ADUSER ADU ON (ADU.CDUSER=P.CDUSERSTART) LEFT OUTER JOIN PMACTIVITY PP ON (PP.CDACTIVITY=P.CDPROCESSMODEL) LEFT OUTER JOIN PMACTTYPE PT ON (PT.CDACTTYPE=PP.CDACTTYPE) LEFT OUTER JOIN GNREVISIONSTATUS GNRS ON (P.CDSTATUS=GNRS.CDREVISIONSTATUS) LEFT OUTER JOIN GNEVALRESULTUSED GNRUS ON (GNRUS.CDEVALRESULTUSED=P.CDEVALRSLTPRIORITY) LEFT OUTER JOIN GNEVALRESULT GNR ON (GNRUS.CDEVALRESULT=GNR.CDEVALRESULT) INNER JOIN INOCCURRENCE INCID ON (P.IDOBJECT=INCID.IDWORKFLOW) LEFT OUTER JOIN GNGENTYPE GNT ON (INCID.CDOCCURRENCETYPE=GNT.CDGENTYPE) INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT P.IDOBJECT FROM WFPROCESS P INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON WF.CDTEAM=TM.CDTEAM WHERE 1=1 AND WF.FGACCESSTYPE=1 AND TM.CDUSER=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND WF.FGACCESSTYPE=2 AND UDP.CDUSER=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND WF.FGACCESSTYPE=3 AND UDP.CDUSER=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND WF.FGACCESSTYPE=4 AND UDP.CDUSER=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE 1=1 AND WF.FGACCESSTYPE=5 AND WF.CDUSER=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE 1=1 AND WF.FGACCESSTYPE=6 AND US.CDUSER=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON RL.CDROLE=WF.CDROLE WHERE 1=1 AND WF.FGACCESSTYPE=7 AND RL.CDUSER=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS WHERE 1=1 AND WF.FGACCESSTYPE=30 AND WFP.CDUSERSTART=872 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND WF.FGACCESSTYPE=31 AND US.CDLEADER=872) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST AND GNASSOC.IDPROCESS=PERM.IDPROCESS WHERE 1=1 AND GNASSOC.CDACCESSROLEFIELD=501 GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON PERMISSION.IDPROCESS=P.IDOBJECT INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=P.IDOBJECT WHERE 1=1 AND PERMISSION.FGPERMISSION=1 AND P.FGSTATUS <= 5 AND (P.FGMODELWFSECURITY IS NULL OR P.FGMODELWFSECURITY=0) AND INCID.FGOCCURRENCETYPE=1 UNION ALL SELECT T.IDOBJECT FROM (SELECT PERM.IDOBJECT, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM1.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE 1=1 AND PM.FGACCESSTYPE=1 AND TM.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND PM.FGACCESSTYPE=2 AND UDP.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=3 AND UDP.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=4 AND UDP.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM WHERE 1=1 AND PM.FGACCESSTYPE=5 AND PM.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.FGACCESSTYPE=6 AND US.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE 1=1 AND PM.FGACCESSTYPE=7 AND RL.CDUSER=872) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM2.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PMA.CDCREATEDBY AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE 1=1 AND PM.FGACCESSTYPE=8 AND PMA.CDCREATEDBY=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE 1=1 AND PM.FGACCESSTYPE=9 AND DEP2.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=10 AND DEP2.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=11 AND DEP2.CDUSER=872 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE 1=1 AND PM.FGACCESSTYPE=12 AND US.CDLEADER=872) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PERM3.IDOBJECT, PMA.FGUSETYPEACCESS, PERM3.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, WFP.CDUSERSTART AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND PM.FGACCESSTYPE=30 AND WFP.CDUSERSTART=872 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND PM.FGACCESSTYPE=31 AND US.CDLEADER=872 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND PMA.FGUSETYPEACCESS=1) PERM WHERE 1=1 GROUP BY PERM.IDOBJECT) T INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=T.IDOBJECT WHERE 1=1 AND T.FGPERMISSION=1 AND INCID.FGOCCURRENCETYPE=1 UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE 1=1 AND PP.FGACCESSTYPE=1 AND TM.CDUSER=872 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND PP.FGACCESSTYPE=2 AND UDP.CDUSER=872 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PP.FGACCESSTYPE=3 AND UDP.CDUSER=872 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PP.FGACCESSTYPE=4 AND UDP.CDUSER=872 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE 1=1 AND PP.FGACCESSTYPE=5 AND PP.CDUSER=872 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE 1=1 AND PP.FGACCESSTYPE=6 AND US.CDUSER=872 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE 1=1 AND PP.FGACCESSTYPE=7 AND RL.CDUSER=872) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE 1=1 AND GNCTRL.CDRELATEDFIELD=501 AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE 1=1 AND PP.FGACCESSTYPE=30 AND WFP.CDUSERSTART=872 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND PP.FGACCESSTYPE=31 AND US.CDLEADER=872 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE 1=1 AND GNCTRL.CDRELATEDFIELD=501 AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=T.IDOBJECT WHERE 1=1 AND T.FGPERMISSION=1 AND INCID.FGOCCURRENCETYPE=1) Z WHERE 1=1) MYPERM ON (P.IDOBJECT=MYPERM.IDOBJECT) LEFT OUTER JOIN (SELECT DYNtds038.*, GNASSOCFORMREG.CDASSOC FROM GNASSOCFORMREG INNER JOIN DYNtds038 ON (DYNtds038.OID=GNASSOCFORMREG.OIDENTITYREG)) ENT01 ON (ENT01.CDASSOC=P.CDASSOCREG) WHERE 1=1 AND GNT.cdgentype IN (<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, R05HRU5UWVBF, Y2RnZW50eXBl, Y2RnZW50eXBlb3duZXI=, ,OTE=)%>) AND P.FGSTATUS <= 5 AND INCID.FGOCCURRENCETYPE=1 AND (GNT.CDTYPEROLE IS NULL OR EXISTS (SELECT 1 FROM (SELECT MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE) AS FGACCESSLIST, CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM, ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.FGACCESSLIST=1 AND CHKPERMTYPEROLE.CDTYPEROLE=GNT.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=872 OR 872=-1)))) TEMPTB0) TEMPTB1