SELECT IDPROCESS,NMPROCESS,QTD_BI,NMACTION,DTHISTORY,TMHISTORY,IDTYPE,NMUSER,NMSTRUCT,NMROLE,NMOCCURRENCETYPE FROM (SELECT IDPROCESS,NMPROCESS,QTD_BI,NMACTION,DTHISTORY,TMHISTORY,IDTYPE,NMUSER,NMSTRUCT,NMROLE,NMOCCURRENCETYPE FROM (SELECT 1 AS QTD_BI, P.IDOBJECT, P.IDPROCESS, P.CDPROCESSMODEL, P.IDPROCESSMODEL, P.NMPROCESSMODEL, P.NMPROCESS, P.NMUSERSTART, GNR.NMEVALRESULT, S.NMSTRUCT, HIS.FGTYPE, CASE WHEN HIS.FGTYPE=1 THEN 'Inst�ncia iniciada' WHEN HIS.FGTYPE=2 THEN 'Inst�ncia suspensa' WHEN HIS.FGTYPE=3 THEN 'Inst�ncia cancelada' WHEN HIS.FGTYPE=4 THEN 'Inst�ncia encerrada' WHEN HIS.FGTYPE=5 THEN 'Inst�ncia reativada' WHEN HIS.FGTYPE=6 THEN 'Atividade habilitada' WHEN HIS.FGTYPE=7 THEN 'Atividade associada' WHEN HIS.FGTYPE=8 THEN 'Atividade desassociada' WHEN HIS.FGTYPE=9 OR HIS.FGTYPE=13 THEN CASE WHEN HIS.FGEXECACTIVITY=1 THEN 'Atividade executada' ELSE 'A��o executada' END WHEN HIS.FGTYPE=10 THEN 'Atividade delegada' WHEN HIS.FGTYPE=11 THEN 'Coment�rio inclu�do' WHEN HIS.FGTYPE=12 THEN 'A��o do gestor' WHEN HIS.FGTYPE=14 THEN 'Evento de timer iniciado' WHEN HIS.FGTYPE=15 THEN 'Evento de timer encerrado' WHEN HIS.FGTYPE=16 THEN 'Atividade cancelada' WHEN HIS.FGTYPE=17 THEN 'Processo retornado' WHEN HIS.FGTYPE=18 THEN 'Atividade recusada' WHEN HIS.FGTYPE=19 THEN 'Retorno aprovado' WHEN HIS.FGTYPE=20 THEN 'Retorno reprovado' WHEN HIS.FGTYPE=21 THEN 'Anexo inclu�do' WHEN HIS.FGTYPE=22 THEN 'Anexo exclu�do' WHEN HIS.FGTYPE=23 THEN 'Documento inclu�do' WHEN HIS.FGTYPE=24 THEN 'Documento exclu�do' WHEN HIS.FGTYPE=25 THEN 'Ocorr�ncia inclu�da' WHEN HIS.FGTYPE=26 THEN 'Ocorr�ncia exclu�da' WHEN HIS.FGTYPE=27 THEN 'Projeto inclu�do' WHEN HIS.FGTYPE=28 THEN 'Projeto exclu�do' WHEN HIS.FGTYPE=29 THEN 'Processo bloqueado para edi��o' WHEN HIS.FGTYPE=30 THEN 'Processo desbloqueado' WHEN HIS.FGTYPE=31 THEN 'Atividade executada automaticamente' WHEN HIS.FGTYPE=32 THEN 'E-mail enviado' WHEN HIS.FGTYPE=33 THEN 'Risco inclu�do' WHEN HIS.FGTYPE=34 THEN 'Risco exclu�do' WHEN HIS.FGTYPE=35 THEN 'Atividade retornada' WHEN HIS.FGTYPE=36 THEN 'Controle inclu�do' WHEN HIS.FGTYPE=37 THEN 'Controle exclu�do' WHEN HIS.FGTYPE=40 THEN 'E-mail recebido' WHEN HIS.FGTYPE=41 THEN 'Evento de mensagem' END AS IDTYPE, HIS.NMACTION, HIS.NMROLE, HIS.NMUSER, HIS.TMHISTORY, HIS.DTHISTORY AS DTHISTORY, GNT.NMGENTYPE AS NMOCCURRENCETYPE FROM WFPROCESS P LEFT OUTER JOIN GNREVISION GREV ON (P.CDREVISION=GREV.CDREVISION) LEFT OUTER JOIN GNSLACONTROL SLACTRL ON (P.CDSLACONTROL=SLACTRL.CDSLACONTROL) LEFT OUTER JOIN ADUSER ADU ON (ADU.CDUSER=P.CDUSERSTART) LEFT OUTER JOIN PMACTIVITY PP ON (PP.CDACTIVITY=P.CDPROCESSMODEL) LEFT OUTER JOIN PMACTTYPE PT ON (PT.CDACTTYPE=PP.CDACTTYPE) LEFT OUTER JOIN GNREVISIONSTATUS GNRS ON (P.CDSTATUS=GNRS.CDREVISIONSTATUS) LEFT OUTER JOIN GNEVALRESULTUSED GNRUS ON (GNRUS.CDEVALRESULTUSED=P.CDEVALRSLTPRIORITY) LEFT OUTER JOIN GNEVALRESULT GNR ON (GNRUS.CDEVALRESULT=GNR.CDEVALRESULT) INNER JOIN INOCCURRENCE INCID ON (P.IDOBJECT=INCID.IDWORKFLOW) LEFT OUTER JOIN GNGENTYPE GNT ON (INCID.CDOCCURRENCETYPE=GNT.CDGENTYPE) INNER JOIN PBPROBLEM PB ON PB.CDOCCURRENCE=INCID.CDOCCURRENCE INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT P.IDOBJECT FROM WFPROCESS P INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON WF.CDTEAM=TM.CDTEAM WHERE 1=1 AND WF.FGACCESSTYPE=1 AND TM.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND WF.FGACCESSTYPE=2 AND UDP.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND WF.FGACCESSTYPE=3 AND UDP.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND WF.FGACCESSTYPE=4 AND UDP.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE 1=1 AND WF.FGACCESSTYPE=5 AND WF.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE 1=1 AND WF.FGACCESSTYPE=6 AND US.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON RL.CDROLE=WF.CDROLE WHERE 1=1 AND WF.FGACCESSTYPE=7 AND RL.CDUSER=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS WHERE 1=1 AND WF.FGACCESSTYPE=30 AND WFP.CDUSERSTART=5799 UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND WF.FGACCESSTYPE=31 AND US.CDLEADER=5799) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST AND GNASSOC.IDPROCESS=PERM.IDPROCESS WHERE 1=1 AND GNASSOC.CDACCESSROLEFIELD=501 GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON PERMISSION.IDPROCESS=P.IDOBJECT INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=P.IDOBJECT WHERE 1=1 AND PERMISSION.FGPERMISSION=1 AND P.FGSTATUS <= 5 AND (P.FGMODELWFSECURITY IS NULL OR P.FGMODELWFSECURITY=0) AND INCID.FGOCCURRENCETYPE=2 UNION ALL SELECT T.IDOBJECT FROM (SELECT PERM.IDOBJECT, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM1.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE 1=1 AND PM.FGACCESSTYPE=1 AND TM.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND PM.FGACCESSTYPE=2 AND UDP.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=3 AND UDP.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=4 AND UDP.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM WHERE 1=1 AND PM.FGACCESSTYPE=5 AND PM.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.FGACCESSTYPE=6 AND US.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE 1=1 AND PM.FGACCESSTYPE=7 AND RL.CDUSER=5799) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM2.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PMA.CDCREATEDBY AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE 1=1 AND PM.FGACCESSTYPE=8 AND PMA.CDCREATEDBY=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE 1=1 AND PM.FGACCESSTYPE=9 AND DEP2.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=10 AND DEP2.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE 1=1 AND PM.FGACCESSTYPE=11 AND DEP2.CDUSER=5799 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE 1=1 AND PM.FGACCESSTYPE=12 AND US.CDLEADER=5799) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PERM3.IDOBJECT, PMA.FGUSETYPEACCESS, PERM3.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, WFP.CDUSERSTART AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE 1=1 AND PM.FGACCESSTYPE=30 AND WFP.CDUSERSTART=5799 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1 UNION ALL SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND PM.FGACCESSTYPE=31 AND US.CDLEADER=5799 AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE 1=1 AND GNCTRL_F.CDRELATEDFIELD=501 AND PMA.FGUSETYPEACCESS=1) PERM WHERE 1=1 GROUP BY PERM.IDOBJECT) T INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=T.IDOBJECT WHERE 1=1 AND T.FGPERMISSION=1 AND INCID.FGOCCURRENCETYPE=2 UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE 1=1 AND PP.FGACCESSTYPE=1 AND TM.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE 1=1 AND PP.FGACCESSTYPE=2 AND UDP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PP.FGACCESSTYPE=3 AND UDP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE 1=1 AND PP.FGACCESSTYPE=4 AND UDP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE 1=1 AND PP.FGACCESSTYPE=5 AND PP.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE 1=1 AND PP.FGACCESSTYPE=6 AND US.CDUSER=5799 UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE 1=1 AND PP.FGACCESSTYPE=7 AND RL.CDUSER=5799) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE 1=1 AND GNCTRL.CDRELATEDFIELD=501 AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE 1=1 AND PP.FGACCESSTYPE=30 AND WFP.CDUSERSTART=5799 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5 UNION ALL SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE 1=1 AND PP.FGACCESSTYPE=31 AND US.CDLEADER=5799 AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE 1=1 AND GNCTRL.CDRELATEDFIELD=501 AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T INNER JOIN INOCCURRENCE INCID ON INCID.IDWORKFLOW=T.IDOBJECT WHERE 1=1 AND T.FGPERMISSION=1 AND INCID.FGOCCURRENCETYPE=2) Z WHERE 1=1) MYPERM ON (P.IDOBJECT=MYPERM.IDOBJECT) INNER JOIN WFHISTORY HIS ON (HIS.IDPROCESS=P.IDOBJECT) LEFT OUTER JOIN WFSTRUCT S ON (HIS.IDSTRUCT=S.IDOBJECT) WHERE 1=1 AND P.FGSTATUS <= 5 AND INCID.FGOCCURRENCETYPE=2 AND (GNT.CDTYPEROLE IS NULL OR EXISTS (SELECT 1 FROM (SELECT MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE) AS FGACCESSLIST, CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /**/UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM, ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.FGACCESSLIST=1 AND CHKPERMTYPEROLE.CDTYPEROLE=GNT.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=5799 OR 5799=-1))) AND HIS.FGTYPE <> 99) TEMPTB0) TEMPTB1