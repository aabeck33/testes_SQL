---------------------> DHO/RH
-- Descrição: Dados do processo
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 08/2022
-- Atualizada em: 
--------------------------------------------------------------------------------
select wf.idprocess, wf.nmprocess, wf.dtstart+wf.tmstart as dtinicio, wf.dtfinish+wf.tmfinish as dtfim, wf.nmuserstart
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS status
, (SELECT wfs.nmstruct FROM WFSTRUCT wfs WHERE wfs.fgstatus = 2 and wfs.idprocess=wf.idobject) as atvAtual
, case form.crp001
    when 1 then 'Requisição de pessoal'
    when 2 then 'Movimentação de Pessoal'
    when 3 then 'Alteração de Centro de Custo'
    when 4 then 'Desligamento'
end as tipo
, case form.crp001
    when 1 then 
        case form.crp063
            when 1 then 'Substituição sem Aumento de Salário'
            when 2 then 'Substituição com Aumento de salário'
            when 3 then 'Aumento de quadro'
            else 'N/A'
        end
    when 2 then
        case form.crp064
            when 1 then 'Aumento salarial'
            when 2 then 'Promoção'
            when 4 then 'Transferência ou Alteração de Cargo'
            else 'N/A'
        end
    else 'N/A'
end as acao
, case form.crp001
    when 1 then (select CRP001 from DYNtrcp01unid where oid = form.OIDABCXJCABC8V3)
    when 2 then
        case form.crp064
            when 1 then (select CRP001 from DYNtrcp01unid where oid = form.OIDABCAF9ABCOFJ)
            when 2 then (select CRP001 from DYNtrcp01unid where oid = form.OIDABCQTNABCWDT)
            when 4 then (select CRP001 from DYNtrcp01unid where oid = form.OIDABCQTNABCWDT)
            else 'N/A'
        end
    when 3 then (select CRP001 from DYNtrcp01unid where oid = form.OIDABCQTNABCWDT)
    when 4 then (select CRP001 from DYNtrcp01unid where oid = form.OIDABCEIDABCBSE)
end as unidade
, case form.crp001
    when 1 then (select CRP001 from DYNcrp01dir where oid = form.OIDABCUPU5NTKV2TKY)
    when 2 then case form.crp064
            when 1 then (select CRP001 from DYNcrp01dir where oid = form.OIDABCHY0V3JFCNPXB)
            when 2 then (select CRP001 from DYNcrp01dir where oid = form.OIDABCZV5YDZ2ORHTQ)
            when 4 then (select CRP001 from DYNcrp01dir where oid = form.OIDABCZV5YDZ2ORHTQ)
            else 'N/A'
        end
    when 3 then (select CRP001 from DYNcrp01dir where oid = form.OIDABCZV5YDZ2ORHTQ)
    when 4 then (select CRP001 from DYNcrp01dir where oid = form.OIDABCFJNV2LZCSNAT)
end as diretoria
, case form.crp001
    when 1 then form.CRP010
    when 2 then case form.crp064
            when 1 then form.CRP032
            when 2 then form.CRP037
            when 4 then form.CRP037
            else 'N/A'
        end
    when 3 then form.CRP037
    when 4 then form.CRP047
end as departamento
, case form.crp001
    when 1 then form.CRP009
    when 2 then case form.crp064
            when 1 then form.CRP055
            when 2 then form.CRP056
            when 4 then form.CRP056
            else 'N/A'
        end
    when 3 then form.CRP056
    when 4 then form.CRP046
end as cc_contabil
, case form.crp001
    when 1 then form.CRP012
    when 2 then case form.crp064
            when 1 then form.CRP031
            when 2 then form.CRP036
            when 4 then form.CRP036
            else 'N/A'
        end
    when 3 then form.CRP036
    when 4 then form.CRP058
end as cargo
, form.crp236 as escalona1
, form.crp237 as escalona2
, form.crp238 as escalona3
, case form.crp001
    when 1 then form.CRP120
    when 2 then form.CRP087
    when 3 then null
    when 4 then null
end as salario
, 1 as quant
from DYNrhcp1 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
where wf.cdprocessmodel = 86


---------------------> GMUD
-- Descrição: GMUD - Mudanças em andamento (similar ao itsm-20)
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2022
-- Atualizada em: 
--------------------------------------------------------------------------------
select distinct *
from (
select wf.idprocess, wf.nmprocess, form.itsm066 as gruposolucionador
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, case when (docs.iddocument is null and wf.fgstatus = 1) then 'Não iniciado'
	   when ((docs.iddocument like 'APL-DE-%' or docs.iddocument like 'SAP-DE-%') and wf.fgstatus = 1) then 'Em andamento'
		when (exists (select 1
                    FROM WFSTRUCT wfs, WFHISTORY HIS
                    WHERE wfs.idstruct = 'Atividade20111012624715' and wfs.idprocess = wf.idobject
                    and HIS.IDSTRUCT = wfs.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and his.nmaction = 'Submeter / Submit') and wf.fgstatus = 1) then 'Entregue'
       when wf.fgstatus = 2 then 'Suspenso'
       when wf.fgstatus = 3 then 'Cancelado'
       when wf.fgstatus = 4 then 'Finalizado'
end Status2
, form.itsm041, form.itsm048, form.itsm040
, docs.VLVALUE as chamado
, (select case when (charindex('#RESP#', his.dscomment) = 0 or his.dscomment is null) then null else substring(his.dscomment, charindex('#RESP#', his.dscomment) +6, charindex(char(10),(substring(his.dscomment, charindex('#RESP#', his.dscomment) +6, 250)))) end
from wfhistory his
where his.idprocess = wf.idobject and his.dthistory + his.tmhistory = (
select max(dthistory + tmhistory) from wfhistory where idprocess = wf.idobject and fgtype = 11 and (dscomment like '%#RESP#%'))
) as resp
, (select case when (charindex('#PEND#', his.dscomment) = 0 or his.dscomment is null) then null else substring(his.dscomment, charindex('#PEND#', his.dscomment) +6, charindex(char(10),(substring(his.dscomment, charindex('#PEND#', his.dscomment) +6, 250)))) end
from wfhistory his
where his.idprocess = wf.idobject and his.dthistory + his.tmhistory = (
select max(dthistory + tmhistory) from wfhistory where idprocess = wf.idobject and fgtype = 11 and (dscomment like '%#PEND#%'))
) as pend
, (select case when (charindex('#USAC#', his.dscomment) = 0 or his.dscomment is null) then null else substring(his.dscomment, charindex('#USAC#', his.dscomment) +6, charindex(char(10),(substring(his.dscomment, charindex('#USAC#', his.dscomment) +6, 250)))) end
from wfhistory his
where his.idprocess = wf.idobject and his.dthistory + his.tmhistory = (
select max(dthistory + tmhistory) from wfhistory where idprocess = wf.idobject and fgtype = 11 and (dscomment like '%#USAC#%'))
) as usracc
/*
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DC-%' or dr.iddocument like 'SAP-DC-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DC-%' or dr.iddocument like 'SAP-DC-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DC
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DP-%' or dr.iddocument like 'SAP-DP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DP-%' or dr.iddocument like 'SAP-DP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DP
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DE-%' or dr.iddocument like 'SAP-DE-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DE-%' or dr.iddocument like 'SAP-DE-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DE
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-EF-%' or dr.iddocument like 'SAP-EF-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-EF-%' or dr.iddocument like 'SAP-EF-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as EF
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-ET-%' or dr.iddocument like 'SAP-ET-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-ET-%' or dr.iddocument like 'SAP-ET-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as ET
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QO-%' or dr.iddocument like 'SAP-QO-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QO-%' or dr.iddocument like 'SAP-QO-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as QO
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QR-%' or dr.iddocument like 'SAP-QR-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QR-%' or dr.iddocument like 'SAP-QR-%')  and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as QR
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as RP
*/
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-DC-%' or dr.iddocument like 'SAP-DC-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as DC
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-DP-%' or dr.iddocument like 'SAP-DP-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as DP
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-DE-%' or dr.iddocument like 'SAP-DE-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as DE
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-EF-%' or dr.iddocument like 'SAP-EF-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as EF
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-ET-%' or dr.iddocument like 'SAP-ET-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as ET
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-QO-%' or dr.iddocument like 'SAP-QO-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as QO
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-QR-%' or dr.iddocument like 'SAP-QR-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as QR
, (select top 1 dr.iddocument +' / '+ case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end
+ case doc.fgstatus when 1 then +' - '+ stuff((select cast(';' as nvarchar(max)) + case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end +' - '+ format(stag.dtdeadline, 'dd/MM/yyyy', 'pt-BR') as [text()]
from GNREVISIONSTAGMEM stag where dr.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (
select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = dr.CDREVISION) and stag.FGAPPROVAL is null
FOR XML PATH('')), 1, 1, '') else '' end
from dcdocrevision dr
inner join dcdocument doc on doc.cddocument = dr.cddocument
inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235
where (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%') and atr.vlvalue = docs.vlvalue
order by dr.cdrevision desc) as RP
, case when (<!%IDLOGIN%> in (select usr.idlogin from aduser usr inner join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1 inner join addepartment dep on dep.cddepartment = rel.cddepartment and (dep.nmdepartment like 'Tecnologia da Informa%' or dep.nmdepartment like 'Information Tech%'))) then 1 else 2 end usrti
, form.itsm035 as GS
, wfs.idstruct, wfs.nmstruct, wf.dtfinish
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left join WFSTRUCT wfs on wfs.idprocess = wf.idobject and wfs.fgstatus = 2
--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
left join (
            select wfs.idprocess, rev.iddocument, att.VLVALUE, rev.cddocument, rev.cdrevision
            from wfstruct wfs
            inner join wfprocdocument wfdoc on wfdoc.idstruct = wfs.idobject
            inner join dcdocrevision rev on rev.cddocument = wfdoc.cddocument and (rev.cdrevision = wfdoc.cddocumentrevis or (wfdoc.cddocumentrevis is null and rev.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)))
            inner join dcdocumentattrib att on att.cdrevision = rev.cdrevision and att.cdattribute = 235 and att.cdrevision = rev.cdrevision
            where (rev.iddocument like 'APL-__-%' or rev.iddocument like 'SAP-__-%')
) docs on docs.idprocess = wf.idobject
where wf.cdprocessmodel = 5679 and form.itsm035 is not null and  (wf.dtfinish is null or datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()))
) sub
where status2 is not null


---------------------> ITSM-33
-- Descrição: Dados dos chamados da central de serviços
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 08/2022
-- Atualizada em: 
--------------------------------------------------------------------------------
select wf.idprocess, wf.nmprocess, usr.nmuser, usr.idlogin, wf.dtstart+wf.tmstart as dtinicio, wf.dtfinish+wf.tmfinish as dtfim
, (select case  when wfs.nmstruct = 'Atividade20131101317429' then 'N1'
                when wfs.nmstruct = 'Atividade20131102332506' then 'N2'
                when wfs.nmstruct = 'Atividade20131102646273' then 'N3'
                else 'N/A'
          end as N
    from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273') and wfs.DTEXECUTION+wfs.TMEXECUTION = (
        select max(wfs.DTEXECUTION+wfs.TMEXECUTION) from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273'))
) as atendN
, (select wfs.nmuser
    from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273') and wfs.DTEXECUTION+wfs.TMEXECUTION = (
        select max(wfs.DTEXECUTION+wfs.TMEXECUTION) from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273'))
) as atendAnalista
, (select case when wfs.fgstatus is not null then 'Sim' else 'Não' end from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.idstruct = 'Atividade20131101317429') as passouN1
, form.itsm066 + '_' + case when form.itsm088 is null then 'N1' else form.itsm088 end as gs_início
, form.itsm035 as gs_fim
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, form.itsm036 as unidserv
, form.itsm002 as objeto, form.itsm006 as servico
, case form.itsm058 
    when 1 then 'Solicitação' 
    when 2 then 'Incidente' 
    when 3 then 'Mudança' 
    when 4 then 'Projeto' 
    when 11 then 'Dúvida' 
    when 5 then 'Problema' 
    when 6 then 'Evento'
    else 'n/a'
end as tipofim
, form.itsm041 as paraQuem
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join aduser usr on usr.cduser = wf.cduserstart
where wf.cdprocessmodel = 5251


---------------------> ITSM-33
-- Descrição: Implementação do SE Suíte em PRD
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em: 06/2022
--------------------------------------------------------------------------------
select wf.idprocess,wf.nmprocess, formm.itsm028
, wf.dtstart + wf.tmstart as dtinicio, wf.dtfinish + wf.tmfinish as dtfim
, formm.ITSM027 as Real_Prd_Normal, formm.ITSM050 as DC_HOM, formm.ITSM003 as tec_resp
from wfprocess wf
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNitsm form on (gnf.oidentityreg = form.oid)
inner join gnassocformreg gnfm on (wf.cdassocreg = gnfm.cdassoc)
inner join DYNitsm015 formm on (gnfm.oidentityreg = formm.oid)
where cdprocessmodel = 5679-- and formm.itsm028 between '2022-03-01' and '2022-03-31'
and form.itsm056 = 'SESUITE'

---------------------> ITSM-34
-- Descrição: Dados dos serviços que não foram usados e dos que foram usados inlcui dados de SLA médio e quantiade de chamados.
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em: 06/2022
--------------------------------------------------------------------------------
select forms.itsm001, forms.itsm002p as objeto, forms.itsm003p as servico, forms.itsm004p as compl, forms.itsm021, forms.itsm006
, avg((QTSLATOTALTIMECAL - QTSLAPAUSETIMECAL + 60) / 3600) as worktime_horas
, case forms.itsm007
    when 1 then 'Solicitação'
    when 2 then 'Incidente'
    when 3 then 'Mudança'
    when 4 then 'Projeto'
    when 5 then 'Problema'
    when 6 then 'Evento'
end as tipo
, count(wf.idprocess) as qtchamados
from wfprocess wf
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNitsm form on (gnf.oidentityreg = form.oid)
inner join DYNitsm001 forms on forms.itsm001 = form.itsm006
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
where cdprocessmodel=5251 and wf.fgstatus = 4 and forms.itsm033 <> 1
group by forms.itsm001, forms.itsm002p, forms.itsm003p, forms.itsm004p, forms.itsm021, forms.itsm006, forms.itsm007
union all
select serv.itsm001, serv.itsm002p as objeto, serv.itsm003p as servico, serv.itsm004p as compl, serv.itsm021, serv.itsm006, null as worktime_horas
, case serv.itsm007
    when 1 then 'Solicitação'
    when 2 then 'Incidente'
    when 3 then 'Mudança'
    when 4 then 'Projeto'
    when 5 then 'Problema'
    when 6 then 'Evento'
end as tipo
, 0 as qtchamados
from DYNitsm001 serv
where not exists (select 1 from DYNitsm tick where tick.itsm006 = serv.itsm001)


---------------------> ITSM-32
-- Descrição: Atividades com usuários inativos
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em:
--------------------------------------------------------------------------------
select wf.idprocess, wfs.nmstruct, usr.nmuser
from wfprocess wf
inner join WFSTRUCT wfs on wfs.idprocess = wf.idobject and wfs.fgstatus = 2
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
inner join aduser usr on usr.cduser = wfa.cduser and fguserenabled = 2
where wf.cdprocessmodel in (5283, 5267, 5273, 5279,5251, 5470, 5692, 5679, 5716, 5756)
and wf.fgstatus < 4

---------------------> ITSM-31
-- Descrição: GOV-Incidentes de TI
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em:
--------------------------------------------------------------------------------
sselect wf.idprocess, wf.nmprocess, wf.dtstart+coalesce(wf.tmstart,cast(0 as datetime)) as inic, wf.dtfinish+coalesce(wf.tmfinish,cast(0 as datetime)) as fim, gnrev.NMREVISIONSTATUS as situac
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as gsb
, form.itsm002 as objeto, form.itsm003 as servico, form.itsm004 as complem, form.ITSM034 as descr
, restx.NMEVALRESULT as prioridade
, form.itsm048 as paraQuemPediuUnid, coalesce((select nmdepartment from addepartment where iddepartment = form.itsm040), form.itsm040) as paraQuemPediuDep
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left join GNEVALRESULTUSED res on res.CDEVALRESULTUSED = wf.CDEVALRSLTPRIORITY
left join GNEVALRESULT restx on restx.CDEVALRESULT = res.CDEVALRESULT
where wf.cdprocessmodel = 5251 and coalesce(form.itsm058, form.itsm044) = 2

---------------------> ITSM-28
-- Descrição: GOV-Desvios de TI
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em:
--------------------------------------------------------------------------------
select wf.idprocess, wf.nmprocess, wf.dtstart+coalesce(wf.tmstart,cast(0 as datetime)) as inic, wf.dtfinish+coalesce(wf.tmfinish,cast(0 as datetime)) as fim, gnrev.NMREVISIONSTATUS as situac
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, form.de008 as investigador, form.de007 as acoesim, form.de006 as descr
, 1 as quant
from DYNdesvti form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.cdprocessmodel = 5756

---------------------> ITSM-27
-- Descrição: GOV-Problemas
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em:
--------------------------------------------------------------------------------
select wf.idprocess, wf.nmprocess, wf.dtstart+coalesce(wf.tmstart,cast(0 as datetime)) as inic, wf.dtfinish+coalesce(wf.tmfinish,cast(0 as datetime)) as fim, gnrev.NMREVISIONSTATUS as situac
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, case when (coalesce(assoc.itsm035, form.itsm035) = '' or coalesce(assoc.itsm035, form.itsm035) is null) then 'N/A' else substring(coalesce(assoc.itsm035, form.itsm035), 1, coalesce(charindex('_', coalesce(assoc.itsm035, form.itsm035))-1, len(coalesce(assoc.itsm035, form.itsm035)))) end as gsb
, coalesce(assoc.itsm002, form.itsm002) as objeto, coalesce(assoc.itsm003, form.itsm003) as servico, coalesce(assoc.itsm004, form.itsm004) as complem , coalesce(assoc.ITSM034, form.ITSM034) as descr
, assoc.pai as refer
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left join (
            SELECT wff.idprocess as pai, p.idprocess, formf.*
            FROM gnassocworkflow bidirect 
            INNER JOIN gnassoc gnas ON bidirect.cdassoc = gnas.cdassoc AND gnas.nrobjectparent = 99207887
            LEFT OUTER JOIN gnactivity gnac ON gnas.cdassoc = gnac.cdassoc
            INNER JOIN wfprocess p ON p.cdgenactivity = gnac.cdgenactivity
            INNER JOIN inoccurrence incid ON p.idobject = incid.idworkflow
            INNER JOIN gngentype gnt ON incid.cdoccurrencetype = gnt.cdgentype
            LEFT OUTER JOIN gnrevisionstatus gnrs ON incid.cdstatus = gnrs.cdrevisionstatus
            left join wfprocess wff on wff.idobject = bidirect.idprocess and wff.cdprocessmodel in (5251,5692,5679,5716)
            inner join gnassocformreg gnff on (wff.cdassocreg = gnff.cdassoc)
            inner join DYNitsm formf on (gnff.oidentityreg = formf.oid)
            WHERE p.idobject IS NOT NULL AND p.cdprodautomation = 202 AND p.cdprodautomation IS NOT NULL
            and p.cdprocessmodel in (5251,5470,5692,5679,5716)
            and bidirect.cdassocworkflow = (select min(bidi.cdassocworkflow) from gnassocworkflow bidi where bidi.cdassoc = bidirect.cdassoc)
) assoc on assoc.idprocess = wf.idprocess
where wf.cdprocessmodel = 5470

---------------------> ITSM-30
-- Descrição: Gov-Mudnaças x RP
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em:
--------------------------------------------------------------------------------
select wf.idprocess, wf.nmprocess
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, docs.VLVALUE as chamado
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 
  where (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as RPattr
, (select top 1 dr.iddocument
FROM dcdocrevision dr 
INNER JOIN dcdocument dc ON dc.cddocument = dr.cddocument 
INNER JOIN gnrevision gr ON gr.cdrevision = dr.cdrevision 
INNER JOIN wfprocdocument wfdoc ON dr.cddocument = wfdoc.cddocument AND (dr.cdrevision = wfdoc.cddocumentrevis OR (wfdoc.cddocumentrevis IS NULL AND dr.fgcurrent = 1))
INNER JOIN wfstruct wfs ON wfdoc.idstruct = wfs.idobject 
where wfs.idprocess = wf.idobject and (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%')
order by dr.cdrevision desc
) as RPassoc
, wfs.idstruct, wfs.nmstruct, wf.dtfinish, wf.dtstart
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left join WFSTRUCT wfs on wfs.idprocess = wf.idobject and wfs.fgstatus = 2
left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
left join (
            select wfs.idprocess, rev.iddocument, att.VLVALUE, rev.cddocument, rev.cdrevision
            from wfstruct wfs
            inner join wfprocdocument wfdoc on wfdoc.idstruct = wfs.idobject
            inner join dcdocrevision rev on rev.cddocument = wfdoc.cddocument and (rev.cdrevision = wfdoc.cddocumentrevis or (wfdoc.cddocumentrevis is null and rev.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)))
            inner join dcdocumentattrib att on att.cdrevision = rev.cdrevision and att.cdattribute = 235 and att.cdrevision = rev.cdrevision
            where (rev.iddocument like 'APL-__-%' or rev.iddocument like 'SAP-__-%')
) docs on docs.idprocess = wf.idobject
where wf.cdprocessmodel = 5679 and form.itsm035 is not null

---------------------> ITSM-29
-- Descrição: Gov-Mudnaças-Quantitativos
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2022
-- Atualizada em:
--------------------------------------------------------------------------------
select wf.idprocess as ident
, case when formm.itsm026 = 1 then 'Emergencial'
       else case formm.itsm013
				when 1 then 'Normal'
				when 2 then 'Normal'
				when 3 then 'Simples'
				when 4 then 'Emergencial'
			end
end as tipo
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN case when gnrev.idREVISIONSTATUS = 'ITSM-11' then 'Cancelado' else 'Encerrado' end
    WHEN 5 THEN 'Bloqueado para edição'
END AS situac
, wf.dtstart + wf.tmstart as inic
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join gnassocformreg gnfm on (wf.cdassocreg = gnfm.cdassoc)
inner join DYNitsm015 formm on (gnfm.oidentityreg = formm.oid)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.cdprocessmodel = 5679

---------------------> ITSM-26
-- Descrição: Painel para valores de indicadores quantitativos (mudança)
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 12/2021
-- Atualizada em: 01/2022
--------------------------------------------------------------------------------
select wf.idprocess as ident, wf.nmprocess as titulo
, gnrev.NMREVISIONSTATUS as etapa, wf.dtstart, wf.dtfinish
, case when formm.itsm026 = 1 then 'Emergencial'
       else case formm.itsm013
				when 1 then 'Normal'
				when 2 then 'Normal'
				when 3 then 'Simples'
				when 4 then 'Emergencial'
			end
end as tipo
, case formm.itsm047
    when 1 then 'Melhoria'
    when 2 then 'Corretiva'
    else case when (formm.itsm013 = 2) then 'Corretiva' else 'N/A' end
end as classif
, case formm.itsm048
    when 0 then 'Não BPx'
    when 1 then 'BPx'
    else case when (formm.itsm048 is null) then 'N/A' end
end as bpx
, case formm.itsm014
    when 1 then 'Crítica'
    when 2 then 'Não crítica'
end as critic
, case formm.itsm010
    when 1 then 'Sucesso'
    when 2 then 'Insucesso'
end as sucess
, case formm.itsm004
    when 1 then 'Baixo'
    when 2 then 'Médio'
    when 3 then 'Alto'
end as impacto
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS tituac
, case formm.itsm009 
    when 0 then 'Sem Rollback'
    when 1 then 'Com Rollback'
end as rback
, formm.itsm027 as implentini, formm.itsm028 as implentfim
, form.itsm002 as servti
, form.itsm004 as servneg
, form.itsm003 as sintserv
, form.itsm034 as descr
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, formm.itsm003 as resptec, formm.itsm002 as lidermud
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join gnassocformreg gnfm on (wf.cdassocreg = gnfm.cdassoc)
inner join DYNitsm015 formm on (gnfm.oidentityreg = formm.oid)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
where wf.cdprocessmodel = 5679


---------------------> ITSM-24
-- Descrição: Painel para valores de indicadores quantitativos (mudança)
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 08/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess, wf.dtfinish+wf.tmfinish as dtfinish, wf.dtstart+wf.tmstart as dtstart
, form.itsm035 as GS, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, case
    when (formmud.itsm013 = 1 and (formmud.itsm026 = 0 or formmud.itsm026 is null)) then 'Normal'
    when (formmud.itsm013 = 2 and (formmud.itsm026 = 0 or formmud.itsm026 is null)) then 'Normal'
    when (formmud.itsm013 = 3 and (formmud.itsm026 = 0 or formmud.itsm026 is null)) then 'Simples'
    when (formmud.itsm013 = 4 or formmud.itsm026 = 1) then 'Emergencial'
end as tipo
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
inner join gnassocformreg gnfmud on (wf.cdassocreg = gnfmud.cdassoc)
inner join DYNitsm015 formmud on (gnfmud.oidentityreg = formmud.oid)
where wf.cdprocessmodel = 5679 and form.itsm035 is not null and wf.fgstatus in (1, 4)
--and (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) or (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) -1 and datepart(mm, wf.dtfinish) = 12))
and ((datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) or (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) -1 and datepart(mm, wf.dtfinish) = 12)) or (wf.dtfinish is null and (datepart(yyyy, wf.dtstart) = datepart(yyyy, getdate()) or (datepart(yyyy, wf.dtstart) = datepart(yyyy, getdate()) -1 and datepart(mm, wf.dtstart) = 12))))

---------------------> ITSM-23
-- Descrição: Painel para valores de indicadores quantitativos (chamados)
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 08/2021
-- Atualizada em: 06/2022
--------------------------------------------------------------------------------
select wf.idprocess, wf.dtfinish+wf.tmfinish as dtfinish, wf.dtstart+wf.tmstart as dtstart
, form.itsm035 as GS, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, case form.itsm058
    when 1 then 'Solicitação'
    when 11 then 'Solicitação'
    when 2 then 'Incidente'
    when 3 then 'Solicitação'
    when 4 then 'Solicitação'
    when 5 then 'Solicitação'
    when 6 then 'Incidente'
  end as tipofim
, (select wfs.idstruct from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273') and wfs.DTEXECUTION+wfs.TMEXECUTION = (
        select max(wfs.DTEXECUTION+wfs.TMEXECUTION) from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273'))
) as atendN
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
where wf.cdprocessmodel = 5251 and form.itsm035 is not null and wf.fgstatus in (1, 4)
--and (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) or (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) -1 and datepart(mm, wf.dtfinish) = 12))
and exists (select 1 from DYNitsm001 cat where cat.itsm001 = form.itsm006 and cat.itsm006 < 999)
and ((datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) or (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) -1 and datepart(mm, wf.dtfinish) = 12)) or (wf.dtfinish is null and (datepart(yyyy, wf.dtstart) = datepart(yyyy, getdate()) or (datepart(yyyy, wf.dtstart) = datepart(yyyy, getdate()) -1 and datepart(mm, wf.dtstart) = 12))))

---------------------> ITSM-22
-- Descrição: Painel para analistas com dados e listas dos chamados (deve havere uma atividade habilitada para entrar na lista)
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idobject, wf.idprocess, wf.nmprocess, form.itsm041 as solicitante
, usr.idlogin as iniciador, wfs.idstruct, wfs.nmstruct
, form.itsm035 as GS, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, coalesce(SLALC.QTRESOLUTIONTIME, 0) / 60 as sla
, case when wf.fgstatus = 1 then round(((select coalesce(sum(QTTIMECALENDAR), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)), 2)
       else ROUND(( gnslactrl.QTTIMEFRSTCAL + gnslactrl.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2)
end as slapercent
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, usr1.idlogin as exec_user
, gs.idrole as exec_gs
, case when (<!%IDLOGIN%> = adrusrgs.idlogin and wfs.idstruct = 'Atividade2041410270936') then 1 else 2 end comSol
, case when (<!%IDLOGIN%> = adrusr.idlogin) then 1 else 2 end meusgs
, 1 as quant_tot
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
inner JOIN GNSLACTRLHISTORY SLAH ON (gnslactrl.CDSLACONTROL = SLAH.CDSLACONTROL AND SLAH.FGCURRENT = 1) 
inner JOIN GNSLALEVEL SLALC ON (SLAH.CDLEVEL = SLALC.CDLEVEL)
inner join aduser usr on usr.cduser = wf.cduserstart
inner join WFSTRUCT wfs on wfs.idprocess = wf.idobject and wfs.fgstatus = 2
left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
left join aduser usr1 on usr1.cduser = wfa.cduser
left join adrole gs on gs.cdrole = wfa.cdrole
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
left join (select usr1.idlogin, adr.cdrole, adr.idrole from aduser usr1
           inner join aduserrole adru on adru.cduser = usr1.cduser
           inner join adrole adr on adr.cdrole = adru.cdrole
           where adr.cdroleowner = 1404 and usr1.idlogin = <!%IDLOGIN%>) adrusr on  (adrusr.cdrole = wfa.cdrole or (wfa.cdrole is null and adrusr.idrole = form.itsm035))
left join (select usr2.idlogin, adr.idrole from aduser usr2
           inner join aduserrole adru on adru.cduser = usr2.cduser
           inner join adrole adr on adr.cdrole = adru.cdrole
           where adr.cdroleowner = 1404 and usr2.idlogin = <!%IDLOGIN%>) adrusrgs on adrusrgs.idrole = form.itsm035
where wf.cdprocessmodel = 5251 and wf.fgstatus = 1 and form.itsm035 is not null


---------------------> ITSM-20
-- Descrição: Painel de controle de Mudanças
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2021
-- Atualizada em: -> próxima atualização verificar parte dos coordenadores para padronização.
--------------------------------------------------------------------------------
select distinct *
from (
select wf.idprocess, wf.nmprocess, form.itsm066 as gruposolucionador
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, case when (docs.iddocument is null and wf.fgstatus = 1) then 'Não iniciado'
	   when ((docs.iddocument like 'APL-DE-%' or docs.iddocument like 'SAP-DE-%') and wf.fgstatus = 1) then 'Em andamento'
		when (exists (select 1
                    FROM WFSTRUCT wfs, WFHISTORY HIS
                    WHERE wfs.idstruct = 'Atividade20111012624715' and wfs.idprocess = wf.idobject
                    and HIS.IDSTRUCT = wfs.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and his.nmaction = 'Submeter / Submit') and wf.fgstatus = 1) then 'Entregue'
       when wf.fgstatus = 2 then 'Suspenso'
       when wf.fgstatus = 3 then 'Cancelado'
       when wf.fgstatus = 4 then 'Finalizado'
end Status2
, form.itsm041, form.itsm048, form.itsm040
, docs.VLVALUE as chamado
, (select case when (charindex('#RESP#', his.dscomment) = 0 or his.dscomment is null) then null else substring(his.dscomment, charindex('#RESP#', his.dscomment) +6, charindex(char(10),(substring(his.dscomment, charindex('#RESP#', his.dscomment) +6, 250)))) end
from wfhistory his
where his.idprocess = wf.idobject and his.dthistory + his.tmhistory = (
select max(dthistory + tmhistory) from wfhistory where idprocess = wf.idobject and fgtype = 11 and (dscomment like '%#RESP#%'))
) as resp
, (select case when (charindex('#PEND#', his.dscomment) = 0 or his.dscomment is null) then null else substring(his.dscomment, charindex('#PEND#', his.dscomment) +6, charindex(char(10),(substring(his.dscomment, charindex('#PEND#', his.dscomment) +6, 250)))) end
from wfhistory his
where his.idprocess = wf.idobject and his.dthistory + his.tmhistory = (
select max(dthistory + tmhistory) from wfhistory where idprocess = wf.idobject and fgtype = 11 and (dscomment like '%#PEND#%'))
) as pend
, (select case when (charindex('#PRIO#', his.dscomment) = 0 or his.dscomment is null) then null else substring(his.dscomment, charindex('#PRIO#', his.dscomment) +6, charindex(char(10),(substring(his.dscomment, charindex('#PRIO#', his.dscomment) +6, 250)))) end
from wfhistory his
where his.idprocess = wf.idobject and his.dthistory + his.tmhistory = (
select max(dthistory + tmhistory) from wfhistory where idprocess = wf.idobject and fgtype = 11 and (dscomment like '%#PRIO#%'))
) as prio
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DC-%' or dr.iddocument like 'SAP-DC-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DC-%' or dr.iddocument like 'SAP-DC-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DC
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DP-%' or dr.iddocument like 'SAP-DP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DP-%' or dr.iddocument like 'SAP-DP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DP
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DE-%' or dr.iddocument like 'SAP-DE-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-DE-%' or dr.iddocument like 'SAP-DE-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DE
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-EF-%' or dr.iddocument like 'SAP-EF-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-EF-%' or dr.iddocument like 'SAP-EF-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as EF
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-ET-%' or dr.iddocument like 'SAP-ET-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-ET-%' or dr.iddocument like 'SAP-ET-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as ET
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QO-%' or dr.iddocument like 'SAP-QO-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QO-%' or dr.iddocument like 'SAP-QO-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as QO
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QR-%' or dr.iddocument like 'SAP-QR-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-QR-%' or dr.iddocument like 'SAP-QR-%')  and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as QR
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 where (dr.iddocument like 'APL-RP-%' or dr.iddocument like 'SAP-RP-%') and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as RP
, case when (<!%IDLOGIN%> = adrusr.idlogin) then 1 else 2 end meusgs
, case when (<!%IDLOGIN%> = adrcoord.coord) then 1 else 2 end eucoord, adrcoord.coord
, form.itsm035 as GS, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, wfs.idstruct, wfs.nmstruct, wf.dtfinish
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left join WFSTRUCT wfs on wfs.idprocess = wf.idobject and wfs.fgstatus = 2
left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
left join (
            select wfs.idprocess, rev.iddocument, att.VLVALUE, rev.cddocument, rev.cdrevision
            from wfstruct wfs
            inner join wfprocdocument wfdoc on wfdoc.idstruct = wfs.idobject
            inner join dcdocrevision rev on rev.cddocument = wfdoc.cddocument and (rev.cdrevision = wfdoc.cddocumentrevis or (wfdoc.cddocumentrevis is null and rev.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)))
            inner join dcdocumentattrib att on att.cdrevision = rev.cdrevision and att.cdattribute = 235 and att.cdrevision = rev.cdrevision
            where (rev.iddocument like 'APL-__-%' or rev.iddocument like 'SAP-__-%')
) docs on docs.idprocess = wf.idobject
left join (select usr1.idlogin, adr.cdrole, adr.idrole from aduser usr1
           inner join aduserrole adru on adru.cduser = usr1.cduser
           inner join adrole adr on adr.cdrole = adru.cdrole
           where adr.cdroleowner = 1404 and usr1.idlogin = <!%IDLOGIN%>) adrusr on  (adrusr.cdrole = wfa.cdrole or (wfa.cdrole is null and adrusr.idrole = form.itsm035))
left join (select usr1.idlogin, adr.cdrole, adr.idrole, coord.ITSM002 as coord from aduser usr1
           inner join aduserrole adru on adru.cduser = usr1.cduser
           inner join adrole adr on adr.cdrole = adru.cdrole
           inner join DYNitsm017 lgs on lgs.itsm001 = case when charindex('_', adr.idrole) < 1 then 'null' else left(adr.idrole, charindex('_', adr.idrole)-1) end
           inner join DYNitsm016 coord on lgs.OIDABCBSAGZNWY2N0Q = coord.oid
           where adr.cdroleowner = 1404 and coord.ITSM002 = <!%IDLOGIN%>) adrcoord on (adrcoord.cdrole = wfa.cdrole or (wfa.cdrole is null and adrcoord.idrole = form.itsm035))
--his.fgtype = 52 -- comentário editado
where wf.cdprocessmodel = 5679 and form.itsm035 is not null and (wf.dtfinish is null or datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()))  -- and wf.fgstatus <> 4
) sub
where status2 is not null --and gsb = 'sesuite'

---------------------> ITSM-19
-- Descrição: Painel de Governança
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess, wf.dtstart+wf.tmstart as dtabertura, wf.dtfinish+wf.tmfinish as dtencerramento, form.itsm006 as servicoID, form.itsm070 as categoria, form.itsm002 as objeto, form.itsm003 as servico, form.itsm004 as complemento
, form.itsm034 as descricao
, form.itsm066 as gruposolucionador
, case itsm058
    when 1 then 'Solicitação'
    when 2 then 'Incidente'
    when 3 then 'Mudança'
    when 4 then 'Projeto'
    when 5 then 'Problema'
    when 6 then 'Evento'
    when 11 then 'Dúvida'
end as tipo
, case when wf.fgstatus = 1 then case when round(((select coalesce(sum(QTTIMECALENDAR), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)), 2) < 100 then 'SLA_Ok' else 'SLA_NOk' end
       else case when ROUND (( gnslactrl.QTTIMEFRSTCAL + gnslactrl.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2) < 100 then 'SLA_Ok' else 'SLA_NOk' end 
end as sla
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS status
, round(((select coalesce(sum(QTTIMECALENDAR), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)), 2) as complexo
, SLALC.QTRESOLUTIONTIME as slap
, ROUND (( gnslactrl.QTTIMEFRSTCAL + gnslactrl.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2) as simples
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
left JOIN GNSLACTRLHISTORY SLAH ON (gnslactrl.CDSLACONTROL = SLAH.CDSLACONTROL AND SLAH.FGCURRENT = 1) 
left JOIN GNSLALEVEL SLALC ON (SLAH.CDLEVEL = SLALC.CDLEVEL)
where wf.cdprocessmodel = 5251 and wf.fgstatus < 6 and datepart(yyyy, wf.dtstart) = datepart(yyyy, getdate())


---------------------> ITSM-21
-- Descrição: Relação de usuários dos Grupos olucionadores
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select distinct adr.idrole, usr.idlogin, usr.nmuser, coord.itsm002 as idlogincoord, coord.itsm001 as nmusercoord
from aduser usr
inner join aduserrole adru on adru.cduser = usr.cduser
inner join adrole adr on adr.cdrole = adru.cdrole
inner join DYNitsm017 lgs on lgs.itsm001 = left(adr.idrole, charindex('_', adr.idrole)-1)
inner join DYNitsm016 coord on lgs.OIDABCBSAGZNWY2N0Q = coord.oid
where adr.cdroleowner = 1404


---------------------> ITSM-18
-- Descrição: Painel G5: Apontamneto de horas
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 05/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select (sum(coalesce(horas,0)) / qhm.horasMes) * 100 as indicador, sum(horas) as horas
, qhm.ano as anoap, qhm.mes as mesap, depset.depart, depset.setor, usr.nmuser as analista, qhm.horasMes
FROM aduser usr
left join aduser lider on lider.cduser = usr.cdleader
inner join DYNitsm016 resp on resp.itsm001 = usr.nmuser or resp.itsm001 = lider.nmuser
inner join (select oid, left(itsm001, charindex('_', itsm001) -1) as depart, right(itsm001, len(itsm001) - charindex('_', itsm001)) as setor from DYNitsm020) depset on depset.oid = resp.OIDABCKIK9UXB5HNKT
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.iddepartment like 'ti %'
inner join adposition pos on pos.cdposition = rel.cdposition and pos.nmposition <> 'Diretor' and pos.nmposition <> 'Gerente' and pos.nmposition <> 'Vice presidente'
inner join (select year(getdate()) as ano, num.itsm001 as mes, ((DATEDIFF(DAY, DATEFROMPARTS(YEAR(getdate()),num.itsm001,1), eomonth(datefromparts(year(getdate()),num.itsm001,1)))) - (DATEDIFF(WEEK, DATEFROMPARTS(YEAR(getdate()),num.itsm001,1), eomonth(datefromparts(year(getdate()),num.itsm001,1))) * 2) -
                CASE WHEN DATENAME(WEEKDAY, DATEFROMPARTS(YEAR(getdate()),num.itsm001,1)) = 'Sunday' THEN 1
                    ELSE 0
                END +
                CASE WHEN DATENAME(WEEKDAY, eomonth(datefromparts(year(getdate()),num.itsm001,1))) = 'Saturday' THEN 1
                    ELSE 0
                END) * 8 as horasMes
                from DYNitsm011 num
                where num.itsm001 <= month(getdate())
) qhm on 1 = 1
inner join (
SELECT TIMESHEETVIEW.DTACTUAL, TIMESHEETVIEW.NMRESOURCE, TIMESHEETVIEW.cduser
, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) AS QTTOTALMIN
, DATEADD(ms, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) % 1000, DATEADD(ss, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0))/1000, CONVERT(DATETIME2(3),'19700101'))) AS QTHORAS
, TIMESHEETVIEW.IDOBJECT AS OBJETO, TIMESHEETVIEW.NMACTIVITY AS ATIVIDADE
, TIMESHEETVIEW.CDISOSYSTEM, GTE.DSDESCRIPTION
, GTS.FGSTATUS
, cast((cast(Datepart(hh,(DATEADD(ms, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) % 1000, DATEADD(ss, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0))/1000, CONVERT(DATETIME2(3),'19700101')))))*3600 as float) + cast(Datepart(mi,(DATEADD(ms, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) % 1000, DATEADD(ss, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0))/1000, CONVERT(DATETIME2(3),'19700101')))))*60 as float)+ cast(Datepart(ss,(DATEADD(ms, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) % 1000, DATEADD(ss, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0))/1000, CONVERT(DATETIME2(3),'19700101'))))) as float)) / 3600 as float) as horas
FROM (
--Projeto
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, ATITYPE.IDTASKTYPE + ' - ' + ATITYPE.NMTASKTYPE AS IDTYPE, ATI.CDTASKTYPE AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, CASE ATI.FGCHARGE WHEN 1 THEN 1 ELSE 2 END AS CHARGE, ATI.CDTASK AS CDACTIVITY, ATI.NMIDTASK AS IDACTIVITY, ATB.CDTASK AS CDOBJECT, ATB.NMIDTASK AS IDOBJECT, ATB.NMTASK AS NMOBJECT, ATI.FGTASKTYPE AS FGACTIVITYTYPE, ATI.NMTASK AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNTIMESHEET TIMESHEET
INNER JOIN PRTASKTIMESHEET TASKTIME ON (TASKTIME.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN PRTASK ATI ON (ATI.CDTASK=TASKTIME.CDTASK)
LEFT OUTER JOIN PRTASKTYPE ATITYPE ON (ATI.CDTASKTYPE=ATITYPE.CDTASKTYPE)
INNER JOIN PRTASK ATB ON (ATI.CDBASETASK=ATB.CDTASK)
	LEFT JOIN (SELECT DISTINCT PVIEW.PR_CDTASK FROM (SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=1
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=2
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT AND UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=3
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, ACCVIEW.CDUSER FROM PRTASKACCESS ACCVIEW  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=4
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, TMM.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADTEAMUSER TMM ON TMM.CDTEAM=ACCVIEW.CDTEAM  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=5
	) PVIEW WHERE 1=1) PRTASKSECURITY ON PRTASKSECURITY.PR_CDTASK=ATB.CDBASETASK AND ATB.FGRESTRICT=1
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
WHERE ATI.FGTASKTYPE=1


UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY, ASEXECACT.CDEXECACTIVITY AS CDOBJECT, GNA.IDACTIVITY AS IDOBJECT, CASE WHEN ASEXECACT.CDPLANNING IS NULL THEN ASACT.IDACTIVITY + ' - ' + ASACT.NMACTIVITY ELSE ASPLANACT.IDPLANACTIVITY + ' - ' + ASPLANACT.NMPLANACTIVITY END AS NMOBJECT, CAST(8 AS NUMERIC(10)) AS FGACTIVITYTYPE, GNA.IDACTIVITY AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG)
INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY)
LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING)
INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY)
WHERE ASEXECACT.FGACTTYPE=1


UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY, ASEXECACT.CDEXECACTIVITY AS CDOBJECT, GNA.IDACTIVITY AS IDOBJECT, CASE WHEN ASEXECACT.CDPLANNING IS NULL THEN ASACT.IDACTIVITY + ' - ' + ASACT.NMACTIVITY ELSE ASPLANACT.IDPLANACTIVITY + ' - ' + ASPLANACT.NMPLANACTIVITY END AS NMOBJECT, CAST(9 AS NUMERIC(10)) AS FGACTIVITYTYPE, GNA.IDACTIVITY AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG)
INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY)
LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING)
INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY)
WHERE ASEXECACT.FGACTTYPE=3


UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY, ASEXECACT.CDEXECACTIVITY AS CDOBJECT, GNA.IDACTIVITY AS IDOBJECT, CASE WHEN ASEXECACT.CDPLANNING IS NULL THEN ASACT.IDACTIVITY + ' - ' + ASACT.NMACTIVITY ELSE ASPLANACT.IDPLANACTIVITY + ' - ' + ASPLANACT.NMPLANACTIVITY END AS NMOBJECT, CAST(10 AS NUMERIC(10)) AS FGACTIVITYTYPE, GNA.IDACTIVITY AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG)
INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY)
LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING)
INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY)
WHERE ASEXECACT.FGACTTYPE IN (2,6,7,8)

--Plano de ação
UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY, CASE WHEN GNACT2.CDGENACTIVITY IS NULL THEN GNA.CDGENACTIVITY ELSE GNACT2.CDGENACTIVITY END AS CDOBJECT, CASE WHEN GNACT2.IDACTIVITY IS NULL THEN GNA.IDACTIVITY ELSE GNACT2.IDACTIVITY END AS IDOBJECT, CASE WHEN GNACT2.NMACTIVITY IS NULL THEN GNA.NMACTIVITY ELSE GNACT2.NMACTIVITY END AS NMOBJECT, CASE WHEN GNA.CDACTIVITYOWNER IS NULL THEN 6 ELSE 7 END AS FGACTIVITYTYPE,GNA.NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNTASK GNTK ON (GNA.CDGENACTIVITY=GNTK.CDGENACTIVITY)
LEFT OUTER JOIN GNGENTYPE GNGNTP ON (GNGNTP.CDGENTYPE=GNTK.CDTASKTYPE)
LEFT OUTER JOIN GNACTIVITY GNACT2 ON (GNACT2.CDGENACTIVITY=GNA.CDACTIVITYOWNER)
LEFT OUTER JOIN GNACTIONPLAN GNACTPL ON (GNACTPL.CDGENACTIVITY=GNACT2.CDGENACTIVITY)
LEFT OUTER JOIN GNGENTYPE GNGNTP2 ON (GNGNTP2.CDGENTYPE=GNACTPL.CDACTIONPLANTYPE)
INNER JOIN ADUSER ADUS ON (GNA.CDUSER=ADUS.CDUSER)
WHERE 1 = 1

--Reunião
UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, GNGT.IDGENTYPE + ' - ' + GNGT.NMGENTYPE AS IDTYPE, GNM.CDMEETINGTYPE AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, GNM.CDMEETING AS CDACTIVITY, GNM.IDMEETING AS IDACTIVITY, GNM.CDMEETING AS CDOBJECT, GNM.IDMEETING AS IDOBJECT, GNM.NMMEETING AS NMOBJECT, 4 AS FGACTIVITYTYPE, GNM.NMMEETING AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNMEETINGTSHEET GMTS ON (GMTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNMEETING GNM ON (GNM.CDMEETING=GMTS.CDMEETING)
LEFT OUTER JOIN GNGENTYPE GNGT ON (GNM.CDMEETINGTYPE=GNGT.CDGENTYPE)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
WHERE 1 = 1

--Workflow
UNION ALL
SELECT GNTS.CDISOSYSTEM, GNTS.CDTIMESHEET, GNR.IDRESOURCE, GNR.NMRESOURCE, GNR.CDRESOURCE, '' AS IDTYPE, -1 AS TYPEDATA, 0 AS PLANEJADO, GNTS.DTACTUAL, GNTS.CDUSER, GNR.CDUSER AS RESOURCEUSER, GNTS.FGSTATUS, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN, 2 AS CHARGE, GNA.CDGENACTIVITY AS CDACTIVITY, WFS.IDSTRUCT AS IDACTIVITY, GNAWF.CDGENACTIVITY AS CDOBJECT, WFP.IDPROCESS AS IDOBJECT, WFP.NMPROCESS AS NMOBJECT, 11 AS FGACTIVITYTYPE, WFS.NMSTRUCT AS NMACTIVITY, WFP.IDOBJECT AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNACTIVITY GNA
INNER JOIN WFACTIVITY WFA ON (WFA.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN WFSTRUCT WFS ON (WFS.IDOBJECT=WFA.IDOBJECT)
INNER JOIN WFPROCESS WFP ON (WFP.IDOBJECT=WFS.IDPROCESS)
INNER JOIN GNACTIVITY GNAWF ON (GNAWF.CDGENACTIVITY=WFP.CDGENACTIVITY)
INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE)
INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP WHERE AUXWFP.FGSTATUS <= 5 AND (AUXWFP.FGMODELWFSECURITY IS NULL OR AUXWFP.FGMODELWFSECURITY=0) UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT
FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD
	FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE PP.FGACCESSTYPE=1
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PP.FGACCESSTYPE=2
UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION) WHERE PP.FGACCESSTYPE=3
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE PP.FGACCESSTYPE=4
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE PP.FGACCESSTYPE=5
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE PP.FGACCESSTYPE=6
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE PP.FGACCESSTYPE=7
) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE PP.FGACCESSTYPE=30
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PP.FGACCESSTYPE=31
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99
WHERE 1=1 GROUP BY PERM99.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT T.IDOBJECT FROM (SELECT PERM.IDOBJECT, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM1.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE PM.FGACCESSTYPE=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PM.FGACCESSTYPE=2
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=3
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=4
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM WHERE PM.FGACCESSTYPE=5
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM CROSS JOIN ADUSER US WHERE PM.FGACCESSTYPE=6
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE PM.FGACCESSTYPE=7
) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM2.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PMA.CDCREATEDBY AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE PM.FGACCESSTYPE=8
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE PM.FGACCESSTYPE=9
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION) WHERE PM.FGACCESSTYPE=10
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE PM.FGACCESSTYPE=11
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE PM.FGACCESSTYPE=12
) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PERM3.IDOBJECT, PMA.FGUSETYPEACCESS, PERM3.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, WFP.CDUSERSTART AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE PM.FGACCESSTYPE=30
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PM.FGACCESSTYPE=31
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND PMA.FGUSETYPEACCESS=1) PERM GROUP BY PERM.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN WFPROCSECURITYLIST WFLIST ON (AUXWFP.IDOBJECT=WFLIST.IDPROCESS) INNER JOIN WFPROCSECURITYCTRL WFCTRL ON (WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS) WHERE WFCTRL.CDACCESSROLEFIELD IN (501)
AND WFLIST.FGACCESSTYPE=5 AND WFLIST.FGACCESSEXCEPTION=1
AND AUXWFP.FGSTATUS <= 5) Z) MYPERM ON (WFP.IDOBJECT=MYPERM.IDOBJECT)
WHERE (WFP.CDPRODAUTOMATION IS NULL OR WFP.CDPRODAUTOMATION NOT IN (160, 202, 275))


UNION ALL
SELECT GNTS.CDISOSYSTEM, GNTS.CDTIMESHEET, GNR.IDRESOURCE, GNR.NMRESOURCE, GNR.CDRESOURCE, '' AS IDTYPE, -1 AS TYPEDATA, 0 AS PLANEJADO, GNTS.DTACTUAL, GNTS.CDUSER, GNR.CDUSER AS RESOURCEUSER, GNTS.FGSTATUS, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN, 2 AS CHARGE, GNA.CDGENACTIVITY AS CDACTIVITY, TSW.NMPREFIX + '-' + CAST(TST.NRTASK AS VARCHAR(255)) AS IDACTIVITY, TSW.CDWORKSPACE AS CDOBJECT, TSW.NMPREFIX AS IDOBJECT, TSW.NMWORKSPACE AS NMOBJECT, 14 AS FGACTIVITYTYPE, TST.NMTITLE AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, TST.CDTASK
FROM GNACTIVITY GNA
INNER JOIN WFPROCESS WFP ON (WFP.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN TSTASK TST ON (TST.IDOBJECT=WFP.IDOBJECT)
INNER JOIN TSWORKSPACE TSW ON (TSW.CDWORKSPACE=TST.CDWORKSPACE)
INNER JOIN TSFLOWSTEP TSFS ON (TSFS.CDFLOW=TST.CDFLOW AND TSFS.CDSTEP=TST.CDSTEP)
LEFT JOIN TSSPRINT TSS ON (TSS.CDSPRINT=TST.CDSPRINT AND TSS.CDWORKSPACE=TST.CDWORKSPACE)
INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE)
WHERE 1 = 1


UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, ATITYPE.IDTASKTYPE + ' - ' + ATITYPE.NMTASKTYPE AS IDTYPE, ATI.CDTASKTYPE AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, CASE ATI.FGCHARGE WHEN 1 THEN 1 ELSE 2 END AS CHARGE, ATI.CDTASK AS CDACTIVITY, ATI.NMIDTASK AS IDACTIVITY, ATI.CDTASK AS CDOBJECT, ATI.NMIDTASK AS IDOBJECT, ATI.NMTASK AS NMOBJECT, ATI.FGTASKTYPE AS FGACTIVITYTYPE, ATI.NMTASK AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK
FROM GNTIMESHEET TIMESHEET
INNER JOIN PRTASKTIMESHEET TASKTIME ON (TASKTIME.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN PRTASK ATI ON (ATI.CDTASK=TASKTIME.CDTASK)
LEFT JOIN (SELECT DISTINCT PVIEW.PR_CDTASK FROM (SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=1
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=2
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT AND UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=3
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, ACCVIEW.CDUSER FROM PRTASKACCESS ACCVIEW  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=4
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, TMM.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADTEAMUSER TMM ON TMM.CDTEAM=ACCVIEW.CDTEAM  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=5
) PVIEW WHERE 1=1) PRTASKSECURITY ON PRTASKSECURITY.PR_CDTASK=ATI.CDBASETASK AND ATI.FGRESTRICT=1 LEFT OUTER JOIN PRTASKTYPE ATITYPE ON (ATI.CDTASKTYPE=ATITYPE.CDTASKTYPE)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
WHERE ATI.FGTASKTYPE IN (2, 3) AND (( ATI.FGRESTRICT=2 OR ATI.FGRESTRICT IS NULL OR ATI.FGRESTRICT=0) OR (PRTASKSECURITY.PR_CDTASK IS NOT NULL))


)TIMESHEETVIEW, GNTIMESHEET GTS, GNTIMEENTRY GTE
WHERE TIMESHEETVIEW.CDTIMESHEET=GTS.CDTIMESHEET AND GTE.CDTIMESHEET=TIMESHEETVIEW.CDTIMESHEET


) timesheetcomp on timesheetcomp.cduser = usr.cduser and year(timesheetcomp.DTACTUAL) = qhm.ano and month(timesheetcomp.DTACTUAL) = qhm.mes
where usr.FGUSERENABLED = 1 --and usr.iduser = 'abeck'
group by qhm.ano, qhm.mes, depset.depart, depset.setor, usr.nmuser, qhm.horasMes
order by usr.nmuser

---------------------> ITSM-17
-- Descrição: Painel G4: Dados do Questionário (year to date)
--	  Campos: Chamado, Nota, data de encerramento do chamado, coordenador responsável, gerente, grupo solucionador
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
SELECT wf.idprocess, GNEXECUSR.VLNOTE
, wf.dtfinish
, form.itsm035 as GS, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, 1 as quant
FROM GNACTIVITY GNACT
INNER JOIN SVSURVEY SRV ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY)
INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=SRV.CDSURVEY)
INNER JOIN GNGENTYPE GNTP ON (GNSRV.CDSURVEYTYPE=GNTP.CDGENTYPE)
inner JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEYEXEC=SRV.CDSURVEYEXEC)
INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNSUREXEC.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC)
inner join WFSURVEYEXECPROC wfsur on wfsur.CDSURVEYEXECUSER = GNEXECUSR.CDSURVEYEXECUSER
inner join wfprocess wf on wf.idobject = wfsur.idobject
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNitsm form on (gnf.oidentityreg = form.oid)
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
WHERE wf.cdprocessmodel = 5251 and wf.fgstatus = 4 and vlnote is not null
and (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) or datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) - 1)

---------------------> ITSM-16
-- Descrição: Painel G5: Dados do SLA (year to date)
--	  Campos: Chamado, data de encerramento do chamado, coordenador responsável, gerente, grupo solucionador
--            Porcentagem do SLA, SLA, 1 se dentro do SLA
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess
, wf.dtfinish+tmfinish as dtfinish
, wf.dtstart+tmstart as dtstart
, ROUND (( gnslactrl.QTTIMEFRSTCAL + gnslactrl.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2) AS SLAPERCENT
, case when ROUND (( gnslactrl.QTTIMEFRSTCAL + gnslactrl.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2) < 100 then 1 else 0 end as slaok
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, form.itsm035 as GS, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, coalesce(SLALC.QTRESOLUTIONTIME, 0) / 60 as sla
, depset.depart, depset.setor
, case form.itsm058
    when 1 then 'Solicitação'
    when 11 then 'Solicitação'
    when 2 then 'Incidente'
    when 3 then 'Solicitação'
    when 4 then 'Solicitação'
    when 5 then 'Solicitação'
    when 6 then 'Incidente'
  end as tipofim
, (SELECT top 1 WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.idprocess = wf.idobject and str.idobject = wfa.idobject and (wfa.NMEXECUTEDACTION like '%Cancelar%' or wfa.NMEXECUTEDACTION like '%Encerrar%')
   and (str.idstruct = 'Atividade20131101317429' or str.idstruct = 'Atividade20131102332506' or 
   str.idstruct = 'Atividade20131102646273' or str.idstruct = 'Atividade2091512233371' or str.idstruct = 'Atividade201110173611852' or str.idstruct = 'Atividade2091512238643')
   and str.dtexecution+str.tmexecution = (SELECT max(str.dtexecution+str.tmexecution) FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.idprocess = wf.idobject and str.idobject = wfa.idobject and (wfa.NMEXECUTEDACTION like '%Cancelar%' or wfa.NMEXECUTEDACTION like '%Encerrar%')
   and (str.idstruct = 'Atividade20131101317429' or str.idstruct = 'Atividade20131102332506' or 
   str.idstruct = 'Atividade20131102646273' or str.idstruct = 'Atividade2091512233371' or str.idstruct = 'Atividade201110173611852' or str.idstruct = 'Atividade2091512238643'))
) as analista
, 1 as quant_tot
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
inner JOIN GNSLACTRLHISTORY SLAH ON (gnslactrl.CDSLACONTROL = SLAH.CDSLACONTROL AND SLAH.FGCURRENT = 1) 
inner JOIN GNSLALEVEL SLALC ON (SLAH.CDLEVEL = SLALC.CDLEVEL)
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
where wf.cdprocessmodel = 5251 and wf.fgstatus = 4 and form.itsm035 is not null
and (datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) or datepart(yyyy, wf.dtfinish) = datepart(yyyy, getdate()) - 1)

/*
, case when ((select coalesce(sum(qttime), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)) >= 100 then 100
       when ((select coalesce(sum(qttime), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)) is null then 0
  else round(((select coalesce(sum(qttime), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)), 2)
  end 
*/



---------------------> ITSM-01
-- Descrição: Lista de atividades ad-hoc com status e data de execução
--	  Campos: identificador do processo / nome da atividade pai / executor da atividade pai
--            nome da atividade ad-hoc / executor da atividade ad-hoc / status da atividade ad-hoc
--            data de execução da atividade ad-hoc
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wfp.idprocess, gnactowner.nmactivity as nmactowner, wfao.nmuser as exe_owner, gnact.nmactivity, wfa.nmuser as exe_adh
, case gnact.fgstatus
    when 3 then 'Em execução'
    when 5 then 'Finalizada'
    else 'Indefinido'
end status
, (select exeadhoc.dthistory + exeadhoc.tmhistory from (SELECT top 1 HIS.DTHISTORY, HIS.TMHISTORY
    FROM WFHISTORY HIS
    Where HIS.IDSTRUCT = wfs.IDOBJECT
    AND HIS.FGTYPE IN (9)
    ORDER BY HIS.DTHISTORY, HIS.TMHISTORY) exeadhoc) as dtexec
from wfactivity wfa
inner join WFSTRUCT wfs on wfs.idobject = wfa.IDOBJECT
inner join WFPROCESS wfp on wfp.idobject = wfs.idprocess
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
inner join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
inner join wfactivity wfao on gnactowner.cdgenactivity=wfao.cdgenactivity
inner join aduser usr on usr.cduser = wfao.cduser
where wfa.FGACTIVITYTYPE=3 and wfp.cdprocessmodel in (5251, 5470, 5692, 5679)

---------------------> ITSM-02
-- Descrição: Lista de processos e serviços configurados com aprovador adicional inativo
--	  Campos: identificador do processo ou serviço / nome do usuário que precisa ser substituído
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess as objeto, form.itsm022 as nmuser
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.cdprocessmodel in (5251, 5470, 5692, 5679) and wf.fgstatus = 1
and exists (select 1 from aduser usr where usr.idlogin = form.itsm023 and usr.fguserenabled = 2)
union all
select form.itsm001 as objeto, form.itsm020 as nmuser
from DYNitsm001 form
where exists (select 1 from aduser usr where usr.idlogin = form.itsm019 and usr.fguserenabled = 2)

---------------------> ITSM-03
-- Descrição: Lista de serviços e os POPs associados
--	  Campos: identificador do serviço / identificador do POP
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select form.itsm001 as servico, pop.itsm001 as pop
from DYNitsm001 form
left join DYNitsm005 pop on pop.OIDABCOF6I5OE0ST0Q = form.oid

---------------------> ITSM-04
-- Descrição: Lista de coordenadores desabilitados responsáveis por GS e GS sem Coordenador
--	  Campos: Coordenador, identificador do Grupo solucionador
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select coord.itsm001 as coord, coord.itsm002, gs.itsm001 as gs
from DYNitsm016 coord
inner join DYNitsm017 gs on gs.OIDABCBSAGZNWY2N0Q = coord.oid
where exists (select 1 from aduser usr where usr.idlogin = coord.itsm002 and usr.fguserenabled = 2)
union all
select distinct 'Vazio' as coord, '' as itsm002, substring(adr.idrole,1,charindex('_',adr.idrole)-1) as gs
from adrole adr
where adr.fgenabled = 1 and adr.cdroleowner = 1404
and substring(adr.idrole,1,charindex('_',adr.idrole)-1) not in (select gs.itsm001
from DYNitsm016 coord
inner join DYNitsm017 gs on gs.OIDABCBSAGZNWY2N0Q = coord.oid)

---------------------> ITSM-05
-- Descrição: Lista de Grupos solucionadores vazios ou apena com usuários inativos
--	  Campos: identificador do Grupo solucionador
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select adr.idrole
from adrole adr
where adr.fgenabled = 1 and adr.cdroleowner = 1404 and (
-- vazio
not exists (select 1 from aduserrole adru where adru.cdrole = adr.cdrole) or
--só inativos
(select count(*) from aduserrole adru inner join aduser usr on usr.cduser = adru.cduser and usr.fguserenabled = 2 where adru.cdrole = adr.cdrole) = 
(select count(*) from aduserrole adru where adru.cdrole = adr.cdrole)
)
---------------------> ITSM-07
-- Descrição: Lista de Processos/Objetos sem dono ou apena com usuários inativos como donos
--	  Campos: Processo/Objeto (identificador do Papel funcional)
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select adr.idrole
from adrole adr
where adr.fgenabled = 1 and adr.cdroleowner = 1430 and (
-- vazio
not exists (select 1 from aduserrole adru where adru.cdrole = adr.cdrole) or
--só inativos
(select count(*) from aduserrole adru inner join aduser usr on usr.cduser = adru.cduser and usr.fguserenabled = 2 where adru.cdrole = adr.cdrole) = 
(select count(*) from aduserrole adru where adru.cdrole = adr.cdrole)
)

---------------------> ITSM- Não cadastrado porque o usuário pode trocar o aprovador.
-- Descrição: Lista de Serviços com aprovador adiciponal e seu status
--	  Campos: Código do serviço, nome do usuário, login do usuário e status do usuário
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select form.itsm001, usr.nmuser, usr.idlogin
, case usr.FGUSERENABLED when 1 then 'Ativo' when 2 then 'Inativo' else '' end status
from DYNitsm001 form
inner join aduser usr on usr.idlogin = form.itsm019

---------------------> ITSM-06
-- Descrição: Lista de serviços duplicados **Não pode haver serviços duplicados**
--	  Campos: Item1, Item2 (duplicidade), objeto, serviço, complemento (em todos os idiomas)
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 03/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select form1.itsm001 as item1, form2.itsm001 as item2
, form1.itsm002p, form1.itsm003p, form1.itsm004p
, form1.itsm002e, form1.itsm003e, form1.itsm004e
from dynitsm001 form1
inner join dynitsm001 form2 on ((form2.itsm002p = form1.itsm002p and form2.itsm003p = form1.itsm003p and form2.itsm004p = form1.itsm004p) or
((form2.itsm002e = form1.itsm002e and form2.itsm003e = form1.itsm003e and form2.itsm004e = form1.itsm004e)))
and form1.oid <> form2.oid and substring(form2.itsm001, 9, 7) > substring(form1.itsm001, 9, 7)


---------------------> ITSM-08
-- Descrição: Lista de chamados e suas associações individuais
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
--Subprocessos
SELECT wf2.idprocess as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
from wfstruct wfs
inner join WFSUBPROCESS wfsub on wfsub.IDOBJECT = wfs.IDOBJECT
inner join wfprocess wf on wfs.idprocess = wf.idobject
inner join wfprocess wf2 on wf2.idobject = wfsub.IDSUBPROCESS
where wfsub.CDPROCESSMODEL in (5251, 5470, 5692, 5679,5716)
--Workflow
union all
SELECT wf.idprocess as filho, p.idprocess as pai, p.fgstatus, p.nmprocessmodel, p.nmprocess, p.nmuserstart, p.fgconcludedstatus
FROM gnassocworkflow bidirect 
INNER JOIN gnassoc gnas ON bidirect.cdassoc = gnas.cdassoc AND gnas.nrobjectparent IN ( 99207887 ) 
LEFT OUTER JOIN gnactivity gnac ON gnas.cdassoc = gnac.cdassoc 
INNER JOIN wfprocess p ON p.cdgenactivity = gnac.cdgenactivity 
INNER JOIN pmactivity pmact ON (pmact.cdactivity = p.cdprocessmodel) 
left join wfprocess wf on wf.idobject = bidirect.idprocess and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
WHERE p.idobject IS NOT NULL AND ( p.cdprodautomation NOT IN( 160, 202 ))
and p.cdprocessmodel in (5251,5470,5692,5679,5716)
--Problema
union all
SELECT wf.idprocess as filho, p.idprocess as pai, p.fgstatus, p.nmprocessmodel, p.nmprocess, p.nmuserstart, p.fgconcludedstatus
FROM gnassocworkflow bidirect 
INNER JOIN gnassoc gnas ON bidirect.cdassoc = gnas.cdassoc AND gnas.nrobjectparent IN ( 99207887 ) 
LEFT OUTER JOIN gnactivity gnac ON gnas.cdassoc = gnac.cdassoc 
INNER JOIN wfprocess p ON p.cdgenactivity = gnac.cdgenactivity 
INNER JOIN inoccurrence incid ON ( p.idobject = incid.idworkflow ) 
INNER JOIN gngentype gnt ON incid.cdoccurrencetype = gnt.cdgentype 
LEFT OUTER JOIN gnrevisionstatus gnrs ON ( incid.cdstatus = gnrs.cdrevisionstatus ) 
left join wfprocess wf on wf.idobject = bidirect.idprocess and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
WHERE p.idobject IS NOT NULL AND ( p.cdprodautomation IN( 202 ) AND p.cdprodautomation IS NOT NULL )
and p.cdprocessmodel in (5251,5470,5692,5679,5716)
--Incidente
union all
SELECT wf.idprocess as filho, p.idprocess as pai, p.fgstatus, p.nmprocessmodel, p.nmprocess, p.nmuserstart, p.fgconcludedstatus
FROM gnassocworkflow bidirect 
INNER JOIN gnassoc gnas ON bidirect.cdassoc = gnas.cdassoc AND gnas.nrobjectparent IN ( 99207887 ) 
LEFT OUTER JOIN gnactivity gnac ON gnas.cdassoc = gnac.cdassoc 
INNER JOIN wfprocess p ON p.cdgenactivity = gnac.cdgenactivity 
INNER JOIN inoccurrence incid ON ( p.idobject = incid.idworkflow ) 
INNER JOIN gngentype gnt ON incid.cdoccurrencetype = gnt.cdgentype 
LEFT OUTER JOIN gnrevisionstatus gnrs ON ( incid.cdstatus = gnrs.cdrevisionstatus ) 
left join wfprocess wf on wf.idobject = bidirect.idprocess and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
WHERE p.idobject IS NOT NULL AND ( p.cdprodautomation IN( 160 ) AND p.cdprodautomation IS NOT NULL )
and p.cdprocessmodel in (5251,5470,5692,5679,5716)
--Documento
union all
SELECT dr.iddocument +'/'+ gr.idrevision as filho, wfproc.idprocess as pai, wfproc.fgstatus, wfproc.nmprocessmodel, wfproc.nmprocess, wfproc.nmuserstart, wfproc.fgconcludedstatus
FROM dcdocrevision dr 
INNER JOIN dcdocument dc ON dc.cddocument = dr.cddocument 
INNER JOIN gnrevision gr ON gr.cdrevision = dr.cdrevision 
INNER JOIN wfprocdocument wfdoc ON dr.cddocument = wfdoc.cddocument AND (dr.cdrevision = wfdoc.cddocumentrevis OR (wfdoc.cddocumentrevis IS NULL AND dr.fgcurrent = 1)) 
INNER JOIN wfstruct wfs ON wfdoc.idstruct = wfs.idobject 
INNER JOIN wfprocess wfproc ON wfs.idprocess = wfproc.idobject 
WHERE  wfproc.cdprocessmodel in (5251,5470,5692,5679,5716)
--Plano de ação
union all
SELECT gnact.idactivity as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
FROM wfprocess wf
inner JOIN GNACTIVITY GNP ON (wf.CDGENACTIVITY = GNP.CDGENACTIVITY)
inner join gnassocactionplan stpl on stpl.cdassoc = GNP.CDASSOC
inner JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan 
INNER JOIN gntmcactionplan gntmc ON gntmc.cdgenactivity = stpl.cdactionplan 
INNER JOIN gnactivity gnact ON gntmc.cdgenactivity = gnact.cdgenactivity 
WHERE wf.cdprocessmodel in (5251,5470,5692,5679,5716)
--Ad-Hoc
union all
SELECT gnact.idactivity as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
from wfactivity wfa 
inner join WFSTRUCT wfs on wfs.idobject = wfa.IDOBJECT 
inner join WFPROCESS wf on wf.idobject = wfs.idprocess 
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity 
inner join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner 
where wfa.FGACTIVITYTYPE = 3 and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
--Ativos
union all
SELECT obj.idobject as filho, prc.idprocess as pai, prc.fgstatus, prc.nmprocessmodel, prc.nmprocess, prc.nmuserstart, prc.fgconcludedstatus
FROM gnassocasset sptb
inner JOIN obobject obj ON (obj.cdobject = sptb.cdasset AND obj.cdrevision = sptb.cdassetrevision)
inner join GNACTIVITY GNP ON gnp.cdassoc = sptb.cdassoc
inner join wfprocess prc on (PRC.CDGENACTIVITY = GNP.CDGENACTIVITY)
INNER JOIN asasset ass ON (ass.cdasset = obj.cdobject AND ass.cdrevision = obj.cdrevision) 
INNER JOIN gnassoc gnas ON gnp.cdassoc = gnas.cdassoc AND gnas.nrobjectparent IN ( 99207887 )
LEFT OUTER JOIN gnrevision gn ON (gn.cdassoc = gnas.cdassoc)
where prc.cdprocessmodel in (5251,5470,5692,5679,5716)
--Projeto
union all
SELECT ab.nmidtask as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
FROM   prtasktype prtt,addepartment depart,prpriority priori,prtask ab,
       prtaskwfprocess
       prwf
inner join wfprocess wf on wf.idobject = prwf.idprocess
WHERE  ab.fgtasktype = 1
       AND prtt.cdtasktype = ab.cdtasktype
       AND depart.cddepartment = ab.cdtaskdept
       AND priori.cdpriority = ab.cdpriority
       AND ab.cdbasetask = ab.cdtask
       AND ab.cdtask = prwf.cdtask
and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
--Atividade de projeto
union all
SELECT ab.nmidtask +'/'+ ati.nmidtask as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
FROM   prtask ati,prtask ab,prtaskwfprocess prwf 
inner join wfprocess wf on wf.idobject = prwf.idprocess
WHERE  ati.cdtask = ab.cdtask 
       AND ati.fgtasktype = 3 
       AND ab.cdbasetask = ab.cdtask 
       AND ati.cdtask = prwf.cdtask 
and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
  UNION all
SELECT ab.nmidtask +'/'+ ati.nmidtask as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
FROM   prtask ati,prtask ab,prtaskwfprocess prwf
inner join wfprocess wf on wf.idobject = prwf.idprocess
WHERE  ati.fgtasktype = 1 
       AND ati.cdbasetask <> ati.cdtask 
       AND ati.cdbasetask = ab.cdtask 
       AND ati.cdtask = prwf.cdtask 
and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
--Anexos
union all
SELECT adattch.nmattachment as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
FROM  wfprocattachment wfp, adattachment adattch, wfprocess wf
WHERE adattch.cdattachment = wfp.cdattachment and wf.idobject = wfp.idprocess
and wf.cdprocessmodel in (5251,5470,5692,5679,5716)
AND wfp.cduser IS NOT NULL
--Análises e suas causas
union all
SELECT gna.idanalisys +'/'+ pb.nmcause as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
FROM gnstruct gns 
LEFT OUTER JOIN addepartment ada ON gns.cddeptrespcause = ada.cddepartment 
LEFT OUTER JOIN gnanalisys gna ON gna.cdanalisys = gns.cdanalisys 
INNER JOIN pbstructcause pb ON gns.cdstruct = pb.cdstruct 
LEFT OUTER JOIN obcause ob ON ob.cdcause = pb.cdcause 
inner join pbproblem pbp on (gns.cdtoolanalysis = pbp.CDTOOLSANALISYS)
INNER JOIN INOCCURRENCE INC ON (inc.cdoccurrence = pbp.cdoccurrence)
inner join wfprocess wf on (wf.IDOBJECT = INC.IDWORKFLOW)
WHERE wf.cdprocessmodel in (5251,5470,5692,5679,5716)
--Checklists
union all
SELECT wfs.idstruct as filho, wf.idprocess as pai, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
from WFSTRUCT wfs
inner join WFPROCESS wf on wf.idobject = wfs.idprocess
where wf.cdprocessmodel in (5251,5470,5692,5679,5716) and wfs.IDOBJECT in ( 
		select wfs.IDOBJECT 
		from WFSTRUCT wfs, WFACTIVITY wfa, WFACTCHECKLIST wfc, WFPROCESS wfp
		where wfs.IDOBJECT = wfa.IDOBJECT and wfs.IDOBJECT = wfc.IDACTIVITY and wfp.idobject = wfs.idprocess
		and wfp.cdprocessmodel in (5251,5470,5692,5679,5716)
)

---------------------> ITSM-09
-- Descrição: Quantidade de vezes que cada chamado foi enviado para Pausa ou para Fornecedor,
--            quantas vezes ele retornou do solicitante e quantas vezes ele foi reativado pelo gestor
--			  o total de encerrados, outros stastus agrupado, se o chamado voltou mesmo ou o coord encerrou
--			  e se encerrou automaticamente.
--	  
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess
, (select count(HIS.IDSTRUCT)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE str.idstruct = 'Atividade204915466137' and str.idprocess = wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 6) as ciclosfornec
, (select count(HIS.IDSTRUCT)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE str.idstruct = 'Atividade2049154312401' and str.idprocess = wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and his.nmaction = 'Retornar o chamado para o Analista') as ciclosretorno
, (select count(HIS.IDSTRUCT)
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE str.idstruct = 'Timer4' and str.idprocess = wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 14) as ciclospausa
, (select count(HIS.IDSTRUCT)
FROM WFHISTORY HIS
WHERE his.idprocess = wf.idobject and HIS.FGTYPE = 5) as reativacoes
, case when exists (select 1
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE str.idstruct = 'Atividade2049154312401' and str.idprocess = wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and his.nmaction = 'Automático') then 1 else 0 end as fimauto
, case when exists (select 1
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE str.idstruct = 'Decisão21127163635189' and str.idprocess = wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and his.nmaction = 'Encerrar') then 1 else 0 end as naoretornou
, case when wf.fgstatus < 4 then 1 else 0 end as outrostatus
, case wf.fgstatus when 4 then 1 else 0 end as encerrados
, 1 as total
from wfprocess wf
where wf.cdprocessmodel in (5251,5470,5692,5679,5716)


---------------------> ITSM-13
-- Descrição: Lista dos Grupos solucionadores, seus menbros e coordenadores responsáveis.
--	  
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select adr.idrole, adr.nmrole, usr.idlogin, usr.nmuser, grsc.itsm001, grsc.itsm002
from adrole adr
left join DYNitsm017 grs on grs.itsm001 = left(adr.idrole,coalesce(charindex('_',adr.idrole), 1) -1)
left join DYNitsm016 grsc on grsc.oid = grs.OIDABCBSAGZNWY2N0Q
left join aduserrole adru on adru.cdrole = adr.cdrole
left join aduser usr on usr.cduser = adru.cduser
where adr.cdroleowner = 1404

---------------------> ATIVOS-01
-- Descrição: Informações de ativos
--	  Obs.: Necessário revisão!
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 03/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
SELECT OBJ.IDOBJECT, OBJ.NMOBJECT, OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT AS NM_FULLNAME
, ASINVPC.NMOS, ASINVPC.NMIPADDRESS, ASINVPC.NMUSERNAME, usr.nmuser
, OBJTYPE.nmobjecttype as objTipo, site.idsite, site.nmsite, dep.iddepartment, dep.nmdepartment
, case when OBJ.NMOBJECT like 'ak%' then 'T' else 'P' end as propriedade
, case when bios.nmtype like '%desktop%' then 'Desktop'
       when bios.nmtype like '%tower%' then 'Desktop'
       when bios.nmtype like '%notebook%' then 'Notebook'
       when bios.nmtype like '%portable%' then 'Notebook'
       when bios.nmtype like '%laptop%' then 'Notebook'
       when bios.nmtype like '%thinkpad%' then 'Notebook'
       when bios.nmtype like '%chassis%' then 'Servidor'
       when bios.nmtype like '%other%' then 'Servidor'
       else case when OBJ.NMOBJECT like 'akd%' then 'Desktop'
                 when OBJ.NMOBJECT like 'akn%' then 'Notebook'
                 when OBJ.NMOBJECT like 'd%' then 'Desktop'
                 when OBJ.NMOBJECT like 'n%' then 'Notebook'
                 else 'N/A'
            end
 end as nmtype
, ASAST.DTSTARTOPER
, (select top 1 case when cpu.nmtype like '%i3%' then 'I3'
                     when cpu.nmtype like '%i5%' then 'I5'
                     when cpu.nmtype like '%i7%' then 'I7'
                     when cpu.nmtype like '%xeon%' then 'XEON'
                     when cpu.nmtype like '%2 duo%' then '2 DUO'
                     when cpu.nmtype like '%AMD%' then 'AMD'
                     when cpu.nmtype like '%dual%' then 'Dual-Core'
                     when cpu.nmtype like '%celeron%' then 'Celeron'
                     when cpu.nmtype like '%quad%' then 'Quad-Core'
                     when cpu.nmtype like '%atom%' then 'Atom'
                     else 'Outro' end as cputype
   from ASASTINVCPCPU cpu where cpu.CDASTINVITCOMPUTER = ASINVPC.CDASTINVITCOMPUTER) as cputype
, (select sum(coalesce(mem.VLCAPACITYMB,0)) from ASASTINVCPMEMORY mem where mem.CDASTINVITCOMPUTER = ASINVPC.CDASTINVITCOMPUTER) as memMB
, 1 as qtd
FROM OBOBJECT OBJ
INNER JOIN OBOBJECTGROUP OBJGRP ON (OBJGRP.CDOBJECTGROUP=OBJ.CDOBJECT)
INNER JOIN OBOBJECTTYPE OBJTYPE ON (OBJTYPE.CDOBJECTTYPE=OBJGRP.CDOBJECTTYPE)
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION = OBJ.CDREVISION)
left JOIN ASASTINVITCOMPUTER ASINVPC ON (ASAST.CDASSET=ASINVPC.CDASSET AND ASAST.CDREVISION = ASINVPC.CDREVISION)
left JOIN ASASTINVENTORY ASINV ON (ASINVPC.CDASTINVENTORY=ASINV.CDASTINVENTORY)
left join ASASTINVCPBIOS bios on bios.CDASTINVITCOMPUTER = ASINVPC.CDASTINVITCOMPUTER
left join ASHISTASSETSITE locali on locali.cdasset = ASAST.cdasset and locali.cdrevision = ASAST.cdrevision and 
          (locali.dthistory+locali.tmhistory = (select max(locali2.dthistory+locali2.tmhistory)
                                                from ASHISTASSETSITE locali2
                                                where locali2.cdasset = locali.cdasset and locali2.cdrevision = locali.cdrevision))
left join assite site on site.cdsite = locali.cdsite
left join aduser usr on usr.idlogin = ASINVPC.NMUSERNAME
left join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
left join addepartment dep on dep.cddepartment = rel.cddepartment
WHERE OBJ.FGCURRENT = 1 AND OBJ.FGTEMPLATE <> 1
AND (ASINVPC.CDASTINVENTORY IS NULL OR ASINVPC.CDASTINVENTORY = (
     SELECT MAX(CDASTINVENTORY) FROM ASASTINVITCOMPUTER ASPC WHERE ASPC.CDASSET = ASAST.CDASSET AND ASPC.CDREVISION = ASAST.CDREVISION))
AND ASAST.FGASSTATUS <> 4 and OBJTYPE.cdobjecttype in (4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)

---------------------> ITSM-11
-- Descrição: Painel G1: Informações do cabeçalho e corpo do chamado
--	  
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess as identificador, wf.nmprocess, form.itsm033 as descricao
, wf.nmuserstart as quemPediu
, (select distinct unid.iddepartment +' - '+ unid.nmdepartment from addepartment dep inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment and rel.FGDEFAULTDEPTPOS = 1 and rel.cduser = wf.cduserstart inner join addepartment unid on unid.cddepartment = dep.cddeptowner) as quemPediuUnid
, (select dep.iddepartment +' - '+ dep.nmdepartment from addepartment dep inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment and rel.FGDEFAULTDEPTPOS = 1 and rel.cduser = wf.cduserstart) as quemPediuDep
, (select pos.idposition +' - '+ pos.nmposition from adposition pos inner join aduserdeptpos rel on rel.cdposition = pos.cdposition and rel.FGDEFAULTDEPTPOS = 1 and rel.cduser = wf.cduserstart) as quemPediuPos
, form.itsm041 as paraQuemPediu, form.itsm048 as paraQuemPediuUnid, case when (select nmdepartment from addepartment where iddepartment = form.itsm040) is null then form.itsm040 else (select nmdepartment from addepartment where iddepartment = form.itsm040) end as paraQuemPediuDep, form.itsm039 as paraQuemPediuPos
, form.itsm036 as unidserv, form.itsm070 as categserv
, form.itsm002 as objeto, form.itsm006 as servico, form.itsm004 as complemento, form.itsm049 as detalhe
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento - '+gnrev.NMREVISIONSTATUS WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado - '+ gnrev.NMREVISIONSTATUS
WHEN 5 THEN 'Bloqueado para edição' END AS status
, case when BNSLAFINISH is null then DATEADD(ms, gnslactrl.BNSLAFINISHPLAN % 1000, DATEADD(ss, gnslactrl.BNSLAFINISHPLAN/1000, CONVERT(DATETIME2(3),'19700101')))
       else  DATEADD(ms, gnslactrl.BNSLAFINISH % 1000, DATEADD(ss, gnslactrl.BNSLAFINISH/1000, CONVERT(DATETIME2(3),'19700101'))) end as quandoFicaPronto
, case gnslactrl.FGSLAFINISHSTATUS when 1 then 'Em dia' when 2 then 'Em atraso' else 'N/A' end pzstatus
, case form.itsm058 
    when 1 then 'Solicitação' 
    when 2 then 'Incidente' 
    when 3 then 'Mudança' 
    when 4 then 'Projeto' 
    when 11 then 'Dúvida' 
    when 5 then 'Problema' 
    when 6 then 'Evento'
    else 'n/a'
end as tipofim
, restx.NMEVALRESULT as prioridade, depset.depart, depset.setor
, wf.dtstart + wf.tmstart as dtinicio, wf.dtfinish + wf.tmfinish as dtfim
, form.itsm035 as GS
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
inner join GNSLA gnsla on gnsla.cdsla = gnslactrl.cdsla and gnsla.FGENABLED = 1
left JOIN GNSLACTRLHISTORY SLAH ON (gnslactrl.CDSLACONTROL = SLAH.CDSLACONTROL AND SLAH.FGCURRENT = 1) 
left JOIN GNSLALEVEL SLALC ON (SLAH.CDLEVEL = SLALC.CDLEVEL)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 is null or form.itsm035 = '') then '' else left(form.itsm035, charindex('_', form.itsm035)-1) end
inner join DYNitsm016 resp on resp.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join (select oid, left(itsm001, charindex('_', itsm001) -1) as depart, right(itsm001, len(itsm001) - charindex('_', itsm001)) as setor from DYNitsm020) depset on depset.oid = resp.OIDABCKIK9UXB5HNKT
left join GNEVALRESULTUSED res on res.CDEVALRESULTUSED = wf.CDEVALRSLTPRIORITY
left join GNEVALRESULT restx on restx.CDEVALRESULT = res.CDEVALRESULT
where wf.cdprocessmodel = 5251 and datepart(yyyy, wf.dtstart) = datepart(yyyy, getdate())


---------------------> ITSM-12
-- Descrição: Painel G2: Informações quantitativas
--	  Campos: idprocess, data de início, data de encerramento, quantidade, quantidade encerrado
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess, wf.dtstart, wf.dtfinish
, case when wf.dtfinish is not null then 1 else 0 end as qtdf
, 1 as qtd
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
inner join GNSLA gnsla on gnsla.cdsla = gnslactrl.cdsla and gnsla.FGENABLED = 1
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.cdprocessmodel = 5251


---------------------> ITSM-15
-- Descrição: Catálogo de serviços
--	  
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select form.itsm001 as [Identificador], cat.itsm003 as [Categoria {en-us}], cat.itsm002 as [Categoria {pt-br}], subc.itsm004 as [SubCategoria {en-us}], subc.itsm003 as [SubCategoria {pt-br}], agrup.itsm001e as [Grouper {en-us}], agrup.itsm001p as [Agrupador {pt-br}], form.itsm002e as [Object {en-us}], form.itsm002p as [Objeto {pt-br}], form.itsm003e as [Service {en-us}], form.itsm003p as [Serviço {pt-br}], form.itsm004e as [Complement {en-us}], form.itsm004p as [Complemento {pt-br}], form.itsm005e as [Descrição {en-us}], form.itsm005p as [Descrição {pt-br}], form.itsm006 as [SLA], form.itsm007 as [Tipo], form.itsm011e as [Comentários - {en-us}], form.itsm011p as [Comnetários {pt-br}], form.itsm023 as [Atendimento Corporativo], form.itsm021 as [Grupo solucionador], form.itsm012 as [Horário de suporte], form.itsm022 as [Esforço], form.itsm008 as [Quem Solicita - Todos], form.itsm009 as [Quem solicita - TI], form.itsm010 as [Quem solicita - DHO], form.itsm024 as [Quem solicita - VSC], form.itsm025 as [Quem solicita - Servicedesk], form.itsm026 as [Quem solicita - Governança], form.itsm028 as [Quem solicita - GQ], form.itsm032 as [Quem solicita - Key user], form.itsm013 as [Aprovação - Líder], form.itsm014 as [Aprovação - Gerente], form.itsm015 as [Aprovação - Diretor], form.itsm016 as [Aprovação - Dono], form.itsm017 as [Aprovação - Gerente TI], form.itsm018 as [Aprovação - Adicional], form.itsm019 as [Aprovação - Adicional (login)], form.itsm020 as [Aprovação - Adicional (nome)], form.itsm029 as [Aprovação - Coord Grupo Soluc.], form.itsm027 as [Automatizado], form.itsm030 as [Automatizado - complemento], form.itsm031 as [Automatizado - Preparação], form.oidrevisionform, form.oid as [oidentityreg], (select OIDENTITY from EFFORM where oid = (SELECT oidform FROM EFREVISIONFORM WHERE idform = 'itsm001' AND FGCURRENT=1)) as [oidentity] from DYNitsm001 form inner join DYNitsm002 cat on form.OIDABCP4PNGD3QW8LP = cat.oid inner join DYNitsm003 subc on form.OIDABC33MU921YCVUK = subc.oid inner join DYNitsm019 agrup on form.OIDABC868DY7UV2HFM = agrup.oid



---------------------> ITSM-14
-- Descrição: Apontamento de horas (Processo / Projeto / Atividades isoladas / Plano de ação)
--	  
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
select sum(horas) as horas, usr.nmuser as analista, usr.idlogin as login, timesheetcomp.DTACTUAL
FROM aduser usr
inner join (
SELECT TIMESHEETVIEW.DTACTUAL, TIMESHEETVIEW.NMRESOURCE, TIMESHEETVIEW.cduser
, cast((cast(Datepart(hh,(DATEADD(ms, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) % 1000, DATEADD(ss, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0))/1000, CONVERT(DATETIME2(3),'19700101')))))*3600 as float) + cast(Datepart(mi,(DATEADD(ms, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) % 1000, DATEADD(ss, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0))/1000, CONVERT(DATETIME2(3),'19700101')))))*60 as float)+ cast(Datepart(ss,(DATEADD(ms, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) % 1000, DATEADD(ss, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0))/1000, CONVERT(DATETIME2(3),'19700101'))))) as float)) / 3600 as float) as horas
FROM (
--Projeto
SELECT TIMESHEET.CDTIMESHEET, GNR.NMRESOURCE AS NMRESOURCE, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN
, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN
, ATI.CDTASK AS CDACTIVITY, ATI.NMIDTASK AS IDACTIVITY
FROM GNTIMESHEET TIMESHEET
INNER JOIN PRTASKTIMESHEET TASKTIME ON (TASKTIME.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN PRTASK ATI ON (ATI.CDTASK=TASKTIME.CDTASK)
LEFT OUTER JOIN PRTASKTYPE ATITYPE ON (ATI.CDTASKTYPE=ATITYPE.CDTASKTYPE)
INNER JOIN PRTASK ATB ON (ATI.CDBASETASK=ATB.CDTASK)
	LEFT JOIN (SELECT DISTINCT PVIEW.PR_CDTASK FROM (SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=1
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=2
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT AND UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=3
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, ACCVIEW.CDUSER FROM PRTASKACCESS ACCVIEW  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=4
	/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
	SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, TMM.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADTEAMUSER TMM ON TMM.CDTEAM=ACCVIEW.CDTEAM  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=5
	) PVIEW WHERE 1=1) PRTASKSECURITY ON PRTASKSECURITY.PR_CDTASK=ATB.CDBASETASK AND ATB.FGRESTRICT=1
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
WHERE ATI.FGTASKTYPE=1

UNION ALL
SELECT TIMESHEET.CDTIMESHEET, GNR.NMRESOURCE AS NMRESOURCE, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN
, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN
, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG)
INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY)
LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING)
INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY)
WHERE ASEXECACT.FGACTTYPE=1

UNION ALL
SELECT TIMESHEET.CDTIMESHEET, GNR.NMRESOURCE AS NMRESOURCE, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN
, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN
, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG)
INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY)
LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING)
INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY)
WHERE ASEXECACT.FGACTTYPE=3

UNION ALL
SELECT TIMESHEET.CDTIMESHEET, GNR.NMRESOURCE AS NMRESOURCE, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN
, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN
, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG)
INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY)
LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING)
INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY)
WHERE ASEXECACT.FGACTTYPE IN (2,6,7,8)

--Plano de ação
UNION ALL
SELECT TIMESHEET.CDTIMESHEET, GNR.NMRESOURCE AS NMRESOURCE, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN
, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN
, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY)
INNER JOIN GNTASK GNTK ON (GNA.CDGENACTIVITY=GNTK.CDGENACTIVITY)
LEFT OUTER JOIN GNGENTYPE GNGNTP ON (GNGNTP.CDGENTYPE=GNTK.CDTASKTYPE)
LEFT OUTER JOIN GNACTIVITY GNACT2 ON (GNACT2.CDGENACTIVITY=GNA.CDACTIVITYOWNER)
LEFT OUTER JOIN GNACTIONPLAN GNACTPL ON (GNACTPL.CDGENACTIVITY=GNACT2.CDGENACTIVITY)
LEFT OUTER JOIN GNGENTYPE GNGNTP2 ON (GNGNTP2.CDGENTYPE=GNACTPL.CDACTIONPLANTYPE)
INNER JOIN ADUSER ADUS ON (GNA.CDUSER=ADUS.CDUSER)
WHERE 1 = 1

UNION ALL
SELECT TIMESHEET.CDTIMESHEET, GNR.NMRESOURCE AS NMRESOURCE, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN
, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN
, GNM.CDMEETING AS CDACTIVITY, GNM.IDMEETING AS IDACTIVITY
FROM GNTIMESHEET TIMESHEET
INNER JOIN GNMEETINGTSHEET GMTS ON (GMTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN GNMEETING GNM ON (GNM.CDMEETING=GMTS.CDMEETING)
LEFT OUTER JOIN GNGENTYPE GNGT ON (GNM.CDMEETINGTYPE=GNGT.CDGENTYPE)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
WHERE 1 = 1

--Workflow
UNION ALL
SELECT GNTS.CDTIMESHEET, GNR.NMRESOURCE, GNTS.DTACTUAL, GNTS.CDUSER, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN
, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN
, GNA.CDGENACTIVITY AS CDACTIVITY, WFS.IDSTRUCT AS IDACTIVITY
FROM GNACTIVITY GNA
INNER JOIN WFACTIVITY WFA ON (WFA.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN WFSTRUCT WFS ON (WFS.IDOBJECT=WFA.IDOBJECT)
INNER JOIN WFPROCESS WFP ON (WFP.IDOBJECT=WFS.IDPROCESS)
INNER JOIN GNACTIVITY GNAWF ON (GNAWF.CDGENACTIVITY=WFP.CDGENACTIVITY)
INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE)
WHERE (WFP.CDPRODAUTOMATION IS NULL OR WFP.CDPRODAUTOMATION NOT IN (275))

UNION ALL
SELECT GNTS.CDTIMESHEET, GNR.NMRESOURCE, GNTS.DTACTUAL, GNTS.CDUSER, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN
, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN
, GNA.CDGENACTIVITY AS CDACTIVITY, TSW.NMPREFIX + '-' + CAST(TST.NRTASK AS VARCHAR(255)) AS IDACTIVITY
FROM GNACTIVITY GNA
INNER JOIN WFPROCESS WFP ON (WFP.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN TSTASK TST ON (TST.IDOBJECT=WFP.IDOBJECT)
INNER JOIN TSWORKSPACE TSW ON (TSW.CDWORKSPACE=TST.CDWORKSPACE)
INNER JOIN TSFLOWSTEP TSFS ON (TSFS.CDFLOW=TST.CDFLOW AND TSFS.CDSTEP=TST.CDSTEP)
LEFT JOIN TSSPRINT TSS ON (TSS.CDSPRINT=TST.CDSPRINT AND TSS.CDWORKSPACE=TST.CDWORKSPACE)
INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY)
INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE)
WHERE 1 = 1

UNION ALL
SELECT TIMESHEET.CDTIMESHEET, GNR.NMRESOURCE AS NMRESOURCE, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN
, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN
, ATI.CDTASK AS CDACTIVITY, ATI.NMIDTASK AS IDACTIVITY
FROM GNTIMESHEET TIMESHEET
INNER JOIN PRTASKTIMESHEET TASKTIME ON (TASKTIME.CDTIMESHEET=TIMESHEET.CDTIMESHEET)
INNER JOIN PRTASK ATI ON (ATI.CDTASK=TASKTIME.CDTASK)
LEFT JOIN (SELECT DISTINCT PVIEW.PR_CDTASK FROM (SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=1
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=2
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT AND UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=3
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, ACCVIEW.CDUSER FROM PRTASKACCESS ACCVIEW  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=4
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, TMM.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADTEAMUSER TMM ON TMM.CDTEAM=ACCVIEW.CDTEAM  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=5
) PVIEW WHERE 1=1) PRTASKSECURITY ON PRTASKSECURITY.PR_CDTASK=ATI.CDBASETASK AND ATI.FGRESTRICT=1 LEFT OUTER JOIN PRTASKTYPE ATITYPE ON (ATI.CDTASKTYPE=ATITYPE.CDTASKTYPE)
INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE)
WHERE ATI.FGTASKTYPE IN (2, 3) AND (( ATI.FGRESTRICT=2 OR ATI.FGRESTRICT IS NULL OR ATI.FGRESTRICT=0) OR (PRTASKSECURITY.PR_CDTASK IS NOT NULL))
)TIMESHEETVIEW, GNTIMESHEET GTS, GNTIMEENTRY GTE
WHERE TIMESHEETVIEW.CDTIMESHEET=GTS.CDTIMESHEET AND GTE.CDTIMESHEET=TIMESHEETVIEW.CDTIMESHEET
) timesheetcomp on timesheetcomp.cduser = usr.cduser and year(timesheetcomp.DTACTUAL) = year(getdate()) and (month(timesheetcomp.DTACTUAL) = month(getdate()) or month(timesheetcomp.DTACTUAL) = month(getdate()) - 1)
where usr.FGUSERENABLED = 1
group by timesheetcomp.DTACTUAL, usr.nmuser, usr.idlogin

=================================================================================================================================
==
== Original
==
=================================================================================================================================
SELECT TIMESHEETVIEW.DTACTUAL, TIMESHEETVIEW.CDRESOURCE, TIMESHEETVIEW.IDRESOURCE, TIMESHEETVIEW.NMRESOURCE, TIMESHEETVIEW.CDTIMESHEET, CASE WHEN FGOVER=0 THEN CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12)) ELSE CASE WHEN FGOVER=2 THEN CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12)) END END AS QTSTRAIGHTMIN, CASE WHEN FGOVER=0 THEN CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12)) ELSE CASE WHEN FGOVER=1 THEN CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12)) END END AS QTOVERMIN, (COALESCE (CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTSTRAIGHTMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=2 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0) + COALESCE(CASE WHEN FGOVER=0 THEN (CAST( TIMESHEETVIEW.QTOVERMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) ELSE CASE WHEN FGOVER=1 THEN (CAST( GTE.QTTOTALMIN AS NUMERIC(28,12)) * CAST( 60 * 1000 AS NUMERIC(28,12))) END END, 0)) AS QTTOTALMIN, CASE WHEN TIMESHEETVIEW.CDUSER IS NULL THEN -1 ELSE TIMESHEETVIEW.CDUSER END AS CDUSER, TIMESHEETVIEW.RESOURCEUSER, TIMESHEETVIEW.IDOBJECT + ' - ' + TIMESHEETVIEW.NMOBJECT AS OBJETO, TIMESHEETVIEW.IDACTIVITY + ' - ' + TIMESHEETVIEW.NMACTIVITY AS ATIVIDADE, CASE TIMESHEETVIEW.CHARGE WHEN 1 THEN 'Faturada' ELSE 'Não faturada' END AS CHARGE, TIMESHEETVIEW.DEPARTMENT, TIMESHEETVIEW.POSITION, TIMESHEETVIEW.IDTYPE, TIMESHEETVIEW.CDISOSYSTEM, TIMESHEETVIEW.TMSTRAIGHTHOURS, TIMESHEETVIEW.TMOVERHOURS, GTE.QTTOTALMIN AS TOTALMINENTRY, GTE.NRSEQTIME, TIMESHEETVIEW.TYPEDATA, TIMESHEETVIEW.FGACTIVITYTYPE, TIMESHEETVIEW.CDACTIVITY, TIMESHEETVIEW.CDOBJECT, GTE.FGMODE, GTE.FGOVER, GTE.TMSTARTHOURS, GTE.TMENDHOURS, GTE.TMTOTALHOURS, GTE.DSDESCRIPTION, GTE.DSNOTES, GTE.DSJUSTIFY, GTS.FGSTATUS, GTS.CDAPPROV, CASE WHEN ADU.NMUSER IS NULL THEN 'Admin' ELSE ADU.NMUSER END AS NMUSER, TIMESHEETVIEW.IDOBJECTPROCESS

FROM (SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, ATITYPE.IDTASKTYPE + ' - ' + ATITYPE.NMTASKTYPE AS IDTYPE, ATI.CDTASKTYPE AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, CASE ATI.FGCHARGE WHEN 1 THEN 1 ELSE 2 END AS CHARGE, ADDPT.IDDEPARTMENT + ' - ' + ADDPT.NMDEPARTMENT AS DEPARTMENT, ADPOS.IDPOSITION + ' - ' + ADPOS.NMPOSITION AS POSITION, ADDP.CDDEPARTMENT, ADDP.CDPOSITION, ATI.CDTASK AS CDACTIVITY, ATI.NMIDTASK AS IDACTIVITY, ATB.CDTASK AS CDOBJECT, ATB.NMIDTASK AS IDOBJECT, ATB.NMTASK AS NMOBJECT, ATI.FGTASKTYPE AS FGACTIVITYTYPE, ATI.NMTASK AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNTIMESHEET TIMESHEET INNER JOIN PRTASKTIMESHEET TASKTIME ON (TASKTIME.CDTIMESHEET=TIMESHEET.CDTIMESHEET) INNER JOIN PRTASK ATI ON (ATI.CDTASK=TASKTIME.CDTASK) LEFT OUTER JOIN PRTASKTYPE ATITYPE ON (ATI.CDTASKTYPE=ATITYPE.CDTASKTYPE) INNER JOIN PRTASK ATB ON (ATI.CDBASETASK=ATB.CDTASK) LEFT JOIN (SELECT DISTINCT PVIEW.PR_CDTASK FROM (SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=1
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=2
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT AND UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=3
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, ACCVIEW.CDUSER FROM PRTASKACCESS ACCVIEW  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=4
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, TMM.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADTEAMUSER TMM ON TMM.CDTEAM=ACCVIEW.CDTEAM  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=5
) PVIEW WHERE 1=1) PRTASKSECURITY ON PRTASKSECURITY.PR_CDTASK=ATB.CDBASETASK AND ATB.FGRESTRICT=1 INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE) LEFT OUTER JOIN ADUSERDEPTPOS ADDP ON (GNR.CDUSER=ADDP.CDUSER AND ADDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT ADDPT ON (ADDP.CDDEPARTMENT=ADDPT.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION ADPOS ON (ADDP.CDPOSITION=ADPOS.CDPOSITION) WHERE ATI.FGTASKTYPE=1 AND (( ATB.FGRESTRICT=2 OR ATB.FGRESTRICT IS NULL OR ATB.FGRESTRICT=0) OR (PRTASKSECURITY.PR_CDTASK IS NOT NULL))
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, ADDPT.IDDEPARTMENT + ' - ' + ADDPT.NMDEPARTMENT AS DEPARTMENT, ADPOS.IDPOSITION + ' - ' + ADPOS.NMPOSITION AS POSITION, ADDP.CDDEPARTMENT, ADDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY, ASEXECACT.CDEXECACTIVITY AS CDOBJECT, GNA.IDACTIVITY AS IDOBJECT, CASE WHEN ASEXECACT.CDPLANNING IS NULL THEN ASACT.IDACTIVITY + ' - ' + ASACT.NMACTIVITY ELSE ASPLANACT.IDPLANACTIVITY + ' - ' + ASPLANACT.NMPLANACTIVITY END AS NMOBJECT, CAST(8 AS NUMERIC(10)) AS FGACTIVITYTYPE, GNA.IDACTIVITY AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNTIMESHEET TIMESHEET INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE) LEFT OUTER JOIN ADUSERDEPTPOS ADDP ON (ADDP.CDUSER=GNR.CDUSER AND ADDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT ADDPT ON (ADDP.CDDEPARTMENT=ADDPT.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION ADPOS ON (ADDP.CDPOSITION=ADPOS.CDPOSITION) INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY) INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG) INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY) LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING) INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY) WHERE ASEXECACT.FGACTTYPE IN (1)
UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, ADDPT.IDDEPARTMENT + ' - ' + ADDPT.NMDEPARTMENT AS DEPARTMENT, ADPOS.IDPOSITION + ' - ' + ADPOS.NMPOSITION AS POSITION, ADDP.CDDEPARTMENT, ADDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY, ASEXECACT.CDEXECACTIVITY AS CDOBJECT, GNA.IDACTIVITY AS IDOBJECT, CASE WHEN ASEXECACT.CDPLANNING IS NULL THEN ASACT.IDACTIVITY + ' - ' + ASACT.NMACTIVITY ELSE ASPLANACT.IDPLANACTIVITY + ' - ' + ASPLANACT.NMPLANACTIVITY END AS NMOBJECT, CAST(9 AS NUMERIC(10)) AS FGACTIVITYTYPE, GNA.IDACTIVITY AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNTIMESHEET TIMESHEET INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE) LEFT OUTER JOIN ADUSERDEPTPOS ADDP ON (ADDP.CDUSER=GNR.CDUSER AND ADDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT ADDPT ON (ADDP.CDDEPARTMENT=ADDPT.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION ADPOS ON (ADDP.CDPOSITION=ADPOS.CDPOSITION) INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY) INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG) INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY) LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING) INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY) WHERE ASEXECACT.FGACTTYPE IN (3)
UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, ADDPT.IDDEPARTMENT + ' - ' + ADDPT.NMDEPARTMENT AS DEPARTMENT, ADPOS.IDPOSITION + ' - ' + ADPOS.NMPOSITION AS POSITION, ADDP.CDDEPARTMENT, ADDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY AS IDACTIVITY, ASEXECACT.CDEXECACTIVITY AS CDOBJECT, GNA.IDACTIVITY AS IDOBJECT, CASE WHEN ASEXECACT.CDPLANNING IS NULL THEN ASACT.IDACTIVITY + ' - ' + ASACT.NMACTIVITY ELSE ASPLANACT.IDPLANACTIVITY + ' - ' + ASPLANACT.NMPLANACTIVITY END AS NMOBJECT, CAST(10 AS NUMERIC(10)) AS FGACTIVITYTYPE, GNA.IDACTIVITY AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNTIMESHEET TIMESHEET INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE) LEFT OUTER JOIN ADUSERDEPTPOS ADDP ON (ADDP.CDUSER=GNR.CDUSER AND ADDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT ADDPT ON (ADDP.CDDEPARTMENT=ADDPT.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION ADPOS ON (ADDP.CDPOSITION=ADPOS.CDPOSITION) INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY) INNER JOIN GNACTIVITYTIMECFG GNCFG ON (GNA.CDACTIVITYTIMECFG=GNCFG.CDACTIVITYTIMECFG) INNER JOIN ASEXECACTIVITY ASEXECACT ON (GNA.CDGENACTIVITY=ASEXECACT.CDGENACTIVITY) LEFT JOIN ASPLANACTIVITY ASPLANACT ON (ASPLANACT.CDPLANACTIVITY=ASEXECACT.CDPLANNING) INNER JOIN ASACTIVITY ASACT ON (ASEXECACT.CDACTIVITY=ASACT.CDACTIVITY) WHERE ASEXECACT.FGACTTYPE IN (2,6,7,8)
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, NULL AS IDTYPE, 0 AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, ADDPT.IDDEPARTMENT + ' - ' + ADDPT.NMDEPARTMENT AS DEPARTMENT, ADPOS.IDPOSITION + ' - ' + ADPOS.NMPOSITION AS POSITION, ADDP.CDDEPARTMENT, ADDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, GNA.IDACTIVITY, CASE WHEN GNACT2.CDGENACTIVITY IS NULL THEN GNA.CDGENACTIVITY ELSE GNACT2.CDGENACTIVITY END AS CDOBJECT, CASE WHEN GNACT2.IDACTIVITY IS NULL THEN GNA.IDACTIVITY ELSE GNACT2.IDACTIVITY END AS IDOBJECT, CASE WHEN GNACT2.NMACTIVITY IS NULL THEN GNA.NMACTIVITY ELSE GNACT2.NMACTIVITY END AS NMOBJECT, CASE WHEN GNA.CDACTIVITYOWNER IS NULL THEN 6 ELSE 7 END AS FGACTIVITYTYPE,GNA.NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNTIMESHEET TIMESHEET INNER JOIN GNACTIVITYTSHEET GNTS ON (GNTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE) LEFT OUTER JOIN ADUSERDEPTPOS ADDP ON (ADDP.CDUSER=GNR.CDUSER AND ADDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT ADDPT ON (ADDP.CDDEPARTMENT=ADDPT.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION ADPOS ON (ADDP.CDPOSITION=ADPOS.CDPOSITION) INNER JOIN GNACTIVITY GNA ON (GNA.CDGENACTIVITY=GNTS.CDGENACTIVITY) INNER JOIN GNTASK GNTK ON (GNA.CDGENACTIVITY=GNTK.CDGENACTIVITY) LEFT OUTER JOIN GNGENTYPE GNGNTP ON (GNGNTP.CDGENTYPE=GNTK.CDTASKTYPE) LEFT OUTER JOIN GNACTIVITY GNACT2 ON (GNACT2.CDGENACTIVITY=GNA.CDACTIVITYOWNER) LEFT OUTER JOIN GNACTIONPLAN GNACTPL ON (GNACTPL.CDGENACTIVITY=GNACT2.CDGENACTIVITY) LEFT OUTER JOIN GNGENTYPE GNGNTP2 ON (GNGNTP2.CDGENTYPE=GNACTPL.CDACTIONPLANTYPE) INNER JOIN ADUSER ADUS ON (GNA.CDUSER=ADUS.CDUSER) WHERE 1 = 1
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, GNGT.IDGENTYPE + ' - ' + GNGT.NMGENTYPE AS IDTYPE, GNM.CDMEETINGTYPE AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, 2 AS CHARGE, ADDPT.IDDEPARTMENT + ' - ' + ADDPT.NMDEPARTMENT AS DEPARTMENT, ADPOS.IDPOSITION + ' - ' + ADPOS.NMPOSITION AS POSITION, ADDP.CDDEPARTMENT, ADDP.CDPOSITION, GNM.CDMEETING AS CDACTIVITY, GNM.IDMEETING AS IDACTIVITY, GNM.CDMEETING AS CDOBJECT, GNM.IDMEETING AS IDOBJECT, GNM.NMMEETING AS NMOBJECT, 4 AS FGACTIVITYTYPE, GNM.NMMEETING AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNTIMESHEET TIMESHEET INNER JOIN GNMEETINGTSHEET GMTS ON (GMTS.CDTIMESHEET=TIMESHEET.CDTIMESHEET) INNER JOIN GNMEETING GNM ON (GNM.CDMEETING=GMTS.CDMEETING) LEFT OUTER JOIN GNGENTYPE GNGT ON (GNM.CDMEETINGTYPE=GNGT.CDGENTYPE) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE) LEFT OUTER JOIN ADUSERDEPTPOS ADDP ON (ADDP.CDUSER=GNR.CDUSER AND ADDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT ADDPT ON (ADDP.CDDEPARTMENT=ADDPT.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION ADPOS ON (ADDP.CDPOSITION=ADPOS.CDPOSITION) WHERE 1 = 1
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT GNTS.CDISOSYSTEM, GNTS.CDTIMESHEET, GNR.IDRESOURCE, GNR.NMRESOURCE, GNR.CDRESOURCE, '' AS IDTYPE, -1 AS TYPEDATA, 0 AS PLANEJADO, GNTS.DTACTUAL, GNTS.CDUSER, GNR.CDUSER AS RESOURCEUSER, GNTS.FGSTATUS, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN, 2 AS CHARGE, ADDP.IDDEPARTMENT + ' - ' + ADDP.NMDEPARTMENT AS DEPARTMENT, ADP.IDPOSITION + ' - ' + ADP.NMPOSITION AS POSITION, ADUDP.CDDEPARTMENT, ADUDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, WFS.IDSTRUCT AS IDACTIVITY, GNAWF.CDGENACTIVITY AS CDOBJECT, WFP.IDPROCESS AS IDOBJECT, WFP.NMPROCESS AS NMOBJECT, 11 AS FGACTIVITYTYPE, WFS.NMSTRUCT AS NMACTIVITY, WFP.IDOBJECT AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNACTIVITY GNA INNER JOIN WFACTIVITY WFA ON (WFA.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN WFSTRUCT WFS ON (WFS.IDOBJECT=WFA.IDOBJECT) INNER JOIN WFPROCESS WFP ON (WFP.IDOBJECT=WFS.IDPROCESS) INNER JOIN GNACTIVITY GNAWF ON (GNAWF.CDGENACTIVITY=WFP.CDGENACTIVITY) INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE) LEFT JOIN ADUSERDEPTPOS ADUDP ON (ADUDP.CDUSER=GNR.CDUSER AND ADUDP.FGDEFAULTDEPTPOS=1) LEFT JOIN ADDEPARTMENT ADDP ON (ADDP.CDDEPARTMENT=ADUDP.CDDEPARTMENT) LEFT JOIN ADPOSITION ADP ON (ADP.CDPOSITION=ADUDP.CDPOSITION) INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON WF.CDTEAM=TM.CDTEAM WHERE WF.FGACCESSTYPE=1 AND WF.FGACCESSEXCEPTION IS NULL
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE WF.FGACCESSTYPE=2
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=3
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=4
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE WF.FGACCESSTYPE=5
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE WF.FGACCESSTYPE=6
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON RL.CDROLE=WF.CDROLE WHERE WF.FGACCESSTYPE=7
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS WHERE WF.FGACCESSTYPE=30
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE WF.FGACCESSTYPE=31
AND WF.FGACCESSEXCEPTION IS NULL) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON (GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST AND GNASSOC.IDPROCESS=PERM.IDPROCESS) WHERE GNASSOC.CDACCESSROLEFIELD IN (501) GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON PERMISSION.IDPROCESS=AUXWFP.IDOBJECT WHERE PERMISSION.FGPERMISSION=1 AND AUXWFP.FGSTATUS <= 5 AND (AUXWFP.FGMODELWFSECURITY IS NULL OR AUXWFP.FGMODELWFSECURITY=0) UNION ALL SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE PP.FGACCESSTYPE=1
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PP.FGACCESSTYPE=2
UNION ALL SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION) WHERE PP.FGACCESSTYPE=3
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE PP.FGACCESSTYPE=4
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE PP.FGACCESSTYPE=5
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE PP.FGACCESSTYPE=6
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE PP.FGACCESSTYPE=7
) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE PP.FGACCESSTYPE=30
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PP.FGACCESSTYPE=31
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT T.IDOBJECT FROM (SELECT PERM.IDOBJECT, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM1.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE PM.FGACCESSTYPE=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PM.FGACCESSTYPE=2
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=3
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=4
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM WHERE PM.FGACCESSTYPE=5
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM CROSS JOIN ADUSER US WHERE PM.FGACCESSTYPE=6
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE PM.FGACCESSTYPE=7
) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM2.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PMA.CDCREATEDBY AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE PM.FGACCESSTYPE=8
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE PM.FGACCESSTYPE=9
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION) WHERE PM.FGACCESSTYPE=10
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE PM.FGACCESSTYPE=11
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE PM.FGACCESSTYPE=12
) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PERM3.IDOBJECT, PMA.FGUSETYPEACCESS, PERM3.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, WFP.CDUSERSTART AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE PM.FGACCESSTYPE=30
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PM.FGACCESSTYPE=31
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND PMA.FGUSETYPEACCESS=1) PERM GROUP BY PERM.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN WFPROCSECURITYLIST WFLIST ON (AUXWFP.IDOBJECT=WFLIST.IDPROCESS) INNER JOIN WFPROCSECURITYCTRL WFCTRL ON (WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS) WHERE WFCTRL.CDACCESSROLEFIELD IN (501)
AND WFLIST.FGACCESSTYPE=5 AND WFLIST.FGACCESSEXCEPTION=1
AND AUXWFP.FGSTATUS <= 5) Z) MYPERM ON (WFP.IDOBJECT=MYPERM.IDOBJECT) WHERE (WFP.CDPRODAUTOMATION IS NULL OR WFP.CDPRODAUTOMATION NOT IN (160, 202, 275))
UNION ALL
SELECT GNTS.CDISOSYSTEM, GNTS.CDTIMESHEET, GNR.IDRESOURCE, GNR.NMRESOURCE, GNR.CDRESOURCE, '' AS IDTYPE, -1 AS TYPEDATA, 0 AS PLANEJADO, GNTS.DTACTUAL, GNTS.CDUSER, GNR.CDUSER AS RESOURCEUSER, GNTS.FGSTATUS, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN, 2 AS CHARGE, ADDP.IDDEPARTMENT + ' - ' + ADDP.NMDEPARTMENT AS DEPARTMENT, ADP.IDPOSITION + ' - ' + ADP.NMPOSITION AS POSITION, ADUDP.CDDEPARTMENT, ADUDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, WFS.IDSTRUCT AS IDACTIVITY, GNAWF.CDGENACTIVITY AS CDOBJECT, WFP.IDPROCESS AS IDOBJECT, WFP.NMPROCESS AS NMOBJECT, 12 AS FGACTIVITYTYPE, WFS.NMSTRUCT AS NMACTIVITY, WFP.IDOBJECT AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNACTIVITY GNA INNER JOIN WFACTIVITY WFA ON (WFA.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN WFSTRUCT WFS ON (WFS.IDOBJECT=WFA.IDOBJECT) INNER JOIN WFPROCESS WFP ON (WFP.IDOBJECT=WFS.IDPROCESS) INNER JOIN GNACTIVITY GNAWF ON (GNAWF.CDGENACTIVITY=WFP.CDGENACTIVITY) INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE) LEFT JOIN ADUSERDEPTPOS ADUDP ON (ADUDP.CDUSER=GNR.CDUSER AND ADUDP.FGDEFAULTDEPTPOS=1) LEFT JOIN ADDEPARTMENT ADDP ON (ADDP.CDDEPARTMENT=ADUDP.CDDEPARTMENT) LEFT JOIN ADPOSITION ADP ON (ADP.CDPOSITION=ADUDP.CDPOSITION) INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON WF.CDTEAM=TM.CDTEAM WHERE WF.FGACCESSTYPE=1
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE WF.FGACCESSTYPE=2
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=3
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=4
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE WF.FGACCESSTYPE=5
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE WF.FGACCESSTYPE=6
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON RL.CDROLE=WF.CDROLE WHERE WF.FGACCESSTYPE=7
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS WHERE WF.FGACCESSTYPE=30
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE WF.FGACCESSTYPE=31
AND WF.FGACCESSEXCEPTION IS NULL) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON (GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST AND GNASSOC.IDPROCESS=PERM.IDPROCESS) WHERE GNASSOC.CDACCESSROLEFIELD IN (501) GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON PERMISSION.IDPROCESS=AUXWFP.IDOBJECT WHERE AUXWFP.FGSTATUS <= 5
AND (AUXWFP.FGMODELWFSECURITY IS NULL OR AUXWFP.FGMODELWFSECURITY=0)
UNION ALL
SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE PP.FGACCESSTYPE=1
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PP.FGACCESSTYPE=2
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION) WHERE PP.FGACCESSTYPE=3
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE PP.FGACCESSTYPE=4
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE PP.FGACCESSTYPE=5
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE PP.FGACCESSTYPE=6
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE PP.FGACCESSTYPE=7
) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE PP.FGACCESSTYPE=30
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PP.FGACCESSTYPE=31
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT T.IDOBJECT FROM (SELECT PERM.IDOBJECT, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM1.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE PM.FGACCESSTYPE=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PM.FGACCESSTYPE=2
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=3
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=4
UNION ALL 
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM WHERE PM.FGACCESSTYPE=5
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM CROSS JOIN ADUSER US WHERE PM.FGACCESSTYPE=6
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE PM.FGACCESSTYPE=7
) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM2.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PMA.CDCREATEDBY AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE PM.FGACCESSTYPE=8
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE PM.FGACCESSTYPE=9
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION) WHERE PM.FGACCESSTYPE=10
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE PM.FGACCESSTYPE=11
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE PM.FGACCESSTYPE=12
) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PERM3.IDOBJECT, PMA.FGUSETYPEACCESS, PERM3.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, WFP.CDUSERSTART AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE PM.FGACCESSTYPE=30
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PM.FGACCESSTYPE=31
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND PMA.FGUSETYPEACCESS=1) PERM GROUP BY PERM.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN WFPROCSECURITYLIST WFLIST ON (AUXWFP.IDOBJECT=WFLIST.IDPROCESS) INNER JOIN WFPROCSECURITYCTRL WFCTRL ON (WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS) WHERE WFCTRL.CDACCESSROLEFIELD IN (501) AND WFLIST.CDUSER=1548 AND WFLIST.FGACCESSTYPE=5 AND WFLIST.FGACCESSEXCEPTION=1
AND AUXWFP.FGSTATUS <= 5) Z) MYPERM ON (WFP.IDOBJECT=MYPERM.IDOBJECT) WHERE WFP.CDPRODAUTOMATION=160
UNION ALL
SELECT GNTS.CDISOSYSTEM, GNTS.CDTIMESHEET, GNR.IDRESOURCE, GNR.NMRESOURCE, GNR.CDRESOURCE, '' AS IDTYPE, -1 AS TYPEDATA, 0 AS PLANEJADO, GNTS.DTACTUAL, GNTS.CDUSER, GNR.CDUSER AS RESOURCEUSER, GNTS.FGSTATUS, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN, 2 AS CHARGE, ADDP.IDDEPARTMENT + ' - ' + ADDP.NMDEPARTMENT AS DEPARTMENT, ADP.IDPOSITION + ' - ' + ADP.NMPOSITION AS POSITION, ADUDP.CDDEPARTMENT, ADUDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, WFS.IDSTRUCT AS IDACTIVITY, GNAWF.CDGENACTIVITY AS CDOBJECT, WFP.IDPROCESS AS IDOBJECT, WFP.NMPROCESS AS NMOBJECT, 13 AS FGACTIVITYTYPE, WFS.NMSTRUCT AS NMACTIVITY, WFP.IDOBJECT AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNACTIVITY GNA INNER JOIN WFACTIVITY WFA ON (WFA.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN WFSTRUCT WFS ON (WFS.IDOBJECT=WFA.IDOBJECT) INNER JOIN WFPROCESS WFP ON (WFP.IDOBJECT=WFS.IDPROCESS) INNER JOIN GNACTIVITY GNAWF ON (GNAWF.CDGENACTIVITY=WFP.CDGENACTIVITY) INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE) LEFT JOIN ADUSERDEPTPOS ADUDP ON (ADUDP.CDUSER=GNR.CDUSER AND ADUDP.FGDEFAULTDEPTPOS=1) LEFT JOIN ADDEPARTMENT ADDP ON (ADDP.CDDEPARTMENT=ADUDP.CDDEPARTMENT) LEFT JOIN ADPOSITION ADP ON (ADP.CDPOSITION=ADUDP.CDPOSITION) INNER JOIN (SELECT DISTINCT Z.IDOBJECT FROM (SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN (SELECT PERM.USERCD, PERM.IDPROCESS, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WF.FGPERMISSION, WF.IDPROCESS, TM.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADTEAMUSER TM ON WF.CDTEAM=TM.CDTEAM WHERE WF.FGACCESSTYPE=1
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE WF.FGACCESSTYPE=2
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDDEPARTMENT=UDP.CDDEPARTMENT AND WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=3
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, UDP.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERDEPTPOS UDP ON WF.CDPOSITION=UDP.CDPOSITION WHERE WF.FGACCESSTYPE=4
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, WF.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF WHERE WF.FGACCESSTYPE=5
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF CROSS JOIN ADUSER US WHERE WF.FGACCESSTYPE=6
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, RL.CDUSER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN ADUSERROLE RL ON RL.CDROLE=WF.CDROLE WHERE WF.FGACCESSTYPE=7
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, WFP.CDUSERSTART AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS WHERE WF.FGACCESSTYPE=30
AND WF.FGACCESSEXCEPTION IS NULL
UNION ALL
SELECT WF.FGPERMISSION, WF.IDPROCESS, US.CDLEADER AS USERCD, WF.CDACCESSLIST FROM WFPROCSECURITYLIST WF INNER JOIN WFPROCESS WFP ON WFP.IDOBJECT=WF.IDPROCESS INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE WF.FGACCESSTYPE=31
AND WF.FGACCESSEXCEPTION IS NULL) PERM INNER JOIN WFPROCSECURITYCTRL GNASSOC ON (GNASSOC.CDACCESSLIST=PERM.CDACCESSLIST AND GNASSOC.IDPROCESS=PERM.IDPROCESS) WHERE GNASSOC.CDACCESSROLEFIELD IN (501) GROUP BY PERM.USERCD, PERM.IDPROCESS) PERMISSION ON PERMISSION.IDPROCESS=AUXWFP.IDOBJECT WHERE AUXWFP.FGSTATUS <= 5
AND (AUXWFP.FGMODELWFSECURITY IS NULL OR AUXWFP.FGMODELWFSECURITY=0)
UNION ALL
SELECT T.IDOBJECT FROM (SELECT MIN(PERM99.FGPERMISSION) AS FGPERMISSION, PERM99.IDOBJECT FROM (SELECT WFP.IDOBJECT, PERM1.FGPERMISSION FROM (SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADTEAMUSER TM ON PP.CDTEAM=TM.CDTEAM WHERE PP.FGACCESSTYPE=1
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PP.FGACCESSTYPE=2
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON (PP.CDDEPARTMENT=UDP.CDDEPARTMENT AND PP.CDPOSITION=UDP.CDPOSITION) WHERE PP.FGACCESSTYPE=3
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERDEPTPOS UDP ON PP.CDPOSITION=UDP.CDPOSITION WHERE PP.FGACCESSTYPE=4
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, PP.CDUSER AS USERCD FROM PMPROCACCESSLIST PP WHERE PP.FGACCESSTYPE=5
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, US.CDUSER AS USERCD FROM PMPROCACCESSLIST PP CROSS JOIN ADUSER US WHERE PP.FGACCESSTYPE=6
UNION ALL
SELECT PP.FGPERMISSION, PP.CDPROC, PP.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN ADUSERROLE RL ON RL.CDROLE=PP.CDROLE WHERE PP.FGACCESSTYPE=7
) PERM1 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PERM1.CDPROC WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL) AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PERM2.IDOBJECT, PERM2.FGPERMISSION FROM (SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, WFP.CDUSERSTART AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC WHERE PP.FGACCESSTYPE=30
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5
UNION ALL
SELECT PP.FGPERMISSION, WFP.IDOBJECT, PP.CDPROC, PP.CDACCESSLIST, US.CDLEADER AS USERCD FROM PMPROCACCESSLIST PP INNER JOIN WFPROCESS WFP ON WFP.CDPROCESSMODEL=PP.CDPROC INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PP.FGACCESSTYPE=31
AND WFP.FGMODELWFSECURITY=1 AND WFP.FGSTATUS <= 5) PERM2 INNER JOIN PMPROCSECURITYCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDPROC=GNASSOC.CDPROC) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACTIVITY OBJ ON GNASSOC.CDPROC=OBJ.CDACTIVITY WHERE GNCTRL.CDRELATEDFIELD IN (501) AND (OBJ.FGUSETYPEACCESS=0 OR OBJ.FGUSETYPEACCESS IS NULL)) PERM99 WHERE 1=1 GROUP BY PERM99.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT T.IDOBJECT FROM (SELECT PERM.IDOBJECT, MIN(PERM.FGPERMISSION) AS FGPERMISSION FROM (SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM1.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, TM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADTEAMUSER TM ON PM.CDTEAM=TM.CDTEAM WHERE PM.FGACCESSTYPE=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT WHERE PM.FGACCESSTYPE=2
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDDEPARTMENT=UDP.CDDEPARTMENT AND PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=3
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, UDP.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERDEPTPOS UDP ON PM.CDPOSITION=UDP.CDPOSITION WHERE PM.FGACCESSTYPE=4
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PM.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM WHERE PM.FGACCESSTYPE=5
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM CROSS JOIN ADUSER US WHERE PM.FGACCESSTYPE=6
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, RL.CDUSER AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN ADUSERROLE RL ON RL.CDROLE=PM.CDROLE WHERE PM.FGACCESSTYPE=7
) PERM1 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM1.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM1.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM1.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT WFP.IDOBJECT, PMA.FGUSETYPEACCESS, PERM2.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, PMA.CDCREATEDBY AS USERCD FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE WHERE PM.FGACCESSTYPE=8
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT WHERE PM.FGACCESSTYPE=9
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON (DEP2.CDDEPARTMENT=DEP1.CDDEPARTMENT AND DEP2.CDPOSITION=DEP1.CDPOSITION) WHERE PM.FGACCESSTYPE=10
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, DEP2.CDUSER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSERDEPTPOS DEP1 ON DEP1.CDUSER=PMA.CDCREATEDBY INNER JOIN ADUSERDEPTPOS DEP2 ON DEP2.CDPOSITION=DEP1.CDPOSITION WHERE PM.FGACCESSTYPE=11
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN ADUSER US ON US.CDUSER=PMA.CDCREATEDBY WHERE PM.FGACCESSTYPE=12
) PERM2 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM2.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM2.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM2.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND WFP.FGSTATUS <= 5 AND PMA.FGUSETYPEACCESS=1 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PERM3.IDOBJECT, PMA.FGUSETYPEACCESS, PERM3.FGPERMISSION FROM (SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, WFP.CDUSERSTART AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL WHERE PM.FGACCESSTYPE=30
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1
UNION ALL
SELECT PM.FGPERMISSION, PM.CDACTTYPE, PM.CDACCESSLIST, US.CDLEADER AS USERCD, WFP.IDOBJECT FROM PMACTTYPESECURLIST PM INNER JOIN PMACTIVITY PMA ON PM.CDACTTYPE=PMA.CDACTTYPE INNER JOIN WFPROCESS WFP ON PMA.CDACTIVITY=WFP.CDPROCESSMODEL INNER JOIN ADUSER US ON US.CDUSER=WFP.CDUSERSTART WHERE PM.FGACCESSTYPE=31
AND WFP.FGSTATUS <= 5 AND WFP.FGMODELWFSECURITY=1) PERM3 INNER JOIN PMACTTYPESECURCTRL GNASSOC ON (PERM3.CDACCESSLIST=GNASSOC.CDACCESSLIST AND PERM3.CDACTTYPE=GNASSOC.CDACTTYPE) INNER JOIN PMACCESSROLEFIELD GNCTRL ON GNASSOC.CDACCESSROLEFIELD=GNCTRL.CDACCESSROLEFIELD INNER JOIN PMACCESSROLEFIELD GNCTRL_F ON GNCTRL.CDRELATEDFIELD=GNCTRL_F.CDACCESSROLEFIELD INNER JOIN PMACTIVITY PMA ON PERM3.CDACTTYPE=PMA.CDACTTYPE WHERE GNCTRL_F.CDRELATEDFIELD IN (501) AND PMA.FGUSETYPEACCESS=1) PERM GROUP BY PERM.IDOBJECT) T WHERE 1 = 1
UNION ALL
SELECT AUXWFP.IDOBJECT FROM WFPROCESS AUXWFP INNER JOIN WFPROCSECURITYLIST WFLIST ON (AUXWFP.IDOBJECT=WFLIST.IDPROCESS) INNER JOIN WFPROCSECURITYCTRL WFCTRL ON (WFLIST.CDACCESSLIST=WFCTRL.CDACCESSLIST AND WFLIST.IDPROCESS=WFCTRL.IDPROCESS) WHERE WFCTRL.CDACCESSROLEFIELD IN (501)
AND WFLIST.FGACCESSTYPE=5 AND WFLIST.FGACCESSEXCEPTION=1
AND AUXWFP.FGSTATUS <= 5) Z) MYPERM ON (WFP.IDOBJECT=MYPERM.IDOBJECT) WHERE WFP.CDPRODAUTOMATION=202
UNION ALL
SELECT GNTS.CDISOSYSTEM, GNTS.CDTIMESHEET, GNR.IDRESOURCE, GNR.NMRESOURCE, GNR.CDRESOURCE, '' AS IDTYPE, -1 AS TYPEDATA, 0 AS PLANEJADO, GNTS.DTACTUAL, GNTS.CDUSER, GNR.CDUSER AS RESOURCEUSER, GNTS.FGSTATUS, GNTS.QTSTRAIGHTMIN, GNTS.QTOVERMIN, GNTS.TMSTRAIGHTHOURS, GNTS.TMOVERHOURS, GNTS.QTTOTALMIN, 2 AS CHARGE, ADDP.IDDEPARTMENT + ' - ' + ADDP.NMDEPARTMENT AS DEPARTMENT, ADP.IDPOSITION + ' - ' + ADP.NMPOSITION AS POSITION, ADUDP.CDDEPARTMENT, ADUDP.CDPOSITION, GNA.CDGENACTIVITY AS CDACTIVITY, TSW.NMPREFIX + '-' + CAST(TST.NRTASK AS VARCHAR(255)) AS IDACTIVITY, TSW.CDWORKSPACE AS CDOBJECT, TSW.NMPREFIX AS IDOBJECT, TSW.NMWORKSPACE AS NMOBJECT, 14 AS FGACTIVITYTYPE, TST.NMTITLE AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, TST.CDTASK FROM GNACTIVITY GNA INNER JOIN WFPROCESS WFP ON (WFP.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN TSTASK TST ON (TST.IDOBJECT=WFP.IDOBJECT) INNER JOIN TSWORKSPACE TSW ON (TSW.CDWORKSPACE=TST.CDWORKSPACE) INNER JOIN TSFLOWSTEP TSFS ON (TSFS.CDFLOW=TST.CDFLOW AND TSFS.CDSTEP=TST.CDSTEP) LEFT JOIN TSSPRINT TSS ON (TSS.CDSPRINT=TST.CDSPRINT AND TSS.CDWORKSPACE=TST.CDWORKSPACE) INNER JOIN GNACTIVITYTSHEET GNATS ON (GNATS.CDGENACTIVITY=GNA.CDGENACTIVITY) INNER JOIN GNTIMESHEET GNTS ON (GNTS.CDTIMESHEET=GNATS.CDTIMESHEET) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=GNTS.CDRESOURCE) LEFT JOIN ADUSERDEPTPOS ADUDP ON (ADUDP.CDUSER=GNR.CDUSER AND ADUDP.FGDEFAULTDEPTPOS=1) LEFT JOIN ADDEPARTMENT ADDP ON (ADDP.CDDEPARTMENT=ADUDP.CDDEPARTMENT) LEFT JOIN ADPOSITION ADP ON (ADP.CDPOSITION=ADUDP.CDPOSITION) WHERE 1 = 1
UNION ALL
SELECT TIMESHEET.CDISOSYSTEM, TIMESHEET.CDTIMESHEET, GNR.IDRESOURCE AS IDRESOURCE, GNR.NMRESOURCE AS NMRESOURCE, GNR.CDRESOURCE, ATITYPE.IDTASKTYPE + ' - ' + ATITYPE.NMTASKTYPE AS IDTYPE, ATI.CDTASKTYPE AS TYPEDATA, 0 AS PLANEJADO, TIMESHEET.DTACTUAL, TIMESHEET.CDUSER, GNR.CDUSER AS RESOURCEUSER, TIMESHEET.FGSTATUS, TIMESHEET.QTSTRAIGHTMIN, TIMESHEET.QTOVERMIN, TIMESHEET.TMSTRAIGHTHOURS, TIMESHEET.TMOVERHOURS, TIMESHEET.QTTOTALMIN, CASE ATI.FGCHARGE WHEN 1 THEN 1 ELSE 2 END AS CHARGE, ADDPT.IDDEPARTMENT + ' - ' + ADDPT.NMDEPARTMENT AS DEPARTMENT, ADPOS.IDPOSITION + ' - ' + ADPOS.NMPOSITION AS POSITION, ADDP.CDDEPARTMENT, ADDP.CDPOSITION, ATI.CDTASK AS CDACTIVITY, ATI.NMIDTASK AS IDACTIVITY, ATI.CDTASK AS CDOBJECT, ATI.NMIDTASK AS IDOBJECT, ATI.NMTASK AS NMOBJECT, ATI.FGTASKTYPE AS FGACTIVITYTYPE, ATI.NMTASK AS NMACTIVITY, CAST(NULL AS VARCHAR(50)) AS IDOBJECTPROCESS, CAST(NULL AS NUMERIC(10)) AS CDTASK FROM GNTIMESHEET TIMESHEET INNER JOIN PRTASKTIMESHEET TASKTIME ON (TASKTIME.CDTIMESHEET=TIMESHEET.CDTIMESHEET) INNER JOIN PRTASK ATI ON (ATI.CDTASK=TASKTIME.CDTASK) LEFT JOIN (SELECT DISTINCT PVIEW.PR_CDTASK FROM (SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=1
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=2
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, UDP.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADUSERDEPTPOS UDP ON UDP.CDDEPARTMENT=ACCVIEW.CDDEPARTMENT AND UDP.CDPOSITION=ACCVIEW.CDPOSITION  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=3
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, ACCVIEW.CDUSER FROM PRTASKACCESS ACCVIEW  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=4
/*DONTREMOVE*/UNION ALL/*DONTREMOVE*/
SELECT ACCVIEW.CDTASK AS PR_CDTASK, ACCVIEW.FGACCESSCOST, TMM.CDUSER FROM PRTASKACCESS ACCVIEW INNER JOIN ADTEAMUSER TMM ON TMM.CDTEAM=ACCVIEW.CDTEAM  WHERE ACCVIEW.FGACCESS=1 AND ACCVIEW.FGTEAMMEMBER=5
) PVIEW WHERE 1=1) PRTASKSECURITY ON PRTASKSECURITY.PR_CDTASK=ATI.CDBASETASK AND ATI.FGRESTRICT=1 LEFT OUTER JOIN PRTASKTYPE ATITYPE ON (ATI.CDTASKTYPE=ATITYPE.CDTASKTYPE) INNER JOIN GNRESOURCEVIEW GNR ON (GNR.CDRESOURCE=TIMESHEET.CDRESOURCE) LEFT OUTER JOIN ADUSERDEPTPOS ADDP ON (GNR.CDUSER=ADDP.CDUSER AND ADDP.FGDEFAULTDEPTPOS=1) LEFT OUTER JOIN ADDEPARTMENT ADDPT ON (ADDP.CDDEPARTMENT=ADDPT.CDDEPARTMENT) LEFT OUTER JOIN ADPOSITION ADPOS ON (ADDP.CDPOSITION=ADPOS.CDPOSITION) WHERE ATI.FGTASKTYPE IN (2, 3) AND (( ATI.FGRESTRICT=2 OR ATI.FGRESTRICT IS NULL OR ATI.FGRESTRICT=0) OR (PRTASKSECURITY.PR_CDTASK IS NOT NULL))
)TIMESHEETVIEW, GNTIMESHEET GTS

LEFT JOIN ADUSER ADU ON (ADU.CDUSER=GTS.CDUSER), GNTIMEENTRY GTE

WHERE TIMESHEETVIEW.CDTIMESHEET=GTS.CDTIMESHEET AND GTE.CDTIMESHEET=TIMESHEETVIEW.CDTIMESHEET
--AND TIMESHEETVIEW.DTACTUAL >= '2020-11-01' AND TIMESHEETVIEW.DTACTUAL <= '2020-11-22' AND TIMESHEETVIEW.CDRESOURCE IN (257)


---------------------
--
-- Tipos de registro no histórico do processo
--
--------------------------------------------------------------------------------
CASE 
	WHEN HIS.FGTYPE =  1 THEN 'Processo iniciado'
    WHEN HIS.FGTYPE =  2 THEN 'Processo suspenso'
    WHEN HIS.FGTYPE =  3 THEN 'Processo cancelado'
    WHEN HIS.FGTYPE =  4 THEN 'Processo encerrado'
    WHEN HIS.FGTYPE =  5 THEN 'Processo reativado'
    WHEN HIS.FGTYPE =  6 THEN 'Atividade habilitada'
    WHEN HIS.FGTYPE =  7 THEN 'Atividade associada'
    WHEN HIS.FGTYPE =  8 THEN 'Atividade desassociada'
    WHEN HIS.FGTYPE =  9 THEN 'Ação executada'
    WHEN HIS.FGTYPE = 10 THEN 'Atividade delegada'
    WHEN HIS.FGTYPE = 11 THEN 'Comentário incluído'
    WHEN HIS.FGTYPE = 12 THEN 'Ação do gestor'
	WHEN HIS.FGTYPE = 14 THEN 'Evento de timer iniciado'
    WHEN HIS.FGTYPE = 15 THEN 'Evento de timer encerrado'
    WHEN HIS.FGTYPE = 16 THEN 'Atividade cancelada'
    WHEN HIS.FGTYPE = 17 THEN 'Processo retornado'
	WHEN HIS.FGTYPE = 18 THEN 'Atividade recusada'
    WHEN HIS.FGTYPE = 19 THEN 'Retorno aprovado'
	WHEN HIS.FGTYPE = 20 THEN 'Retorno reprovado'
	WHEN HIS.FGTYPE = 21 THEN 'Anexo incluído'
    WHEN HIS.FGTYPE = 22 THEN 'Anexo excluído'
	WHEN HIS.FGTYPE = 23 THEN 'Documento incluído'
	WHEN HIS.FGTYPE = 24 THEN 'Documento excluído'
	WHEN HIS.FGTYPE = 25 THEN 'Ocorrência incluída'
	WHEN HIS.FGTYPE = 26 THEN 'Ocorrência excluída'
	WHEN HIS.FGTYPE = 27 THEN 'Projeto incluído'
	WHEN HIS.FGTYPE = 28 THEN 'Projeto excluído'
	WHEN HIS.FGTYPE = 29 THEN 'Processo bloqueado para edição'
	WHEN HIS.FGTYPE = 30 THEN 'Processo desbloqueado'
	WHEN HIS.FGTYPE = 31 THEN 'Atividade executada automaticamente'
	WHEN HIS.FGTYPE = 32 THEN 'E-mail enviado'
	WHEN HIS.FGTYPE = 52 THEN 'Comentário Editado'
END AS FGTYPE_T

---------------------
-- Descrição: LAB CUBO 10 - Dados do processo LAB para CQ IN.
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2018
-- Atualizada em: 
--------------------------------------------------------------------------------
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
, (select distinct his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143141313' else 'Decisão17517143228556' end
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143141313' else 'Decisão17517143228556' end
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprfinal
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


---------------------
-- Descrição: Todos os dados relevantes do processo ACESSO GQ.
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2018
-- Atualizada em: 
--------------------------------------------------------------------------------
select case form.ac001 when 1 then 'Sistema Computadorizado' when 2 then 'Área com Acesso Controlado' end as tpacesso
, case form.ac002 when 1 then 'Criação' when 2 then 'Alteração' when 3 then 'Cancelamento' end as acao
, form.ac003 as nomesol, form.ac004 as matrsol, form.ac005 as areasol, form.ac006 as funcsol, form.ac007 as respnome
, coalesce(form.ac008,'N/A') as fabricante, form.ac011 as perini, form.ac012 as perfim, form.ac013 as resparea, form.ac014 as respfunc
, unid.ac001 as unidade, setor.ac001 as setor, sistem.ac001 as sist_area, perf.ac001 as perfil
, wf.NMUSERSTART as iniciador, wf.idprocess as identificador, wf.nmprocess as titulo, wf.dtstart as dataini
, (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão185281202031'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão185281202031'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as dtaprresp
, (SELECT HIS.NMUSER
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão185281202031'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão185281202031'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as nmaprresp
, (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1852812055258'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1852812055258'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as dtaprvsc
, (SELECT HIS.NMUSER
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1852812055258'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1852812055258'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as nmaprvsc
, (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1852812937774'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1852812937774'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as dtaprtec
, (SELECT HIS.NMUSER
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1852812937774'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1852812937774'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as nmaprtec
, (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade18528121519500'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade18528121519500'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as dtexec
, (SELECT HIS.NMUSER
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade18528121519500'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade18528121519500'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) as nmexec
, 1 as quantidade
from DYNuq054 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left join DYNuq055 unid on form.OIDABCP1SHXENT6DCC = unid.OID
left join DYNuq056 setor on form.OIDABC6H0IT6DIZ4ZT = setor.OID
left join DYNuq057 sistem on form.OIDABCZFX7ZHK25JAJ = sistem.OID
left join DYNuq058 perf on form.OIDABC9P284WPD60QM = perf.OID
where wf.cdprocessmodel=4209

---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário Funil de projetos.
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2016
-- Atualizada em: 02/2017
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, form.govprj004 as respPrj, dep.nmdepartment as depRespPrj, form.govprj007 as dtIniPla, form.govprj008 as dtFimPlan, form.govprj011 as valor, form.govprj012 as ROI
, case form.govprj024 when 1 then 'SOX' else 'Não SOX' end as sox
, case form.govprj025 when 1 then 'BPx' else 'Não BPx' end as BPx
, clas.clprj001 as classificacao, tpproj.tpprj001 as tipoProj
, (select max(GOVPRJ2004) from DYNgovprj2 where form.oid = OIDABCINfABCN1Y) as numReport
, (select top 1 GOVPRJ2001 from DYNgovprj2 where form.oid = OIDABCINfABCN1Y and GOVPRJ2001 in (select max(GOVPRJ2001) from DYNgovprj2 where form.oid = OIDABCINfABCN1Y) order by GOVPRJ2004) as dtReport
, (select top 1 case GOVPRJ2002 when 1 then 'Verde' when 2 then 'Amarelo' when 3 then 'Vermelho' end from DYNgovprj2 where form.oid = OIDABCINfABCN1Y and GOVPRJ2001 in (select max(GOVPRJ2001) from DYNgovprj2 where form.oid = OIDABCINfABCN1Y) order by GOVPRJ2004) as StatusReport
, (select max(GOVPRJ1004) from DYNgovprj1 where form.oid = OIDABCvoLABCFR6) as numAval
, (select top 1 GOVPRJ1001 from DYNgovprj1 where form.oid = OIDABCvoLABCFR6 and GOVPRJ1001 in (select max(GOVPRJ1001) from DYNgovprj1 where form.oid = OIDABCvoLABCFR6) order by GOVPRJ1004) as dtAval
, (select top 1 case GOVPRJ1002 when 1 then 'Verde' when 2 then 'Amarelo' when 3 then 'Vermelho' end from DYNgovprj1 where form.oid = OIDABCvoLABCFR6 and GOVPRJ1001 in (select max(GOVPRJ1001) from DYNgovprj1 where form.oid = OIDABCvoLABCFR6) order by GOVPRJ1004) as StatusAval
, (select struc.nmstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2) as nmatvatual
, (select format(struc.dtenabled,'dd/MM/yyyy') from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2) as dtiniatvatual
, (select format(struc.dtestimatedfinish,'dd/MM/yyyy') from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2) as przatvatual
, (select executor from (SELECT case when HIS.NMUSER is null then HIS.nmrole else HIS.NMUSER end as executor
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  his1.idprocess = wf.idobject
)) his) as executatvatual
, case when (select cdleader from aduser where nmuser = form.govprj004) in (1175, 4, 954, 4296) or form.govprj004 = 'Guilhermo Cintra Fragelli' then 'Sistemas'
       when (select cdleader from aduser where nmuser = form.govprj004) in (672, 1681) or form.govprj004 = 'Alexandre Correa Lima' then 'Infraestrutura'
       else 'Não TI'
end as setorTI
, 1 as quantidade
from DYNgovprj form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left join aduser usr on usr.nmuser = form.govprj004
left join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
left join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNclprj clas on form.OIDABCcIrABCkYi = clas.oid
left join DYNtpprj tpproj on form.OIDABCz89ABCjeR = tpproj.oid
where wf.cdprocessmodel=1316

---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário DHO.
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2016
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, form.*
, 1 as quantidade
from DYNrhcp1 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where wf.cdprocessmodel=86

---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário OOS.
--            Requisitos: 01 - 13
--            As linhas comentadas (--prod--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaprod--).
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tbs004,'dd/MM/yyyy') as dtdeteccao, datepart(yyyy,form.tbs004) as dtdeteccao_ano, datepart(MM,form.tbs004) as dtdeteccao_mes
, format(form.tbs005,'dd/MM/yyyy') as dtocorrencia, datepart(yyyy,form.tbs005) as dtocorrencia_ano, datepart(MM,form.tbs005) as dtocorrencia_mes
, format(form.tbs006,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tbs006) as dtlimite_ano, datepart(MM,form.tbs006) as dtlimite_mes
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
, form.tbs002 as respanalisen1, 'NA' as respanalisen2, form.tbs037 as respinvestiga, 'NA' as metodo, 'NA' as idamostra, 'NA' as descteste, 'NA' as especific
, catraiz.tbs007 as catcausaraiz, catev.tbs001 as tipo, laboc.tbs001 as laboratorio, unid.tbs001 as unidade
, coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs012 where OIDABCVdbABCyvW = form.oid FOR XML PATH('')), 4, 4000)), 'NA') as prodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895352873'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895352873'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn1
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1410289542484'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1410289542484'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn2
, case coalesce((select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), -1) when 1 then 'Aberta no prazo' when 2 then 'Aberta em atraso' else 'NA' end as abertura
, (select format(his.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmissao
, case when (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão14102895442364' or str1.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff (dd, form.tbs004, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão14102895442364' or str1.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end as conclusao
, (select distinct format(his.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão14102895442364' or str1.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtencerrada
--prod--, prod.tbs003 as codprod, prod.tbs002 as descprod, prod.tbs004 as lotes
--placao--, gnactp.idactivity as idplano
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
--prod--left join DYNtbs012 prod on form.oid = prod.OIDABCVdbABCyvW
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
where wf.cdprocessmodel=38
union
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tds001,'dd/MM/yyyy') as dtdeteccao, datepart(yyyy,form.tds001) as dtdeteccao_ano, datepart(MM,form.tds001) as dtdeteccao_mes
, format(form.tds002,'dd/MM/yyyy') as dtocorrencia, datepart(yyyy,form.tds002) as dtocorrencia_ano, datepart(MM,form.tds002) as dtocorrencia_mes
, format(form.tds003,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tds003) as dtlimite_ano, datepart(MM,form.tds003) as dtlimite_mes
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
, case gnrev.NMREVISIONSTATUS when 'Encerrado' then coalesce ((select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141028103225870'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141028103225870'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his),'Eficaz') else '' end as eficaia
, form.tds004 as respanalisen1, form.tds047 as respanalisen2, form.tds005 as respinvestiga, form.tds009 as metodo, form.tds010 as idamostra, form.tds011 as descteste, form.tds012 as especific
, catraiz.tbs007 as catcausaraiz, catev.tbs001 as tipo, laboc.tbs001 as laboratorio, unid.tbs001 as unidade
, coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs012 where OIDABCZnQABCmWp = form.oid FOR XML PATH('')), 4, 4000)), 'NA') as prodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895352873'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895352873'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn1
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1410289542484'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1410289542484'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn2
, case coalesce((select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), -1) when 1 then 'Aberta no prazo' when 2 then 'Aberta em atraso' else 'NA' end as abertura
, (select format(his.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmissao
, case when (wf.dtstart > '2017-12-04') then case when form.tds016 = 'SST' or form.tds016 = 'OAL' then 
case when (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão17517143141313'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão17517143141313'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff (dd, form.tds001, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão17517143141313'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão17517143141313'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end
                                    else
case when (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão17517143228556'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão17517143228556'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff (dd, form.tds001, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão17517143228556'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão17517143228556'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end
end else
case when (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff (dd, form.tds001, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end end as conclusao
, case when (wf.dtstart > '2017-12-04') then case when form.tds016 = 'SST' or form.tds016 = 'OAL' then 
(select distinct format(his.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão17517143141313')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão17517143141313')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)
                                    else
(select distinct format(his.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão17517143228556')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão17517143228556')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)
end else
(select distinct format(his.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão14102895442364' or str1.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) end as dtencerrada
--prod--, prod.tbs003 as codprod, prod.tbs002 as descprod, prod.tbs004 as lotes
--placao--, gnactp.idactivity as idplano
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
--prod--left join DYNtbs012 prod on form.oid = prod.OIDABCZnQABCmWp
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
where wf.cdprocessmodel=38
/*
, case (select dadosatv.FGCONCLUDEDSTATUS from (select top 1 HIS.DTHISTORY, HIS.TMHISTORY, QTDURATION,QTHOURS,FGEXECACTIVITY,str.idSTRUCT, str.NMSTRUCT, str.FGCONCLUDEDSTATUS, HIS.NMUSER, HIS.NMACTION, wfa.NMEXECUTEDACTION, his.idprocess
from WFHISTORY HIS
inner join WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT
inner JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and FGEXECACTIVITY is not null
order by HIS.DTHISTORY desc, HIS.TMHISTORY desc
) dadosatv) when 1 then 'Em dia' when 2 then 'Em atraso' end as exeprazo
*/


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário de Desvio
--            Separado 1 linha para cada produto/lote.
-- 
-- 
-- 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 05/2016
-- Atualizada em: -
--------------------------------------------------------------------------------
select * from (Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, 'NA' as repqualidade, dispfin.tbs009 as disposfinalgeral
, prod.tbs001 as dispfinal
, prod.tbs003 as codprod, prod.tbs002 as descprod, prod.tbs004 as lotes
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity + ' - ' + CASE
                     WHEN gnactp.NRTASKSEQ = 1 THEN 'Alta prioridade'
                     WHEN gnactp.NRTASKSEQ = 2 THEN 'Média prioridade'
                     WHEN gnactp.NRTASKSEQ = 3 THEN 'Baixa prioridade'
                     ELSE ''
                 END as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, 1 as quantidade
from DYNtbs010 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs012 prod on form.oid = prod.OIDABCBZmABCZOW
left join DYNtbs009 dispfin on dispfin.oid = form.OIDABCInNABCCBb
where wf.cdprocessmodel=17
union
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, form.tds071 as repqualidade
, dispfin.tbs009 as disposfinalgeral
, prod.tbs001 as dispfinal
, prod.tbs003 as codprod, prod.tbs002 as descprod, prod.tbs004 as lotes
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity + ' - ' + CASE
                     WHEN gnactp.NRTASKSEQ = 1 THEN 'Alta prioridade'
                     WHEN gnactp.NRTASKSEQ = 2 THEN 'Média prioridade'
                     WHEN gnactp.NRTASKSEQ = 3 THEN 'Baixa prioridade'
                     ELSE ''
                 END as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, 1 as quantidade
from DYNtds010 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs012 prod on form.oid = prod.OIDABCr58ABCzha
left join DYNtbs009 dispfin on dispfin.oid = form.OIDABCjBjABCGzr
where wf.cdprocessmodel=17) sub


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário de Desvio.
--            Requisitos: 01 - 16
--            As 4 linhas comentadas (--prod--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaprod--).
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
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
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tbs012,'dd/MM/yyyy') as dtdeteccao, datepart(yyyy,form.tbs012) as dtdeteccao_ano, datepart(MM,form.tbs012) as dtdeteccao_mes
, format(form.tbs013,'dd/MM/yyyy') as dtocorrencia, datepart(yyyy,form.tbs013) as dtocorrencia_ano, datepart(MM,form.tbs013) as dtocorrencia_mes
, format(form.tbs014,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tbs014) as dtlimite_ano, datepart(MM,form.tbs014) as dtlimite_mes
, form.tbs017 as nometerceiro, form.tbs039 as loteterceiro, form.tbs057 as justrelprod
, case when form.tbs012 is not null then datediff(dd, cast(format(form.tbs012,'yyyy/MM/dd') as date), cast(format(wf.dtstart,'yyyy/MM/dd') as date)) else -1 end as tempabertura
, case when case when (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff(dd,cast(format(form.tbs012,'yyyy/MM/dd') as date),(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else datediff(dd,cast(format(form.tbs012,'yyyy/MM/dd') as date), getdate()) end > 25 then 'Em atraso' else 'Em dia' end as prazoproc
, case when case when (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff(dd,cast(format(form.tbs012,'yyyy/MM/dd') as date),(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else datediff(dd,cast(format(form.tbs012,'yyyy/MM/dd') as date), getdate()) end > 3 then 'Em atraso' else 'Em dia' end as prazoabertura
, case when (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff(dd,cast(format(form.tbs012,'yyyy/MM/dd') as date),(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end as tempoaprovinicial
, case when (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff(dd,cast(format(form.tbs012,'yyyy/MM/dd') as date),(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end as tempoaprovfinal
, case when (case when (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff(dd,cast(format(form.tbs012,'yyyy/MM/dd') as date),(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end) > 30 then 'Em atraso' else 'Em dia' end as tempoaprovfinalc
, case when (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null and (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff(dd,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), (select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end as tempototinvestiga
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
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovinicial
, (select datepart(yyyy,HIS.DTHISTORY) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovinicial_ano
, (select datepart(MM,HIS.DTHISTORY) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovinicial_mes
, (select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovinicial
, datediff(dd,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject and his1.nmaction = 'Rejeitar'
) and his.nmaction = 'Rejeitar') his),(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject and his1.nmaction = 'Aprovar'
) and his.nmaction = 'Aprovar') his)) as ciclorejinicial
, (select count(his.nmaction) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject) his where his.nmaction = 'Rejeitar') as regaprovinicial
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovfinal
, (select datepart(yyyy,HIS.DTHISTORY) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovfinal_ano
, (select datepart(MM,HIS.DTHISTORY) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovfinal_mes
, datediff(dd,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject and his1.nmaction = 'Rejeitar'
) and his.nmaction = 'Rejeitar') his),(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject and his1.nmaction = 'Aprovar'
) and his.nmaction = 'Aprovar') his)) as ciclorejinfinal
, (select count(his.nmaction) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject) his where his.nmaction = 'Rejeitar') as regaprovfinal
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141027113051875'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141027113051875'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmeteregistro
, coalesce((select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141027113146417'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141027113146417'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), form.tbs044) as investigador
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141027113146417'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141027113146417'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtinvestigador
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113659651'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141027113659651'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtareaacorr
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1571615355993'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1571615355993'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtpuverde
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153513122'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153513122'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtpuamarela
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153516481'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153516481'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtcqfisicoquim
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153519931'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153519931'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtcqmicrobio
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153521833'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153521833'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtcqmatemb
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153523510'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153523510'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dthse
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153525165'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153525165'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtfiscal
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153526920'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153526920'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtestab
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153529862'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153529862'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtplanej
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153531348'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153531348'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtdeposit
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153533198'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153533198'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dteng
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1571615353578'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1571615353578'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtped
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1571615353895'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1571615353895'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtvalmetana
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153540364'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153540364'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtvalida
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153542651'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153542651'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtti
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153554750'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153554750'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtbpf
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão15716153557102'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão15716153557102'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'NA') as dtsgq
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
union all
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
, case gnrev.NMREVISIONSTATUS when 'Encerrado' then coalesce((select nmuser from (SELECT top 1 max(HIS.TMHISTORY) as maxtime, his.NMUSER
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113926692' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY, his.TMHISTORY, his.NMUSER
order by his.TMHISTORY DESC) _sub),'Eficaz') else 'NA' end as eficacia
, case form.tds052 when 1 then 'Sim' when 2 then 'Não' end recorrente
, case form.tds006 when 0 then 'Não' when 1 then 'Sim' end provterceiro
, case form.tds042 when 0 then 'Não' when 1 then 'Sim' end aguardapl
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tds001,'dd/MM/yyyy') as dtdeteccao, datepart(yyyy,form.tds001) as dtdeteccao_ano, datepart(MM,form.tds001) as dtdeteccao_mes
, format(form.tds002,'dd/MM/yyyy') as dtocorrencia, datepart(yyyy,form.tds002) as dtocorrencia_ano, datepart(MM,form.tds002) as dtocorrencia_mes
, format(form.tds003,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tds003) as dtlimite_ano, datepart(MM,form.tds003) as dtlimite_mes
, form.tds007 as nometerceiro, form.tds008 as loteterceiro, form.tds010 as justrelprod
, case when form.tds001 is not null then datediff(dd, cast(format(form.tds001,'yyyy/MM/dd') as date), cast(format(wf.dtstart,'yyyy/MM/dd') as date)) else -1 end as tempabertura
, case when case when (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) is not null then datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date),(select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub)) else datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date), getdate()) end > 25 then 'Em atraso' else 'Em dia' end as prazoproc
, case when case when (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) is not null then datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date),(select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub)) else datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date), getdate()) end > 3 then 'Em atraso' else 'Em dia' end as prazoabertura
, case when (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) is not null then datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date),(select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub)) else -1 end as tempoaprovinicial
, case when (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) is not null then datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date),(select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub)) else -1 end as tempoaprovfinal
, case when(case when (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) is not null then datediff(dd,cast(format(form.tds001,'yyyy/MM/dd') as date),(select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub)) else -1 end) > 30 then 'Em atraso' else 'Em dia' end as tempoaprovfinalc
, case when (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) is not null and (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) is not null then datediff(dd,(select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub), (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub)) else -1 end as tempototinvestiga
, case (select FGCONCLUDEDSTATUS from (SELECT top 1 max(HIS.TMHISTORY) as maxtime, str.FGCONCLUDEDSTATUS
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Atividade1571413144783' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY, his.TMHISTORY, str.FGCONCLUDEDSTATUS
order by his.TMHISTORY DESC) _sub) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoanaliscli
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
, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113057548' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) as dtaprovinicial
, coalesce((select nmuser from (SELECT top 1 max(HIS.TMHISTORY) as maxtime, his.NMUSER
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Atividade141027113146417' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY, his.TMHISTORY, his.NMUSER
order by his.TMHISTORY DESC) _sub), form.tds004) as investigador
, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Atividade141027113146417' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) as dtinvestigador
, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão15716153513122' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) as dtpuamarela
, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão15716153516481' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) as dtcqfisicoquim
, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão15716153519931' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) as dtcqmicrobio
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

---------------------
-- Descrição: Todos os dados relevantes para análise do Plano de Ação.
--
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
select CAST(gntype.IDGENTYPE + CASE WHEN gntype.IDGENTYPE IS NULL THEN NULL ELSE ' - ' END + gntype.NMGENTYPE AS VARCHAR(510)) AS tipoplano
, plano.idactivity as idPlano, plano.nmactivity as nmPlano
, CAST(GNGNTP.IDGENTYPE + CASE WHEN GNGNTP.IDGENTYPE IS NULL THEN NULL ELSE ' - ' END + GNGNTP.NMGENTYPE AS VARCHAR(510)) AS tipoatividade
, atv.idactivity as idAtividade
, (select nmuser from aduser where cduser=plano.CDUSEr) as planejador
--, (select dep.nmdepartment from addepartment dep inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment where rel.cduser=plano.CDUSEr) as area_planejador
, (select nmuser from aduser where cduser=plano.CDUSERACTIVRESP) as resp_plano
--, (select dep.nmdepartment from addepartment dep inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment where rel.cduser=plano.CDUSERACTIVRESP) as area_resp_plano
, (select nmuser from aduser where cduser=atv.cduser) as executor
, (select dep.nmdepartment from addepartment dep inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment where rel.cduser=atv.cduser and rel.FGDEFAULTDEPTPOS =1) as area_executor
, atv.nmactivity as nomeAtividade, atv.VLPERCENTAGEM as porcentagem
, CEILING(atv.qtminutesplan/1440) as diasplan, CEILING(atv.qtminutesreal/1440) as diasreal
, CASE
    WHEN plano.NRTASKSEQ = 1 THEN '1 - Alta prioridade'
    WHEN plano.NRTASKSEQ = 2 THEN '3 - Média prioridade'
    WHEN plano.NRTASKSEQ = 3 THEN '5 - Baixa prioridade'
    ELSE ''
END NMPRIORITY
, case atv.fgstatus
     when  1 then 'Em planejamento'
     when  2 then 'Em aprovavação do planejamento'
     when  3 then 'Em execução'
     when  4 then 'Em aprovação da execução'
     when  5 then 'Encerrada'
     when  7 then 'Cancelada'
     when  9 then 'Cancelada'
     when 10 then 'Cancelada'
     when 11 then 'Cancelada'
end as Status
, format(atv.dtstartplan,'dd/MM/yyyy') as dtiniciopl, datepart(yyyy,atv.dtstartplan) as dtiniciopl_ano, datepart(MM,atv.dtstartplan) as dtiniciopl_mes
, format(atv.dtfinishplan,'dd/MM/yyyy') as dtfimpl, datepart(yyyy,atv.dtfinishplan) as dtfimpl_ano, datepart(MM,atv.dtfinishplan) as dtfimpl_mes
, format(atv.dtstart,'dd/MM/yyyy') as dtinicioreal, datepart(yyyy,atv.dtstart) as dtinicioreal_ano, datepart(MM,atv.dtstart) as dtinicioreal_mes
, format(atv.dtfinish,'dd/MM/yyyy') as dtfimreal, datepart(yyyy,atv.dtfinish) as dtfimreal_ano, datepart(MM,atv.dtfinish) as dtfimreal_mes
, format(actpl.dtinsert,'dd/MM/yyyy') as dtcriaplano, datepart(yyyy,actpl.dtinsert) as dtcriaplano_ano, datepart(MM,actpl.dtinsert) as dtcriaplano_mes
, format(aprov.dtapprov,'dd/MM/yyyy') as dataaprova, datepart(yyyy,aprov.dtapprov) as dataaprova_ano, datepart(MM,aprov.dtapprov) as dataaprova_mes
, case when aprov.dtapprov is null or atv.DTFINISH is null then null
    else datediff(DD,atv.DTFINISH,aprov.dtapprov)
end as tempoAprova
, format((select DTFINISH from gnactivity where cdgenactivity = atv.cdgenactivity), 'dd/MM/yyyy') as dtrecebeu_paraaprovar
, format((select coalesce (dtfinish,dtfinishplan)+qtduetime from gnactivity where cdgenactivity = atv.cdgenactivity), 'dd/MM/yyyy') as dtprevaprov
, (aprov.cdcycle - 1) as qtdRejeitado
, case 
    when atv.DTFINISH is null and atv.dtfinishplan <= getdate() then 'Atrasado'
    when atv.DTFINISH is null and atv.dtfinishplan > getdate() then 'Em dia'
    when atv.DTFINISH is not null and atv.dtfinishplan < atv.dtfinish then 'Atrasado'
    when atv.DTFINISH is not null and atv.dtfinishplan >= atv.dtfinish then 'Em dia'
end as PrazoAtividade
, case 
    when plano.DTFINISH is null and plano.dtfinishplan > getdate() then 'Atrasado'
    when plano.DTFINISH is null and plano.dtfinishplan <= getdate() then 'Em dia'
    when plano.DTFINISH is not null and plano.dtfinishplan < plano.dtfinish then 'Atrasado'
    when plano.DTFINISH is not null and plano.dtfinishplan >= plano.dtfinish then 'Em dia'
end as PrazoPlano
, case when aprov.fgapprov = 1 then 'Aprovou a atividade' when aprov.fgapprov = 2 then 'Reprovou a atividade' end as aprovacao
, case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, nmuser)) when aprov.cdteam is not null then (select nmteam from adteam where cdteam = aprov.cdteam) end as aprovador
--, aprov.dsobs
, 1 as quantidade
--, iduseraprov, aprov.cdapprov, atv.cdgenactivity, actpl.cdactionplan, aprov.qtduetime
from gnactivity atv
INNER JOIN GNTASK GNTK ON (ATV.CDGENACTIVITY = GNTK.CDGENACTIVITY)
LEFT OUTER JOIN GNTASKTYPE GNTKTP ON (GNTKTP.CDTASKTYPE = GNTK.CDTASKTYPE)
LEFT OUTER JOIN GNGENTYPE GNGNTP ON (GNGNTP.CDGENTYPE = GNTKTP.CDTASKTYPE)
inner join gnactivity plano on plano.cdgenactivity = atv.cdactivityowner
left join GNEVALRESULTUSED cdresult on cdresult.CDEVALRESULTUSED = atv.CDEVALRSLTPRIORITY
inner join gnactionplan actpl on atv.cdactivityowner = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
left join gnvwapprovresp aprov on aprov.cdapprov = atv.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
      and cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
left join (select max(cdcycle) as maxcycle, cdapprov from gnvwapprovresp group by cdapprov) max_cycle
         on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where atv.CDISOSYSTEM in (174,160,202) and atv.cdactivityowner is not null and gntype.IDGENTYPE like 'AN-%'
--and (atv.dtfinishplan > '2016/01/01' or atv.dtfinish > '2016/01/01' or aprov.dtapprov > '2016/01/01')
order by tipoplano, plano.idactivity, atv.idactivity, atv.fgstatus, aprov.dtapprov, aprov.nmuserapprov


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário CM.
--            01, 02, 03, 04, 05, 07, 08, 09, 10, 13, 15, 17, 19, 20, 21, 22, 23, 25, 26, 35, 36, 37, 38, 39, 40, 41.
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, form.tbs009 as nmterceiro, form.tbs033 as nmaprovaremud
, case form.tbs030 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, 'NA' as mbr
, 'NA' as tpmbr
, 'NA' as info1lote
, case when form.tbs011 = 1 then '' else format(form.tbs012,'dd/MM/yyyy') end as dtinitemp
, case when form.tbs011 = 1 then '' else format(form.tbs013,'dd/MM/yyyy') end as dtfimtemp
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
, coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCFCIABCMH0 = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaprodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
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
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABC1pFABCwh3 = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listaclientes --listaclientes--
, 'NA' as listaregulatórios
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs019 where OIDABCJonABCFKa = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listamudanca --listamudanca--
, 'NA' as areasaval
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmis
, (select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprov
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprov
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
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtencerrou
, datepart(yyyy,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtencerrou_ano
, datepart(MM,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtencerrou_mes
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmencerrou
, case when gnrev.NMREVISIONSTATUS = 'Cancelado' then case (SELECT WFA.FGAUTOEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and WFA.NMEXECUTEDACTION = 'Cancelar' and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and WFA.NMEXECUTEDACTION = 'Cancelar' and his1.idprocess = wf.idobject
)) when 1 then 'Automático na primeira atividade' when 2 then 'Não Automático na primeira atividade' else 'Por solicitação' end
end Cancelamento
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi,(SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)),(SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(mi,(SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tpsegaprov
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(dd, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tppriaprov
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(dd, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tpcriaplacao
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(dd, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tpaguardacli
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtlibera
, datepart(yyyy,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) ) as dtlibera_ano
, datepart(MM,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) ) as dtlibera_mes
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmlibera
, datediff(dd, (select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914347264')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914347264')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), (select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as tempoaceita
, (select count(*) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and HIS.NMACTION = 'Submeter' and his.idprocess = wf.idobject) his) as qtdciclos
, 1 as Quantidade
from DYNtbs015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs039 areamud on areamud.oid = form.OIDABCQueABCNDM
left join DYNtbs039 areaini on areaini.oid = form.OIDABC3a2ABCLSW
left join DYNtbs001 unid on unid.oid = form.OIDABCTYWABCE9z
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where cdprocessmodel=1
union
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, form.tds002 as nmterceiro, form.tds017 as nmaprovaremud
, case form.tds016 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, case form.tds107 when 1 then 'Sim' when 2 then 'Não' end as mbr
, case form.tds108 when 1 then 'Melhoria' when 2 then 'Atualização obrigatória' end as tpmbr
, case form.tds109 when 1 then 'Sim' when 2 then 'Não' end as info1lote
, case when form.tds004 = 1 then '' else format(form.tds005,'dd/MM/yyyy') end as dtinitemp
, case when form.tds004 = 1 then '' else format(form.tds006,'dd/MM/yyyy') end as dtfimtemp
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
, coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCIQeABC45y = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaprodlote --listaprod--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
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
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABCtTKABCkFM = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listaclientes --listaclientes--
, coalesce((select substring((select ' | '+ tds001 +' - '+ tds002 +' - '+ format(tds003,'dd/MM/yyyy') as [text()] from DYNtds043 where OIDABC8eEABCZHc = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listaregulatórios --listaregulatórios--
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),8,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds067,tds068,tds069,tds070,tds071,tds072,tds073,tds074,tds075,tds076,tds077,tds078,tds079,tds080,tds081,tds082,tds083,tds084,tds085,tds086,tds087,tds088,tds089,tds090,tds091,tds092,tds093,tds094,tds095,tds096,tds097,tds098,tds099,tds100,tds101,tds102,tds103)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as areasaval
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmis
, (select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprov
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprov
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
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtencerrou
, datepart(yyyy,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtencerrou_ano
, datepart(MM,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtencerrou_mes
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914543984'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmencerrou
, case when gnrev.NMREVISIONSTATUS = 'Cancelado' then case (SELECT WFA.FGAUTOEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and WFA.NMEXECUTEDACTION = 'Cancelar' and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and WFA.NMEXECUTEDACTION = 'Cancelar' and his1.idprocess = wf.idobject
)) when 1 then 'Automático na primeira atividade' when 2 then 'Não Automático na primeira atividade' else 'Por solicitação' end
end Cancelamento
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(dd, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tpsegaprov
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(dd, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tppriaprov
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(dd, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102914459502'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tpcriaplacao
, case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(mi, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)))/1440 else
datediff(dd, (SELECT (cast(wfa.dtstart as datetime) + cast(wfa.tmstart as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141111113134390'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate())/1440 end tpaguardacli
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtlibera
, datepart(yyyy,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) ) as dtlibera_ano
, datepart(MM,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) ) as dtlibera_mes
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmlibera
, datediff(dd, (select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914347264')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914347264')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), (select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828', 'Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as tempoaceita
, (select count(*) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and HIS.NMACTION = 'Submeter' and his.idprocess = wf.idobject) his) as qtdciclos
, 1 as Quantidade
from DYNtds015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs039 areamud on areamud.oid = form.OIDABCk8DABCghk
left join DYNtbs001 unid on unid.oid = form.OIDABCVrhABCPrY
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where cdprocessmodel=1


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário CM.
--            06
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select form.oid,wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, wf.dtstart as dtabertura
, case when wf.dtfinish is null then (select max(his.DTHISTORY+his.TMHISTORY) from wfhistory his where HIS.FGTYPE = 3 and his.idprocess = wf.idobject and not exists 
(select his1.fgtype from wfhistory his1 where HIS1.FGTYPE = 5 and his1.idprocess = his.idprocess and his1.DTHISTORY+his1.TMHISTORY  > his.DTHISTORY+his.TMHISTORY)) else wf.dtfinish end as dtfechamento
, mud.tbs001 as mudanca
, 1 as quantidade
from DYNtbs015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join DYNtbs019 mud on mud.OIDABCJonABCFKa = form.oid
where cdprocessmodel=1
union
Select form.oid,wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, wf.dtstart as dtabertura
, case when wf.dtfinish is null then (select max(his.DTHISTORY+his.TMHISTORY) from wfhistory his where HIS.FGTYPE = 3 and his.idprocess = wf.idobject and not exists 
(select his1.fgtype from wfhistory his1 where HIS1.FGTYPE = 5 and his1.idprocess = his.idprocess and his1.DTHISTORY+his1.TMHISTORY  > his.DTHISTORY+his.TMHISTORY)) else wf.dtfinish end as dtfechamento
, mud.mudanca as mudanca
, 1 as quantidade
from DYNtds015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join (select oid, substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as mudanca
from (select * from dyntds015) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1) mud on mud.oid = form.OID
where cdprocessmodel=1


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário CM.
--            11, 12
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, wfs.nmstruct
, case when adr.nmrole is not null then adr.nmrole else usra.nmuser end executor
, case when datediff(DD, (cast(wfs.dtenabled as datetime) + cast(wfs.tmenabled as datetime)), getdate()) > 15 then 'Em atraso' else 'Em dia' end status
, datediff(DD, (cast(wfs.dtenabled as datetime) + cast(wfs.tmenabled as datetime)), getdate()) as dias
, 1 as quantidade
from WFPROCESS wf
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE<>3
left join adrole adr on adr.cdrole = wfa.cdrole
left join aduser usra on usra.cduser = wfa.cduser
where cdprocessmodel=1 and wfs.nmstruct like '(%' and WFS.FGSTATUS in (1,2) and wfs.DTENABLED is not null


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário CM.
--            14
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, gnactp.idactivity as idplano, usrp.nmuser as planejador
, 1 as quantidade
from WFPROCESS wf
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
inner join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
inner JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
inner JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
inner join aduser usrp on usrp.cduser = gnactp.cduser
where cdprocessmodel=1


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário CM.
--            18
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, wfs.nmstruct, case wfs.FGCONCLUDEDSTATUS when 1 then 'Finalizada em dia' when 2 then 'Finalizada em atraso' else 'NA' end statusencerramento
, datediff(dd, (cast(dtenabled as datetime) + cast(tmenabled as datetime)), (cast(dtexecution as datetime) + cast(tmexecution as datetime))) as tpexec
, 1 as quantidade
from WFPROCESS wf
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
inner join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE<>3
where cdprocessmodel=1 and wfs.FGCONCLUDEDSTATUS is not null


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário CM.
--            24
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, gnact.nmactivity
, case gnact.fgstatus
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
, (select format(exeadhoc.dthistory,'dd/MM/yyyy') from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY
FROM WFHISTORY HIS
Where HIS.IDSTRUCT = wfs.IDOBJECT
AND HIS.FGTYPE IN (9,11)
ORDER   BY HIS.DTHISTORY, HIS.TMHISTORY) exeadhoc) as dtexec
, 1 as quantidade
from WFPROCESS wf
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
inner join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where cdprocessmodel=1 and wfs.FGCONCLUDEDSTATUS is not null



---------------------
-- Descrição: Todos os dados relevantes para análise do processo EQ.
-- Requisitos: 01 (EQ)
--            As 4 linhas comentadas (--atribs--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaatributos--).
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2016
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, pos.nmposition as funciniciador
, gnrev.NMREVISIONSTATUS as situacao, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
/*
, coalesce((select substring((select ' | '+ ATT.NMLABEL +' = '+ coalesce(PROCA.NMSTRING, cast(PROCA.VLFLOAT as varchar), format(PROCA.DTDATE,'dd/MM/yyyy'), ADATVL.NMATTRIBUTE, cast(ADATVL.VLATTRIBUTE as varchar), format(ADATVL.DTATTRIBUTE,'dd/MM/yyyy'), ADATVL2.NMATTRIBUTE, cast(ADATVL2.VLATTRIBUTE as varchar), format(ADATVL2.DTATTRIBUTE,'dd/MM/yyyy')) as [text()] from WFPROCATTRIB PROCA
            INNER JOIN ADATTRIBUTE ATT ON PROCA.CDATTRIBUTE=ATT.CDATTRIBUTE and ATT.FGDATATYPE <> 4
            LEFT OUTER JOIN ADATTRIBVALUE ADAV ON ADAV.CDVALUE=PROCA.CDVALUE
            LEFT OUTER JOIN ADATTRIBVALUE ADATVL ON (PROCA.CDATTRIBUTE = ADATVL.CDATTRIBUTE AND PROCA.CDVALUE = ADATVL.CDVALUE) 
            LEFT OUTER JOIN ADATTRIBUTE ATT2 ON (PROCA.CDATTRIBUTE = ATT2.CDATTRIBUTE) 
            LEFT OUTER JOIN WFPROATTMULTIVALUE AUAUDATMULT ON (ATT2.CDATTRIBUTE = AUAUDATMULT.CDATTRIBUTE AND AUAUDATMULT.IDPROCATTRIB  = PROCA.IDOBJECT ) 
            LEFT OUTER JOIN ADATTRIBVALUE ADATVL2 ON (AUAUDATMULT.CDATTRIBUTE = ADATVL2.CDATTRIBUTE AND AUAUDATMULT.CDVALUE = ADATVL2.CDVALUE) where PROCA.idprocess = wf.IDOBJECT FOR XML PATH('')), 4, 1000)), 'NA') as listaatributos --listaatributos
*/
, coalesce((select substring((SELECT ' | '+ GNFILE.nmfile as [text()] from adattachment adattch, wfprocattachment, ADATTACHFILE, GNFILE
            where adattch.cdattachment = wfprocattachment.cdattachment AND wfprocattachment.idprocess = wf.IDOBJECT and ADATTACHFILE.CDATTACHMENT = adattch.CDATTACHMENT and ADATTACHFILE.CDCOMPLEXFILECONT = GNFILE.CDCOMPLEXFILECONT
            FOR XML PATH('')), 4, 1000)), 'NA') as listaanexos --listaanexos
, coalesce((select substring((SELECT ' | '+ gnt.idgentype +' - '+ p.idprocess as [text()] from gnassocworkflow bidirect
            INNER JOIN gnassoc gnas ON bidirect.cdassoc = gnas.cdassoc AND gnas.nrobjectparent IN ( 99207887 )
            LEFT OUTER JOIN gnactivity gnac ON gnas.cdassoc = gnac.cdassoc
            INNER JOIN wfprocess p ON p.cdgenactivity = gnac.cdgenactivity
            INNER JOIN inoccurrence incid ON ( p.idobject = incid.idworkflow )
            INNER JOIN gngentype gnt ON incid.cdoccurrencetype = gnt.cdgentype
            LEFT OUTER JOIN gnrevisionstatus gnrs ON ( incid.cdstatus = gnrs.cdrevisionstatus )
            where p.cdprocessmodel <> 72 and bidirect.idprocess = wf.IDOBJECT AND p.idobject IS NOT NULL AND p.cdprodautomation IS NOT NULL FOR XML PATH('')), 4, 1000)), 'NA') as listaprocessos --listaprocessos
, (SELECT count(p.idprocess) from gnassocworkflow bidirect
            INNER JOIN gnassoc gnas ON bidirect.cdassoc = gnas.cdassoc AND gnas.nrobjectparent IN ( 99207887 )
            LEFT OUTER JOIN gnactivity gnac ON gnas.cdassoc = gnac.cdassoc
            INNER JOIN wfprocess p ON p.cdgenactivity = gnac.cdgenactivity
            INNER JOIN inoccurrence incid ON ( p.idobject = incid.idworkflow )
            INNER JOIN gngentype gnt ON incid.cdoccurrencetype = gnt.cdgentype
            LEFT OUTER JOIN gnrevisionstatus gnrs ON ( incid.cdstatus = gnrs.cdrevisionstatus )
            where p.cdprocessmodel = 72 and bidirect.idprocess = wf.IDOBJECT AND p.idobject IS NOT NULL AND p.cdprodautomation IS NOT NULL) as qtdsolic
, unid.NMATTRIBUTE as unidade
, tipoeq.NMATTRIBUTE as TipoEQ
, format(pzconc.dtdate,'dd/MM/yyyy') as prazoConclusao
, resp.nmstring as respEvento
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join addepartment dep on dep.cddepartment=rel.cddepartment 
             where usr.nmuser = resp.nmstring and usr.fguserenabled = 1) as deprespEvento
, (select pos.nmposition from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join adposition pos on pos.cdposition=rel.cdposition
             where usr.nmuser = resp.nmstring and usr.fguserenabled = 1) as posrespEvento
, arearespeq.NMATTRIBUTE as AreaResp
, criteq.NMATTRIBUTE as criticidade
, nmclieq.NMATTRIBUTE as nmcliente
, vefeq.NMATTRIBUTE as eficacia
, tvef.nmstring as tempoeficacia
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity + ' - ' + case gnactp.fgstatus
                     when  1 then 'Em planejamento'
                     when  2 then 'Em aprovavação do planejamento'
                     when  3 then 'Em execução'
                     when  4 then 'Em aprovação da execução'
                     when  5 then 'Encerrada'
                     when  7 then 'Cancelada'
                     when  9 then 'Cancelada'
                     when 10 then 'Cancelada'
                     when 11 then 'Cancelada'
                 end + ' - ' + CASE
                     WHEN gnactp.NRTASKSEQ = 1 THEN 'Alta prioridade'
                     WHEN gnactp.NRTASKSEQ = 2 THEN 'Média prioridade'
                     WHEN gnactp.NRTASKSEQ = 3 THEN 'Baixa prioridade'
                     ELSE ''
                 END as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
--atribs--, ATT.NMLABEL, coalesce(PROCA.NMSTRING, cast(PROCA.VLFLOAT as varchar), format(PROCA.DTDATE,'dd/MM/yyyy'), ADATVL.NMATTRIBUTE, cast(ADATVL.VLATTRIBUTE as varchar), format(ADATVL.DTATTRIBUTE,'dd/MM/yyyy'), ADATVL2.NMATTRIBUTE, cast(ADATVL2.VLATTRIBUTE as varchar), format(ADATVL2.DTATTRIBUTE,'dd/MM/yyyy')) as valoratributo --atribs--
--, PROCA.DSMEMO AS DSVALUE
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'Não concluído') as dtconclusao
, coalesce((select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'Não concluído') as nmconclusao
, coalesce((select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join addepartment dep on dep.cddepartment=rel.cddepartment where usr.cduser = (select cduser from (SELECT HIS.cdUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)), 'Não concluído') as depconclusao
, coalesce((select pos.nmposition from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join adposition pos on pos.cdposition=rel.cdposition where usr.cduser = (select cduser from (SELECT HIS.cdUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade141028145830734'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)), 'Não concluído') as posconclusao
, (select max(DTESTIMATEDFINISH) from wfstruct where idprocess = wf.idobject and idstruct = 'Decisão141028145854181') as dtprevaprova
, coalesce((select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141028145854181'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141028145854181'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'Não concluído') as dtaprova
, coalesce((select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141028145854181'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141028145854181'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), 'Não concluído') as nmaprova
--placao--, gnactp.idactivity as idplano
, (select struc.nmstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2) as nmatvatual
, (select format(struc.dtenabled,'dd/MM/yyyy') from wfstruct struc where struc.idprocess = wf.idobject and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2) as dtiniatvatual
, (select format(struc.dtestimatedfinish,'dd/MM/yyyy') from wfstruct struc where struc.idprocess = wf.idobject and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2) as przatvatual
, (select executor from (SELECT case when HIS.NMUSER is null then HIS.nmrole else HIS.NMUSER end as executor
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject 
and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject 
and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  his1.idprocess = wf.idobject
)) his) as usratvatual
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join addepartment dep on dep.cddepartment=rel.cddepartment 
             where usr.fguserenabled = 1 and usr.cduser = (select executor from (SELECT case when HIS.cdUSER is not null then HIS.cdUSER end as executor
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject 
and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject 
and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  his1.idprocess = wf.idobject
)) his)) as depatvatual
, (select pos.nmposition from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join adposition pos on pos.cdposition=rel.cdposition
             where usr.fguserenabled = 1 and usr.cduser = (select executor from (SELECT case when HIS.cdUSER is not null then HIS.cdUSER end as executor
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject 
and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject 
and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  his1.idprocess = wf.idobject
)) his)) as posatvatual
, (select case when struc.dtestimatedfinish < getdate() then 'Em atraso' else 'Em dia' end as prazo from wfstruct struc where struc.idprocess = wf.idobject and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2) as statusatvatual
, case wf.FGCONCLUDEDSTATUS when 1 then 'Encerrado em dia' when 2 then 'Encerado em atraso' end as statusconclusao
, 1 as quantidade
from WFPROCESS wf
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join WFPROCATTRIB procunid on procunid.idprocess = wf.IDOBJECT and procunid.cdattribute=123
LEFT OUTER JOIN ADATTRIBVALUE unid ON (procunid.CDATTRIBUTE = unid.CDATTRIBUTE AND procunid.CDVALUE = unid.CDVALUE)
left join WFPROCATTRIB tipo on tipo.idprocess = wf.IDOBJECT and tipo.cdattribute=124
LEFT OUTER JOIN ADATTRIBVALUE tipoeq ON (tipo.CDATTRIBUTE = tipoeq.CDATTRIBUTE AND tipo.CDVALUE = tipoeq.CDVALUE)
left join WFPROCATTRIB pzconc on pzconc.idprocess = wf.IDOBJECT and pzconc.cdattribute=194
left join WFPROCATTRIB resp on resp.idprocess = wf.IDOBJECT and resp.cdattribute=179
left join WFPROCATTRIB arearesp on arearesp.idprocess = wf.IDOBJECT and arearesp.cdattribute=122
LEFT OUTER JOIN ADATTRIBVALUE arearespeq ON (arearesp.CDATTRIBUTE = arearespeq.CDATTRIBUTE AND arearesp.CDVALUE = arearespeq.CDVALUE)
left join WFPROCATTRIB crit on crit.idprocess = wf.IDOBJECT and crit.cdattribute=126
LEFT OUTER JOIN ADATTRIBVALUE criteq ON (crit.CDATTRIBUTE = criteq.CDATTRIBUTE AND crit.CDVALUE = criteq.CDVALUE)
left join WFPROCATTRIB nmcli on nmcli.idprocess = wf.IDOBJECT and nmcli.cdattribute=196
LEFT OUTER JOIN ADATTRIBVALUE nmclieq ON (nmcli.CDATTRIBUTE = nmclieq.CDATTRIBUTE AND nmcli.CDVALUE = nmclieq.CDVALUE)
left join WFPROCATTRIB vef on vef.idprocess = wf.IDOBJECT and vef.cdattribute=137
LEFT OUTER JOIN ADATTRIBVALUE vefeq ON (vef.CDATTRIBUTE = vefeq.CDATTRIBUTE AND vef.CDVALUE = vefeq.CDVALUE)
left join WFPROCATTRIB tvef on tvef.idprocess = wf.IDOBJECT and tvef.cdattribute=136
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
/*--atribs--
left join WFPROCATTRIB PROCA on PROCA.idprocess = wf.IDOBJECT
INNER JOIN ADATTRIBUTE ATT ON PROCA.CDATTRIBUTE=ATT.CDATTRIBUTE and ATT.FGDATATYPE <> 4
LEFT OUTER JOIN ADATTRIBVALUE ADAV ON ADAV.CDVALUE=PROCA.CDVALUE
LEFT OUTER JOIN ADATTRIBVALUE ADATVL ON (PROCA.CDATTRIBUTE = ADATVL.CDATTRIBUTE AND PROCA.CDVALUE = ADATVL.CDVALUE) 
LEFT OUTER JOIN ADATTRIBUTE ATT2 ON (PROCA.CDATTRIBUTE = ATT2.CDATTRIBUTE) 
LEFT OUTER JOIN WFPROATTMULTIVALUE AUAUDATMULT ON (ATT2.CDATTRIBUTE = AUAUDATMULT.CDATTRIBUTE AND AUAUDATMULT.IDPROCATTRIB  = PROCA.IDOBJECT ) 
LEFT OUTER JOIN ADATTRIBVALUE ADATVL2 ON (AUAUDATMULT.CDATTRIBUTE = ADATVL2.CDATTRIBUTE AND AUAUDATMULT.CDVALUE = ADATVL2.CDVALUE) 
*/--atribs--
where cdprocessmodel=28


---------------------
-- Descrição: Todos os dados relevantes para análise do processo EQ e Plano de ação
-- Requisitos: 02 (EQ)
--            As 4 linhas comentadas (--atribs--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaatributos--).
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2016
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_eq
, unid.NMATTRIBUTE as unidade
, tipoeq.NMATTRIBUTE as TipoEQ
, format(pzconc.dtdate,'dd/MM/yyyy') as prazoConclusao
, resp.nmstring as respEvento
, arearespeq.NMATTRIBUTE as AreaResp
, criteq.NMATTRIBUTE as criticidade
, nmclieq.NMATTRIBUTE as nmcliente
, vefeq.NMATTRIBUTE as eficacia
, tvef.nmstring as tempoeficacia
, gnactp.idactivity as idplano, gnactp.nmactivity as nmplano
, case gnactp.fgstatus
    when  1 then 'Em planejamento'
    when  2 then 'Em aprovavação do planejamento'
    when  3 then 'Em execução'
    when  4 then 'Em aprovação da execução'
    when  5 then 'Encerrado'
    when  7 then 'Cancelado'
    when  9 then 'Cancelado'
    when 10 then 'Cancelado'
    when 11 then 'Cancelado'
end as status_plano
, case gnactp.NRTASKSEQ
    WHEN 1 THEN 'Alta prioridade'
    WHEN 2 THEN 'Média prioridade'
    WHEN 3 THEN 'Baixa prioridade'
    ELSE ''
END as prioridade_plano
, gnatv.idactivity as idatividade, gnatv.nmactivity as nmatividade
, (select usr.nmuser from aduser usr where usr.cduser = gnatv.cduser) as executor
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join addepartment dep on dep.cddepartment=rel.cddepartment 
             where usr.cduser = gnatv.cduser and usr.fguserenabled = 1) as depexecutor
, (select pos.nmposition from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join adposition pos on pos.cdposition=rel.cdposition
             where usr.cduser = gnatv.cduser and usr.fguserenabled = 1) as posexecutor
, case gnatv.fgstatus
    when  1 then 'Em planejamento'
    when  2 then 'Em aprovavação do planejamento'
    when  3 then 'Em execução'
    when  4 then 'Em aprovação da execução'
    when  5 then 'Encerrada'
    when  7 then 'Cancelada'
    when  9 then 'Cancelada'
    when 10 then 'Cancelada'
    when 11 then 'Cancelada'
end as status_atividade
, gnatv.DTSTARTPLAN as iniciio_plam, gnatv.DTFINISHPLAN as fim_plam, gnatv.QTDURATIONPLAN as duracao_plan
, gnatv.DTSTART as iniciio_real, gnatv.DTFINISH as fim_real, gnatv.QTDURATIONREAL as duracao_real
, case when gnatv.fgstatus = 5 and gnatv.DTFINISH > gnatv.DTFINISHPLAN then 'Encerrou em atraso'
       when gnatv.fgstatus = 5 and gnatv.DTFINISH <= gnatv.DTFINISHPLAN then 'Encerrou em dia'
       else 'Não encerrou'
  end as status_encerramento
, case when aprov.fgapprov = 1 then 'Aprovou a atividade' when aprov.fgapprov = 2 then 'Reprovou a atividade' end as aprovacao
, case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, aprov.nmuser)) when aprov.cdteam is not null then coalesce(aprov.nmuserapprov, (select nmteam from adteam where cdteam = aprov.cdteam)) end as aprovador
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join addepartment dep on dep.cddepartment=rel.cddepartment 
             where usr.nmuser = (case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, aprov.nmuser)) when aprov.cdteam is not null then coalesce(aprov.nmuserapprov, (select nmteam from adteam where cdteam = aprov.cdteam)) end) and usr.fguserenabled = 1) as depaprovador
, (select pos.nmposition from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join adposition pos on pos.cdposition=rel.cdposition
             where usr.nmuser = (case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, aprov.nmuser)) when aprov.cdteam is not null then coalesce(aprov.nmuserapprov, (select nmteam from adteam where cdteam = aprov.cdteam)) end) and usr.fguserenabled = 1) as posaprovador
, aprov.cdcycle, aprov.dtdeadline, aprov.qtduetime, aprov.dtapprov
, case when aprov.dtdeadline is not null and aprov.dtapprov is not null then case when aprov.dtdeadline >= aprov.dtapprov then 'Em dia' when aprov.dtdeadline < aprov.dtapprov then 'Em atraso' end
       when aprov.dtdeadline is not null and aprov.dtapprov is null then case when aprov.dtdeadline >= getdate() then 'Pendente - Em dia' when aprov.dtdeadline < getdate() then 'Pendente - Em atraso' end
       else 'Não aprovado'
end as status_aprova
, (select count(*) from DYNtds041 sol where sol.tds013 = gnactp.idactivity and sol.tds014 = gnatv.idactivity) as qtd_solic
, 1 as quantidade
from WFPROCESS wf
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join WFPROCATTRIB procunid on procunid.idprocess = wf.IDOBJECT and procunid.cdattribute=123
LEFT OUTER JOIN ADATTRIBVALUE unid ON (procunid.CDATTRIBUTE = unid.CDATTRIBUTE AND procunid.CDVALUE = unid.CDVALUE)
left join WFPROCATTRIB tipo on tipo.idprocess = wf.IDOBJECT and tipo.cdattribute=124
LEFT OUTER JOIN ADATTRIBVALUE tipoeq ON (tipo.CDATTRIBUTE = tipoeq.CDATTRIBUTE AND tipo.CDVALUE = tipoeq.CDVALUE)
left join WFPROCATTRIB pzconc on pzconc.idprocess = wf.IDOBJECT and pzconc.cdattribute=194
left join WFPROCATTRIB resp on resp.idprocess = wf.IDOBJECT and resp.cdattribute=179
left join WFPROCATTRIB arearesp on arearesp.idprocess = wf.IDOBJECT and arearesp.cdattribute=122
LEFT OUTER JOIN ADATTRIBVALUE arearespeq ON (arearesp.CDATTRIBUTE = arearespeq.CDATTRIBUTE AND arearesp.CDVALUE = arearespeq.CDVALUE)
left join WFPROCATTRIB crit on crit.idprocess = wf.IDOBJECT and crit.cdattribute=126
LEFT OUTER JOIN ADATTRIBVALUE criteq ON (crit.CDATTRIBUTE = criteq.CDATTRIBUTE AND crit.CDVALUE = criteq.CDVALUE)
left join WFPROCATTRIB nmcli on nmcli.idprocess = wf.IDOBJECT and nmcli.cdattribute=196
LEFT OUTER JOIN ADATTRIBVALUE nmclieq ON (nmcli.CDATTRIBUTE = nmclieq.CDATTRIBUTE AND nmcli.CDVALUE = nmclieq.CDVALUE)
left join WFPROCATTRIB vef on vef.idprocess = wf.IDOBJECT and vef.cdattribute=137
LEFT OUTER JOIN ADATTRIBVALUE vefeq ON (vef.CDATTRIBUTE = vefeq.CDATTRIBUTE AND vef.CDVALUE = vefeq.CDVALUE)
left join WFPROCATTRIB tvef on tvef.idprocess = wf.IDOBJECT and tvef.cdattribute=136
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
inner JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
inner join gnactivity gnatv ON gnatv.cdactivityowner = gnactp.cdgenactivity
left join gnvwapprovresp aprov on aprov.cdapprov = gnatv.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
      and cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
left join (select max(cdcycle) as maxcycle, cdapprov from gnvwapprovresp group by cdapprov) max_cycle
         on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where cdprocessmodel=28


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário Solicitação
-- Requisitos: 03 (EQ)
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, case form.tds005 when 1 then 'Alteração de prazo de atividade do processo' when 2 then 'Alteração de prazo de atividade de Plano de Ação' 
                   when 3 then 'Cancelamento de atividade de Plano de Ação' when 4 then 'Adendo' when 5 then 'Cancelamento do Processo' end tpsolicitação
, coalesce((select substring((select ' | '+ tds013 +' - '+ tds014 +' ('+ coalesce(format(tds007,'dd/MM/yyyy'),' ') +'='+ coalesce(format(tds008,'dd/MM/yyyy'),' ') +'/'+ tds003 +'='+ tds004 +'/Cancelar: '+ case TDS009 when 0 then 'Não' when 1 then 'Sim' end +')' as [text()] from DYNtds041 where OIDABCFHvABCauy = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaplano --listaplanoac--
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplanoassoc --listaplação--
, coalesce((select substring((select ' | '+ tds001 as [text()] from DYNtds042 where OIDABCyheABCdqV = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaproc --listaproc--
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1517164539264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1517164539264'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmissao
, (select format(max(wfs1.DTESTIMATEDFINISH),'dd/MM/yyyy') from wfstruct wfs1 where wfs1.idprocess = wf.idobject and wfs1.idstruct = 'Decisão1517164719957') as dtprevaprovacao
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovacao
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(dd, (select (cast(STR.dtenabled as datetime) + cast(STR.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
))) else
datediff(dd, (select (cast(STR.dtenabled as datetime) + cast(STR.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate()) end end leadtime_aprovacao
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovacao
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtexecucao
, datepart(yyyy,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtexecucao_ano
, datepart(MM,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtexecucao_mes
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172722655'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmexecucao
, unid.tbs001 as unidade, areasol.tbs11 as areasolicitante
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
where wf.cdprocessmodel=72 and form.tds003 = 4

--

Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, wf.dtstart as dtabertura, wf.dtfinish
, case form.tds003
    when 1 then 'Desvio'
    when 2 then 'Controle de Mudança'
    when 3 then 'Reclamação de Mercado'
    when 4 then 'Evento da Qualidade'
    when 5 then 'Investigação laboratorial'
    else 'N;A'
end tipo
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS statusproc
, case form.tds005 when 1 then 'Alteração de prazo de atividade do processo' when 2 then 'Alteração de prazo de atividade de Plano de Ação' 
                   when 3 then 'Cancelamento de atividade de Plano de Ação' when 4 then 'Adendo' when 5 then 'Cancelamento do Processo' end tpsolicitação
, coalesce((select substring((select ' | '+ tds013 +' - '+ tds014 as [text()] from DYNtds041 where OIDABCFHvABCauy = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaplano --listaplanoac--
, coalesce((select substring((select ' | '+ tds001 as [text()] from DYNtds042 where OIDABCyheABCdqV = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaproc --listaproc--
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
where wf.cdprocessmodel = 3239

---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário RM.
--            Requisitos: 01, 02, 03, 07, 08, 09, 10, 11, 12, 13, 14
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tbs004,'dd/MM/yyyy') as dtrecebimento, datepart(yyyy,form.tbs004) as dtrecebimento_ano, datepart(MM,form.tbs004) as dtrecebimento_mes
, format(form.tbs005,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tbs005) as dtlimite_ano, datepart(MM,form.tbs005) as dtlimite_mes
, format(form.tbs010, 'dd/MM/yyyy') as dtfabricacao, format(form.tbs011, 'dd/MM/yyyy') as dtvalidade, format(form.tbs015, 'dd/MM/yyyy') as dtrecamostra
, case when wf.dtfinish is null then 'Em andamento' when form.tbs005 < wf.dtfinish then 'Finalizada em atraso' when form.tbs005 >= wf.dtfinish then 'Finalizada em dia' end prazoRM
, coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs032 where OIDABC1IVABC1FY = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listatestes --listatestes--
, form.tbs030 as reprgq
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
				 left join gnactivity gnactp ON stpl.cdactionplan = gnactp.cdgenactivity
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
, coalesce((select substring((select '; '+ tbs001 as [text()] from DYNtbs017 where OIDABChURABC86n = form.oid FOR XML PATH('')), 3, 4000)), 'NA') as listafc --listafc--
, form.tbs006 as numref, form.tbs007 as codprod, form.tbs008 as descprod, form.tbs009 as lote, form.tbs013 as nmreclamante
, case form.tbs014 when 1 then 'Sim' when 2 then 'Não' end as amostradisp
, case form.tbs038 when 1 then 'Sim' when 2 then 'Não' end as acaoimediata
, case form.tbs053 when 1 then 'Sim' when 2 then 'Não' end as analiseadic
, case form.tbs080 when 1 then 'Sim' when 2 then 'Não' end as recorrente
, case form.tbs021 when 1 then 'Sim' when 2 then 'Não' end as necessidadecapa
, case form.tbs075 when 1 then 'Sim' when 2 then 'Não' end as capaproposto
, motiv.tbs001 as motivreclam, tprec.tbs004 as tpreclamante, crit.tbs001 as critini, classific.tbs003 as classificacao, crit2.tbs001 as critifin
, equipo.tbs001 as equiplinha, craiz.tbs001 as causaraiz, area.tbs001 as areaocorrencia, unid.tbs001 as unidade
, (case when form.tbs004 is not null then case when ((wf.dtstart - form.tbs004) <= 3) then 'Em dia' else 'Em atraso' end else 
case when (wf.dtstart - getdate()) <= 3 then 'Em dia' else 
'Em atraso' end end) as leadtabertura
, (case when (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then case when (((SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) - form.tbs004) <= 30) then 'Em dia' else 'Em atraso' end else 
case when (getdate() - form.tbs004) <= 30 then 'Em dia' else 
'Em atraso' end end) as leadtencerra
--aprovações
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovgq
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovgq
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprgq
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovprd
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovprd
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprprd
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovmnt
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovmnt
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprmnt
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovdme
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovdme
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprdme
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovped
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovped
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprped
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovamz
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovamz
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoapramz
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovqfn
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovqfn
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprqfn
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovcq
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovcq
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprvcq
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovest
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovest
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprrest
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovtrc
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovtrc
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprtrc
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovrtc
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovrtc
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprrtc
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovadc
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovadc
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoapradc
--investigação
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtinvestiga
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nminvestiga
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoinvestiga
, 1 as quantidade
from DYNtbs014 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs001 unid on unid.oid = form.OIDABCbgLABCm5u
left join DYNtbs029 motiv on motiv.oid = form.OIDABCgbXABC9QU
left join DYNtbs028 crit on crit.oid = form.OIDABCsKPABCl6W
left join DYNtbs027 crit2 on crit2.oid = form.OIDABCEmiABCQsB
left join DYNtbs003 classific on classific.oid = form.OIDABCnRSABCmHu
left join DYNtbs020 equipo on equipo.oid = form.OIDABC2qCABCls2
left join DYNtbs022 craiz on craiz.oid = form.OIDABCspBABCWrH
left join DYNtbs004 tprec on tprec.oid = form.OIDABCUBSABC8Gp
left join DYNtbs021 area on area.oid = form.OIDABCAa2ABCC4v
where wf.cdprocessmodel=53
union
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tds001,'dd/MM/yyyy') as dtrecebimento, datepart(yyyy,form.tds001) as dtrecebimento_ano, datepart(MM,form.tds001) as dtrecebimento_mes
, format(form.tds002,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tds002) as dtlimite_ano, datepart(MM,form.tds002) as dtlimite_mes
, format(form.tds007, 'dd/MM/yyyy') as dtfabricacao, format(form.tds008, 'dd/MM/yyyy') as dtvalidade, format(form.tds011, 'dd/MM/yyyy') as dtrecamostra
, case when wf.dtfinish is null then 'Em andamento' when form.tds002 < wf.dtfinish then 'Finalizada em atraso' when form.tds002 >= wf.dtfinish then 'Finalizada em dia' end prazoRM
, coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()] from DYNtbs032 where OIDABCkrtABCXN2 = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listatestes --listatestes--
, form.tds020 as reprgq
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
				 left join gnactivity gnactp ON stpl.cdactionplan = gnactp.cdgenactivity
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
, coalesce((select substring((select '; '+ tbs001 as [text()] from DYNtbs017 where OIDABCHS9ABCX2a = form.oid FOR XML PATH('')), 3, 4000)), 'NA') as listafc --listafc--
, form.tds003 as numref, form.tds004 as codprod, form.tds005 as descprod, form.tds006 as lote, form.tds009 as nmreclamante
, case form.tds010 when 1 then 'Sim' when 2 then 'Não' end as amostradisp
, case form.tds028 when 1 then 'Sim' when 2 then 'Não' end as acaoimediata
, case form.tds043 when 1 then 'Sim' when 2 then 'Não' end as analiseadic
, case form.tds050 when 1 then 'Sim' when 2 then 'Não' end as recorrente
, case form.tds016 when 1 then 'Sim' when 2 then 'Não' end as necessidadecapa
, case form.tds057 when 1 then 'Sim' when 2 then 'Não' end as capaproposto
, motiv.tbs001 as motivreclam, tprec.tbs004 as tpreclamante, crit.tbs001 as critini, classific.tbs003 as classificacao, crit2.tbs001 as critifin
, equipo.tbs001 as equiplinha, craiz.tbs001 as causaraiz, area.tbs001 as areaocorrencia, unid.tbs001 as unidade
, (case when form.tds001 is not null then case when ((wf.dtstart - form.tds001) <= 3) then 'Em dia' else 'Em atraso' end else 
case when (wf.dtstart - getdate()) <= 3 then 'Em dia' else 
'Em atraso' end end) as leadtabertura
, (case when (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then case when (((SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) - form.tds001) <= 30) then 'Em dia' else 'Em atraso' end else 
case when (getdate() - form.tds001) <= 30 then 'Em dia' else 
'Em atraso' end end) as leadtencerra
--aprovações
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovgq
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovgq
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprgq
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovprd
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovprd
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102916658'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprprd
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovmnt
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovmnt
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718229336'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprmnt
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovdme
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovdme
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182214624'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprdme
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovped
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovped
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1577182212159'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprped
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovamz
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovamz
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão151610294178'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoapramz
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovqfn
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovqfn
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102925488'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprqfn
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovcq
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovcq
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102910388'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprvcq
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovest
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovest
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193017951'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprest
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovtrc
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovtrc
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1573193023204'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprtrc
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovrtc
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovrtc
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão157718221789'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoaprrtc
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovadc
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovadc
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1516102835296'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoapradc
--investigação
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtinvestiga
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nminvestiga
, case (select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102992133595'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) when 1 then 'Em dia' when 2 then 'Em atraso' end as prazoinvestiga
, 1 as quantidade
from DYNtds014 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs001 unid on unid.oid = form.OIDABCaWMABCqnd
left join DYNtbs029 motiv on motiv.oid = form.OIDABCjLPABCz3F
left join DYNtbs028 crit on crit.oid = form.OIDABCaeyABCctT
left join DYNtbs027 crit2 on crit2.oid = form.OIDABCgksABC3AJ
left join DYNtbs003 classific on classific.oid = form.OIDABC6m1ABCU4G
left join DYNtbs020 equipo on equipo.oid = form.OIDABCQZHABCywL
left join DYNtbs022 craiz on craiz.oid = form.OIDABCk1aABCETU
left join DYNtbs004 tprec on tprec.oid = form.OIDABCvoqABCQ9V
left join DYNtbs021 area on area.oid = form.OIDABCyT9ABCNPC
where wf.cdprocessmodel=53


---------------------
-- Descrição: Dados dos Planos de Ação de RM.
--            Requisitos: 04
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tbs004,'dd/MM/yyyy') as dtrecebimento, datepart(yyyy,form.tbs004) as dtrecebimento_ano, datepart(MM,form.tbs004) as dtrecebimento_mes
, format(form.tbs005,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tbs005) as dtlimite_ano, datepart(MM,form.tbs005) as dtlimite_mes
, unid.tbs001 as unidade, gnactp.idactivity as idplano
, 1 as quantidade
from DYNtbs014 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs001 unid on unid.oid = form.OIDABCbgLABCm5u
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left join gnactivity gnactp ON stpl.cdactionplan = gnactp.cdgenactivity
where wf.cdprocessmodel=53
union
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tds001,'dd/MM/yyyy') as dtrecebimento, datepart(yyyy,form.tds001) as dtrecebimento_ano, datepart(MM,form.tds001) as dtrecebimento_mes
, format(form.tds002,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tds002) as dtlimite_ano, datepart(MM,form.tds002) as dtlimite_mes
, unid.tbs001 as unidade, gnactp.idactivity as idplano
, 1 as quantidade
from DYNtds014 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs001 unid on unid.oid = form.OIDABCaWMABCqnd
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left join gnactivity gnactp ON stpl.cdactionplan = gnactp.cdgenactivity
where wf.cdprocessmodel=53


---------------------
-- Descrição: Lista de atividades AD-Hoc de RM.
--            Requisitos: 06
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as statusproc, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tbs004,'dd/MM/yyyy') as dtrecebimento, datepart(yyyy,form.tbs004) as dtrecebimento_ano, datepart(MM,form.tbs004) as dtrecebimento_mes
, format(form.tbs005,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tbs005) as dtlimite_ano, datepart(MM,form.tbs005) as dtlimite_mes
, unid.tbs001 as unidade
, gnact.nmactivity, case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end as statusatv
, case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end as executor
, gnactowner.nmactivity as nmactowner
, (select format(exeadhoc.dthistory,'dd/MM/yyyy') from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY
FROM WFHISTORY HIS
Where HIS.IDSTRUCT = wfs.IDOBJECT
AND HIS.FGTYPE IN (9,11)
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) exeadhoc) as dtexec
, (case when (SELECT top 1 HIS.DTHISTORY
FROM WFHISTORY HIS
Where HIS.IDSTRUCT = wfs.IDOBJECT
AND HIS.FGTYPE IN (9,11)
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) is not null then case when (((SELECT top 1 HIS.DTHISTORY
FROM WFHISTORY HIS
Where HIS.IDSTRUCT = wfs.IDOBJECT
AND HIS.FGTYPE IN (9,11)
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) - wfs.DTENABLED) <= 15) then 'Em dia' else 'Em atraso' end else 
case when (getdate() - wfs.DTENABLED) <= 15 then 'Em dia' else 
'Em atraso' end end) as leadtencerra
, 1 as quantidade
from DYNtbs014 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs001 unid on unid.oid = form.OIDABCbgLABCm5u
left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wf.cdprocessmodel=53
union
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as statusproc, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, format(form.tds001,'dd/MM/yyyy') as dtrecebimento, datepart(yyyy,form.tds001) as dtrecebimento_ano, datepart(MM,form.tds001) as dtrecebimento_mes
, format(form.tds002,'dd/MM/yyyy') as dtlimite, datepart(yyyy,form.tds002) as dtlimite_ano, datepart(MM,form.tds002) as dtlimite_mes
, unid.tbs001 as unidade
, gnact.nmactivity, case gnact.fgstatus
    when 5 then 'Executada'
    when 3 then 'Pendente'
  end as statusatv
, case
    when gnact.fgexecutertype= 1 then (select nmuser from aduser where cduser = gnact.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is not null
      then (select nmuser from aduser where cduser = wfa.cduser)
    when gnact.fgexecutertype=6 and (select nmuser from aduser where cduser = wfa.cduser) is null
      then (select nmrole from adrole where cdrole = gnact.cdrole)
    else 'n/a'
  end as executor
, gnactowner.nmactivity as nmactowner
, (select format(exeadhoc.dthistory,'dd/MM/yyyy') from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY
FROM WFHISTORY HIS
Where HIS.IDSTRUCT = wfs.IDOBJECT
AND HIS.FGTYPE IN (9,11)
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) exeadhoc) as dtexec
, (case when (SELECT top 1 HIS.DTHISTORY
FROM WFHISTORY HIS
Where HIS.IDSTRUCT = wfs.IDOBJECT
AND HIS.FGTYPE IN (9,11)
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) is not null then case when (((SELECT top 1 HIS.DTHISTORY
FROM WFHISTORY HIS
Where HIS.IDSTRUCT = wfs.IDOBJECT
AND HIS.FGTYPE IN (9,11)
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) - wfs.DTENABLED) <= 15) then 'Em dia' else 'Em atraso' end else 
case when (getdate() - wfs.DTENABLED) <= 15 then 'Em dia' else 
'Em atraso' end end) as leadtencerra
, 1 as quantidade
from DYNtds014 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
left join DYNtbs001 unid on unid.oid = form.OIDABCaWMABCqnd
left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wf.cdprocessmodel=53


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário Solicitação.
-- CM.: 27, 29, 30, 31, 32, 34  (não tem 28)
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
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
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaceitacao
, datepart(yyyy,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtaceitacao_ano
, datepart(MM,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtaceitacao_mes
, (select HIS.NMACTION from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as acaceitacao
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaceitacao
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaprovacao
, datepart(yyyy,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtaprovacao_ano
, datepart(MM,(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) as dtaprovacao_mes
, (select HIS.NMACTION from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as acaprovacao
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmaprovacao
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(dd, (select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
))) else
datediff(dd,(select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade15722172749323'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate()) end end leadtime_avaliacao
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(dd, (select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
))) else
datediff(dd, (select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217282722'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate()) end end leadtime_avareas
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(dd, (select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
))) else
datediff(dd, (select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão1517164547614'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate()) end end leadtime_aprova
, case when gnrev.NMREVISIONSTATUS <> 'Cancelado' then case when (SELECT STR.DTEXECUTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) is not null then datediff(dd, (select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), (SELECT (cast(STR.DTEXECUTION as datetime) + cast(STR.TMEXECUTION as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
))) else
datediff(dd, (select (cast(str.dtenabled as datetime) + cast(str.tmenabled as datetime))
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1572217288432'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)), getdate()) end end leadtime_execucao
, (select count(*) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1517164539264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and HIS.NMACTION = 'Submeter' and his.idprocess = wf.idobject) his) as qtdciclos
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
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
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs001 unid on unid.oid = form.OIDABC5qIABClq3
left join DYNtbs011 areasol on areasol.oid = form.OIDABChRhABCLwI
--placao--left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
--placao--left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--placao--left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
--placao--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
--adhoc--left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--adhoc--left join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
--adhoc--left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
--adhoc--left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wf.cdprocessmodel=72 and form.tds003 = 2


---------------------
-- Descrição: Todos os dados relevantes para análise do processo e formulário Solicitação.
-- CM.: 33
--            As linhas comentadas (--placao--) são para listar os produtos em uma coluna,
--               se liberar, bloquear as linhas com (--listaplação--).
--
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2015
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, case form.tds005 when 1 then 'Alteração de prazo de atividade do processo' when 2 then 'Alteração de prazo de atividade de Plano de Ação' 
                   when 3 then 'Cancelamento de atividade de Plano de Ação' when 4 then 'Adendo' when 5 then 'Cancelamento do Processo' end tpsolicitação
, gnact.idactivity as idatividade, gnact.nmactivity as nmatividade, usrad.nmuser as executor
, unid.tbs001 as unidade, areasol.tbs11 as areasolicitante
, 1 as quantidade
from DYNtds038 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs001 unid on unid.oid = form.OIDABC5qIABClq3
left join DYNtbs011 areasol on areasol.oid = form.OIDABChRhABCLwI
left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
inner join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
left join aduser usrad on usrad.cduser = gnact.cduser
where wf.cdprocessmodel=72 and form.tds003 = 2


---------------------
-- Descrição: CM 10) Dados do CM com lista de produtos impactados por linha.
--            Processos: CM
--            Área: GQ TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2018
-- Atualizada em: -
-- 
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, gnrev.NMREVISIONSTATUS as statusevento
, case wf.fgstatus
    when 1 then 'Em andamento'
    when 2 then 'Suspenso'
    when 3 then 'Cancelado'
    when 4 then 'Encerrado'
    when 5 then 'Bloqueado para edição'
end as statusprocesso
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtGQ1
, (select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmGQ1
,  (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtGQ2
, (select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141111113212628'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmGQ2
,  (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914531751'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914531751'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtAM
, (select nmuser from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914531751'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102914531751'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as nmAM
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

---------------------
-- Descrição: Lab02) Processo (ID/titulo) x ação (nome e numero) x área x mês x status x nome x prazo
--            Processos: CM/DE/EQ
--            Área: CQ TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: -
-- 
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess
, plano.idactivity as idplano, atv.idactivity as idatividade, atv.nmactivity as nmatividade
, (select nmuser from aduser where cduser=atv.cduser) as executor
, case atv.fgstatus
     when  1 then 'Em planejamento'
     when  2 then 'Em aprovavação do planejamento'
     when  3 then 'Em execução'
     when  4 then 'Em aprovação da execução'
     when  5 then 'Encerrada'
     when  7 then 'Cancelada'
     when  9 then 'Cancelada'
     when 10 then 'Cancelada'
     when 11 then 'Cancelada'
end as Status
, format(atv.dtfinishplan,'dd/MM/yyyy') as dtexcecucaoplan, datepart(yyyy,atv.dtfinishplan) as dtexcecucaoplan_ano, datepart(MM,atv.dtfinishplan) as dtexcecucaoplan_mes
, format(atv.dtfinish,'dd/MM/yyyy') as dtexcecucao, datepart(yyyy,atv.dtfinish) as dtexcecucao_ano, datepart(MM,atv.dtfinish) as dtexcecucao_mes
, 1 as quantidade
from WFPROCESS wf
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
left JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
left JOIN gnactivity atv ON atv.cdactivityowner = plano.cdgenactivity
where wf.cdprocessmodel in (1,17,28) and atv.cduser in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))
union
Select null as idprocess, null as nmprocess
, plano.idactivity as idplano, atv.idactivity as idatividade, atv.nmactivity as nmatividade
, (select nmuser from aduser where cduser=atv.cduser) as executor
, case atv.fgstatus
     when  1 then 'Em planejamento'
     when  2 then 'Em aprovavação do planejamento'
     when  3 then 'Em execução'
     when  4 then 'Em aprovação da execução'
     when  5 then 'Encerrada'
     when  7 then 'Cancelada'
     when  9 then 'Cancelada'
     when 10 then 'Cancelada'
     when 11 then 'Cancelada'
end as Status
, format(atv.dtfinishplan,'dd/MM/yyyy') as dtexcecucaoplan, datepart(yyyy,atv.dtfinishplan) as dtexcecucaoplan_ano, datepart(MM,atv.dtfinishplan) as dtexcecucaoplan_mes
, format(atv.dtfinish,'dd/MM/yyyy') as dtexcecucao, datepart(yyyy,atv.dtfinish) as dtexcecucao_ano, datepart(MM,atv.dtfinish) as dtexcecucao_mes
, 1 as quantidade
from gnactionplan gnpl
left JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
left JOIN gnactivity atv ON atv.cdactivityowner = plano.cdgenactivity
where GNPL.CDACTIONPLANTYPE in (23, 26, 27) and atv.cduser in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))

---------------------
-- Descrição: Lab04) Area x identificador CM x fase x prazo (por fase)
--            Processos: CM
--            Área: CQ TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: -
-- 
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, gnrev.NMREVISIONSTATUS as status, wf.NMUSERSTART as iniciador
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, areamud.tbs001 as areamudanca
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para ediçao' end statusprocesso
/*
, HIS.NMUSER, HIS.NMACTION
, format(HIS.DTHISTORY,'dd/MM/yyyy') as dtexecucao, datepart(yyyy,HIS.DTHISTORY) as dtexecucao_ano, datepart(MM,HIS.DTHISTORY) as dtexecucao_mes
, format(str.DTESTIMATEDFINISH,'dd/MM/yyyy') as dtprazo, datepart(yyyy,str.DTESTIMATEDFINISH) as dtprazo_ano, datepart(MM,str.DTESTIMATEDFINISH) as dtprazo_mes
*/
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs019 where OIDABCJonABCFKa = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listamudanca --listamudanca--
, coalesce((select substring((select ' | '+ wfassoc.idprocess as [text()] from wfprocess wfp
inner JOIN gnactivity gnactp ON wfp.CDGENACTIVITY = gnactp.CDGENACTIVITY
inner join GNASSOCWORKFLOW workf on workf.cdassoc = gnactp.cdassoc
inner join wfprocess wfassoc on wfassoc.idobject = workf.idprocess
where wfp.idobject = wf.idobject FOR XML PATH('')), 4, 1000)), 'NA') as listaprocassoc --listaprocessos--
, 1 as quantidade
from DYNtbs015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on (HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject))
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
left join DYNtbs039 areamud on areamud.oid = form.OIDABCQueABCNDM
where wf.cdprocessmodel in (1) and wf.CDUSERSTART in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))
--HIS.CDUSER in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))
union
Select wf.idprocess, wf.nmprocess, gnrev.NMREVISIONSTATUS as status, wf.NMUSERSTART as iniciador
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, areamud.tbs001 as areamudanca
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para ediçao' end statusprocesso
/*
, HIS.NMUSER, HIS.NMACTION
, format(HIS.DTHISTORY,'dd/MM/yyyy') as dtexecucao, datepart(yyyy,HIS.DTHISTORY) as dtexecucao_ano, datepart(MM,HIS.DTHISTORY) as dtexecucao_mes
, format(str.DTESTIMATEDFINISH,'dd/MM/yyyy') as dtprazo, datepart(yyyy,str.DTESTIMATEDFINISH) as dtprazo_ano, datepart(MM,str.DTESTIMATEDFINISH) as dtprazo_mes
*/
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
, coalesce((select substring((select ' | '+ wfassoc.idprocess as [text()] from wfprocess wfp
inner JOIN gnactivity gnactp ON wfp.CDGENACTIVITY = gnactp.CDGENACTIVITY
inner join GNASSOCWORKFLOW workf on workf.cdassoc = gnactp.cdassoc
inner join wfprocess wfassoc on wfassoc.idobject = workf.idprocess
where wfp.idobject = wf.idobject FOR XML PATH('')), 4, 1000)), 'NA') as listaprocassoc --listaprocessos--
, 1 as quantidade
from DYNtds015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on (HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject))
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
left join DYNtbs039 areamud on areamud.oid = form.OIDABCk8DABCghk
where wf.cdprocessmodel in (1) and wf.CDUSERSTART in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))
--HIS.CDUSER in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))

---------------------
-- Descrição: Lab03) Processo (ID/titulo) x ação (nome e numero) x área x mês x status x nome x prazo X confirmada (sim/não) x laboratório de ocorrência x mês da abertura x criticidade
--            Processos: OOS
--            Área: CQ TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: -
-- 
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess
, plano.idactivity as idplano, atv.idactivity as idatividade, atv.nmactivity as nmatividade
, (select nmuser from aduser where cduser=atv.cduser) as executor
, case atv.fgstatus
     when  1 then 'Em planejamento'
     when  2 then 'Em aprovavação do planejamento'
     when  3 then 'Em execução'
     when  4 then 'Em aprovação da execução'
     when  5 then 'Encerrada'
     when  7 then 'Cancelada'
     when  9 then 'Cancelada'
     when 10 then 'Cancelada'
     when 11 then 'Cancelada'
end as Status
, format(atv.dtfinishplan,'dd/MM/yyyy') as dtexcecucaoplan, datepart(yyyy,atv.dtfinishplan) as dtexcecucaoplan_ano, datepart(MM,atv.dtfinishplan) as dtexcecucaoplan_mes
, format(atv.dtfinish,'dd/MM/yyyy') as dtexcecucao, datepart(yyyy,atv.dtfinish) as dtexcecucao_ano, datepart(MM,atv.dtfinish) as dtexcecucao_mes
, case form.tbs011 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, case form.tbs035 when 1 then 'Crítico' when 2 then 'Não crítico' end as critfin
, case form.tbs029 when 1 then 'Sim' when 2 then 'Não' end as confirmada
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, laboc.tbs001 as laboratorio
, 1 as quantidade
from DYNtbs016 form
left join GNFORMREG reg on reg.OIDENTITYREG = form.OID
left join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
left join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
left JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left join aduser usr on usr.cduser = wf.CDUSERSTART
left join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
left join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs026 laboc on laboc.oid = form.OIDABCYa3ABCdTh
--
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
left JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
left JOIN gnactivity atv ON atv.cdactivityowner = plano.cdgenactivity
where wf.cdprocessmodel in (38) and atv.cduser in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))
union
Select wf.idprocess, wf.nmprocess
, plano.idactivity as idplano, atv.idactivity as idatividade, atv.nmactivity as nmatividade
, (select nmuser from aduser where cduser=atv.cduser) as executor
, case atv.fgstatus
     when  1 then 'Em planejamento'
     when  2 then 'Em aprovavação do planejamento'
     when  3 then 'Em execução'
     when  4 then 'Em aprovação da execução'
     when  5 then 'Encerrada'
     when  7 then 'Cancelada'
     when  9 then 'Cancelada'
     when 10 then 'Cancelada'
     when 11 then 'Cancelada'
end as Status
, format(atv.dtfinishplan,'dd/MM/yyyy') as dtexcecucaoplan, datepart(yyyy,atv.dtfinishplan) as dtexcecucaoplan_ano, datepart(MM,atv.dtfinishplan) as dtexcecucaoplan_mes
, format(atv.dtfinish,'dd/MM/yyyy') as dtexcecucao, datepart(yyyy,atv.dtfinish) as dtexcecucao_ano, datepart(MM,atv.dtfinish) as dtexcecucao_mes
, case form.tds008 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini
, case form.tds031 when 1 then 'Crítico' when 2 then 'Não crítico' end as critfin
, case form.tds025 when 1 then 'Sim' when 2 then 'Não' end as confirmada
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, laboc.tbs001 as laboratorio
, 1 as quantidade
from DYNtds016 form
left join GNFORMREG reg on reg.OIDENTITYREG = form.OID
left join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
left join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
left JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left join aduser usr on usr.cduser = wf.CDUSERSTART
left join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
left join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs026 laboc on laboc.oid = form.OIDABCIsOABCqaE
--
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
left JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
left JOIN gnactivity atv ON atv.cdactivityowner = plano.cdgenactivity
where wf.cdprocessmodel in (38) and atv.cduser in (select rel.cduser from aduserdeptpos rel where cddepartment in (94,162))


---------------------
-- Descrição: CUBO 9 - Todos os dados do registro
--            Processos: OOS
--            Área: CQ TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 08/2018
-- 
--------------------------------------------------------------------------------
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
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895352873'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895352873'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn1
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade1410289542484'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade1410289542484'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn2
, 'NA' as investigadorn3
, case coalesce((select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), -1) when 1 then 'Aberta no prazo' when 2 then 'Aberta em atraso' else 'NA' end as abertura
, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmissao
, case when (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff (dd, form.tbs004, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão14102895442364'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end as conclusao
, (select distinct his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão14102895442364' or str1.idstruct = 'Decisão14102895449199')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtencerrada
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
, case gnrev.NMREVISIONSTATUS when 'Encerrado' then coalesce ((select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141028103225870'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Decisão141028103225870'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his),'Eficaz') else '' end as eficaia
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102895352873','Atividade17517142546397')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102895352873','Atividade17517142546397')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn1
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade1410289542484','Atividade17517142748315')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade1410289542484','Atividade17517142748315')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn2
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade17822182820415'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade17822182820415'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as investigadorn3
, case coalesce((select his.FGCONCLUDEDSTATUS from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his), -1) when 1 then 'Aberta no prazo' when 2 then 'Aberta em atraso' else 'NA' end as abertura
, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 'Atividade14102895346716'
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtsubmissao
, case when (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143228556' else 'Decisão17517143141313' end)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143228556' else 'Decisão17517143141313' end)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null then datediff (dd, form.tds001, (select his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143228556' else 'Decisão17517143141313' end)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143228556' else 'Decisão17517143141313' end)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his)) else -1 end as conclusao
, (select distinct his.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.FGCONCLUDEDSTATUS
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Decisão14102895442364' or str.idstruct = 'Decisão14102895449199' or str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143228556' else 'Decisão17517143141313' end)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and (str1.idstruct = 'Decisão14102895442364' or str1.idstruct = 'Decisão14102895449199' or str.idstruct = case when (catev.tbs001 = 'SST' or catev.tbs001 = 'OAL') then 'Decisão17517143228556' else 'Decisão17517143141313' end)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtencerrada
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

---------------------
-- Descrição: Dados dos registros (unidade - iniciador - ID - nome - status)
--            Processos: DHO
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 05/2016
-- Atualizada em: -
-- 
--------------------------------------------------------------------------------
Select form.crp008 as unidade, wf.idprocess, wf.nmprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador
, gnrev.NMREVISIONSTATUS as status
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, (select struc.nmstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2) as nmatvatual
--, wfs.nmstruct as nmatvatual
--, case wfa.FGEXECUTORTYPE when 1 then wfa.nmrole when 3 then wfa.nmuser when 4 then wfa.nmuser end as executor
, (select case wfact.FGEXECUTORTYPE when 1 then wfact.nmrole when 3 then wfact.nmuser when 4 then wfact.nmuser end as execut from wfstruct struc inner join wfactivity wfact on struc.idobject = wfact.IDOBJECT where struc.idprocess = wf.idobject and struc.fgstatus = 2) as executor
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura --, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento --, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, 1 as quantidade
from DYNrhcp1 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
--inner join WFSTRUCT wfs on wf.idobject = wfs.idprocess
--inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where wf.cdprocessmodel=86 and wf.fgstatus < 6
and form.crp008 like '0050 - UQF Industrial%'


---------------------
-- Descrição: Solicitações repetidas - Mesmo tipo e mesma matrícula
--            Processos: DHO
-- crp030 - mov_matricula
-- crp044 - des_matricula
-- crp052 - ocupanterior_matricula
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 05/2016
-- Atualizada em: -
-- 
--------------------------------------------------------------------------------
select form.crp030, form.crp044, form.crp052, form.crp008 as unidade, wf.idprocess, wf.nmprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador
, 1 as quantidade
from DYNrhcp1 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
where (
       (select count(form1.crp044) from DYNrhcp1 form1 inner join GNFORMREG regp on regp.OIDENTITYREG = form1.OID inner join GNFORMREGGROUP gropp on gropp.CDFORMREGGROUP = regp.CDFORMREGGROUP inner join WFPROCESS wfp on wfp.CDFORMREGGROUP = gropp.CDFORMREGGROUP INNER JOIN INOCCURRENCE INCp ON (wfp.IDOBJECT = INCp.IDWORKFLOW) LEFT OUTER JOIN GNREVISIONSTATUS GNrevp ON (INCp.CDSTATUS = GNrevp.CDREVISIONSTATUS) where form1.crp044 = form.crp044 and form1.crp001=4 and form1.crp001 = form.crp001 and wfp.fgstatus in (1,2,4,5) and gnrevp.CDREVISIONSTATUS not in (17,30)) > 1
    or (select count(form1.crp052) from DYNrhcp1 form1 inner join GNFORMREG regp on regp.OIDENTITYREG = form1.OID inner join GNFORMREGGROUP gropp on gropp.CDFORMREGGROUP = regp.CDFORMREGGROUP inner join WFPROCESS wfp on wfp.CDFORMREGGROUP = gropp.CDFORMREGGROUP INNER JOIN INOCCURRENCE INCp ON (wfp.IDOBJECT = INCp.IDWORKFLOW) LEFT OUTER JOIN GNREVISIONSTATUS GNrevp ON (INCp.CDSTATUS = GNrevp.CDREVISIONSTATUS) where form1.crp052 = form.crp052 and form1.crp001=1 and form1.crp001 = form.crp001 and form1.crp063=1 and form1.crp063 = form.crp063 and wfp.fgstatus in (1,2,4,5) and gnrevp.CDREVISIONSTATUS not in (17,30)) > 1
    or (select count(form1.crp030) from DYNrhcp1 form1 inner join GNFORMREG regp on regp.OIDENTITYREG = form1.OID inner join GNFORMREGGROUP gropp on gropp.CDFORMREGGROUP = regp.CDFORMREGGROUP inner join WFPROCESS wfp on wfp.CDFORMREGGROUP = gropp.CDFORMREGGROUP INNER JOIN INOCCURRENCE INCp ON (wfp.IDOBJECT = INCp.IDWORKFLOW) LEFT OUTER JOIN GNREVISIONSTATUS GNrevp ON (INCp.CDSTATUS = GNrevp.CDREVISIONSTATUS) where form1.crp030 = form.crp030 and form1.crp001=2 and form1.crp001 = form.crp001 and form1.crp064 = form.crp064 and wfp.fgstatus in (1,2,5) and gnrevp.CDREVISIONSTATUS not in (17,30)) > 1
    or (select count(form1.crp030) from DYNrhcp1 form1 inner join GNFORMREG regp on regp.OIDENTITYREG = form1.OID inner join GNFORMREGGROUP gropp on gropp.CDFORMREGGROUP = regp.CDFORMREGGROUP inner join WFPROCESS wfp on wfp.CDFORMREGGROUP = gropp.CDFORMREGGROUP INNER JOIN INOCCURRENCE INCp ON (wfp.IDOBJECT = INCp.IDWORKFLOW) LEFT OUTER JOIN GNREVISIONSTATUS GNrevp ON (INCp.CDSTATUS = GNrevp.CDREVISIONSTATUS) where form1.crp030 = form.crp030 and form1.crp001=3 and form1.crp001 = form.crp001 and form1.crp065 = form.crp065 and wfp.fgstatus in (1,2,5) and gnrevp.CDREVISIONSTATUS not in (17,30)) > 1
)
and wf.cdprocessmodel=86 and wf.fgstatus in (1,2,4,5) and gnrev.CDREVISIONSTATUS not in (17,30)

---------------------
-- Descrição: Listagem dos códgos de impressão dos processos que estão na atividade "Aprovação do Presidente"
--            Processos: DHO
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 05/2016
-- Atualizada em: -
-- 
--------------------------------------------------------------------------------
select form.crp008 as unidade, wf.idprocess as identificador, wf.nmprocess as titulo, wf.idobject as codimpress
, 1 as quantidade
from DYNrhcp1 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
where wf.cdprocessmodel=86 and wfs.idstruct = 'Decisão1551912320809'
and wfs.DTENABLED is not null and DTEXECUTION is null and wf.fgstatus = 1
and form.crp008 like '0020%'
order by form.crp008, wf.idprocess





----------------------------------------------

Select wf.idprocess, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_eq
, unid.NMATTRIBUTE as unidade
, tipoeq.NMATTRIBUTE as TipoEQ
, format(pzconc.dtdate,'dd/MM/yyyy') as prazoConclusao
, resp.nmstring as respEvento
, arearespeq.NMATTRIBUTE as AreaResp
, criteq.NMATTRIBUTE as criticidade
, nmclieq.NMATTRIBUTE as nmcliente
, vefeq.NMATTRIBUTE as eficacia
, tvef.nmstring as tempoeficacia
, (select cliafet.tbs001 as clienteafetado
from DYNtds010 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf1 on wf1.CDFORMREGGROUP = grop.CDFORMREGGROUP
left join DYNtbs037 cliafet on cliafet.oid = form.OIDABCGpkABCxJ0
where wf1.idobject = wf.idobject) as clienteafetado
, gnactp.idactivity as idplano, gnactp.nmactivity as nmplano
, CAST(gntype.IDGENTYPE + CASE WHEN gntype.IDGENTYPE IS NULL THEN NULL ELSE ' - ' END + gntype.NMGENTYPE AS VARCHAR(510)) AS tipoplano
, CAST(GNGNTP.IDGENTYPE + CASE WHEN GNGNTP.IDGENTYPE IS NULL THEN NULL ELSE ' - ' END + GNGNTP.NMGENTYPE AS VARCHAR(510)) AS tipoatividade
, gnactp.cduser as planejador, gnactp.cduseractivresp as respplano
, case gnactp.fgstatus
    when  1 then 'Em planejamento'
    when  2 then 'Em aprovavação do planejamento'
    when  3 then 'Em execução'
    when  4 then 'Em aprovação da execução'
    when  5 then 'Encerrado'
    when  7 then 'Cancelado'
    when  9 then 'Cancelado'
    when 10 then 'Cancelado'
    when 11 then 'Cancelado'
end as status_plano
, case gnactp.NRTASKSEQ
    WHEN 1 THEN 'Alta prioridade'
    WHEN 2 THEN 'Média prioridade'
    WHEN 3 THEN 'Baixa prioridade'
    ELSE ''
END as prioridade_plano
, gnatv.idactivity as idatividade, gnatv.nmactivity as nmatividade
, (select usr.nmuser from aduser usr where usr.cduser = gnatv.cduser) as executor
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join addepartment dep on dep.cddepartment=rel.cddepartment 
             where usr.cduser = gnatv.cduser and usr.fguserenabled = 1) as depexecutor
, (select pos.nmposition from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join adposition pos on pos.cdposition=rel.cdposition
             where usr.cduser = gnatv.cduser and usr.fguserenabled = 1) as posexecutor
, case gnatv.fgstatus
    when  1 then 'Em planejamento'
    when  2 then 'Em aprovavação do planejamento'
    when  3 then 'Em execução'
    when  4 then 'Em aprovação da execução'
    when  5 then 'Encerrada'
    when  7 then 'Cancelada'
    when  9 then 'Cancelada'
    when 10 then 'Cancelada'
    when 11 then 'Cancelada'
end as status_atividade
, gnpl.dtinsert as dtcriaplano
, gnatv.DTSTARTPLAN as iniciio_plam, gnatv.DTFINISHPLAN as fim_plam, gnatv.QTDURATIONPLAN as duracao_plan
, gnatv.DTSTART as iniciio_real, gnatv.DTFINISH as fim_real, gnatv.QTDURATIONREAL as duracao_real
, gnatv.VLPERCENTAGEM as porcentagem
, case when gnatv.fgstatus = 5 and gnatv.DTFINISH > gnatv.DTFINISHPLAN then 'Encerrou em atraso'
       when gnatv.fgstatus = 5 and gnatv.DTFINISH <= gnatv.DTFINISHPLAN then 'Encerrou em dia'
       else 'Não encerrou'
  end as status_encerramento
, case when aprov.fgapprov = 1 then 'Aprovou a atividade' when aprov.fgapprov = 2 then 'Reprovou a atividade' end as aprovacao
, case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, aprov.nmuser)) when aprov.cdteam is not null then coalesce(aprov.nmuserapprov, (select nmteam from adteam where cdteam = aprov.cdteam)) end as aprovador
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join addepartment dep on dep.cddepartment=rel.cddepartment 
             where usr.nmuser = (case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, aprov.nmuser)) when aprov.cdteam is not null then coalesce(aprov.nmuserapprov, (select nmteam from adteam where cdteam = aprov.cdteam)) end) and usr.fguserenabled = 1) as depaprovador
, (select pos.nmposition from aduser usr inner join aduserdeptpos rel on rel.cduser=usr.cduser and fgdefaultdeptpos=1 inner join adposition pos on pos.cdposition=rel.cdposition
             where usr.nmuser = (case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, aprov.nmuser)) when aprov.cdteam is not null then coalesce(aprov.nmuserapprov, (select nmteam from adteam where cdteam = aprov.cdteam)) end) and usr.fguserenabled = 1) as posaprovador
, aprov.cdcycle, aprov.dtdeadline, aprov.qtduetime, aprov.dtapprov
, case when aprov.dtdeadline is not null and aprov.dtapprov is not null then case when aprov.dtdeadline >= aprov.dtapprov then 'Em dia' when aprov.dtdeadline < aprov.dtapprov then 'Em atraso' end
       when aprov.dtdeadline is not null and aprov.dtapprov is null then case when aprov.dtdeadline >= getdate() then 'Pendente - Em dia' when aprov.dtdeadline < getdate() then 'Pendente - Em atraso' end
       else 'Não aprovado'
end as status_aprova
, (select count(*) from DYNtds041 sol where sol.tds013 = gnactp.idactivity and sol.tds014 = gnatv.idactivity) as qtd_solic
, datediff(DD, gnatv.DTFINISH, aprov.dtapprov) as leadtime_aprov
, 1 as quantidade
from WFPROCESS wf
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join WFPROCATTRIB procunid on procunid.idprocess = wf.IDOBJECT and procunid.cdattribute=123
LEFT OUTER JOIN ADATTRIBVALUE unid ON (procunid.CDATTRIBUTE = unid.CDATTRIBUTE AND procunid.CDVALUE = unid.CDVALUE)
left join WFPROCATTRIB tipo on tipo.idprocess = wf.IDOBJECT and tipo.cdattribute=124
LEFT OUTER JOIN ADATTRIBVALUE tipoeq ON (tipo.CDATTRIBUTE = tipoeq.CDATTRIBUTE AND tipo.CDVALUE = tipoeq.CDVALUE)
left join WFPROCATTRIB pzconc on pzconc.idprocess = wf.IDOBJECT and pzconc.cdattribute=194
left join WFPROCATTRIB resp on resp.idprocess = wf.IDOBJECT and resp.cdattribute=179
left join WFPROCATTRIB arearesp on arearesp.idprocess = wf.IDOBJECT and arearesp.cdattribute=122
LEFT OUTER JOIN ADATTRIBVALUE arearespeq ON (arearesp.CDATTRIBUTE = arearespeq.CDATTRIBUTE AND arearesp.CDVALUE = arearespeq.CDVALUE)
left join WFPROCATTRIB crit on crit.idprocess = wf.IDOBJECT and crit.cdattribute=126
LEFT OUTER JOIN ADATTRIBVALUE criteq ON (crit.CDATTRIBUTE = criteq.CDATTRIBUTE AND crit.CDVALUE = criteq.CDVALUE)
left join WFPROCATTRIB nmcli on nmcli.idprocess = wf.IDOBJECT and nmcli.cdattribute=196
LEFT OUTER JOIN ADATTRIBVALUE nmclieq ON (nmcli.CDATTRIBUTE = nmclieq.CDATTRIBUTE AND nmcli.CDVALUE = nmclieq.CDVALUE)
left join WFPROCATTRIB vef on vef.idprocess = wf.IDOBJECT and vef.cdattribute=137
LEFT OUTER JOIN ADATTRIBVALUE vefeq ON (vef.CDATTRIBUTE = vefeq.CDATTRIBUTE AND vef.CDVALUE = vefeq.CDVALUE)
left join WFPROCATTRIB tvef on tvef.idprocess = wf.IDOBJECT and tvef.cdattribute=136
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
inner JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = gnpl.CDACTIONPLANTYPE
left join gngentype gntp on gntp.cdgentype = gnactp.cdgenactivity
inner join gnactivity gnatv ON gnatv.cdactivityowner = gnactp.cdgenactivity
INNER JOIN GNTASK GNTK ON (gnatv.CDGENACTIVITY = GNTK.CDGENACTIVITY)
LEFT OUTER JOIN GNTASKTYPE GNTKTP ON (GNTKTP.CDTASKTYPE = GNTK.CDTASKTYPE)
LEFT OUTER JOIN GNGENTYPE GNGNTP ON (GNGNTP.CDGENTYPE = GNTKTP.CDTASKTYPE)
left join gnvwapprovresp aprov on aprov.cdapprov = gnatv.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
      and cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
left join (select max(cdcycle) as maxcycle, cdapprov from gnvwapprovresp group by cdapprov) max_cycle
         on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where wf.cdprocessmodel in (17,53,1,28,38)  --wf.cdprocessmodel=17


---------------------
-- Descrição: Todos os dados relevantes do processo de contratos do dep. Jurídico.
--            CUBO 01
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2017
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, case when form.con042 = '' or form.con042 is null then 'N/A' else form.con042 end as contrpai
, coalesce((select substring((select ' | '+ wff.idprocess as [text()]
from DYNcon001 formf
inner join gnassocformreg gnff on (gnff.oidentityreg = formf.oid)
inner join wfprocess wff on (wff.cdassocreg = gnff.cdassoc)
INNER JOIN INOCCURRENCE INCf ON (wff.IDOBJECT = INCf.IDWORKFLOW)
inner join aduser usrf on usrf.cduser = wff.cdUSERSTART
inner join aduserdeptpos relf on relf.cduser = usrf.cduser and relf.FGDEFAULTDEPTPOS = 1
inner join addepartment depf on depf.cddepartment = relf.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrevf ON (INCf.CDSTATUS = GNrevf.CDREVISIONSTATUS)
where wff.cdprocessmodel=2808 and formf.con042 = wf.idprocess FOR XML PATH('')), 4, 4000)), 'NA') as filhos
, case   when form.con057 = 1 then '0020 - ANS Industrial Taboão da Serra/SP / ' else '' end +
''+ case when form.con121 = 1 then '0030 - INOVAT Guarulhos/SP / ' else '' end +
''+ case when form.con058 = 1 then '0050 - UQFN Força de Vendas / ' else '' end +
''+ case when form.con059 = 1 then '0050 - UQFN Industrial Brasília/DF / ' else '' end +
''+ case when form.con060 = 1 then '0052 - UQFN Industrial Pouso Alegre/MG / ' else '' end +
''+ case when form.con061 = 1 then '0053 - UQFN Industrial Embu Guaçu/SP / ' else '' end +
''+ case when form.con062 = 1 then '0055 - UQFN Centro Administrativo / ' else '' end +
''+ case when form.con140 = 1 then '0054 - Depósito Taboão da Serra/SP / ' else '' end +
''+ case when form.con063 = 1 then '0056 - UQFN Gráfica ArtPack/SP / ' else '' end +
''+ case when form.con127 = 1 then '0040 - UQ Ind. Gráfica e de Emb. Ltda/MG / ' else '' end +
''+ case when form.con064 = 1 then '0058 - UQFN Industrial Bthek/BF / ' else '' end +
''+ case when form.con065 = 1 then '0059 - UQFN Centro de Distribuição/MG / ' else '' end +
''+ case when form.con126 = 1 then '0059 - UQFN Centro de Distribuição/MG / ' else '' end +
''+ case when form.con066 = 1 then '0060 - F&F Distribuidora de Produtos Farmacêuticos / ' else '' end +
''+ case when form.con068 = 1 then '0090 - Laboratil / ' else '' end +
''+ case when form.con135 = 1 then 'Claris / ' else '' end +
''+ case when form.con125 = 1 then 'RobFerma / ' else '' end +
''+ case when form.con137 = 1 then '0500 - UQFN Goiânia/GO / ' else '' end +
''+ case when form.con129 = 1 then 'Union Agener Inc. / ' else '' end +
''+ case when form.con131 = 1 then 'Union Agener Holding / ' else '' end +
''+ case when form.con070 = 1 then 'UQFN Bandeirantes' else '' end as empcont
, form.con011 as solicitante, form.con012 as depsol, form.con013 as diraprov, form.con014 as gestcontr, form.con039 as geraprov
, form.con019 as objeto, case form.con071 when 1 then 'Fixo' when 2 then 'Variável' else 'N/A' end valor
, form.con022 as razaosoc, form.con023 as nmfantasia, form.con024 as cnpj, form.con076 as vigencia
, form.con073 as pedsap, form.con074 as contrsap, form.con075 as valinic, form.con026 as valneg, form.con075 - form.con026 as saving
, struc.nmstruct as nmatvatual
, struc.dtenabled as dtiniatvatual
, struc.dtestimatedfinish as przatvatual
, case when HIS.NMUSER is null then HIS.nmrole else HIS.NMUSER end as executatvatual
, combo1.con001 as tipocontr
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNcon001espec combo1 on combo1.oid = form.OIDABCzgOABC2Ih
inner join WFHISTORY HIS on his.idprocess = wf.idobject and his.fgtype = 6
inner JOIN WFSTRUCT struc ON HIS.IDSTRUCT=struc.IDOBJECT and struc.idprocess = wf.idobject and struc.idstruct <> 'Atividade1576102552943' and struc.fgstatus = 2
and HIS.DTHISTORY+HIS.TMHISTORY = (select max(HIS1.DTHISTORY+HIS1.TMHISTORY) FROM WFHISTORY HIS1 where his1.fgtype = 6 and his1.idprocess = wf.idobject and his1.idstruct = struc.idobject)
where (wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909)


---------------------
-- Descrição: Todos os dados relevantes do processo de contratos do dep. Jurídico.
--            CUBO 02
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2017
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, wf.dtstart as dtabertura
, wf.dtfinish as dtfechamento
, stru.IDSTRUCT, stru.NMSTRUCT, coalesce(his.nmrole, 'Usuário') as tpexecut, his.nmuser, his.nmaction
--, format(his.dthistory,'dd/MM/yyyy') as dthistory, his.tmhistory
--, STRu.dtenabled, STRu.tmenabled, STRu.DTEXECUTION, STRu.TMEXECUTION
, case when STRu.DTEXECUTION is not null then datediff(DD,(cast(STRu.dtenabled as datetime) + cast(STRu.tmenabled as datetime)),
--              (cast(STRu.DTEXECUTION as datetime) + cast(STRu.TMEXECUTION as datetime))
              (cast(his.dthistory as datetime) + cast(his.tmhistory as datetime))) else null end as Tempo
/*
, (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject and his.idstruct = his1.idstruct) as historymax
*/
, 1 as quantidade
from DYNcon001 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE IN (9) 
--/*
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject and his.idstruct = his1.idstruct)
--*/
left join wfstruct stru on stru.idobject = his.idstruct
where wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909


---------------------
-- Descrição: Todos os dados relevantes do processo de contratos do dep. Jurídico.
--            CUBO 03
-- Autor: Alvaro Adriano Beck
-- Criada em: 02/2017
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, case dc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento
, gr.dtrevision as dtrevisao, gr.dtvalidity as dtvalidade
, ct.idcategory, dr.iddocument, dr.nmtitle, gr.idrevision
--, dr.cddocument, dr.cdrevision, wfs.nmstruct, wfdoc.idprocess, wfdoc.cdprocdocument, wfs.idobject
, case when CDPHYSFILEFINLDEST is not null then 
    'Local final'
  else
    case when CDPHYSFILEINTERMED is not null then
      'Local intermediário'
    else
      case when CDPHYSFILECURRENT is not null then
        'Local corrente'
      else
        'Não arquivado'
      end
    end
  end as tplocal
, case when CDPHYSFILEFINLDEST is not null then 
    cast(locaf.dslocation as varchar(255)) +' - '+ locaf.nmphyslocation +' - '+ repof.nmbox
  else
    case when CDPHYSFILEINTERMED is not null then
      cast(locai.dslocation as varchar(255)) +' - '+ locai.nmphyslocation +' - '+ repoi.nmbox
    else
      cast(locac.dslocation as varchar(255)) +' - '+ locac.nmphyslocation +' - '+ repoc.nmbox
    end
  end as localizacao
--, cast(locac.dslocation as varchar(255)) +' - '+ locac.nmphyslocation +' - '+ repoc.nmbox as localizacao
--, cast(locai.dslocation as varchar(255)) +' - '+ locai.nmphyslocation +' - '+ repoi.nmbox as localizacao
--, cast(locaf.dslocation as varchar(255)) +' - '+ locaf.nmphyslocation +' - '+ repof.nmbox as localizacao
--, CDPHYSFILECURRENT, CDPHYSFILEINTERMED, CDPHYSFILEFINLDEST
, 1 as quantidade
FROM dcdocrevision dr
INNER JOIN dcdocument dc ON dc.cddocument = dr.cddocument
INNER JOIN dccategory ct ON dr.cdcategory = ct.cdcategory
INNER JOIN gnrevision gr ON gr.cdrevision = dr.cdrevision
INNER JOIN wfprocdocument wfdoc ON dr.cddocument = wfdoc.cddocument AND (dr.cdrevision = wfdoc.cddocumentrevis 
           OR (wfdoc.cddocumentrevis IS NULL AND dr.fgcurrent = 1))
INNER JOIN wfstruct wfs ON wfdoc.idstruct = wfs.idobject
INNER JOIN wfprocess wf ON wfs.idprocess = wf.idobject
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DCDOCUMENTARCHIVAL fisico on fisico.cddocument = dc.cddocument
left join DCPHYSICALFILE repoc on fisico.CDPHYSFILECURRENT = repoc.CDPHYSICALFILE
left join DCPHYSICALFILE repoi on fisico.CDPHYSFILEINTERMED = repoi.CDPHYSICALFILE
left join DCPHYSICALFILE repof on fisico.CDPHYSFILEFINLDEST = repof.CDPHYSICALFILE
left join DCPHYSLOCATION locac on locac.CDPHYSLOCATION = repoc. CDPHYSLOCATION
left join DCPHYSLOCATION locai on locai.CDPHYSLOCATION = repoi. CDPHYSLOCATION
left join DCPHYSLOCATION locaf on locaf.CDPHYSLOCATION = repof. CDPHYSLOCATION
WHERE wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909


---------------------
-- Descrição: Estatística de tempo para jurídico
--            CUBO 04
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
SELECT wf.idprocess, gnrev.NMREVISIONSTATUS AS STATUS, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart AS dtabertura
, wf.dtfinish AS dtfechamento
, his.nmuser
, his.nmaction
, (select top 1 (cast(his1.dthistory as datetime) + cast(his1.tmhistory as datetime))
   from wfhistory his1
   where his1.idprocess = his.idprocess and his1.idstruct = his.idstruct and his1.DTHISTORY+his1.tmhistory < his.dthistory+his.tmhistory
   and his1.fgtype = 6
   order by his1.dthistory+his1.tmhistory desc) as liberado
, (cast(his.dthistory as datetime) + cast(his.tmhistory as datetime)) as executado
, (DATEDIFF(dd, (select top 1 (cast(his1.dthistory as datetime) + cast(his1.tmhistory as datetime))
   from wfhistory his1
   where his1.idprocess = his.idprocess and his1.idstruct = his.idstruct and his1.DTHISTORY+his1.tmhistory < his.dthistory+his.tmhistory
   and his1.fgtype = 6
   order by his1.dthistory+his1.tmhistory desc), (cast(his.dthistory as datetime) + cast(his.tmhistory as datetime))) + 1) as tempo_cd
, (DATEDIFF(dd, (select top 1 (cast(his1.dthistory as datetime) + cast(his1.tmhistory as datetime))
   from wfhistory his1
   where his1.idprocess = his.idprocess and his1.idstruct = his.idstruct and his1.DTHISTORY+his1.tmhistory < his.dthistory+his.tmhistory
   and his1.fgtype = 6
   order by his1.dthistory+his1.tmhistory desc), (cast(his.dthistory as datetime) + cast(his.tmhistory as datetime))) + 1)
  -(DATEDIFF(wk, (select top 1 (cast(his1.dthistory as datetime) + cast(his1.tmhistory as datetime))
   from wfhistory his1
   where his1.idprocess = his.idprocess and his1.idstruct = his.idstruct and his1.DTHISTORY+his1.tmhistory < his.dthistory+his.tmhistory
   and his1.fgtype = 6
   order by his1.dthistory+his1.tmhistory desc), (cast(his.dthistory as datetime) + cast(his.tmhistory as datetime))) * 2)
  -(CASE WHEN DATENAME(dw, (select top 1 (cast(his1.dthistory as datetime) + cast(his1.tmhistory as datetime))
   from wfhistory his1
   where his1.idprocess = his.idprocess and his1.idstruct = his.idstruct and his1.DTHISTORY+his1.tmhistory < his.dthistory+his.tmhistory
   and his1.fgtype = 6
   order by his1.dthistory+his1.tmhistory desc)) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, (cast(his.dthistory as datetime) + cast(his.tmhistory as datetime))) = 'Saturday' THEN 1 ELSE 0 END) as tempo_wd
, 1 AS quantidade
FROM DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS ON his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner join wfstruct stru on stru.idobject = his.idstruct
WHERE (wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909)
and stru.idstruct = 'Decisão1696121412176'

---------------------
-- Descrição: Todos os dados relevantes do processo de contratos do dep. Jurídico. + ID do documento gerado.
--            CUBO 05
-- Autor: Alvaro Adriano Beck
-- Criada em: 08/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.dtstart as dtabertura, wf.idprocess, form.con012 as depsol
, (select dep.nmdepartment from addepartment dep
   inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment and rel.FGDEFAULTDEPTPOS = 1 and rel.CDUSER = (select usr.cduser from aduser usr where usr.idlogin = form.con041)) as diretoria
, case when
            substring(case when form.con057 = 1 then ' | 0020 - ANS Industrial Taboão da Serra/SP' else '' end +
  case when form.con121 = 1 then ' | 0030 - INOVAT Guarulhos/SP' else '' end +
  case when form.con058 = 1 then ' | 0050 - UQFN Força de Vendas' else '' end +
  case when form.con059 = 1 then ' | 0050 - UQFN Industrial Brasília/DF' else '' end +
  case when form.con060 = 1 then ' | 0052 - UQFN Industrial Pouso Alegre/MG' else '' end +
  case when form.con061 = 1 then ' | 0053 - UQFN Industrial Embu Guaçu/SP' else '' end +
  case when form.con062 = 1 then ' | 0055 - UQFN Centro Administrativo' else '' end +
  case when form.con140 = 1 then ' | 0054 - Depósito Taboão da Serra/SP' else '' end +
  case when form.con063 = 1 then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
  case when form.con127 = 1 then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
  case when form.con064 = 1 then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
  case when form.con065 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when form.con126 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when form.con066 = 1 then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
  case when form.con068 = 1 then ' | 0090 - Laboratil' else '' end +
  case when form.con135 = 1 then ' | Claris' else '' end +
  case when form.con125 = 1 then ' | RobFerma' else '' end +
  case when form.con137 = 1 then ' | 0500 - UQFN Goiânia/GO' else '' end +
  case when form.con129 = 1 then ' | Union Agener Inc.' else '' end +
  case when form.con131 = 1 then ' | Union Agener Holding' else '' end +
  case when form.con070 = 1 then ' | UQFN Bandeirantes' else '' end, 4, 500) = '' then 'Sem DRAC'
       else
            substring(case when form.con057 = 1 then ' | 0020 - ANS Industrial Taboão da Serra/SP' else '' end +
  case when form.con121 = 1 then ' | 0030 - INOVAT Guarulhos/SP' else '' end +
  case when form.con058 = 1 then ' | 0050 - UQFN Força de Vendas' else '' end +
  case when form.con059 = 1 then ' | 0050 - UQFN Industrial Brasília/DF' else '' end +
  case when form.con060 = 1 then ' | 0052 - UQFN Industrial Pouso Alegre/MG' else '' end +
  case when form.con061 = 1 then ' | 0053 - UQFN Industrial Embu Guaçu/SP' else '' end +
  case when form.con062 = 1 then ' | 0055 - UQFN Centro Administrativo' else '' end +
  case when form.con140 = 1 then ' | 0054 - Depósito Taboão da Serra/SP' else '' end +
  case when form.con063 = 1 then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
  case when form.con127 = 1 then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
  case when form.con064 = 1 then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
  case when form.con065 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when form.con126 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when form.con066 = 1 then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
  case when form.con068 = 1 then ' | 0090 - Laboratil' else '' end +
  case when form.con135 = 1 then ' | Claris' else '' end +
  case when form.con125 = 1 then ' | RobFerma' else '' end +
  case when form.con137 = 1 then ' | 0500 - UQFN Goiânia/GO' else '' end +
  case when form.con129 = 1 then ' | Union Agener Inc.' else '' end +
  case when form.con131 = 1 then ' | Union Agener Holding' else '' end +
  case when form.con070 = 1 then ' | UQFN Bandeirantes' else '' end, 4, 500)
       end as unidade
, form.con022 as RazaoSocialContraria, form.con045 as tipoAtividade, case when wf.cdprocessmodel <> 2951 then combo1.con001 else 'Distrato' end as tipocontr
, wf.nmprocess as nomeProcesso, form.con019 as Objeto
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, gnrev.NMREVISIONSTATUS as RespAcao
, cast(coalesce((select substring((select ' | '+ struc.nmstruct as [text()] from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as nmatvatual
, cast(coalesce((select substring((select ' | '+ coalesce(wfa.nmuser,wfa.nmrole) as [text()] from wfstruct struc
                 LEFT OUTER JOIN WFACTIVITY WFA ON STRuc.IDOBJECT = WFA.IDOBJECT where struc.idprocess = wf.idobject and struc.fgstatus = 2
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as executores
, form.con013 as diretorapr
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.idstruct in ('Decisão1696121412176', 'Decisão16119164313782') and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as advogado
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.idstruct in ('Atividade161111103336346', 'Atividade16819124838176', 'Atividade1684133947305', 'Atividade16819125923303') 
and str.idprocess=wf.idobject and str.idobject = wfa.idobject
and str.DTENABLED + str.TMENABLED = (SELECT max(str1.DTENABLED+str1.TMENABLED) FROM WFSTRUCT STR1, WFACTIVITY WFA1
   WHERE str1.idstruct in ('Atividade161111103336346', 'Atividade16819124838176', 'Atividade1684133947305', 'Atividade16819125923303') 
and str1.idprocess=wf.idobject and str1.idobject = wfa1.idobject)) as comprador
, cast(coalesce((select substring((select ' | '+ rev.iddocument as [text()] from dcdocumentattrib atrel
                 inner join dcdocrevision rev on rev.cdrevision = atrel.cdrevision
                 where atrel.cdrevision = rev.cdrevision and ((atrel.cdattribute = 230 or atrel.cdattribute = 231) and nmvalue = wf.idprocess) FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as contrato
, 'Em Desenvolvimento' as contratoVigente
, 'Em Desenvolvimento' as vigencia
, 'Em Desenvolvimento' as status
, 'Em Desenvolvimento' as regularizacaoAndamento
, 'Em Desenvolvimento' as prazoTermino
, 'Em Desenvolvimento' as Contratante
, 'Em Desenvolvimento' as Contratada
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNcon001espec combo1 on combo1.oid = form.OIDABCzgOABC2Ih
where wf.fgstatus <= 5

---------------------
-- Descrição: Jurídico
--            CUBO 06
-- Autor: Alvaro Adriano Beck
-- Criada em: 08/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess
, gnrev.NMREVISIONSTATUS as status, wf.nmprocess, wf.dtstart as dtabertura, form.con012 as depsol
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, case when wf.cdprocessmodel <> 2951 then combo1.con001 else 'Distrato' end as tipocontr
, form.con041 as diretoraprlogin
, form.con013 as diretorapr
, (select dep.nmdepartment from addepartment dep
   inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment and rel.FGDEFAULTDEPTPOS = 1 and rel.CDUSER = (select usr.cduser from aduser usr where usr.idlogin = form.con041)) as diretoria
, substring(case when form.con057 = 1 then ' | 0020 - ANS Industrial Taboão da Serra/SP' else '' end +
  case when form.con121 = 1 then ' | 0030 - INOVAT Guarulhos/SP' else '' end +
  case when form.con058 = 1 then ' | 0050 - UQFN Força de Vendas' else '' end +
  case when form.con059 = 1 then ' | 0050 - UQFN Industrial Brasília/DF' else '' end +
  case when form.con060 = 1 then ' | 0052 - UQFN Industrial Pouso Alegre/MG' else '' end +
  case when form.con061 = 1 then ' | 0053 - UQFN Industrial Embu Guaçu/SP' else '' end +
  case when form.con062 = 1 then ' | 0055 - UQFN Centro Administrativo' else '' end +
  case when form.con140 = 1 then ' | 0054 - Depósito Taboão da Serra/SP' else '' end +
  case when form.con063 = 1 then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
  case when form.con127 = 1 then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
  case when form.con064 = 1 then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
  case when form.con065 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when form.con126 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when form.con066 = 1 then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
  case when form.con068 = 1 then ' | 0090 - Laboratil' else '' end +
  case when form.con135 = 1 then ' | Claris' else '' end +
  case when form.con125 = 1 then ' | RobFerma' else '' end +
  case when form.con137 = 1 then ' | 0500 - UQFN Goiânia/GO' else '' end +
  case when form.con129 = 1 then ' | Union Agener Inc.' else '' end +
  case when form.con131 = 1 then ' | Union Agener Holding' else '' end +
  case when form.con070 = 1 then ' | UQFN Bandeirantes' else '' end, 4, 500) as empcont
, form.con022 as contratada
, form.con045 as tipocontrato
, form.con019 as objeto
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.idstruct in ('Decisão1696121412176', 'Decisão16119164313782') and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as advogado
, cast(coalesce((select substring((select ' | '+ struc.nmstruct as [text()] from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as nmatvatual
, cast(coalesce((select substring((select ' | '+ coalesce(wfa.nmuser,wfa.nmrole) as [text()] from wfstruct struc
                 LEFT OUTER JOIN WFACTIVITY WFA ON STRuc.IDOBJECT = WFA.IDOBJECT where struc.idprocess = wf.idobject and struc.fgstatus = 2
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as executores
, cast(coalesce((select substring((select ' | '+ rev.iddocument as [text()] from dcdocumentattrib atrel
                 inner join dcdocrevision rev on rev.cdrevision = atrel.cdrevision
                 where atrel.cdrevision = rev.cdrevision and ((atrel.cdattribute = 230 or atrel.cdattribute = 231) and nmvalue = wf.idprocess) FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as contrato
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNcon001espec combo1 on combo1.oid = form.OIDABCzgOABC2Ih
where wf.fgstatus <= 5


---------------------
-- Descrição: Painéis de indicadores do Jurídico e Compras
--            Fontes de 01 à 11
-- Autor: Alvaro Adriano Beck
-- Criada em: 08/2018
-- Atualizada em: -
--------------------------------------------------------------------------------
--Fonte01:
select cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
, case when (rev.fgcurrent = 2) and (doc.fgstatus = 2) then 'Obsoleto' 
       when (rev.fgcurrent = 1) and (doc.fgstatus = 2) and (gnrev.dtvalidity - getdate()) > 0 then 'Vigente'
       when (doc.fgstatus = 7) then 'Encerrado'
       when (doc.fgstatus = 4) then 'Cancelado'
       when (doc.fgstatus = 1) then 'Emitindo'
       when (rev.fgcurrent = 1) and (doc.fgstatus = 2) and (gnrev.dtvalidity - getdate()) <= 0 then 'Vencido'
       when (rev.fgcurrent = 1) and (doc.fgstatus = 2) and (gnrev.dtvalidity is null) then 'N/A'
       when (doc.fgstatus = 3) then 'Em renovação'
else 'N/A'
end as status
, coalesce((select form.con026 from DYNcon001 form
   inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
   inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
   where wf.idprocess = ((select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null)))), 0) as valor
, coalesce((select form.con077 from DYNcon001 form
   inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
   inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
   where wf.idprocess = ((select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null)))), 0) as vmensal
, gnrev.dtvalidity as dtvalid
, coalesce((select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null)),'N/A') as procassoc
, (select atvl.nmvalue from dcdocumentattrib atvl where atvl.cdattribute = 349 and atvl.cdrevision = rev.cdrevision) as depsol
, coalesce((select meses.con002
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join DYNcon001meses meses on meses.oid = form.OIDABC9E1L03VLGM5R
where wf.idprocess = (select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null))), 'N/A') as mesreaj
, 1 as quantidade
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
where rev.cdcategory in (select cdcategory from dccategory where idcategory in ('jurcont', 'jurcontconf'))
and (((rev.fgcurrent <> 2) and (doc.fgstatus <> 1)) or ((rev.fgcurrent <> 2) and (doc.fgstatus <> 3))) and doc.fgstatus <> 4

----->Fonte02
select case coluna
            when 'empcont01' then '0020 - ANS Industrial Taboão da Serra/SP'
            when 'empcont03' then '0050 - UQFN Força de Vendas'
            when 'empcont02' then '0030 - INOVAT Guarulhos/SP'
            when 'empcont07' then '0055 - UQFN Centro Administrativo'
            when 'empcont04' then '0050 - UQFN Industrial Brasília/DF'
            when 'empcont05' then '0059 - Centro Logístico Pouso Alegre'
            when 'empcont10' then '0052 - UQFN Industrial Pouso Alegre/MG'
            when 'empcont06' then '0053 - UQFN Industrial Embu Guaçu/SP'
            when 'empcont08' then '0040 - UQ Ind. Gráfica e de Emb. Ltda/MG'
            when 'empcont09' then '0058 - UQFN Industrial Bthek/BF'
            when 'empcont01' then '0059 - UQFN Centro de Distribuição/MG'
            when 'empcont11' then '0060 - F&F Distribuidora de Produtos Farmacêuticos'
            when 'empcont12' then '0090 - Laboratil'
            when 'empcont13' then 'UQFN Bandeirantes'
			when 'empcont14' then 'RobFerma'
			when 'empcont15' then '0010 - UNION AGENER Industrial Augusta\GA'
			when 'empcont16' then 'Union Agener Holding'
			when 'empcont17' then 'Claris'
			when 'empcont18' then '0500 - UQFN Goiânia/GO'
			when 'empcont19' then 'Union Agener Inc.'
			when 'empcont20' then '0054 - Depósito Taboão da Serra/SP'
		end unidade
, sum(valor) as quantidade
from (
        select coluna, valor
        from (  SELECT rev.cdrevision
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71146) then 1 else 0 end) as empcont01
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71147) then 1 else 0 end) as empcont02
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71148) then 1 else 0 end) as empcont03
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71149) then 1 else 0 end) as empcont04
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71155 or atvl.cdvalue = 112803) then 1 else 0 end) as empcont05
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71151) then 1 else 0 end) as empcont06
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71152) then 1 else 0 end) as empcont07
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71153) then 1 else 0 end) as empcont08
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71154) then 1 else 0 end) as empcont09
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71150) then 1 else 0 end) as empcont10
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71156) then 1 else 0 end) as empcont11
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71157) then 1 else 0 end) as empcont12
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71158) then 1 else 0 end) as empcont13
                , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 71159) then 1 else 0 end) as empcont14
               , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 78939) then 1 else 0 end) as empcont15
               , ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 78940) then 1 else 0 end) as empcont16
				, ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 112801) then 1 else 0 end) as empcont17
				, ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 112802) then 1 else 0 end) as empcont18
				, ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 118615) then 1 else 0 end) as empcont19
				, ( case when exists (select atcd.nmattribute 
                    from DCDOCMULTIATTRIB atvl
                    inner join adattribvalue atcd on atcd.cdvalue = atvl.cdvalue
                    where atvl.cdattribute = 354 and atvl.cdrevision = rev.cdrevision and atvl.cdvalue = 118616) then 1 else 0 end) as empcont20
                from dcdocrevision rev
                inner join DCDOCMULTIATTRIB atv on atv.cdrevision = rev.cdrevision
                where rev.fgcurrent = 1 and atv.cdattribute = 354
                group by rev.cdrevision
             ) s
unpivot (valor for coluna in (empcont01,empcont02,empcont03,empcont04,empcont05,empcont06,empcont07,empcont08,empcont09,empcont10,empcont11,empcont12,empcont13,empcont14,empcont15,empcont16)) as tt
where 1 = 1) _sub
group by coluna

--Fonte03:
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess, wf.dtstart as dtabertura, form.con012 as depsol
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, case when wf.cdprocessmodel <> 2951 then combo1.con001 else 'Distrato' end as tipocontr
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNcon001espec combo1 on combo1.oid = form.OIDABCzgOABC2Ih
where (wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909 or wf.cdprocessmodel=2951)
and wf.fgstatus <= 5

--Fonte04:
select
case when substring(case when coluna = 'con057' then ' | 0020 - ANS Industrial Taboão da Serra/SP' else '' end +
  case when coluna = 'con121' then ' | 0030 - INOVAT Guarulhos/SP' else '' end +
  case when coluna = 'con058' then ' | 0050 - UQFN Força de Vendas' else '' end +
  case when coluna = 'con059' then ' | 0050 - UQFN Industrial Brasília/DF' else '' end +
  case when coluna = 'con060' then ' | 0052 - UQFN Industrial Pouso Alegre/MG' else '' end +
  case when coluna = 'con061' then ' | 0053 - UQFN Industrial Embu Guaçu/SP' else '' end +
  case when coluna = 'con062' then ' | 0055 - UQFN Centro Administrativo' else '' end +
  case when coluna = 'con140' then ' | 0054 - Depósito Taboão da Serra/SP' else '' end +
  case when coluna = 'con063' then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
  case when coluna = 'con127' then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
  case when coluna = 'con064' then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
  case when coluna = 'con065' then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when coluna = 'con126' then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
  case when coluna = 'con066' then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
  case when coluna = 'con068' then ' | 0090 - Laboratil' else '' end +
  case when coluna = 'con135' then ' | Claris' else '' end +
  case when coluna = 'con125' then ' | RobFerma' else '' end +
  case when coluna = 'con137' then ' | 0500 - UQFN Goiânia/GO' else '' end +
  case when coluna = 'con129' then ' | Union Agener Inc.' else '' end +
  case when coluna = 'con131' then ' | Union Agener Holding' else '' end +
  case when coluna = 'con070' then ' | UQFN Bandeirantes' else '' end, 4, 500) = '' then 
case coluna
	when 'con001' then '0020 - ANS Industrial Taboão da Serra/SP'
	when 'con120' then '0030 - INOVAT Guarulhos/SP'
	when 'con002' then '0050 - UQFN Força de Vendas'
	when 'con003' then '0050 - UQFN Industrial Brasília/DF'
	when 'con004' then '0052 - UQFN Industrial Pouso Alegre/MG'
	when 'con005' then '0053 - UQFN Industrial Embu Guaçu/SP'
	when 'con006' then '0055 - UQFN Centro Administrativo'
	when 'con139' then '0054 - Depósito Taboão da Serra/SP'
	when 'con007' then '0056 - UQFN Gráfica ArtPack/SP'
	when 'con123' then '0040 - UQ Ind. Gráfica e de Emb. Ltda/MG'
	when 'con008' then '0058 - UQFN Industrial Bthek/BF'
	when 'con009' then '0059 - UQFN Centro de Distribuição/MG'
	when 'con122' then '0059 - UQFN Centro de Distribuição/MG'
	when 'con010' then '0060 - F&F Distribuidora de Produtos Farmacêuticos'
	when 'con067' then '0090 - Laboratil'
	when 'con134' then 'Claris'
	when 'con124' then 'RobFerma'
	when 'con136' then '0500 - UQFN Goiânia/GO'
	when 'con128' then 'Union Agener Inc.'
	when 'con130' then 'Union Agener Holding'
	when 'con069' then 'UQFN Bandeirantes'
end else
case coluna
	when 'con057' then '0020 - ANS Industrial Taboão da Serra/SP'
	when 'con121' then '0030 - INOVAT Guarulhos/SP'
	when 'con058' then '0050 - UQFN Força de Vendas'
	when 'con059' then '0050 - UQFN Industrial Brasília/DF'
	when 'con060' then '0052 - UQFN Industrial Pouso Alegre/MG'
	when 'con061' then '0053 - UQFN Industrial Embu Guaçu/SP'
	when 'con062' then '0055 - UQFN Centro Administrativo'
	when 'con140' then '0054 - Depósito Taboão da Serra/SP'
	when 'con063' then '0056 - UQFN Gráfica ArtPack/SP'
	when 'con127' then '0040 - UQ Ind. Gráfica e de Emb. Ltda/MG'
	when 'con064' then '0058 - UQFN Industrial Bthek/BF'
	when 'con065' then '0059 - UQFN Centro de Distribuição/MG'
	when 'con126' then '0059 - UQFN Centro de Distribuição/MG'
	when 'con066' then '0060 - F&F Distribuidora de Produtos Farmacêuticos'
	when 'con068' then '0090 - Laboratil'
	when 'con135' then 'Claris'
	when 'con125' then 'RobFerma'
	when 'con137' then '0500 - UQFN Goiânia/GO'
	when 'con129' then 'Union Agener Inc.'
	when 'con131' then 'Union Agener Holding'
	when 'con070' then 'UQFN Bandeirantes'
end end unidade
, sum(valor) as quantidade
from (
select coluna, valor
from (SELECT idprocess, formj.*
from DYNcon001 formj
   inner join gnassocformreg gnfj on (gnfj.oidentityreg = formj.oid)
   inner join wfprocess wfj on (wfj.cdassocreg = gnfj.cdassoc)
   where wfj.fgstatus = 1 and (wfj.cdprocessmodel=2808 or wfj.cdprocessmodel=2909 or wfj.cdprocessmodel=2951)
) s
unpivot (valor for coluna in (con057, con121, con058, con062, con059, con060, con061, con063, con064, con065, con066, con068, con070)) as tt
where 1 = 1) _sub
group by coluna

--Fonte05:
select qtdretornos, sum(quantidade) as quantidade
from (
Select wf.idprocess
, sum(1) as quantidade
, sum(1) as qtdretornos
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9 and his.nmaction = 'Retornar para solicitante'
inner join wfstruct stru on stru.idobject = his.idstruct and stru.idstruct in ('Atividade16819124838176', 'Atividade1684133947305','Atividade16819125923303')
where wf.cdprocessmodel = 2808 or wf.cdprocessmodel = 2909 or wf.cdprocessmodel = 2951
group by wf.idprocess
) _sub
group by qtdretornos

--Fonte06:
select idprocess + quem as quem, avg(diasestimado) as previsto, avg(diasreal) as realizado
from (
select quantidade, diasestimado, diasreal
, case substring(idprocess, 1, charindex('-',idprocess))
    when 'GERCONC-' then 'GERCONSEC-' else substring(idprocess, 1, charindex('-',idprocess)) end idprocess
, case when quem is null then 'Total' else quem end quem
from (
select idprocess, quem, sum(distinct quantidade) as quantidade, sum(distinct diasestimado) as diasestimado, sum(distinct diasreal) as diasreal
from (
Select wf.idprocess, wf.dtfinish, struc.DTENABLED, struc.DTESTIMATEDFINISH, struc.DTEXECUTION
, datediff(dd,struc.DTENABLED,struc.DTESTIMATEDFINISH) as diasestimado
, case when (datediff(dd,struc.DTENABLED,struc.DTEXECUTION) = 0) then 1 else datediff(dd,struc.DTENABLED,struc.DTEXECUTION) end as diasreal
, case when struc.idstruct in ('Atividade16119163923431','Atividade168410214599','Atividade16102711203529')
                           then 'Requisitante'
		when struc.idstruct in ('Decisão1951410726769','Decisão1951410124977','Decision181017144253360')
                           then 'Aprovador Técnico'
		when struc.idstruct in ('Atividade1612714493380','Decisão16127145213103','Decisão1696121919398','Atividade161281447041','Atividade16920163737407','Atividade16119164416308','Decisão1612614385612')
                           then 'Gestor do Contrato'
		when struc.idstruct in ('Decisão1696121412176','Atividade16920164057329','Atividade16920164858885','Decisão16119164313782','Atividade16126141818467')
                           then 'Jurídico'
       when struc.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303','Atividade16127145153125','Atividade16127145159707','Atividade17124103318911','Atividade1612714533177','Atividade1612814472837','Atividade16127145318908','Decisão1812213523878','Decisão1831132945259','Decisão18122135258564','Atividade161111103336346','Decision197115357474','Decision197115351995','Decision197115353790','Decisão1812213523878','Decision1971153515198','Decision1971153511389','Decisão18122135258564','Decision1971153522516')
                           then 'Compras'
       when struc.idstruct in ('Atividade1612714843817','Atividade1666153353560','Atividade161049385571','Atividade161111103422527')
                           then 'Assinatura'
       when struc.idstruct in ('Decisão191210135022969','Decisão19121013525163','Decisão16102511415448','Decisão166614406373','Decisão166614415242','Decisão16920164138189','Decisão16920164041982','Decisão1692016412130','Decisão16920164130446','Decisão16920165113328','Decisão161025131858874','Decisão16119164028957','Decisão16119164033806','Decisão16119164045259','Decisão181221121914','Decisão191210145235167','Decisão19121014289244','Decisão191210143220611')
                           then 'Aprovadores'
		when struc.idstruct in ('Atividade169612214299','Atividade166615352732','Atividade1611916433297','Atividade171121417254')
                           then 'Finalização'
       else 'N/A'
  end as quem
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and his.fgtype = 9
inner JOIN WFSTRUCT struc ON HIS.IDSTRUCT = struc.IDOBJECT and struc.idprocess = wf.idobject and struc.fgstatus = 3
where (wf.cdprocessmodel = 2808 or wf.cdprocessmodel = 2909 or wf.cdprocessmodel = 2951)
and wf.fgstatus = 4 and gnrev.NMREVISIONSTATUS <> 'Cancelado'
) _sub
group by idprocess, quem
with rollup
) __sub
where idprocess is not null) ___sub
where quem <> 'N/A'
group by idprocess, quem

--Fonte07:
Select wf.idprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, stru.IDSTRUCT, stru.NMSTRUCT, coalesce(his.nmrole, 'Usuário') as tpexecut, his.nmuser, his.nmaction
, his.dthistory as dthistory, his.tmhistory
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner join wfstruct stru on stru.idobject = his.idstruct and stru.idstruct in ('Decisão1696121412176', 'Decisão16119164313782')
where wf.cdprocessmodel = 2808 or wf.cdprocessmodel = 2909 or wf.cdprocessmodel = 2951

--Fonte08:
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, wf.dtstart as dtabertura
, case when wf.cdprocessmodel <> 2951 then combo1.con001 else 'Distrato' end as tipocontr
, case when wf.cdprocessmodel <> 2909 then (SELECT HIS.NMUSER
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303','Atividade161111103336346')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303','Atividade161111103336346')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
)) else 'N/A' end as comprador
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNcon001espec combo1 on combo1.oid = form.OIDABCzgOABC2Ih
where (wf.cdprocessmodel = 2808 or wf.cdprocessmodel = 2909 or wf.cdprocessmodel = 2951)
and exists (SELECT HIS.NMUSER
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303','Atividade161111103336346')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 6 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303','Atividade161111103336346')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 6 and his1.idprocess = wf.idobject
))
and not exists (SELECT HIS.NMUSER
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade169612214299','Atividade1611916433297')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE = 9 and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade169612214299','Atividade1611916433297')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject
))
and wf.fgstatus = 1

--Fonte09:
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, wf.dtstart, struc.nmstruct as nmatvatual, struc.dtenabled as dtiniatvatual
, struc.dtestimatedfinish as przatvatual
, case when HIS.NMUSER is null then HIS.nmrole else HIS.NMUSER end as executatvatual
, coalesce((select dep1.iddepartment +' - '+ dep1.nmdepartment from aduser usr1 inner join aduserdeptpos rel1 on rel1.cduser = usr1.cduser and rel1.fgdefaultdeptpos = 1 inner join addepartment dep1 on dep1.cddepartment = rel1.cddepartment where usr1.cduser = HIS.cdUSER), HIS.nmrole) as executarea
, case when wf.cdprocessmodel <> 2951 then combo1.con001 else 'Distrato' end as tipocontr
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNcon001espec combo1 on combo1.oid = form.OIDABCzgOABC2Ih
inner join WFHISTORY HIS on his.idprocess = wf.idobject and his.fgtype = 6
inner JOIN WFSTRUCT struc ON HIS.IDSTRUCT = struc.IDOBJECT and struc.idprocess = wf.idobject and struc.fgstatus = 2
and HIS.DTHISTORY+HIS.TMHISTORY = (select max(HIS1.DTHISTORY+HIS1.TMHISTORY) FROM WFHISTORY HIS1 where his1.fgtype = 6 and his1.idprocess = wf.idobject and his1.idstruct = struc.idobject)
where (wf.cdprocessmodel = 2808 or wf.cdprocessmodel = 2909 or wf.cdprocessmodel = 2951)
and wf.fgstatus = 1

--Fonte10:
Select coalesce(form.con012,'N/A') as con012
, sum(1) as quantidade
--, case when gnrev.NMREVISIONSTATUS = 'Cancelado' then 'Cancelados pelo Usuário' else 'Cancelados pelo Gestor' end as acao
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
where (wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909 or wf.cdprocessmodel=2951)
and (gnrev.NMREVISIONSTATUS = 'Cancelado' or wf.fgstatus = 3)
group by con012
--group by case when gnrev.NMREVISIONSTATUS = 'Cancelado' then 'Cancelados pelo Usuário' else 'Cancelados pelo Gestor' end

--Fonte11:
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess, wf.dtstart
, case when wf.cdprocessmodel <> 2951 then combo1.con001 else 'Distrato' end as tipocontr
, case when coalesce(datediff(dd,
form.con078
, (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (6) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select min(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (6) and his1.idprocess = wf.idobject)
)), -1) = -1 then 'N/A'
when datediff(dd,
form.con078
, (SELECT HIS.DTHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (6) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select min(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade16819124838176','Atividade1684133947305','Atividade16819125923303')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (6) and his1.idprocess = wf.idobject)
)) < 120 then 'Em atraso'
else 'Em dia' end as prazo
, 1 as quantidade
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNcon001espec combo1 on combo1.oid = form.OIDABCzgOABC2Ih
inner join WFHISTORY HIS on his.idprocess = wf.idobject and his.fgtype = 6
inner JOIN WFSTRUCT struc ON HIS.IDSTRUCT = struc.IDOBJECT and struc.idprocess = wf.idobject and struc.fgstatus = 2
and HIS.DTHISTORY+HIS.TMHISTORY = (select max(HIS1.DTHISTORY+HIS1.TMHISTORY) FROM WFHISTORY HIS1 where his1.fgtype = 6 and his1.idprocess = wf.idobject and his1.idstruct = struc.idobject)
where (wf.cdprocessmodel = 2808) --or wf.cdprocessmodel=2909 or wf.cdprocessmodel=2951)
and wf.fgstatus = 1

--Fonte12:
select *
, case status when 'Em renovação' then 1 else 0 end qrenovando
, case status when 'Á Vencer' then 1 else 0 end qavencer
from (
select cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
, case when (rev.fgcurrent = 2) and (doc.fgstatus = 2) then 'Obsoleto' 
       when (doc.fgstatus = 7) then 'Encerrado'
       when (doc.fgstatus = 4) then 'Cancelado'
       when (doc.fgstatus = 1) then 'Emitindo'
       when ((rev.fgcurrent = 1) and (doc.fgstatus = 2) and (gnrev.dtvalidity - getdate()) > 0 or
             (rev.fgcurrent = 1) and (doc.fgstatus = 2) and (gnrev.dtvalidity - getdate()) <= 0) then 'Á Vencer'
       when (rev.fgcurrent = 1) and (doc.fgstatus = 2) and (gnrev.dtvalidity is null) then 'N/A'
       when (doc.fgstatus = 3) then 'Em renovação'
else 'N/A'
end as status
, coalesce((select form.con026 from DYNcon001 form
   inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
   inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
   INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
   where wf.idprocess = ((select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null)))), 0) as valor
, coalesce((select form.con077 from DYNcon001 form
   inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
   inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
   INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
   where wf.idprocess = ((select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null)))), 0) as vmensal
, gnrev.dtvalidity as dtvalid
, coalesce((select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null)),'N/A') as procassoc
, (select atvl.nmvalue from dcdocumentattrib atvl where atvl.cdattribute = 349 and atvl.cdrevision = rev.cdrevision) as depsol
, coalesce((select meses.con002
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (wf.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join DYNcon001meses meses on meses.oid = form.OIDABC9E1L03VLGM5R
where wf.idprocess = (select nmvalue from dcdocumentattrib where cdrevision = rev.cdrevision and ((cdattribute = 230 or cdattribute = 231) and nmvalue is not null))), 'N/A') as mesreaj
, 1 as quantidade
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
where rev.cdcategory in (select cdcategory from dccategory where idcategory in ('jurcont', 'jurcontconf'))
and (((rev.fgcurrent <> 2) and (doc.fgstatus <> 1)) or ((rev.fgcurrent <> 2) and (doc.fgstatus <> 3))) and doc.fgstatus <> 4 and doc.fgstatus <> 7
and (gnrev.dtvalidity between getdate() and dateadd(month,12,getdate())
or datepart(year,gnrev.dtvalidity) = datepart(year,getdate()))
) _sub

---------------------
-- Descrição: Processos DHO de um determonado Gerente - aberto por todos os seus subordinados diretos.
-- Solicitado por: André Bochnia (327)
-- Autor: Alvaro Adriano Beck
-- Criada em: 12/2017
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, (select struc.nmstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2) as nmatvatual
, (select format(struc.dtenabled,'dd/MM/yyyy') from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2) as dtiniatvatual
, (select format(struc.dtestimatedfinish,'dd/MM/yyyy') from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2) as przatvatual
, (select executor from (SELECT case when HIS.NMUSER is null then HIS.nmrole else HIS.NMUSER end as executor
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct = 
(select struc.idstruct from wfstruct struc where struc.idprocess = wf.idobject and struc.fgstatus = 2)
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  his1.idprocess = wf.idobject
)) his) as executatvatual
, case form.crp001 when 1 then 'Requisição de pessoal' when 2 then 'Alteração de cargos e salários' when 3 then 'Transferência' when 4 then 'Desligamento' end as tipoSolic
, case when (form.crp001 = 1 and form.crp063 = 1) then 'Substituição' when (form.crp001 = 1 and form.crp063 = 2) then 'Aumento de quadro' when (form.crp001 = 1 and form.crp063 = 3) then 'Substituição com aumento de quadro'
       when (form.crp001 = 2 and form.crp064 = 1) then 'Aumento salarial' when (form.crp001 = 2 and form.crp064 = 2) then 'Promoção' when (form.crp001 = 2 and form.crp064 = 3) then 'Alteração de cargo'
       when (form.crp001 = 3 and form.crp065 = 1) then 'Unidade' when (form.crp001 = 3 and form.crp065 = 2) then 'Área (mesma unidade)'
       when (form.crp001 = 4) then '-'
  end as subTipoSolic
, 1 as Quantidade
from DYNrhcp1 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where wf.cdprocessmodel=86
and (327 in (select usrw.cdleader from wfprocess wfw inner join aduser usrw on usrw.cduser = wfw.cduserstart where wfw.idobject = wf.idobject)
	 or wf.cduserstart = 327)


---------------------
-- Descrição: Dados de documentos em fluxo de emissão/revisão (POP / FORM / AVAL - BSB)
-- Solicitado por: Engenharia BSB (Weslei Fernando Silva Dias)
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select idcategory as tipodoc, sub.iddocument, sub.idrevision, sub.nmtitle, sub.fase, sub.desde, qtdeadline as prazodias, dtdeadline as prazo, sub.executor, dep.nmdepartment, pos.nmposition
, case when (dtdeadline > getdate()) then 'Em dia' when (dtdeadline = getdate()) then 'Vence hoje' when (dtdeadline < getdate()) then 'Em atraso' end as status
, case when (dtdeadline > getdate()) then 0 when (dtdeadline = getdate()) then 0 when (dtdeadline < getdate()) then datediff(dd, dtdeadline, getdate()) end as diasatraso
from (select rev.iddocument, gnrev.idrevision, rev.nmtitle, rev.cdrevision, cat.idcategory
 , case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when doc.fgstatus = 4 then 'Cancelado' 
   when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' when rev.fgcurrent = 2 then 
   case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision 
   where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev 
 , case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase 
 , stag.NRCYCLE as ciclo, stag.dtdeadline, stag.qtdeadline
 , dateadd(day, -stag.qtdeadline, stag.dtdeadline) as desde
 , case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA'  
   else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor 
 from dcdocrevision rev 
 inner join dcdocument doc on doc.cddocument = rev.cddocument 
 inner join dccategory cat on cat.cdcategory = rev.cdcategory
 inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision 
 left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
      and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
      and stag.dtapproval is null
where cat.CDCATEGORYOWNER = 27 ) sub
inner join aduser usr on usr.nmuser = sub.executor
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
where fase is not null and statusrev in ('Em fluxo','Emissão')
order by iddocument, idrevision, fase, executor


---------------------
-- Descrição: Dados do processo Desvio - Cubo 01 parte 02 com menos campos
-- Solicitado por: Anovis
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento, form.tds001 as dtdeteccao, form.tds002 as dtocorrencia, form.tds003 as dtlimite
, classinic.tbs005 as classificini, catevent.tbs006 as catevento, classfin.tbs002 as classfim, catraiz.tbs007 as catcausaraiz
, areaocor.tbs11 as areaocorrencia
, case form.tds052 when 1 then 'Sim' when 2 then 'Não' end recorrente
, case form.tds030 when 1 then 'Sim' when 2 then 'Não' end as lotebloq
, case form.tds044 when 1 then 'Sim' when 2 then 'Não' end as verifeficacia
, case form.tds006 when 0 then 'Não' when 1 then 'Sim' end provterceiro, form.tds007 as nometerceiro, form.tds008 as loteterceiro
, case form.tds009 when 1 then 'Sim' when 2 then 'Não' end as relprod, form.tds010 as justrelprod
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess = wf.idobject) as dtaprovinicial
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141027113057548' and str.idprocess = wf.idobject and str.idobject = wfa.idobject) as nmaprovinicial
, coalesce((SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess = wf.idobject and str.idobject = wfa.idobject), form.tds004) as nmaprovfim
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess = wf.idobject) as dtaprovfim
, coalesce((SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade141027113146417' and str.idprocess = wf.idobject and str.idobject = wfa.idobject), form.tds004) as nminvestiga
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade141027113146417' and str.idprocess = wf.idobject) as dtinvestiga
, case when cliafet.tbs001 is null then (cast(coalesce((select substring((select ' | '+ cliafet1.tbs001 as [text()] from DYNtbs040 cliafet1
   where form.oid = cliafet1.OIDABC5M99RTZHBWXW FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000))) else cliafet.tbs001 end as clienteafetado
, cast(coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +')' as [text()]
                     from DYNtbs012 where OIDABCr58ABCzha = form.oid FOR XML PATH('')), 4, 8000)), 'NA') as varchar(8000)) as prodlote --listaprod--
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
, 1 as quantidade
from DYNtds010 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left join DYNtbs005 classinic on classinic.oid = form.OIDABCCM0ABCSbb
left join DYNtbs006 catevent on catevent.oid = form.OIDABCV3fABC895
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABChG0ABCjLn
left join DYNtbs037 cliafet on cliafet.oid = form.OIDABCGpkABCxJ0
left join DYNtbs002 classfin on classfin.oid = form.OIDABC4sfABC3Qp
left join DYNtbs011 areaocor on areaocor.oid = form.OIDABCO2wABCqaO
where wf.cdprocessmodel=17

---------------------
-- Descrição: Dados do processo DEsvio.
-- Solicitado por: Inovat
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2018
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess, form.tds004 as investigador
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, wf.dtstart as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, wf.dtfinish as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, form.tds001 as dtdeteccao, datepart(yyyy,form.tds001) as dtdeteccao_ano, datepart(MM,form.tds001) as dtdeteccao_mes
, form.tds002 as dtocorrencia, datepart(yyyy,form.tds002) as dtocorrencia_ano, datepart(MM,form.tds002) as dtocorrencia_mes
, form.tds003 as dtlimite, datepart(yyyy,form.tds003) as dtlimite_ano, datepart(MM,form.tds003) as dtlimite_mes
, areadetec.tbs11 as areadetec, areaocor.tbs11 as areaocorrencia, form.tds071 as repqualidade
, cast(coalesce((select substring((select ' | '+ tbs003 +' - '+ tbs002 +' ('+ tbs004 +') - '+ coalesce(tbs001,'NA') as [text()] from DYNtbs012 where OIDABCr58ABCzha = form.oid FOR XML PATH('')), 4, 8000)), 'NA') as varchar(8000)) as prodlote --listaprod--
, classinic.tbs005 as classificini, catevent.tbs006 as catevento
, catraiz.tbs007 as catcausaraiz, classfin.tbs002 as classfin
, cast(coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABC5M99RTZHBWXW = form.oid FOR XML PATH('')), 4, 8000)), 'NA') as varchar(8000)) as listacli --listaclientes--
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
left join DYNtbs002 classfin on classfin.oid = form.OIDABC4sfABC3Qp
where wf.cdprocessmodel=3235

---------------------
-- Descrição: UQ-LISTATREINA - Lista de usuários e suas necessidades de treinamento com status
--                             e outros dados relacionados
-- Solicitado por: União Química
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2019
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
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and ((pos.idposition like 'PA0052%') or (pos.idposition like 'BR0050%') or (pos.idposition like 'EG0053%') or (pos.idposition like 'VETEG0053%'))
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
where usr.fguserenabled = 1
) __sub
group by unid, setor, areapadrao, idposition, nmposition, idlogin, nmuser, iddocument, idrevision, situacao, dtdoc

---------------------
-- Descrição: UQ-STATUSPOP - Resumo dos treinamentos por POP
-- Solicitado por: União Química
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2019
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
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and ((pos.idposition like 'PA0052%') or (pos.idposition like 'BR0050%') or (pos.idposition like 'EG0053%') or (pos.idposition like 'VETEG0053%'))
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
where usr.fguserenabled = 1
) _sub0
group by unid, POP, situacao
with rollup

---------------------
-- Descrição: UQ-STATUSSETOR - Resumo dos treinamentos por Setor
-- Solicitado por: União Química
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2019
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
, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, CHARINDEX('-', idposition), 2) else '' end as setor
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
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and ((pos.idposition like 'PA0052%') or (pos.idposition like 'BR0050%') or (pos.idposition like 'EG0053%') or (pos.idposition like 'VETEG0053%'))
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
where usr.fguserenabled = 1
) _sub0
group by unid, setor, situacao
with rollup

---------------------
-- Descrição: UQ-LISTAUSRSETOR - Usuários x Setor x ROLES
-- Solicitado por: União Química
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select usr.idlogin, usr.nmuser, pos.idposition, pos.nmposition
, case when CHARINDEX('-', pos.idposition) <> 0 then SUBSTRING(pos.idposition, CHARINDEX('-', idposition)+1, 2) else '' end as setor
, case when CHARINDEX('-', pos.idposition) <> 0 then SUBSTRING(pos.idposition, 1, charindex('-', pos.idposition)-1) else '' end as unid
,1 as quantidade
from aduser usr
inner join aduserdeptpos rel on usr.cduser = rel.cduser and rel.FGDEFAULTDEPTPOS = 2 and rel.cddepartment = 164
inner join adposition pos on rel.cdposition = pos.cdposition and pos.fgposenabled = 1 and ((pos.idposition like 'PA0052%') or (pos.idposition like 'BR0050%') or (pos.idposition like 'EG0053%') or (pos.idposition like 'VETEG0053%'))
where usr.fguserenabled = 1

---------------------
-- Descrição: UQ-STATUSUSRROLEPOP - Status x Usuários x ROLES x POP
-- Solicitado por: União Química
-- Autor: Alvaro Adriano Beck
-- Criada em: 04/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select usr.nmuser, coalesce((select nmdepartment from addepartment where cddepartment = (select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1)), 'NA') as areapadrao
, case when CHARINDEX('-', idposition) <> 0 then SUBSTRING(idposition, CHARINDEX('-', idposition), 2) else '' end as setor
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
inner join adposition pos on pos.cdposition = rel0.cdposition and pos.fgposenabled = 1 and ((pos.idposition like 'PA0052%') or (pos.idposition like 'BR0050%') or (pos.idposition like 'EG0053%') or (pos.idposition like 'VETEG0053%'))
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
where usr.fguserenabled = 1


---------------------
-- Descrição: xxxxxxxx - Dados para Indicadores do processo AN-CM.
--            Parte 1: Todos os registros (processo)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess, wf.nmprocess, gnrev.NMREVISIONSTATUS as si, wf.dtstart
, case when wf.fgstatus = 3 or wf.fgstatus = 2 then (
    SELECT max(HIS.DTHISTORY+HIS.TMHISTORY) as dtlib
    FROM WFHISTORY HIS
    WHERE (HIS.FGTYPE = 2 or HIS.FGTYPE = 3) and his.idprocess = wf.idobject) else wf.dtfinish
end dtfinish
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status
from wfprocess wf
left outer join gnrevisionstatus gnrev on wf.cdstatus = gnrev.cdrevisionstatus
where wf.cdprocessmodel=1

---------------------
-- Descrição: xxxxxxxx - Dados para Indicadores do processo AN-CM.
--            Parte 2: Dados das atividades (Aceitação, Criação do Plano de ação e Aprovações GQ1 e GQ2)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess, str.nmstruct, wf.dtstart, case when HIS.NMUSER is null then HIS.nmrole else HIS.NMUSER end LiberadoPara, HIS.DTHISTORY + HIS.TMHISTORY as dtliberado
, dateadd(day, (wfa.qthours/60)/24, HIS.DTHISTORY + HIS.TMHISTORY) as prazo
, gnrev.NMREVISIONSTATUS as status
, hist.dtlib as ttt, hist.nmuser as nmexecut, hist.nmaction as acexecut
, case when hist.dtlib is null then datediff(dd, HIS.DTHISTORY+HIS.TMHISTORY, getdate()) else datediff(dd, HIS.DTHISTORY+HIS.TMHISTORY, hist.dtlib)+1 end leadtime
, (SELECT count(HIS1.IDOBJECT) as cicl
   FROM WFHISTORY HIS1
   WHERE  HIS1.FGTYPE = 6 and his1.idprocess = wf.idobject and HIS1.IDSTRUCT = STR.IDOBJECT and HIS1.DTHISTORY+HIS1.TMHISTORY <= HIS.DTHISTORY+HIS.TMHISTORY) as ciclo
FROM WFHISTORY HIS
inner join wfprocess wf on his.idprocess = wf.idobject
left outer join gnrevisionstatus gnrev on wf.cdstatus = gnrev.cdrevisionstatus
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Atividade14102914355828' or str.idstruct = 'Atividade1518102355189'
	or str.idstruct = 'Decisão14102914536874' or str.idstruct = 'Decisão141111113212628'
	or str.idstruct = 'Atividade14102914459502' or str.idstruct = 'Atividade176913390667')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
inner join (SELECT HIS1.DTHISTORY+HIS1.TMHISTORY as dtlib, his1.nmuser, his1.nmaction, his1.idprocess, his1.IDSTRUCT
    FROM WFHISTORY HIS1
    WHERE  HIS1.FGTYPE = 9) hist on hist.idprocess = wf.idobject and HISt.IDSTRUCT = str.IDobject and hist.dtlib = (SELECT top 1 min(HIS1.DTHISTORY+HIS1.TMHISTORY) as dtlib
        FROM WFHISTORY HIS1
        WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject and HIS1.DTHISTORY+HIS1.TMHISTORY >= HIS.DTHISTORY+HIS.TMHISTORY and HIS1.IDSTRUCT=STR.IDOBJECT
        order by dtlib asc)
WHERE HIS.FGTYPE = 6 and wf.cdprocessmodel=1
order by idprocess,nmstruct,dtliberado


---------------------
-- Descrição: xxxxxxxx - Dados para Indicadores do processo AN-CM.
--            Parte 3: Dados das ações (Planos de ação)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select actp.idactivity as plano, actp.nmactivity as nmplano
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
end as status_plano
, act.idactivity as atividade, act.nmactivity as nmatividade
, case act.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Aprovação da execução'
    when 5 then 'Encerrada'
    WHEN 6 THEN 'Cancelada' 
    WHEN 7 THEN 'Cancelada' 
    WHEN 8 THEN 'Cancelada' 
    WHEN 9 THEN 'Cancelada' 
    WHEN 10 THEN 'Cancelada' 
    WHEN 11 THEN 'Cancelada'
end as status_act
, (select usr.nmuser from aduser usr where act.cduser = usr.cduser) as executor, act.dtstartplan, act.dtfinishplan, act.dtstart, act.dtfinish
, case
    when aprov.fgapprov = 1 then 'Aprovou'
    when aprov.fgapprov = 2 then 'Rejeitou'
end as aprovacao
, case
    when aprov.fgapprov is null then
        case
            when aprov.cdteam is null then (select nmuser from aduser where cduser = aprov.cduser)
            when aprov.cdteam is not null then (select nmteam from adteam where cdteam = aprov.cdteam)
        end
    else (select nmuser from aduser where cduser = aprov.cduserapprov)
end as aprovador
, aprov.dtapprov, aprov.cdcycle as ciclo
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
left join gnvwapprovresp aprov on aprov.cdapprov = act.cdexecroute and aprov.cdprod = 174 and nrseq between 1 and (case when aprov.fgapprov is null then 1 else 100 end)
where plano.CDACTIONPLANTYPE = 23
order by actp.idactivity, act.idactivity, cdapprov, cdcycle

---------------------
-- Descrição: CUBO CM 01 CM_Geral - Dados para Indicadores do processo IN-CM.
--            Parte 1: Todos os registros (processo)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2019
-- Atualizada em: 06/2020
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABC1pFABCwh3 = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listaclientes
, coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCIQeABC45y = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaprodlote
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, his.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct in ('Atividade141029141729547', 'Atividade141111113134390', 'Decisão14102914531751', 'Decisão14102914536874', 'Decisão141111113212628', 'Atividade14102914543984'))
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=3234
/*
select wf.idprocess, wf.nmprocess, gnrev.NMREVISIONSTATUS as si, wf.dtstart
, case when wf.fgstatus = 3 or wf.fgstatus = 2 then (
    SELECT max(HIS.DTHISTORY+HIS.TMHISTORY) as dtlib
    FROM WFHISTORY HIS
    WHERE (HIS.FGTYPE = 2 or HIS.FGTYPE = 3) and his.idprocess = wf.idobject) else wf.dtfinish
end dtfinish
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status
from wfprocess wf
left outer join gnrevisionstatus gnrev on wf.cdstatus = gnrev.cdrevisionstatus
where wf.cdprocessmodel=1
*/

---------------------
-- Descrição: CUBO CM 02 CM_Aceitação - Dados para Indicadores do processo IN-CM.
--            Parte 2: Dados das atividades (Aceitação, Criação do Plano de ação e Aprovações GQ1 e GQ2)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2019
-- Atualizada em: 06/2020
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, his.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct in ('Atividade14102914347264', 'Atividade141029141729547', 'Atividade14102914355828','Atividade1518102355189'))
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=3234
/*
select wf.idprocess, str.nmstruct, wf.dtstart, case when HIS.NMUSER is null then HIS.nmrole else HIS.NMUSER end LiberadoPara, HIS.DTHISTORY + HIS.TMHISTORY as dtliberado
, dateadd(day, (wfa.qthours/60)/24, HIS.DTHISTORY + HIS.TMHISTORY) as prazo
, gnrev.NMREVISIONSTATUS as status
, hist.dtlib as ttt, hist.nmuser as nmexecut, hist.nmaction as acexecut
, case when hist.dtlib is null then datediff(dd, HIS.DTHISTORY+HIS.TMHISTORY, getdate()) else datediff(dd, HIS.DTHISTORY+HIS.TMHISTORY, hist.dtlib)+1 end leadtime
, (SELECT count(HIS1.IDOBJECT) as cicl
   FROM WFHISTORY HIS1
   WHERE  HIS1.FGTYPE = 6 and his1.idprocess = wf.idobject and HIS1.IDSTRUCT = STR.IDOBJECT and HIS1.DTHISTORY+HIS1.TMHISTORY <= HIS.DTHISTORY+HIS.TMHISTORY) as ciclo
FROM WFHISTORY HIS
inner join wfprocess wf on his.idprocess = wf.idobject
left outer join gnrevisionstatus gnrev on wf.cdstatus = gnrev.cdrevisionstatus
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Atividade14102914355828' or str.idstruct = 'Atividade1518102355189'
	or str.idstruct = 'Decisão14102914536874' or str.idstruct = 'Decisão141111113212628'
	or str.idstruct = 'Atividade14102914459502' or str.idstruct = 'Atividade176913390667')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
inner join (SELECT HIS1.DTHISTORY+HIS1.TMHISTORY as dtlib, his1.nmuser, his1.nmaction, his1.idprocess, his1.IDSTRUCT
    FROM WFHISTORY HIS1
    WHERE  HIS1.FGTYPE = 9) hist on hist.idprocess = wf.idobject and HISt.IDSTRUCT = str.IDobject and hist.dtlib = (SELECT top 1 min(HIS1.DTHISTORY+HIS1.TMHISTORY) as dtlib
        FROM WFHISTORY HIS1
        WHERE  HIS1.FGTYPE = 9 and his1.idprocess = wf.idobject and HIS1.DTHISTORY+HIS1.TMHISTORY >= HIS.DTHISTORY+HIS.TMHISTORY and HIS1.IDSTRUCT=STR.IDOBJECT
        order by dtlib asc)
WHERE HIS.FGTYPE = 6 and wf.cdprocessmodel=3234
order by idprocess,nmstruct,dtliberado
*/

---------------------
-- Descrição: CUBO CM 03 CM_Planejamento do plano de ação - Dados para Indicadores do processo IN-CM.
--            Parte 3: Dados das ações (Planos de ação)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2019
-- Atualizada em: 06/2020
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, HIS.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Atividade141029141729547' or str.idstruct = 'Atividade14102914459502')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=3234
/*
select actp.idactivity as plano, actp.nmactivity as nmplano
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
end as status_plano
, act.idactivity as atividade, act.nmactivity as nmatividade
, case act.fgstatus
    when 1 then 'Planejamento'
    when 2 then 'Aprovação do planejamento'
    when 3 then 'Execução'
    when 4 then 'Aprovação da execução'
    when 5 then 'Encerrada'
    WHEN 6 THEN 'Cancelada' 
    WHEN 7 THEN 'Cancelada' 
    WHEN 8 THEN 'Cancelada' 
    WHEN 9 THEN 'Cancelada' 
    WHEN 10 THEN 'Cancelada' 
    WHEN 11 THEN 'Cancelada'
end as status_act
, (select usr.nmuser from aduser usr where act.cduser = usr.cduser) as executor, act.dtstartplan, act.dtfinishplan, act.dtstart, act.dtfinish
, case
    when aprov.fgapprov = 1 then 'Aprovou'
    when aprov.fgapprov = 2 then 'Rejeitou'
end as aprovacao
, case
    when aprov.fgapprov is null then
        case
            when aprov.cdteam is null then (select nmuser from aduser where cduser = aprov.cduser)
            when aprov.cdteam is not null then (select nmteam from adteam where cdteam = aprov.cdteam)
        end
    else (select nmuser from aduser where cduser = aprov.cduserapprov)
end as aprovador
, aprov.dtapprov, aprov.cdcycle as ciclo
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
left join gnvwapprovresp aprov on aprov.cdapprov = act.cdexecroute and aprov.cdprod = 174 and nrseq between 1 and (case when aprov.fgapprov is null then 1 else 100 end)
where plano.CDACTIONPLANTYPE = 64
order by actp.idactivity, act.idactivity, cdapprov, cdcycle
*/

---------------------
-- Descrição: CUBO CM 04 CM_Plano de ação - Dados para Indicadores do processo IN-CM.
--            Parte 4: 
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2019
-- Atualizada em: 06/2020
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS statusproc
, plano.idactivity as Plano_id, plano.nmactivity as Plano_nm
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
, case plano.fgstatus
     when  5 then plano.dtfinish
     when  6 then plano.dtupdate
     when  7 then plano.dtupdate
     when  9 then plano.dtupdate
     when 10 then plano.dtupdate
     when 11 then plano.dtupdate
end as Plano_fimr
, (select nmuser from aduser where cduser = acao.cduser) as Acao_exec
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1 inner join addepartment dep on dep.cddepartment = rel.cddepartment where usr.cduser = acao.cduser) as Acao_area
, acao.idactivity as idAcao, acao.nmactivity as Acao_nm
, acao.dtstartplan as Acao_inicp, acao.dtfinishplan as Acao_fimpo, acao.dtstart as Acao_inicr
, case acao.fgstatus
     when  5 then acao.dtfinish
     when  6 then acao.dtupdate
     when  7 then acao.dtupdate
     when  9 then acao.dtupdate
     when 10 then acao.dtupdate
     when 11 then acao.dtupdate
end as Acao_fimr
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
inner JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
inner join gnactivity acao on plano.cdgenactivity = acao.cdactivityowner
left join gnvwapprovresp aprov on aprov.cdapprov = acao.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 or (fgpend is null and fgapprov is null))
      or (fgpend = 1 and fgapprov is null)) and aprov.cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
where cdprocessmodel=3234

---------------------
-- Descrição: CUBO01 - IN-CM_Geral
--
-- Comentário: Cubo completo.
-- Autor: Alvaro Adriano Beck
-- Criada em: 10/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABC1pFABCwh3 = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listaclientes
, coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCIQeABC45y = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaprodlote
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, his.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct in ('Atividade141029141729547', 'Atividade141111113134390', 'Decisão14102914531751', 'Decisão14102914536874', 'Decisão141111113212628', 'Atividade14102914543984'))
INNER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=3234
/*
union all
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABC1pFABCwh3 = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listaclientes
, coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCIQeABC45y = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaprodlote
, null as ciclo
, null as atividade
, null as atvHabilitada
, null as atvExecutada
, null as atvExecutor
, null as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where cdprocessmodel=3234 and wf.idprocess not in (Select wf.idprocess
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct in ('Atividade141029141729547', 'Atividade141111113134390', 'Decisão14102914531751', 'Decisão14102914536874', 'Decisão141111113212628', 'Atividade14102914543984'))
inner JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=3234
)
*/
---------------------
-- Descrição: CUBO02 - IN-CM_Aceitação
--
-- Comentário: Cubo completo.
-- Autor: Alvaro Adriano Beck
-- Criada em: 10/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, his.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct in ('Atividade14102914347264', 'Atividade141029141729547', 'Atividade14102914355828','Atividade1518102355189'))
INNER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=3234

---------------------
-- Descrição: CUBO03 - IN-CM_Elaboração do plano de ação
--
-- Comentário: Cubo completo.
-- Autor: Alvaro Adriano Beck
-- Criada em: 10/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, HIS.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Atividade141029141729547' or str.idstruct = 'Atividade14102914459502')
INNER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=3234


---------------------
-- Descrição: CUBO04 - IN-CM_Plano de ação
--
-- Comentário: Cubo completo.
-- Autor: Alvaro Adriano Beck
-- Criada em: 10/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS statusproc
, plano.idactivity as Plano_id, plano.nmactivity as Plano_nm
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
, case plano.fgstatus
    when 6 then plano.dtupdate
    when 7 then plano.dtupdate
    when 9 then plano.dtupdate
    when 10 then plano.dtupdate
    when 11 then plano.dtupdate
else plano.dtfinish end as Plano_fimr
, (select nmuser from aduser where cduser = acao.cduser) as Acao_exec
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1 inner join addepartment dep on dep.cddepartment = rel.cddepartment where usr.cduser = acao.cduser) as Acao_area
, acao.idactivity as idAcao, acao.nmactivity as Acao_nm
, acao.dtstartplan as Acao_inicp, acao.dtfinishplan as Acao_fimpo, acao.dtstart as Acao_inicr
, case acao.fgstatus
    when 6 then acao.dtupdate
    when 7 then acao.dtupdate
    when 9 then acao.dtupdate
    when 10 then acao.dtupdate
    when 11 then acao.dtupdate
else acao.dtfinish end as Acao_fimr
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
inner JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
inner join gnactivity acao on plano.cdgenactivity = acao.cdactivityowner
left join gnvwapprovresp aprov on aprov.cdapprov = acao.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 or (fgpend is null and fgapprov is null))
      or (fgpend = 1 and fgapprov is null)) and aprov.cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
where cdprocessmodel=3234

---------------------
-- Descrição: CUBO11 - AN-CM_Plano de ação
--
-- Comentário: Cubo completo.
-- Autor: Alvaro Adriano Beck
-- Criada em: 10/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS statusproc
, plano.idactivity as Plano_id, plano.nmactivity as Plano_nm
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
inner JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
inner join gnactivity acao on plano.cdgenactivity = acao.cdactivityowner
left join gnvwapprovresp aprov on aprov.cdapprov = acao.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 or (fgpend is null and fgapprov is null))
      or (fgpend = 1 and fgapprov is null)) and aprov.cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
where cdprocessmodel=1

---------------------
-- Descrição: CUBE01 - UA-DE_Geral
--
-- Comentário: Cubo completo.
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idProcess, wf.nmUserStart, gnrev.NMREVISIONSTATUS as incStatus, wf.nmProcess
, CASE wf.fgstatus WHEN 1 THEN 'In progress' WHEN 2 THEN 'Postponed' WHEN 3 THEN 'Cancelled' WHEN 4 THEN 'Finished' WHEN 5 THEN 'Blocked for editing' END AS procStatus
, wf.dtStart, wf.dtFinish
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) apprEnabled
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject) as apprPerformed
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as apprExecutor
, 1 as Qty
from DYNtds010 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where cdprocessmodel=4469

---------------------
-- Descrição: LeadTimeDOC - Lead Time Documetnos de Manutenção
--
-- Comentário: Em desenvolvimento
-- Autor: Alvaro Adriano Beck
-- Criada em: 12/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select CAST(CAST(ROUND(attribm.vlvalue,0) as int) as varchar(50)) as chamado
--, revm.iddocument, gnrevm.idrevision
, cast(coalesce((select substring((select ' | '+ rev.iddocument +'/'+ gnrev.idrevision + case doc.fgstatus when 2 then '' else '*' end as [text()]
                 from dcdocumentattrib attrib
                 inner join gnrevision gnrev on gnrev.cdrevision = attrib.cdrevision
                 inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision
                 inner join dcdocument doc on doc.cddocument = rev.cddocument
                 where attrib.vlvalue = attribm.vlvalue
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listadoc --listdoc--
, datediff(DD
    , coalesce((select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
        where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-DE-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (2))
                , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
        where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-DE-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (1)))
    , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
                where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-DE-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (3,4))
    )+1 as approvalTimeDE
, datediff(DD
    , coalesce((select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
        where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-QO-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (2))
                , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
        where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-QO-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (1)))
    , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
                where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-QO-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (3,4))
    )+1 as approvalTimeQO
, datediff(DD
    , coalesce((select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
        where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-QR-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (2))
                , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
        where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-QR-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (1)))
    , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
                where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-QR-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (3,4))
    )+1 as approvalTimeQR
, datediff(DD
    , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
        where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-DE-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (1))
    , (select top 1 max(stag1.dtapproval)
        from GNREVISIONSTAGMEM stag1
                where stag1.CDREVISION = (select max(attrib.cdrevision) from dcdocumentattrib attrib inner join dcdocrevision rev on rev.cdrevision = attrib.cdrevision and rev.iddocument like '%-RP-%' where attrib.CDATTRIBUTE = 235 and attrib.vlvalue = attribm.vlvalue)
            AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE in (3,4))
    )+1 as totalTime
, 1 as quantidade
from dcdocumentattrib attribm
where attribm.CDATTRIBUTE = 235 and attribm.vlvalue is not null --and attribm.vlvalue in ('186753')
group by attribm.vlvalue
order by attribm.vlvalue desc

---------------------
-- Descrição: FRETE
--
-- Comentário: Em desenvolvimento...
-- Autor: Alvaro Adriano Beck
-- Criada em: 12/2019
-- Atualizada em: -
--------------------------------------------------------------------------------
select wf.idprocess as identificador, wf.nmprocess as titulo, gnrev.NMREVISIONSTATUS as status
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, wf.dtstart + wf.tmstart as dtinicio, wf.dtfinish + wf.tmfinish as dtfim
, form.fr001 as solicitante, form.fr002 as depsolicit, form.fr005 as nmorigem, form.fr007 as cidadeorigem, uforig.a001 as uforig
, form.fr011 as dtcoletasug, form.fr012 as dtcoletaprog, form.fr013 as dtcoletareal
, form.fr014 as nmdest, form.fr016 as cidadedest, ufdest.a001 as ufdest
, form.fr020 as dtentregasug, form.fr021 as dtentregaprog, form.fr022 as dtentregareal
, form.fr023 as ordeminterna
, case form.fr042 when 1 then 'Frota interna' when 2 then 'Transportadora' else '' end as tptransporte
, case form.fr042 when 1 then form.fr043 +' | '+ form.fr044  when 2 then form.fr035 else '' end as transportador
, case form.fr045 when 1 then 'Sim' else 'Não' end transf_entre_plantas
, grid.fr001 as cod_pedido
from DYNsolfrete form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left join DYNai001uf uforig on form.OIDABCM8HDQXDSPPAM = uforig.oid
left join DYNai001uf ufdest on form.OIDABCXL0LYZDMLX6C = ufdest.oid
left join DYNsolfrete01 grid on grid.OIDABC48UFLJ6RGD63 = form.oid
where wf.cdprocessmodel = 4922

---------------------
-- Descrição: Analisys CM 01 CM_General information - Dados para Indicadores do processo UA-CM.
--            Parte 1: Todos os registros (processo)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2020
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'In progress' WHEN 2 THEN 'Suspended' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'Finished' WHEN 5 THEN 'Blocked for edition' END AS statusproc
, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, (select substring((
select ' | '+ (select il.nmlabel from efitemlanguage il
                         inner join efstructform ef on ef.oid = il.OIDSTRUCTFORM
                         inner join emattrmodel em on ef.oidattributemodel = em.oid
                         inner join EFREVISIONFORM rf on ef.OIDREVISIONFORM = rf.oid and rf.fgcurrent = 1
where il.FGLANGUAGE = 1 and rf.idform = 'QUA015' and idname = coluna and oidentity = (select oid from EMENTITYMODEL where idname = 'tds015')) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043,
                              tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060,
                              tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
, (select substring((
select ' | '+ (select il.nmlabel from efitemlanguage il
                         inner join efstructform ef on ef.oid = il.OIDSTRUCTFORM
                         inner join emattrmodel em on ef.oidattributemodel = em.oid
                         inner join EFREVISIONFORM rf on ef.OIDREVISIONFORM = rf.oid and rf.fgcurrent = 1
where il.FGLANGUAGE = 1 and rf.idform = 'QUA015' and idname = coluna and oidentity = (select oid from EMENTITYMODEL where idname = 'tds015')) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds067,tds068,tds069,tds070,tds071,tds072,tds073,tds074,tds075,tds076,tds077,tds078,tds079,tds080,tds081,tds082,tds083,tds084,tds085,tds086,
                              tds087,tds088,tds089,tds090,tds091,tds092,tds093,tds094,tds095,tds096,tds097,tds098,tds099,tds100,tds101,tds102,tds103,tds156,tds157,tds158,tds164)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as areasaval
, coalesce((select substring((select ' | '+ tbs001 as [text()] from DYNtbs040 where OIDABC1pFABCwh3 = form.oid FOR XML PATH('')), 4, 1000)), 'NA') as listaclientes
, coalesce((select substring((select ' | # '+ coalesce(tbs002,' ') +' - '+ coalesce(tbs001,' ') +' ('+ coalesce(tbs003,' ') +' | '+ coalesce(tbs004,' ') +' | '+ coalesce(format(tbs005,'dd/MM/yyyy'),' ') +' | '+ coalesce(tbs006,' ') +')' as [text()] from DYNtbs024 where OIDABCIQeABC45y = form.oid FOR XML PATH('')), 4, 40000)), 'NA') as listaprodlote
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, his.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct in ('Atividade141029141729547', 'Atividade141111113134390', 'Decisão14102914531751', 'Decisão14102914536874', 'Decisão141111113212628', 'Atividade14102914543984', 'Atividade14102914355828', 'Atividade1518102355189'))
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=4468

---------------------
-- Descrição: Analisys CM 02 CM_Acceptance - Dados para Indicadores do processo UA-CM.
--            Parte 2: Dados das atividades (Aceitação, Criação do Plano de ação e Aprovações GQ1 e GQ2)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2020
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'In progress' WHEN 2 THEN 'Suspended' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'Finished' WHEN 5 THEN 'Blocked for edition' END AS statusproc
, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, datediff(DD, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
), (his.dthistory + his.tmhistory)) as atvLeadTime
, dateadd(mi, wfa.qthours, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
)) as atvDueDate
, case when datediff(DD, dateadd(mi, wfa.qthours, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
)), (his.dthistory + his.tmhistory)) <= 0 then 'On Time' else 'Delayed' end as atvLeadTimeStatus
, his.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct in ('Atividade14102914347264', 'Atividade141029141729547', 'Atividade14102914355828','Atividade1518102355189', 'Atividade14102914355828', 'Atividade1518102355189'))
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=4468

---------------------
-- Descrição: Analisys CM 03 CM_Action Plan Planning - Dados para Indicadores do processo UA-CM.
--            Parte 3: Dados das ações (Planos de ação)
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2020
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'In progress' WHEN 2 THEN 'Suspended' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'Finished' WHEN 5 THEN 'Blocked for edition' END AS statusproc
, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, (row_number() over (PARTITION BY wf.idprocess,str.nmstruct order by wf.idprocess,str.nmstruct,his.dthistory + his.tmhistory)) as ciclo
, str.nmstruct as atividade
, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
) as atvHabilitada
, his.dthistory + his.tmhistory as atvExecutada
, datediff(DD, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
), (his.dthistory + his.tmhistory)) as atvLeadTime
, dateadd(mi, wfa.qthours, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
)) as atvDueDate
, case when datediff(DD, dateadd(mi, wfa.qthours, (select top 1 his1.dthistory + his1.tmhistory
   from wfhistory his1
   where his1.idprocess = wf.idobject and HIS1.FGTYPE = 6 and his1.IDSTRUCT = his.IDSTRUCT
         and his1.dthistory + his1.tmhistory < his.dthistory + his.tmhistory
   order by his1.dthistory + his1.tmhistory desc
)), (his.dthistory + his.tmhistory)) <= 0 then 'On Time' else 'Delayed' end as atvLeadTimeStatus
, HIS.NMUSER as atvExecutor
, his.nmaction as atvAcao
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and (str.idstruct = 'Atividade141029141729547' or str.idstruct = 'Atividade14102914459502')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
where cdprocessmodel=4468

---------------------
-- Descrição: Analisys CM 04 CM_Action Plan and actions data - Dados para Indicadores do processo UA-CM.
--            Parte 4: 
--
--
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2020
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart as dtabertura
, CASE wf.fgstatus when 3 then (select top 1 his1.dthistory + his1.tmhistory
                                from wfhistory his1
                                inner join wfprocess wf1 on his1.idprocess = wf1.idobject and wf1.idprocess = wf.idprocess
                                where HIS1.FGTYPE = 3
                                order by his1.dthistory + his1.tmhistory desc
) else wf.dtfinish end as dtfechamento
, CASE wf.fgstatus WHEN 1 THEN 'In progress' WHEN 2 THEN 'Suspended' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'Finished' WHEN 5 THEN 'Blocked for edition' END AS statusproc
, plano.idactivity as Plano_id, plano.nmactivity as Plano_nm
, case plano.fgstatus
     when  1 then 'Planning'
     when  2 then 'Planning approval'
     when  3 then 'In progress'
     when  4 then 'Execution approval'
     when  5 then 'Finished'
     when  6 then 'Canceled'
     when  7 then 'Canceled'
     when  9 then 'Canceled'
     when 10 then 'Canceled'
     when 11 then 'Canceled'
end as Plano_st
, case plano.fgstatus
     when  5 then plano.dtfinish
     when  6 then plano.dtupdate
     when  7 then plano.dtupdate
     when  9 then plano.dtupdate
     when 10 then plano.dtupdate
     when 11 then plano.dtupdate
end as Plano_fimr
, (select nmuser from aduser where cduser = acao.cduser) as Acao_exec
, (select dep.nmdepartment from aduser usr inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.fgdefaultdeptpos = 1 inner join addepartment dep on dep.cddepartment = rel.cddepartment where usr.cduser = acao.cduser) as Acao_area
, acao.idactivity as idAcao, acao.nmactivity as Acao_nm
, acao.dtstartplan as Acao_inicp, acao.dtfinishplan as Acao_fimp, acao.dtstart as Acao_inicr
, case when (datediff(DD, acao.dtfinishplan, case when acao.dtfinish is not null then acao.dtfinish else getdate() end) <= 0) then 'On Time' else 'Delayed' end as Acao_leadtimeStatus
, case acao.fgstatus
     when  5 then acao.dtfinish
     when  6 then acao.dtupdate
     when  7 then acao.dtupdate
     when  9 then acao.dtupdate
     when 10 then acao.dtupdate
     when 11 then acao.dtupdate
end as Acao_fimr
, case acao.fgstatus
     when  1 then 'Planning'
     when  2 then 'Planning approval'
     when  3 then 'In progess'
     when  4 then 'Execution approval'
     when  5 then 'Finished'
     when  6 then 'Canceled'
     when  7 then 'Canceled'
     when  9 then 'Canceled'
     when 10 then 'Canceled'
     when 11 then 'Canceled'
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
    else 'Not'
end as acao_disp
, case when aprov.fgapprov = 1 then 'Yes' when aprov.fgapprov = 2 then 'Not' end as Apr_acao
, case when (coalesce(aprov.nmuserapprov, nmuser)) is not null then (coalesce(aprov.nmuserapprov, nmuser)) end as Apr_exec
, aprov.dtapprov as Apr_dt, aprov.cdcycle as qtdCiclos
, case when (acao.dtfinish is null and aprov.dtapprov is null) then null when (acao.dtfinish is null) then datediff(DD, acao.dtfinish, getdate()) else datediff(DD, acao.dtfinish, aprov.dtapprov) end as Apr_LeadTime
, 1 as quantidade
from WFPROCESS wf
inner JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
inner join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
inner JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
inner JOIN gnactivity plano ON gnpl.cdgenactivity = plano.cdgenactivity
inner join gnactivity acao on plano.cdgenactivity = acao.cdactivityowner
left join gnvwapprovresp aprov on aprov.cdapprov = acao.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 or (fgpend is null and fgapprov is null))
      or (fgpend = 1 and fgapprov is null)) and aprov.cdcycle = (select max(cdcycle) from gnvwapprovresp aprov2 where aprov2.cdprod = aprov.cdprod and aprov2.cdapprov = aprov.cdapprov)
where cdprocessmodel=4468


---------------------
-- Descrição: Painel de gestão de CM
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2021
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart, wf.dtfinish
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS statusproc
, gnrev.NMREVISIONSTATUS as status
, 1 as quantidade
from WFPROCESS wf
left outer join gnrevisionstatus gnrev on wf.cdstatus = gnrev.cdrevisionstatus
where wf.cdprocessmodel = 4468

---------------------
-- Descrição: Painel de Reclamação de Mercado
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2022
-- Atualizada em: -
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart+wf.tmstart as dtabertura, wf.dtfinish+wf.tmfinish as dtfechamento
, form.tds004 as prodcod, form.tds005 as proddesc, form.tds006 as prodlote
, clini.tbs001 as critini, clfin.tbs001 as critfinal, ccr.tbs001 as catcausaraiz
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status_processo
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102992123382' and str.idprocess=wf.idobject) as registrarRM_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102992123382' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as registrarRM_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade14102992123382' and str.idprocess=wf.idobject) as registrarRM_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102992133595' and str.idprocess=wf.idobject) as investigarRM_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102992133595' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as investigarRM_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Atividade14102992133595' and str.idprocess=wf.idobject) as investigarRM_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão14102992143534' and str.idprocess=wf.idobject) as AprovarSUP_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão14102992143534' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarSUP_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão14102992143534' and str.idprocess=wf.idobject) as AprovarSUP_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1516102916658' and str.idprocess=wf.idobject) as AprovarPRD_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1516102916658' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarPRD_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1516102916658' and str.idprocess=wf.idobject) as AprovarPRD_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão157718229336' and str.idprocess=wf.idobject) as AprovarMAN_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão157718229336' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarMAN_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão157718229336' and str.idprocess=wf.idobject) as AprovarMAN_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1577182214624' and str.idprocess=wf.idobject) as AprovarDME_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1577182214624' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarDME_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1577182214624' and str.idprocess=wf.idobject) as AprovarDME_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1577182212159' and str.idprocess=wf.idobject) as AprovarPeD_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1577182212159' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarPeD_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1577182212159' and str.idprocess=wf.idobject) as AprovarPeD_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão151610294178' and str.idprocess=wf.idobject) as AprovarARM_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão151610294178' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarARM_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão151610294178' and str.idprocess=wf.idobject) as AprovarARM_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1516102925488' and str.idprocess=wf.idobject) as AprovarQFR_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1516102925488' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarQFR_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1516102925488' and str.idprocess=wf.idobject) as AprovarQFR_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1516102910388' and str.idprocess=wf.idobject) as AprovarCTQ_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1516102910388' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarCTQ_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1516102910388' and str.idprocess=wf.idobject) as AprovarCTQ_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1573193017951' and str.idprocess=wf.idobject) as AprovarETB_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1573193017951' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarETB_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1573193017951' and str.idprocess=wf.idobject) as AprovarETB_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1573193023204' and str.idprocess=wf.idobject) as AprovarTER_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1573193023204' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarTER_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1573193023204' and str.idprocess=wf.idobject) as AprovarTER_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão157718221789' and str.idprocess=wf.idobject) as AprovarRPT_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão157718221789' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarRPT_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão157718221789' and str.idprocess=wf.idobject) as AprovarRPT_dtini
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Decisão1516102835296' and str.idprocess=wf.idobject) as AprovarAAD_dtexe
, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Decisão1516102835296' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as AprovarAAD_resp
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
WHERE  str.idstruct = 'Decisão1516102835296' and str.idprocess=wf.idobject) as AprovarAAD_dtini
, 1 as quantidade
from wfprocess wf
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNtds014 form on (gnf.oidentityreg = form.oid)
left join DYNtbs028 clini on clini.oid = form.OIDABCAEYABCCTT
left join DYNtbs027 clfin on clfin.oid = form.OIDABCGKSABC3AJ
left join DYNtbs022 ccr on ccr.oid = form.OIDABCK1AABCETU
where wf.cdprocessmodel = 3238
and exists (select 1 from wfstruct wfs where wfs.idprocess = wf.idobject and wfs.idstruct in ('Atividade14102992123382','Atividade14102992133595','Decisão14102992143534','Decisão1516102916658','Decisão157718229336','Decisão1577182214624','Decisão1577182212159','Decisão151610294178','Decisão1516102925488','Decisão1516102910388','Decisão1573193017951','Decisão1573193023204','Decisão157718221789','Decisão1516102835296'))

---------------------
-- Descrição: UA DE
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2021
-- Atualizada em: 07/2022
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart, wf.dtfinish
, CASE wf.fgstatus
    WHEN 1 THEN 'In progress'
    WHEN 2 THEN 'Suspended'
    WHEN 3 THEN 'Canceled'
    WHEN 4 THEN 'Closed'
    WHEN 5 THEN 'Locked from editing'
END AS statusproc
, gnrev.NMREVISIONSTATUS as statusExec
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, (SELECT str.dtexecution+str.tmexecution FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idprocess = wf.idobject and str.idobject = wfa.idobject and str.idstruct = 'Decisão141027113714228') qaApprov
, 1 as Qty
, criticidade.tbs002 as Critic
from DYNtds010 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
LEFT join DYNtbs002 criticidade on form.OIDABC4SFABC3QP = criticidade.oid
where wf.cdprocessmodel = 4469

---------------------
-- Descrição: UA CM
--	  Campos: 
-- 
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2021
-- Atualizada em: 07/2022
--------------------------------------------------------------------------------
Select wf.idprocess, wf.nmprocess, wf.dtstart, wf.dtfinish
, CASE wf.fgstatus
    WHEN 1 THEN 'In progress'
    WHEN 2 THEN 'Suspended'
    WHEN 3 THEN 'Canceled'
    WHEN 4 THEN 'Closed'
    WHEN 5 THEN 'Locked from editing'
END AS statusproc
, gnrev.NMREVISIONSTATUS as statusExec
, CASE form.TDS016
    WHEN 1 THEN 'Critical CM'
    WHEN 2 THEN 'Non-Critical CM'
END AS CRITICI
, cast(coalesce((select substring((select ' | '+ gnactp.idactivity as [text()] from gnactivity gnact
                 left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
                 left JOIN gnactionplan gnpl ON gnpl.cdgenactivity = stpl.cdactionplan
                 left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
                 where wf.CDGENACTIVITY = gnact.CDGENACTIVITY
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listaplacao --listaplação--
, (SELECT str.dtexecution+str.tmexecution FROM WFSTRUCT STR, WFACTIVITY WFA WHERE str.idprocess = wf.idobject and str.idobject = wfa.idobject and str.idstruct = 'Decisão14102914536874') qaApprov
, usr.nmuser as Owner
, case form.tds106 when 0 then 'No' when 1 then 'Yes' end as regulatoryImpact
, (select impact.TDS004 from DYNtds043 impact where impact.OIDABC8EEABCZHC = form.oid and impact.OIDABCVHKABC73U = '4749662ce816f492006c8a9fada7d746') as AnnualRepComm
, 1 as Qty
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join aduser usr on usr.cduser = wf.cduserstart
where wf.cdprocessmodel = 4468


