---------------------> ITSM-35
-- Descrição: Treinamentos TI
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2022
-- Atualizada em: 
--------------------------------------------------------------------------------
select usr.nmuser,usr.idlogin, coalesce((select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') as areapadrao
, coordr.nmuser as lider
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, CHARINDEX('-', idposition)+1, 2) else '' end as setor
, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, 1, charindex('-',idposition)-1) else '' end as unid
, idposition , revc.iddocument, gnrevc.idrevision, revc.iddocument +'-'+ gnrevc.idrevision as POP
, case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
				tr1.fgstatus = 8 and tr1.FGCANCEL <> 1 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8 and tr2.FGCANCEL <> 1)), 'Não avaliado') = 'Aprovado')
       then 'Treinado'
       else case when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3))) <= 60 then 'Aguardando Treinamento – Homologação' else 'Aguardando Treinamento – Homologação (em atraso)' end end
end Situacao
, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and (pos.idposition like 'TICORP%')
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cddocument = revc.cddocument and revo.fgcurrent = case when (
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 4 and
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 5) then 1 else
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument)
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (110,46)
inner join aduser coordr on coordr.cduser = usr.cdleader
left join DYNitsm016 coordgs on (coordgs.ITSM001 = coordr.nmuser or coordgs.ITSM001 = usr.nmuser)
left join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
where usr.fguserenabled = 1
and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
from dcdocrevision revi
inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub
where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3))


----------------------------------------------------------------------------
select usr0.* from aduser usr0 where (select count(usr1.iduser) from aduser usr1 where usr1.idlogin = usr0.idlogin) > 1

--Modelo final:
select revc.cdrevision, usr.nmuser, usr.iduser, pos.nmposition, co.idcourse, revc.iddocument
, (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, (select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
   , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            and rev1.cdrevision = revc.cdrevision and stag1.DTAPPROVAL is not null
            group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) sub1) as data_primeira_aprovacao
, (select max(tr1.DTREALFINISH)
   from TRTRAINING tr1
   inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
   inner join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain and trev1.cdrevision = revc.cdrevision
  ) as dttreinamento
, coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8)
), 'Não avaliado') as condicao
, case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and 
														      tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
, gnrevc.DTREVISION
, (select tr1.idtrain
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and 
														      tr2.fgstatus = 8)
) as treinamento
, (select tr1.dtrealfinish
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and 
														      tr2.fgstatus = 8)
) as data_treinamento
, (select count(posp.nmposition)
from aduser usr0
inner join aduserdeptpos rel0 on rel0.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in 
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cdrevision = revc.cdrevision and revo.fgcurrent = case when (
                select max(revi.cdrevision)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cddocument = revc.cddocument and gnrevi.fgstatus not in (4,5)
                ) is not null then 1 else 
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument) 
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1
inner join aduserdeptpos relp on relp.cduser = usr0.cduser and relp.FGDEFAULTDEPTPOS = 1
inner join addepartment depp on depp.cddepartment = relp.cddepartment
inner join adposition posp on posp.cdposition = relp.cdposition
where usr0.cduser = usr.cduser) as total
, (select count(__subapro.situacao) from (select case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and 
														      tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
from aduser usr0
inner join aduserdeptpos rel0 on rel0.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in 
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cdrevision = revc.cdrevision and revo.fgcurrent = case when (
                select max(revi.cdrevision)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cddocument = revc.cddocument and gnrevi.fgstatus not in (4,5)
                ) is not null then 1 else 
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument) 
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1
where usr0.cduser = usr.cduser) __subapro where __subapro.situacao = 'Ok') as qtd_apro
, gnrevc.idrevision, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in 
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cdrevision = revc.cdrevision and revo.fgcurrent = case when (
                select max(revi.cdrevision)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cddocument = revc.cddocument and gnrevi.fgstatus not in (4,5)
                ) is not null then 1 else 
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument) 
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1
where usr.cduser = (select cduser from aduser where iduser = 'msfonseca')
Order by situacao, pos.nmposition, co.idcourse

