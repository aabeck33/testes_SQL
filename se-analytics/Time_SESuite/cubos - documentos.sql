select count(*)
from 
--DCAUDITSYSTEM
--DCPRINTCOPYPROT
--DCPRINTCOPYPROTdoc
--DCPRINTCOPYCANCEL

----------------------------------
select rev.cddocument,cat.idcategory, rev.iddocument, gnrev.idrevision, rev.nmtitle, docatt1.NMVALUE as indexcliente
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' end statusdoc
, moti.nmreason as motivorev
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left join dcdocumentattrib docatt1 on docatt1.cddocument = rev.cddocument and cdattribute = 203
inner join dcdocument doc on rev.cddocument = doc.cddocument
left join GNREASON moti on moti.cdreason = gnrev.CDREASON
--where fgcurrent=1
order by rev.CDDOCUMENT

/*
select * from adattribute where nmlabel='edição farmacopeica'
select * from dcdocumentattrib where cdattribute = 203
select * from dcdocrevision where cddocument = 17647
--
select list.NMATTRIBUTE from dcdocumentattrib att
inner join dcdocrevision rev on rev.CDDOCUMENT=att.cddocument
inner join adattribute atr on atr.cdattribute=att.cdattribute
inner join ADATTRIBVALUE list on list.cdattribute = att.cdattribute and list.cdvalue = att.cdvalue
where atr.nmlabel like '%sap%'
*/
-----------------------------------------------------------
Select wf.idprocess, wf.nmprocess
/*
, gnactp.fgstatus, gnpl.cdactionplan
, gnpl.cdgenactivity, gnactp.DTSTART, gnactp.dtfinish
, gnactp.dtstartplan, gnactp.dtfinishplan, stpl.cdassocactionplan
*/
, gnactp.idactivity as idplano, gnactp.nmactivity as nomeplano
, atividade.fgstatus, atividade.idactivity, atividade.nmactivity, atividade.DTSTART
, atividade.dtfinish, atividade.dtstartplan,atividade.dtfinishplan
, (select nmuser from aduser where cduser=atividade.cduser) as executor
from wfprocess wf
INNER JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
inner join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
INNER JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
INNER JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
inner join gnactivity atividade on atividade.cdactivityowner = gnactp.cdgenactivity
where wf.cdprocessmodel in (1, 17, 28)
----------------------------------------------------------------
select cat.idcategory +' - '+ cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
,rev.cdrevision,rev.cddocument,FGCURRENT
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' end statusdoc
, moti.nmreason as motivorev
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.NRCYCLE as ciclo, stag.dtdeadline, stag.qtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, stag.dtapproval as dtexecut
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
left join GNREASON moti on moti.cdreason = gnrev.CDREASON
where fgcurrent <> 1 and doc.fgstatus < 4 and rev.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
order by cat.idcategory, rev.iddocument, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE


