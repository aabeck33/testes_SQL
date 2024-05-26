---------------------
-- Descrição: Excelência Operacional (EXC_PLA-02/04)
-- Autor: Alvaro Adriano Beck
-- Descrição: Dados dos Planos de ação
-- Criada em: 01/2022
-- Atualizada em: 
--------------------------------------------------------------------------------
select * from (
select case when pilar is null then 'Total'
       else pilar end pilar
, quant
from (
select count(*) as quant
, substring(actp.nmactivity, charindex(' - ', actp.nmactivity, 1)+3, charindex(' - ', actp.nmactivity, 8) - charindex(' - ', actp.nmactivity, 1)-3) as pilar
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactionplan actpl on actp.cdgenactivity = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
where gntype.CDGENTYPEOWNER = 53 and actp.nmactivity like '0053 - %'  and actp.fgstatus = 3 and case when charindex(' - ', actp.nmactivity, 1) = 0 or charindex(' - ', actp.nmactivity, 8) = 0 then 'N/A' else 
substring(actp.nmactivity, charindex(' - ', actp.nmactivity, 1)+3, charindex(' - ', actp.nmactivity, 8) - charindex(' - ', actp.nmactivity, 1)-3) end in ('Custos', 'Pessoas', 'Produtividade', 'Qualidade')
group by substring(actp.nmactivity, charindex(' - ', actp.nmactivity, 1)+3, charindex(' - ', actp.nmactivity, 8) - charindex(' - ', actp.nmactivity, 1)-3)
with rollup
) _sub
) _sub2

---------------------
-- Descrição: Excelência Operacional (Germano e Fidélio)
-- Autor: Alvaro Adriano Beck
-- Descrição: Dados dos Planos de ação
-- Criada em: 09/2019
-- Atualizada em: 
--------------------------------------------------------------------------------
select CAST(gntype.IDGENTYPE + CASE WHEN gntype.IDGENTYPE IS NULL THEN NULL ELSE ' - ' END + gntype.NMGENTYPE AS VARCHAR(250)) AS planta
, actp.idactivity as plano, actp.nmactivity as nmplano, coalesce(actp.VLPERCENTAGEM,0) as porcentPlano
, actp.DTstartPLAN as dtInicioPlano_planed, actp.DTFINISHPLAN as dtFimPlano_planed
, actp.DTstart as dtInicioPlano_real, actp.DTFINISH as dtFimPlano_real
, (select nmuser from aduser where cduser=actp.cduser) as RespPlano
, case actp.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Verificação da eficácia'
    when 5 then 'Encerrado'
    WHEN 6 THEN 'Cancelado' 
    WHEN 7 THEN 'Cancelado' 
    WHEN 8 THEN 'Cancelado' 
    WHEN 9 THEN 'Cancelado' 
    WHEN 10 THEN 'Cancelado' 
    WHEN 11 THEN 'Cancelado'
end as statusPlano
, act.idactivity as idacao, act.nmactivity as nmacao, coalesce(act.VLPERCENTAGEM,0) as porcentAcao
, act.DTstartPLAN as dtInicioAcao_planed, act.DTFINISHPLAN as dtFimAcao_planed
, act.DTstart as dtInicioAcao_real, act.DTFINISH as dtFimAcao_real
, (select nmuser from aduser where cduser=act.cduser) as execAcao
, case act.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Aprovação da execução'
    when 5 then 'Encerrada'
    WHEN 6 THEN 'Cancelado' 
    WHEN 7 THEN 'Cancelado' 
    WHEN 8 THEN 'Cancelado' 
    WHEN 9 THEN 'Cancelado' 
    WHEN 10 THEN 'Cancelado' 
    WHEN 11 THEN 'Cancelado'
end as statusAcao
, 1 as quantidade
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
inner join gnactionplan actpl on act.cdactivityowner = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
where gntype.CDGENTYPEOWNER = 53


--===============================================> IN Elisa G.

Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus
    when 1 then 'Em andamento'
    when 2 then 'Suspenso'
    when 3 then 'Cancelado'
    when 4 then 'Encerrado'
    when 5 then 'Bloqueado para edição'
