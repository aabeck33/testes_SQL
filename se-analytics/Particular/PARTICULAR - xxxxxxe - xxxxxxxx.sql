SELECT DISTINCT A.IDIDENTIFIER AS ID_ANALISE, A.NMNAME AS NOME_ANALISE, T.TXDATA FROM SETEXT T  INNER JOIN BI2DATASETSQLQUERY D ON T.OID=D.OIDCLOB  INNER JOIN BI2ANALYSIS A ON A.OID=D.OIDANALYSIS where T.TXDATA like '%aduserrole%'