---------------------
-- Descrição: Treinamento de POPs IN por área
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 12/2020
-- Atualizada em: 12/2021
--------------------------------------------------------------------------------
select nmuser, idlogin, nmposition as ROLE, situacao, areapadrao, pop
 from (
 select usr.iduser, usr.idlogin, usr.nmuser, pos.nmposition, co.idcourse, revc.iddocument, gnrevc.idrevision
 , coalesce(revc.iddocument, co.idcourse) as pop
 , case when gnrevc.DTREVISION is not null then gnrevc.DTREVISION else (select max(stag1.dtapproval)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                 stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3)) end as dtdoc
 , (select iddepartment+'-'+nmdepartment  from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
 , case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
               from trtraining tr1
               inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
               left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
               where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
 				tr1.fgstatus = 8 and tr1.FGCANCEL <> 1 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                         from TRTRAINING tr2
                                                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                         left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                         where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8 and tr1.FGCANCEL <> 1)), 'Não avaliado') = 'Aprovado')
        then 'Treinado'
        else case when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                 stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3))) <= 60 then 'Aguardando Treinamento – Homologação' else 'Aguardando Treinamento – Homologação (em atraso)' end end
 end Situacao
 , 1 as quantidade
 from aduser usr
 inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
 inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
 inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and (idposition like '%GRU-%' OR idposition LIKE '%IN0030%')
 inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
 inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
 left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
 left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
 left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
        (select max(revo.cdrevision)
         from dcdocrevision revo
         where revo.cddocument = revc.cddocument and revo.fgcurrent = case when (
                 (select distinct gnrevi.fgstatus
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 4 and
                 (select distinct gnrevi.fgstatus
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 5) then 1 else
                 case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument)
                 when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
        )
 left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
 inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (70,71,97)
 where 
 usr.fguserenabled = 1 and (
coalesce((select compa.iddepartment from addepartment compa inner join addepartment dep on compa.fgdepttype = 2 and dep.cddeptowner = compa.cddepartment and dep.cddepartment in (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') like '%0030%' or 
coalesce((select compa.iddepartment from addepartment compa inner join addepartment dep on compa.fgdepttype = 2 and dep.cddeptowner = compa.cddepartment and dep.cddepartment in (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') like '%0020%' or 
coalesce((select compa.iddepartment from addepartment compa inner join addepartment dep on compa.fgdepttype = 2 and dep.cddeptowner = compa.cddepartment and dep.cddepartment in (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') like '%0055%'
 )
union all
select usr.iduser, usr.idlogin, usr.nmuser, pos.nmposition, co.idcourse, 'N/A' as iddocument, 'N/A' as idrevision, 'N/A' as pop, tre.DTVALID as dtdoc
, (select iddepartment+'-'+nmdepartment  from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
, case when datediff(dd, DTVALID, getdate()) > 0 then 'Inapto' else 'Treinado' end as Situacao
, 1 as quantidade
 from aduser usr
 inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1
 inner join addepartment dep on dep.cddepartment = rel.cddepartment
 inner join adposition pos on pos.cdposition = rel.cdposition and pos.fgposenabled = 1
 inner join  trtrainuser treusr on treusr.cduser = usr.cduser
 inner join trtraining tre on tre.cdtrain = treusr.cdtrain
 inner join trcourse co on co.cdcourse = tre.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (97)
 where tre.FGTRAINVALID = 1
) __sub
 group by areapadrao, nmposition, idlogin, nmuser, iddocument, pop, situacao


---------------------
-- Descrição: Lista dos usuários cadastrados e seu sttus relacionado a treinamento de POPs
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 12/2020
-- Atualizada em: -
--------------------------------------------------------------------------------
select adc.iddepartment +' - '+ adc.nmdepartment as unidade, usr.idlogin, usr.nmuser
, case 
  when usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-197') 
  and usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-302')
  then 'Apto' else 'Inapto'
end status_INDE
, case 
  when usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-200') 
  then 'Apto' else 'Inapto'
end status_INEQ
, case 
  when usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-199') 
  and usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-295')
  then 'Apto' else 'Inapto'
end status_INCM
, case 
  when usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-089') 
  and usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-307')
  and usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-198')
  and usr.cduser in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-183')
  then 'Apto' else 'Inapto'
end status_INLAB
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join addepartment adc on adc.fgdepttype = 2 and adc.cddepartment = dep.cddeptowner
where usr.FGUSERENABLED = 1 and usr.nmdomainuid is not null

---------------------
-- Descrição: Lista dos usuários responsáves por alguma ação não encerrada porém inapto para tal execução
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 12/2020
-- Atualizada em: -
--------------------------------------------------------------------------------
select usr.idlogin, usr.nmuser, plano.idactivity as plano, act.idactivity as acao
from gnactivity act
inner join aduser usr on usr.cduser = act.cduser
inner join gnactivity plano on plano.cdgenactivity = act.cdactivityowner
INNER JOIN gntask gntk on act.cdgenactivity = gntk.cdgenactivity
inner join gnactionplan actpl on act.cdactivityowner = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
where act.fgstatus < 5 and act.CDACTIVITYOWNER is not null and gntype.idgentype = 'IN-DE'
and usr.cduser not in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-197') 
  and usr.cduser not in (select treusr.cduser
    from trtrainuser treusr
    inner join trtraining tre on tre.cdtrain = treusr.cdtrain
    inner join trcourse cou on cou.cdcourse = tre.cdcourse
    inner join DCDOCTRAIN tdoc on tre.cdtrain = tdoc.cdtrain
    inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision and rev.fgcurrent = 1
    where rev.iddocument = 'POP-IN-O-302')


---------------------
-- Descrição: Cubo Treinamento IN
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
 select nmuser, idlogin, nmposition as ROLE, situacao, areapadrao, pop
 from (
 select usr.iduser, usr.idlogin, usr.nmuser, pos.nmposition, co.idcourse, revc.iddocument, gnrevc.idrevision
 , coalesce(revc.iddocument, co.idcourse) as pop
 , case when gnrevc.DTREVISION is not null then gnrevc.DTREVISION else (select max(stag1.dtapproval)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                 stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3)) end as dtdoc
 , (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
 , case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
               from trtraining tr1
               inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
               left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
               where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
 				tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                         from TRTRAINING tr2
                                                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                         left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                         where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
        then 'Treinado'
        else case when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                 stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3))) <= 60 then 'Aguardando Treinamento – Homologação' else 'Aguardando Treinamento – Homologação (em atraso)' end end
 end Situacao
 , 1 as quantidade
 from aduser usr
 inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
 inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
 inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and (idposition like '%GRU-%')
 inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
 inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
 left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
 left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
 left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
        (select max(revo.cdrevision)
         from dcdocrevision revo
         where revo.cddocument = revc.cddocument and revo.fgcurrent = case when (
                 (select distinct gnrevi.fgstatus
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 4 and
                 (select distinct gnrevi.fgstatus
                 from dcdocrevision revi
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 5) then 1 else
                 case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument)
                 when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
        )
 left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
 inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (70,71,97)
 where usr.fguserenabled = 1 and coalesce((select compa.idcompanies from adcompanies compa inner join addepartment dep on dep.cdcompanies = compa.cdcompanies and cddepartment in (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') like '%0030%'
 ) __sub
 group by areapadrao, nmposition, idlogin, nmuser, iddocument, pop, situacao
 
 
---------------------
-- Descrição: Treinamentos - LISTATREINA
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2018
-- Atualizada em: -
--------------------------------------------------------------------------------
select nmuser, idlogin, nmposition, idposition, situacao, areapadrao, iddocument, idrevision, dtdoc
, setor, unid, count(quantidade) as quantidade
from (
select usr.iduser, usr.idlogin, usr.nmuser, pos.idposition, pos.nmposition, co.idcourse, revc.iddocument, gnrevc.idrevision
, coalesce(revc.iddocument, co.idcourse) as pop
, case when CHARINDEX('-', pos.idposition) <> 0 then SUBSTRING(pos.idposition, CHARINDEX('-', idposition)+1, 2) else '' end as setor
, case when CHARINDEX('-', pos.idposition) <> 0 then SUBSTRING(pos.idposition, 1, charindex('-', pos.idposition)-1) else '' end as unid
, case when gnrevc.DTREVISION is not null then gnrevc.DTREVISION else (select max(stag1.dtapproval)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3)) end as dtdoc
, (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
, case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
				tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Treinado'
       else case when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3))) <= 60 then 'Aguardando Treinamento – Homologação' else 'Aguardando Treinamento – Homologação (em atraso)' end end
end Situacao
, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and (pos.idposition like 'BR0050%')
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cddocument = revc.cddocument and revo.fgcurrent = case when (
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 4 and
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 5) then 1 else
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument)
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (37,38,46,62,70,71,97,111,114,105,107,109,112,138,146,147)
where usr.fguserenabled = 1 and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
from dcdocrevision revi
inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub
where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3))
) __sub
group by unid, setor, areapadrao, idposition, nmposition, idlogin, nmuser, iddocument, idrevision, situacao, dtdoc


---------------------
-- Descrição: Treinamento - LISTAUSRSETOR
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2018
-- Atualizada em: -
--------------------------------------------------------------------------------
select usr.idlogin, usr.nmuser, pos.idposition, pos.nmposition
, case when CHARINDEX('-', pos.idposition) <> 0 then SUBSTRING(pos.idposition, 8, 2) else '' end as setor
, case when CHARINDEX('-', pos.idposition) <> 0 then SUBSTRING(pos.idposition, 1, charindex('-', pos.idposition)-1) else '' end as unid
,1 as quantidade
from aduser usr
inner join aduserdeptpos rel on usr.cduser = rel.cduser and rel.FGDEFAULTDEPTPOS = 2 and rel.cddepartment = 164
inner join adposition pos on rel.cdposition = pos.cdposition and pos.fgposenabled = 1 and (pos.idposition like 'BR0050%')
where usr.fguserenabled = 1 and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
from dcdocrevision revi
inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub
where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3))

---------------------
-- Descrição: Treinamento - STATUSPOP
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2018
-- Atualizada em: -
--------------------------------------------------------------------------------
select distinct sum(quantidade) as qtdtot, sum(case when situacao = 'Treinado' then 1 else 0 end) as qtdok, sum(case when situacao = 'Pendente' then 1 else 0 end) as qtdpend, sum(case when situacao = 'Aguardando Treinamento – Homologação (em atraso)' then 1 else 0 end) as qtdathea, sum(case when situacao = 'Aguardando Treinamento – Homologação' then 1 else 0 end) as qtdath, sum(case when situacao = 'Aguardando Treinamento' then 1 else 0 end) as qtdat
, round(((Cast(sum(case when situacao = 'Pendente' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as ppend, round(((cast(sum(case when situacao = 'Treinado' then 1 else 0 end) AS NUMERIC(10,4))*100)/cast(sum(quantidade) AS NUMERIC(10,4))),2) as pok
, round(((Cast(sum(case when situacao = 'Aguardando Treinamento – Homologação (em atraso)' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as pathea, round(((Cast(sum(case when situacao = 'Aguardando Treinamento – Homologação' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as path
, round(((Cast(sum(case when situacao = 'Aguardando Treinamento' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as pat
, POP, situacao, unid
from (
select coalesce((select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') as areapadrao
, pos.idposition, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, 1, charindex('-',idposition)-1) else '' end as unid, revc.iddocument, gnrevc.idrevision, revc.iddocument +'-'+ gnrevc.idrevision as POP
, case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
				tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Treinado'
       else case when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3))) <= 60 then 'Aguardando Treinamento – Homologação' else 'Aguardando Treinamento – Homologação (em atraso)' end end
end Situacao
, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and (pos.idposition like 'BR0050%')
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cddocument = revc.cddocument and revo.fgcurrent = case when (
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 4 and
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 5) then 1 else
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument)
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (37,38,46,62,70,71,97,111,114,105,107,109,112,138,146,147)
where usr.fguserenabled = 1 and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
from dcdocrevision revi
inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub
where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3))
) _sub0
group by unid, POP, situacao
with rollup

---------------------
-- Descrição: Treinamento - STATUSSETOR
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2018
-- Atualizada em: -
--------------------------------------------------------------------------------
select distinct sum(quantidade) as qtdtot, sum(case when situacao = 'Treinado' then 1 else 0 end) as qtdok, sum(case when situacao = 'Pendente' then 1 else 0 end) as qtdpend, sum(case when situacao = 'Aguardando Treinamento – Homologação (em atraso)' then 1 else 0 end) as qtdathea, sum(case when situacao = 'Aguardando Treinamento – Homologação' then 1 else 0 end) as qtdath, sum(case when situacao = 'Aguardando Treinamento' then 1 else 0 end) as qtdat
, round(((Cast(sum(case when situacao = 'Pendente' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as ppend, round(((cast(sum(case when situacao = 'Treinado' then 1 else 0 end) AS NUMERIC(10,4))*100)/cast(sum(quantidade) AS NUMERIC(10,4))),2) as pok
, round(((Cast(sum(case when situacao = 'Aguardando Treinamento – Homologação (em atraso)' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as pathea, round(((Cast(sum(case when situacao = 'Aguardando Treinamento – Homologação' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as path
, round(((Cast(sum(case when situacao = 'Aguardando Treinamento' then 1 else 0 end) AS NUMERIC(10,4))*100)/Cast(sum(quantidade) AS NUMERIC(10,4))),2) as pat
, setor, situacao, unid
from (
select coalesce((select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') as areapadrao
, pos.idposition, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, 1, charindex('-',idposition)-1) else '' end as unid
, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, CHARINDEX('-', idposition)+1, 2) else '' end as setor
, case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
				tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Treinado'
       else case when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3))) <= 60 then 'Aguardando Treinamento – Homologação' else 'Aguardando Treinamento – Homologação (em atraso)' end end
end Situacao
, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and (pos.idposition like 'BR0050%')
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cddocument = revc.cddocument and revo.fgcurrent = case when (
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 4 and
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 5) then 1 else
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument)
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (37,38,46,62,70,71,97,111,114,105,107,109,112,138,146,147)
where usr.fguserenabled = 1 and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
from dcdocrevision revi
inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub
where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3))
) _sub0
group by unid, setor, situacao
with rollup


---------------------
-- Descrição: Treinamento - STATUSUSRROLEPOP
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2018
-- Atualizada em: -
--------------------------------------------------------------------------------
select usr.nmuser,usr.idlogin, coalesce((select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') as areapadrao
, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, CHARINDEX('-', idposition)+1, 2) else '' end as setor
, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, 1, charindex('-',idposition)-1) else '' end as unid
,idposition , revc.iddocument, gnrevc.idrevision, revc.iddocument +'-'+ gnrevc.idrevision as POP
, case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
				tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Treinado'
       else case when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and
                stag1.fgstage = 3 and nrcycle = (select max(stag1.nrcycle)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument) and stag1.fgstage = 3))) <= 60 then 'Aguardando Treinamento – Homologação' else 'Aguardando Treinamento – Homologação (em atraso)' end end
end Situacao
, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and (pos.idposition like 'BR0050%')
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cddocument = revc.cddocument and revo.fgcurrent = case when (
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 4 and
                (select distinct gnrevi.fgstatus
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revo.cddocument)) <> 5) then 1 else
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument)
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1 and co.cdcoursetype in (37,38,46,62,70,71,97,111,114,105,107,109,112,138,146,147)
where usr.fguserenabled = 1 and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
from dcdocrevision revi
inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub
where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3))


---------------------
-- Descrição: Lista de paticipantes de um Treinamento
-- 09
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2016
-- Atualizada em: -
--------------------------------------------------------------------------------
select rev.iddocument,gnrev.idrevision
, (select count(usr.nmuser) from dcdoctrain trd
inner join TRTRAINUSER tu on tu.cdtrain = trd.cdtrain
inner join aduser usr on usr.cduser = tu.cduser
where trd.cdrevision = rev.cdrevision) as treinadas
, (select count(rel.cduser) from DCDOCCOURSE docc
inner join GNCOURSEMAPITEM relc on docc.cdcourse = relc.cdcourse
inner join addeptposition deppos on relc.cdmapping = deppos.cdmapping
inner join aduserdeptpos rel on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment and FGDEFAULTDEPTPOS = 2
where docc.cddocument = rev.cddocument) as total
, case when (select count(rel.cduser) from DCDOCCOURSE docc
inner join GNCOURSEMAPITEM relc on docc.cdcourse = relc.cdcourse
inner join addeptposition deppos on relc.cdmapping = deppos.cdmapping
inner join aduserdeptpos rel on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment and FGDEFAULTDEPTPOS = 2
where docc.cddocument = rev.cddocument) = 0 then -1 else ((select count(usr.nmuser) from dcdoctrain trd
inner join TRTRAINUSER tu on tu.cdtrain = trd.cdtrain
inner join aduser usr on usr.cduser = tu.cduser
where trd.cdrevision = rev.cdrevision) * 100) / (select count(rel.cduser) from DCDOCCOURSE docc
inner join GNCOURSEMAPITEM relc on docc.cdcourse = relc.cdcourse
inner join addeptposition deppos on relc.cdmapping = deppos.cdmapping
inner join aduserdeptpos rel on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment and FGDEFAULTDEPTPOS = 2
where docc.cddocument = rev.cddocument) end as percentagem
, 1 as quantidade
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
where cddocument in (select dcou.cddocument from dcdoccourse dcou inner join trcourse trc on trc.cdcourse = dcou.cdcourse where trc.cdcoursetype in (36,37,38))
order by rev.IDDOCUMENT,gnrev.idrevision

---------------------
-- Descrição: Lista Documentos de cada ROLE atribuída ao "usuário" e se ele deve ser treinado (pendente).
--            Essa é a lista do público para um treinamento.
-- 01
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select revc.cdrevision,usr.nmuser, usr.iduser, pos.nmposition, co.idcourse, revc.iddocument
, case usr.fguserenabled when 1 then 'Ativo' when 2 then 'Inativo' end as usrstatus
, (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                              WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                         END tt
            from TRTRAINING tr2
            inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
			  inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
            where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
            from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
			inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
          )), 'Não avaliado') as Condicao
, case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
              , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
              from dcdocrevision rev1
              inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
              inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
              inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
              INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
              where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
              and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=revc.cddocument)
              group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1)
              <=
              (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
			    inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument)
             or
             (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
             and
              (coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                                           WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                                      END sit
                         from TRTRAINING tr2
                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
						 inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
                         where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
                         from TRTRAINING tr1
                         inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
						 inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
                         ) order by tr2.cdtrain desc), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
, gnrevc.DTREVISION
, (select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
   , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
   from dcdocrevision rev1
   inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
   inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
   inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
   inner JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
   where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
   and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=revc.cddocument)
   group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1) as data_primeira_aprovacao
, (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument) as data_treinamento
, (select count(posp.nmposition)
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and rel.FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
left join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 where cddocument=revc.cddocument and revi.fgcurrent = case when (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 inner join GNREVISIONSTAGMEM stag1 ON revi.CDREVISION = stag1.CDREVISION
                                 where cddocument=revc.cddocument and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
                                 and revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revi.cddocument)
                                ) is not null then 2 else 1 end)
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
inner join aduserdeptpos relp on relp.cduser = usr0.cduser and relp.FGDEFAULTDEPTPOS = 1
inner join addepartment depp on depp.cddepartment = relp.cddepartment
inner join adposition posp on posp.cdposition = relp.cdposition
where rel0.cdposition = rel.cdposition) as total
, (select count(__subapro.situacao) from (select case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
              , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
              from dcdocrevision rev1
              inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
              inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
              inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
              INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
              where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
              and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=revc.cddocument)
              group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1)
              <=
              (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
              inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument)
             or
             (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
              inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
             and
              (coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                                      WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                                 END sit
                         from TRTRAINING tr2
                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr0.cduser
                         inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
                         where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
                         from TRTRAINING tr1
                         inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
                         inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
                         ) order by tr2.cdtrain desc), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
inner join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 where cddocument=revc.cddocument and revi.fgcurrent = case when (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 inner join GNREVISIONSTAGMEM stag1 ON revi.CDREVISION = stag1.CDREVISION
                                 where cddocument=revc.cddocument and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
                                 and revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revi.cddocument)
                                ) is not null then 2 else 1 end)
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
where rel0.cdposition = rel.cdposition) __subapro where __subapro.situacao = 'Ok') as qtd_apro
, gnrevc.idrevision, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 where cddocument=revc.cddocument and revi.fgcurrent = case when (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 inner join GNREVISIONSTAGMEM stag1 ON revi.CDREVISION = stag1.CDREVISION
                                 where cddocument=revc.cddocument and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
                                 and revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revi.cddocument)
                                ) is not null then 2 else 1 end)
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
--where rel0.cdposition = 252 --usr.cduser = (select cduser from aduser where iduser = 'abeck' )
Order by situacao, pos.nmposition, co.idcourse

---------------------
-- Descrição: Lista de Usuários x Roles x Documentos.
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select usr.nmuser, usr.iduser, pos.nmposition, co.idcourse, revc.iddocument
, case usr.fguserenabled when 1 then 'Ativo' when 2 then 'Inativo' end as usrstatus
, (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and tr2.fgstatus = 8)
), 'Não avaliado') as condicao
, case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and 
														      tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
, gnrevc.DTREVISION
, (select tr1.dtrealfinish
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and 
														      tr2.fgstatus = 8)
) as data_treinamento
, (select count(posp.nmposition)
from aduser usr0
inner join aduserdeptpos rel0 on rel0.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in 
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cdrevision = revc.cdrevision and revo.fgcurrent = case when (
                select max(revi.cdrevision)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cddocument = revc.cddocument and gnrevi.fgstatus not in (4,5)
                ) is not null then 1 else 
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument) 
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1
inner join aduserdeptpos relp on relp.cduser = usr0.cduser and relp.FGDEFAULTDEPTPOS = 1
inner join addepartment depp on depp.cddepartment = relp.cddepartment
inner join adposition posp on posp.cdposition = relp.cdposition
where usr0.cduser = usr.cduser) as total
, (select count(__subapro.situacao) from (select case when (coalesce((select case when tu1.fgresult = 1 then 'Aprovado' when tu1.fgresult = 2 then 'Reprovado' end
              from trtraining tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
              left join DCDOCTRAIN trev1 on trev1.cdtrain = tr1.cdtrain
              where tr1.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev1.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev1.cdrevision is null)) and
                    tr1.fgstatus = 8 and tr1.cdtrain = (select max(tr2.cdtrain) as cdtrain
                                                        from TRTRAINING tr2
                                                        inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
                                                        left join DCDOCTRAIN trev2 on trev2.cdtrain = tr2.cdtrain
                                                        where tr2.cdcourse = co.cdcourse and ((revc.cdrevision is not null and trev2.cdrevision = revc.cdrevision) or (revc.cdrevision is null and trev2.cdrevision is null)) and 
														      tr2.fgstatus = 8)), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
from aduser usr0
inner join aduserdeptpos rel0 on rel0.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in 
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cdrevision = revc.cdrevision and revo.fgcurrent = case when (
                select max(revi.cdrevision)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cddocument = revc.cddocument and gnrevi.fgstatus not in (4,5)
                ) is not null then 1 else 
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument) 
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1
where usr0.cduser = usr.cduser) __subapro where __subapro.situacao = 'Ok') as qtd_apro
, gnrevc.idrevision, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel0 on rel0.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel0.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1
inner join addeptposition deppos on deppos.cdposition = rel0.cdposition and deppos.cddepartment = rel0.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument and doc.fgstatus <> 4
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in 
       (select max(revo.cdrevision)
        from dcdocrevision revo
        where revo.cdrevision = revc.cdrevision and revo.fgcurrent = case when (
                select max(revi.cdrevision)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cddocument = revc.cddocument and gnrevi.fgstatus not in (4,5)
                ) is not null then 1 else 
                case (select doco.fgstatus from dcdocument doco where doco.cddocument = revo.cddocument) 
                when 1 then 1 when 2 then 1 when 4 then 1 else 2 end end
       )
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
inner join trcourse co on co.cdcourse = relc.cdcourse and co.fgenabled = 1
--Where usr.fguserenabled=1
--Order by situacao, pos.nmposition, co.idcourse
---------------------
-- Descrição: Lista da capacitação do Colaborador - baseada nas ROLES
-- 08
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select revc.cdrevision, usr.nmuser, usr.iduser, pos.nmposition, co.idcourse, revc.iddocument
, (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)) as areapadrao
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, (select max(tr1.DTREALFINISH)
   from TRTRAINING tr1
   inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
   inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
  ) as dttreinamento
, coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                              WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                         END tt
            from TRTRAINING tr2
            inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
			inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
            where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
            from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
			inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
          )), 'Não avaliado') as Condicao