end as statusprocesso
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, case form.tds016 when 1 then 'Crítico' when 2 then 'Não crítico' end as crit
, case when (coalesce((SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
                WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject), cast('1970-01-01' as datetime)) > coalesce((SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
                WHERE str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject), cast('1970-01-01' as datetime))) then 'Aprovar [GQ1]'
       when (coalesce((SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
                WHERE str.idstruct = 'Decisão14102914536874' and str.idprocess=wf.idobject), cast('1970-01-01' as datetime)) = coalesce((SELECT str.DTEXECUTION+str.TMEXECUTION FROM WFSTRUCT STR
                WHERE str.idstruct = 'Decisão141111113212628' and str.idprocess=wf.idobject), cast('1970-01-01' as datetime))) then 'N/A'
       else 'Aprovar [GQ2]'
end atv_approva
, (SELECT max(str.DTEXECUTION+str.TMEXECUTION) as dtaprov FROM WFSTRUCT STR
WHERE (str.idstruct = 'Decisão14102914536874' or str.idstruct = 'Decisão141111113212628')and str.idprocess=wf.idobject) as dtaprov
, gnactp.idactivity as idplano
, case when exists (select 1 from gnactivity where cdactivityowner = gnactp.cdgenactivity and fgstatus <= 3 and dtfinish is null and dtfinishplan < getdate()) then 'Atraso' 
       when exists (select 1 from gnactivity where cdactivityowner = gnactp.cdgenactivity and fgstatus <= 3 and dtfinish is null and dtfinishplan >= getdate()) then 'Em dia'
       else 'N/A'
end as prazopl
, case gnactp.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Verificação da eficácia / Aprovação da execução'
    when 5 then 'Encerrado'
    WHEN 6 THEN 'Cancelado' 
    WHEN 7 THEN 'Cancelado' 
    WHEN 8 THEN 'Cancelado' 
    WHEN 9 THEN 'Cancelado' 
    WHEN 10 THEN 'Cancelado' 
    WHEN 11 THEN 'Cancelado'
    else 'N/A'
end as statuspl
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
where cdprocessmodel = 3234


--==============================================> UA - Melanie
select case act.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Verificação da eficácia / Aprovação da execução'
    when 5 then 'Encerrada'
    WHEN 6 THEN 'Cancelado' 
    WHEN 7 THEN 'Cancelado' 
    WHEN 8 THEN 'Cancelado' 
    WHEN 9 THEN 'Cancelado' 
    WHEN 10 THEN 'Cancelado' 
    WHEN 11 THEN 'Cancelado'
