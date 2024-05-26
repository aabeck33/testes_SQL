SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(NULL AS VARCHAR(50)) AS DSREASON, NULL AS DTSTARTEXECUSER, NULL AS DTFINISHEXECUSER, CAST(NULL AS NUMERIC) AS VLNOTE, CAST(NULL AS NUMERIC(19)) AS QTTMTEXECUSER, NULL AS NMFGAVOID, NULL AS STATUS, NULL AS NMDEPARTMENT, NULL AS NMPOSITION, NULL AS NMEMAIL, NULL AS IDUSER, NULL AS NMPARTICIPANT, CAST(NULL AS INTEGER) AS CDCOMPANY, NULL AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 0 AS NRONE, 0 AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYSESSION GNSS INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYSESSION=GNSS.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEY=GNSRV.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSUREXEC.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNQ.FGTYPEQUESTION IN (1, 2) AND NOT EXISTS (SELECT 1 FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) WHERE GNSEQ.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNSA.FGSELECTED=1 AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER)) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(GNEXECUSR.DSREASON AS VARCHAR(MAX)) AS DSREASON, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.VLNOTE , CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMDEPARTMENT, ADDEP.NMDEPARTMENT) END AS NMDEPARTMENT, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMPOSITION, ADPOS.NMPOSITION) END AS NMPOSITION, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(CAST(AUSER.DSUSEREMAIL AS VARCHAR(255)), CAST(AUSER.NMUSEREMAIL AS VARCHAR(255)), GNEXECUSR.NMPARTICIPANTEMAIL) END AS NMEMAIL, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN AUSER.IDUSER END AS IDUSER, CASE WHEN GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4 THEN '#{210696}' + ' ' + TEMPORDERANO.NRORDER ELSE COALESCE(AUSER.NMUSER, GNEXECUSR.NMPARTICIPANT, GNEXECUSR.NMPARTICIPANTEMAIL, '#{210696}' + ' ' + TEMPORDERANO.NRORDER) END AS NMPARTICIPANT, ADEC.CDCOMPANY, CASE WHEN ADEC.IDCOMMERCIAL IS NOT NULL THEN ADEC.IDCOMMERCIAL+' - '+ADEC.NMCOMPANY ELSE NULL END AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 1 AS NRONE, CASE WHEN GNSA.FGSELECTED=1 THEN 1 ELSE 0 END AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(GNSA.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYQUESTION=GNSEQ.CDSURVEYQUESTION) INNER JOIN GNSURVEYSESSION GNSS ON (GNSS.CDSURVEYSESSION=GNSQ.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER) INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNEXECUSR.CDSURVEYEXECUSER=GNSEQ.CDSURVEYEXECUSER) INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) WHERE GNS.CDSURVEY IN (967,961,963,965,969,971,973,975,977,979)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) LEFT JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=AUSER.CDEXTERNALUSER) LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=COALESCE(GNEXECUSR.CDCOMPANY, ADEU.CDCOMPANY)) LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT AND GNEXECUSR.CDUSER IS NOT NULL) LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION AND GNEXECUSR.CDUSER IS NOT NULL)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSEQ.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNQ.FGTYPEQUESTION IN (1, 2) AND GNSA.FGSELECTED=1) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(NULL AS VARCHAR(50)) AS DSREASON, NULL AS DTSTARTEXECUSER, NULL AS DTFINISHEXECUSER, CAST(NULL AS NUMERIC) AS VLNOTE, CAST(NULL AS NUMERIC(19)) AS QTTMTEXECUSER, NULL AS NMFGAVOID, NULL AS STATUS, NULL AS NMDEPARTMENT, NULL AS NMPOSITION, NULL AS NMEMAIL, NULL AS IDUSER, NULL AS NMPARTICIPANT, CAST(NULL AS INTEGER) AS CDCOMPANY, NULL AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 0 AS NRONE, 0 AS FGSELECTED, CAST(NULL AS VARCHAR(50)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, CAST(NULL AS NUMERIC) AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYSESSION GNSS INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYSESSION=GNSS.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEY=GNSRV.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSUREXEC.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNQ.FGTYPEQUESTION IN (3, 6, 7, 8, 9) AND NOT EXISTS (SELECT 1 FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) WHERE GNSEQ.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND (GNSA.DSOBSERVATION IS NOT NULL OR GNSA.DTDATE IS NOT NULL OR GNSA.QTTIME IS NOT NULL) AND GNSEQ.CDSURVEYQUESTION=GNSQ.CDSURVEYQUESTION)) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(GNEXECUSR.DSREASON AS VARCHAR(MAX)) AS DSREASON, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.VLNOTE , CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMDEPARTMENT, ADDEP.NMDEPARTMENT) END AS NMDEPARTMENT, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMPOSITION, ADPOS.NMPOSITION) END AS NMPOSITION, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(CAST(AUSER.DSUSEREMAIL AS VARCHAR(255)), CAST(AUSER.NMUSEREMAIL AS VARCHAR(255)), GNEXECUSR.NMPARTICIPANTEMAIL) END AS NMEMAIL, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN AUSER.IDUSER END AS IDUSER, CASE WHEN GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4 THEN '#{210696}' + ' ' + TEMPORDERANO.NRORDER ELSE COALESCE(AUSER.NMUSER, GNEXECUSR.NMPARTICIPANT, GNEXECUSR.NMPARTICIPANTEMAIL, '#{210696}' + ' ' + TEMPORDERANO.NRORDER) END AS NMPARTICIPANT, ADEC.CDCOMPANY, CASE WHEN ADEC.IDCOMMERCIAL IS NOT NULL THEN ADEC.IDCOMMERCIAL+' - '+ADEC.NMCOMPANY ELSE NULL END AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 1 AS NRONE, CASE WHEN (GNQ.FGTYPEQUESTION IN (3,6) AND GNSA.DSOBSERVATION IS NOT NULL) OR (GNQ.FGTYPEQUESTION IN (7,8) AND GNSA.DTDATE IS NOT NULL) OR (GNQ.FGTYPEQUESTION=9 AND GNSA.QTTIME IS NOT NULL) THEN 1 ELSE 0 END AS FGSELECTED, CASE WHEN GNQ.FGTYPEQUESTION IN (3,6) THEN CAST(GNSA.DSOBSERVATION AS VARCHAR(MAX)) WHEN GNQ.FGTYPEQUESTION=7 THEN CAST (CAST(GNSA.DTDATE AS DATE) AS VARCHAR(50)) + ' ' + CASE WHEN GNSA.QTTIME > 0 THEN CAST(CEILING((GNSA.QTTIME/60)) AS VARCHAR(50)) + ':' + COALESCE( CASE WHEN (GNSA.QTTIME % 60) < 10 THEN '0' END,'') + CAST(GNSA.QTTIME % 60 AS VARCHAR(50)) ELSE CAST(NULL AS VARCHAR(50)) END WHEN GNQ.FGTYPEQUESTION=8 THEN CAST (CAST(GNSA.DTDATE AS DATE) AS VARCHAR(50)) WHEN GNQ.FGTYPEQUESTION=9 THEN CASE WHEN GNSA.QTTIME > 0 THEN CAST(CEILING((GNSA.QTTIME/60)) AS VARCHAR(50)) + ':' + COALESCE( CASE WHEN (GNSA.QTTIME % 60) < 10 THEN '0' END,'') + CAST(GNSA.QTTIME % 60 AS VARCHAR(50)) ELSE CAST(NULL AS VARCHAR(50)) END ELSE CAST(NULL AS VARCHAR(50)) END AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, CAST(NULL AS NUMERIC) AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYQUESTION=GNSEQ.CDSURVEYQUESTION) INNER JOIN GNSURVEYSESSION GNSS ON (GNSS.CDSURVEYSESSION=GNSQ.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNEXECUSR.CDSURVEYEXECUSER=GNSEQ.CDSURVEYEXECUSER) INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) WHERE GNS.CDSURVEY IN (967,961,963,965,969,971,973,975,977,979)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) LEFT JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=AUSER.CDEXTERNALUSER) LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=COALESCE(GNEXECUSR.CDCOMPANY, ADEU.CDCOMPANY)) LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT AND GNEXECUSR.CDUSER IS NOT NULL) LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION AND GNEXECUSR.CDUSER IS NOT NULL)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSEQ.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNQ.FGTYPEQUESTION IN (3, 6, 7, 8, 9) AND (GNSA.DSOBSERVATION IS NOT NULL OR GNSA.DTDATE IS NOT NULL OR GNSA.QTTIME IS NOT NULL)) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(NULL AS VARCHAR(50)) AS DSREASON, NULL AS DTSTARTEXECUSER, NULL AS DTFINISHEXECUSER, CAST(NULL AS NUMERIC) AS VLNOTE, CAST(NULL AS NUMERIC(19)) AS QTTMTEXECUSER, NULL AS NMFGAVOID, NULL AS STATUS, NULL AS NMDEPARTMENT, NULL AS NMPOSITION, NULL AS NMEMAIL, NULL AS IDUSER, NULL AS NMPARTICIPANT, CAST(NULL AS INTEGER) AS CDCOMPANY, NULL AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 0 AS NRONE, 0 AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(3850)) AS DSMATRIX, CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + '.' + CAST(GNMATRIX.NRORDER AS VARCHAR(50)) + ' ' + CAST(COALESCE(GNMATRIX.DSQUESTION, GNQ.DSQUESTION) AS VARCHAR(3800)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYSESSION GNSS INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYSESSION=GNSS.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEY=GNSRV.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) INNER JOIN GNQUESTION GNMATRIX ON (GNMATRIX.CDQUESTIONOWNER=GNQ.CDQUESTION)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSUREXEC.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNQ.FGTYPEQUESTION IN (4, 5) AND NOT EXISTS (SELECT 1 FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) WHERE GNSEQ.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNSA.FGSELECTED=1 AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER AND GNSEQ.CDMATRIXQUESTION=GNMATRIX.CDQUESTION)) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(GNEXECUSR.DSREASON AS VARCHAR(MAX)) AS DSREASON, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.VLNOTE , CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMDEPARTMENT, ADDEP.NMDEPARTMENT) END AS NMDEPARTMENT, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMPOSITION, ADPOS.NMPOSITION) END AS NMPOSITION, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(CAST(AUSER.DSUSEREMAIL AS VARCHAR(255)), CAST(AUSER.NMUSEREMAIL AS VARCHAR(255)), GNEXECUSR.NMPARTICIPANTEMAIL) END AS NMEMAIL, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN AUSER.IDUSER END AS IDUSER, CASE WHEN GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4 THEN '#{210696}' + ' ' + TEMPORDERANO.NRORDER ELSE COALESCE(AUSER.NMUSER, GNEXECUSR.NMPARTICIPANT, GNEXECUSR.NMPARTICIPANTEMAIL, '#{210696}' + ' ' + TEMPORDERANO.NRORDER) END AS NMPARTICIPANT, ADEC.CDCOMPANY, CASE WHEN ADEC.IDCOMMERCIAL IS NOT NULL THEN ADEC.IDCOMMERCIAL+' - '+ADEC.NMCOMPANY ELSE NULL END AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 1 AS NRONE, CASE WHEN GNSA.FGSELECTED=1 THEN 1 ELSE 0 END AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(3850)) AS DSMATRIX, CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + '.' + CAST(GNMATRIX.NRORDER AS VARCHAR(50)) + ' ' + CAST(COALESCE(GNMATRIX.DSQUESTION, GNQ.DSQUESTION) AS VARCHAR(3800)) AS DSQUESTION, CAST(GNSA.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYQUESTION=GNSEQ.CDSURVEYQUESTION) INNER JOIN GNSURVEYSESSION GNSS ON (GNSS.CDSURVEYSESSION=GNSQ.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER) INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNEXECUSR.CDSURVEYEXECUSER=GNSEQ.CDSURVEYEXECUSER) INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) WHERE GNS.CDSURVEY IN (967,961,963,965,969,971,973,975,977,979)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) LEFT JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=AUSER.CDEXTERNALUSER) LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=COALESCE(GNEXECUSR.CDCOMPANY, ADEU.CDCOMPANY)) LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT AND GNEXECUSR.CDUSER IS NOT NULL) LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION AND GNEXECUSR.CDUSER IS NOT NULL) INNER JOIN GNQUESTION GNMATRIX ON (GNMATRIX.CDQUESTIONOWNER=GNQ.CDQUESTION AND GNSEQ.CDMATRIXQUESTION=GNMATRIX.CDQUESTION)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSEQ.CDSURVEYEXEC IN (229,226,227,228,230,231,232,233,234,235) AND GNQ.FGTYPEQUESTION IN (4, 5) AND GNSA.FGSELECTED=1)