---------------------
-- Descrição: Lab01) Relação de solicitação de Ras: Identificador x título x código SAP 
--                                           x lote x centro de trabalho x versão de emissão x motivo da emissão
--            CATEGORIAS: 4.2
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select req.IDREQUEST, req.NMREQUEST
, req.DTREQUEST as dtabertura
, cast(coalesce((select substring((select ' | '+ docrev.iddocument as [text()] from DCPRINTREQUEST prt
                 inner join dcdocrevision docrev on docrev.cddocument = prt.cddocument and fgcurrent = 1
                 where prt.cdrequest = req.cdrequest
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listadocumentos --listadocumentos--
, replace(replace(rtrim(ltrim((select cast(dsvalue  as varchar(4000)) from GNREQUESTATTRIB where cdrequest = req.cdrequest and cdattribute = 159))), CHAR(10), ' | '), CHAR(13), '') as codigosap
, replace(replace(rtrim(ltrim((select cast(dsvalue  as varchar(4000)) from GNREQUESTATTRIB where cdrequest = req.cdrequest and cdattribute = 160))), CHAR(10), ' | '), CHAR(13), '') as lote
, replace(replace(rtrim(ltrim((select cast(dsvalue  as varchar(4000)) from GNREQUESTATTRIB where cdrequest = req.cdrequest and cdattribute = 161))), CHAR(10), ' | '), CHAR(13), '') as lotecontrole
, (select attvl.nmattribute from GNREQUESTATTRIB gnatt inner join adattribvalue attvl on attvl.cdattribute = gnatt.cdattribute and attvl.cdvalue = gnatt.cdvalue where cdrequest = req.cdrequest and gnatt.cdattribute = 170) as centrotrab
, (select attvl.nmattribute from GNREQUESTATTRIB gnatt inner join adattribvalue attvl on attvl.cdattribute = gnatt.cdattribute and attvl.cdvalue = gnatt.cdvalue where cdrequest = req.cdrequest and gnatt.cdattribute = 169) as versaoemissao
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from SRREQUESTATTRIBMUL gnatt
                 inner join adattribvalue attvl on attvl.cdattribute = gnatt.cdattribute and attvl.cdvalue = gnatt.cdvalue
                 where cdrequest = req.cdrequest and gnatt.cdattribute = 162
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listamotivo --listadocumentos--
--, (select attvl.nmattribute from SRREQUESTATTRIBMUL gnatt inner join adattribvalue attvl on attvl.cdattribute = gnatt.cdattribute and attvl.cdvalue = gnatt.cdvalue where cdrequest = req.cdrequest and gnatt.cdattribute = 162) as motivo
--, docrev.iddocument
, 1 as quantidade
from GNREQUEST req
--inner join DCPRINTREQUEST prt on prt.cdrequest = req.cdrequest
--inner join dcdocrevision docrev on docrev.cddocument = prt.cddocument and fgcurrent = 1
--select * from GNREQUESTATTRIB where cdattribute = 159
where req.CDREQUESTTYPE in (39)


---------------------
-- Descrição: Lab07a) categoria x identificador x título x revisão x ciclo x crítica x usuário
--            CATEGORIAS: FEIN/MAIN/RAIN/MAEM/RAEM/MG/FEMP/MAMP/RAMP/FEPA/MAPA FQ/
--                        MAPA MIC/RAPA LIB/RAPA EST/RAMIC/RAMIC RA/RA GERAL/MAVL/RAVL
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select cat.idcategory +' - '+ cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
, gnrev.dtrevision as dtrev
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' end statusdoc
, moti.nmreason as motivorev
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.NRCYCLE as ciclo, stag.qtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
, coalesce((select substring((select ' | '+ cast(crit.dscritic as varchar(4000)) as [text()] from GNREVISIONCRITIC crit where crit.cdrevision = rev.cdrevision and crit.nrcycle = stag.nrcycle FOR XML PATH('')), 4, 4000)), 'NA') as listacriticas --listacriticas--
, 1 as quantidade
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
left join GNREASON moti on moti.cdreason = gnrev.CDREASON
where doc.fgstatus = 2 and rev.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
and stag.dtdeadline is not null and cat.cdcategory in (126,127,113,129,116,117,120,121,122,138,128,114,118,123,124,131,134,139,133)
order by cat.idcategory, rev.iddocument, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE


---------------------
-- Descrição: Lab07b) categoria x identificador x título x revisão x fase x usuário x data
--            CATEGORIAS: FEIN/MAIN/RAIN/MAEM/RAEM/MG/FEMP/MAMP/RAMP/FEPA/MAPA FQ/
--                        MAPA MIC/RAPA LIB/RAPA EST/RAMIC/RAMIC RA/RA GERAL/MAVL/RAVL
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select cat.idcategory +' - '+ cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' end statusdoc
, moti.nmreason as motivorev
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.NRCYCLE as ciclo, stag.qtdeadline
, stag.dtdeadline as dtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, stag.dtapproval as dtexecut
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
, case when (select nmvalue from dcdocumentattrib where cdattribute = 204 and cdrevision = rev.cdrevision) is null then 'NA' else 
(select nmvalue from dcdocumentattrib where cdattribute = 204 and cdrevision = rev.cdrevision) end Indexacao_cliente
, 1 as quantidade
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
left join GNREASON moti on moti.cdreason = gnrev.CDREASON
where doc.fgstatus in (1,3) and rev.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
and stag.dtdeadline is not null and cat.cdcategory in (126,127,113,129,116,117,120,121,122,138,128,114,118,123,124,131,134,139,133)
order by cat.idcategory, rev.iddocument, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE


---------------------
-- Descrição: Lab06) categoria x identificador x título x revisão x 
--            identificador do documento relacionado x título do documento relacionado
--            CATEGORIAS: FEIN/MAIN/RAIN/MAEM/RAEM/MG/FEMP/MAMP/RAMP/FEPA/MAPA FQ/
--                        MAPA MIC/RAPA LIB/RAPA EST/RAMIC/RAMIC RA/RA GERAL/MAVL/RAVL
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select cat.idcategory +' - '+ cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then '/do' when 5 then 'Indexação' end statusdoc
, gnrev.dtrevision as dtrev
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision
where assoc.cdrevision = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as compostode --listadocfilho--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevision = revc.cdrevision
where assoc.cdrevisionassoc = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as usadoem --listadocpai--
, 1 as quantidade
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
where doc.fgstatus < 4 and rev.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
and cat.cdcategory in (126,127,113,129,116,117,120,121,122,138,128,114,118,123,124,131,134,139,133)
and rev.fgcurrent = 1
order by cat.idcategory, rev.iddocument


---------------------
-- Descrição: Lab07c) categoria x identificador x título x revisão x indexação Cliente
--            CATEGORIAS: FEIN/MAIN/MAEM/MG/FEMP/MAMP/FEPA/MAPA FQ/MAPA MIC/MAVL
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select cat.idcategory +' - '+ cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' end statusdoc
, case when (select nmvalue from dcdocumentattrib where cdattribute = 204 and cdrevision = rev.cdrevision) is null then 'NA' else 
(select nmvalue from dcdocumentattrib where cdattribute = 204 and cdrevision = rev.cdrevision) end Indexacao_cliente
, gnrev.dtrevision as dtrev
, gnrev.dtvalidity as dtvalidade
, 1 as quantidade
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
where doc.fgstatus < 4 and rev.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
and cat.cdcategory in (126,127,113,129,116,117,120,121,122,138)
and rev.fgcurrent = 1
order by cat.idcategory, rev.iddocument


---------------------
-- Descrição: Uso de áreas e equipes na segurança das categorias de documentos
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select quem, oque, permissoes
from (select case
           when (doc.CDTEAM is not null and doc.CDDEPARTMENT is null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
           when (doc.CDTEAM is null and doc.CDDEPARTMENT is not null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem
, 'Tem acesso '+ case doc.FGPERMISSION when 1 then 'concedido' when 2 then 'negado' end
  +' na categoria: '+ cat.idcategory +' - '+ cat.NMCATEGORY as Oque, 'Documentos' as Modulo
,eq.idteam, cat.idcategory, doc.CDACCESSROLE
,cast ((select substring(__sub.__permissoes, 2, 4000) as [text()] from (
        select case dcc.FGACCESSADD when 1 then ';Incluir' else '' end
        + case dcc.FGACCESSEDIT when 1 then ';Alterar' else '' end
        + case dcc.FGACCESSDELETE when 1 then ';Excluir' else '' end
        + case dcc.FGACCESSKNOW when 1 then ';Conhecimento' else '' end
        + case dcc.FGACCESSTRAIN when 1 then ';Treinamento' else '' end
        + case dcc.FGACCESSVIEW when 1 then ';Visualizar' else '' end
        + case dcc.FGACCESSPRINT when 1 then ';Imprimir' else '' end
        + case dcc.FGACCESSPHYSFILE when 1 then ';Arquivar' else '' end
        + case dcc.FGACCESSREVISION when 1 then ';Revisar' else '' end
        + case dcc.FGACCESSCOPY when 1 then ';Distribuir cópia' else '' end
        + case dcc.FGACCESSREGTRAIN when 1 then ';Registrar treinamento'  else '' end
        + case dcc.FGACCESSCANCEL when 1 then ';Cancelar' else '' end
        + case dcc.FGACCESSSAVE when 1 then ';Salvar localmente' else '' end
        + case dcc.FGACCESSSIGN when 1 then ';Assinatura' else '' end
        + case dcc.FGACCESSNOTIFY when 1 then ';Notificação' else '' end
        + case dcc.FGACCESSEDITKNOW when 1 then ';Avaliar aplicabilidade' else '' end
        + case dcc.FGACCESSADDCOMMENT when 1 then ';Incluir comentário' else '' end as __permissoes
from DCCATEGORYDOCROLE dcc
where dcc.CDACCESSROLE = doc.CDACCESSROLE) __sub
for XML path('')) as varchar(4000)) as permissoes
from DCCATEGORYDOCROLE doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
left join addepartment dep on dep.cddepartment = doc.CDdepartment
inner join dccategory cat on cat.CDCATEGORY = doc.CDCATEGORY
where (doc.CDTEAM is not null and doc.CDDEPARTMENT is null) or (doc.CDTEAM is null and doc.CDDEPARTMENT is not null)
) __sub --where idteam = 'ACESSO TOTAL POP BSB' and idcategory = 'VET BSB'


---------------------
-- Descrição: DME01a e 02a) Todos os documentos com fases do útimo ciclo do fluxo de revisão
--            CATEGORIAS: 1 - POP TDS, 2 - AVAL TDS, 3 - FORM TDS, 4 - LGB TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select rev.iddocument, rev.nmtitle, gnrev.idrevision, rev.cdrevision
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
,rev.fgcurrent, 'ANOVIS' as unidade
, gnrev.dtrevision as dtrevisao
, gnrev.dtvalidity as dtvalidade
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.qtdeadline, stag.NRCYCLE as ciclo, stag.NRSEQUENCE, stag.CDMEMBERINDEX
, stag.dtdeadline as dtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, stag.dtapproval as dtexecut
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
, case when cast(cast(stag.NRCYCLE as varchar(255))+cast(stag.FGSTAGE as varchar(255))+cast(stag.NRSEQUENCE as varchar(255))+cast(stag.CDMEMBERINDEX as varchar(255)) as integer) =
       (select min(cast(cast(stag2.NRCYCLE as varchar(255))+cast(stag2.FGSTAGE as varchar(255))+cast(stag2.NRSEQUENCE as varchar(255))+cast(stag2.CDMEMBERINDEX as varchar(255)) as integer))
        from GNREVISIONSTAGMEM stag2
        where stag2.cdrevision = stag.cdrevision
       ) then datediff(dd,gnrev.DTREVCREATE,stag.DTAPPROVAL)
  else
       datediff(dd,(select stag3.dtapproval from GNREVISIONSTAGMEM stag3
                    where cast(cast(stag3.NRCYCLE as varchar(255))+cast(stag3.FGSTAGE as varchar(255))+cast(stag3.NRSEQUENCE as varchar(255))+cast(stag3.CDMEMBERINDEX as varchar(255)) as integer) = 
                           (select max(cast(cast(stag2.NRCYCLE as varchar(255))+cast(stag2.FGSTAGE as varchar(255))+cast(stag2.NRSEQUENCE as varchar(255))+cast(stag2.CDMEMBERINDEX as varchar(255)) as integer)) as code
        from GNREVISIONSTAGMEM stag2
        where stag2.cdrevision = stag.cdrevision and cast(cast(stag2.NRCYCLE as varchar(255))+cast(stag2.FGSTAGE as varchar(255))+cast(stag2.NRSEQUENCE as varchar(255))+cast(stag2.CDMEMBERINDEX as varchar(255)) as integer) <
              cast(cast(stag.NRCYCLE as varchar(255))+cast(stag.FGSTAGE as varchar(255))+cast(stag.NRSEQUENCE as varchar(255))+cast(stag.CDMEMBERINDEX as varchar(255)) as integer)
         and stag2.dtapproval is not null) and stag3.cdrevision = rev.cdrevision),stag.DTAPPROVAL)
  end leadtime
, his.dtaccess as dtcancel
, his.NMREVISION as revcancel, his.nmuser, cast(his.dsjustify as varchar(4000)) as jutificativa
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision
where assoc.cdrevision = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as compostode --listadocfilho--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevision = revc.cdrevision
where assoc.cdrevisionassoc = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as usadoem --listadocpai--
, 1 as quantidade
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
where rev.cdcategory in (105,106,107,108)
order by rev.iddocument, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE, stag.CDMEMBERINDEX

---------------------
-- Descrição: DME01b e 02b) Todos os documentos sem fases do fluxo de revisão
--            CATEGORIAS: 1 - POP TDS, 2 - AVAL TDS, 3 - FORM TDS, 4 - LGB TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select rev.iddocument, rev.nmtitle, gnrev.idrevision, rev.cdrevision
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, gnrev.dtrevision as dtrevisao
, gnrev.dtvalidity as dtvalidade
, his.dtaccess as dtcancel
, his.NMREVISION as revcancel, his.nmuser, cast(his.dsjustify as varchar(4000)) as jutificativa
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision
where assoc.cdrevision = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as compostode --listadocfilho--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevision = revc.cdrevision
where assoc.cdrevisionassoc = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as usadoem --listadocpai--
, 1 as quantidade
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
where rev.cdcategory in (105,106,107,108)
order by rev.iddocument

---------------------
-- Descrição: DME04) Distribuição de cópias
--            CATEGORIAS: 1 - POP TDS, 2 - AVAL TDS, 3 - FORM TDS, 4 - LGB TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select rev.cdrevision, rev.iddocument, rev.nmtitle, gnrev.idrevision
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, gnrev.dtrevision as dtrevisao
, prot.DTPRINTCOPYPROT as dtdistribuida
, prot.DTUSERRECCONF as dtconfirmada
, copyst.NMCOPYSTATION
, (select max(prc.DTPRINTCOPYCANCEL) from DCPRINTCOPYCANCEL prc where prc.cddocument = rev.cddocument and prc.cdrevision = rev.cdrevision) as dtrecolhida
, 1 as quantidade
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join DCPRINTCOPYprotdoc protdoc on protdoc.cdrevision = rev.cdrevision
inner join DCPRINTCOPYprot prot on prot.cdprintcopyprot =  protdoc.cdprintcopyprot
inner join dccopystation copyst on copyst.CDCOPYSTATION = prot.CDCOPYSTATION
where rev.cdcategory in (105,106,107,108)
order by rev.IDDOCUMENT, rev.CDREVISION


