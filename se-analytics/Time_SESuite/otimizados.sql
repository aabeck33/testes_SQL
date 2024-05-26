-- AN - Desvio Cubo 01 parte 1
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, 'NA' as repqualidade
, case form.tbs027 when 1 then 'Sim' when 2 then 'Não' end as lotebloq
, case form.tbs028 when 1 then 'Sim' when 2 then 'Não' end as procbloq
, case form.tbs041 when 1 then 'Sim' when 2 then 'Não' end as capa
, case form.tbs080 when 1 then 'Sim' when 2 then 'Não' end as clientefinal
, case form.tbs055 when 1 then 'Sim' when 2 then 'Não' end as relprod
, case when (form.tbs072 = 1 OR form.tbs073 = 1 OR form.tbs074 = 1 OR form.tbs075 = 1 OR form.tbs076 = 1) then 'Sim' 
       when (form.tbs072 = 2 OR form.tbs073 = 2 OR form.tbs074 = 2 OR form.tbs075 = 2 OR form.tbs076 = 2) then 'Não' end as hse
, case form.tbs072 when 1 then 'Sim' when 2 then 'Não' end as hse1
, case form.tbs073 when 1 then 'Sim' when 2 then 'Não' end as hse2
, case form.tbs074 when 1 then 'Sim' when 2 then 'Não' end as hse3
, case form.tbs075 when 1 then 'Sim' when 2 then 'Não' end as hse4
, case form.tbs076 when 1 then 'Sim' when 2 then 'Não' end as hse5
, case form.tbs048 when 1 then 'Sim' when 2 then 'Não' end as verifeficacia
, case gnrev.NMREVISIONSTATUS when 'Encerrado' then case form.tbs081 when 1 then 'Eficaz' when 2 then 'Não eficaz' else '' end else '' end as eficacia
, case form.tbs030 when 0 then 'Não' when 1 then 'Sim' end recorrente
, case form.tbs016 when 0 then 'Não' when 1 then 'Sim' end provterceiro
, case form.aguardapl when 0 then 'Não' when 1 then 'Sim' end aguardapl
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, form.tbs012 as dtdeteccao
, form.tbs013 as dtocorrencia
, form.tbs014 as dtlimite
, form.tbs017 as nometerceiro, form.tbs039 as loteterceiro, form.tbs057 as justrelprod
, case when form.tbs012 is not null then datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), cast(format(wf.dtstart,'yyyy/MM/dd') as date)) else -1 end as tempabertura
, case when case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then
datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else
datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), getdate()) end > 25 then 'Em atraso' else 'Em dia' end as prazoproc
, case when case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) is not null then
datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject)) else
datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), getdate()) end > 3 then 'Em atraso' else 'Em dia' end as prazoabertura
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) is not null then
datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject)) else -1 end as tempoaprovinicial
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then
datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else -1 end as tempoaprovfinal
, case when (case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then
datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else -1 end) > 30 then 
   'Em atraso' else 'Em dia' end as tempoaprovfinalc
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) is not null and
(SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then
datediff(dd, (SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else -1 end as tempototinvestiga
, 'NA' as prazoanaliscli
, cast(coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs012 where OIDABCBZmABCZOW = form.oid FOR XML PATH('')), 4, 8000)), 'NA') as varchar(8000)) as prodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity + ' - ' + CASE
                     WHEN gnactp.NRTASKSEQ = 1 THEN 'Alta prioridade'
                     WHEN gnactp.NRTASKSEQ = 2 THEN 'Média prioridade'
                     WHEN gnactp.NRTASKSEQ = 3 THEN 'Baixa prioridade'
                     ELSE ''
                 END as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, cast(coalesce((select substring((select ' | '+ gnact.nmactivity +' / '+ case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end +' / '+
  case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end +' / '+ gnactowner.nmactivity as [text()] from WFSTRUCT wfs
				left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
				left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
				left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
                where wf.idobject = wfs.idprocess
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaadhoc --listaadhoc--
, areadetec.tbs11 as areadetec, areaocor.tbs11 as areaocorrencia, classinic.tbs005 as classificini, catevent.tbs006 as catevento
, catraiz.tbs007 as catcausaraiz, equipo.tbs013 as equipamento, dispfin.tbs009 as disposfinal, classfin.tbs002 as classfin, unid.tbs001 as unidade, 'NA' clienteafetado
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) as dtaprovinicial
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmaprovinicial
, datediff(dd, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Rejeitar')
and his.nmaction = 'Rejeitar' group by his.DTHISTORY) _sub), (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Aprovar')
and his.nmaction = 'Aprovar' group by his.DTHISTORY) _sub)) as ciclorejinicial
, (SELECT count(his.nmaction)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9
and his.nmaction = 'Rejeitar') as regaprovinicial
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) as dtaprovfinal
, datediff(dd, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Rejeitar')
and his.nmaction = 'Rejeitar' group by his.DTHISTORY) _sub), (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Aprovar')
and his.nmaction = 'Aprovar' group by his.DTHISTORY) _sub)) as ciclorejinfinal
, (SELECT count(his.nmaction)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9
and his.nmaction = 'Rejeitar') as regaprovfinal
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade141027113051875' and str.idprocess=wf.idobject) as dtsubmeteregistro
, coalesce((SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade141027113146417' and str.idprocess=wf.idobject and str.idobject = wfa.idobject), form.tbs044) as investigador
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade141027113146417' and str.idprocess=wf.idobject) as dtinvestigador
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113659651' and str.idprocess=wf.idobject) as dtareaacorr
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1571615355993' and str.idprocess=wf.idobject) as dtpuverde
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153513122' and str.idprocess=wf.idobject) as dtpuamarela
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153516481' and str.idprocess=wf.idobject) as dtcqfisicoquim
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153519931' and str.idprocess=wf.idobject) as dtcqmicrobio
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153521833' and str.idprocess=wf.idobject) as dtcqmatemb
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153523510' and str.idprocess=wf.idobject) as dthse
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153525165' and str.idprocess=wf.idobject) as dtfiscal
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153526920' and str.idprocess=wf.idobject) as dtestab
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153529862' and str.idprocess=wf.idobject) as dtplanej
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153531348' and str.idprocess=wf.idobject) as dtdeposit
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153533198' and str.idprocess=wf.idobject) as dteng
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1571615353578' and str.idprocess=wf.idobject) as dtped
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1571615353895' and str.idprocess=wf.idobject) as dtvalmetana
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153540364' and str.idprocess=wf.idobject) as dtvalida
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153542651' and str.idprocess=wf.idobject) as dtti
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153554750' and str.idprocess=wf.idobject) as dtbpf
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153557102' and str.idprocess=wf.idobject) as dtsgq
--prod--, prod.tbs003 as codprod, prod.tbs002 as descprod, prod.tbs004 as lotes
--placao--, gnactp.idactivity as idplano
/* adhoc
, gnact.nmactivity, case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end as status
, case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end as executor
, gnactowner.nmactivity as nmactowner
*/
, 1 as quantidade
from DYNtbs010 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs011 areadetec on areadetec.oid = form.OIDABCDfwABC5KU
left join DYNtbs011 areaocor on areaocor.oid = form.OIDABCM6gABCRMJ
left join DYNtbs005 classinic on classinic.oid = form.OIDABCbhdABCcG4
left join DYNtbs006 catevent on catevent.oid = form.OIDABCPnPABCtlj
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABC3i7ABC2fm
left join DYNtbs013 equipo on equipo.oid = form.OIDABCcotABCnUs
left join DYNtbs009 dispfin on dispfin.oid = form.OIDABCInNABCCBb
left join DYNtbs002 classfin on classfin.oid = form.OIDABClGPABCiPe
left join DYNtbs001 unid on unid.oid = form.OIDABCoXzABC5KA
--prod--left join DYNtbs012 prod on form.oid = prod.OIDABCBZmABCZOW
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wf.cdprocessmodel=17


-- AN - Desvio Cubo 01 parte 2
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, form.tds071 as repqualidade
, case form.tds030 when 1 then 'Sim' when 2 then 'Não' end as lotebloq
, case form.tds031 when 1 then 'Sim' when 2 then 'Não' end as procbloq
, case form.tds039 when 1 then 'Sim' when 2 then 'Não' end as capa
, 'NA' as clientefinal
, case form.tds009 when 1 then 'Sim' when 2 then 'Não' end as relprod
, case when (form.tds017 = 1 OR form.tds018 = 1 OR form.tds019 = 1 OR form.tds020 = 1 OR form.tds021 = 1) then 'Sim' 
       when (form.tds017 = 2 OR form.tds018 = 2 OR form.tds019 = 2 OR form.tds020 = 2 OR form.tds021 = 2) then 'Não' end as hse
, case form.tds017 when 1 then 'Sim' when 2 then 'Não' end as hse1
, case form.tds018 when 1 then 'Sim' when 2 then 'Não' end as hse2
, case form.tds019 when 1 then 'Sim' when 2 then 'Não' end as hse3
, case form.tds020 when 1 then 'Sim' when 2 then 'Não' end as hse4
, case form.tds021 when 1 then 'Sim' when 2 then 'Não' end as hse5
, case form.tds044 when 1 then 'Sim' when 2 then 'Não' end as verifeficacia
, case gnrev.NMREVISIONSTATUS when 'Encerrado' then coalesce((SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141027113926692' and str.idprocess = wf.idobject and str.idobject = wfa.idobject),
      'Eficaz') else 'NA' end as eficacia
, case form.tds052 when 1 then 'Sim' when 2 then 'Não' end recorrente
, case form.tds006 when 0 then 'Não' when 1 then 'Sim' end provterceiro
, case form.tds042 when 0 then 'Não' when 1 then 'Sim' end aguardapl
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, form.tds001 as dtdeteccao
, form.tds002 as dtocorrencia
, form.tds003 as dtlimite
, form.tds007 as nometerceiro, form.tds008 as loteterceiro, form.tds010 as justrelprod
, case when form.tds001 is not null then datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), cast(format(wf.dtstart,'yyyy/MM/dd') as date)) else -1 end as tempabertura
, case when case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then 
      datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else 
      datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), getdate()) end > 25 then 'Em atraso' else 'Em dia' end as prazoproc
