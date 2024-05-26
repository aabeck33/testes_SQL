---------------------
-- Descrição: Uso de áreas e equipes no sistema
-- Autor: Alvaro Adriano Beck
-- Criada em: 11/2015
-- Atualizada em: -
-- Descrição detalhada: Script que lista o uso de Equipes e Áreas no SESuite - Módulos:
--                      Documentos, Processos, Workflow, Solicitação, Projetos, Desempenho,
--                      Protocolo, Roteiros responsáveis (geral - Admin), Plano de Ação,
--                      BI, Arquivo Físico, Controle de atividade, DashBoads, Admin, Problema,
--                      Formulário (na), Almoxarifado
-- 
-- Lista das Equipes x Módulo:
-- Responsável por atividade ou projeto
-- Acesso restrito aos custos projeto (Parte interessada)
-- Conhecimento de Revisão do projeto
-- Segurança do Tipo de Processo/Atividade
-- Segurança do Processo/Atividades
-- Cadastro da lista de acesso do processo, atividade e decisão
-- Cadastro de propriedades padrões de atividade e decisão
-- Cadastro de propriedades do processo
-- Cadastro de item da estrutura do processo
-- Cadastro de ação da atividade
-- Cadastro da lista de acesso para os eventos de notificação
-- Lista de segurança da atividade
-- Item do processo
-- Categoria de documentos - Distribuição de cópias impressas
-- Segurança da categoria
-- Posto de cópias
-- Visualização de indicadores
-- Áreas membros de Equipe
-- Segurança do documento
-- Sequencia do Protocolo
-- Segurança do tipo de protocolo
-- Atributos do tipo de protocolo
-- Acesso aos cubos do BI
-- Acesso às Solicitações restritas
-- Segurança do tipo de Solcitação
-- Responsável pelo atendimento de solicitações
-- Parte de roteiro responsável
-- Acesso às unidades de negócio do Desempenho
-- Visualização de Análises Gráficas
-- Notificação de indicador de scorecard
-- Segurança do item do ScoreCard
-- Responsável pela medição de indicadores
-- Responsável pela meta de indicadores
-- Acesso em Scorecards
-- Aprovações de indicador
-- Acesso em Indicadores
-- Processo de revisão de documentos
-- Segurança do tipo de Guia de Remessa
-- Segurança do tipo de Ação e Plano de ação (plano de ação)
-- Regra de e-mails de Projetos
-- Segurança do Portfólio de projetos
-- Local de armazenamento de Arquivo Físico
-- Permissões nos DashBoards
-- Emitentes/Atendentes de Solicitação
-- Notificado em Agendamento
-- Tem acesso aos atributos de Protocolos
-- Segurança do tipo de Almoxarifado
-- Segurança do tipo de Problema
-- Segurança do Almoxarifado
-- Responsável e Dono de Almoxarifado
--------------------------------------------------------------------------------
select tudo.*, 1 as Quantidade
from (
--Responsável por atividade ou projeto
select 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem,
case
when pra.cdtask <> pra.cdbasetask then 'É responsável pela atividade: ' + pra.nmidtask + ' - ' + pra.nmtask + ' | do Projeto: ' + (select prj.nmtask from prtask prj where prj.cdtask = pra.cdbasetask)
when pra.cdtask = pra.cdbasetask then 'É responsável pelo projeto: ' + pra.nmidtask + ' - ' + pra.nmtask
end as Oque, 'Projetos' as Modulo
from prtask pra
left join ADTEAM eq on eq.cdteam = pra.CDTEAMRESP
where pra.CDTEAMRESP is not null
union
--Acesso restrito aos custos projeto (Parte interessada)
select
case
when pra.FGTEAMMEMBER = 5 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when pra.FGTEAMMEMBER = 1 then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
case
when pra.FGACCESSCOST = 1 then 'Tem acesso no projeto: ' + pr.nmidtask + ' - ' + pr.nmtask
when pra.FGACCESSCOST = 2 then 'Não tem acesso no projeto: ' + pr.nmidtask + ' - ' + pr.nmtask
end as Oque, 'Projetos' as Modulo
from PRTASKACCESS pra
left join ADTEAM eq on eq.cdteam = pra.cdteam
left join addepartment dep on dep.cddepartment = pra.cddepartment
inner join prtask pr on pr.cdtask = pra.CDTASK
where pra.FGTEAMMEMBER = 5 or pra.FGTEAMMEMBER = 1
union
--Local de armazenamento de Arquivo Físico
select
'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment as Quem,
'Abriga o Local de armazenamento: ' + fl.NMPHYSLOCATION as Oque, 'Arquivo Físico' as Modulo
from DCPHYSLOCATION fl
left join addepartment dep o/n dep.cddepartment = fl.cddepartment
where fl.CDPHYSLOCOWNER is null and fl.FGENABLED = 1
union
--Conhecimento de Revisão do projeto
select
case
when pra.FGACCESSTYPE = 1 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when pra.FGACCESSTYPE = 2 then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Recebe conhecimento de publicação dos projetos da /: ' + pr.nmtasktype as Oque, 'Projetos' as Modulo
from PRTKTPACCESSROLE pra
left join ADTEAM eq on eq.cdteam = pra.cdteam
left join addepartment dep on dep.cddepartment = pra.cddepartment
inner join prtasktype pr on pr.cdtasktype = pra.CDTASKtype
where pra.FGACCESSTYPE = 2 or pra.FGACCESSTYPE = 1
union
--Cadastro da lista de tipo de acesso de atividades
select
case
when pra.FGACCESSTYPE = 1 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when pra.FGACCESSTYPE = 2 then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Tem acesso na atividade: ' + pm.Idactivity + ' - ' + pm.nmactivity as Oque, 'Processos' as Modulo
from PMACTSECURITYLIST pra
left join ADTEAM eq on eq.cdteam = pra.cdteam
left join addepartment dep on dep.cddepartment = pra.cddepartment
inner join pmactivity pm on pm.cdactivity = pra.cdactivity
where (pra.FGACCESSTYPE = 2 or pra.FGACCESSTYPE = 1)
union
--Segurança do Processo/Atividades
select
case
when (aclist.cddepartment is null and aclist.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (aclist.cddepartment is not null and aclist.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Pode ' + field.NMACCESSROLEFIELD + ' ' + act.IDACTIVITY + ' - ' + act.NMACTIVITY as Oque, 'Processos' as Modulo
from PMACTSECURITYCTRL acctrl
inner join PMACTSECURITYLIST aclist on aclist.CDACTIVITY = acctrl.CDACTIVITY
inner join PMACCESSROLEFIELD field on field.CDACCESSROLEFIELD = acctrl.CDACCESSROLEFIELD
inner join pmactivity act on act.CDACTIVITY = acctrl.CDACTIVITY
left join ADTEAM eq on eq.cdteam = aclist.cdteam
left join addepartment dep on dep.cddepartment = aclist.cddepartment
where (aclist.cddepartment is null and aclist.CDTEAM is not null) or (aclist.cddepartment is not null and aclist.CDTEAM is null)
union
--Segurança do Tipo de Processo/Atividades
select
case
when (aclist.cddepartment is null and aclist.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (aclist.cddepartment is not null and aclist.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Pode ' + field.NMACCESSROLEFIELD + ' do tipo ' + act.IDACTTYPE + ' - ' + act.NMACTTYPE as Oque, 'Processos' as Modulo
from PMACTTYPESECURCTRL acctrl
inner join PMACTTYPESECURLIST aclist on aclist.CDACTTYPE = acctrl.CDACTTYPE and aclist.CDACCESSLIST = acctrl.CDACCESSLIST
inner join PMACCESSROLEFIELD field on field.CDACCESSROLEFIELD = acctrl.CDACCESSROLEFIELD
inner join PMACTTYPE act on act.CDACTTYPE = acctrl.CDACTTYPE
left join ADTEAM eq on eq.cdteam = aclist.cdteam
left join addepartment dep on dep.cddepartment = aclist.cddepartment
where (aclist.cddepartment is null and aclist.CDTEAM is not null) or (aclist.cddepartment is not null and aclist.CDTEAM is null)
union
--Cadastro de propriedades padrões de atividade e decisão
select case
when pra.CDTEAM is not null then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when pra.CDDEPARTMENT is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Cadastro de propriedades padrões de atividade e decisão' as Oque, 'Processos' as Modulo
from PMITEMMODEL pra
left join addepartment dep on dep.cddepartment = pra.cddepartment
left join ADTEAM eq on eq.cdteam = pra.cdteam
where (pra.CDTEAM is not null or pra.CDDEPARTMENT is null) or (pra.CDTEAM is null or pra.CDDEPARTMENT is not null)
union
--Cadastro de propriedades do processo
select case
when pra.FGCTRLMANAGER = 7 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when pra.FGCTRLMANAGER = 3 then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Gestor do processo: ' + act.IDACTIVITY + ' - ' + act.NMACTIVITY as Oque, 'Processos' as Modulo
from PMPROCESS pra
left join addepartment dep on dep.cddepartment = pra.CDDEPTMANAGER
left join ADTEAM eq on eq.cdteam = pra.CDTEAMMANAGER
left join PMACTIVITY act on act.cdactivity = pra.cdproc
where (pra.FGCTRLMANAGER = 3 or pra.FGCTRLMANAGER = 7)
union
--Cadastro de item da estrutura do processo
select case
when pra.FGDELEGRESTRICTION = 3 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when pra.CDDEPARTMENT is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Restrição de delegação na atividade: ' + act.IDACTIVITY + ' - ' + act.NMACTIVITY as Oque, 'Processos' as Modulo
from PMSTRUCT pra
left join ADTEAM eq on eq.cdteam = pra.CDDELEGATIONTEAM
left join addepartment dep on dep.cddepartment = pra.CDDEPARTMENT
inner join PMACTIVITY act on act.cdactivity = pra.cdactivity
where pra.FGDELEGRESTRICTION = 3 or pra.CDDEPARTMENT is not null
union
--Cadastro de ação da atividade
select case
when pra.FGSELECRESTRICTION = 2 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
end as Quem, 'Restrição de execução na atividade: ' + act.IDACTIVITY + ' - ' + act.nmACTIVITY as Oque, 'Processos' as Modulo
from PMSTRUCTACTION pra
left join ADTEAM eq on eq.cdteam = pra.CDTEAM
left join PMSTRUCT stru on stru.cdstruct = pra.cdstruct
left join pmactivity act on act.cdactivity = stru.cdactivity
where pra.FGSELECRESTRICTION = 2
union
--Cadastro da lista de acesso para os eventos de notificação
select case
when (pra.CDTEAM is not null and pra.CDDEPARTMENT is null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (pra.CDTEAM is null and pra.CDDEPARTMENT is not null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Notificação da atividade: ' + act.IDACTIVITY + ' - ' + act.NMACTIVITY as Oque, 'Processos' as Modulo
from PMSTRUCTNOTIFYLIST pra
left join ADTEAM eq on eq.cdteam = pra.CDTEAM
left join addepartment dep on dep.cddepartment = pra.CDDEPARTMENT
left join PMSTRUCT stru on stru.cdstruct = pra.cdstruct
left join pmactivity act on act.cdactivity = stru.cdactivity
where (pra.CDTEAM is not null and pra.CDDEPARTMENT is null) or (pra.CDTEAM is null and pra.CDDEPARTMENT is not null)
union
--Lista de segurança da atividade
select case
when (pra.CDTEAM is not null and pra.CDDEPARTMENT is null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (pra.CDTEAM is null and pra.CDDEPARTMENT is not null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Tem acesso à atividade: ' + act.idstruct + ' - ' + act.nmstruct as Oque, 'Workflow' as Modulo
from WFACTSECURITYLIST pra
left join ADTEAM eq on eq.cdteam = pra.CDTEAM
left join addepartment dep on dep.cddepartment = pra.CDDEPARTMENT
left join WFSTRUCT act on act.idobject = pra.idstruct
where (pra.CDTEAM is not null and pra.CDDEPARTMENT is null) or (pra.CDTEAM is null and pra.CDDEPARTMENT is not null)
union
--Segurança do tipo de Ação e Plano de ação (plano de ação)
select
case
when trdef.fgaccesstype = 1 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (trdef.fgaccesstype = 2 or trdef.fgaccesstype = 3) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
'Está na lista de acesso do Tipo de Ação/Plano de ação: ' + gntype.IDGENTYPE + ' - ' + gntype.NMGENTYPE as Oque, 'Plano de ação' as Modulo
from GNGENTYPE gntype
left join GNTYPEROLEDEF trdef on trdef.CDTYPEROLE = gntype.CDTYPEROLE
left join GNTYPEROLE perm on perm.CDTYPEROLE = gntype.CDTYPEROLE
left join ADTEAM eq on eq.cdteam = trdef.cdteam
left join addepartment dep on dep.cddepartment = trdef.cddepartment
where gntype.CDISOSYSTEM = 174 and trdef.fgaccesstype in (1,2,3)
union
--Item do processo
select case
when pra.FGDELEGRESTRICTION = 3 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when pra.nmdepartment is not null and dep.iddepartment is not null then 'Área: ' + dep.iddepartment + ' - ' + pra.nmdepartment
when pra.nmdepartment is not null and dep.iddepartment is null then 'Área: ' + pra.nmdepartment
end as Quem, 'Participa na atividade: ' + pra.idstruct + ' - ' + pra.nmstruct as Oque, 'Workflow' as Modulo
from WFSTRUCT pra
left join ADTEAM eq on eq.cdteam = pra.CDDELEGATIONTEAM
left join addepartment dep on dep.nmdepartment = pra.nmdepartment
where pra.FGDELEGRESTRICTION = 3 or pra.nmdepartment is not null
union
--Categoria de documentos - Distribuição de cópias impressas
select 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 'Responsaveis pela distribuição de cópias da categoria: ' + doc.idcategory + ' - ' + doc.NMCATEGORY as Oque, 'Documentos' as Modulo
from DCCATEGORY doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAMRESPCOPY
where doc.CDTEAMRESPCOPY is not null
union
--Segurança da categoria
select case
when (doc.CDTEAM is not null and doc.CDDEPARTMENT is null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (doc.CDTEAM is null and doc.CDDEPARTMENT is not null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Tem acesso na categoria: ' + cat.idcategory + ' - ' + cat.NMCATEGORY as Oque, 'Documentos' as Modulo
from DCCATEGORYDOCROLE doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
left join addepartment dep on dep.cddepartment = doc.CDdepartment
inner join dccategory cat on cat.CDCATEGORY = doc.CDCATEGORY
where (doc.CDTEAM is not null and doc.CDDEPARTMENT is null) or (doc.CDTEAM is null and doc.CDDEPARTMENT is not null)
union
--Posto de cópias
select 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 'Faz parte do Posto de Cópia: ' + doc.NMCOPYSTATION as Oque, 'Documentos' as Modulo
from DCCOPYSTATION doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
where doc.CDTEAM is not null
union
--Segurança do documento
select case
when doc.CDTEAM is not null then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when doc.cddepartment is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Tem acesso ao documento: ' + docc.iddocument + ' - ' + docc.nmtitle as Oque, 'Documentos' as Modulo
from DCDOCACCESSROLE doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
left join addepartment dep on dep.cddepartment = doc.CDdepartment
inner join dcdocrevision docc on docc.cddocument = doc.cddocument
where doc.CDTEAM is not null or doc.cddepartment is not null
union
--Sequencia do Protocolo
select case
when doc.CDTEAM is not null then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when doc.cddepartment is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Participou do Protocolo: ' + docc.nmtitle as Oque, 'Documentos' as Modulo
from DCPROCEEDINGROLE doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
left join addepartment dep on dep.cddepartment = doc.CDdepartment
inner join DCPROCEEDING docc on docc.CdPROCEEDING = doc.cDPROCEEDING
where doc.CDTEAM is not null or doc.cddepartment is not null
union
--Segurança do tipo de protocolo
select case
when doc.CDTEAM is not null then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when doc.cddepartment is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Tem acesso aos Protocolos do tipo: ' + docc.nmtitle as Oque, 'Protocolo' as Modulo
from DCPROCTYPEROLE doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
left join addepartment dep on dep.cddepartment = doc.CDdepartment
inner join DCPROCTYPE docc on docc.CDPROCTYPE = doc.CDPROCTYPE
where doc.CDTEAM is not null or doc.cddepartment is not null
union
--Atributos do tipo de protocolo
select case
when doc.CDTEAM is not null then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when doc.cddepartment is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 'Tem acesso ao atributo: ' + atr.nmlabel + ' - do tipo de protocolo: ' + docc.nmtitle as Oque, 'Protocolo' as Modulo
from DCPROCTYPEATTRIB doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
left join addepartment dep on dep.cddepartment = doc.CDdepartment
inner join DCPROCTYPE docc on docc.CDPROCTYPE = doc.CDPROCTYPE
inner join adattribute atr on atr.cdattribute = doc.cdattribute
where doc.CDTEAM is not null or doc.cddepartment is not null
union
--Acesso aos cubos do BI
select 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 'Tem acesso no Cubo: ' + bian.nmkpi as Oque, 'BI' as Modulo
from BIANALYSISTEAMPERMISSION bi
left join ADTEAM eq on eq.cdteam = bi.cdadteam
inner join BIKPIPERMISSIONS perm on perm.BIPermissionsOID = bi.OID
inner join BIANALYSIS bian on bian.oid = perm.BIKPIOID
union
--Emitentes/Atendentes de Solicitação
select case
when (req.CDTASKDEPT is null and req.CDREQUESTDEPT is not null) then 'Área emitente: ' + dep.iddepartment + ' - ' + dep.nmdepartment
when (req.CDREQUESTDEPT is not null and req.CDTASKDEPT is null) then 'Área responsável pelo atendimento: ' + dep1.iddepartment + ' - ' + dep1.nmdepartment
when (req.CDREQUESTDEPT is not null and req.CDTASKDEPT is not null) then 'Área emitente: ' + dep.iddepartment + ' - ' + dep.nmdepartment + ' | Área responsável pelo atendimento: ' + dep1.iddepartment + ' - ' + dep1.nmdepartment
end as Quem, 
' da Solicitação: ' + req.IDREQUEST + ' - ' + req.NMREQUEST as Oque, 'Solicitação' as Modulo
from GNREQUEST req
left join addepartment dep on dep.cddepartment = req.CDREQUESTDEPT
left join addepartment dep1 on dep1.cddepartment = req.CDTASKDEPT
where req.CDTASKDEPT is not null or req.CDREQUESTDEPT is not null
union
--Acesso às Solicitações restritas
select
'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment as Quem,
'Tem acesso na Solicitação: ' + reque.idrequest + ' - ' + reque.nmrequest as Oque, 'Solicitação' as Modulo
from GNREQUESTACCESS solac
left join addepartment dep on dep.cddepartment = solac.cddepartment
inner join gnrequest reque on reque.cdrequest = solac.cdrequest
union
--Segurança do tipo de Solcitação
select
case
when (soltype.cddepartment is null and soltype.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (soltype.cddepartment is not null and soltype.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Tem acesso no tipo de Solicitaço: ' + reqtype.IDREQUESTTYPE + ' - ' + reqtype.NMREQUESTTYPE as Oque, 'Solicitação' as Modulo
from SRREQTYPEACCROLE soltype
inner join GNREQUESTTYPE reqtype on reqtype.CDREQUESTTYPE = soltype.CDREQUESTTYPE
left join ADTEAM eq on eq.cdteam = soltype.cdteam
left join addepartment dep on dep.cddepartment = soltype.cddepartment
where (soltype.cddepartment is null and soltype.CDTEAM is not null) or (soltype.cddepartment is not null and soltype.CDTEAM is null)
union
--Responsável pelo atendimento de solicitações
select
'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment as Quem,
'É responsável pelo atendimento da solicitação: ' + solac.idrequest + ' - ' + solac.nmrequest as Oque, 'Solicitação' as Modulo
from GNREQUEST solac
left join addepartment dep on dep.cddepartment = solac.CDTASKDEPT
where solac.FGTASKRESP = 1 OR solac.FGTASKRESP = 3
union
--Parte de roteiro responsável
select
'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment as Quem,
'É parte do Roteiro responsável: ' + aprou.IDAPPROVALROUTE + ' - ' + aprou.NMAPPROVALROUTE as Oque, 'Admin' as Modulo
from ADAPPROVALROUTE aprou
left join ADAPPROVROUTERESP memb on memb.cdapprovalroute = aprou.cdapprovalroute
left join addepartment dep on dep.cddepartment = memb.cddepartment
where memb.cddepartment is not null
union
--Participa em roteiro de aprovação
select
case
when (rotaprov.cddepartment is null and rotaprov.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (rotaprov.cddepartment is not null and rotaprov.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'É parte do Roteiro responsável: ' + route.IDAPPROVALROUTE + ' - ' + route.NMAPPROVALROUTE as Oque, 'Admin' as Modulo
from GNAPPROVRESP rotaprov
inner join GNAPPROV aprov on aprov.CDAPPROV = rotaprov.CDAPPROV
inner join ADAPPROVALROUTE route on route.CDAPPROVALROUTE = aprov.CDAPPROVALROUTE
left join ADTEAM eq on eq.cdteam = rotaprov.cdteam
left join addepartment dep on dep.cddepartment = rotaprov.cddepartment
where (rotaprov.cddepartment is null and rotaprov.CDTEAM is not null) or (rotaprov.cddepartment is not null and rotaprov.CDTEAM is null)
union
--Acesso às unidades de negócio do Desempenho
select
case
when buniac.FGACCESSTYPE = 5 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when buniac.FGACCESSTYPE = 1 then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Tem acesso na Unidade de negócio: ' + buni.IDBUSINESSUNIT + ' - ' + buni.NMBUSINESSUNIT as Oque, 'Desempenho' as Modulo
from STBUSINESUNITACCES buniac
left join ADTEAM eq on eq.cdteam = buniac.cdteam
left join addepartment dep on dep.cddepartment = buniac.cddepartment
inner join STBUSINESSUNIT buni on buni.cdbusinessunit = buniac.cdbusinessunit
where buniac.FGACCESSTYPE = 5 or buniac.FGACCESSTYPE = 1
union
--Visualização de Análises Gráficas
select
'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 
'Tem acesso na Análise Gráfica: ' + anagra.IDGRAPHANALYSIS + ' - ' + anagra.NMGRAPHANALYSIS as Oque, 'Desempenho' as Modulo
from STGRAPHANALYSIS anagra
left join ADTEAM eq on eq.cdteam = anagra.CDTEAMVIEW
where anagra.CDTEAMVIEW is not null
union
--Notificação de indicador de scorecard
select
'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 
'Recebe alerta do Indicador: ' + indic.IDSCMETRIC + ' | Indicador: ' + stindic.IDMETRIC + ' - ' + stindic.NMMETRIC +
' no Scorecard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque, 'Desempenho' as Modulo
from STSCMETRIC indic
left join ADTEAM eq on eq.cdteam = indic.CDTEAMALERT
left join stmetric stindic on stindic.cdmetric = indic.cdmetric
left join stscorecard score on score.cdscorecard = indic.cdscorecard
where indic.CDTEAMALERT is not null
union
--Segurança do item do ScoreCard
select
case
when (unidneg.cddepartment is null and unidneg.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (unidneg.cddepartment is not null and unidneg.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Tem acesso no item: ' + stitem.IDSCOREITEM + ' - ' + stitem.NMSCOREITEM + ' do ScoreCard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque, 'Desempenho' as Modulo
from STSCSTRUCTACCESS unidneg
inner join STSCSTRUCTITEM item on item.CDSCSTRUCTITEM = unidneg.CDSCSTRUCTITEM and item.CDSCORECARD = unidneg.CDSCORECARD and item.CDREVISION = unidneg.CDREVISION
inner join STSCOREITEM stitem on stitem.CDSCOREITEM = item.CDSCOREITEM
inner join STSCORECARD score on score.CDSCORECARD = unidneg.CDSCORECARD and score.CDREVISION = unidneg.CDREVISION
left join ADTEAM eq on eq.cdteam = unidneg.cdteam
left join addepartment dep on dep.cddepartment = unidneg.cddepartment
where (unidneg.cddepartment is null and unidneg.CDTEAM is not null) or (unidneg.cddepartment is not null and unidneg.CDTEAM is null)
union
--Responsável pela medição de indicadores
select
'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 
'Responsável pela Medição do Indicador: ' + indic.IDSCMETRIC + ' | Indicador: ' + stindic.IDMETRIC + ' - ' + stindic.NMMETRIC +
' no Scorecard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque, 'Desempenho' as Modulo
from STSCMETRIC indic
left join ADTEAM eq on eq.cdteam = indic.CDTEAMMETRIC
left join stmetric stindic on stindic.cdmetric = indic.cdmetric
left join stscorecard score on score.cdscorecard = indic.cdscorecard
where indic.CDTEAMMETRIC is not null
union
--Aprovações de indicador
select
'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 
'Faz aprovação do Indicador: ' + indic.IDSCMETRIC + ' | Indicador: ' + stindic.IDMETRIC + ' - ' + stindic.NMMETRIC +
' no Scorecard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque, 'Desempenho' as Modulo
from STSCMETRIC indic
left join ADTEAM eq on eq.cdteam = indic.CDTEAMAPPROV
left join stmetric stindic on stindic.cdmetric = indic.cdmetric
left join stscorecard score on score.cdscorecard = indic.cdscorecard
where indic.CDTEAMAPPROV is not null
union
--Visualização de indicadores
select
'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 
'É a equipe de Visualização do Indicador: ' + indic.IDSCMETRIC + ' | Indicador: ' + stindic.IDMETRIC + ' - ' + stindic.NMMETRIC +
' no Scorecard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque, 'Desempenho' as Modulo
from STSCMETRIC indic
left join ADTEAM eq on eq.cdteam = indic.CDTEAMVIEW
left join stmetric stindic on stindic.cdmetric = indic.cdmetric
left join stscorecard score on score.cdscorecard = indic.cdscorecard
where indic.CDTEAMVIEW is not null
union
--Responsável pela meta de indicadores
select
'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem, 
'Responsável pela Meta do Indicador: ' + indic.IDSCMETRIC + ' | Indicador: ' + stindic.IDMETRIC + ' - ' + stindic.NMMETRIC +
' no Scorecard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque, 'Desempenho' as Modulo
from STSCMETRIC indic
left join ADTEAM eq on eq.cdteam = indic.CDTEAMTARGET
left join stmetric stindic on stindic.cdmetric = indic.cdmetric
left join stscorecard score on score.cdscorecard = indic.cdscorecard
where indic.CDTEAMTARGET is not null
union
--Acesso em Scorecards
select
case
when scoreac.cdteam is not null then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when scoreac.cddepartment is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Tem acesso no Scorecard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque, 'Desempenho' as Modulo
from STSCORECARDACCESS scoreac
left join ADTEAM eq on eq.cdteam = scoreac.cdteam
left join addepartment dep on dep.cddepartment = scoreac.cddepartment
inner join STSCORECARD score on score.cdscorecard = scoreac.cdscorecard and score.cdrevision = scoreac.cdrevision
where (scoreac.cdteam is not null and scoreac.cddepartment is null) OR (scoreac.cdteam is null and scoreac.cddepartment is not null)
union
--Acesso em Indicadores
select
case
when metric.FGACCESSTYPE = 1 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (metric.FGACCESSTYPE = 2 OR metric.FGACCESSTYPE = 3) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
'Tem acesso no Indicador: ' + indic.idscmetric + ' | Indicador: ' + stindic.IDMETRIC + ' - ' + stindic.NMMETRIC + ' no Scorecard: ' + score.IDSCORECARD + ' - ' + score.NMSCORECARD as Oque,
'Desempenho' as Modulo
from STSCMETRICACCESS metric
left join ADTEAM eq on eq.cdteam = metric.CDTEAM
left join addepartment dep on dep.cddepartment = metric.cddepartment
left join stscmetric indic on indic.cdscmetric = metric.cdscmetric and indic.cdscorecard = metric.cdscorecard and indic.cdrevision = metric.cdrevision
left join stmetric stindic on stindic.cdmetric = indic.cdmetric
left join stscorecard score on score.cdscorecard = indic.cdscorecard and score.cdrevision = indic.cdrevision
where metric.FGACCESSTYPE in (1,2,3)
union
--Processo de revisão de documentos
select
case
when (rrev.cdteam is not null and rrev.cddepartment is null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (rrev.cdteam is null and rrev.cddepartment is not null and rrev.CDUSER is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
'Participa do processo de revisão como: ' + case
when FGSTAGE = 1 then 'Elaborador'
when FGSTAGE = 2 then 'Consensador'
when FGSTAGE = 3 then 'Aprovador'
when FGSTAGE = 4 then 'Homologador'
end + ' | do documento: ' + rev.iddocument + ' - ' + rev.nmtitle + ' | da Categoria: ' + cat.idcategory + ' - ' + cat.nmcategory as Oque,
'Documentos' as Modulo
from GNREVISIONSTAGMEM rrev
left join dcdocrevision rev on rev.cdrevision = rrev.cdrevision
left join dcdocument doc on doc.cddocument = rev.cddocument
left join adteam eq on eq.cdteam = rrev.cdteam
left join addepartment dep on dep.cddepartment = rrev.cddepartment
left join dccategory cat on cat.cdcategory = rev.cdcategory
where doc.FGSTATUS in (1,3) and (rrev.cdteam is not null or (rrev.cddepartment is not null and rrev.CDUSER is null))
union
--Segurança do tipo de Guia de Remessa
select
case
when trdef.fgaccesstype = 1 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (trdef.fgaccesstype = 2 or trdef.fgaccesstype = 3) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
'Está na lista de acesso do Tipo de GR: ' + gntype.IDGENTYPE + ' - ' + gntype.NMGENTYPE as Oque, 'Documentos' as Modulo
from GNGENTYPE gntype
left join GNTYPEROLEDEF trdef on trdef.CDTYPEROLE = gntype.CDTYPEROLE
left join GNTYPEROLE perm on perm.CDTYPEROLE = gntype.CDTYPEROLE
left join ADTEAM eq on eq.cdteam = trdef.cdteam
left join addepartment dep on dep.cddepartment = trdef.cddepartment
where gntype.CDISOSYSTEM = 0 and trdef.fgaccesstype in (1,2,3)
union
--Regra de e-mails de Projetos
select
case
when (rto.CDDEPARTMENT is null and rto.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (rto.CDDEPARTMENT is not null and rto.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Está na lista de e-mails da Regra: ' + gnm.IDMAILRULE + ' - ' + gnm.NMMAILRULE as Oque, 'Projetos' as Modulo
from GNMAILRULETO rto
inner join GNMAILRULE gnm on gnm.CDMAILRULE = rto.CDMAILRULE
left join ADTEAM eq on eq.cdteam = rto.cdteam
left join addepartment dep on dep.cddepartment = rto.cddepartment
where (rto.CDDEPARTMENT is null and rto.CDTEAM is not null) or (rto.CDDEPARTMENT is not null and rto.CDTEAM is null)
union
--Segurança do Portfólio de projetos
select
'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment as Quem, 
'Está na lista de acesso do Portfólio: ' + pf.IDPORTFOLIO + ' - ' + pf.NMPORTFOLIO + ' do tipo: ' + pft.IDPORTFOLIOTYPE + ' - ' + pft.NMPORTFOLIOTYPE as Oque,
'Projetos' as Modulo
from PRPORTFOLIO pf
inner join PRPORTFOLIOACCESS pfa on pfa.CDPORTFOLIO = pf.CDPORTFOLIO
inner join PRPORTFOLIOTYPE pft on pft.CDPORTFOLIOTYPE = pf.CDPORTFOLIOTYPE
left join addepartment dep on dep.cddepartment = pfa.cddepartment
where pf.FGRESTRICT = 2 and pf.FGENABLED = 1 and (pfa.FGTEAMMEMBER = 1 or pfa.FGTEAMMEMBER = 3)
union
--Segurança do tipo de Almoxarifado
select
case
when trdef.fgaccesstype = 1 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (trdef.fgaccesstype = 2 or trdef.fgaccesstype = 3) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
'Está na lista de acesso do Tipo de Almoxarifado: ' + gntype.IDGENTYPE + ' - ' + gntype.NMGENTYPE as Oque, 'Almoxarifado' as Modulo
from GNGENTYPE gntype
left join GNTYPEROLEDEF trdef on trdef.CDTYPEROLE = gntype.CDTYPEROLE
left join GNTYPEROLE perm on perm.CDTYPEROLE = gntype.CDTYPEROLE
left join ADTEAM eq on eq.cdteam = trdef.cdteam
left join addepartment dep on dep.cddepartment = trdef.cddepartment
where gntype.CDISOSYSTEM = 180 and trdef.fgaccesstype in (1,2,3)
union
--Segurança do Almoxarifado
select
case
when acc.CDTEAM is not null then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when acc.CDDEPARTMENT is not null then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
'Está na lista de acesso do Almoxarifado: ' + stroom.idstoreroom + ' - ' + stroom.nmstoreroom as Oque, 'Almoxarifado' as Modulo
from GNSTOREROOM stroom
left join GNSTOREACCESSROLE acc on acc.cdstoreroom = stroom.cdstoreroom
left join ADTEAM eq on eq.cdteam = acc.cdteam
left join addepartment dep on dep.cddepartment = acc.cddepartment
where acc.cdteam is not null or acc.cddepartment is not null
union
--Responsável e Dono de Almoxarifado
select
'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Quem,
'É responsável pelo Almoxarifado: ' + stroom.idstoreroom + ' - ' + stroom.nmstoreroom as Oque, 'Almoxarifado' as Modulo
from GNSTOREROOM stroom
left join ADTEAM eq on eq.cdteam = stroom.CDTEAMRESP
left join addepartment dep on dep.cddepartment = stroom.CDDEPARTMENT
where stroom.CDTEAMRESP is not null
union
select
'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment as Quem,
'É dona do Almoxarifado: ' + stroom.idstoreroom + ' - ' + stroom.nmstoreroom as Oque, 'Almoxarifado' as Modulo
from GNSTOREROOM stroom
left join ADTEAM eq on eq.cdteam = stroom.CDTEAMRESP
left join addepartment dep on dep.cddepartment = stroom.CDDEPARTMENT
where stroom.cddepartment is not null
union
--Segurança do tipo de Problema
select
case
when trdef.fgaccesstype = 1 then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (trdef.fgaccesstype = 2 or trdef.fgaccesstype = 3) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem,
'Está na lista de acesso do Tipo de Problema: ' + gntype.IDGENTYPE + ' - ' + gntype.NMGENTYPE as Oque, 'Problema' as Modulo
from GNGENTYPE gntype
left join GNTYPEROLEDEF trdef on trdef.CDTYPEROLE = gntype.CDTYPEROLE
left join GNTYPEROLE perm on perm.CDTYPEROLE = gntype.CDTYPEROLE
left join ADTEAM eq on eq.cdteam = trdef.cdteam
left join addepartment dep on dep.cddepartment = trdef.cddepartment
where gntype.CDISOSYSTEM = 202 and trdef.fgaccesstype in (1,2,3)
union
--Permissões nos DashBoards
select
case
when (dashb.cddepartment is null and dashb.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (dashb.cddepartment is not null and dashb.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Tem acesso no DashBoard: ' + dash.IDDASHBOARD + ' - ' + dash.NMDASHBOARD as Oque, 'DashBoards' as Modulo
from ADDASHBOARDROLE dashb
inner join ADDASHBOARD dash on dash.cddashboard = dashb.cddashboard
left join ADTEAM eq on eq.cdteam = dashb.cdteam
left join addepartment dep on dep.cddepartment = dashb.cddepartment
where (dashb.cddepartment is null and dashb.CDTEAM is not null) or (dashb.cddepartment is not null and dashb.CDTEAM is null)
union
--Tem acesso aos atributos de Protocolos
select
case
when (atribprot.cddepartment is null and atribprot.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (atribprot.cddepartment is not null and atribprot.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'Tem acesso ao Atributo: ' + atrib.NMATTRIBUTE + ' do Protocolo: ' + prot.IDPROCEEDING + ' - ' + prot.NMTITLE as Oque, 'Protocolo' as Modulo
from DCPROCATTRIB atribprot
inner join DCPROCEEDING prot on prot.CDPROCEEDING = atribprot.CDPROCEEDING
inner join adattribute atrib on atrib.CDATTRIBUTE = atribprot.CDATTRIBUTE
left join ADTEAM eq on eq.cdteam = atribprot.cdteam
left join addepartment dep on dep.cddepartment = atribprot.cddepartment
where (atribprot.cddepartment is null and atribprot.CDTEAM is not null) or (atribprot.cddepartment is not null and atribprot.CDTEAM is null)
union
--Áreas membros de Equipe
select 
'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment as Quem,
'É membro da Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM as Oque, 'Admin' as Modulo
from ADTEAMMEMBER mem
left join addepartment dep on dep.cddepartment = mem.cddepartment
left join ADTEAM eq on eq.cdteam = mem.cdteam
where mem.cddepartment is not null
union
--Notificado em Agendamento
select
case
when (notif.cddepartment is null and notif.CDTEAM is not null) then 'Equipe: ' + eq.IDTEAM + ' - ' + eq.NMTEAM
when (notif.cddepartment is not null and notif.CDTEAM is null) then 'Área: ' + dep.iddepartment + ' - ' + dep.nmdepartment
end as Quem, 
'É notificada no Agendamento: ' + sched.IDSCHEDULE + ' - ' + sched.NMSCHEDULE as Oque, 'Admin' as Modulo
from GNSCHEDULENOTIFIC notif
inner join GNSCHEDULE sched on sched.CDSCHEDULE = notif.CDSCHEDULE
left join ADTEAM eq on eq.cdteam = notif.cdteam
left join addepartment dep on dep.cddepartment = notif.cddepartment
where (notif.cddepartment is null and notif.CDTEAM is not null) or (notif.cddepartment is not null and notif.CDTEAM is null)
union
--Lista das Equipes x Módulo
select 'Equipe: ' + team.IDTEAM + ' - ' + team.NMTEAM as Quem,
'Está cadastrada no módulo: ' + adsys.NMISOSYSTEM as Oque, 'Admin' as Modulo
from ADTEAMMODULE teamm
inner join adteam team on team.cdteam = teamm.cdteam
inner join ADISOSYSTEM adsys on adsys.CDISOSYSTEM = teamm.CDISOSYSTEM
) tudo
group by tudo.modulo, tudo.quem, tudo.oque