, (select top 1 tr2.idtrain tt
   from TRTRAINING tr2
   inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
   inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
   where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
   from TRTRAINING tr1
   inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
   inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
 )) as treinamento
, case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
              , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
              from dcdocrevision rev1
              inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
              inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
              inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
              INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
              where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
              and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=revc.cddocument)
              group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1)
              <=
              (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument)
             or
             (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
             and
              (coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                                           WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                                      END sit
                         from TRTRAINING tr2
                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
						 inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
                         where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
                         from TRTRAINING tr1
                         inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
						 inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
                         ) order by tr2.cdtrain desc), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
, gnrevc.DTREVISION
, (select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
   , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and rev1.fgcurrent = 1
            and rev1.cddocument = revc.cddocument and stag1.DTAPPROVAL is not null
            group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1) as data_primeira_aprovacao
, (select count(posp.nmposition)
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and rel.FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
left join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
inner join aduserdeptpos relp on relp.cduser = usr0.cduser and relp.FGDEFAULTDEPTPOS = 1
inner join addepartment depp on depp.cddepartment = relp.cddepartment
inner join adposition posp on posp.cdposition = relp.cdposition
where usr0.cduser = usr.cduser) as totalusr
, (select count(posp.nmposition)
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and rel.FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos0 on pos0.cdposition = rel.cdposition
left join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
inner join aduserdeptpos relp on relp.cduser = usr0.cduser and relp.FGDEFAULTDEPTPOS = 1
inner join addepartment depp on depp.cddepartment = relp.cddepartment
inner join adposition posp on posp.cdposition = relp.cdposition
where pos0.cdposition=pos.cdposition) as totalrole
, (select count(posp.nmposition)
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and rel.FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos0 on pos0.cdposition = rel.cdposition
left join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
inner join aduserdeptpos relp on relp.cduser = usr0.cduser and relp.FGDEFAULTDEPTPOS = 1
inner join addepartment depp on depp.cddepartment = relp.cddepartment
inner join adposition posp on posp.cdposition = relp.cdposition
where (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 1))
= (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1))) as totalareapad
, (select count(__subapro.situacao) from (select case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
              , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
              from dcdocrevision rev1
              inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
              inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
              inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
              INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
              where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
              and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=revc.cddocument)
              group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1)
              <=
              (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument)
             or
             (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
             and
              (coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                                      WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                                 END sit
                         from TRTRAINING tr2
                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr0.cduser
						 inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
                         where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
                         from TRTRAINING tr1
                         inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
						 inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
                         ) order by tr2.cdtrain desc), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
