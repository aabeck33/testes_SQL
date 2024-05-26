SELECT CASE /*PLANEJAMENTO*/ WHEN GNACT.FGSTATUS IN (1,2) THEN CASE WHEN (GNACT.DTSTARTPLAN > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTSTARTPLAN IS NULL) THEN 1 WHEN GNACT.DTSTARTPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END /*ENCERRADO*/ WHEN GNACT.FGSTATUS=5 THEN CASE WHEN GNACT.DTFINISHPLAN IS NULL OR GNACT.DTFINISHPLAN >= GNACT.DTFINISH THEN 1 ELSE 3 END /*ANALISE CRITICA*/ WHEN GNACT.FGSTATUS=8 THEN CASE WHEN (SRV.DTDEADLINEANALYSIS > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR SRV.DTDEADLINEANALYSIS IS NULL) THEN 1 WHEN SRV.DTDEADLINEANALYSIS >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END /*ENCERRAMENTO*/ WHEN GNACT.FGSTATUS=10 THEN CASE WHEN (SRV.DTDEADLINECONCLUS > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR SRV.DTDEADLINECONCLUS IS NULL) THEN 1 WHEN SRV.DTDEADLINECONCLUS >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END /*EXECUCAO*/ ELSE CASE /*CORRECAO*/ WHEN ( GNSUREXEC.FGSTATUS=2 AND GNSRV.FGCORRECTION=1) THEN CASE WHEN (GNSRV.DTDEADLINECORRECT > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNSRV.DTDEADLINECORRECT IS NULL) THEN 1 WHEN GNSRV.DTDEADLINECORRECT >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END ELSE CASE  WHEN (GNACT.FGSTATUS=3 AND SRV.DTCLOSURE IS NOT NULL)  THEN CASE WHEN (SRV.DTCLOSURE > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR SRV.DTCLOSURE IS NULL) THEN 1 WHEN SRV.DTCLOSURE >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END WHEN GNACT.DTSTART IS NULL  THEN CASE WHEN (GNACT.DTSTARTPLAN > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTSTARTPLAN IS NULL) THEN 1 WHEN GNACT.DTSTARTPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END WHEN (GNACT.DTSTART IS NOT NULL AND GNACT.DTFINISH IS NULL)  THEN CASE WHEN (GNACT.DTFINISHPLAN > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTFINISHPLAN IS NULL) THEN 1 WHEN GNACT.DTFINISHPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END WHEN (GNACT.DTSTART IS NOT NULL AND GNACT.DTFINISH IS NOT NULL)  THEN CASE WHEN GNACT.DTFINISH >= dateadd(dd, datediff(dd,0, getDate()), 0) OR GNACT.DTFINISHPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN CASE WHEN (GNACT.DTFINISHPLAN > DATEADD(DAY, 2, GNACT.DTFINISH) OR GNACT.DTFINISHPLAN IS NULL OR GNACT.DTFINISH IS NULL) THEN 1 WHEN GNACT.DTFINISHPLAN >= GNACT.DTFINISH THEN 2 ELSE 3 END ELSE CASE WHEN (GNACT.DTFINISH > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTFINISH IS NULL) THEN 1 WHEN GNACT.DTFINISH >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END END END END END AS FGDEADLINE, SRV.FGOBJECT, GNSRV.FGENABLED, GNACT.CDFAVORITE, CASE WHEN GNACT.FGSTATUS=3 AND GNSUREXEC.CDSURVEYEXEC IS NOT NULL THEN CASE WHEN GNSUREXEC.FGSTATUS=1 THEN 3 WHEN GNSUREXEC.FGSTATUS=2 THEN 7 END ELSE GNACT.FGSTATUS END FGSTATUS, GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.QTMINUTESREAL, GNACT.QTMINUTESPLAN, GNTP.IDGENTYPE, GNTP.NMGENTYPE, GNTP.CDGENTYPE, GNACT.CDGENACTIVITY AS CDACTIVITY, GNACT.CDGENACTIVITY, GNACT.CDASSOC, SRV.CDSURVEY, SRV.FGMULTANSWER, SRV.QTMAXATTEMPTS, GNSRV.CDSURVEYTYPE, SRV.FGPURPOSESURVEY, GNSUREXEC.CDSURVEYEXEC, GNSUREXEC.FGSTATUS AS FGSTATUSEXEC, GNSUREXEC.CDSURVEY AS CDSVEXEC, TEMPQTANS.QTANSWERS, TEMPQTANSWER.QTRESPONDENT, TEMPQTQUESTION.QTQUESTION, GNTP.IDGENTYPE AS IDSURVEYTYPE, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CASE WHEN GNTP.IDGENTYPE IS NOT NULL THEN CAST(GNTP.IDGENTYPE + ' - ' + GNTP.NMGENTYPE AS VARCHAR(350)) ELSE NULL END AS IDNMSURVEYTYPE, CAST(CAST(GNACT.QTMINUTESPLAN AS NUMERIC(19)) * 60000 AS NUMERIC(19)) AS QTTMPLAN, CAST(CAST(GNACT.QTMINUTESREAL AS NUMERIC(19)) * 60000 AS NUMERIC(19)) AS QTTMREAL, CASE SRV.FGPURPOSESURVEY WHEN 1 THEN '#{210771}' ELSE '#{101166}' END AS NMPURPOSESURVEY, CASE GNACT.FGSTATUS WHEN 1 THEN '#{100470}' WHEN 2 THEN '#{200135}' WHEN 3 THEN CASE WHEN GNSUREXEC.FGSTATUS=2 THEN '#{209659}' ELSE '#{100481}' END WHEN 4 THEN '#{201912}' WHEN 5 THEN '#{100667}' WHEN 6 THEN '#{100481}' WHEN 7 THEN '#{209659}' WHEN 8 THEN '#{211594}' WHEN 9 THEN '#{211595}' WHEN 10 THEN '#{101006}' WHEN 11 THEN '#{200383}' END AS NMSTATUS, (SELECT NMTOKEN FROM GNSURVEYEXECUSER WHERE CDSURVEYEXECUSER= (SELECT MAX(GNSEUSR.CDSURVEYEXECUSER) AS CDSURVEYEXECUSER FROM GNSURVEYEXEC GNSEXEC INNER JOIN GNSURVEYEXECUSER GNSEUSR ON (GNSEUSR.CDSURVEYEXEC=GNSEXEC.CDSURVEYEXEC) WHERE GNSEUSR.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC)) AS NMTOKEN, TEMPNOTES.VLMINNOTE, TEMPNOTES.VLMAXNOTE, TEMPNOTES.VLAVGNOTE, SRV.FGSCORE, SRV.CDTEMPLATE, CASE /*PLANEJAMENTO*/ WHEN GNACT.FGSTATUS IN (1,2) THEN CASE WHEN (GNACT.DTSTARTPLAN > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTSTARTPLAN IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN GNACT.DTSTARTPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END /*ENCERRADO*/ WHEN GNACT.FGSTATUS=5 THEN CASE WHEN GNACT.DTFINISHPLAN IS NULL OR GNACT.DTFINISHPLAN >= GNACT.DTFINISH THEN (CAST ('#{100900}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END /*ANALISE CRITICA*/ WHEN GNACT.FGSTATUS=8 THEN CASE WHEN (SRV.DTDEADLINEANALYSIS > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR SRV.DTDEADLINEANALYSIS IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN SRV.DTDEADLINEANALYSIS >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END /*ENCERRAMENTO*/ WHEN GNACT.FGSTATUS=10 THEN CASE WHEN (SRV.DTDEADLINECONCLUS > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR SRV.DTDEADLINECONCLUS IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN SRV.DTDEADLINECONCLUS >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END /*EXECUCAO*/ ELSE CASE /*CORRECAO*/ WHEN ( GNSUREXEC.FGSTATUS=2 AND GNSRV.FGCORRECTION=1) THEN CASE WHEN (GNSRV.DTDEADLINECORRECT > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNSRV.DTDEADLINECORRECT IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN GNSRV.DTDEADLINECORRECT >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END ELSE CASE  WHEN (GNACT.FGSTATUS=3 AND SRV.DTCLOSURE IS NOT NULL)  THEN CASE WHEN (SRV.DTCLOSURE > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR SRV.DTCLOSURE IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN SRV.DTCLOSURE >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END WHEN GNACT.DTSTART IS NULL  THEN CASE WHEN (GNACT.DTSTARTPLAN > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTSTARTPLAN IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN GNACT.DTSTARTPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END WHEN (GNACT.DTSTART IS NOT NULL AND GNACT.DTFINISH IS NULL)  THEN CASE WHEN (GNACT.DTFINISHPLAN > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTFINISHPLAN IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN GNACT.DTFINISHPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END WHEN (GNACT.DTSTART IS NOT NULL AND GNACT.DTFINISH IS NOT NULL)  THEN CASE WHEN GNACT.DTFINISH >= dateadd(dd, datediff(dd,0, getDate()), 0) OR GNACT.DTFINISHPLAN >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN CASE WHEN (GNACT.DTFINISHPLAN > DATEADD(DAY, 2, GNACT.DTFINISH) OR GNACT.DTFINISHPLAN IS NULL OR GNACT.DTFINISH IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN GNACT.DTFINISHPLAN >= GNACT.DTFINISH THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END ELSE CASE WHEN (GNACT.DTFINISH > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR GNACT.DTFINISH IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN GNACT.DTFINISH >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END END END END END AS NMDEADLINE, TEMPQTRESPEXECANS.QTEXECUTED, TEMPQTCANCEL.QTCANCELED, TEMPQTRESP.QTSURVEYEXECMEMBER, CASE SRV.FGLANGUAGE WHEN 1 THEN CAST('#{215202}' AS VARCHAR(50)) WHEN 2 THEN CAST('#{215206}' AS VARCHAR(50)) WHEN 3 THEN CAST('#{215204}' AS VARCHAR(50)) WHEN 4 THEN CAST('#{215205}' AS VARCHAR(50)) WHEN 5 THEN CAST('#{215207}' AS VARCHAR(50)) WHEN 6 THEN CAST('#{215208}' AS VARCHAR(50)) WHEN 7 THEN CAST('#{215209}' AS VARCHAR(50)) WHEN 8 THEN CAST('#{309020}' AS VARCHAR(50)) WHEN 9 THEN CAST('#{215211}' AS VARCHAR(50)) WHEN 10 THEN CAST('#{217207}' AS VARCHAR(50)) WHEN 11 THEN CAST('#{215203}' AS VARCHAR(50)) WHEN 12 THEN CAST('#{215212}' AS VARCHAR(50)) WHEN 13 THEN CAST('#{220249}' AS VARCHAR(50)) WHEN 14 THEN CAST('#{309021}' AS VARCHAR(50)) WHEN 15 THEN CAST('#{309022}' AS VARCHAR(50)) WHEN 16 THEN CAST('#{309023}' AS VARCHAR(50)) WHEN 17 THEN CAST('#{309024}' AS VARCHAR(50)) WHEN 18 THEN CAST('#{309025}' AS VARCHAR(50)) WHEN 19 THEN CAST('#{309026}' AS VARCHAR(50)) WHEN 20 THEN CAST('#{309835}' AS VARCHAR(50)) ELSE NULL END AS NMLANGUAGE FROM GNACTIVITY GNACT INNER JOIN SVSURVEY SRV ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=SRV.CDSURVEY) INNER JOIN GNGENTYPE GNTP ON (GNSRV.CDSURVEYTYPE=GNTP.CDGENTYPE) LEFT JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEYEXEC=SRV.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTRESPONDENT, GNUSR.CDSURVEYEXEC FROM GNSURVEYEXECUSER GNUSR GROUP BY GNUSR.CDSURVEYEXEC) TEMPQTANSWER ON (TEMPQTANSWER.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTANSWERS, GNUSR.CDSURVEYEXEC FROM GNSURVEYEXECUSER GNUSR WHERE GNUSR.FGSTATUS IN (2,3) AND COALESCE(GNUSR.FGAVOID, 2)=2 GROUP BY GNUSR.CDSURVEYEXEC) TEMPQTANS ON (TEMPQTANS.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTQUESTION, GNQ.CDSURVEY FROM GNSURVEYQUESTION GNQ GROUP BY GNQ.CDSURVEY) TEMPQTQUESTION ON (TEMPQTQUESTION.CDSURVEY=SRV.CDSURVEY) LEFT JOIN (SELECT COUNT(1) AS QTCANCELED, GNSUEUSR.CDSURVEYEXEC FROM GNSURVEYEXECUSER GNSUEUSR WHERE GNSUEUSR.FGAVOID=1 GROUP BY GNSUEUSR.CDSURVEYEXEC) TEMPQTCANCEL ON (TEMPQTCANCEL.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) LEFT JOIN (SELECT MAX(GNSUEUSR.VLNOTE) AS VLMAXNOTE, MIN(GNSUEUSR.VLNOTE) AS VLMINNOTE, AVG(GNSUEUSR.VLNOTE) AS VLAVGNOTE, GNSUEUSR.CDSURVEYEXEC FROM GNSURVEYEXECUSER GNSUEUSR WHERE GNSUEUSR.FGSTATUS=3 AND COALESCE(GNSUEUSR.FGAVOID, 2)=2 GROUP BY GNSUEUSR.CDSURVEYEXEC) TEMPNOTES ON (TEMPNOTES.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTEXECUTED, AVG(GNUSR.QTTMTOTALEXECUSER) AS QTAVGEXECTIME, GNUSR.CDSURVEYEXEC FROM GNSURVEYEXECUSER GNUSR WHERE GNUSR.FGSTATUS IN (2,3) AND COALESCE(GNUSR.FGAVOID, 2)=2 GROUP BY GNUSR.CDSURVEYEXEC) TEMPQTRESPEXECANS ON (TEMPQTRESPEXECANS.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTSURVEYEXECMEMBER, SVM.CDSURVEYEXEC FROM SVSURVEYEXECMEMBER SVM GROUP BY SVM.CDSURVEYEXEC) TEMPQTRESP ON (TEMPQTRESP.CDSURVEYEXEC=SRV.CDSURVEYEXEC)  WHERE (GNTP.FGACTIVE=1 AND GNACT.CDISOSYSTEM=214 AND 1=1 AND ((GNTP.CDGENTYPE IN(<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, R05HRU5UWVBF, Q0RHRU5UWVBF, Q0RHRU5UWVBFT1dORVI=,, MjA4,)%>))) AND ((GNTP.CDGENTYPE IS NULL) OR (GNTP.CDGENTYPE IS NOT NULL AND (GNTP.CDTYPEROLE IS NULL OR EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.CDTYPEROLE=GNTP.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=15413 OR 15413=-1))))) AND SRV.FGMODEL=2)