end as status
, act.VLPERCENTAGEM as [%]
, actp.idactivity as [AP ID #], actp.nmactivity as [AP Title], act.idactivity as [Task #], act.nmactivity as [Task Title]
, act.dtfinishplan as [Due Date]
, case when (act.fgstatus = 4 or act.fgstatus = 5) then act.dtfinish else null end as Submitted
, usr.nmuser as [Name], dep.iddepartment +' - '+ dep.nmdepartment as [Department]
, cast(coalesce((select substring((select ' | '+ wf.idprocess +' - '+ format(wf.dtstart, 'MM/dd/yyyy') as [text()] from DYNtds038 form
                                   inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
                                   inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
                                   INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
                                   inner join DYNtds041 rpl on rpl.OIDABCFHVABCAUY = form.oid
                                   where wf.cdprocessmodel = 4473 and form.tds005 = 2 and rpl.tds011 = actp.cdgenactivity and rpl.tds012 = act.cdgenactivity
                                   order by wf.dtstart
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as Requestes --requestList--
, 1 as quant
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
INNER JOIN gntask gntk ON gntk.cdgenactivity = act.cdgenactivity
LEFT OUTER JOIN aduser usr ON act.cduser = usr.cduser
LEFT OUTER JOIN aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1
LEFT OUTER JOIN addepartment dep on dep.cddepartment = rel.cddepartment
where plano.CDACTIONPLANTYPE in (122, 131, 132, 133, 134, 135)


---------------------
-- Descrição: Planos de ação GQ
-- Autor: Alvaro Adriano Beck
-- Descrição: Dados dos Planos de ação
-- Criada em: 09/2019
-- Atualizada em: 03/08/2020
--------------------------------------------------------------------------------
select actp.idactivity as plano, actp.nmactivity as nmplano, act.cdgenactivity, act.idactivity as atividade, act.nmactivity as nmatividade, actp.DTINSERT Dt_cadastro_acao
, coalesce((select substring((select ' | '+ wf.idprocess as [text()]
            from gnassocactionplan stpl
            inner JOIN GNACTIVITY GNP on stpl.cdassoc = GNP.cdassoc
            inner join wfprocess wf on wf.CDGENACTIVITY = gnp.CDGENACTIVITY
            where plano.cdgenactivity = stpl.cdactionplan FOR XML PATH('')), 4, 4000)), 'NA') as idprocess 
, case act.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Verificação da eficácia / Aprovação da execução'
    when 5 then 'Encerrada'
    WHEN 6 THEN 'Cancelado' 
    WHEN 7 THEN 'Cancelado' 
    WHEN 8 THEN 'Cancelado' 
    WHEN 9 THEN 'Cancelado' 
    WHEN 10 THEN 'Cancelado' 
    WHEN 11 THEN 'Cancelado'
end as status
, usr.nmuser as executor, dep.iddepartment +' - '+ dep.nmdepartment as executorarea, act.dtstartplan, act.dtfinishplan, act.dtstart, act.dtfinish
, case
        when suce.fgstatus <= 4 then 'Não'
        when suce.fgstatus > 4 then 'Sim'
        else ''
end liberada
, act.dsdescription as oque, gntk.dswhy as porque, gntk.dswhere as onde, act.dsactivity as como, aprov.dtapprov
, case
    when aprov.fgapprov = 1 then 'Aprovou'
    when aprov.fgapprov = 2 then 'Rejeitou'
end as aprovacao
, aprov.dsobs as dsobsaprov
, (select nmuser from aduser where cduser = aprov.cduserapprov) as aprovador
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
INNER JOIN gntask gntk ON gntk.cdgenactivity = act.cdgenactivity
left outer join GNACTIVITYLINKS link on link.cdactivity = act.cdgenactivity
left outer join gnactivity suce on suce.cdgenactivity = link.CDPREDECESSOR
LEFT OUTER JOIN aduser usr ON act.cduser = usr.cduser
LEFT OUTER JOIN aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1
LEFT OUTER JOIN addepartment dep on dep.cddepartment = rel.cddepartment
inner join gnvwapprovresp aprov on aprov.cdapprov = act.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
inner join (select max(cdcycle) as maxcycle, cdapprov
      from gnvwapprovresp where cdprod=174
      group by cdapprov) max_cycle on  aprov.cdcycle = max_cycle.maxcycle
where aprov.cdapprov = max_cycle.cdapprov and plano.CDACTIONPLANTYPE in (64,65,66,67,68,69)

------------
Select wf.idprocess, wf.nmprocess, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS statusproc
, plano.idactivity as Plano_id, plano.nmactivity as Plano_nm
, priori.nmevalresult, gntypepl.nmgentype as nmtipoplano, gntypepl.idgentype as idtipoplano
, case plano.fgstatus
     when  1 then 'Em planejamento'
     when  2 then 'Em aprovavação do planejamento'
     when  3 then 'Em execução'
     when  4 then 'Em aprovação da execução'
     when  5 then 'Encerrado'
     when  6 then 'Cancelado'
     when  7 then 'Cancelado'
     when  9 then 'Cancelado'
     when 10 then 'Cancelado'
     when 11 then 'Cancelado'
end as Plano_st
, (select nmuser from aduser where cduser = acao.cduser) as Acao_exec
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1 inner join addepartment dep on dep.cddepartment = rel.cddepartment where usr.cduser = acao.cduser) as Acao_area
, acao.idactivity as idAcao, acao.nmactivity as Acao_nm
, acao.dtstartplan as Acao_inicp, acao.dtfinishplan as Acao_fimpo, acao.dtstart as Acao_inicr, acao.dtfinish as Acao_fimr
, gntypeac.nmgentype as nmtipoacao, gntypeac.idgentype as idtipoacao
, case acao.fgstatus
     when  1 then 'Em planejamento'
     when  2 then 'Em aprovavação do planejamento'
     when  3 then 'Em execução'
     when  4 then 'Em aprovação da execução'
     when  5 then 'Encerrada'
     when  6 then 'Cancelada'
     when  7 then 'Cancelada'
     when  9 then 'Cancelada'
     when 10 then 'Cancelada'
     when 11 then 'Cancelada'
end as Acao_st
, (cast(substring((select ', '+ gnact.idactivity as [text()]
from GNACTIVITYLINKS pred
inner join gnactivity gnact on pred.cdpredecessor = gnact.cdgenactivity
where pred.cdactivity = acao.cdgenactivity
FOR XML PATH('')), 3, 250) as varchar(255))) as acao_predecessora
, case
    when (plano.fgstatus = 3 and acao.fgstatus = 3 and (select count(pred2.cdactivity) from GNACTIVITYLINKS pred2 where pred2.cdactivity = acao.cdgenactivity) = 0)
         or (plano.fgstatus = 3 and acao.fgstatus = 3 and (select min(gnact.fgstatus) from GNACTIVITYLINKS pred 
             inner join gnactivity gnact on pred.cdpredecessor = gnact.cdgenactivity where pred.cdactivity = acao.cdgenactivity)  > 4) then 'Sim'
    else 'Não'
end as acao_disp
, case when aprov.fgapprov = 1 then 'Sim' when aprov.fgapprov = 2 then 'Não' end as Apr_acao
, case when (coalesce(aprov.nmuserapprov, nmuser)) is not null then (coalesce(aprov.nmuserapprov, nmuser)) end as Apr_exec
, aprov.dtapprov as Apr_dt, aprov.cdcycle as qtdCiclos
, 1 as quantidade
from WFPROCESS wf
inner JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
inner join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
inner JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
INNER JOIN GNGENTYPE gntypepl ON gntypepl.CDGENTYPE = gnpl.CDACTIONPLANTYPE
inner JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
inner join gnactivity acao on plano.cdgenactivity = acao.cdactivityowner
inner join GNTMCACTIONPLAN TMCPLAN on TMCPLAN.CDGENACTIVITY = acao.CDGENACTIVITY
LEFT OUTER JOIN GNGENTYPE gntypeac ON (gntypeac.CDGENTYPE=TMCPLAN.CDACTIONPLANTYPE)
inner join GNEVALRESULTUSED GNEVALRESACT ON GNEVALRESACT.CDEVALRESULTUSED = plano.CDEVALRSLTPRIORITY
inner join GNEVALRESULT priori on priori.CDEVALRESULT=GNEVALRESACT.CDEVALRESULT
left join gnvwapprovresp aprov on aprov.cdapprov = acao.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 or (fgpend is null and fgapprov is null))
      or (fgpend = 1 and fgapprov is null)) and aprov.cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
where cdprocessmodel=1

------------------------------------------
select actp.idactivity as plano, actp.nmactivity as nmplano, act.idactivity as atividade, act.nmactivity as nmatividade, actp.DTINSERT Dt_cadastro_acao
, (select top 1 wf.idprocess
            from gnassocactionplan stpl
            inner JOIN GNACTIVITY GNP on stpl.cdassoc = GNP.cdassoc
            inner join wfprocess wf on wf.CDGENACTIVITY = gnp.CDGENACTIVITY
            where plano.cdgenactivity = stpl.cdactionplan and wf.idprocess like 'ANVTEQ%' order by wf.idprocess) as idprocess
, (select top 1 wf.nmprocess
            from gnassocactionplan stpl
            inner JOIN GNACTIVITY GNP on stpl.cdassoc = GNP.cdassoc
            inner join wfprocess wf on wf.CDGENACTIVITY = gnp.CDGENACTIVITY
            where plano.cdgenactivity = stpl.cdactionplan and wf.idprocess like 'ANVTEQ%' order by wf.idprocess) as nmprocess
, (select top 1 unid.NMATTRIBUTE
            from gnassocactionplan stpl
            inner JOIN GNACTIVITY GNP on stpl.cdassoc = GNP.cdassoc
            inner join wfprocess wf on wf.CDGENACTIVITY = gnp.CDGENACTIVITY
            inner join WFPROCATTRIB procunid on procunid.idprocess = wf.IDOBJECT and procunid.cdattribute=196
            inner JOIN ADATTRIBVALUE unid ON (procunid.CDATTRIBUTE = unid.CDATTRIBUTE AND procunid.CDVALUE = unid.CDVALUE)
            where plano.cdgenactivity = stpl.cdactionplan and wf.idprocess like 'ANVTEQ%' order by wf.idprocess) as cliente
, coalesce((select substring((select ' | '+ wf.idprocess as [text()]
            from gnassocactionplan stpl
            inner JOIN GNACTIVITY GNP on stpl.cdassoc = GNP.cdassoc
            inner join wfprocess wf on wf.CDGENACTIVITY = gnp.CDGENACTIVITY
            where plano.cdgenactivity = stpl.cdactionplan FOR XML PATH('')), 4, 4000)), 'NA') as listaproc 
, case act.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Verificação da eficácia / Aprovação da execução'
    when 5 then 'Encerrada'
    WHEN 6 THEN 'Cancelado' 
    WHEN 7 THEN 'Cancelado' 
    WHEN 8 THEN 'Cancelado' 
    WHEN 9 THEN 'Cancelado' 
    WHEN 10 THEN 'Cancelado' 
    WHEN 11 THEN 'Cancelado'
end as status
, usr.nmuser as executor, dep.iddepartment, acttype.idgentype, acttype.nmgentype, priori.nmevalresult as Prioridade
, act.dtstartplan, act.dtfinishplan, act.dtstart, act.dtfinish
, act.dsdescription as oque, gntk.dswhy as porque, gntk.dswhere as onde, act.dsactivity as como, aprov.dtapprov
, case
    when aprov.fgapprov = 1 then 'Aprovou'
    when aprov.fgapprov = 2 then 'Rejeitou'
end as aprovacao
, aprov.dsobs as dsobsaprov
, (select nmuser from aduser where cduser = aprov.cduserapprov) as aprovador
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
INNER JOIN gntask gntk ON gntk.cdgenactivity = act.cdgenactivity
inner join GNEVALRESULTUSED GNEVALRESACT ON GNEVALRESACT.CDEVALRESULTUSED = actp.CDEVALRSLTPRIORITY
inner join GNEVALRESULT priori on priori.CDEVALRESULT=GNEVALRESACT.CDEVALRESULT
inner join gngentype acttype on acttype.cdgentype = gntk.cdtasktype
LEFT JOIN aduser usr ON act.cduser = usr.cduser
left join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
left join addepartment dep on dep.cddepartment = rel.cddepartment
inner join gnvwapprovresp aprov on aprov.cdapprov = act.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
inner join (select max(cdcycle) as maxcycle, cdapprov
      from gnvwapprovresp where cdprod=174
      group by cdapprov) max_cycle on  aprov.cdcycle = max_cycle.maxcycle
where aprov.cdapprov = max_cycle.cdapprov and plano.CDACTIONPLANTYPE = 26
and actp.idactivity = 'AN-EQ-00500'



--=======================================================================
select * from (
select case when pilar is null then 'Total' 
            when pilar is not null and statusplano is null then 'Total - '+ pilar
       else pilar end pilar
, case when statusplano is null then pilar else statusplano end statusplano
, quant
from (
select count(*) as quant
, substring(actp.nmactivity, charindex(' - ', actp.nmactivity, 1)+3, charindex(' - ', actp.nmactivity, 8) - charindex(' - ', actp.nmactivity, 1)-3) as pilar
, case actp.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Verificação da eficácia'
    when 5 then 'Encerrado'
    WHEN 6 THEN 'Cancelado' 
    WHEN 7 THEN 'Cancelado' 
    WHEN 8 THEN 'Cancelado' 
    WHEN 9 THEN 'Cancelado' 
    WHEN 10 THEN 'Cancelado' 
    WHEN 11 THEN 'Cancelado'
end as statusPlano
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactionplan actpl on actp.cdgenactivity = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
where gntype.CDGENTYPEOWNER = 53 and actp.nmactivity like '0020 - %'
group by substring(actp.nmactivity, charindex(' - ', actp.nmactivity, 1)+3, charindex(' - ', actp.nmactivity, 8) - charindex(' - ', actp.nmactivity, 1)-3), actp.fgstatus
with rollup
) _sub
) _sub2
where (statusplano is not null and pilar <> 'Total') or pilar = 'Total'


select * from (
select case when pilar is null then 'Total'
       else pilar end pilar
, quant
from (
select count(*) as quant
, substring(actp.nmactivity, charindex(' - ', actp.nmactivity, 1)+3, charindex(' - ', actp.nmactivity, 8) - charindex(' - ', actp.nmactivity, 1)-3) as pilar
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactionplan actpl on actp.cdgenactivity = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
where gntype.CDGENTYPEOWNER = 53 and actp.nmactivity like '0020 - %'  and actp.fgstatus = 3
group by substring(actp.nmactivity, charindex(' - ', actp.nmactivity, 1)+3, charindex(' - ', actp.nmactivity, 8) - charindex(' - ', actp.nmactivity, 1)-3)
with rollup
) _sub
) _sub2


---------------------
-- Descrição: UA APL
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2021
-- Atualizada em: 07/2022
--------------------------------------------------------------------------------
select case act.fgstatus
    when 1 then 'Planning'
    when 2 then 'Planning approval'
    when 3 then 'Execution'
    when 4 then 'Effectinveness verification'
    when 5 then 'Finished'
    WHEN 6 THEN 'Cancelled' 
    WHEN 7 THEN 'Cancelled' 
    WHEN 8 THEN 'Cancelled' 
    WHEN 9 THEN 'Cancelled' 
    WHEN 10 THEN 'Cancelled' 
    WHEN 11 THEN 'Cancelled'
end as statusACT
, act.VLPERCENTAGEM as [%]
, actp.idactivity as [AP ID #], actp.nmactivity as [AP Title], act.idactivity as [Task #], act.nmactivity as [Task Title]
, act.dtfinishplan as [Due Date]
, case when (act.fgstatus = 4 or act.fgstatus = 5) then act.dtfinish else null end as Submitted
, usr.nmuser as [Name], dep.iddepartment +' - '+ dep.nmdepartment as [Department]
, cast(coalesce((select substring((select ' | '+ wf.idprocess +' - '+ format(wf.dtstart, 'MM/dd/yyyy') as [text()] from DYNtds038 form
                                   inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
                                   inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
                                   INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
                                   inner join DYNtds041 rpl on rpl.OIDABCFHVABCAUY = form.oid
                                   where wf.cdprocessmodel = 4473 and form.tds005 = 2 and rpl.tds011 = actp.cdgenactivity and rpl.tds012 = act.cdgenactivity
                                   order by wf.dtstart
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as Requests --requestList--
, 1 as quant
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
INNER JOIN gntask gntk ON gntk.cdgenactivity = act.cdgenactivity
LEFT OUTER JOIN aduser usr ON act.cduser = usr.cduser
LEFT OUTER JOIN aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1
LEFT OUTER JOIN addepartment dep on dep.cddepartment = rel.cddepartment
where plano.CDACTIONPLANTYPE in (122, 131, 132, 133, 134, 135)