inner join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
where usr0.cduser = usr.cduser) __subapro where __subapro.situacao = 'Ok') as qtd_aprousr
, (select count(__subapro.situacao) from (select case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
              , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
              from dcdocrevision rev1
              inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
              inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
              inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
              INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
              where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
              and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=revc.cddocument)
              group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1)
              <=
              (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument)
             or
             (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
             and
              (coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                                      WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                                 END sit
                         from TRTRAINING tr2
                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr0.cduser
						 inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
                         where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
                         from TRTRAINING tr1
                         inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
						 inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
                         ) order by tr2.cdtrain desc), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos0 on pos0.cdposition = rel.cdposition
inner join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
where pos0.cdposition=pos.cdposition) __subapro where __subapro.situacao = 'Ok') as qtd_aprorole
, (select count(__subapro.situacao) from (select case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
              , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
              from dcdocrevision rev1
              inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
              inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
              inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
              INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
              where doc1.fgstatus < 4 and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
              and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=revc.cddocument)
              group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1)
              <=
              (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument)
             or
             (select max(tr1.DTREALFINISH)
              from TRTRAINING tr1
              inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
			  inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
             and
              (coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
                                      WHEN TU2.FGRESULT = 2 THEN 'Reprovado'
                                 END sit
                         from TRTRAINING tr2
                         inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr0.cduser
						 inner join DCDOCCOURSE docc2 on docc2.cdcourse = tr2.cdcourse and docc2.cddocument = revc.cddocument
                         where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
                         from TRTRAINING tr1
                         inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr0.cduser
						 inner join DCDOCCOURSE docc1 on docc1.cdcourse = tr1.cdcourse and docc1.cddocument = revc.cddocument
                         ) order by tr2.cdtrain desc), 'Não avaliado') = 'Aprovado')
       then 'Ok'
       else 'Pendente'
