---------------------
-- Descrição: Lista dos projetos de TI com avanço físico (programas)
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 03/2021
-- Atualizada em: 
-- Fórmula do KPI:
--					100 * [% realizado do projeto] / case when ([% replanejado do projeto] = 0 or [% replanejado do projeto] is null) then [% planejado do projeto] else [% replanejado do projeto] end
--------------------------------------------------------------------------------
select P.NMIDTASK AS "Id. do projeto",P.NMTASK AS "Nome do projeto"
, case p.FGPHASE
    when 1 then 'Planejamento'
    when 2 then 'Execução'
    when 3 then 'Verificação'
    when 4 then 'Encerrado'
    when 5 then 'Aprovação'
    when 6 then 'Suspenso'
    when 7 then 'Cancelado'
end fase
, usr.nmuser as resp
, p.DTPLANST as "Início planejado", p.DTPLANEND as "Fim planejado"
, p.DTREPLST as "Início replan.", p.DTREPLEND	as "Fim replan."
, p.DTACTST as "Início real", p.DTACTEND as "Fim real"
, coalesce(p.QTACTPERC, 0) as "% realizado do projeto"
, case when p.QTACTPERC = 100 then 100
       when p.DTPLANST = p.DTPLANEND then 0
       else case when coalesce(cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                 when coalesce(cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                 else coalesce(cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100, 0) 
            end
  end as "% planejado do projeto"
, case when p.QTACTPERC = 100 then 100
       when p.DTREPLST = p.DTREPLEND then 0
       else case when coalesce(cast(datediff(dd, p.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTREPLST, p.DTREPLEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                 when coalesce(cast(datediff(dd, p.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTREPLST, p.DTREPLEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                 else coalesce(cast(datediff(dd, p.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTREPLST, p.DTREPLEND) as decimal(7,2)) * 100, 0)
            end
  end as "% replanejado do projeto"
, case when p.QTACTPERC = 100 then 1
       when p.DTPLANST = p.DTPLANEND then 0
       else case when coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) >= 100 then 100
                 when coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) <= 0 then 0
                 else coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100)
            end
  end as IDP
, prio.idPRIORITY as Prioridade
, 1 as qtd
, (select nmidtask from prtask where cdtask = prog.CDBASETASK) as programa
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
inner join prtask prog on prog.nmidtask = p.nmidtask and prog.fgtasktype = 5 and prog.cdtasktype = 4
where p.cdtasktype = 4 and P.FGTASKTYPE = 1 and P.NRTASKINDEX = 0 and prog.cdtask <> prog.cdbasetask

---------------------
-- Descrição: Avanço físico dos programas de TI e KPI
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 03/2021
-- Atualizada em: 
-- Fórmula do KPI:
--					100 * [porRealPrj] / case when ([porReplanPrj] = 0 or [porReplanPrj] is null) then [porPlanPrj] else [porReplanPrj] end
--------------------------------------------------------------------------------
select P.NMIDTASK AS "Id. do programa", P.NMTASK AS "Nome do programa"
, case p.FGPHASE
    when 1 then 'Planejamento'
    when 2 then 'Execução'
    when 3 then 'Verificação'
    when 4 then 'Encerrado'
    when 5 then 'Aprovação'
    when 6 then 'Suspenso'
    when 7 then 'Cancelado'
end fase
, usr.nmuser as resp
, p.DTPLANST as "Início planejado", p.DTPLANEND as "Fim planejado"
, p.DTREPLST as "Início replan.", p.DTREPLEND	as "Fim replan."
, p.DTACTST as "Início real", p.DTACTEND as "Fim real"
, case when (select cast(avg(case when proj.QTACTPERC = 100 then 100
                                  when proj.DTPLANST = proj.DTPLANEND then 0
                                  else case when coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                                            when coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                                            else coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0)
                                       end
                             end) as decimal(7,2)) as porPlan
             from prtask proj
             where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                   select NMIDTASK
                   from prtask proj1
                   where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask)) is not null
       then
             (select cast(avg(case when proj.QTACTPERC = 100 then 100
                                   when proj.DTPLANST = proj.DTPLANEND then 0
                                   else case when coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                                             when coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                                             else coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0)
                                        end
                              end) as decimal(7,2)) as porPlan
              from prtask proj
              where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                    select NMIDTASK
                    from prtask proj1
                    where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask))
       else
             (select cast(avg(case when proj.QTACTPERC = 100 then 100
                                   when proj.DTPLANST = proj.DTPLANEND then 0
                                   else case when coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                                             when coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                                             else coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0)
                                        end
                              end) as decimal(7,2)) as porPlan
              from prtask proj
              where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                    select NMIDTASK
                    from prtask proj1
                    where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask in (
                          select cdtask
                          from prtask proj2
                          where proj2.NRTASKINDEX = 0 and proj2.cdtask = proj2.cdbasetask and proj2.cdtasktype = 25 and proj2.fgtasktype = 5 and proj2.nmidtask in (
                                select nmidtask
                                from prtask proj3
                                where proj3.cdtask <> proj3.cdbasetask and proj3.cdtasktype = 25 and proj3.fgtasktype = 5 and proj3.cdbasetask = p.cdtask))))
  end as porPlanPrj
