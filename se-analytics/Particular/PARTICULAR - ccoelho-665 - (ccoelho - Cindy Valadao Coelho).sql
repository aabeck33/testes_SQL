SELECT ID_PROCESS,NMPROCESS,QTD_BI,IDSLASTATUS,DTSTART,NMUSERSTART,NMEVALRESULT,NMOCCURRENCETYPE,NMDEADLINE,IDSITUATION,NMREVISIONSTATUS,IDREVISIONSTATUS,DTDEADLINEFIELD,DTFINISH,DTSLAFINISH,TDS010TDS073,TDS010TDS074,TDS010TDS075,TDS010TDS076,TDS010TDS077,TDS010TDS078,TDS010TDS079,TDS010TDS080,TDS010TDS081,TDS010TDS082,TDS010TDS083,TDS010TDS084,TDS010TDS085,TDS010TDS086,TDS010TDS087,TDS010TDS088,TDS010TDS089,TDS010TDS090,TDS010TDS091,TDS010TDS093,TDS010TDS092,TDS010TDS094,TDS010TDS095,TDS010TDS096,TDS010TDS097,TDS010TDS098,TDS010TDS099,TDS010TDS100,TDS010TDS101,TDS010TDS0102,TDS010TDS103,TDS010TDS104,TDS010TDS102,TDS010TDS105,TDS010TDS0106,TDS010TDS106,TDS010TDS001,TDS010TDS002,TDS010TDS003,TDS010TDS004,TDS010TDS005,TDS010TDS006,TDS010TDS007,TDS010TDS008,TDS010TDS009,TDS010TDS010,TDS010TDS011,TDS010TDS012,TDS010TDS013,TDS010TDS014,TDS010TDS015,TDS010TDS016,TDS010TDS017,TDS010TDS018,TDS010TDS019,TDS010TDS020,TDS010TDS021,TDS010TDS022,TDS010TDS023,TDS010TDS024,TDS010TDS025,TDS010TDS026,TDS010TDS027,TDS010TDS028,TDS010TDS029,TDS010TDS030,TDS010TDS031,TDS010TDS032,TDS010TDS033,TDS010TDS034,TDS010TDS035,TDS010TDS036,TDS010TDS037,TDS010TDS038,TDS010TDS039,TDS010TDS040,TDS010TDS041,TDS010TDS042,TDS010TDS043,TDS010TDS044,TDS010TDS045,TDS010TDS046,TDS010TDS047,TDS010TDS048,TDS010TDS049,TDS010TDS050,TDS010TDS051,TDS010TDS052,TDS010TDS053,TDS010TDS054,TDS010TDS055,TDS010TDS056,TDS010TDS057,TDS010TDS058,TDS010TDS059,TDS010TDS060,TDS010TDS061,TDS010TDS062,TDS010TDS063,TDS010TDS064,TDS010TDS065,TDS010TDS066,TDS010TDS067,TDS010TDS068,TDS010TDS069,TDS010TDS070,TDS010TDS071,TDS010TDS072 FROM (SELECT ID_PROCESS,NMPROCESS,QTD_BI,IDSLASTATUS,DTSTART,NMUSERSTART,NMEVALRESULT,NMOCCURRENCETYPE,NMDEADLINE,IDSITUATION,NMREVISIONSTATUS,IDREVISIONSTATUS,DTDEADLINEFIELD,DTFINISH,DTSLAFINISH,TDS010TDS073,TDS010TDS074,TDS010TDS075,TDS010TDS076,TDS010TDS077,TDS010TDS078,TDS010TDS079,TDS010TDS080,TDS010TDS081,TDS010TDS082,TDS010TDS083,TDS010TDS084,TDS010TDS085,TDS010TDS086,TDS010TDS087,TDS010TDS088,TDS010TDS089,TDS010TDS090,TDS010TDS091,TDS010TDS093,TDS010TDS092,TDS010TDS094,TDS010TDS095,TDS010TDS096,TDS010TDS097,TDS010TDS098,TDS010TDS099,TDS010TDS100,TDS010TDS101,TDS010TDS0102,TDS010TDS103,TDS010TDS104,TDS010TDS102,TDS010TDS105,TDS010TDS0106,TDS010TDS106,TDS010TDS001,TDS010TDS002,TDS010TDS003,TDS010TDS004,TDS010TDS005,TDS010TDS006,TDS010TDS007,TDS010TDS008,TDS010TDS009,TDS010TDS010,TDS010TDS011,TDS010TDS012,TDS010TDS013,TDS010TDS014,TDS010TDS015,TDS010TDS016,TDS010TDS017,TDS010TDS018,TDS010TDS019,TDS010TDS020,TDS010TDS021,TDS010TDS022,TDS010TDS023,TDS010TDS024,TDS010TDS025,TDS010TDS026,TDS010TDS027,TDS010TDS028,TDS010TDS029,TDS010TDS030,TDS010TDS031,TDS010TDS032,TDS010TDS033,TDS010TDS034,TDS010TDS035,TDS010TDS036,TDS010TDS037,TDS010TDS038,TDS010TDS039,TDS010TDS040,TDS010TDS041,TDS010TDS042,TDS010TDS043,TDS010TDS044,TDS010TDS045,TDS010TDS046,TDS010TDS047,TDS010TDS048,TDS010TDS049,TDS010TDS050,TDS010TDS051,TDS010TDS052,TDS010TDS053,TDS010TDS054,TDS010TDS055,TDS010TDS056,TDS010TDS057,TDS010TDS058,TDS010TDS059,TDS010TDS060,TDS010TDS061,TDS010TDS062,TDS010TDS063,TDS010TDS064,TDS010TDS065,TDS010TDS066,TDS010TDS067,TDS010TDS068,TDS010TDS069,TDS010TDS070,TDS010TDS071,TDS010TDS072 FROM (SELECT CAST(ENT01.tds073 AS TEXT) AS TDS010TDS073, ENT01.tds074 AS TDS010TDS074, CAST(ENT01.tds075 AS TEXT) AS TDS010TDS075, ENT01.tds076 AS TDS010TDS076, CASE WHEN ENT01.tds077=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS077, CASE WHEN ENT01.tds078=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS078, CASE WHEN ENT01.tds079=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS079, CASE WHEN ENT01.tds080=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS080, CASE WHEN ENT01.tds081=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS081, CASE WHEN ENT01.tds082=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS082, CASE WHEN ENT01.tds083=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS083, CASE WHEN ENT01.tds084=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS084, CASE WHEN ENT01.tds085=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS085, CASE WHEN ENT01.tds086=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS086, CASE WHEN ENT01.tds087=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS087, CASE WHEN ENT01.tds088=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS088, CASE WHEN ENT01.tds089=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS089, CASE WHEN ENT01.tds090=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS090, CASE WHEN ENT01.tds091=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS091, CASE WHEN ENT01.tds093=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS093, CASE WHEN ENT01.tds092=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS092, CASE WHEN ENT01.tds094=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS094, CASE WHEN ENT01.tds095=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS095, CASE WHEN ENT01.tds096=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS096, CASE WHEN ENT01.tds097=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS097, CASE WHEN ENT01.tds098=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS098, CASE WHEN ENT01.tds099=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS099, CASE WHEN ENT01.tds100=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS100, CASE WHEN ENT01.tds101=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS101, CASE WHEN ENT01.tds0102=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS0102, CASE WHEN ENT01.tds103=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS103, CASE WHEN ENT01.tds104=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS104, CASE WHEN ENT01.tds102=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS102, CAST(ENT01.tds105 AS TEXT) AS TDS010TDS105, CASE WHEN ENT01.tds0106=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS0106, CASE WHEN ENT01.tds106=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS106, ENT01.tds001 AS TDS010TDS001, ENT01.tds002 AS TDS010TDS002, ENT01.tds003 AS TDS010TDS003, CAST(ENT01.tds004 AS TEXT) AS TDS010TDS004, CAST(ENT01.tds005 AS TEXT) AS TDS010TDS005, CASE WHEN ENT01.tds006=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS006, CAST(ENT01.tds007 AS TEXT) AS TDS010TDS007, CAST(ENT01.tds008 AS TEXT) AS TDS010TDS008, ENT01.tds009 AS TDS010TDS009, CAST(ENT01.tds010 AS TEXT) AS TDS010TDS010, CAST(ENT01.tds011 AS TEXT) AS TDS010TDS011, CAST(ENT01.tds012 AS TEXT) AS TDS010TDS012, CAST(ENT01.tds013 AS TEXT) AS TDS010TDS013, CAST(ENT01.tds014 AS TEXT) AS TDS010TDS014, CAST(ENT01.tds015 AS TEXT) AS TDS010TDS015, CAST(ENT01.tds016 AS TEXT) AS TDS010TDS016, ENT01.tds017 AS TDS010TDS017, ENT01.tds018 AS TDS010TDS018, ENT01.tds019 AS TDS010TDS019, ENT01.tds020 AS TDS010TDS020, ENT01.tds021 AS TDS010TDS021, CAST(ENT01.tds022 AS TEXT) AS TDS010TDS022, CAST(ENT01.tds023 AS TEXT) AS TDS010TDS023, CAST(ENT01.tds024 AS TEXT) AS TDS010TDS024, CAST(ENT01.tds025 AS TEXT) AS TDS010TDS025, CASE WHEN ENT01.tds026=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS026, CAST(ENT01.tds027 AS TEXT) AS TDS010TDS027, CAST(ENT01.tds028 AS TEXT) AS TDS010TDS028, CAST(ENT01.tds029 AS TEXT) AS TDS010TDS029, ENT01.tds030 AS TDS010TDS030, ENT01.tds031 AS TDS010TDS031, CAST(ENT01.tds032 AS TEXT) AS TDS010TDS032, CASE WHEN ENT01.tds033=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS033, CAST(ENT01.tds034 AS TEXT) AS TDS010TDS034, CAST(ENT01.tds035 AS TEXT) AS TDS010TDS035, CAST(ENT01.tds036 AS TEXT) AS TDS010TDS036, CAST(ENT01.tds037 AS TEXT) AS TDS010TDS037, CAST(ENT01.tds038 AS TEXT) AS TDS010TDS038, ENT01.tds039 AS TDS010TDS039, CAST(ENT01.tds040 AS TEXT) AS TDS010TDS040, CAST(ENT01.tds041 AS TEXT) AS TDS010TDS041, CASE WHEN ENT01.tds042=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS042, CASE WHEN ENT01.tds043=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS043, ENT01.tds044 AS TDS010TDS044, ENT01.tds045 AS TDS010TDS045, CAST(ENT01.tds046 AS TEXT) AS TDS010TDS046, CAST(ENT01.tds047 AS TEXT) AS TDS010TDS047, ENT01.tds048 AS TDS010TDS048, CAST(ENT01.tds049 AS TEXT) AS TDS010TDS049, CAST(ENT01.tds050 AS TEXT) AS TDS010TDS050, ENT01.tds051 AS TDS010TDS051, ENT01.tds052 AS TDS010TDS052, CASE WHEN ENT01.tds053=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS053, CASE WHEN ENT01.tds054=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS054, CASE WHEN ENT01.tds055=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS055, CASE WHEN ENT01.tds056=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS056, CASE WHEN ENT01.tds057=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS057, CASE WHEN ENT01.tds058=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS058, CASE WHEN ENT01.tds059=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS059, CASE WHEN ENT01.tds060=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS060, CASE WHEN ENT01.tds061=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS061, CASE WHEN ENT01.tds062=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS062, CASE WHEN ENT01.tds063=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS063, CASE WHEN ENT01.tds064=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS064, CASE WHEN ENT01.tds065=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS065, CASE WHEN ENT01.tds066=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS066, CASE WHEN ENT01.tds067=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS067, CASE WHEN ENT01.tds068=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS068, CASE WHEN ENT01.tds069=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS069, CASE WHEN ENT01.tds070=1 THEN 'Sim' ELSE 'N�o' END AS TDS010TDS070, CAST(ENT01.tds071 AS TEXT) AS TDS010TDS071, ENT01.tds072 AS TDS010TDS072, 1 AS QTD_BI, P.IDOBJECT, P.IDPROCESS AS ID_PROCESS, P.NMPROCESS, P.CDPROCESSMODEL, P.CDREVISION, P.IDPROCESSMODEL, P.NMPROCESSMODEL, P.FGSTATUS AS FGSTATUS,CONVERT(DATETIME, P.DTSTART + ' ' + P.TMSTART, 120) AS DTSTART,CONVERT(DATETIME, P.DTFINISH + ' ' + P.TMFINISH, 120) AS DTFINISH,SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(SLACTRL.BNSLAFINISH AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-02:00') AS DTSLAFINISH, P.TMSTART, P.TMFINISH, P.CDUSERSTART, ADU.NMUSER AS NMUSERSTART, P.CDFAVORITE, P.FGSLASTATUS, CASE P.FGSTATUS WHEN 1 THEN 'Andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edi��o' END AS IDSITUATION, CASE P.FGSLASTATUS WHEN 10 THEN 'Play' WHEN 30 THEN 'Pause' WHEN 40 THEN 'Stop' END AS IDSLASTATUS, CASE WHEN P.VLTIMEFINISH IS NULL THEN 9999999999 ELSE P.VLTIMEFINISH END AS VLTIMEFINISH, GREV.IDREVISION, SLACTRL.BNSLAFINISH, PT.CDACTTYPE, PT.IDACTTYPE, PT.NMACTTYPE, PP.NMACTIVITY AS PROCESSMODEL, GNRS.IDREVISIONSTATUS, GNRS.NMREVISIONSTATUS, GNRS.CDREVISIONSTATUS, GNRS.FGLOGO AS FGLOGOREVISIONSTATUS, GNRUS.VLEVALRESULT, GNR.NMEVALRESULT, GNR.FGSYMBOL, CASE WHEN GNR.NRORDER IS NULL THEN -999999999 ELSE GNR.NRORDER END AS NRORDERPRIORITY, dateadd(minute, P.NRTIMEESTFINISH, P.DTESTIMATEDFINISH) AS DTDEADLINEFIELD, P.NRTIMEESTFINISH AS NRHRDEADLINEFIELD, CAST('VLTIMEFINISH' AS VARCHAR(50)) AS NRDEADLINEFIELD_IMG, CAST('VLTIMEFINISH' AS VARCHAR(50)) AS DEADLINEFIELD_DT, (SELECT TOP 1 1 FROM WFPROCDOCUMENT T_QTD_DOC WHERE T_QTD_DOC.IDPROCESS=P.IDOBJECT) AS QTD_DOC, (SELECT TOP 1 1 FROM WFPROCATTACHMENT T_QTD_ATT WHERE T_QTD_ATT.IDPROCESS=P.IDOBJECT AND T_QTD_ATT.CDUSER IS NOT NULL) AS QTD_ATT, ROW_NUMBER() OVER (ORDER/**/ BY P.IDPROCESS ASC) AS ROW_NUM, CASE WHEN P.FGSTATUS IN (1,2,3,5) THEN (CAST(FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))) AS VARCHAR) + ' dia(s) ' + CAST(FLOOR((CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) AS VARCHAR) + ' hora(s) ' + CAST(FLOOR((((CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) - FLOOR((CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST((GETDATE()-(P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24))*60) AS VARCHAR) + ' minuto(s)') WHEN P.FGSTATUS=4 THEN (CAST(FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))) AS VARCHAR) + ' dia(s) ' + CAST(FLOOR((CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) AS VARCHAR) + ' hora(s) ' + CAST(FLOOR((((CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24) - FLOOR((CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8)) - FLOOR(CAST(((P.DTFINISH+' '+P.TMFINISH) - (P.DTSTART+' '+P.TMSTART)) AS NUMERIC(18,8))))*24))*60) AS VARCHAR) + ' minuto(s)') END AS DURATION_WF, CASE WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN P.FGCONCLUDEDSTATUS=1 THEN 1 WHEN P.FGCONCLUDEDSTATUS=2 THEN 3 END) ELSE (CASE WHEN (( P.DTESTIMATEDFINISH > CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME)) OR (P.DTESTIMATEDFINISH IS NULL)) THEN 1 WHEN (( P.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND P.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (P.DTESTIMATEDFINISH=CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME))) THEN 2 ELSE 3 END) END AS FGDEADLINE, CASE WHEN (( P.DTESTIMATEDFINISH > CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME)) OR (P.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND P.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (P.DTESTIMATEDFINISH IS NULL)) THEN 1 ELSE 3 END AS FGDEADLINE2, CASE WHEN P.FGCONCLUDEDSTATUS IS NOT NULL THEN (CASE WHEN P.FGCONCLUDEDSTATUS=1 THEN 'Em dia' WHEN P.FGCONCLUDEDSTATUS=2 THEN 'Em atraso' END) ELSE (CASE WHEN (( P.DTESTIMATEDFINISH > CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME)) OR (P.DTESTIMATEDFINISH IS NULL)) THEN 'Em dia' WHEN (( P.DTESTIMATEDFINISH=CAST( dateadd(dd, datediff(dd,0, getDate()), 0) AS DATETIME) AND P.NRTIMEESTFINISH >= (datepart(minute, getdate()) + datepart(hour, getdate()) * 60)) OR (P.DTESTIMATEDFINISH=CAST((dateadd(dd, datediff(dd,0, getDate()), 0) + 1) AS DATETIME))) THEN 'Pr�ximo do vencimento' ELSE 'Em atraso' END) END AS NMDEADLINE ,P.QTHOURS AS QTHOURS, P.FGDURATIONUNIT AS FGDURATIONUNIT, P.CDPROCESS, GNT.IDGENTYPE AS IDOCCURRENCETYPE, GNT.NMGENTYPE AS NMOCCURRENCETYPE, INCID.CDOCCURRENCETYPE AS CDOCCURRENCETYPE, GNT.FGLOGO AS FGLOGOOCCURRENCETYPE FROM WFPROCESS P LEFT OUTER JOIN GNREVISION GREV ON (P.CDREVISION=GREV.CDREVISION) LEFT OUTER JOIN GNSLACONTROL SLACTRL ON (P.CDSLACONTROL=SLACTRL.CDSLACONTROL) LEFT OUTER JOIN ADUSER ADU ON (ADU.CDUSER=P.CDUSERSTART) LEFT OUTER JOIN PMACTIVITY PP ON (PP.CDACTIVITY=P.CDPROCESSMODEL) LEFT OUTER JOIN PMACTTYPE PT ON (PT.CDACTTYPE=PP.CDACTTYPE) LEFT OUTER JOIN GNREVISIONSTATUS GNRS ON (P.CDSTATUS=GNRS.CDREVISIONSTATUS) LEFT OUTER JOIN GNEVALRESULTUSED GNRUS ON (GNRUS.CDEVALRESULTUSED=P.CDEVALRSLTPRIORITY) LEFT OUTER JOIN GNEVALRESULT GNR ON (GNRUS.CDEVALRESULT=GNR.CDEVALRESULT) INNER JOIN INOCCURRENCE INCID ON (P.IDOBJECT=INCID.IDWORKFLOW) LEFT OUTER JOIN GNGENTYPE GNT ON (INCID.CDOCCURRENCETYPE=GNT.CDGENTYPE) INNER JOIN PBPROBLEM PB ON PB.CDOCCURRENCE=INCID.CDOCCURRENCE INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT P.IDOBJECT FROM WFPROCESS P INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON WF.CDTEAM=TM.CDTEAM WHERE 1=1 AND WF.FGACCESSTYPE=1 AND TM.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND WF.FGACCESSTYPE=2 AND UDP.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND WF.FGACCESSTYPE=3 AND UDP.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND WF.FGACCESSTYPE=4 AND UDP.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE 1=1 AND WF.FGACCESSTYPE=5 AND WF.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE 1=1 AND WF.FGACCESSTYPE=6 AND US.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON RL.CDROLE=WF.CDROLE WHERE 1=1 AND WF.FGACCESSTYPE=7 AND RL.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS WHERE 1=1 AND WF.FGACCESSTYPE=30 AND WFP.CDUSERSTART=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND WF.FGACCESSTYPE=31 AND US.CDLEADER=5799) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST AND GNASSOC.IDPROCESS=PERM.IDPROCESS WHERE 1=1 AND GNASSOC.CDACCESSROLEFIELD=501 GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON PERMISSION.IDPROCESS=P.IDOBJECT INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=P.IDOBJECT WHERE 1=1 AND PERMISSION.FGPERMISSION=1 AND P.FGSTATUS <= 5 AND (P.FGMODELWFSECURITY IS NULL OR P.FGMODELWFSECURITY=0) AND INCID.FGOCCURRENCETYPE=2 UNION ALL SELECT T.IDOBJECT FROM (SELECT PERM.IDOBJECT, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM1.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE 1=1 AND PM.FGACCESSTYPE=1 AND TM.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND PM.FGACCESSTYPE=2 AND UDP.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=3 AND UDP.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=4 AND UDP.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM WHERE 1=1 AND PM.FGACCESSTYPE=5 AND PM.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.FGACCESSTYPE=6 AND US.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE 1=1 AND PM.FGACCESSTYPE=7 AND RL.CDUSER=5799) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM2.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PMA.CDCREATEDBY AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE 1=1 AND PM.FGACCESSTYPE=8 AND PMA.CDCREATEDBY=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE 1=1 AND PM.FGACCESSTYPE=9 AND DEP2.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=10 AND DEP2.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=11 AND DEP2.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE 1=1 AND PM.FGACCESSTYPE=12 AND US.CDLEADER=5799) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PERM3.IDOBJECT, PMA.FGUSETYPEACCESS, PERM3.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, WFP.CDUSERSTART AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND PM.FGACCESSTYPE=30 AND WFP.CDUSERSTART=5799 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND PM.FGACCESSTYPE=31 AND US.CDLEADER=5799 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND PMA.FGUSETYPEACCESS=1) PERM WHERE 1=1 GROUP BY PERM.IDOBJECT) T INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=T.IDOBJECT WHERE 1=1 AND T.FGPERMISSION=1 AND INCID.FGOCCURRENCETYPE=2 UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE 1=1 AND PP.FGACCESSTYPE=1 AND TM.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND PP.FGACCESSTYPE=2 AND UDP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PP.FGACCESSTYPE=3 AND UDP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PP.FGACCESSTYPE=4 AND UDP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE 1=1 AND PP.FGACCESSTYPE=5 AND PP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE 1=1 AND PP.FGACCESSTYPE=6 AND US.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE 1=1 AND PP.FGACCESSTYPE=7 AND RL.CDUSER=5799) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE 1=1 AND GNCTRL.CDRELATEDFIELD=501 AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE 1=1 AND PP.FGACCESSTYPE=30 AND WFP.CDUSERSTART=5799 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND PP.FGACCESSTYPE=31 AND US.CDLEADER=5799 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE 1=1 AND GNCTRL.CDRELATEDFIELD=501 AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=T.IDOBJECT WHERE 1=1 AND T.FGPERMISSION=1 AND INCID.FGOCCURRENCETYPE=2) Z WHERE 1=1) MYPERM ON (P.IDOBJECT=MYPERM.IDOBJECT) LEFT OUTER JOIN (SELECT DYNtds010.*, GNASSOCFORMREG.CDASSOC FROM GNASSOCFORMREG INNER JOIN DYNtds010 ON (DYNtds010.OID=GNASSOCFORMREG.OIDENTITYREG)) ENT01 ON (ENT01.CDASSOC=P.CDASSOCREG) WHERE 1=1 AND GNT.cdgentype IN (<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, R05HRU5UWVBF, Y2RnZW50eXBl, Y2RnZW50eXBlb3duZXI=, ,OTI=)%>) AND P.FGSTATUS <= 5 AND INCID.FGOCCURRENCETYPE=2 AND (GNT.CDTYPEROLE IS NULL OR EXISTS (SELECT 1 FROM (SELECT MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE) AS FGACCESSLIST, CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /**/UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM, ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.FGACCESSLIST=1 AND CHKPERMTYPEROLE.CDTYPEROLE=GNT.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=5799 OR 5799=-1)))) TEMPTB0) TEMPTB1