, case when case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) is not null then 
      datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject)) else 
      datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), getdate()) end > 3 then 'Em atraso' else 'Em dia' end as prazoabertura
, case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) is not null then 
      datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject)) else -1 end as tempoaprovinicial
, case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then 
      datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date), (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else -1 end as tempoaprovfinal
, case when (case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then 
      datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else -1 end) > 30 then 'Em atraso' else 'Em dia' end as tempoaprovfinalc
, case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) is not null and 
(SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) is not null then 
      datediff(dd, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject), (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject)) else -1 end as tempototinvestiga
, case (SELECT str.FGCONCLUDEDSTATUS FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade1571413144783' and str.idprocess=wf.idobject) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoanaliscli
, cast(coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs012 where OIDABCr58ABCzha = form.oid FOR XML PATH('')), 4, 8000)), 'NA') as varchar(8000)) as prodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity + ' - ' + CASE
                     WHEN gnactp.NRTASKSEQ = 1 THEN 'Alta prioridade'
                     WHEN gnactp.NRTASKSEQ = 2 THEN 'Média prioridade'
                     WHEN gnactp.NRTASKSEQ = 3 THEN 'Baixa prioridade'
                     ELSE ''
                 END as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, cast(coalesce((select substring((select ' | '+ gnact.nmactivity +' / '+ case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end +' / '+
  case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end +' / '+ gnactowner.nmactivity as [text()] from WFSTRUCT wfs
				left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
				left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
				left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
                where wf.idobject = wfs.idprocess
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaadhoc --listaadhoc--
, areadetec.tbs11 as areadetec, areaocor.tbs11 as areaocorrencia, classinic.tbs005 as classificini, catevent.tbs006 as catevento
, catraiz.tbs007 as catcausaraiz, equipo.tbs013 as equipamento, dispfin.tbs009 as disposfinal, classfin.tbs002 as classfin, unid.tbs001 as unidade, cliafet.tbs001 as clienteafetado
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject) as dtaprovinicial
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmaprovinicial
, datediff(dd, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Rejeitar')
and his.nmaction = 'Rejeitar' group by his.DTHISTORY) _sub), (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Aprovar')
and his.nmaction = 'Aprovar' group by his.DTHISTORY) _sub)) as ciclorejinicial
, (SELECT count(his.nmaction)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9
and his.nmaction = 'Rejeitar') as regaprovinicial
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) as dtaprovfinal
, datediff(dd, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Rejeitar')
and his.nmaction = 'Rejeitar' group by his.DTHISTORY) _sub), (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9 and his1.nmaction = 'Aprovar')
and his.nmaction = 'Aprovar' group by his.DTHISTORY) _sub)) as ciclorejinfinal
, (SELECT count(his.nmaction)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9
and his.nmaction = 'Rejeitar') as regaprovfinal
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade141027113051875' and str.idprocess=wf.idobject) as dtsubmeteregistro
, coalesce((SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade141027113146417' and str.idprocess=wf.idobject and str.idobject = wfa.idobject), form.tds004) as investigador
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade141027113146417' and str.idprocess=wf.idobject) as dtinvestigador
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113659651' and str.idprocess=wf.idobject) as dtareaacorr
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1571615355993' and str.idprocess=wf.idobject) as dtpuverde
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153513122' and str.idprocess=wf.idobject) as dtpuamarela
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153516481' and str.idprocess=wf.idobject) as dtcqfisicoquim
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153519931' and str.idprocess=wf.idobject) as dtcqmicrobio
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153521833' and str.idprocess=wf.idobject) as dtcqmatemb
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153523510' and str.idprocess=wf.idobject) as dthse
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153525165' and str.idprocess=wf.idobject) as dtfiscal
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153526920' and str.idprocess=wf.idobject) as dtestab
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153529862' and str.idprocess=wf.idobject) as dtplanej
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153531348' and str.idprocess=wf.idobject) as dtdeposit
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153533198' and str.idprocess=wf.idobject) as dteng
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1571615353578' and str.idprocess=wf.idobject) as dtped
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1571615353895' and str.idprocess=wf.idobject) as dtvalmetana
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153540364' and str.idprocess=wf.idobject) as dtvalida
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153542651' and str.idprocess=wf.idobject) as dtti
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153554750' and str.idprocess=wf.idobject) as dtbpf
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão15716153557102' and str.idprocess=wf.idobject) as dtsgq
--prod--, prod.tbs003 as codprod, prod.tbs002 as descprod, prod.tbs004 as lotes
--placao--, gnactp.idactivity as idplano
/* adhoc
, gnact.nmactivity, case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end as status
, case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end as executor
, gnactowner.nmactivity as nmactowner
*/
, 1 as quantidade
from DYNtds010 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs011 areadetec on areadetec.oid = form.OIDABC1moABCe0S
left join DYNtbs011 areaocor on areaocor.oid = form.OIDABCO2wABCqaO
left join DYNtbs005 classinic on classinic.oid = form.OIDABCCM0ABCSbb
left join DYNtbs006 catevent on catevent.oid = form.OIDABCV3fABC895
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABChG0ABCjLn
left join DYNtbs037 cliafet on cliafet.oid = form.OIDABCGpkABCxJ0
left join DYNtbs013 equipo on equipo.oid = form.OIDABCx5sABCIJb
left join DYNtbs009 dispfin on dispfin.oid = form.OIDABCjBjABCGzr
left join DYNtbs002 classfin on classfin.oid = form.OIDABC4sfABC3Qp
left join DYNtbs001 unid on unid.oid = form.OIDABCNyxABCtag
--prod--left join DYNtbs012 prod on form.oid = prod.OIDABCr58ABCzha
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wf.cdprocessmodel=17

-- AN - CM Cubo 01 parte 2
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, form.tds002 as nmterceiro, form.tds017 as nmaprovaremud
, case form.tds016 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, case form.tds107 when 1 then 'Sim' when 2 then 'Não' end as mbr
, case form.tds108 when 1 then 'Melhoria' when 2 then 'Atualização obrigatória' end as tpmbr
, case form.tds109 when 1 then 'Sim' when 2 then 'Não' end as info1lote
, case when form.tds004 = 1 then '' else form.tds005 end as dtinitemp
, case when form.tds004 = 1 then '' else form.tds006 end as dtfimtemp
, case when form.tds004 = 1 then '' else form.tds007 end as lotestemp
, case form.tds004 when 1 then 'Permanente' when 2 then 'Temporária' end as classific
, case form.tds024 when 0 then 'Não' when 1 then 'Sim' end as materialprod
, case form.tds001 when 0 then 'Não' when 1 then 'Sim' end as impactterc
, null as impactcli
, case form.tds013 when 0 then 'Não' when 1 then 'Sim' end as avalcli
, case form.tds003 when 0 then 'Não' when 1 then 'Sim' end as emergencial
, case form.tds112 when 0 then 'Não' when 1 then 'Sim' end as impactliberalote
, case form.tds011 when 0 then 'Não' when 1 then 'Sim' end as tpimpacto_validacao
, case form.tds012 when 0 then 'Não' when 1 then 'Sim' end as tpimpacto_qualificacao
, case form.tds105 when 0 then 'Não' when 1 then 'Sim' end as tpimpacto_estabiliadde
, case form.tds106 when 0 then 'Não' when 1 then 'Sim' end as tpimpacto_regulatorio
, areamud.tbs001 as areamudanca, 'NA' as areainiciadora, unid.tbs001 as unidade
, cast(coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +
     ' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +
     ' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCIQeABC45y = form.oid 
     FOR XML PATH('')), 4,99000)), 'NA') as varchar(max)) as listaprodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, cast(coalesce((select substring((select ' | '+ gnact.nmactivity +' / '+ case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end +' / '+
  case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end +' / '+ gnactowner.nmactivity as [text()] from WFSTRUCT wfs
				left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
				left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
				left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
                where wf.idobject = wfs.idprocess
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaadhoc --listaadhoc--
, cast(coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABCtTKABCkFM = form.oid 
   FOR XML PATH('')), 4, 1000)), 'NA') as varchar(1000)) as listaclientes --listaclientes--
, cast(coalesce((select substring((select ' | '+ tds001 +' - '+ tds002 +' - '+ format(tds003,'dd/MM/yyyy') as [text()] from DYNtds043 where OIDABC8eEABCZHc = form.oid 
   FOR XML PATH('')), 4, 1000)), 'NA') as varchar(1000)) as listaregulatórios --listaregulatórios--
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, 
                              tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, 
                              tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),8,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds067,tds068,tds069,tds070,tds071,tds072,tds073,tds074,tds075,tds076,tds077,tds078,tds079,tds080,tds081,tds082,tds083,tds084,tds085,tds086,
                              tds087,tds088,tds089,tds090,tds091,tds092,tds093,tds094,tds095,tds096,tds097,tds098,tds099,tds100,tds101,tds102,tds103)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as areasaval
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject
) as dtsubmis
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject and str.idobject = wfa.idobject
) as nmaprov
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject) as dtaprov
--placao--, gnactp.idactivity as idplano
/* adhoc
, gnact.nmactivity, case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end as status
, case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end as executor
, gnactowner.nmactivity as nmactowner
*/
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102914543984' and str.idprocess=wf.idobject) as dtencerrou
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102914543984' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmencerrou
, case when gnrev.NMREVISIONSTATUS = 'Cancelado' then case (SELECT WFA.FGAUTOEXECUTION FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject and str.idobject = wfa.idobject and WFA.NMEXECUTEDACTION = 'Cancelar'
) when 1 then 'Automático na primeira atividade' when 2 then 'Não Automático na primeira atividade' else 'Por solicitação' end
end Cancelamento
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject), getdate())/1440 end tpsegaprov
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject), getdate())/1440 end tppriaprov
, case when (SELECT max(str.DTEXECUTION+str.TMEXECUTION) FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade176913390667', 'Atividade14102914459502') and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT max(str.DTENABLED+str.TMENABLED) FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade176913390667', 'Atividade14102914459502') and str.idprocess=wf.idobject), (
SELECT max(str.DTEXECUTION+str.TMEXECUTION) FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade176913390667', 'Atividade14102914459502') and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT max(str.DTENABLED+str.TMENABLED) FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade176913390667', 'Atividade14102914459502') and str.idprocess=wf.idobject), getdate())/1440 end tpcriaplacao
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject), getdate())/1440 end tpaguardacli
, (select max(dtexecution) from (SELECT max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189') and str.idprocess=wf.idobject group by str.dtexecution) _sub) as dtlibera
, (select nmuser from (SELECT top 1 max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION, WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189') and str.idprocess=wf.idobject and str.idobject = wfa.idobject 
group by str.dtexecution, wfa.nmuser order by str.dtexecution DESC) _sub) as nmlibera
, datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject), (select max(dtexecution) from 
       (SELECT max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189') and str.idprocess=wf.idobject 
group by str.dtexecution) _sub))/1440 as tempoaceita
, (SELECT count(WFA.NMEXECUTEDACTION) FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject and str.idobject = wfa.idobject and wfa.NMEXECUTEDACTION = 'Submeter') as qtdciclos
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs039 areamud on areamud.oid = form.OIDABCk8DABCghk
left join DYNtbs001 unid on unid.oid = form.OIDABCVrhABCPrY
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where cdprocessmodel=1