, case when (select cast(avg(case when proj.QTACTPERC = 100 then 100
                                  when proj.DTREPLST = proj.DTREPLEND then 0
                                  else case when coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                                            when coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                                            else coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0)
                                       end
                             end) as decimal(7,2)) as porReplan
             from prtask proj
             where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                   select NMIDTASK
                   from prtask proj1
                   where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask)) is not null
      then
            (select cast(avg(case when proj.QTACTPERC = 100 then 100
                                  when proj.DTREPLST = proj.DTREPLEND then 0
                                  else case when coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                                            when coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                                            else coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0)
                                       end
                             end) as decimal(7,2)) as porReplan
             from prtask proj
             where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                   select NMIDTASK
                   from prtask proj1
                   where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask))
      else
            (select cast(avg(case when proj.QTACTPERC = 100 then 100
                                  when proj.DTREPLST = proj.DTREPLEND then 0
                                  else case when coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0) >= 100 then 100
                                            when coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0) <= 0 then 0
                                            else coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0)
                                       end
                             end) as decimal(7,2)) as porReplan
             from prtask proj
             where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                   select NMIDTASK
                    from prtask proj1
                    where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask in (
                          select cdtask
                          from prtask proj2
                          where proj2.NRTASKINDEX = 0 and proj2.cdtask = proj2.cdbasetask and proj2.cdtasktype = 25 and proj2.fgtasktype = 5 and proj2.nmidtask in (
                                select nmidtask
                                from prtask proj3
                                where proj3.cdtask <> proj3.cdbasetask and proj3.cdtasktype = 25 and proj3.fgtasktype = 5 and proj3.cdbasetask = p.cdtask))))
  end as porReplanPrj
, 
--coalesce(p.QTACTPERC, 0) 
case when (select cast(avg(coalesce(proj.QTACTPERC, 0)) as decimal(7,2)) as porReal
             from prtask proj
             where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                   select NMIDTASK
                   from prtask proj1
                   where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask)) is not null
       then
             (select cast(avg(coalesce(proj.QTACTPERC, 0)) as decimal(7,2)) as porReal
              from prtask proj
              where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                    select NMIDTASK
                    from prtask proj1
                    where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask))
       else
             (select cast(avg(coalesce(proj.QTACTPERC, 0)) as decimal(7,2)) as porReal
              from prtask proj
              where proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.FGPHASE < 6 and proj.nmidtask in (
                    select NMIDTASK
                    from prtask proj1
                    where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask in (
                          select cdtask
                          from prtask proj2
                          where proj2.NRTASKINDEX = 0 and proj2.cdtask = proj2.cdbasetask and proj2.cdtasktype = 25 and proj2.fgtasktype = 5 and proj2.nmidtask in (
                                select nmidtask
                                from prtask proj3
                                where proj3.cdtask <> proj3.cdbasetask and proj3.cdtasktype = 25 and proj3.fgtasktype = 5 and proj3.cdbasetask = p.cdtask))))
  end as porRealPrj
, 1 as qtd
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
where p.cdtasktype = 25 and P.FGTASKTYPE = 5 and p.cdtask = p.cdbasetask

---------------------
-- Descrição: CUBO EXC_PRO-CONS Dados dos projetos de Excelência Operacional
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 03/2020
-- Atualizada em: 
-- 
--------------------------------------------------------------------------------
select P.NMIDTASK AS "Id. do projeto",P.NMTASK AS "Nome do projeto"
, case p.FGPHASE
    when 1 then 'Planejamento'
    when 2 then 'Execução'
    when 3 then 'Verificação'
    when 4 then 'Encerrado'
    when 5 then 'Aprovação'
    when 6 then 'Suspenso'
    when 7 then 'Cancelado'
end fase
, usr.nmuser as resp
, p.DTPLANST as "Início planejado", p.DTPLANEND as "Fim planejado"
, p.DTREPLST as "Início replan.", p.DTREPLEND	as "Fim replan."
, p.DTACTST as "Início real", p.DTACTEND as "Fim real"
, coalesce(p.QTACTPERC, 0) as "% realizado do projeto"
, case when p.QTACTPERC = 100 then 100
       when p.DTPLANST = p.DTPLANEND then 0
       else cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100
  end as "% planejado do projeto"
, case when p.QTACTPERC = 100 then 1
       when p.DTPLANST = p.DTPLANEND then 0
       else coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100)
  end as "IDP"
, prio.idPRIORITY
, case when p.DTPLANST = p.DTPLANEND then 'N/A'
       when ((cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) - p.QTACTPERC <= 0) then 'No prazo'
       else 'Atrasado'
  end statusprj
