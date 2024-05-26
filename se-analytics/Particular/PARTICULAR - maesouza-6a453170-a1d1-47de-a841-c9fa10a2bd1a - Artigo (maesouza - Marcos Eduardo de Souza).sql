SELECT KBREV.IDARTICLE, KBARL.NMARTICLE, KBREV.OID AS OIDREVISION, CONCAT(KB.IDKNOWLEDGEBASE, CONCAT(' - ', KBLD.NMKNOWLEDGEBASE)) AS IDNAMEKB, KBREV.OIDKNOWLEDGEBASE, CASE WHEN GNT.IDGENTYPE IS NULL THEN '' ELSE CONCAT(GNT.IDGENTYPE, CONCAT(' - ', COALESCE (TRLAN.NMTRANSLATION, GNT.NMGENTYPE))) END AS IDNAMECATEGORY, KBREV.OIDCATEGORY, ADU.NMUSER AS NMRESPONSIBLE, ADU.CDUSER AS CDRESPONSIBLE, CASE WHEN KBART.DTEXPIRATION < <!%TODAY%> OR KBART.FGOBSOLETE=1 THEN '#{308328}' ELSE '#{100900}' END AS FGOBSOLETE, KBART.DTEXPIRATION, CAST(KBA708.DSVALUE AS VARCHAR(4000)) AS DSATTRIB708, COALESCE(ADATV850L.NMTRANSLATION, ADATV850.NMATTRIBUTE) AS NMATTRIB850, KBA850.CDVALUE AS CDATTRIB850 FROM KBKNOWLEDGEBASE KB INNER JOIN KBARTICLEREVISION KBREV ON KBREV.OIDKNOWLEDGEBASE=KB.OID INNER JOIN KBARTICLEREVLANGUAGE KBARL ON (KBARL.OIDREVISIONARTICLE=KBREV.OID) INNER JOIN (SELECT CASE WHEN MAX(USERLANG) > 0 THEN MAX(USERLANG) WHEN MAX(BASELANG) > 0 AND MAX(USERLANG)=0 THEN MAX(BASELANG) ELSE MIN(FIRSTENABLEDLANG) END AS FGLANGUAGE, KBAR1.OID, KBAR1.OIDKNOWLEDGEBASE FROM KBARTICLEREVISION KBAR1 INNER JOIN (SELECT KBAR.OID, KLD.FGLANGUAGE AS USERLANG, 0 AS BASELANG, 99 AS FIRSTENABLEDLANG FROM KBARTICLEREVISION KBAR INNER JOIN KBLANGUAGEDATA KLD ON (KBAR.OIDKNOWLEDGEBASE=KLD.OIDKNOWLEDGEBASE AND KLD.FGENABLED=1 AND KLD.FGLANGUAGE=<!%FGLANGUAGE%>) INNER JOIN KBARTICLEREVLANGUAGE KBARL ON (KBARL.OIDREVISIONARTICLE=KBAR.OID AND KLD.FGLANGUAGE=KBARL.FGLANGUAGE) WHERE KBARL.NMARTICLE IS NOT NULL UNION SELECT KBAR.OID, 0 AS USERLANG, BASELANG.CDBASELANGUAGE AS BASELANG, 99 AS FIRSTENABLEDLANG FROM KBARTICLEREVISION KBAR INNER JOIN KBBASELANGCONFIG BASELANG ON (BASELANG.CDLANGUAGE=<!%FGLANGUAGE%>) INNER JOIN KBLANGUAGEDATA KLD ON (KBAR.OIDKNOWLEDGEBASE=KLD.OIDKNOWLEDGEBASE AND KLD.FGLANGUAGE=BASELANG.CDBASELANGUAGE AND KLD.FGENABLED=1 AND KLD.FGLANGUAGE <> <!%FGLANGUAGE%>) INNER JOIN KBARTICLEREVLANGUAGE KBARL ON (KBARL.OIDREVISIONARTICLE=KBAR.OID AND KLD.FGLANGUAGE=KBARL.FGLANGUAGE) WHERE KBARL.NMARTICLE IS NOT NULL UNION SELECT KBAR.OID, 0 AS USERLANG, 0 AS BASELANG, MIN(KLD.FGLANGUAGE) AS FIRSTENABLEDLANG FROM KBARTICLEREVISION KBAR INNER JOIN KBLANGUAGEDATA KLD ON (KBAR.OIDKNOWLEDGEBASE=KLD.OIDKNOWLEDGEBASE AND KLD.FGENABLED=1 AND KLD.FGLANGUAGE <> <!%FGLANGUAGE%>) INNER JOIN KBARTICLEREVLANGUAGE KBARL ON (KBARL.OIDREVISIONARTICLE=KBAR.OID AND KLD.FGLANGUAGE=KBARL.FGLANGUAGE) WHERE KBARL.NMARTICLE IS NOT NULL GROUP BY KBAR.OID, KLD.OID) KBASELANGINNER ON (KBAR1.OID=KBASELANGINNER.OID) GROUP BY KBAR1.OID, KBAR1.OIDKNOWLEDGEBASE) KBASELANG ON (KBASELANG.OID=KBARL.OIDREVISIONARTICLE AND KBARL.FGLANGUAGE=KBASELANG.FGLANGUAGE) INNER JOIN KBLANGUAGEDATA KBLD ON (KBLD.OIDKNOWLEDGEBASE=KBASELANG.OIDKNOWLEDGEBASE AND KBASELANG.FGLANGUAGE=KBLD.FGLANGUAGE) INNER JOIN KBARTICLEDATA KBART ON KBART.OID=KBREV.OIDARTICLE INNER JOIN ADUSER ADU ON ADU.CDUSER=KBREV.CDRESPONSIBLE INNER JOIN KBARTICLEREVISION KBACURREV ON KBREV.OIDARTICLE=KBACURREV.OIDARTICLE AND KBACURREV.FGCURRENT=1 LEFT JOIN KBCATEGORY KBC ON KBC.OID=KBREV.OIDCATEGORY LEFT JOIN GNGENTYPE GNT ON GNT.CDGENTYPE=KBC.CDGENTYPE LEFT OUTER JOIN GNTRANSLATIONLANGUAGE TRLAN ON KBC.CDTRANSLATION=TRLAN.CDTRANSLATION AND TRLAN.FGLANGUAGE=KBLD.FGLANGUAGE INNER JOIN (SELECT KBSECURITY.OID, INNERSECURITY.* FROM KBKNOWLEDGEBASE KBSECURITY INNER JOIN (SELECT CASE WHEN MAX(KBSEC.FGEDITKB)=1 THEN 1 ELSE 2 END AS FGEDITKB, CASE WHEN MAX(KBSEC.FGVIEWKB)=1 THEN 1 ELSE 2 END AS FGVIEWKB, CASE WHEN MAX(KBSEC.FGDELETEKB)=1 THEN 1 ELSE 2 END AS FGDELETEKB, CASE WHEN MAX(KBSEC.FGNEWARTICLE)=1 THEN 1 ELSE 2 END AS FGNEWARTICLE, CASE WHEN MAX(KBSEC.FGEDITARTICLE)=1 THEN 1 ELSE 2 END AS FGEDITARTICLE, CASE WHEN MAX(KBSEC.FGVIEWARTICLE)=1 THEN 1 ELSE 2 END AS FGVIEWARTICLE, CASE WHEN MAX(KBSEC.FGDELETEARTICLE)=1 THEN 1 ELSE 2 END AS FGDELETEARTICLE, KBSEC.CDTYPEROLE FROM (SELECT CASE WHEN FGEDITKB=1 THEN (CASE WHEN FGPERMISSION=1 THEN 1 ELSE 2 END) ELSE NULL END AS FGEDITKB, CASE WHEN FGVIEWKB=1 THEN (CASE WHEN FGPERMISSION=1 THEN 1 ELSE 2 END) ELSE NULL END AS FGVIEWKB, CASE WHEN FGDELETEKB=1 THEN (CASE WHEN FGPERMISSION=1 THEN 1 ELSE 2 END) ELSE NULL END AS FGDELETEKB, CASE WHEN FGNEWARTICLE=1 THEN (CASE WHEN FGPERMISSION=1 THEN 1 ELSE 2 END) ELSE NULL END AS FGNEWARTICLE, CASE WHEN FGEDITARTICLE=1 THEN (CASE WHEN FGPERMISSION=1 THEN 1 ELSE 2 END) ELSE NULL END AS FGEDITARTICLE, CASE WHEN FGVIEWARTICLE=1 THEN (CASE WHEN FGPERMISSION=1 THEN 1 ELSE 2 END) ELSE NULL END AS FGVIEWARTICLE, CASE WHEN FGDELETEARTICLE=1 THEN (CASE WHEN FGPERMISSION=1 THEN 1 ELSE 2 END) ELSE NULL END AS FGDELETEARTICLE, CDTYPEROLE FROM KBACCESSCONTROL KBAC WHERE (CDUSER=<!%CDUSER%> OR CDTEAM IN (SELECT DISTINCT(CDTEAM) FROM ADTEAMUSER WHERE CDUSER=<!%CDUSER%>) OR FGACCESSTYPE=6)) KBSEC GROUP BY KBSEC.CDTYPEROLE) INNERSECURITY ON (INNERSECURITY.CDTYPEROLE=KBSECURITY.CDTYPEROLE AND (FGVIEWARTICLE=1 AND FGVIEWKB=1))) PERMISSION ON (PERMISSION.OID=KB.OID) LEFT JOIN KBARTICLEATTRIB KBA708 ON KBACURREV.OID=KBA708.OIDARTICLE AND KBA708.CDATTRIBUTE=708 LEFT JOIN KBARTICLEATTRIB KBA850 ON KBACURREV.OID=KBA850.OIDARTICLE AND KBA850.CDATTRIBUTE=850 LEFT JOIN ADATTRIBVALUE ADATV850 ON KBA850.CDATTRIBUTE=ADATV850.CDATTRIBUTE AND KBA850.CDVALUE=ADATV850.CDVALUE LEFT JOIN GNTRANSLATIONLANGUAGE ADATV850L ON ADATV850.CDTRANSLATION=ADATV850L.CDTRANSLATION AND KBASELANG.FGLANGUAGE=ADATV850L.FGLANGUAGE WHERE 1=1 AND KBREV.FGCURRENT=1 AND KBREV.FGSTATUS=2 AND CAST(KBREV.OIDKNOWLEDGEBASE AS VARCHAR(255))=CAST('56b5252c99674cc52972566e5ddb0753' AS VARCHAR(255)) AND KBC.CDGENTYPE IN (<!%FUNC(com.softexpert.generic.parameter.InClauseBuilder, R05HRU5UWVBF, Q0RHRU5UWVBF, Q0RHRU5UWVBFT1dORVI=,, Mjkz,)%>)