SELECT TU.CDUSER, CASE WHEN USU.CDEXTERNALUSER IS NULL THEN USU.IDUSER ELSE NULL END AS IDUSER , USU.NMUSER , USU.NMUSEREMAIL AS NMEMAIL, USU.CDEXTERNALUSER, TU.VLPROGRESS , T.IDTRAIN , T.NMTRAIN , CAST(T.IDTRAIN + ' - ' + T.NMTRAIN AS VARCHAR(305)) AS IDNMTRAIN, ADC.IDCOMMERCIAL , ADEC.IDCOMMERCIAL AS IDEXTERNALCOMPANY , ADEC.NMCOMPANY, ADEC.NMCOMPANY AS NMEXTERNALCOMPANY , TU.VLNOTE , TU.VLFREQ , T.DTPROGSTART , T.DTPROGFINISH, T.VLCOSTPROG AS VLQTPROGCOST , T.QTPARTPROG , T.QTTMTOTPROG , T.DTREALSTART , T.DTREALFINISH, T.VLCOSTREAL AS VLQTREALCOST , T.QTPARTREAL , T.QTTMTOTREAL , T.FGCANCEL , T.FGINVALID, T.CDTRAIN , T.CDCOURSE , T.DTVALID , C.IDCOURSE , C.NMCOURSE , CT.CDGENTYPE AS CDCOURSETYPE, CT.IDGENTYPE AS IDCOURSETYPE, CT.NMGENTYPE AS NMCOURSETYPE, CASE WHEN T.FGCANCEL=1 THEN (CAST ('#{104230}' AS VARCHAR(255))) WHEN T.FGINVALID=1 THEN (CAST ('#{110951}' AS VARCHAR(255))) WHEN T.FGSTATUS=1 THEN (CAST ('#{100470}' AS VARCHAR(255))) WHEN T.FGSTATUS=2 THEN (CAST ('#{102327}' AS VARCHAR(255))) WHEN T.FGSTATUS=3 THEN (CAST ('#{217835}' AS VARCHAR(255))) WHEN T.FGSTATUS=4 THEN (CAST ('#{201912}' AS VARCHAR(255))) WHEN T.FGSTATUS=5 THEN (CAST ('#{100481}' AS VARCHAR(255))) WHEN T.FGSTATUS=7 THEN (CAST ('#{105053}' AS VARCHAR(255))) WHEN T.FGSTATUS=8 THEN (CAST ('#{100667}' AS VARCHAR(255))) WHEN T.FGSTATUS=10 THEN (CAST ('#{100940}' AS VARCHAR(255))) END AS NMFGSTATUS , 1  AS FGTYPETRAIN, TU.CDTRAINUSER, TR.FGTRAUSRCONTACCESS , ADEU.NMPOSITION AS NMEXTERNALPOSITION, ADEU.NMDEPARTMENT AS NMEXTERNALDEPARTMENT, CASE WHEN T.DTVALID < dateadd(dd, datediff(dd,0, getDate()), 0) THEN 1 ELSE 2 END AS FGVALID, (CAST(T.QTTMTOTPROG AS NUMERIC)*60000) AS QTTOTPROGHOURS, (CAST(T.QTTMTOTREAL AS NUMERIC)*60000) AS QTTOTREALHOURS, TCONF.IDCONFIGURATION+ ' - ' +TCONF.NMCONFIGURATION AS IDNMCONFIGURATION, CT.IDGENTYPE+ ' - ' +CT.NMGENTYPE AS IDNMTYPECOURSE, C.IDCOURSE+ ' - ' +C.NMCOURSE AS IDNMCOURSE, CASE WHEN T.FGCANCEL=1 THEN (CAST ('#{104230}' AS VARCHAR(255))) WHEN T.FGINVALID=1 THEN (CAST ('#{110951}' AS VARCHAR(255))) WHEN T.FGSTATUS=1 THEN (CAST ('#{100470}' AS VARCHAR(255))) WHEN T.FGSTATUS=2 THEN (CAST ('#{102327}' AS VARCHAR(255))) WHEN T.FGSTATUS=3 THEN (CAST ('#{217835}' AS VARCHAR(255))) WHEN T.FGSTATUS=4 THEN (CAST ('#{201912}' AS VARCHAR(255))) WHEN T.FGSTATUS=5 THEN (CAST ('#{100481}' AS VARCHAR(255))) WHEN T.FGSTATUS=7 THEN (CAST ('#{105053}' AS VARCHAR(255))) WHEN T.FGSTATUS=8 THEN (CAST ('#{100667}' AS VARCHAR(255))) WHEN T.FGSTATUS=10 THEN (CAST ('#{100940}' AS VARCHAR(255))) END AS IDSTATUS, CASE WHEN TRM.IDTRAININGMETHOD IS NOT NULL THEN CAST(TRM.IDTRAININGMETHOD + ' - ' + TRM.NMTRAININGMETHOD AS VARCHAR(350)) ELSE NULL END AS IDNMTRAININGMETHOD, CASE WHEN TU.FGRESULT=1 THEN (CAST ('#{217786}' AS VARCHAR(255))) WHEN TU.FGRESULT=2 THEN (CAST ('#{217787}' AS VARCHAR(255))) WHEN COALESCE(TU.FGRESULT, 3)=3 THEN (CAST ('#{101296}' AS VARCHAR(255))) END AS NMFGRESULT, CASE WHEN TEMPQTINST.QTINSTRUCTOR > 1 THEN (CAST ('#{300482}' AS VARCHAR(255))) WHEN ( TEMPQTINST.QTINSTRUCTOR=1 AND TEMPINST.IDINSTRUCTOR IS NOT NULL) THEN CAST(TEMPINST.IDINSTRUCTOR + ' - ' + TEMPINST.NMINSTRUCTOR AS VARCHAR(350)) ELSE TEMPINST.NMINSTRUCTOR END AS NMUSERINSTRUCTOR, CASE WHEN T.FGPARTTYPE=1 THEN (CAST ('#{207292}' AS VARCHAR(255))) WHEN T.FGPARTTYPE=2 THEN (CAST ('#{105415}' AS VARCHAR(255))) END AS IDPARTTYPE, CASE WHEN T.FGEXECTYPE=1 THEN CAST('#{101417}' AS VARCHAR(50)) ELSE CAST('#{101419}' AS VARCHAR(50)) END AS NMFGEXECTYPE, USU.NMUSER AS NMPARTICIPANT, CAST( CASE WHEN USU.CDEXTERNALUSER IS NULL THEN '#{200835}' WHEN USU.CDEXTERNALUSER IS NOT NULL THEN '#{303826}' ELSE '#{300578}' END AS VARCHAR(4000)) AS NMUSERRESPTYPE, CASE WHEN AP.IDPOSITION IS NOT NULL THEN CAST(AP.IDPOSITION + ' - ' + AP.NMPOSITION AS VARCHAR(310)) WHEN ADEU.NMPOSITION IS NOT NULL THEN ADEU.NMPOSITION ELSE NULL END AS IDNMPOSITION, CASE WHEN AD.IDDEPARTMENT IS NOT NULL THEN CAST (AD.IDDEPARTMENT + ' - ' + AD.NMDEPARTMENT AS VARCHAR(310)) WHEN ADEU.NMDEPARTMENT IS NOT NULL THEN ADEU.NMDEPARTMENT ELSE NULL END AS IDNMDEPARTMENT FROM TRTRAINING T INNER JOIN TRCONFIGURATION TCONF ON (T.CDCONFIGURATION=TCONF.CDCONFIGURATION) INNER JOIN TRCOURSE C ON (T.CDCOURSE=C.CDCOURSE) INNER JOIN TRTRAINUSER TU ON (T.CDTRAIN=TU.CDTRAIN) LEFT OUTER JOIN ADALLUSERS USU ON (TU.CDUSER=USU.CDUSER) INNER JOIN GNGENTYPE CT ON (C.CDCOURSETYPE=CT.CDGENTYPE) LEFT OUTER JOIN (/* Pares */ SELECT ADU1.CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADUSER ADU1 INNER JOIN ADUSER ADU2 ON (ADU2.CDUSER <> ADU1.CDUSER) INNER JOIN ADPARAMS ADP0 ON (ADP0.CDPARAM=3  AND ADP0.CDISOSYSTEM=153  AND ADP0.VLPARAM=1) INNER JOIN ADPARAMS ADP1 ON (ADP1.CDPARAM=20  AND ADP1.CDISOSYSTEM=153) INNER JOIN ADPARAMS ADP2 ON (ADP2.CDPARAM=21  AND ADP2.CDISOSYSTEM=153) INNER JOIN ADPARAMS ADP3 ON (ADP3.CDPARAM=22  AND ADP3.CDISOSYSTEM=153) WHERE 1=1 AND EXISTS ( SELECT 1  FROM ADMINISTRATION  WHERE ADU2.CDLEADER=ADU1.CDLEADER  AND ADP1.VLPARAM=1  AND (ADP2.VLPARAM <> 1 OR ADP3.VLPARAM=2) /*sub*/UNION/*sub*/ ALL SELECT 1  FROM ADUSERDEPTPOS ADUDP1 INNER JOIN ADUSERDEPTPOS ADUDP2 ON ( ADUDP2.CDDEPARTMENT=ADUDP1.CDDEPARTMENT AND ADUDP2.CDPOSITION=ADUDP1.CDPOSITION)  WHERE ADUDP1.CDUSER=ADU1.CDUSER  AND ADUDP2.CDUSER=ADU2.CDUSER  AND ADP2.VLPARAM=1  AND (ADP1.VLPARAM <> 1 OR ADP3.VLPARAM=2) /*sub*/UNION/*sub*/ ALL SELECT 1  FROM ADUSERDEPTPOS ADUDP1 INNER JOIN ADUSERDEPTPOS ADUDP2 ON ( ADUDP2.CDDEPARTMENT=ADUDP1.CDDEPARTMENT AND ADUDP2.CDPOSITION=ADUDP1.CDPOSITION)  WHERE ADUDP1.CDUSER=ADU1.CDUSER  AND ADUDP2.CDUSER=ADU2.CDUSER  AND ADU2.CDLEADER=ADU1.CDLEADER  AND ADP1.VLPARAM=1  AND ADP2.VLPARAM=1  AND ADP3.VLPARAM=1) AND ADU2.CDUSER=<!%CDUSER%> GROUP BY ADU1.CDUSER /*sub*/UNION/*sub*/ /* Lider */ SELECT ADL.CDLEADER AS CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADUSER ADL INNER JOIN ADPARAMS ADP ON (ADP.CDPARAM=4  AND ADP.CDISOSYSTEM=153  AND ADP.VLPARAM=1) WHERE ADL.CDLEADER IS NOT NULL AND ADL.CDUSER=<!%CDUSER%> GROUP BY ADL.CDLEADER /*sub*/UNION/*sub*/ /* Liderados */ SELECT T.CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM (SELECT ADU1.CDUSER, ADU0.CDUSER AS CDLEADER, 1 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU2.CDUSER, ADU0.CDUSER AS CDLEADER, 2 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU3.CDUSER, ADU0.CDUSER AS CDLEADER, 3 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) INNER JOIN ADUSER ADU3 ON (ADU3.CDLEADER=ADU2.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU4.CDUSER, ADU0.CDUSER AS CDLEADER, 4 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) INNER JOIN ADUSER ADU3 ON (ADU3.CDLEADER=ADU2.CDUSER) INNER JOIN ADUSER ADU4 ON (ADU4.CDLEADER=ADU3.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU5.CDUSER, ADU0.CDUSER AS CDLEADER, 5 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) INNER JOIN ADUSER ADU3 ON (ADU3.CDLEADER=ADU2.CDUSER) INNER JOIN ADUSER ADU4 ON (ADU4.CDLEADER=ADU3.CDUSER) INNER JOIN ADUSER ADU5 ON (ADU5.CDLEADER=ADU4.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%>) T INNER JOIN ADPARAMS ADP ON (ADP.CDPARAM=2  AND ADP.CDISOSYSTEM=153  AND ADP.VLPARAM=1) GROUP BY T.CDUSER /*sub*/UNION/*sub*/ /* Proprio usuario */ SELECT CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADMINISTRATION /*sub*/UNION/*sub*/ /* Equipe de controle por unidade organizacional */ SELECT ADUDPPOS.CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADUSERDEPTPOS ADUDPPOS INNER JOIN ADDEPTSUBLEVEL ADDPSUB ON (ADDPSUB.CDDEPT=ADUDPPOS.CDDEPARTMENT) INNER JOIN ADDEPARTMENT ADP ON (ADP.CDDEPARTMENT=ADDPSUB.CDOWNER) INNER JOIN ADTEAMUSER ADTU ON (ADTU.CDTEAM=ADP.CDSECURITYTEAM) WHERE ADTU.CDUSER=<!%CDUSER%> GROUP BY ADUDPPOS.CDUSER) USERPERM ON (USERPERM.CDUSER=USU.CDUSER AND USERPERM.CDUSERDATA=<!%CDUSER%>) LEFT OUTER JOIN ADDEPARTMENT AD ON (TU.CDDEPARTMENT=AD.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION AP ON (TU.CDPOSITION=AP.CDPOSITION) INNER JOIN TRCONTENTCONFIG TR ON (TR.CDCONTENTCONFIG=T.CDCONTENTCONFIG) LEFT OUTER JOIN ADCOMPANY ADC ON (ADC.CDCOMPANY=T.CDCOMPANY) LEFT OUTER JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=USU.CDEXTERNALUSER) LEFT OUTER JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=ADEU.CDCOMPANY) LEFT OUTER JOIN (SELECT COUNT(TRTI.CDTRAININSTRUCTOR) AS QTINSTRUCTOR, TRTI.CDTRAIN FROM TRTRAININSTRUCTOR TRTI GROUP BY TRTI.CDTRAIN) TEMPQTINST ON (TEMPQTINST.CDTRAIN=T.CDTRAIN) LEFT OUTER JOIN (SELECT TRT.CDTRAIN, TRT.CDUSERINST, COALESCE (TRT.NMINSTRUCTOR, USU.NMUSER) AS NMINSTRUCTOR, USU.IDUSER AS IDINSTRUCTOR, TRT.FGINSTRUCTORTYPE, TRT.QTWORKLOAD FROM TRTRAININSTRUCTOR TRT LEFT OUTER JOIN ADALLUSERS USU ON ( TRT.CDUSERINST=USU.CDUSER) WHERE EXISTS (SELECT 1 FROM TRTRAININSTRUCTOR TRTI WHERE TRTI.CDTRAIN=TRT.CDTRAIN GROUP BY TRTI.CDTRAIN HAVING COUNT(TRTI.CDTRAININSTRUCTOR)=1)) TEMPINST ON (TEMPINST.CDTRAIN=T.CDTRAIN) LEFT OUTER JOIN TRTRAININGMETHOD TRM ON (TRM.CDTRAININGMETHOD=T.CDTRAININGMETHOD) WHERE T.FGPROFILE <> 1 AND COALESCE(T.FGCANCEL,2) <> 1 AND COALESCE(T.FGINVALID,2) <> 1 AND USU.FGUSERENABLED=1 AND ((AD.CDDEPARTMENT IN(<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, QURERVBBUlRNRU5U, Q0RERVBBUlRNRU5U, Q0RERVBUT1dORVI=,, MzI2, QUQ=)%>))) AND EXISTS (SELECT 1  FROM ADUSERDEPTPOS ADDPTP  WHERE ADDPTP.CDUSER=USU.CDUSER AND ((ADDPTP.CDDEPARTMENT IN(<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, QURERVBBUlRNRU5U, Q0RERVBBUlRNRU5U, Q0RERVBUT1dORVI=,, MzI2, QUREUFRQ)%>)))) AND (EXISTS (SELECT ADT1.CDUSER FROM ADTEAMUSER ADT1  INNER JOIN ADPARAMS ADP  ON (ADP.CDPARAM=1 AND ADP.CDISOSYSTEM=153 AND ADP.VLPARAM=ADT1.CDTEAM) WHERE ADT1.CDUSER=<!%CDUSER%>)  OR USERPERM.CDUSER IS NOT NULL)