, substring(pty.idtasktype, 5, 45) as unidade
, (select vlvalue from prtaskattrib where cdattribute = 529 and cdtask = p.cdtask) as "CAPEX Aprovado"
, (select vlvalue from prtaskattrib where cdattribute = 530 and cdtask = p.cdtask) as "CAPEX Planejado"
, (select vlvalue from prtaskattrib where cdattribute = 531 and cdtask = p.cdtask) as "CAPEX Realizado"
, case when (select vlvalue from prtaskattrib where cdattribute = 529 and cdtask = p.cdtask) is null or
            (select vlvalue from prtaskattrib where cdattribute = 529 and cdtask = p.cdtask) = 0 then 0
       else (select vlvalue from prtaskattrib where cdattribute = 531 and cdtask = p.cdtask) / (select vlvalue from prtaskattrib where cdattribute = 529 and cdtask = p.cdtask)
  end "IDC"
, 1 as qtd
/*
, ati.NMIDTASK as "ID da Atividade"
, ati.NMTASK as "Nome da atividade", ati.DTPLANST as "Início planejado da atividade", ati.DTPLANST as "Fim planejado da atividade", usrati.nmuser, coalesce(ati.QTACTPERC, 0) as "% realizado da atividade"
, case when ati.QTACTPERC = 100 then 100
    else case when ((ati.DTPLANST > getdate() and ati.QTACTPERC is null) or p.DTPLANST = p.DTPLANEND) then 0
            else case when ati.DTPLANST <> ati.DTPLANEND then 
                      cast(datediff(dd, ati.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, ati.DTPLANST, ati.DTPLANEND) as decimal(7,2)) * 100
                   else cast(datediff(dd, ati.DTPLANST, getdate()) as decimal(7,2)) * 100
                 end
         end
  end as "% planejado da atividade"
*/
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
--left join PRTASK ATI on P.CDTASK = ATI.CDBASETASK and ati.NMIDTASK <> P.NMIDTASK
--left join aduser usrati on usrati.cduser = ati.CDTASKRESP
where P.FGTASKTYPE = 1 and P.NRTASKINDEX = 0
and p.cdtasktype in (select cdtasktype from prtasktype where CDTASKTYPEOWNER = 15)
--and P.NMIDTASK = 'PRO-CORP-0001/2020'


------- Backup --
select P.NMIDTASK AS "Id. do projeto",P.NMTASK AS "Nome do projeto"
, case p.FGPHASE
    when 1 then 'Planejamento'
    when 2 then 'Execução'
    when 3 then 'Verificação'
    when 4 then 'Encerrado'
    when 5 then 'Aprovação'
    when 6 then 'Suspenso'
    when 7 then 'Cancelado'
end fase
, usr.nmuser as resp
, p.DTPLANST as "Início planejado", p.DTPLANEND as "Fim planejado"
, p.DTREPLST as "Início replan.", p.DTREPLEND	as "Fim replan."
, p.DTACTST as "Início real", p.DTACTEND as "Fim real"
, coalesce(p.QTACTPERC, 0) as "% realizado do projeto"
, case when p.QTACTPERC = 100 then 100
    else cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100
  end as "% planejado do projeto"
, case when p.QTACTPERC = 100 then 1
    else coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100)
  end as "Status(IDP)"
, prio.idPRIORITY
, case when ((cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) - p.QTACTPERC <= 0) then 'No prazo'
       when ((cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) - p.QTACTPERC > 0 and
             (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) - p.QTACTPERC <= 10) then 'Atenção'
       else 'Atrasado'
  end statusprj
, 1 as qtd
, substring(pty.idtasktype, 5, 45) as unidade
, ati.NMIDTASK as "ID da Atividade"
, ati.NMTASK as "Nome da atividade", ati.DTPLANST as "Início planejado da atividade", ati.DTPLANST as "Fim planejado da atividade", usrati.nmuser, coalesce(ati.QTACTPERC, 0) as "% realizado da atividade"
, case when ati.QTACTPERC = 100 then 100
    else case when (ati.DTPLANST > getdate() and ati.QTACTPERC is null) then 0
            else case when ati.DTPLANST <> ati.DTPLANEND then 
                      cast(datediff(dd, ati.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, ati.DTPLANST, ati.DTPLANEND) as decimal(7,2)) * 100
                   else cast(datediff(dd, ati.DTPLANST, getdate()) as decimal(7,2)) * 100
                 end
         end
  end as "% planejado da atividade"
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
left join PRTASK ATI on P.CDTASK = ATI.CDBASETASK and ati.NMIDTASK <> P.NMIDTASK
left join aduser usrati on usrati.cduser = ati.CDTASKRESP
where P.FGTASKTYPE = 1 and P.NRTASKINDEX = 0
and p.cdtasktype in (select cdtasktype from prtasktype where CDTASKTYPEOWNER = 15)