end Situacao
from aduser usr0
inner join aduserdeptpos rel on rel.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos0 on pos0.cdposition = rel.cdposition
inner join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
where (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr0.cduser and FGDEFAULTDEPTPOS = 1))
= (select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1))) __subapro where __subapro.situacao = 'Ok') as qtd_aproareapad
, gnrevc.idrevision, 1 as quantidade
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
left join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
--Where usr.cduser = XXX
Order by pos.nmposition, situacao, co.idcourse
--where usr.cduser in (select cduser from aduserdeptpos where cddepartment = (select cddepartment from addepartment where nmdepartment = 'Fabricação'))
---------------------
-- Descrição: Lista de ROLES x Cursos x Documentos
-- 07
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select pos.nmposition, co.idcourse
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, revc.iddocument, gnrevc.idrevision
, 1 as quantidade
from adposition pos
left join addeptposition deppos on deppos.cdposition = pos.cdposition and deppos.cddepartment in (164)
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join trcourse co on co.cdcourse = relc.cdcourse
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
where pos.cdposition in (select cdposition from aduserdeptpos where FGDEFAULTDEPTPOS = 2)
--and  co.idcourse is not null
order by NMPOSITION, idcourse
---------------------
-- Descrição: Lista de Treinamentos ainda não Verificados
-- 06
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select tr.idtrain, tr.nmtrain, tr.DTREALFINISH
1 as quantidade
from trtraining tr
where tr.fgstatus = 8 and tr.idtrain like 'TDS-TRE-%'
and tr.idtrain not in (select coalesce(nmstring,' ') from WFPROCATTRIB where cdattribute = 210)
---------------------
-- Descrição: Lista de paticipantes de um Treinamento
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select tr.idtrain, usr.nmuser, tr.DTREALFINISH, tr.fgstatus
from TRTRAINING tr
inner join TRTRAINUSER tu on tu.cdtrain = tr.cdtrain
inner join aduser usr on usr.cduser = tu.cduser
where tr.fgstatus > 1 --and tr.idcourse = ''
order by tr.idtrain, usr.nmuser
---------------------
-- Descrição: Lista de todos os Treinamentos que um usuário participou
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select tr.idtrain, co.idcourse, usr.nmuser, tr.DTREALFINISH
, CASE tu.FGRESULT WHEN 1 THEN 'Aprovado' WHEN 2 THEN 'Reprovado' END aprovacao
from TRTRAINING tr
inner join TRTRAINUSER tu on tu.cdtrain = tr.cdtrain
inner join aduser usr on usr.cduser = tu.cduser
inner join trcourse co on co.cdcourse = tr.cdcourse
where tr.fgstatus = 8 and usr.cduser=1548
order by tr.idtrain, tr.DTREALFINISH
--------------------------------------------------------------------------------------------
--
--
--
--
--
--------------------------------------------------------------------------------
select usr.nmuser, pos.nmposition, revc.iddocument
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, (
select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
) as dttreinamento
, coalesce((
select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
       WHEN TU2.FGRESULT = 2 THEN 'Reprovado' END tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)), 'Não avaliado') as Condicao