---------------------
-- Descrição: DME - Cubo 1 Todos os documentos com fases do útimo ciclo do fluxo de revisão
-- irá substituir todos os outros criados no sistema em (09/2019)
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019 / 11/2019
-- 
--------------------------------------------------------------------------------
select rev.iddocument, rev.nmtitle, gnrev.idrevision, rev.cdrevision
, datediff(dd, rev.dtinsert, (select max(coalesce(stagld.dtapproval, cast(0 as datetime)) + coalesce(stagld.tmapproval, cast(0 as datetime))) from GNREVISIONSTAGMEM stagld 
   where stagld.cdrevision = stag.cdrevision and stagld.nrcycle = stag.nrcycle and stagld.fgstage = 3)) +1 as leadtimeaprov
, case when substring(cat.idcategory, 1, 1) in ('1','2','3','4','5','6','7','8','9','0') then substring(cat.idcategory, 5, 50) else cat.idcategory end idcategory
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, case rev.cdcategory
    when  39 then 'BSB'
    when  45 then 'BSB'
    when 110 then 'AN'
    when 111 then 'AN'
    when 112 then 'AN'
	when 113 then 'AN'
	when 114 then 'AN'
	when 145 then 'BSB'
	when 146 then 'BSB'
    when 225 then 'IN'
    when 226 then 'IN'
	when 227 then 'IN'
	when 243 then 'IN'
	when 265 then 'BSB'
	when 304 then 'UA'
	when 305 then 'UA'
	when 306 then 'UA'
	when 307 then 'UA'
	when 308 then 'UA'
    else 'N/A'