-- AN - CM Cubo 01 parte 1
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, form.tbs009 as nmterceiro, form.tbs033 as nmaprovaremud
, case form.tbs030 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, 'NA' as mbr
, 'NA' as tpmbr
, 'NA' as info1lote
, case when form.tbs011 = 1 then '' else form.tbs012 end as dtinitemp
, case when form.tbs011 = 1 then '' else form.tbs013 end as dtfimtemp
, case when form.tbs011 = 1 then '' else form.tbs014 end as lotestemp
, case form.tbs011 when 1 then 'Permanente' when 2 then 'Temporária' end as classific
, case form.tbs055 when 0 then 'Não' when 1 then 'Sim' end as materialprod
, case form.tbs008 when 0 then 'Não' when 1 then 'Sim' end as impactterc
, case form.tbs022 when 0 then 'Não' when 1 then 'Sim' end as impactcli
, case form.tbs026 when 0 then 'Não' when 1 then 'Sim' end as avalcli
, case form.tbs010 when 0 then 'Não' when 1 then 'Sim' end as emergencial
, case form.tbs020 when 0 then 'Não' when 1 then 'Sim' end as impactliberalote
, 'NA' as tpimpacto_validacao
, 'NA' as tpimpacto_qualificacao
, 'NA' as tpimpacto_estabiliadde
, 'NA' as tpimpacto_regulatorio
, areamud.tbs001 as areamudanca, areaini.tbs001 as areainiciadora, unid.tbs001 as unidade
, cast(coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCFCIABCMH0 = form.oid FOR XML PATH('')), 4, 40000)), 'NA')  as varchar(8000)) as listaprodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, cast(coalesce((select substring((select ' | '+ gnact.nmactivity +' / '+ case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end +' / '+
  case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end +' / '+ gnactowner.nmactivity as [text()] from WFSTRUCT wfs
				left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
				left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
				left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
                where wf.idobject = wfs.idprocess
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaadhoc --listaadhoc--
, cast(coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABC1pFABCwh3 = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as varchar(1000)) as listaclientes --listaclientes--
, 'NA' as listaregulatórios
, cast(coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs019 where OIDABCJonABCFKa = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as varchar(1000)) as listamudanca --listamudanca--
, 'NA' as areasaval
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject
) as dtsubmis
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject and str.idobject = wfa.idobject
) as nmaprov
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject) as dtaprov
--placao--, gnactp.idactivity as idplano
/* adhoc
, gnact.nmactivity, case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end as status
, case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end as executor
, gnactowner.nmactivity as nmactowner
*/
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102914543984' and str.idprocess=wf.idobject) as dtencerrou
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102914543984' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmencerrou
, case when gnrev.NMREVISIONSTATUS = 'Cancelado' then case (SELECT WFA.FGAUTOEXECUTION FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject and str.idobject = wfa.idobject and WFA.NMEXECUTEDACTION = 'Cancelar'
) when 1 then 'Automático na primeira atividade' when 2 then 'Não Automático na primeira atividade' else 'Por solicitação' end
end Cancelamento
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject), getdate())/1440 end tpsegaprov
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject), getdate())/1440 end tppriaprov
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102914459502' and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade14102914459502' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade14102914459502' and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade14102914459502' and str.idprocess=wf.idobject), getdate())/1440 end tpcriaplacao
, case when (SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject) is not null then
datediff(mi, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject))/1440 else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade141111113134390' and str.idprocess=wf.idobject), getdate())/1440 end tpaguardacli
, (select max(dtexecution) from (SELECT max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189') and str.idprocess=wf.idobject group by str.dtexecution) _sub) as dtlibera
, (select nmuser from (SELECT top 1 max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION, WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189') and str.idprocess=wf.idobject and str.idobject = wfa.idobject 
group by str.dtexecution, wfa.nmuser order by str.dtexecution DESC) _sub) as nmlibera
, datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject), (select max(dtexecution) from 
       (SELECT max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189') and str.idprocess=wf.idobject 
group by str.dtexecution) _sub))/1440 as tempoaceita
, (SELECT count(WFA.NMEXECUTEDACTION) FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102914347264' and str.idprocess=wf.idobject and str.idobject = wfa.idobject and wfa.NMEXECUTEDACTION = 'Submeter') as qtdciclos
, 1 as Quantidade
from DYNtbs015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs039 areamud on areamud.oid = form.OIDABCQueABCNDM
left join DYNtbs039 areaini on areaini.oid = form.OIDABC3a2ABCLSW
left join DYNtbs001 unid on unid.oid = form.OIDABCTYWABCE9z
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where cdprocessmodel=1

-- AN - LAB Cubo 09

Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, wf.dtstart as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, wf.dtfinish as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, form.tbs004 as dtdeteccao, datepart(yyyy,form.tbs004) as dtdeteccao_ano, datepart(MM,form.tbs004) as dtdeteccao_mes
, form.tbs005 as dtocorrencia, datepart(yyyy,form.tbs005) as dtocorrencia_ano, datepart(MM,form.tbs005) as dtocorrencia_mes
, form.tbs006 as dtlimite, datepart(yyyy,form.tbs006) as dtlimite_ano, datepart(MM,form.tbs006) as dtlimite_mes
, form.tbs002 as respanalisen1, form.tbs037 as respinvestiga, 'NA' as metodo, 'NA' as idamostra, 'NA' as descteste, 'NA' as especific
, catraiz.tbs007 as catcausaraiz, catev.tbs001 as tipo, laboc.tbs001 as laboratorio, unid.tbs001 as unidade
, case form.tbs011 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, case form.tbs035 when 1 then 'Crítico' when 2 then 'Não crítico' end as critfin
, case form.tbs029 when 1 then 'Sim' when 2 then 'Não' end as confirmada
, case form.tbs052 when 1 then 'Sim' when 2 then 'Não' end as necessidadeve
, case form.tbs031 when 0 then 'Não' when 1 then 'Sim' end as recorrente
, case form.tbs008 when 0 then 'Não' when 1 then 'Sim' end as ocoremterfornec
, case form.tbs022 when 0 then 'Não' when 1 then 'Sim' end as remedicao
, 'NA' as erroobvio
, 'NA' as extracaoadic
, 'NA' as amostraoriginal
, 'NA' as reamostragem
, 'NA' as aguardaplacao
, case gnrev.NMREVISIONSTATUS when 'Encerrado' then case form.tbs051 when 1 then 'Eficaz' when 2 then 'Não eficaz' else '' end else '' end as eficacia
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102895352873' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as investigadorn1
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade1410289542484' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as investigadorn2
, 'NA' as investigadorn3
, case coalesce((SELECT str.FGCONCLUDEDSTATUS FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102895346716' and str.idprocess=wf.idobject), -1) when 1 then 'Aberta no prazo' when 2 then 'Aberta em atraso' else 'NA' end as abertura
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102895346716' and str.idprocess=wf.idobject) as dtsubmissao
, case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102895442364' and str.idprocess=wf.idobject) is not null then
datediff (dd, form.tbs004, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102895442364' and str.idprocess=wf.idobject)) else -1 end as conclusao
, (select max(dtexecution) from (SELECT max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct in ('Decisão14102895442364', 'Decisão14102895449199') and str.idprocess=wf.idobject group by str.dtexecution) _sub) as dtencerrada
, coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs012 where OIDABCVdbABCyvW = form.oid FOR XML PATH('')), 4, 4000)), 'NA') as prodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, 1 as quantidade
from DYNtbs016 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs025 catev on catev.oid = form.OIDABCi3MABCjEA
left join DYNtbs026 laboc on laboc.oid = form.OIDABCYa3ABCdTh
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABC87ZABCfAP
left join DYNtbs001 unid on unid.oid = form.OIDABCONdABCARv
where wf.cdprocessmodel=38 and wf.fgstatus < 6
union all
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, wf.dtstart as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, wf.dtfinish as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, form.tds001 as dtdeteccao, datepart(yyyy,form.tds001) as dtdeteccao_ano, datepart(MM,form.tds001) as dtdeteccao_mes
, form.tds002 as dtocorrencia, datepart(yyyy,form.tds002) as dtocorrencia_ano, datepart(MM,form.tds002) as dtocorrencia_mes
, form.tds003 as dtlimite, datepart(yyyy,form.tds003) as dtlimite_ano, datepart(MM,form.tds003) as dtlimite_mes
, form.tds004 as respanalisen1, form.tds005 as respinvestiga, form.tds009 as metodo, form.tds010 as idamostra, form.tds011 as descteste, form.tds012 as especific
, catraiz.tbs007 as catcausaraiz, catev.tbs001 as tipo, laboc.tbs001 as laboratorio, unid.tbs001 as unidade
, case form.tds008 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, case form.tds031 when 1 then 'Crítico' when 2 then 'Não crítico' end as critfin
, case form.tds025 when 1 then 'Sim' when 2 then 'Não' end as confirmada
, case form.tds032 when 1 then 'Sim' when 2 then 'Não' end as necessidadeve
, case form.tds027 when 0 then 'Não' when 1 then 'Sim' end as recorrente
, case form.tds006 when 0 then 'Não' when 1 then 'Sim' end as ocoremterfornec
, case form.tds018 when 0 then 'Não' when 1 then 'Sim' end as remedicao
, case form.tds045 when 0 then 'Não' when 1 then 'Sim' end as erroobvio
, case form.tds044 when 0 then 'Não' when 1 then 'Sim' end as extracaoadic
, case form.tds048 when 0 then 'Não' when 1 then 'Sim' end as amostraoriginal
, case form.tds049 when 0 then 'Não' when 1 then 'Sim' end as reamostragem
, case form.tds043 when 0 then 'Não' when 1 then 'Sim' end as aguardaplacao
, case gnrev.NMREVISIONSTATUS when 'Encerrado' then coalesce((SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141028103225870' and str.idprocess=wf.idobject and str.idobject = wfa.idobject),'Eficaz') else '' end as eficaia
, (select NMUSER from (SELECT top 1 max(str.DTEXECUTION+str.TMEXECUTION) as mexec, WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct in ('Atividade14102895352873', 'Atividade17517142546397') and str.idprocess=wf.idobject and str.idobject = wfa.idobject
group by WFA.NMUSER, str.DTEXECUTION+str.TMEXECUTION order by str.DTEXECUTION+str.TMEXECUTION DESC) _sub) as investigadorn1
, (select NMUSER from (SELECT top 1 max(str.DTEXECUTION+str.TMEXECUTION) as mexec, WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct in ('Atividade1410289542484', 'Atividade17517142748315') and str.idprocess=wf.idobject and str.idobject = wfa.idobject
group by WFA.NMUSER, str.DTEXECUTION+str.TMEXECUTION order by str.DTEXECUTION+str.TMEXECUTION DESC) _sub) as investigadorn2
, (select NMUSER from (SELECT top 1 max(str.DTEXECUTION+str.TMEXECUTION) as mexec, WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct in ('Atividade17822182820415') and str.idprocess=wf.idobject and str.idobject = wfa.idobject
group by WFA.NMUSER, str.DTEXECUTION+str.TMEXECUTION order by str.DTEXECUTION+str.TMEXECUTION DESC) _sub) as investigadorn3
, case coalesce((SELECT str.FGCONCLUDEDSTATUS FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102895346716' and str.idprocess=wf.idobject), -1) when 1 then 'Aberta no prazo' when 2 then 'Aberta em atraso' else 'NA' end as abertura
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102895346716' and str.idprocess=wf.idobject) as dtsubmissao
, case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão17517143228556' and str.idprocess=wf.idobject) is not null then
datediff (dd, form.tds001, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão17517143228556' and str.idprocess=wf.idobject)) else -1 end as conclusao
, (select max(dtexecution) from (SELECT max(str.DTEXECUTION+str.TMEXECUTION) as mexec, str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct in ('Decisão17517143228556','Decisão14102895442364', 'Decisão14102895449199') and str.idprocess=wf.idobject group by str.dtexecution) _sub) as dtencerrada
, coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs012 where OIDABCZnQABCmWp = form.oid FOR XML PATH('')), 4, 4000)), 'NA') as prodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, 1 as quantidade
from DYNtds016 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs025 catev on catev.oid = form.OIDABCDVEABCirD
left join DYNtbs026 laboc on laboc.oid = form.OIDABCIsOABCqaE
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABCV7YABC5wq
left join DYNtbs001 unid on unid.oid = form.OIDABCcwcABCrcN
where wf.cdprocessmodel=38 and wf.fgstatus < 6


-- AN - CM Cubo 07
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, case form.tds005 when 1 then 'Alteração de prazo de atividade do processo' when 2 then 'Alteração de prazo de atividade de Plano de Ação' 
                   when 3 then 'Cancelamento de atividade de Plano de Ação' when 4 then 'Adendo' when 5 then 'Cancelamento do Processo' end tpsolicitação
, coalesce((select substring((select ' | '+ tds013 +' - '+ tds014 +' ('+ coalesce(format(tds007,'dd/MM/yyyy'),' ') +'='+ coalesce(format(tds008,'dd/MM/yyyy'),' ') +'/'+ tds003 +'='+ tds004 +'/Cancelar: '+ case TDS009 when 0 then 'Não' when 1 then 'Sim' end +')' as [text()] from DYNtds041 where OIDABCFHvABCauy = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaplano --listaplanoac--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplanoassoc --listaplação--
, coalesce((select substring((select ' | '+ tds001 +' ('+ coalesce(format(tds006,'dd/MM/yyyy'),' ') +'=>'+ coalesce(format(tds007,'dd/MM/yyyy'),' ') +')' as [text()] from DYNtds042 where OIDABCyheABCdqV = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaproc --listaproc--
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade15722172749323' and str.idprocess=wf.idobject) as dtaceitacao
, (SELECT WFA.NMACTION FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade15722172749323' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as acaceitacao
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade15722172749323' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmaceitacao
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject) as dtaprovacao
, (SELECT WFA.NMACTION FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as acaprovacao
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmaprovacao
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject) is not null then 
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade15722172749323' and str.idprocess=wf.idobject), (SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade15722172749323' and str.idprocess=wf.idobject)) else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade15722172749323' and str.idprocess=wf.idobject), getdate()) end end leadtime_avaliacao
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade1572217282722' and str.idprocess=wf.idobject) is not null then 
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade1572217282722' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade1572217282722' and str.idprocess=wf.idobject)) else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade1572217282722' and str.idprocess=wf.idobject), getdate()) end end leadtime_avareas
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject) is not null then 
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject)) else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1517164547614' and str.idprocess=wf.idobject), getdate()) end end leadtime_aprova
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade1572217288432' and str.idprocess=wf.idobject) is not null then 
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade1572217288432' and str.idprocess=wf.idobject), (
SELECT STR.DTEXECUTION + STR.TMEXECUTION FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade1572217288432' and str.idprocess=wf.idobject)) else
datediff(dd, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade1572217288432' and str.idprocess=wf.idobject), getdate()) end end leadtime_execucao
, (SELECT count(HIS.TMHISTORY)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Atividade1517164539264' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9
and HIS.NMACTION = 'Submeter') as qtdciclos
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, cast(coalesce((select substring((select ' | '+ gnact.nmactivity +' / '+ case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end +' / '+
  case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end +' / '+ gnactowner.nmactivity as [text()] from WFSTRUCT wfs
				left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
				left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
				left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
                where wf.idobject = wfs.idprocess
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaadhoc --listaadhoc--
, unid.tbs001 as unidade, areasol.tbs11 as areasolicitante
--placao--, gnactp.idactivity as idplanoassociado
, 1 as quantidade
from DYNtds038 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs001 unid on unid.oid = form.OIDABC5qIABClq3
left join DYNtbs011 areasol on areasol.oid = form.OIDABChRhABCLwI
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wf.cdprocessmodel=72 and form.tds003 = 2

-- AN - CM Cubo 10
Select wf.idprocess, wf.nmprocess, gnrev.NMREVISIONSTATUS as statusevento
, case wf.fgstatus
    when 1 then 'Em andamento'
    when 2 then 'Suspenso'
    when 3 then 'Cancelado'
    when 4 then 'Encerrado'
    when 5 then 'Bloqueado para edição'
end as statusprocesso
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject) as dtGQ1
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmGQ1
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject) as dtGQ2
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmGQ2
,  (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102914531751' and str.idprocess=wf.idobject) as dtAM
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão14102914531751' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmAM
, case when prodb.tbs002 is null then prodd.tbs002 else prodb.tbs002 end as codigo
, case when prodb.tbs001 is null then prodd.tbs001 else prodb.tbs001 end as descr
, case when prodd.tbs008 is null then case when clid.tbs001 is null then clib.tbs001 else clid.tbs001 end else prodd.tbs008 end as cliente
, gnactp.idactivity as plAcao, aprov.nmuser, convert(varchar(10),aprov.dtapprov, 103) as dataaprova
, 1 as Quantidade
from wfprocess wf
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
left join DYNtds015 formd on (gnf.oidentityreg = formd.oid)
left join DYNtbs015 formb on (gnf.oidentityreg = formb.oid)
left outer join gnrevisionstatus gnrs on (wf.cdstatus = gnrs.cdrevisionstatus)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left join DYNtbs024 prodb on prodb.OIDABCFCIABCMH0 = formb.oid
left join DYNtbs040 clib on clib.OIDABC1pFABCwh3 = formb.oid
left join DYNtbs024 prodd on prodd.OIDABCIQeABC45y = formd.oid
left join DYNtbs040 clid on clid.OIDABCtTKABCkFM = formd.oid
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left join gnactivity gnact on wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
left join gnvwapprovresp aprov on aprov.cdapprov = gnactp.CDPLANROUTE and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
left join (select max(cdcycle) as maxcycle, cdapprov
      from gnvwapprovresp where cdprod=174
      group by cdapprov) max_cycle on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where cdprocessmodel=1

-- IN - LAB Cubo 10
select form.tds005 as analista, form.tds009 as metodo, form.tds011 as teste
, wf.idprocess, wf.nmprocess, wf.dtstart, gnrev.NMREVISIONSTATUS as statuslab
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusprb
, catraiz.tbs007 as catcausaraiz, catev.tbs001 as catevento, laboc.tbs001 as laboratorio
, case form.tds008 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, case form.tds031 when 1 then 'Crítico' when 2 then 'Não crítico' end as critfin
, cast(coalesce((select substring((select ' | '+ equipo.tds001 as [text()] from DYNtds016 form1
                 left join DYNtds050 equipo on form1.oid = equipo.OIDABC60YRMLCRJSBK
                 where form1.oid = form.oid
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaequipamentos --listaequipamentos--
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143141313' 
      else 'Decisão17517143228556' end and str.idprocess=wf.idobject) as dtaprfinal
, 1 as quantidade
from DYNtds016 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs025 catev on catev.oid = form.OIDABCDVEABCirD
left join DYNtbs026 laboc on laboc.oid = form.OIDABCIsOABCqaE
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABCV7YABC5wq
left join DYNtbs001 unid on unid.oid = form.OIDABCcwcABCrcN
where wf.cdprocessmodel=3237
