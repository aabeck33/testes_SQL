SELECT DR.CDDOCUMENT,CAST (CASE WHEN DC.FGSTATUS=1 THEN 'Emiss�o' WHEN DC.FGSTATUS=2 THEN 'Homologado' WHEN DC.FGSTATUS=3 THEN 'Em revis�o' WHEN DC.FGSTATUS=4 THEN 'Cancelado' WHEN DC.FGSTATUS=5 THEN 'Indexa��o' END AS VARCHAR(255)) AS FGSTATUSDOC ,CT.IDCATEGORY,DR.IDDOCUMENT,DR.NMTITLE,GR.IDREVISION,DR.NMAUTHOR,DR.NRHITS,GR.DTVALIDITY,GR.DTREVISION,MONTH(GR.DTREVISION) AS NMREVISION_MONTH, YEAR(GR.DTREVISION) AS NMREVISION_YEAR FROM DCDOCREVISION DR INNER JOIN DCDOCUMENT DC ON DC.CDDOCUMENT=DR.CDDOCUMENT INNER JOIN DCCATEGORY CT ON DR.CDCATEGORY=CT.CDCATEGORY INNER JOIN GNREVISION GR ON GR.CDREVISION=DR.CDREVISION INNER JOIN DCFILE DE ON DE.CDREVISION=DR.CDREVISION INNER JOIN SEF_DCCATEGORY_CHILDREN(125) CTFILTER ON (CTFILTER.CDCATEGORY=CT.CDCATEGORY) LEFT OUTER JOIN DCDOCUMENTARCHIVAL DA ON DA.CDDOCUMENT=DR.CDDOCUMENT LEFT JOIN GNREVCONFIG GRC ON (CT.CDREVCONFIG=GRC.CDREVCONFIG) INNER JOIN GNELETRONICFILECFG CFG ON (CFG.CDELETRONICFILECFG=CT.CDELETRONICFILECFG) LEFT OUTER JOIN GNFORMCFGTEMP GFFT ON (GFFT.CDELETRONICFILECFG=CFG.CDELETRONICFILECFG) LEFT OUTER JOIN EFFORM EFF ON (GFFT.OIDFORM=EFF.OID) LEFT JOIN (SELECT MAX(T.FGPERMISSIONTYPE) AS FGPERMISSION, T.CDDOCUMENT FROM/*SUB*/ DCUSERPERMISSION_V T WHERE 1=1 AND T.CDUSER IN (875, -1) AND T.CDPERMISSION=3 GROUP BY T.CDDOCUMENT) Z3 ON DC.CDDOCUMENT=Z3.CDDOCUMENT AND Z3.FGPERMISSION=1 WHERE 1=1 AND DC.FGSTATUS IN (1,2,3,5) AND (CT.CDTYPEROLE IS NULL OR EXISTS (SELECT 1 FROM (SELECT MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE) AS FGACCESSLIST, CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM, ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.FGACCESSLIST=1 AND CHKPERMTYPEROLE.CDTYPEROLE=CT.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=875 OR 875=-1))) AND ((Z3.CDDOCUMENT IS NOT NULL) OR (DC.CDCREATEDBY=875)) AND DR.FGCURRENT=1