end unidade
, case when (rev.fgcurrent = 1 and doc.fgstatus <> 1) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, gnrev.dtrevprogstart, gnrev.dtrevprogfinish, rev.dtinsert as dtrevrealstart, gnrev.dtrevrealfinish as dtrevrealfinishH
, (select top 1 max(stag1.dtapproval)
from GNREVISIONSTAGMEM stag1
where stag1.CDREVISION = gnrev.CDREVISION AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE = 3
) as dtrevrealfinishA
, datediff(DD, gnrev.DTREVPROGFINISH, gnrev.DTREVREALFINISH) as FimDif
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.qtdeadline, stag.NRCYCLE as ciclo, stag.NRSEQUENCE, stag.CDMEMBERINDEX
, stag.dtdeadline as dtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, case when stag.CDUSER is null then 'NA' else (select dep.nmdepartment from addepartment dep inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment and FGDEFAULTDEPTPOS = 1 where rel.cduser = stag.cduser) end depExecutor
, stag.dtapproval as dtexecut
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
, datediff(DD, stag.dtdeadline, stag.dtapproval) as leadtime
, his.dtaccess as dtCancel
, his.NMREVISION as revCancel, his.nmuser as nmuserCancel, cast(his.dsjustify as varchar(4000)) as jutificCancel
, (select nmattribute from adattribvalue where cdattribute = 200 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 200 and cdrevision = rev.cdrevision)) as cod_sap_cyrel
, (select nmattribute from adattribvalue where cdattribute = 199 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 199 and cdrevision = rev.cdrevision)) as cod_sap_tira
, (select nmattribute from adattribvalue where cdattribute = 193 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 193 and cdrevision = rev.cdrevision)) as pharmacode
, (select nmattribute from adattribvalue where cdattribute = 192 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 192 and cdrevision = rev.cdrevision)) as destec
, (select nmattribute from adattribvalue where cdattribute = 146 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 146 and cdrevision = rev.cdrevision)) as tpfaca
, (select nmattribute from adattribvalue where cdattribute = 145 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 145 and cdrevision = rev.cdrevision)) as faca
, (select nmattribute from adattribvalue where cdattribute = 142 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 142 and cdrevision = rev.cdrevision)) as utilmatemb
, (select nmattribute from adattribvalue where cdattribute = 141 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 141 and cdrevision = rev.cdrevision)) as tpmatemb
, (select nmattribute from adattribvalue where cdattribute = 140 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 140 and cdrevision = rev.cdrevision)) as codanter
, (select nmattribute from adattribvalue where cdattribute = 138 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 138 and cdrevision = rev.cdrevision)) as codanovis
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from DCDOCMULTIATTRIB dcatt
                 inner join adattribvalue attvl on attvl.cdattribute = dcatt.cdattribute and attvl.cdvalue = dcatt.cdvalue
                 where dcatt.cdrevision = rev.cdrevision and dcatt.cdattribute = 143
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listapaís --listapaís--
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from DCDOCMULTIATTRIB dcatt
                 inner join adattribvalue attvl on attvl.cdattribute = dcatt.cdattribute and attvl.cdvalue = dcatt.cdvalue
                 where dcatt.cdrevision = rev.cdrevision and dcatt.cdattribute = 144
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listalinhaemb --listalinhaemb--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision
where assoc.cdrevision = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as compostode --listadocfilho--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevision = revc.cdrevision
where assoc.cdrevisionassoc = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as usadoem --listadocpai--
, coalesce((select substring((select ' | '+ cast(crit.nrcritic as varchar(255)) +') '+ cast(crit.dscritic as varchar(4000)) as [text()] from GNREVISIONCRITIC crit
            where crit.cdrevision = rev.cdrevision and crit.nrcycle = stag.nrcycle FOR XML PATH('')), 4, 4000)), 'NA') as criticas --listacríticas--