, (
select top 1 tr2.idtrain tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)) as treinamento
--, tr.IDTRAIN, tr.NMTRAIN, tu.cduser
--, revt.iddocument, co.idcourse
, case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, max(stag1.FGSTAGE) as fase, 
            max(stag1.NRCYCLE) as ciclo, max(stag1.DTAPPROVAL) as dtaprova
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            and rev1.fgcurrent = 1
            --and rev1.iddocument = 'TST000005'
            and rev1.cddocument = revc.cddocument
            and stag1.DTAPPROVAL is not null
            group by rev1.iddocument, rev1.cdrevision, rev1.fgcurrent, gnrev1.fgstatus) __sub1) <= (select max(tr1.DTREALFINISH)
             from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
            inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument)
            or
            (select max(tr1.DTREALFINISH)
             from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
            inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
            and
            (coalesce((
select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
       WHEN TU2.FGRESULT = 2 THEN 'Reprovado' END tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)), 'Não avaliado') = 'Aprovado')
            then 'Ok'
else 'Pendente'
end SSSSS
, gnrevc.DTREVISION
, (select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, max(stag1.FGSTAGE) as fase, 
            max(stag1.NRCYCLE) as ciclo, max(stag1.DTAPPROVAL) as dtaprova
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            and rev1.fgcurrent = 1
            --and rev1.iddocument = 'TST000005'
            and rev1.cddocument = revc.cddocument
            and stag1.DTAPPROVAL is not null
            group by rev1.iddocument, rev1.cdrevision, rev1.fgcurrent, gnrev1.fgstatus) __sub1) as data_aprova
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
--mapeamento
left join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
--treinamento
/*
left join TRTRAINUSER tu on tu.cduser = usr.cduser
left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
left join DCDOCTRAIN doct on doct.cdtrain = tr.cdtrain and doct.cdrevision = revc.cdrevision
left join dcdocrevision revt on revt.cdrevision = doct.cdrevision
*/
--TRUSERCOURSE
where usr.cduser = (select cduser from aduser where nmuser='Andre Luiz Andrade Miranda')
--co.idcourse='POP-TDS-G-006'
--order by tr.IDTRAIN
/*
select iddocument,cddocument,cdrevision from dcdocrevision where iddocument in ('POP-TDS-F-026', 'POP-TDS-A-002','POP-TDS-E-017','POP-TDS-D-021','POP-TDS-G-004')
27597         
 27705         
 27844         
 28119         
 31512         
 36496         
 28655

select DTREALFINISH,idtrain
from TRTRAINING tr
inner join TRTRAINUSER tu on tu.cduser = 926
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct on doct.cdtrain = tr.cdtrain and doct.cdrevision = 36496
inner join dcdocrevision revt on revt.cdrevision = doct.cdrevision


select usr.cduser
from aduser usr
inner join (select cduser, row_number() OVER(ORDER BY cduser desc) as rownr from aduser) _row on _row.cduser = usr.cduser
where _row.rownr = 1

*/


--========================================================================================
--Lista Usuário x Roles x Documentos x Requerido X Status (treinado no doc vigente?)
select usr.nmuser, pos.nmposition, revc.iddocument
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
--, tr.IDTRAIN, tr.NMTRAIN, tu.cduser
--, revt.iddocument, co.idcourse
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
--mapeamento
inner join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
inner join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
inner join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
inner join trcourse co on co.cdcourse = docc.cdcourse
--treinamento
/*
inner join TRTRAINUSER tu on tu.cduser = usr.cduser
inner join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct on doct.cdtrain = tr.cdtrain
inner join dcdocrevision revt on revt.cdrevision = doct.cdrevision
*/
--TRUSERCOURSE
--where co.idcourse='POP-TDS-G-006'
--order by tr.IDTRAIN


-- Dados dos documentos para treinamento
-- gnrev.fgstatus = 5 está em Liberação
select rev.iddocument, gnrev.fgstatus, rev.cdrevision, rev.fgcurrent, max(stag.FGSTAGE) as fase, max(stag.NRCYCLE) as ciclo, max(stag.DTAPPROVAL) as dtaprova
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION
where doc.fgstatus < 4 and stag.FGSTAGE = 3
and rev.fgcurrent = case when (doc.fgstatus = 3
                               and ((select max(fgstage) from GNREVISIONSTAGMEM 
                               where NRCYCLE = (select max(NRCYCLE) from GNREVISIONSTAGMEM where cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument))
                               and cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument) and DTDEADLINE is not null)
                              ) = 4) then 2 
                         when (doc.fgstatus = 1 
                               and ((select max(fgstage) from GNREVISIONSTAGMEM 
                               where NRCYCLE = (select max(NRCYCLE) from GNREVISIONSTAGMEM where cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument))
                               and cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument) and DTDEADLINE is not null)
                              ) < 4) then 0
                         else 1 end
and rev.iddocument = 'TST000005'
and stag.DTAPPROVAL is not null
group by rev.iddocument, rev.cdrevision, rev.fgcurrent, gnrev.fgstatus

--
SELECT T.IDTRAIN, T.NMTRAIN,
                    CASE WHEN TU.FGRESULT = 1 THEN 'Aprovado'
                         WHEN TU.FGRESULT = 2 THEN 'Reprovado' END AS FGRESULT,
                    C.NMCOURSE,
                    TCONF.IDCONFIGURATION,
                    USU.NMUSER,
                    USU.IDUSER,
                    T.DTVALID ,
                    T.DTREALSTART ,
                    T.DTREALFINISH,
                    CASE WHEN T.FGSTATUS = 1 THEN 'Planejamento'
                         WHEN T.FGSTATUS = 2 THEN 'Em aprovação'
                         WHEN T.FGSTATUS = 3 THEN 'Não aprovado'
                         WHEN T.FGSTATUS = 4 THEN 'Aprovado'
                         WHEN T.FGSTATUS = 5 THEN 'Em execução'
                         WHEN T.FGSTATUS = 6 THEN 'Pós-treinamento'
                         WHEN T.FGSTATUS = 7 THEN 'Verificação de eficácia'
                         WHEN T.FGSTATUS = 8 THEN 'Encerrado'
                         WHEN T.FGSTATUS = 9 THEN 'Cancelado' END AS FGSTATUS,
                    T.CDTRAIN
