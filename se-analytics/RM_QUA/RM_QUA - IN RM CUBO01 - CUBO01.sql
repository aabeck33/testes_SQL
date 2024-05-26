Select wf.idprocess, wf.nmprocess, wf.dtstart+wf.tmstart as dtabertura, wf.dtfinish+wf.tmfinish as dtfechamento , form.tds004 as prodcod, form.tds005 as proddesc, form.tds006 as prodlote , clini.tbs001 as critini, clfin.tbs001 as critfinal, ccr.tbs001 as catcausaraiz , case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edi��o' end as status_processo , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Atividade14102992123382' and str.idprocess=wf.idobject) as registrarRM_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Atividade14102992123382' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as registrarRM_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Atividade14102992123382' and str.idprocess=wf.idobject) as registrarRM_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Atividade14102992133595' and str.idprocess=wf.idobject) as investigarRM_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Atividade14102992133595' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as investigarRM_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Atividade14102992133595' and str.idprocess=wf.idobject) as investigarRM_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o14102992143534' and str.idprocess=wf.idobject) as AprovarSUP_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o14102992143534' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarSUP_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o14102992143534' and str.idprocess=wf.idobject) as AprovarSUP_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1516102916658' and str.idprocess=wf.idobject) as AprovarPRD_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1516102916658' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarPRD_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1516102916658' and str.idprocess=wf.idobject) as AprovarPRD_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o157718229336' and str.idprocess=wf.idobject) as AprovarMAN_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o157718229336' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarMAN_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o157718229336' and str.idprocess=wf.idobject) as AprovarMAN_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1577182214624' and str.idprocess=wf.idobject) as AprovarDME_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1577182214624' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarDME_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1577182214624' and str.idprocess=wf.idobject) as AprovarDME_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1577182212159' and str.idprocess=wf.idobject) as AprovarPeD_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1577182212159' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarPeD_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1577182212159' and str.idprocess=wf.idobject) as AprovarPeD_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o151610294178' and str.idprocess=wf.idobject) as AprovarARM_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o151610294178' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarARM_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o151610294178' and str.idprocess=wf.idobject) as AprovarARM_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1516102925488' and str.idprocess=wf.idobject) as AprovarQFR_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1516102925488' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarQFR_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1516102925488' and str.idprocess=wf.idobject) as AprovarQFR_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1516102910388' and str.idprocess=wf.idobject) as AprovarCTQ_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1516102910388' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarCTQ_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1516102910388' and str.idprocess=wf.idobject) as AprovarCTQ_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1573193017951' and str.idprocess=wf.idobject) as AprovarETB_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1573193017951' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarETB_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1573193017951' and str.idprocess=wf.idobject) as AprovarETB_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1573193023204' and str.idprocess=wf.idobject) as AprovarTER_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1573193023204' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarTER_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1573193023204' and str.idprocess=wf.idobject) as AprovarTER_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o157718221789' and str.idprocess=wf.idobject) as AprovarRPT_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o157718221789' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarRPT_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o157718221789' and str.idprocess=wf.idobject) as AprovarRPT_dtini , (SELECT str.DTEXECUTION FROM WFSTRUCT STR WHERE str.idstruct = 'Decis�o1516102835296' and str.idprocess=wf.idobject) as AprovarAAD_dtexe , (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idstruct = 'Decis�o1516102835296' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarAAD_resp , (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Decis�o1516102835296' and str.idprocess=wf.idobject) as AprovarAAD_dtini , 1 as quantidade from wfprocess wf inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc) inner join DYNtds014 form on (gnf.oidentityreg = form.oid) left join DYNtbs028 clini on clini.oid = form.OIDABCAEYABCCTT left join DYNtbs027 clfin on clfin.oid = form.OIDABCGKSABC3AJ left join DYNtbs022 ccr on ccr.oid = form.OIDABCK1AABCETU where wf.cdprocessmodel = 3238 and exists (select 1 from wfstruct wfs where wfs.idprocess = wf.idobject and wfs.idstruct in ('Atividade14102992123382','Atividade14102992133595','Decis�o14102992143534','Decis�o1516102916658','Decis�o157718229336','Decis�o1577182214624','Decis�o1577182212159','Decis�o151610294178','Decis�o1516102925488','Decis�o1516102910388','Decis�o1573193017951','Decis�o1573193023204','Decis�o157718221789','Decis�o1516102835296'))