, 1 as quantidade
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
where rev.cdcategory in (39, 45, 110, 111, 112, 225, 226, 113, 114, 145, 146, 227, 243, 265, 304, 305, 306, 307, 308)
--and (datepart(year,gnrev.dtrevrealfinish) = <!%YEAR%> or gnrev.dtrevrealfinish is null)
order by rev.iddocument, gnrev.idrevision, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE, stag.CDMEMBERINDEX

---------------------
-- Descrição: DME05b) Todos os documentos sem fases do fluxo de revisão
--            CATEGORIAS: 1 - AF TDS, 2 - FEME TDS, 3 - DT TDS
-- Autor: Alvaro Adriano Beck
-- Criada em: 01/2016
-- Atualizada em: 09/2019
-- 
--------------------------------------------------------------------------------
select rev.iddocument, rev.nmtitle, gnrev.idrevision, rev.cdrevision
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, gnrev.dtrevision as dtrevisao
, gnrev.dtvalidity as dtvalidade
, his.dtaccess as dtcancel
, his.NMREVISION as revcancel, his.nmuser, cast(his.dsjustify as varchar(4000)) as jutificativa
, (select nmattribute from adattribvalue where cdattribute = 200 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 200 and cdrevision = rev.cdrevision)) as cod_sap_cyrel
, (select nmattribute from adattribvalue where cdattribute = 199 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 199 and cdrevision = rev.cdrevision)) as cod_sap_tira
, (select nmattribute from adattribvalue where cdattribute = 193 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 193 and cdrevision = rev.cdrevision)) as pharmacode
, (select nmattribute from adattribvalue where cdattribute = 192 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 192 and cdrevision = rev.cdrevision)) as destec
, (select nmattribute from adattribvalue where cdattribute = 146 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 146 and cdrevision = rev.cdrevision)) as tpfaca
, (select nmattribute from adattribvalue where cdattribute = 145 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 145 and cdrevision = rev.cdrevision)) as faca
, (select nmattribute from adattribvalue where cdattribute = 142 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 142 and cdrevision = rev.cdrevision)) as utilmatemb
, (select nmattribute from adattribvalue where cdattribute = 141 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 141 and cdrevision = rev.cdrevision)) as tpmatemb
, (select nmattribute from adattribvalue where cdattribute = 140 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 140 and cdrevision = rev.cdrevision)) as codanter
, (select nmattribute from adattribvalue where cdattribute = 138 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 138 and cdrevision = rev.cdrevision)) as codanovis
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from DCDOCMULTIATTRIB dcatt
                 inner join adattribvalue attvl on attvl.cdattribute = dcatt.cdattribute and attvl.cdvalue = dcatt.cdvalue
                 where dcatt.cdrevision = rev.cdrevision and dcatt.cdattribute = 143
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listapaís --listapaís--
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from DCDOCMULTIATTRIB dcatt
                 inner join adattribvalue attvl on attvl.cdattribute = dcatt.cdattribute and attvl.cdvalue = dcatt.cdvalue
                 where dcatt.cdrevision = rev.cdrevision and dcatt.cdattribute = 144
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as listalinhaemb --listalinhaemb--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision
where assoc.cdrevision = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as compostode --listadocfilho--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevision = revc.cdrevision
where assoc.cdrevisionassoc = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as usadoem --listadocpai--
, 1 as quantidade
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
where rev.cdcategory in (110,111,112)
order by rev.iddocument



---------------------
-- Descrição: Cubo de BI para a Ana de PA - Dados de docummentos (DME)
-- Autor: Alvaro Adriano Beck
-- Criada em: 06/2018
-- Atualizada em: 09/2019
--------------------------------------------------------------------------------
select  rev.iddocument, rev.nmtitle, gnrev.idrevision, doc.dtinsert
, stag.qtdeadline, stag.NRCYCLE as ciclo, stag.NRSEQUENCE, stag.CDMEMBERINDEX
, cat.idcategory, cat.nmcategory
, gnrev.DTREVPROGSTART, gnrev.DTREVPROGFINISH, gnrev.DTREVREALSTART, gnrev.DTREVREALFINISH
, datediff(DD, gnrev.DTREVPROGFINISH, gnrev.DTREVREALFINISH) as FimDif
, case rev.cdcategory
    when  39 then 'BSB'
    when  45 then 'BSB'
    when  50 then 'BSB'
    when   9 then 'PA'
    when  11 then 'PA'
    when  16 then 'BSB'
    when  34 then 'EG'
	when  35 then 'BSB'
	when  36 then 'EG'
	when  37 then 'PA'
	when  38 then 'EG'
	when  40 then 'BSB'
	when 145 then 'BSB'
	when 146 then 'BSB'
	else 'N/A'
