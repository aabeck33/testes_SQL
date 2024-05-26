SELECT TSTSK.CDTASK, TSTSK.CDWORKSPACE, TSTSK.CDFLOW, TSTSK.CDSTEP, TSTSK.NRTASK, TSTSK.NMTITLE, TSTSK.CDCREATEDBY, TSTSK.CDREPORTER, TSTSK.CDASSIGNEE, TSTSK.CDTASKTYPE, TSTSK.CDPRIORITY, TSTSK.OIDDESCRIPTION, TSTSK.DTDEADLINE, TSTSK.IDOBJECT, TSTSK.NRORDER, TSTSK.DTINSERT, TSTSK.DTUPDATE, TSTSK.DTFINISH, TSTSK.DTSTARTPLAN, TSTSK.DTSTART, TSTSK.NMUSERUPD, TSTSK.VLESTIMATE, TSTSK.CDSPRINT, TSTSK.FGARCHIVE, CASE WHEN TSTSK.DTDEADLINE IS NULL THEN NULL WHEN TSTSK.DTFINISH IS NULL THEN CASE WHEN TSTSK.DTDEADLINE=dateadd(dd, datediff(dd,0, getDate()), 0) OR TSTSK.DTDEADLINE=(dateadd(dd, datediff(dd,0, getDate()), 0) + 1) THEN 2 WHEN TSTSK.DTDEADLINE < dateadd(dd, datediff(dd,0, getDate()), 0) THEN 3 ELSE 1 END ELSE CASE WHEN TSTSK.DTDEADLINE < TSTSK.DTFINISH THEN 3 ELSE 1 END END AS FGDEADLINE, CASE WHEN TSTSK.DTDEADLINE IS NULL THEN '#{208091}' WHEN TSTSK.DTFINISH IS NULL THEN CASE WHEN TSTSK.DTDEADLINE=dateadd(dd, datediff(dd,0, getDate()), 0) OR TSTSK.DTDEADLINE=(dateadd(dd, datediff(dd,0, getDate()), 0) + 1) THEN '#{111460}' WHEN TSTSK.DTDEADLINE < dateadd(dd, datediff(dd,0, getDate()), 0) THEN '#{100899}' ELSE '#{100900}' END ELSE CASE WHEN TSTSK.DTDEADLINE < TSTSK.DTFINISH THEN '#{100899}' ELSE '#{100900}' END END AS NMDEADLINE, (SELECT E.IDOBJECT FROM TSTASK A INNER JOIN WFPROCESS B ON A.IDOBJECT=B.IDOBJECT INNER JOIN TSWORKSPACESTEP D ON A.CDWORKSPACE=D.CDWORKSPACE AND A.CDTASKTYPE=D.CDTASKTYPE AND A.CDSTEP=D.CDSTEP INNER JOIN WFSTRUCT E ON B.IDOBJECT=E.IDPROCESS AND D.CDSTRUCT=E.CDSTRUCTMODEL WHERE A.CDTASk=TSTSK.CDTASK AND A.CDWORKSPACE=TSTSK.CDWORKSPACE) AS IDACTIVITY, TSTSK.CDASSOC CDASSOCTASK, GNACT.CDASSOC, GNACT.CDGENACTIVITY, (SELECT COUNT(*) FROM GNTODOLIST LIST INNER JOIN GNTODOLISTITEM LISTITEM ON (LISTITEM.CDTODOLIST=LIST.CDTODOLIST) WHERE LISTITEM.FGDONE=1 AND LIST.CDASSOC=GNACT.CDASSOC) AS QTCHECKEDAMOUNT, (SELECT COUNT(*) FROM GNTODOLIST LIST INNER JOIN GNTODOLISTITEM LISTITEM ON (LISTITEM.CDTODOLIST=LIST.CDTODOLIST) WHERE LIST.CDASSOC=GNACT.CDASSOC) AS QTTOTALAMOUNT, WKS.NMPREFIX + '-' + CAST(TSTSK.NRTASK AS VARCHAR(255)) AS IDENTIFIER_OLAP, CREATEDBY.NMUSER NMCREATEDBY, CREATEDBY.IDUSER IDCREATEDBY, REPORTER.NMUSER NMREPORTER, REPORTER.IDUSER IDREPORTER, ASSIGNEE.NMUSER NMASSIGNEE, ASSIGNEE.IDUSER IDASSIGNEE, PRIORITY.NMPRIORITY, PRIORITY.NRORDER NRORDERPRIORITY, PRIORITY.IDICON PRIORITYICON, PRIORITY.FGSTATUS, TYPE.NMTASKTYPE, TYPE.IDICON TYPEICON, WKS.NMPREFIX, WKS.NMWORKSPACE, WKS.IDICON WORKSPACEICON, WKS.FGMETHODOLOGY, STEP.NMSTEP, TFSTP.FGTYPE, WFL.NMFLOW, SEDESC.TXDATA AS DESCRIPTION, TSSPT.NMTITLE AS NMSPRINT, TSSPT.NRORDER AS NRORDERSPRINT, TSSPT.FGSTATUS AS FGSPRINTSTATUS, TSSPT.DSDESCRIPTION AS DSSPRINT, TSSPT.BNSTART AS BNSPRINTSTART, TSSPT.BNFINISH AS BNSPRINTFINISH, CASE WHEN (SELECT COUNT(CDATTRIBUTE) FROM TSFLOWATTRIB WHERE CDFLOW=WFL.CDFLOW) > 0 THEN 1 ELSE 2 END AS FGHASATTRIBUTE, CASE WHEN TSTSKFLW.CDTASK IS NOT NULL THEN 1 ELSE 2 END AS FGTASKFOLLOW, DATEADD(SECOND, (TSSPT.BNSTART / 1000) +'<!%FUNC("com.softexpert.utils.TimeZoneHelper")%>', '1970-01-01 00:00:00') AS DTSPRINTSTART, DATEADD(SECOND, (TSSPT.BNFINISH / 1000) +'<!%FUNC("com.softexpert.utils.TimeZoneHelper")%>', '1970-01-01 00:00:00') AS DTSPRINTFINISH FROM TSTASK TSTSK INNER JOIN ADUSER CREATEDBY ON (TSTSK.CDCREATEDBY=CREATEDBY.CDUSER) INNER JOIN ADUSER REPORTER ON (TSTSK.CDREPORTER=REPORTER.CDUSER) LEFT JOIN ADUSER ASSIGNEE ON (TSTSK.CDASSIGNEE=ASSIGNEE.CDUSER) INNER JOIN TSTASKTYPE TYPE ON (TSTSK.CDTASKTYPE=TYPE.CDTASKTYPE) INNER JOIN TSPRIORITY PRIORITY ON (TSTSK.CDPRIORITY=PRIORITY.CDPRIORITY) INNER JOIN TSWORKSPACE WKS ON (TSTSK.CDWORKSPACE=WKS.CDWORKSPACE) INNER JOIN TSWORKSPACEPERM WKSP ON (TSTSK.CDWORKSPACE=WKSP.CDWORKSPACE) INNER JOIN TSSTEP STEP ON (TSTSK.CDSTEP=STEP.CDSTEP) INNER JOIN TSFLOW WFL ON (TSTSK.CDFLOW=WFL.CDFLOW) LEFT JOIN TSFLOWSTEP TFSTP ON (TSTSK.CDSTEP=TFSTP.CDSTEP AND TSTSK.CDFLOW=TFSTP.CDFLOW) LEFT JOIN SERICHTEXT SERICHDESC ON (TSTSK.OIDDESCRIPTION=SERICHDESC.OID) LEFT JOIN SETEXT SEDESC ON (SERICHDESC.OIDTEXTCONTENT=SEDESC.OID) INNER JOIN WFPROCESS WFPROC ON (TSTSK.IDOBJECT=WFPROC.IDOBJECT) INNER JOIN GNACTIVITY GNACT ON (WFPROC.CDGENACTIVITY=GNACT.CDGENACTIVITY) LEFT JOIN TSSPRINT TSSPT ON (TSTSK.CDSPRINT=TSSPT.CDSPRINT AND WKS.FGMETHODOLOGY=2) LEFT JOIN TSTASKFOLLOWER TSTSKFLW ON (TSTSK.CDTASK=TSTSKFLW.CDTASK AND TSTSKFLW.CDUSER=15611)  WHERE (( WKSP.FGLISTPUBLIC=1 OR (WKSP.FGLISTASSIGNEE=1 AND TSTSK.CDASSIGNEE='15611') OR (WKSP.FGLISTREPORTER=1 AND TSTSK.CDREPORTER='15611') OR EXISTS (SELECT 1 FROM ADTEAMMEMBER ADTM WHERE ADTM.CDTEAM=WKS.CDTEAMRESPONSIBLE AND ADTM.CDUSER='15611' UNION SELECT 1 FROM ADTEAMMEMBER ADTM WHERE ADTM.CDTEAM=WKS.CDTEAM AND ADTM.CDUSER='15611' AND WKSP.FGLISTTEAM=1)))