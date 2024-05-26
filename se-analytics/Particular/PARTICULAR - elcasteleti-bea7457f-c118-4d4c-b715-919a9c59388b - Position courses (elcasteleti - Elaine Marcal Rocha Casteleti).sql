SELECT U.CDUSER, U.IDUSER, U.NMUSER, CAST( '<font cduser=' + CAST(U.CDUSER AS VARCHAR(50)) +' title=''View employee details'' onclick=''createTooltipForGroupColumnUser(this);event.preventDefault();event.stopPropagation();''>' + U.IDUSER + ' - ' + U.NMUSER + '</font>' +'<span>'+CAST(AUDP.FGDEFAULTDEPTPOS AS VARCHAR(50))+'</span>'+ '<br><div>'+''+'<label>Dept./Position:</label> ' + D.IDDEPARTMENT + ' - ' + D.NMDEPARTMENT + '/' + P.IDPOSITION + ' - ' + P.NMPOSITION + CASE WHEN AUDP.FGDEFAULTDEPTPOS=1 THEN ' (Default)' ELSE '' END +'</div>' AS VARCHAR(4000)) AS NMUSERINFO2, '<label class=''x-grid-group-header-label-ct''>' + '<div class=''x-grid-group-header-div-flex-ct''>' + '<div class=''x-grid-group-header-div-flex-1''>' + '<div class=''profile x-grid-group-header-div-flex-ct''>' + '<div class=''x-grid-group-header-div-avatar-ct''>' +  '<div class=''avatar img-circle''>' +  '<img src=''https://sesuite.uniaoquimica.com.br/se/v40059//temp/dXNlcnBob3RvLWh0dHBzOi8vc2VzdWl0ZS51bmlhb3F1aW1pY2EuY29tLmJyL3NlL3Y0MDA1OS8=-' + CAST(U.CDUSER AS VARCHAR(50)) + '.jpg'' id=''imguser_' + CAST(U.CDUSER AS VARCHAR(50)) + ''' cduser=''' + CAST(U.CDUSER AS VARCHAR(50)) + ''' title=''View employee details'' onclick=''createTooltipForGroupColumnUser(this);event.preventDefault();event.stopPropagation();''>' +  '</div>' + '</div>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-display-flex x-grid-group-header-div-flex-dir-column''>' +  '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-label-title-ct''><label class=''x-grid-group-header-label-title''>Employee</label></div>' +  '<div class=''x-grid-group-header-div-flex-1''>' +  '<span id=''spanuser_' + CAST(U.CDUSER AS VARCHAR(50)) + ''' cduser=''' + CAST(U.CDUSER AS VARCHAR(50)) + ''' class=''x-grid-group-header-span-hidden-idnmuser''>' + U.IDUSER + ' - ' + U.NMUSER + '</span>' +  '<a class=''x-grid-group-header-avatar-user-link'' id=''spanusera_' + CAST(U.CDUSER AS VARCHAR(50)) + ''' cduser=''' + CAST(U.CDUSER AS VARCHAR(50)) + ''' title=''View employee details'' onclick=''createTooltipForGroupColumnUser(this);event.preventDefault();event.stopPropagation();''>' + U.IDUSER + ' - ' + U.NMUSER + '</a>' +  '</div>' + '</div>' + '</div>' + '</div>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-flex-padding-left''>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-flex-dir-column''>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-label-title-ct''><label class=''x-grid-group-header-label-title''>Department</label></div>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-label-title-ct''>' +  '<label class=''x-grid-group-header-label-strong-text x-grid-group-header-label-strong-text-with-a-tag-in-group''>' + D.IDDEPARTMENT + ' - ' + D.NMDEPARTMENT + '</label>' + '</div>' + '</div>' + '</div>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-flex-padding-left''>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-flex-dir-column''>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-label-title-ct''><label class=''x-grid-group-header-label-title''>Position</label></div>' + '<div class=''x-grid-group-header-div-flex-1 x-grid-group-header-div-label-title-ct''>' +  '<label class=''x-grid-group-header-label-strong-text x-grid-group-header-label-strong-text-with-a-tag-in-group''>' + P.IDPOSITION + ' - ' + P.NMPOSITION + CASE WHEN AUDP.FGDEFAULTDEPTPOS=1 THEN '<i class=''seicon-check'' title=''Default department/position'' style=''font-size:13px; color:#008000''></i>' ELSE '' END + '</label>' + '</div>' + '</div>' + '</div>' + '</div>' + '</label>' AS NMUSERINFO, AUDP.FGDEFAULTDEPTPOS, U.FGUSERENABLED, D.CDDEPARTMENT, D.IDDEPARTMENT, D.NMDEPARTMENT, P.CDPOSITION, P.IDPOSITION, P.NMPOSITION, D.IDDEPARTMENT + ' - ' + D.NMDEPARTMENT AS IDNMDEP, P.IDPOSITION + ' - ' + P.NMPOSITION AS IDNMPOS, U.CDUSER AS QTOPERATORFIELD, 0 AS IDHABILITYTYPE, 0 AS IDHABILITY, 0 AS NMHABILITY, 0 AS IDEXPERIENCE , 0 AS NMEXPERIENCE , 0 AS IDINSLEVEL, 0 AS NMINSLEVEL, ADP.CDMAPPING , UC.FGCAPABLE AS FGAPTO, UC.FGREQ, C.CDCOURSE, C.IDCOURSE, C.FGCOURSETYPE, C.NMCOURSE, TRT.FGSTATUS AS FGSTATUSTRAIL, TRT.VLPROGRESS, TRT.VLPROGRESS AS QTPERCTRAIL, GN.CDGENTYPE, GN.CDGENTYPE AS CDCOURSETYPE , GN.IDGENTYPE AS IDCOURSETYPE , GN.IDGENTYPE, GN.NMGENTYPE, T.FGCANCEL, T.FGINVALID, UC.DTVALIDITY , UC.CDNEXTTRAIN, UC.FGINHERITED, CASE WHEN T.FGCANCEL=1 THEN (CAST ('#{104230}' AS VARCHAR(255))) WHEN T.FGINVALID=1 THEN (CAST ('#{110951}' AS VARCHAR(255))) WHEN T.FGSTATUS=1 THEN (CAST ('#{100470}' AS VARCHAR(255))) WHEN T.FGSTATUS=2 THEN (CAST ('#{102327}' AS VARCHAR(255))) WHEN T.FGSTATUS=3 THEN (CAST ('#{217835}' AS VARCHAR(255))) WHEN T.FGSTATUS=4 THEN (CAST ('#{201912}' AS VARCHAR(255))) WHEN T.FGSTATUS=5 THEN (CAST ('#{100481}' AS VARCHAR(255))) WHEN T.FGSTATUS=7 THEN (CAST ('#{105053}' AS VARCHAR(255))) WHEN T.FGSTATUS=8 THEN (CAST ('#{100667}' AS VARCHAR(255))) WHEN T.FGSTATUS=10 THEN (CAST ('#{100940}' AS VARCHAR(255))) END AS NMSTATECAP, UC.FGREQUIRESRETRAIN AS FGREQUIRESRETRAINING, CASE WHEN UC.DTVALIDITY < dateadd(dd, datediff(dd,0, getDate()), 0) THEN 1 ELSE 2 END AS FGDUETRAIN, T.FGSTATUS AS FGSTATUS, T.FGSTATUS AS FGSTATUSNEXT, COALESCE(TRACTUAL.DTREALSTART, TRT.DTSTART) AS DTSTARTCAP, COALESCE(TRACTUAL.DTREALFINISH, TRT.DTFINISH) AS DTFINISHCAP, TRACTUAL.FGSTATUS AS FGSTATUSCAP, TRACTUAL.CDTRAIN AS CDTRAINCAP, TRACTUAL.FGSELFOBJTRAINBYKNOW AS FGSELFOBJTRAINACTUAL, T.FGSELFOBJTRAINBYKNOW AS FGSELFOBJTRAINNEXT, TRACTUAL.CDHISTCOURSE, C.IDCOURSE + ' - ' + C.NMCOURSE AS IDNMCOURSE,  GN.IDGENTYPE + ' - ' + GN.NMGENTYPE AS IDNMGENTYPE,  CASE WHEN C.FGCOURSETYPE=2 THEN '#{217149}' ELSE '#{102342}'  END AS NMCOURSETYPE,  CASE WHEN C.FGCOURSETYPE=2 THEN CASE WHEN TRT.FGSTATUS=2 THEN CAST('#{100481}' AS VARCHAR(255)) WHEN TRT.FGSTATUS=3 THEN CAST('#{100667}' AS VARCHAR(255)) ELSE CAST('#{201912}' AS VARCHAR(255)) END  END AS NMSTATUSTRAIL,  CASE WHEN UC.FGINHERITED=1 THEN CAST('#{212318}' AS VARCHAR(255)) WHEN UC.FGINHERITED=2 THEN CAST('#{105415}' AS VARCHAR(255))  END AS NMFGINHERITED,  CASE WHEN UC.FGREQ=1 THEN CAST('#{104003}' AS VARCHAR(255)) WHEN UC.FGREQ=2 THEN CAST('#{104189}' AS VARCHAR(255)) WHEN UC.FGREQ=3 THEN CAST('#{200613}' AS VARCHAR(255))  END AS NMFGREQ,  CASE WHEN UC.FGCAPABLE=1 THEN CAST('#{104367}' AS VARCHAR(255)) WHEN UC.FGCAPABLE=2 THEN CAST('#{104368}' AS VARCHAR(255)) WHEN UC.FGCAPABLE=3 THEN CAST('#{101296}' AS VARCHAR(255))  END AS NMFGCAPABLE,  CASE WHEN TEMPQTINST.QTINSTRUCTOR > 1 THEN (CAST ('#{300482}' AS VARCHAR(255))) WHEN (TEMPQTINST.QTINSTRUCTOR=1 AND TEMPINST.IDINSTRUCTOR IS NOT NULL) THEN CAST(TEMPINST.IDINSTRUCTOR + ' - ' + TEMPINST.NMINSTRUCTOR AS VARCHAR(350)) ELSE TEMPINST.NMINSTRUCTOR  END AS NMUSERINSTRUCTOR,  (CAST(COALESCE(TRACTUAL.QTTMTOTREAL, THC.QTTMTOT) AS NUMERIC)*60000) AS QTTOTREALHOURS FROM TRHISTORICAL HI INNER JOIN ADUSER U ON (U.CDUSER=HI.CDUSER) INNER JOIN TRUSERCOURSE UC ON (UC.CDUSER=U.CDUSER) INNER JOIN TRCOURSE C ON (UC.CDCOURSE=C.CDCOURSE) INNER JOIN GNGENTYPE GN ON (C.CDCOURSETYPE=GN.CDGENTYPE AND (GN.CDTYPEROLE IS NULL OR EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.CDTYPEROLE=GN.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=5864 OR 5864=-1)))) INNER JOIN ADDEPTPOSITION ADP ON (UC.CDMAPPING=ADP.CDMAPPING) LEFT OUTER JOIN TRTRAILEXECUSER TRT ON (TRT.CDUSER=U.CDUSER AND TRT.CDCOURSE=C.CDCOURSE) LEFT OUTER JOIN TRTRAINING T ON (T.CDTRAIN=UC.CDNEXTTRAIN) LEFT OUTER JOIN TRTRAINING TRACTUAL ON (TRACTUAL.CDTRAIN=UC.CDTRAIN) LEFT OUTER JOIN TRHISTCOURSE THC ON (THC.CDHISTCOURSE=TRACTUAL.CDHISTCOURSE) LEFT OUTER JOIN ( SELECT COUNT(TRTI.CDTRAININSTRUCTOR) AS QTINSTRUCTOR,  TRTI.CDTRAIN  FROM TRTRAININSTRUCTOR TRTI  GROUP BY TRTI.CDTRAIN) TEMPQTINST ON ( TEMPQTINST.CDTRAIN=TRACTUAL.CDTRAIN) LEFT OUTER JOIN ( SELECT TEMPTB.CDTRAIN,  TRT.CDUSERINST,  COALESCE (TRT.NMINSTRUCTOR, USU.NMUSER) AS NMINSTRUCTOR,  USU.IDUSER AS IDINSTRUCTOR,  TRT.FGINSTRUCTORTYPE,  TRT.QTWORKLOAD  FROM (SELECT TRTI.CDTRAIN FROM TRTRAININSTRUCTOR TRTI GROUP BY TRTI.CDTRAIN HAVING COUNT(TRTI.CDTRAININSTRUCTOR)=1)  TEMPTB  INNER JOIN TRTRAININSTRUCTOR TRT  ON (TRT.CDTRAIN=TEMPTB.CDTRAIN)  LEFT OUTER JOIN ADUSER USU  ON (TRT.CDUSERINST=USU.CDUSER)) TEMPINST ON ( TEMPINST.CDTRAIN=TRACTUAL.CDTRAIN) INNER JOIN ADPOSITION P ON (P.CDPOSITION=ADP.CDPOSITION) INNER JOIN ADDEPARTMENT D ON (D.CDDEPARTMENT=ADP.CDDEPARTMENT) INNER JOIN ADUSERDEPTPOS AUDP ON (U.CDUSER=AUDP.CDUSER AND D.CDDEPARTMENT=AUDP.CDDEPARTMENT AND P.CDPOSITION=AUDP.CDPOSITION) LEFT OUTER JOIN (/* Pares */ SELECT ADU1.CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADUSER ADU1 INNER JOIN ADUSER ADU2 ON (ADU2.CDUSER <> ADU1.CDUSER) INNER JOIN ADPARAMS ADP0 ON (ADP0.CDPARAM=3  AND ADP0.CDISOSYSTEM=153  AND ADP0.VLPARAM=1) INNER JOIN ADPARAMS ADP1 ON (ADP1.CDPARAM=20  AND ADP1.CDISOSYSTEM=153) INNER JOIN ADPARAMS ADP2 ON (ADP2.CDPARAM=21  AND ADP2.CDISOSYSTEM=153) INNER JOIN ADPARAMS ADP3 ON (ADP3.CDPARAM=22  AND ADP3.CDISOSYSTEM=153) WHERE 1=1 AND EXISTS ( SELECT 1  FROM ADMINISTRATION  WHERE ADU2.CDLEADER=ADU1.CDLEADER  AND ADP1.VLPARAM=1  AND (ADP2.VLPARAM <> 1 OR ADP3.VLPARAM=2) /*sub*/UNION/*sub*/ ALL SELECT 1  FROM ADUSERDEPTPOS ADUDP1 INNER JOIN ADUSERDEPTPOS ADUDP2 ON ( ADUDP2.CDDEPARTMENT=ADUDP1.CDDEPARTMENT AND ADUDP2.CDPOSITION=ADUDP1.CDPOSITION)  WHERE ADUDP1.CDUSER=ADU1.CDUSER  AND ADUDP2.CDUSER=ADU2.CDUSER  AND ADP2.VLPARAM=1  AND (ADP1.VLPARAM <> 1 OR ADP3.VLPARAM=2) /*sub*/UNION/*sub*/ ALL SELECT 1  FROM ADUSERDEPTPOS ADUDP1 INNER JOIN ADUSERDEPTPOS ADUDP2 ON ( ADUDP2.CDDEPARTMENT=ADUDP1.CDDEPARTMENT AND ADUDP2.CDPOSITION=ADUDP1.CDPOSITION)  WHERE ADUDP1.CDUSER=ADU1.CDUSER  AND ADUDP2.CDUSER=ADU2.CDUSER  AND ADU2.CDLEADER=ADU1.CDLEADER  AND ADP1.VLPARAM=1  AND ADP2.VLPARAM=1  AND ADP3.VLPARAM=1) AND ADU2.CDUSER=<!%CDUSER%> GROUP BY ADU1.CDUSER /*sub*/UNION/*sub*/ /* Lider */ SELECT ADL.CDLEADER AS CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADUSER ADL INNER JOIN ADPARAMS ADP ON (ADP.CDPARAM=4  AND ADP.CDISOSYSTEM=153  AND ADP.VLPARAM=1) WHERE ADL.CDLEADER IS NOT NULL AND ADL.CDUSER=<!%CDUSER%> GROUP BY ADL.CDLEADER /*sub*/UNION/*sub*/ /* Liderados */ SELECT T.CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM (SELECT ADU1.CDUSER, ADU0.CDUSER AS CDLEADER, 1 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU2.CDUSER, ADU0.CDUSER AS CDLEADER, 2 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU3.CDUSER, ADU0.CDUSER AS CDLEADER, 3 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) INNER JOIN ADUSER ADU3 ON (ADU3.CDLEADER=ADU2.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU4.CDUSER, ADU0.CDUSER AS CDLEADER, 4 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) INNER JOIN ADUSER ADU3 ON (ADU3.CDLEADER=ADU2.CDUSER) INNER JOIN ADUSER ADU4 ON (ADU4.CDLEADER=ADU3.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%> /*sub*/UNION/*sub*/ SELECT ADU5.CDUSER, ADU0.CDUSER AS CDLEADER, 5 AS NRLEVEL FROM ADUSER ADU0 INNER JOIN ADUSER ADU1 ON (ADU1.CDLEADER=ADU0.CDUSER) INNER JOIN ADUSER ADU2 ON (ADU2.CDLEADER=ADU1.CDUSER) INNER JOIN ADUSER ADU3 ON (ADU3.CDLEADER=ADU2.CDUSER) INNER JOIN ADUSER ADU4 ON (ADU4.CDLEADER=ADU3.CDUSER) INNER JOIN ADUSER ADU5 ON (ADU5.CDLEADER=ADU4.CDUSER) WHERE ADU0.CDUSER=<!%CDUSER%>) T INNER JOIN ADPARAMS ADP ON (ADP.CDPARAM=2  AND ADP.CDISOSYSTEM=153  AND ADP.VLPARAM=1) GROUP BY T.CDUSER /*sub*/UNION/*sub*/ /* Proprio usuario */ SELECT CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADMINISTRATION /*sub*/UNION/*sub*/ /* Equipe de controle por unidade organizacional */ SELECT ADUDPPOS.CDUSER, CAST(<!%CDUSER%> AS NUMERIC(10)) AS CDUSERDATA FROM ADUSERDEPTPOS ADUDPPOS INNER JOIN ADDEPTSUBLEVEL ADDPSUB ON (ADDPSUB.CDDEPT=ADUDPPOS.CDDEPARTMENT) INNER JOIN ADDEPARTMENT ADP ON (ADP.CDDEPARTMENT=ADDPSUB.CDOWNER) INNER JOIN ADTEAMUSER ADTU ON (ADTU.CDTEAM=ADP.CDSECURITYTEAM) WHERE ADTU.CDUSER=<!%CDUSER%> GROUP BY ADUDPPOS.CDUSER) USERPERM ON (USERPERM.CDUSER=U.CDUSER AND USERPERM.CDUSERDATA=<!%CDUSER%>) WHERE 1=1 AND EXISTS (SELECT 1  FROM ADUSERDEPTPOS ADDPTP  WHERE ADDPTP.CDUSER=U.CDUSER AND ADDPTP.FGDEFAULTDEPTPOS=1  AND ((ADDPTP.CDDEPARTMENT IN(<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, QURERVBBUlRNRU5U, Q0RERVBBUlRNRU5U, Q0RERVBUT1dORVI=,, MzI2, QUREUFRQ)%>)))) AND U.FGUSERENABLED=1 AND (EXISTS (SELECT ADT1.CDUSER FROM ADTEAMUSER ADT1  INNER JOIN ADPARAMS ADP  ON (ADP.CDPARAM=1 AND ADP.CDISOSYSTEM=153 AND ADP.VLPARAM=ADT1.CDTEAM) WHERE ADT1.CDUSER=<!%CDUSER%>)  OR USERPERM.CDUSER IS NOT NULL)