end unidade
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, case when (rev.fgcurrent = 1 and doc.fgstatus <> 1) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, case stag.FGSTAGE when 1 then 'Elaborador' when 2 then 'Consensador' when 3 then 'Aprovador' when 4 then 'Homologador' end Fase
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
, case when cast(cast(stag.NRCYCLE as varchar(255))+cast(stag.FGSTAGE as varchar(255))+cast(stag.NRSEQUENCE as varchar(255))+cast(stag.CDMEMBERINDEX as varchar(255)) as integer) =
       (select min(cast(cast(stag2.NRCYCLE as varchar(255))+cast(stag2.FGSTAGE as varchar(255))+cast(stag2.NRSEQUENCE as varchar(255))+cast(stag2.CDMEMBERINDEX as varchar(255)) as integer))
        from GNREVISIONSTAGMEM stag2
        where stag2.cdrevision = stag.cdrevision
       ) then datediff(dd,gnrev.DTREVCREATE,stag.DTAPPROVAL)
  else
       datediff(dd,(select stag3.dtapproval from GNREVISIONSTAGMEM stag3
                    where cast(cast(stag3.NRCYCLE as varchar(255))+cast(stag3.FGSTAGE as varchar(255))+cast(stag3.NRSEQUENCE as varchar(255))+cast(stag3.CDMEMBERINDEX as varchar(255)) as integer) = 
                           (select max(cast(cast(stag2.NRCYCLE as varchar(255))+cast(stag2.FGSTAGE as varchar(255))+cast(stag2.NRSEQUENCE as varchar(255))+cast(stag2.CDMEMBERINDEX as varchar(255)) as integer)) as code
        from GNREVISIONSTAGMEM stag2
        where stag2.cdrevision = stag.cdrevision and cast(cast(stag2.NRCYCLE as varchar(255))+cast(stag2.FGSTAGE as varchar(255))+cast(stag2.NRSEQUENCE as varchar(255))+cast(stag2.CDMEMBERINDEX as varchar(255)) as integer) <
              cast(cast(stag.NRCYCLE as varchar(255))+cast(stag.FGSTAGE as varchar(255))+cast(stag.NRSEQUENCE as varchar(255))+cast(stag.CDMEMBERINDEX as varchar(255)) as integer)
         and stag2.dtapproval is not null) and stag3.cdrevision = rev.cdrevision),stag.DTAPPROVAL)
  end leadtime
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when stag.cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, gnrev.dtrevision as dtrevisao
, stag.dtdeadline as dtdeadline
, stag.dtapproval as dtexecut
, 1 as quantidade
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION --AND stag.CDUSER IS NOT NULL
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join dccategory cat on cat.cdcategory = rev.cdcategory
where rev.cdcategory in (39, 45, 50, 9, 11, 16, 34, 35, 36, 37, 38, 40, 145, 146) --and rev.FGCURRENT = 1
order by rev.iddocument, gnrev.idrevision, stag.nrcycle, stag.FGSTAGE, stag.nrsequence

---------------------
-- Descrição: ENGMAN - Cubo para acompanhamento do fluxo de revisão de documentos
-- Autor: Alvaro Adriano Beck
-- Criada em: 09/2019
-- Atualizada em: 09/2019
--------------------------------------------------------------------------------
select idcategory as tipodoc, sub.iddocument, sub.idrevision, sub.nmtitle, sub.fase, sub.desde, qtdeadline as prazodias, dtdeadline as prazo, sub.executor, dep.nmdepartment, pos.nmposition
, case when (dtdeadline > getdate()) then 'Em dia' when (dtdeadline = getdate()) then 'Vence hoje' when (dtdeadline < getdate()) then 'Em atraso' end as status
, case when (dtdeadline > getdate()) then 0 when (dtdeadline = getdate()) then 0 when (dtdeadline < getdate()) then datediff(dd, dtdeadline, getdate()) end as diasatraso
, 1 as quantidade
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