FROM TRCOURSE C,GNGENTYPE GN,TRTRAINUSER TU,ADUSER USU, TRCONFIGURATION TCONF , TRTRAINING T
WHERE T.CDCOURSE=C.CDCOURSE AND C.CDCOURSETYPE = GN.CDGENTYPE AND T.CDTRAIN=TU.CDTRAIN AND TU.CDUSER=USU.CDUSER 
AND T.CDCONFIGURATION = TCONF.CDCONFIGURATION
--AND T.FGSTATUS > 4
AND ((EXISTS (SELECT 1 FROM GNTYPEROLE GNROLE_ALIAS WHERE GNROLE_ALIAS.CDTYPEROLE = GN.CDTYPEROLE AND GNROLE_ALIAS.FGTYPE = 1))
    OR ( EXISTS (SELECT 1 FROM GNTYPEPERMISSION GNROLEDEF_ALIAS WHERE GNROLEDEF_ALIAS.CDTYPEROLE = GN.CDTYPEROLE AND GNROLEDEF_ALIAS.CDACCESSLIST = 1
--    AND GNROLEDEF_ALIAS.CDUSER = 1548 
	) OR NOT EXISTS(SELECT 1 FROM GNTYPEPERMISSION WHERE CDACCESSEDIT =1 AND CDACCESSLIST = 1
    AND CDTYPEROLE =GN.CDTYPEROLE)))
--AND UPPER(USU.NMUSER) LIKE UPPER('%alvaro adriano beck%')
--
WITH TMP AS
(
SELECT D.CDREVISION, D.CDUSER, CDMEMBERINDEX
FROM GNREVISIONSTAGMEM D
WHERE D.FGSTAGE = 1 AND D.CDUSER IS NOT NULL ORDER BY 1, 3
),
TMP1 AS
(
SELECT ROW_NUMBER() OVER (PARTITION BY CDREVISION ORDER BY CDMEMBERINDEX) AS RN, CDREVISION, CDUSER, CDMEMBERINDEX
FROM TMP
ORDER BY CDREVISION, CDMEMBERINDEX
)
 
-- Primeira Leitura da base de dados e geração do relatório contendo os movimentos do status “Effective”
 
SELECT   DISTINCT
         'Effective' AS TIPO,
         B.IDDOCUMENT AS SOMAU358,
         B.IDDOCUMENT AS TITLE,
         TRIM(TO_CHAR(C.IDREVISION,'9999999999')) || '.0' AS VERSION,
         'Effective' AS STATUS,
         TO_CHAR(C.DTREVISION,'DD/MM/YYYY') AS "DATE",
         B.NMTITLE AS DESCRIPTION,
         'http://brczwamiso01/se/document/dc_view_document/api_view_document.php?cdddocument=' || TRIM(TO_CHAR(A.CDDOCUMENT,'9999999999')) || '&nrrev=' || C.IDREVISION AS URL,
         CASE WHEN C.IDREVISION = 0
              THEN B.IDDOCUMENT || '_' || '0.0'
              ELSE B.IDDOCUMENT || '_' || TRIM(TO_CHAR(C.IDREVISION - 1,'9999999999')) || '.9' END AS PARENTID,
         (SELECT USR.NMUSER
          FROM ADUSER USR
          WHERE USR.CDUSER = (SELECT T.CDUSER
                              FROM TMP1 T
                              WHERE T.CDREVISION = C.CDREVISION AND RN = 1)) AS AUTHOR
 
FROM  DCDOCUMENT A
INNER JOIN DCDOCREVISION B ON A.CDDOCUMENT = B.CDDOCUMENT
INNER JOIN GNREVISION C ON C.CDREVISION = B.CDREVISION
INNER JOIN GNREVISIONSTAGMEM D ON C.CDREVISION = D.CDREVISION AND D.CDUSER IS NOT NULL
 
WHERE ((A.FGSTATUS = 3 AND C.FGSTATUS = 4) OR (A.FGSTATUS = 2 AND B.FGCURRENT = 1))
 
UNION
 
-- Segunda Leitura da base de dados e geração do relatório contendo os movimentos do  status “For Tranining” ou “Effective”
 
SELECT   DISTINCT
         'For Training' Tipo,
         B.IDDOCUMENT AS SOMAU358,
         B.IDDOCUMENT AS TITLE,
         CASE WHEN C.IDREVISION = 0
              THEN TRIM(TO_CHAR(C.IDREVISION,'9999999999')) || '.0'
              ELSE TRIM(TO_CHAR(C.IDREVISION - 1,'9999999999')) || '.9' END AS VERSION,
         CASE A.FGSTATUS
              WHEN 2 THEN 'Effective'
             WHEN 3 THEN 'For Training' END AS STATUS,
         TO_CHAR(C.DTREVISION,'DD/MM/YYYY') AS "DATE",
         B.NMTITLE AS DESCRIPTION,
         'http://brczwamiso01/se/document/dc_view_document/api_view_document.php?cdddocument=' || TRIM(TO_CHAR(A.CDDOCUMENT,'9999999999')) || '&nrrev=' || C.IDREVISION AS URL,
         CASE WHEN C.IDREVISION = 0
              THEN B.IDDOCUMENT || '_' || '0.0'
              ELSE B.IDDOCUMENT || '_' || TRIM(TO_CHAR(C.IDREVISION - 1,'9999999999')) || '.0' END AS PARENTID,
         (SELECT USR.NMUSER
          FROM ADUSER USR
          WHERE USR.CDUSER = (SELECT T.CDUSER
                              FROM TMP1 T
                              WHERE T.CDREVISION = C.CDREVISION AND RN = 1)) AS AUTHOR
 
FROM  DCDOCUMENT A
INNER JOIN DCDOCREVISION B ON A.CDDOCUMENT = B.CDDOCUMENT
INNER JOIN GNREVISION C ON C.CDREVISION = B.CDREVISION
INNER JOIN GNREVISIONSTAGMEM D ON C.CDREVISION = D.CDREVISION AND D.CDUSER IS NOT NULL
 
WHERE (A.FGSTATUS = 3 AND C.FGSTATUS = 4)
 
ORDER BY 1, 2


--=====================> Lista de treinamnetos com status para o usuário - Situação da capacitação relacioanda às ROLES
select usr.nmuser, pos.nmposition, revc.iddocument
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, (
select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
) as dttreinamento
, coalesce((
select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
       WHEN TU2.FGRESULT = 2 THEN 'Reprovado' END tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)), 'Não avaliado') as Condicao
