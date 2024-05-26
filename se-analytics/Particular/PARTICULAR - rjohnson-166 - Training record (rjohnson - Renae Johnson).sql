SELECT T.FGPARTTYPE, T.FGSTATUS, T.IDTRAIN, T.NMTRAIN, TCONF.IDCONFIGURATION, TCONF.NMCONFIGURATION, C.IDCOURSE, C.NMCOURSE, T.DTPROGSTART, T.DTPROGFINISH, T.VLCOSTPROG AS VLQTPROGCOST, T.QTPARTPROG, T.QTTMTOTPROG, T.DTREALSTART, T.DTREALFINISH, T.CDUSERINST, T.VLCOSTREAL AS VLQTREALCOST, T.QTPARTREAL, T.QTTMTOTREAL, T.FGEFF, T.FGEFFEVAL, T.FGCANCEL, T.FGINVALID, T.CDTRAIN, C.CDCOURSE, T.FGPRESENCELIST, T.DTVALID, CASE WHEN T.DTVALID < <!%TODAY%> THEN 1 ELSE 2 END FGVALID, CASE WHEN EXISTS (SELECT 1 FROM ADATTACHMENT ADA INNER JOIN TRTRAINATTACH TRA ON ( TRA.CDATTACHMENT=ADA.CDATTACHMENT) WHERE TRA.CDTRAIN=T.CDTRAIN) THEN 1 ELSE 2 END FGATTACHMENT, CASE WHEN EXISTS (SELECT 1 FROM DCDOCUMENT D INNER JOIN TRTRAINDOC TD ON ( D.CDDOCUMENT=TD.CDDOCUMENT) WHERE TD.CDTRAIN=T.CDTRAIN) THEN 1 ELSE 2 END FGDOCUMENT, TEMPPRE.FGSTATUSPRE, TEMPTRAIN.DTEVALUATION, TEMPTRAIN.FGSTATUSTRA, TEMPREAC.FGSTATUSREAC, TEMPPOS.FGSTATUSPOS, TEMPEFF.FGSTATUSEFF, CASE WHEN T.FGEFFEVAL=1 THEN CASE WHEN T.FGEFF=1 THEN 1 WHEN T.FGEFF=2 THEN 2 END ELSE 3 END AS FGEFF2, (T.QTTMTOTPROG/60) AS QTTMTOTPROGINHOURS, (T.QTTMTOTREAL/60) AS QTTMTOTREALINHOURS, (CAST(T.QTTMTOTPROG AS NUMERIC)*60000) AS QTTOTPROGHOURS, (CAST(T.QTTMTOTREAL AS NUMERIC)*60000) AS QTTOTREALHOURS, CT.CDGENTYPE AS CDCOURSETYPE, CT.IDGENTYPE AS IDCOURSETYPE, CT.NMGENTYPE AS NMCOURSETYPE,C.IDCOURSE+ ' - ' +C.NMCOURSE AS IDNMCOURSE, CT.IDGENTYPE+ ' - ' +CT.NMGENTYPE AS IDNMTYPECOURSE, TCONF.IDCONFIGURATION+ ' - ' +TCONF.NMCONFIGURATION AS IDNMCONFIGURATION ,CASE WHEN T.FGCANCEL=1 THEN (CAST ('Cancelled' AS VARCHAR(255))) WHEN T.FGINVALID=1 THEN (CAST ('Invalidated' AS VARCHAR(255))) WHEN T.FGSTATUS=1 THEN (CAST ('Planning' AS VARCHAR(255))) WHEN T.FGSTATUS=2 THEN (CAST ('Planning approval' AS VARCHAR(255))) WHEN T.FGSTATUS=3 THEN (CAST ('Not approved' AS VARCHAR(255))) WHEN T.FGSTATUS=4 THEN (CAST ('Start' AS VARCHAR(255))) WHEN T.FGSTATUS=5 THEN (CAST ('Execution' AS VARCHAR(255))) WHEN T.FGSTATUS=7 THEN (CAST ('Effectiveness verification' AS VARCHAR(255))) WHEN T.FGSTATUS=8 THEN (CAST ('Finished' AS VARCHAR(255))) WHEN T.FGSTATUS=10 THEN (CAST ('Evaluation' AS VARCHAR(255))) END AS IDSTATUS, CASE WHEN TRM.IDTRAININGMETHOD IS NOT NULL THEN CAST(TRM.IDTRAININGMETHOD + ' - ' + TRM.NMTRAININGMETHOD AS VARCHAR(350)) ELSE NULL END AS IDNMTRAININGMETHOD ,CASE WHEN ((  TEMPPRE.CDSURVEYEXECPRE IS NOT NULL AND TEMPPRE.FGSTATUSSURVEYPRE >= 5) OR ( TEMPTRAIN.CDSURVEYEXECTRA IS NOT NULL AND TEMPTRAIN.FGSTATUSSURVEYTRA >= 5) OR ( TEMPREAC.CDSURVEYEXECREAC IS NOT NULL AND TEMPREAC.FGSTATUSSURVEYREAC >= 5) OR ( TEMPPOS.CDSURVEYEXECPOS IS NOT NULL AND TEMPPOS.FGSTATUSSURVEYPOS >= 5)) THEN 1 ELSE 2 END AS FGSURVEY, CASE WHEN T.FGEFFEVAL=1 THEN CASE WHEN T.FGEFF=1 THEN CAST('Yes' AS VARCHAR(255)) WHEN T.FGEFF=2 THEN CAST('No' AS VARCHAR(255)) ELSE CASE WHEN T.FGSTATUS=7 THEN CAST('Waiting for verification' AS VARCHAR(255)) ELSE CAST('Blocked' AS VARCHAR(255)) END END ELSE CAST('It does not have' AS VARCHAR(255)) END AS NMFGEFF, CASE WHEN T.FGINVALID IS NOT NULL THEN CASE WHEN T.FGINVALID=1 THEN CAST('Yes' AS VARCHAR(255)) WHEN T.FGINVALID=2 THEN CAST('No' AS VARCHAR(255)) END END AS NMFGINVALID, CASE WHEN T.FGSTATUS=10 THEN CASE WHEN TEMPDEADLINE.DTDEADLINE IS NOT NULL THEN CASE WHEN TEMPDEADLINE.DTDEADLINE < CAST(CURRENT_TIMESTAMP AS DATETIME) THEN 3 WHEN (TEMPDEADLINE.DTDEADLINE=CAST(CURRENT_TIMESTAMP AS DATETIME) OR TEMPDEADLINE.DTDEADLINE=(<!%TODAY%> + 1)) THEN 2 ELSE 1 END ELSE  CASE WHEN T.DTREALFINISH < CAST(CURRENT_TIMESTAMP AS DATETIME) THEN 3 WHEN (T.DTREALFINISH=CAST(CURRENT_TIMESTAMP AS DATETIME) OR T.DTREALFINISH=(<!%TODAY%> + 1)) THEN 2 ELSE 1 END END WHEN T.FGSTATUS=7 THEN  CASE  WHEN T.DTDEADLINE IS NULL  THEN NULL  WHEN T.DTDEADLINE IS NOT NULL  AND T.DTDEADLINE > CAST(CURRENT_TIMESTAMP AS DATETIME)  THEN 1  WHEN T.DTDEADLINE IS NOT NULL  AND (T.DTDEADLINE=CAST(CURRENT_TIMESTAMP AS DATETIME) OR T.DTDEADLINE=(<!%TODAY%> + 1))  THEN 2  ELSE 3 END ELSE CASE  WHEN T.DTREALSTART IS NULL  THEN  CASE WHEN T.DTPROGSTART IS NOT NULL THEN CASE WHEN T.DTPROGSTART > CAST(CURRENT_TIMESTAMP AS DATETIME) THEN 1 WHEN (T.DTPROGSTART=CAST(CURRENT_TIMESTAMP AS DATETIME) OR T.DTPROGSTART=(<!%TODAY%> + 1)) THEN 2 WHEN T.DTPROGSTART < CAST(CURRENT_TIMESTAMP AS DATETIME) THEN 3 END ELSE 1 END  WHEN (T.DTREALSTART IS NOT NULL AND T.DTREALFINISH IS NULL)  THEN CASE WHEN T.DTPROGFINISH IS NOT NULL THEN  CASE WHEN T.DTPROGFINISH > CAST(CURRENT_TIMESTAMP AS DATETIME) THEN 1 WHEN (T.DTPROGFINISH=CAST(CURRENT_TIMESTAMP AS DATETIME) OR T.DTPROGFINISH=(<!%TODAY%> + 1)) THEN 2 WHEN T.DTPROGFINISH < CAST(CURRENT_TIMESTAMP AS DATETIME) THEN 3 END ELSE 1  END  WHEN (T.DTREALSTART IS NOT NULL AND T.DTREALFINISH IS NOT NULL)  THEN CASE WHEN T.DTPROGFINISH IS NOT NULL THEN  CASE WHEN T.DTREALFINISH <= T.DTPROGFINISH THEN 1 WHEN T.DTREALFINISH > T.DTPROGFINISH THEN 3 END ELSE 1  END END END AS FGTRAINDEADLINE, ADC.IDCOMMERCIAL +' - '+ ADC.NMCOMPANY AS IDNMCOMPANY, CASE WHEN T.FGEXECTYPE=1 THEN ADU.IDUSER ELSE T.NMINSTRUCTOR END AS IDUSER, CASE WHEN T.FGEXECTYPE=1 THEN ADU.NMUSER ELSE T.NMINSTRUCTOR END AS NMUSER, CASE WHEN T.FGEXECTYPE=1 THEN AD.IDDEPARTMENT +' - '+ AD.NMDEPARTMENT END AS IDNMDEPARTMENT, CASE WHEN T.FGEXECTYPE=1 THEN AP.IDPOSITION +' - '+ AP.NMPOSITION END AS IDNMPOSITION, T.VLCOSTREAL, T.FGCOSTREAL, T.DTEFF, T.VLCOSTPROG, T.FGCOSTPROG, ADEFF.NMUSER AS NMRESPEFF, CT.CDGENTYPE AS CDTYPECOURSE, CT.IDGENTYPE AS IDTYPECOURSE, CT.NMGENTYPE AS NMTYPECOURSE, 0 AS CDMONTH, CASE WHEN NRENDMONTH IS NULL THEN NULL WHEN NRENDMONTH IS NOT NULL THEN (CAST(NRENDMONTH AS VARCHAR(50)) +'/'+ CAST(NRENDYEAR AS VARCHAR(50))) END AS IDMONTH, 0 AS CDYEAR, CAST(NRENDYEAR AS VARCHAR(50)) AS NMNRENDYEAR , 0 AS CDSTATUS, TEP.CDTEAM AS CDTEAMPROG, TEP.IDTEAM AS IDTEAMPROG, TEP.NMTEAM AS NMTEAMPROG, TER.CDTEAM AS CDTEAMREAL, TER.IDTEAM AS IDTEAMREAL, TER.NMTEAM AS NMTEAMREAL, TEP.IDTEAM+' - '+TEP.NMTEAM AS IDNMTEAMPROG, TER.IDTEAM+' - '+TER.NMTEAM AS IDNMTEAMREAL, CASE WHEN ((T.FGCANCEL IS NULL OR T.FGCANCEL <> 1) AND (T.FGINVALID IS NULL OR T.FGINVALID <> 1)) THEN CASE WHEN (T.FGSTATUS <= 5 OR T.FGSTATUS=9) THEN CASE WHEN T.DTPROGFINISH IS NOT NULL AND T.DTPROGFINISH > CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('On time' AS VARCHAR(255))) WHEN T.DTPROGFINISH IS NOT NULL AND T.DTPROGFINISH=CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('Close to due date' AS VARCHAR(255))) WHEN T.DTPROGFINISH IS NOT NULL AND T.DTPROGFINISH < CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('Past due' AS VARCHAR(255))) END WHEN T.FGSTATUS=6 THEN CASE WHEN TEMPPOS.DTLACKEVALUATION IS NOT NULL THEN CASE WHEN TEMPPOS.DTLACKEVALUATION > CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('On time' AS VARCHAR(255))) WHEN TEMPPOS.DTLACKEVALUATION=CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('Close to due date' AS VARCHAR(255))) ELSE (CAST ('Past due' AS VARCHAR(255))) END END WHEN T.FGSTATUS=7 THEN CASE WHEN T.DTDEADLINE IS NOT NULL AND T.DTDEADLINE > CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('On time' AS VARCHAR(255))) WHEN T.DTDEADLINE IS NOT NULL AND T.DTDEADLINE=CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('Close to due date' AS VARCHAR(255))) WHEN T.DTDEADLINE IS NOT NULL AND T.DTDEADLINE < CAST(<!%TODAY%> AS DATETIME) THEN (CAST ('Past due' AS VARCHAR(255))) END END END AS NMFGTRAINDEADLINE, CASE WHEN(FGPARTTYPE=2) THEN (CAST ('Individual' AS VARCHAR(255))) ELSE (CAST ('Collective' AS VARCHAR(255))) END AS NMFGPARTTYPE FROM TRTRAINING T INNER JOIN TRCOURSE C ON (T.CDCOURSE=C.CDCOURSE) INNER JOIN TRCONFIGURATION TCONF ON (T.CDCONFIGURATION=TCONF.CDCONFIGURATION) LEFT OUTER JOIN ADTEAM TEP ON (TEP.CDTEAM=T.CDTEAMPROG) LEFT OUTER JOIN ADTEAM TER ON (TER.CDTEAM=T.CDTEAMREAL) LEFT OUTER JOIN (SELECT TREXTRAIN.DTEVALUATION, TREXTRAIN.CDTRAIN AS CDTRAINPRE, TREXTRAIN.FGSTATUS AS FGSTATUSPRE, TREXTRAIN.CDSURVEYEXEC AS CDSURVEYEXECPRE, TREXTRAIN.DTDEADLINECOMPLETE AS DTDEADLINECOMPLETEPRE, TREXTRAIN.CDTRAINEVALEXECONF AS CDTRAINEVALEXECONFPRE, TEVALTRAIN.FGREQUIREDTOSTEP AS FGREQUIREDTOSTEPPRE, TEVALTRAIN.FGUSESURVEY AS FGUSESURVEYPRE, GNACT.FGSTATUS AS FGSTATUSSURVEYPRE, TEVALTRAIN.DSEVALUATION AS DSEVALPRE, TEVALTRAIN.CDSURVEYANSWERTEAM AS CDTEAMTESTPRE, TEVALTRAIN.CDSURVEYTEMPLATE AS CDTESTPRE, TEVALTRAIN.FGEVALTYPE AS FGEVALTYPEPRE, TEVALTRAIN.FGDEADLINE AS FGDEADLINEPRE, TEVALTRAIN.QTDEADLINE AS QTDEADLINEPRE FROM TREVALUATIONCONFIG TEVALTRAIN INNER JOIN TRTRAINEVALEXECONF TREXTRAIN ON ( TEVALTRAIN.CDEVALUATIONCONFIG=TREXTRAIN.CDEVALUATIONCONFIG) LEFT OUTER JOIN SVSURVEY SV ON ( SV.CDSURVEY=TREXTRAIN.CDSURVEYEXEC) LEFT OUTER JOIN GNACTIVITY GNACT ON ( GNACT.CDGENACTIVITY=SV.CDGENACTIVITY) WHERE TEVALTRAIN.FGTYPE=1) TEMPPRE ON (TEMPPRE.CDTRAINPRE=T.CDTRAIN) LEFT OUTER JOIN (SELECT TREXTRAIN.DTEVALUATION, TREXTRAIN.CDTRAIN AS CDTRAINTRAIN, TREXTRAIN.FGSTATUS AS FGSTATUSTRA, TREXTRAIN.CDSURVEYEXEC AS CDSURVEYEXECTRA, TREXTRAIN.DTDEADLINECOMPLETE AS DTDEADLINECOMPLETETRA, TREXTRAIN.CDTRAINEVALEXECONF AS CDTRAINEVALEXECONFTRA, TEVALTRAIN.FGUSETOAPPROVAL AS FGUSETOAPPROVALTRA, TEVALTRAIN.FGUSESURVEY AS FGUSESURVEYTRA, GNACT.FGSTATUS AS FGSTATUSSURVEYTRA, TEVALTRAIN.DSEVALUATION AS DSEVALTRAIN, TEVALTRAIN.CDSURVEYANSWERTEAM AS CDTEAMTESTTRAIN, TEVALTRAIN.CDSURVEYTEMPLATE AS CDTESTTRAIN, TEVALTRAIN.FGEVALTYPE AS FGEVALTYPETRAIN, TEVALTRAIN.FGEVALFREQUENCE AS FGEVALFREQUENCE, TEVALTRAIN.FGDEADLINE AS FGDEADLINETRAIN, TEVALTRAIN.QTDEADLINE AS QTDEADLINETRAIN, TEVALTRAIN.VLMINNOTE AS VLMINNOTETRAIN FROM TREVALUATIONCONFIG TEVALTRAIN INNER JOIN TRTRAINEVALEXECONF TREXTRAIN ON ( TEVALTRAIN.CDEVALUATIONCONFIG=TREXTRAIN.CDEVALUATIONCONFIG) LEFT OUTER JOIN SVSURVEY SV ON ( SV.CDSURVEY=TREXTRAIN.CDSURVEYEXEC) LEFT OUTER JOIN GNACTIVITY GNACT ON ( GNACT.CDGENACTIVITY=SV.CDGENACTIVITY) WHERE TEVALTRAIN.FGTYPE=2) TEMPTRAIN ON (TEMPTRAIN.CDTRAINTRAIN=T.CDTRAIN) LEFT OUTER JOIN (SELECT TEVALCONF.DTEVALUATION, TREVALCON.FGUSESURVEY AS FGUSESURVEYREAC, TREVALCON.FGREQUIREDTOSTEP AS FGREQUIREDTOSTEPREAC, TEVALCONF.CDSURVEYEXEC AS CDSURVEYEXECREAC, TEVALCONF.CDTRAINEVALEXECONF AS CDTRAINEVALEXECONFREAC, TEVALCONF.DTDEADLINECOMPLETE AS DTDEADLINECOMPLETEREA, TEVALCONF.DTLACKEVALUATION, TEVALCONF.CDTRAIN AS CDTRAINREAC, TEVALCONF.FGSTATUS AS FGSTATUSREAC, GNACT.FGSTATUS AS FGSTATUSSURVEYREAC, TREVALCON.DSEVALUATION AS DSEVALREAC, TREVALCON.FGEVALTYPE AS FGEVALTYPEREAC, TREVALCON.CDSURVEYANSWERTEAM AS CDTEAMSURVEYREAC, TREVALCON.CDSURVEYTEMPLATE AS CDSURVEYREAC, TREVALCON.QTDEADLINE AS QTDEADLINEREAC, TREVALCON.FGDEADLINE AS FGDEADLINEREAC, TREVALCON.FGANONYMOUS FROM TREVALUATIONCONFIG TREVALCON INNER JOIN TRTRAINEVALEXECONF TEVALCONF ON ( TREVALCON.CDEVALUATIONCONFIG=TEVALCONF.CDEVALUATIONCONFIG) LEFT OUTER JOIN SVSURVEY SV ON ( SV.CDSURVEY=TEVALCONF.CDSURVEYEXEC) LEFT OUTER JOIN GNACTIVITY GNACT ON ( GNACT.CDGENACTIVITY=SV.CDGENACTIVITY) WHERE TREVALCON.FGTYPE=3) TEMPREAC ON (TEMPREAC.CDTRAINREAC=T.CDTRAIN) LEFT OUTER JOIN (SELECT TEVALCONF.DTLACKEVALUATION, TEVALCONF.CDTRAIN AS CDTRAINPOS, TEVALCONF.FGSTATUS AS FGSTATUSPOS, TEVALCONF.CDSURVEYEXEC AS CDSURVEYEXECPOS, TEVALCONF.CDTRAINEVALEXECONF AS CDTRAINEVALEXECONFPOS, TEVALCONF.DTDEADLINECOMPLETE AS DTDEADLINECOMPLETEPOS, TREVALCON.FGUSETOAPPROVAL AS FGUSETOAPPROVALPOS, GNACT.FGSTATUS AS FGSTATUSSURVEYPOS, TREVALCON.QTLACK, TREVALCON.FGUSESURVEY AS FGUSESURVEYPOS, TREVALCON.FGLACK, TREVALCON.DSEVALUATION AS DSEVALPOS, TREVALCON.FGEVALTYPE AS FGEVALTYPEPOS, TREVALCON.CDSURVEYANSWERTEAM AS CDTEAMTESTPOS, TREVALCON.CDSURVEYTEMPLATE AS CDTESTPOS, TREVALCON.FGDEADLINE AS FGDEADLINEPOS, TREVALCON.QTDEADLINE AS QTDEADLINEPOS, TREVALCON.VLMINNOTE AS VLMINNOTEPOS FROM TREVALUATIONCONFIG TREVALCON INNER JOIN TRTRAINEVALEXECONF TEVALCONF ON ( TREVALCON.CDEVALUATIONCONFIG=TEVALCONF.CDEVALUATIONCONFIG) LEFT OUTER JOIN SVSURVEY SV ON ( SV.CDSURVEY=TEVALCONF.CDSURVEYEXEC) LEFT OUTER JOIN GNACTIVITY GNACT ON ( GNACT.CDGENACTIVITY=SV.CDGENACTIVITY) WHERE TREVALCON.FGTYPE=4) TEMPPOS ON (TEMPPOS.CDTRAINPOS=T.CDTRAIN) LEFT OUTER JOIN (SELECT TEVALCONF.DTLACKEVALUATION, TEVALCONF.CDTRAIN AS CDTRAINEFF, TEVALCONF.FGSTATUS AS FGSTATUSEFF, TEVALCONF.CDSURVEYEXEC AS CDSURVEYEXECEFF, TEVALCONF.CDTRAINEVALEXECONF AS CDTRAINEVALEXECONFEFF, TEVALCONF.DTDEADLINECOMPLETE AS DTDEADLINECOMPLETEEFF, TREVALCON.FGUSETOAPPROVAL AS FGUSETOAPPROVALEFF, TREVALCON.FGUSESURVEY AS FGUSESURVEYEFF, TREVALCON.QTLACK AS QTLACKEFF, TREVALCON.FGLACK AS FGLACKEFF, TREVALCON.DSEVALUATION AS DSEVALEFF, TREVALCON.FGEVALTYPE AS FGEVALTYPEEFF, TREVALCON.CDSURVEYANSWERTEAM AS CDTEAMTESTEFF, TREVALCON.CDSURVEYTEMPLATE AS CDTESTEFF, TREVALCON.FGDEADLINE AS FGDEADLINEEFF, TREVALCON.QTDEADLINE AS QTDEADLINEEFF, TREVALCON.VLMINNOTE AS VLMINNOTEEFF FROM TREVALUATIONCONFIG TREVALCON INNER JOIN TRTRAINEVALEXECONF TEVALCONF ON ( TREVALCON.CDEVALUATIONCONFIG=TEVALCONF.CDEVALUATIONCONFIG) WHERE TREVALCON.FGTYPE=5) TEMPEFF ON (TEMPEFF.CDTRAINEFF=T.CDTRAIN) LEFT OUTER JOIN (SELECT TEMPDEAD.CDTRAIN, MIN(TEMPDEAD.DTDEADLINECOMPLETE) AS DTDEADLINE FROM (SELECT T.CDTRAIN, TC.DTDEADLINECOMPLETE, TEC.FGTYPE FROM TRTRAINING T INNER JOIN TRTRAINEVALEXECONF TC ON ( TC.CDTRAIN=T.CDTRAIN) INNER JOIN TREVALUATIONCONFIG TEC ON ( TEC.CDEVALUATIONCONFIG=TC.CDEVALUATIONCONFIG) WHERE T.FGPRE=1 AND TC.FGSTATUS <> 3 AND TEC.FGTYPE=1 AND TC.DTDEADLINECOMPLETE IS NOT NULL  UNION  SELECT T.CDTRAIN, TC.DTDEADLINECOMPLETE, TEC.FGTYPE FROM TRTRAINING T INNER JOIN TRTRAINEVALEXECONF TC ON ( TC.CDTRAIN=T.CDTRAIN) INNER JOIN TREVALUATIONCONFIG TEC ON ( TEC.CDEVALUATIONCONFIG=TC.CDEVALUATIONCONFIG) WHERE T.FGTRAIN=1 AND TC.FGSTATUS <> 3 AND TEC.FGTYPE=2 AND TC.DTDEADLINECOMPLETE IS NOT NULL  UNION  SELECT T.CDTRAIN, TC.DTDEADLINECOMPLETE, TEC.FGTYPE FROM TRTRAINING T INNER JOIN TRTRAINEVALEXECONF TC ON ( TC.CDTRAIN=T.CDTRAIN) INNER JOIN TREVALUATIONCONFIG TEC ON ( TEC.CDEVALUATIONCONFIG=TC.CDEVALUATIONCONFIG) WHERE T.FGREACTION=1 AND TC.FGSTATUS <> 3 AND TEC.FGTYPE=3 AND TC.DTDEADLINECOMPLETE IS NOT NULL  UNION  SELECT T.CDTRAIN, CASE WHEN TC.FGSTATUS=1 THEN TC.DTLACKEVALUATION ELSE TC.DTDEADLINECOMPLETE END AS DTDEADLINECOMPLETE, TEC.FGTYPE FROM TRTRAINING T INNER JOIN TRTRAINEVALEXECONF TC ON ( TC.CDTRAIN=T.CDTRAIN) INNER JOIN TREVALUATIONCONFIG TEC ON ( TEC.CDEVALUATIONCONFIG=TC.CDEVALUATIONCONFIG) WHERE T.FGPOS=1 AND TC.FGSTATUS <> 3 AND TEC.FGTYPE=4 AND (TC.DTDEADLINECOMPLETE IS NOT NULL OR TC.DTLACKEVALUATION IS NOT NULL)  UNION  SELECT T.CDTRAIN, CASE WHEN TC.FGSTATUS=1 THEN TC.DTLACKEVALUATION ELSE TC.DTDEADLINECOMPLETE END AS DTDEADLINECOMPLETE, TEC.FGTYPE FROM TRTRAINING T INNER JOIN TRTRAINEVALEXECONF TC ON ( TC.CDTRAIN=T.CDTRAIN) INNER JOIN TREVALUATIONCONFIG TEC ON ( TEC.CDEVALUATIONCONFIG=TC.CDEVALUATIONCONFIG) WHERE TEC.FGEVALTYPE IS NOT NULL AND TC.FGSTATUS <> 3 AND TEC.FGTYPE=5 AND (TC.DTDEADLINECOMPLETE IS NOT NULL OR TC.DTLACKEVALUATION IS NOT NULL)) TEMPDEAD GROUP BY TEMPDEAD.CDTRAIN) TEMPDEADLINE ON (TEMPDEADLINE.CDTRAIN=T.CDTRAIN) INNER JOIN GNGENTYPE CT ON (C.CDCOURSETYPE=CT.CDGENTYPE AND (CT.CDTYPEROLE IS NULL OR EXISTS (SELECT 1 FROM (SELECT MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE) AS FGACCESSLIST, CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM, ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.FGACCESSLIST=1 AND CHKPERMTYPEROLE.CDTYPEROLE=CT.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=11163 OR 11163=-1)))) LEFT OUTER JOIN TRTRAININGMETHOD TRM ON (TRM.CDTRAININGMETHOD=T.CDTRAININGMETHOD) LEFT OUTER JOIN ADUSER ADEFF ON (ADEFF.CDUSER=T.CDRESPEFF) LEFT OUTER JOIN ADCOMPANY ADC ON (T.CDCOMPANY=ADC.CDCOMPANY) LEFT OUTER JOIN ADUSER ADU ON (ADU.CDUSER=T.CDUSERINST) LEFT OUTER JOIN ADUSERDEPTPOS UDP ON (ADU.CDUSER=UDP.CDUSER AND UDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT AD ON (UDP.CDDEPARTMENT=AD.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION AP ON (UDP.CDPOSITION=AP.CDPOSITION) WHERE T.FGPROFILE <> 1 AND CT.CDGENTYPE IN (<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, R05HRU5UWVBF, Q0RHRU5UWVBF, Q0RHRU5UWVBFT1dORVI=, ,MTM4)%>)