--
---------------------
-- Descrição: BSB-DOC - Cubo 1
-- Autor: Alvaro Adriano Beck
-- Criada em: 03/2020
-- Atualizada em: 09/2019
--------------------------------------------------------------------------------
select rev.iddocument
, req.IDREQUEST, rqtype.IDREQUESTTYPE +' - '+ rqtype.NMREQUESTTYPE as ReqType
, req.DTREQUEST as dtReqAberta, apro.DTAPPROV as dtReqAprovada, usr.nmuser as ReqAprovador
, req.DTUPDATE as ReqAtualizadoEm, req.NMUSERUPD as ReqAtualizadoPor
, case when req.DTREQUEST is null then req.DTREQUEST else gnrev.DTREVCREATE end as ReqAtendida --, format(req.DTREQUESTENDDATE,'dd/MM/yyyy') as ReqFechada
, rev.nmtitle, gnrev.idrevision, rev.cdrevision
, case when substring(cat.idcategory, 1, 1) in ('1','2','3','4','5','6','7','8','9','0') then substring(cat.idcategory, 5, 50) else cat.idcategory end idcategory
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' end statusdoc
, case when (rev.fgcurrent = 1 and doc.fgstatus <> 1) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, gnrev.dtrevprogstart, gnrev.dtrevprogfinish, rev.dtinsert as dtrevrealstart, gnrev.dtrevrealfinish as dtrevrealfinishH
, (select top 1 max(stag1.dtapproval)
from GNREVISIONSTAGMEM stag1
where stag1.CDREVISION = gnrev.CDREVISION AND stag1.dtdeadline IS NOT NULL and stag1.FGSTAGE = 3
) as dtrevrealfinishA
, datediff(DD, gnrev.DTREVPROGFINISH, gnrev.DTREVREALFINISH) as FimDif
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.qtdeadline, stag.NRCYCLE as ciclo, stag.NRSEQUENCE, stag.CDMEMBERINDEX
, stag.dtdeadline as dtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when stag.cdposition is null then case when stag.cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select pos.nmposition from adposition pos where pos.cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, case when stag.CDUSER is null then 'NA' else (select dep.nmdepartment from addepartment dep inner join aduserdeptpos rel on rel.cddepartment = dep.cddepartment and FGDEFAULTDEPTPOS = 1 where rel.cduser = stag.cduser) end depExecutor
, stag.dtapproval as dtexecut
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
, datediff(DD, stag.dtdeadline, stag.dtapproval) as leadtime
, his.dtaccess as dtCancel
, his.NMREVISION as revCancel, his.nmuser as nmuserCancel, cast(his.dsjustify as varchar(4000)) as jutificCancel
, (select nmattribute from adattribvalue where cdattribute = 2 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 2 and cdrevision = rev.cdrevision)) as areaUQ
, (select nmattribute from adattribvalue where cdattribute = 3 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 3 and cdrevision = rev.cdrevision)) as areaEmitenteUQ
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from DCDOCMULTIATTRIB dcatt
                 inner join adattribvalue attvl on attvl.cdattribute = dcatt.cdattribute and attvl.cdvalue = dcatt.cdvalue
                 where dcatt.cdrevision = rev.cdrevision and dcatt.cdattribute = 278
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as areasRespBSB
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from DCDOCMULTIATTRIB dcatt
                 inner join adattribvalue attvl on attvl.cdattribute = dcatt.cdattribute and attvl.cdvalue = dcatt.cdvalue
                 where dcatt.cdrevision = rev.cdrevision and dcatt.cdattribute = 8
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as areasAbrangBSB
, cast(coalesce((select substring((select ' | '+ attvl.nmattribute as [text()] from DCDOCMULTIATTRIB dcatt
                 inner join adattribvalue attvl on attvl.cdattribute = dcatt.cdattribute and attvl.cdvalue = dcatt.cdvalue
                 where dcatt.cdrevision = rev.cdrevision and dcatt.cdattribute = 7
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as LinhasProdBSB
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision
where assoc.cdrevision = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as compostode --listadocfilho--
, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevision = revc.cdrevision
where assoc.cdrevisionassoc = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as usadoem --listadocpai--
, coalesce((select substring((select ' | '+ cast(crit.nrcritic as varchar(255)) +') '+ cast(crit.dscritic as varchar(4000)) as [text()] from GNREVISIONCRITIC crit
            where crit.cdrevision = rev.cdrevision and crit.nrcycle = stag.nrcycle FOR XML PATH('')), 4, 4000)), 'NA') as criticas --listacríticas--
, 1 as quantidade
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
left join GNREVISIONREQASSOC assrev on gnrev.cdrevision = assrev.cdrevision
left join GNREQUEST req on assrev.cdrequest = req.cdrequest
left join GNAPPROVRESP apro on apro.CDPROD = req.CDPROD and apro.CDAPPROV = req.CDAPPROV and apro.DTAPPROV is not null
left join gnrequesttype rqtype on rqtype.CDREQUESTTYPE = req.CDREQUESTTYPE
left join aduser usr on usr.cduser = apro.CDUSERAPPROV
where rev.cdcategory in (16,35,40)


---------------------
-- Descrição: SOPs
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2021
-- Atualizada em: 
-- 
--------------------------------------------------------------------------------
select rev.iddocument, gnrev.idrevision
, case doc.fgstatus when 1 then 'New SOP' when 2 then 'Released' when 3 then 'Under Revision' when 4 then 'Canceled' end situation
, case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE >= getdate()) then 'On Time'
       when (((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE < getdate()) or stag.DTDEADLINE is null) then 'Past Due'
       else ''
end status
, case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) <= 30) then 'Being Revised' 
       when (((doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) > 30) or ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE is null)) then 'Need Action'
       else ''
end sitpd
, stag.dtdeadline, usr.nmuser
, 1 as qtd
from dcdocument doc
inner join dcdocrevision rev on rev.cddocument = doc.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION) AND stag.DTDEADLINE IS not NULL and (stag.FGAPPROVAL <> 1 or stag.FGAPPROVAL is null)
left join aduser usr on usr.cduser = stag.cduser
where rev.cdcategory = 274 and rev.cdrevision = (select max(rev2.cdrevision) from dcdocrevision rev2 where rev2.cddocument = doc.cddocument)


---================================> Elaine
select rev.iddocument, gnrev.idrevision, doc.fgstatus, doc.cddocument, rev.cdrevision, gnrev.dtrevision, gnrev.dtvalidity
, case doc.fgstatus
when 1 then 'New SOP'
when 2 then 'Released'
when 3 then case rev.fgcurrent when 1 then 'Released' else 'Under Revision' end
when 4 then 'Canceled'
end situation
, case doc.fgstatus
when 1 then case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE >= getdate()) then 'On Time'
when (((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE < getdate()) or stag.DTDEADLINE is null) then 'Past Due'
else ''
end
when 2 then 'Released'
when 3 then case rev.fgcurrent when 1 then 'Released' else
case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE >= getdate()) then 'On Time'
when (((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE < getdate()) or stag.DTDEADLINE is null) then 'Past Due'
else ''
end end
when 4 then 'Canceled'
end status
, case when (rev.fgcurrent <> 1 and (doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) <= 30) then 'Being Revised'
when (rev.fgcurrent <> 1 and (((doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) > 30) or ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE is null))) then 'Need Action'
else 'N/A'
end sitpd
, stag.dtdeadline, usr.nmuser
, 1 as qty
from dcdocrevision rev
inner join dcdocument doc on rev.cddocument = doc.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION) AND stag.DTDEADLINE IS not NULL and (stag.FGAPPROVAL <> 1 or stag.FGAPPROVAL is null)
left join aduser usr on usr.cduser = stag.cduser
where rev.cdcategory = 274 and (rev.cdrevision = (select max(rev2.cdrevision) from dcdocrevision rev2 where rev2.cddocument = doc.cddocument)
or doc.fgstatus = 3 and rev.cdrevision = (select max(rev3.cdrevision) from dcdocrevision rev3 inner join gnrevision gnrev1 on gnrev1.cdrevision = rev3.cdrevision where rev3.cddocument = doc.cddocument and gnrev1.dtrevision is not null))


