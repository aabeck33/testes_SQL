SELECT DR.CDDOCUMENT,CAST (CASE WHEN DC.FGSTATUS=1 THEN '#{103645}' WHEN DC.FGSTATUS=2 THEN '#{104235}' WHEN DC.FGSTATUS=3 THEN '#{104705}' WHEN DC.FGSTATUS=4 THEN '#{104230}' WHEN DC.FGSTATUS=5 THEN '#{200421}' WHEN DC.FGSTATUS=6 THEN '#{100263}' WHEN DC.FGSTATUS=7 THEN '#{209484}' END AS VARCHAR(255)) AS FGSTATUSDOC ,CT.IDCATEGORY,DR.IDDOCUMENT,GR.IDREVISION,DR.NMAUTHOR,DR.NRHITS,GR.DTREVISION,CASE WHEN CT.FGENABLEVALID=1 THEN GR.DTVALIDITY ELSE NULL END AS DTVALIDITY,COALESCE(TRLG.NMTRANSLATION, DR.NMTITLE) AS NMTITLE,MONTH(GR.DTREVISION) AS NMREVISION_MONTH, YEAR(GR.DTREVISION) AS NMREVISION_YEAR FROM DCDOCREVISION DR INNER JOIN DCDOCUMENT DC ON DC.CDDOCUMENT=DR.CDDOCUMENT INNER JOIN DCCATEGORY CT ON DR.CDCATEGORY=CT.CDCATEGORY LEFT JOIN GNTRANSLATIONLANGUAGE TRLG ON (DR.CDTRANSLATION=TRLG.CDTRANSLATION AND TRLG.FGLANGUAGE=<!%FGLANGUAGE%>) INNER JOIN GNREVISION GR ON GR.CDREVISION=DR.CDREVISION INNER JOIN GNELETRONICFILECFG CFG ON (CFG.CDELETRONICFILECFG=CT.CDELETRONICFILECFG) WHERE 1=1 AND DC.FGSTATUS IN ('1','2','3','5') AND EXISTS (SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM WHERE PM.CDUSER=<!%CDUSER%> AND CT.CDTYPEROLE=PM.CDTYPEROLE AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=1 /* sub */UNION ALL SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM WHERE PM.CDUSER=-1 AND CT.CDTYPEROLE=PM.CDTYPEROLE AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=1 /* sub */UNION ALL SELECT 1 WHERE CT.CDTYPEROLE IS NULL) AND NOT EXISTS (SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM WHERE PM.CDUSER=<!%CDUSER%> AND CT.CDTYPEROLE=PM.CDTYPEROLE AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=2 /* sub */UNION ALL SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM WHERE PM.CDUSER=-1 AND CT.CDTYPEROLE=PM.CDTYPEROLE AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=2) and (datepart(yyyy, GR.DTREVISION) = datepart(yyyy, getdate()) or datepart(yyyy, GR.DTREVISION) = datepart(yyyy, getdate()) - 1) AND EXISTS (SELECT 1 FROM (SELECT DDOC.CDPERMISSION FROM DCUSERPERMISSIONDOC DDOC WHERE DDOC.CDUSER IN (<!%CDUSER%>, -1) AND DDOC.CDPERMISSION IN (3) AND DDOC.CDDOCUMENT=DC.CDDOCUMENT AND DDOC.FGPERMISSIONTYPE=1 /* sub */UNION ALL SELECT PC.CDPERMISSION FROM DCUSERPERMISSIONCATEG PC WHERE PC.CDUSER IN (<!%CDUSER%>, -1) AND PC.CDPERMISSION IN (3) AND DR.CDDOCUMENT=DC.CDDOCUMENT AND PC.FGPERMISSIONTYPE=1 AND DR.CDCATEGORY=PC.CDCATEGORY AND DC.FGUSECATACCESSROLE=1 /* sub */UNION ALL SELECT SRU.CDPERMISSION FROM DCSECRULECONDDOC SRC INNER JOIN DCSECRULECONDUSER SRU ON SRU.CDCONDITION=SRC.CDCONDITION WHERE Dc.FGUSECATACCESSROLE=1 AND SRU.CDUSER IN (<!%CDUSER%>, -1) AND SRU.CDPERMISSION IN (3) AND SRC.CDDOCUMENT=DC.CDDOCUMENT AND SRU.FGPERMISSIONTYPE=1 GROUP BY SRU.CDPERMISSION, SRC.CDDOCUMENT, SRU.CDUSER, SRU.FGPERMISSIONTYPE /* sub */UNION ALL SELECT 1 WHERE DC.CDCREATEDBY=<!%CDUSER%>) PERM WHERE NOT EXISTS(SELECT 1 FROM DCUSERPERMISSIONDOC DDOC WHERE DDOC.CDUSER IN (<!%CDUSER%>, -1) AND DDOC.CDPERMISSION=PERM.CDPERMISSION AND DDOC.CDDOCUMENT=DC.CDDOCUMENT AND DDOC.FGPERMISSIONTYPE=2 AND DC.CDCREATEDBY <> <!%CDUSER%> /* sub */UNION ALL SELECT 1 FROM DCUSERPERMISSIONCATEG PC WHERE PC.CDUSER IN (<!%CDUSER%>, -1) AND PC.CDPERMISSION=PERM.CDPERMISSION AND DR.CDDOCUMENT=DC.CDDOCUMENT AND PC.FGPERMISSIONTYPE=2 AND DR.CDCATEGORY=PC.CDCATEGORY AND DC.FGUSECATACCESSROLE=1 AND DC.CDCREATEDBY <> <!%CDUSER%> /* sub */UNION ALL SELECT 1 FROM DCSECRULECONDDOC SRC INNER JOIN DCSECRULECONDUSER SRU ON SRU.CDCONDITION=SRC.CDCONDITION WHERE DC.FGUSECATACCESSROLE=1 AND SRU.CDUSER IN (<!%CDUSER%>, -1) AND SRU.CDPERMISSION=PERM.CDPERMISSION AND SRC.CDDOCUMENT=DC.CDDOCUMENT AND SRU.FGPERMISSIONTYPE=2 AND DC.CDCREATEDBY <> <!%CDUSER%> GROUP BY SRU.CDPERMISSION, SRC.CDDOCUMENT, SRU.CDUSER, SRU.FGPERMISSIONTYPE) /* sub */UNION ALL SELECT 1 WHERE DC.CDCREATEDBY=<!%CDUSER%>) AND DR.FGCURRENT=1 