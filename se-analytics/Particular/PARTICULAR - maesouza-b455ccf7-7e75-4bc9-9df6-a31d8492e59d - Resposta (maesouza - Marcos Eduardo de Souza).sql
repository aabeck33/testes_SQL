SELECT CASE WHEN GNEXECUSR.DTFINISHEXECUSER IS NOT NULL THEN CASE WHEN COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) IS NULL OR COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) >= GNEXECUSR.DTFINISHEXECUSER THEN 1 ELSE 3 END ELSE CASE WHEN (COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) IS NULL) THEN 1 WHEN COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN 2 ELSE 3 END END AS FGDEADLINE, CASE WHEN GNEXECUSR.DTFINISHEXECUSER IS NOT NULL THEN CASE WHEN COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) IS NULL OR COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) >= GNEXECUSR.DTFINISHEXECUSER THEN (CAST ('#{100900}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END ELSE CASE WHEN (COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) > DATEADD(DAY, 2, dateadd(dd, datediff(dd,0, getDate()), 0)) OR COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) IS NULL) THEN (CAST ('#{100900}' AS VARCHAR(255))) WHEN COALESCE(SRV.DTCLOSURE, GNACT.DTFINISHPLAN) >= dateadd(dd, datediff(dd,0, getDate()), 0) THEN (CAST ('#{201639}' AS VARCHAR(255))) ELSE (CAST ('#{100899}' AS VARCHAR(255))) END END AS NMFGDEADLINE, GNSRV.FGENABLED, GNACT.CDFAVORITE, CASE WHEN GNACT.FGSTATUS=3 AND GNSUREXEC.CDSURVEYEXEC IS NOT NULL THEN CASE WHEN GNSUREXEC.FGSTATUS=1 THEN 3 WHEN GNSUREXEC.FGSTATUS=2 THEN 7 END ELSE GNACT.FGSTATUS END FGSTATUS, GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.QTMINUTESREAL, GNACT.QTMINUTESPLAN, GNTP.IDGENTYPE, GNTP.NMGENTYPE, GNTP.CDGENTYPE, GNACT.CDGENACTIVITY AS CDACTIVITY, GNACT.CDGENACTIVITY, GNACT.CDASSOC, SRV.CDSURVEY, SRV.FGMULTANSWER, SRV.QTMAXATTEMPTS, GNSRV.CDSURVEYTYPE, SRV.FGPURPOSESURVEY, GNSUREXEC.CDSURVEYEXEC, GNSUREXEC.FGSTATUS AS FGSTATUSEXEC, GNSUREXEC.CDSURVEY AS CDSVEXEC, TEMPQTANS.QTANSWERS, TEMPQTANSWER.QTRESPONDENT, TEMPQTQUESTION.QTQUESTION, GNTP.IDGENTYPE AS IDSURVEYTYPE, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CASE WHEN GNTP.IDGENTYPE IS NOT NULL THEN CAST(GNTP.IDGENTYPE + ' - ' + GNTP.NMGENTYPE AS VARCHAR(350)) ELSE NULL END AS IDNMSURVEYTYPE, CAST(CAST(GNACT.QTMINUTESPLAN AS NUMERIC(19)) * 60000 AS NUMERIC(19)) AS QTTMPLAN, CAST(CAST(GNACT.QTMINUTESREAL AS NUMERIC(19)) * 60000 AS NUMERIC(19)) AS QTTMREAL, CASE SRV.FGPURPOSESURVEY WHEN 1 THEN '#{210771}' ELSE '#{101166}' END AS NMPURPOSESURVEY, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID, CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER, CASE GNACT.FGSTATUS  WHEN 1  THEN '#{100470}'  WHEN 2  THEN '#{200135}'  WHEN 3  THEN  CASE WHEN GNSUREXEC.FGSTATUS=2 THEN '#{209659}' ELSE '#{100481}'  END  WHEN 4  THEN '#{201912}'  WHEN 5  THEN '#{100667}'  WHEN 6  THEN '#{100481}'  WHEN 7  THEN '#{209659}'  WHEN 8  THEN '#{211594}'  WHEN 9  THEN '#{211595}'  WHEN 10  THEN '#{101006}'  WHEN 11  THEN '#{200383}' END AS NMSTATUS, GNEXECUSR.CDSURVEYEXECUSER, GNEXECUSR.VLNOTE, GNEXECUSR.FGAVOID, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.QTTMTOTALEXECUSER, GNEXECUSR.CDUSER AS CDUSEREXEC, GNEXECUSR.NMTOKEN, GNEXECUSR.DSREASON, GNEXECUSR.FGSTATUS AS FGANSWERSTATUS, GNEXECUSR.FGMULTANSWER AS FGMULTANSWERUSER, ADEU.CDEXTERNALUSER, ADEU.NMUSER AS NMEXTERNALUSER, ADEC.NMCOMPANY AS NMEXTERNALCOMPANY, AUSER.IDUSER, AUSER.NMUSER, AUSER.CDUSER, AUSER.NMUSEREMAIL, ADDEP.CDDEPARTMENT, ADDEP.IDDEPARTMENT, ADDEP.NMDEPARTMENT, ADPOS.CDPOSITION, ADPOS.IDPOSITION, ADPOS.NMPOSITION, GNSRV.FGANONYMOUSSURVEY, CASE WHEN GNEXECUSR.FGMULTANSWER=1 AND SRV.FGPURPOSESURVEY=2 THEN GNEXECUSR.NRATTEMPT END AS NRATTEMPT, CASE WHEN GNEXECUSR.NMPARTICIPANTEMAIL IS NULL THEN CAST(AUSER.DSUSEREMAIL AS VARCHAR(255)) ELSE GNEXECUSR.NMPARTICIPANTEMAIL END AS NMEMAIL, CASE WHEN AUSER.NMUSER IS NOT NULL THEN AUSER.NMUSER WHEN ADEU.NMUSER IS NOT NULL THEN ADEU.NMUSER WHEN GNEXECUSR.NMPARTICIPANT IS NOT NULL THEN GNEXECUSR.NMPARTICIPANT WHEN GNEXECUSR.NMPARTICIPANTEMAIL IS NOT NULL THEN GNEXECUSR.NMPARTICIPANTEMAIL ELSE '#{210696}' + ' ' + TEMPTB1.NRORDER END AS NMPARTICIPANT, CAST('1' AS VARCHAR(10)) AS NOANONYMOUS, CASE SRV.FGLANGUAGE WHEN 1 THEN CAST('#{215202}' AS VARCHAR(50)) WHEN 2 THEN CAST('#{215206}' AS VARCHAR(50)) WHEN 3 THEN CAST('#{215204}' AS VARCHAR(50)) WHEN 4 THEN CAST('#{215205}' AS VARCHAR(50)) WHEN 5 THEN CAST('#{215207}' AS VARCHAR(50)) WHEN 6 THEN CAST('#{215208}' AS VARCHAR(50)) WHEN 7 THEN CAST('#{215209}' AS VARCHAR(50)) WHEN 8 THEN CAST('#{215210}' AS VARCHAR(50)) WHEN 9 THEN CAST('#{215211}' AS VARCHAR(50)) WHEN 10 THEN CAST('#{217207}' AS VARCHAR(50)) WHEN 11 THEN CAST('#{215203}' AS VARCHAR(50)) WHEN 12 THEN CAST('#{215212}' AS VARCHAR(50)) WHEN 13 THEN CAST('#{220249}' AS VARCHAR(50)) WHEN 14 THEN CAST('#{304106}' AS VARCHAR(50)) ELSE NULL END AS NMLANGUAGE FROM GNACTIVITY GNACT INNER JOIN SVSURVEY SRV ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=SRV.CDSURVEY) INNER JOIN GNGENTYPE GNTP ON (GNSRV.CDSURVEYTYPE=GNTP.CDGENTYPE) INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEYEXEC=SRV.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTRESPONDENT, GNUSR.CDSURVEYEXEC FROM GNSURVEYEXECUSER GNUSR GROUP BY GNUSR.CDSURVEYEXEC) TEMPQTANSWER ON (TEMPQTANSWER.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTANSWERS, GNUSR.CDSURVEYEXEC FROM GNSURVEYEXECUSER GNUSR WHERE GNUSR.FGSTATUS IN (2,3) AND COALESCE(GNUSR.FGAVOID, 2)=2 GROUP BY GNUSR.CDSURVEYEXEC) TEMPQTANS ON (TEMPQTANS.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) LEFT JOIN (SELECT COUNT(1) AS QTQUESTION, GNQ.CDSURVEY FROM GNSURVEYQUESTION GNQ GROUP BY GNQ.CDSURVEY) TEMPQTQUESTION ON (TEMPQTQUESTION.CDSURVEY=SRV.CDSURVEY) INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNSUREXEC.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) LEFT JOIN ADEXTERNALUSER ADEU ON (ADEU.CDEXTERNALUSER=GNEXECUSR.CDEXTERNALUSER) LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=ADEU.CDCOMPANY) LEFT JOIN ADUSER AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT) LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION) LEFT JOIN (SELECT GNSU2.CDSURVEYEXEC, GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC ORDER /**/ BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 WHERE GNSU2.CDUSER IS NULL AND GNSU2.NMPARTICIPANT IS NULL) TEMPTB1 ON (TEMPTB1.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER)  WHERE (GNTP.FGACTIVE=1 AND GNACT.CDISOSYSTEM=214 AND 1=1 AND ((GNTP.CDGENTYPE IN(<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, R05HRU5UWVBF, Q0RHRU5UWVBF, Q0RHRU5UWVBFT1dORVI=,, MjI5,)%>))) AND ((GNTP.CDGENTYPE IS NULL) OR (GNTP.CDGENTYPE IS NOT NULL AND (GNTP.CDTYPEROLE IS NULL OR EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.CDTYPEROLE=GNTP.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=15413 OR 15413=-1))))) AND SRV.FGMODEL=2)