---------------------
-- Descrição: DOC-02
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2022
-- Atualizada em: 
-- 
--------------------------------------------------------------------------------
select rev.iddocument, rev.NMTITLE, gnrev.idrevision, doc.fgstatus, doc.cddocument, rev.cdrevision, gnrev.dtrevision, gnrev.dtvalidity
, case doc.fgstatus
	when 1 then 'New SOP'
	when 2 then 'Released'
	when 3 then case rev.fgcurrent when 1 then 'Released' else 'Under Revision' end
	when 4 then 'Canceled'
end situation
, case doc.fgstatus
	when 1 then case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE >= getdate()) then 'On Time'
					 when (((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE < getdate()) or stag.DTDEADLINE is null) then 'Past Due'
				else ''
				end
	when 2 then 'Released'
	when 3 then case rev.fgcurrent when 1 then 'Released'
				else
			case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE >= getdate()) then 'On Time'
			when (((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE < getdate()) or stag.DTDEADLINE is null) then 'Past Due'
			else ''
			end end
	when 4 then 'Canceled'
end status
, case when (rev.fgcurrent <> 1 and (doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) <= 30) then 'Being Revised'
	when (rev.fgcurrent <> 1 and (((doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) > 30) or ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE is null))) then 'Need Action'
	else 'N/A'
end sitpd
, stag.dtdeadline, usr.nmuser
, (select TOP 1 owner.nmuser from GNREVISIONSTAGMEM stag inner join aduser owner on owner.cduser = stag.cduser where stag.FGSTAGE = 1 AND stag.cdrevision = rev.cdrevision) as owner
, case when doc.fgstatus = 1 or doc.fgstatus = 3 then case stag.fgstage
    when 1 then 'Waiting for Edit'
    when 2 then 'Waiting for approval'
    when 3 then 'Waiting for approval'
    when 4 then 'Waiting to be effective'
    else 'N/A'
  end else 'N/A' end statusExec
, 1 as qty
from dcdocrevision rev
inner join dcdocument doc on rev.cddocument = doc.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION
          and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION) AND stag.DTDEADLINE IS not NULL and (stag.FGAPPROVAL <> 1 or stag.FGAPPROVAL is null)
left join aduser usr on usr.cduser = stag.cduser
where rev.cdcategory = 274 and (rev.cdrevision = (select max(rev2.cdrevision) from dcdocrevision rev2 where rev2.cddocument = doc.cddocument)
or doc.fgstatus = 3 and rev.cdrevision = (select max(rev3.cdrevision) from dcdocrevision rev3 inner join gnrevision gnrev1 on gnrev1.cdrevision = rev3.cdrevision where rev3.cddocument = doc.cddocument and gnrev1.dtrevision is not null))

---------------------
-- Descrição: DOC-03
-- Autor: Alvaro Adriano Beck
-- Criada em: 07/2022
-- Atualizada em: 
-- 
--------------------------------------------------------------------------------
select rev.iddocument, rev.NMTITLE, gnrev.idrevision, doc.fgstatus, doc.cddocument, rev.cdrevision, gnrev.dtrevision, gnrev.dtvalidity
, case doc.fgstatus
when 1 then 'New SOP'
when 2 then 'Released'
when 3 then case rev.fgcurrent when 1 then 'Released' else 'Under Revision' end
when 4 then 'Canceled'
end situation
, case doc.fgstatus
when 1 then case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE >= getdate()) then 'On Time'
when (((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE < getdate()) or stag.DTDEADLINE is null) then 'Past Due'
else ''
end
when 2 then 'Released'
when 3 then case rev.fgcurrent when 1 then 'Released' else
case when ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE >= getdate()) then 'On Time'
when (((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE < getdate()) or stag.DTDEADLINE is null) then 'Past Due'
else ''
end end
when 4 then 'Canceled'
end status
, case when (rev.fgcurrent <> 1 and (doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) <= 30) then 'Being Revised'
when (rev.fgcurrent <> 1 and (((doc.fgstatus = 1 or doc.fgstatus = 3) and datediff(dd, stag.DTDEADLINE, getdate()) > 30) or ((doc.fgstatus = 1 or doc.fgstatus = 3) and stag.DTDEADLINE is null))) then 'Need Action'
else 'N/A'
end sitpd
, stag.dtdeadline, usr.nmuser
, (select TOP 1 owner.nmuser from GNREVISIONSTAGMEM stag inner join aduser owner on owner.cduser = stag.cduser where stag.FGSTAGE = 1 AND stag.cdrevision = rev.cdrevision) as owner
, case when doc.fgstatus = 1 or doc.fgstatus = 3 then case stag.fgstage
    when 1 then 'Waiting for Edit'
    when 2 then 'Waiting for approval'
    when 3 then 'Waiting for approval'
    when 4 then 'Waiting to be effective'
    else 'N/A'
  end else 'N/A' end statusExec
, 1 as qty
from dcdocrevision rev
inner join dcdocument doc on rev.cddocument = doc.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION) AND stag.DTDEADLINE IS not NULL and (stag.FGAPPROVAL <> 1 or stag.FGAPPROVAL is null)
left join aduser usr on usr.cduser = stag.cduser
where (rev.cdcategory <> 274 and rev.cdcategory in (select cdcategory from dccategory where idcategory in 
('0010 - UA') or cdcategoryowner in 
(select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA'))) or cdcategoryowner in
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA'))))))
and (rev.cdrevision = (select max(rev2.cdrevision) from dcdocrevision rev2 where rev2.cddocument = doc.cddocument)
or doc.fgstatus = 3 and rev.cdrevision = (select max(rev3.cdrevision) from dcdocrevision rev3 inner join gnrevision gnrev1 on gnrev1.cdrevision = rev3.cdrevision where rev3.cddocument = doc.cddocument and gnrev1.dtrevision is not null))