, (
select top 1 tr2.idtrain tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)) as treinamento
--, tr.IDTRAIN, tr.NMTRAIN, tu.cduser
--, revt.iddocument, co.idcourse
, case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, max(stag1.FGSTAGE) as fase, 
            max(stag1.NRCYCLE) as ciclo, max(stag1.DTAPPROVAL) as dtaprova
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            and rev1.fgcurrent = 1
            --and rev1.iddocument = 'TST000005'
            and rev1.cddocument = revc.cddocument
            and stag1.DTAPPROVAL is not null
            group by rev1.iddocument, rev1.cdrevision, rev1.fgcurrent, gnrev1.fgstatus) __sub1) <= (select max(tr1.DTREALFINISH)
             from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
            inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument)
            or
            (select max(tr1.DTREALFINISH)
             from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
            inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
            and
            (coalesce((
select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
       WHEN TU2.FGRESULT = 2 THEN 'Reprovado' END tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)), 'Não avaliado') = 'Aprovado')
            then 'Ok'
else 'Pendente'
end SSSSS
, gnrevc.DTREVISION
, (select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, max(stag1.FGSTAGE) as fase, 
            max(stag1.NRCYCLE) as ciclo, max(stag1.DTAPPROVAL) as dtaprova
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            and rev1.fgcurrent = 1
            --and rev1.iddocument = 'TST000005'
            and rev1.cddocument = revc.cddocument
            and stag1.DTAPPROVAL is not null
            group by rev1.iddocument, rev1.cdrevision, rev1.fgcurrent, gnrev1.fgstatus) __sub1) as data_aprova
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
--mapeamento
left join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.fgcurrent = 1
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
--treinamento
/*
left join TRTRAINUSER tu on tu.cduser = usr.cduser
left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
left join DCDOCTRAIN doct on doct.cdtrain = tr.cdtrain and doct.cdrevision = revc.cdrevision
left join dcdocrevision revt on revt.cdrevision = doct.cdrevision
*/
--TRUSERCOURSE
where usr.cduser = (select cduser from aduser where nmuser='Andre Luiz Andrade Miranda')
--===================================================================================================
-- testes v1
select revc.cdrevision,usr.nmuser, pos.nmposition, revc.iddocument
, case relc.fgreq when 1 then 'Requerido' when 2 then 'Desejável' end as Requerido
, (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
) as dttreinamento
, coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
       WHEN TU2.FGRESULT = 2 THEN 'Reprovado' END tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)), 'Não avaliado') as Condicao
, (select top 1 tr2.idtrain tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)) as treinamento
--, tr.IDTRAIN, tr.NMTRAIN, tu.cduser
--, revt.iddocument, co.idcourse
, case when ((select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
            , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            --and rev1.iddocument = 'POP-TDS-D-021'
            and rev1.cddocument = revc.cddocument
            and stag1.DTAPPROVAL is not null
            and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=rev1.cddocument)
            group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1) <= (select max(tr1.DTREALFINISH)
             from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
            inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument)
            or
            (select max(tr1.DTREALFINISH)
             from TRTRAINING tr1
            inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
            inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument) >= gnrevc.DTREVISION)
            and
            (coalesce((select top 1 CASE WHEN TU2.FGRESULT = 1 THEN 'Aprovado'
       WHEN TU2.FGRESULT = 2 THEN 'Reprovado' END tt
from TRTRAINING tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr2.cdtrain and tu2.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct2 on doct2.cdtrain = tr2.cdtrain and doct2.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
where tr2.DTREALFINISH = (select max(tr1.DTREALFINISH)
from TRTRAINING tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain and tu1.cduser = usr.cduser
--left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
inner join DCDOCTRAIN doct1 on doct1.cdtrain = tr1.cdtrain and doct1.cddocument = revc.cddocument
--inner join dcdocrevision revt1 on revt1.cdrevision = doct1.cdrevision
)), 'Não avaliado') = 'Aprovado')
            then 'Ok'
else 'Pendente'
end SSSSS
, gnrevc.DTREVISION
, (select dtaprova from (select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
            , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            --and rev1.iddocument = 'POP-TDS-F-026'
            and rev1.cddocument = revc.cddocument
            and stag1.DTAPPROVAL is not null
            and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=rev1.cddocument)
            group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE) __sub1) as data_primeira_aprovacao
, gnrevc.idrevision
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment in (164)
inner join adposition pos on pos.cdposition = rel.cdposition
--mapeamento
inner join addeptposition deppos on deppos.cdposition = rel.cdposition and deppos.cddepartment = rel.cddepartment
left join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
left join DCDOCCOURSE docc on docc.cdcourse = relc.cdcourse
left join dcdocument doc on doc.cddocument = docc.cddocument
left join dcdocrevision revc on revc.cddocument = docc.cddocument and (revc.fgcurrent = case when (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 inner join GNREVISIONSTAGMEM stag1 ON revi.CDREVISION = stag1.CDREVISION
                                 where cddocument=revc.cddocument and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
                                 and revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revi.cddocument)
                                ) is not null then 2 else 1 end and (revc.cdrevision in
                                (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 inner join GNREVISIONSTAGMEM stag1 ON revi.CDREVISION = stag1.CDREVISION
                                 where cddocument=revc.cddocument and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
                                )))
/*
left join dcdocrevision revc on revc.cddocument = docc.cddocument and revc.cdrevision in
                                (select max(revi.cdrevision)
                                 from dcdocrevision revi
                                 inner join GNREVISIONSTAGMEM stag1 ON revi.CDREVISION = stag1.CDREVISION
                                 where cddocument=revc.cddocument and stag1.FGSTAGE = 3 and stag1.DTAPPROVAL is not null
                                )
*/
left join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
left join trcourse co on co.cdcourse = docc.cdcourse
--treinamento
/*
left join TRTRAINUSER tu on tu.cduser = usr.cduser
left join TRTRAINING tr on tr.cdtrain = tu.cdtrain
left join DCDOCTRAIN doct on doct.cdtrain = tr.cdtrain and doct.cdrevision = revc.cdrevision
left join dcdocrevision revt on revt.cdrevision = doct.cdrevision
*/
--TRUSERCOURSE
where usr.cduser = (select cduser from aduser where nmuser='Andre Luiz Andrade Miranda')
--------------------------
/*
select rev1.iddocument, gnrev1.fgstatus, rev1.cdrevision, rev1.fgcurrent, stag1.FGSTAGE as fase
            , min(stag1.NRCYCLE) as ciclo, min(stag1.DTAPPROVAL) as dtaprova, gnrev1.idrevision
            from dcdocrevision rev1
            inner join dccategory cat1 on cat1.cdcategory = rev1.cdcategory
            inner join gnrevision gnrev1 on gnrev1.cdrevision = rev1.cdrevision
            inner join dcdocument doc1 on rev1.cddocument = doc1.cddocument
            INNER JOIN GNREVISIONSTAGMEM stag1 ON gnrev1.CDREVISION = stag1.CDREVISION
            where doc1.fgstatus < 4 and stag1.FGSTAGE = 3
            and rev1.iddocument = 'POP-TDS-F-026'
            --and rev1.cddocument = revc.cddocument
            and stag1.DTAPPROVAL is not null
            and rev1.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument=rev1.cddocument)
            group by rev1.cdrevision, rev1.iddocument, rev1.fgcurrent, gnrev1.fgstatus, gnrev1.idrevision, stag1.FGSTAGE
*/
--select max(cdrevision) from dcdocrevision where iddocument='POP-TDS-F-026' -- 36506
--select * from GNREVISIONSTAGMEM where cdrevision in (36506,31512)