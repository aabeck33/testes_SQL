SELECT DR.CDREVISION,CAST (CASE WHEN GR.FGSTATUS=1 THEN '#{103222}' WHEN GR.FGSTATUS=2 THEN '#{104231}' WHEN GR.FGSTATUS=3 THEN '#{100263}' WHEN GR.FGSTATUS=4 THEN '#{104236}' WHEN GR.FGSTATUS=5 THEN '#{104238}' WHEN GR.FGSTATUS=6 THEN '#{101237}' END AS VARCHAR(255)) AS NMSTATUSREV ,CT.IDCATEGORY,DR.IDDOCUMENT,DR.NMTITLE,GR.IDREVISION,DR.NMAUTHOR,GR.DTREVISION,COALESCE((SELECT MAX(NRCYCLE) FROM/*SUB*/ GNREVUPDATE WHERE CDREVISION=GR.CDREVISION), 1) AS NRCYCLE FROM DCDOCREVISION DR INNER JOIN DCDOCUMENT DC ON DC.CDDOCUMENT=DR.CDDOCUMENT INNER JOIN DCCATEGORY CT ON DR.CDCATEGORY=CT.CDCATEGORY INNER JOIN GNREVISION GR ON GR.CDREVISION=DR.CDREVISION INNER JOIN GNREVCONFIG GNREV ON (GNREV.CDREVCONFIG=CT.CDREVCONFIG) LEFT OUTER JOIN GNREVISIONSTATUS GNST ON (GR.CDREVISIONSTATUS=GNST.CDREVISIONSTATUS) INNER JOIN GNELETRONICFILECFG CFG ON (CFG.CDELETRONICFILECFG=CT.CDELETRONICFILECFG) LEFT OUTER JOIN GNFORMCFGTEMP GFFT ON (GFFT.CDELETRONICFILECFG=CFG.CDELETRONICFILECFG) LEFT OUTER JOIN EFFORM EFF ON (GFFT.OIDFORM=EFF.OID) WHERE 1=1 AND DC.FGSTATUS IN ('1','2','3') AND CT.CDCATEGORY IN ('216','218','222','223','224','228','231','234','237','240','241','256','261','326','361','370','420','421','422','375','362','363','327','328','329','257','258','259','260','330','331','238','239','235','236','232','233','229','230','225','226','227','243','219','220','221') AND EXISTS (SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM INNER JOIN DCCATEGORY CATEG ON PM.CDTYPEROLE=CATEG.CDTYPEROLE WHERE PM.CDUSER=<!%CDUSER%> AND CT.CDCATEGORY=CATEG.CDCATEGORY AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=1 /* sub */UNION ALL SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM INNER JOIN DCCATEGORY CATEG ON PM.CDTYPEROLE=CATEG.CDTYPEROLE WHERE PM.CDUSER=-1 AND CT.CDCATEGORY=CATEG.CDCATEGORY AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=1 /* sub */UNION ALL SELECT 1 FROM/*sub*/ DCCATEGORY CATEG WHERE CATEG.CDTYPEROLE IS NULL AND CT.CDCATEGORY=CATEG.CDCATEGORY) AND NOT EXISTS (SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM INNER JOIN DCCATEGORY CATEG ON PM.CDTYPEROLE=CATEG.CDTYPEROLE WHERE PM.CDUSER=<!%CDUSER%> AND CT.CDCATEGORY=CATEG.CDCATEGORY AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=2 /* sub */UNION ALL SELECT 1 FROM/*sub*/ GNUSERPERMTYPEROLE PM INNER JOIN DCCATEGORY CATEG ON PM.CDTYPEROLE=CATEG.CDTYPEROLE WHERE PM.CDUSER=-1 AND CT.CDCATEGORY=CATEG.CDCATEGORY AND PM.CDPERMISSION=5 AND PM.FGPERMISSIONTYPE=2) AND EXISTS (SELECT 1 FROM (SELECT DDOC.CDPERMISSION FROM DCUSERPERMISSIONDOC DDOC WHERE DDOC.CDUSER IN (<!%CDUSER%>, -1) AND DDOC.CDPERMISSION IN (3) AND DDOC.CDDOCUMENT=DC.CDDOCUMENT AND DDOC.FGPERMISSIONTYPE=1 /* sub */UNION ALL SELECT PC.CDPERMISSION FROM DCUSERPERMISSIONCATEG PC WHERE PC.CDUSER IN (<!%CDUSER%>, -1) AND PC.CDPERMISSION IN (3) AND DR.CDDOCUMENT=DC.CDDOCUMENT AND PC.FGPERMISSIONTYPE=1 AND DR.CDCATEGORY=PC.CDCATEGORY AND DC.FGUSECATACCESSROLE=1 /* sub */UNION ALL SELECT SRU.CDPERMISSION FROM DCSECRULECONDDOC SRC INNER JOIN DCSECRULECONDUSER SRU ON SRU.CDCONDITION=SRC.CDCONDITION WHERE Dc.FGUSECATACCESSROLE=1 AND SRU.CDUSER IN (<!%CDUSER%>, -1) AND SRU.CDPERMISSION IN (3) AND SRC.CDDOCUMENT=DC.CDDOCUMENT AND SRU.FGPERMISSIONTYPE=1 GROUP BY SRU.CDPERMISSION, SRC.CDDOCUMENT, SRU.CDUSER, SRU.FGPERMISSIONTYPE /* sub */UNION ALL SELECT 1 WHERE DC.CDCREATEDBY=<!%CDUSER%>) PERM  WHERE NOT EXISTS(SELECT 1 FROM DCUSERPERMISSIONDOC DDOC WHERE DDOC.CDUSER IN (<!%CDUSER%>, -1) AND DDOC.CDPERMISSION=PERM.CDPERMISSION AND DDOC.CDDOCUMENT=DC.CDDOCUMENT AND DDOC.FGPERMISSIONTYPE=2 AND DC.CDCREATEDBY <> <!%CDUSER%> /* sub */UNION ALL SELECT 1 FROM DCUSERPERMISSIONCATEG PC WHERE PC.CDUSER IN (<!%CDUSER%>, -1) AND PC.CDPERMISSION=PERM.CDPERMISSION AND DR.CDDOCUMENT=DC.CDDOCUMENT AND PC.FGPERMISSIONTYPE=2 AND DR.CDCATEGORY=PC.CDCATEGORY AND DC.FGUSECATACCESSROLE=1 AND DC.CDCREATEDBY <> <!%CDUSER%> /* sub */UNION ALL SELECT 1 FROM DCSECRULECONDDOC SRC INNER JOIN DCSECRULECONDUSER SRU ON SRU.CDCONDITION=SRC.CDCONDITION WHERE DC.FGUSECATACCESSROLE=1 AND SRU.CDUSER IN (<!%CDUSER%>, -1) AND SRU.CDPERMISSION=PERM.CDPERMISSION AND SRC.CDDOCUMENT=DC.CDDOCUMENT AND SRU.FGPERMISSIONTYPE=2 AND DC.CDCREATEDBY <> <!%CDUSER%> GROUP BY SRU.CDPERMISSION, SRC.CDDOCUMENT, SRU.CDUSER, SRU.FGPERMISSIONTYPE) /* sub */UNION ALL SELECT 1 WHERE DC.CDCREATEDBY=<!%CDUSER%>) AND CT.FGENABLEREVISION=1