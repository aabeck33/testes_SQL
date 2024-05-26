--=====Formulário
	1-Habilitar | 2-Desabilitar | 3-Requerido | 4-Não requerido | 5-Exibir | 6-Ocultar | 7-Limpar | 8-Recarregar | 9-Variável
--== Correções em formulários
Desvio - Completo - Campo descrição do equipamento (tds075) está sem o atributo
Jurídico - fazer controle de preenchimento do formulário de compras no formulário principal pra GERCONSEC

--=======================> WFStruct
FGTYPE	Tipo [1 - Processo; 2 - Atividade; 3 - Decisão; 4 - Conector fork; 5 - Conector join; 6 - Finalizador; 7 - Início; 20 - Início com timer; 22 - Evento de timer; 23 - Evento de mensagem]
FGSTATUS	Situação [1 - A iniciar; 2 - Habilitado; 3 - Executado; 4 - Suspenso; 5 - Cancelado; 6 - Recusado; 7 - Aprovação de retorno]

--=====================> Tipos de validade
gnrevision
fgvaliditytype:
	1 -> Por data
	2 -> Por tempo
	3 -> Sem validade
--=====================> DOC audit
CASE WHEN FGTYPE=1 THEN 'View document' WHEN FGTYPE=2 THEN 'Registered document' WHEN FGTYPE=3 THEN 'Document deleted' WHEN FGTYPE=4 THEN 'Registered revision' WHEN FGTYPE=5 THEN 'Deleted revision' WHEN FGTYPE=6 THEN 'Closed revision' WHEN FGTYPE=7 THEN 'Printed controlled copy' WHEN FGTYPE=8 THEN 'Printed uncontrolled copy' WHEN FGTYPE=9 THEN 'Modified amount of scheduled copies' WHEN FGTYPE=10 THEN 'Quantity per batch/hours was modified' WHEN FGTYPE=11 THEN 'Canceled document' WHEN FGTYPE=12 THEN 'Released document' WHEN FGTYPE=13 THEN 'Deleted electronic file' WHEN FGTYPE=14 THEN 'Registered archiving' WHEN FGTYPE=15 THEN 'Canceled archiving' WHEN FGTYPE=16 THEN 'Digital signature' WHEN FGTYPE=17 THEN 'Add electronic file' WHEN FGTYPE=18 THEN 'Add PDF version for electronic file' WHEN FGTYPE=19 THEN 'Delete PDF version for electronic file' END

--==========> Regex para MM/YYYY
(?:(?:0[1-9]|1[0-2]))[\/](?:19|20)[0-9]{2}

--==========================> Primeiro e último dia do mês anterior
SELECT DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0) as FirstDayPreviousMonthWithTimeStamp,
    DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, 0, getdate()), 0)) as LastDayPreviousMonthWithTimeStamp

--==========================> ùltimo dia do mês corrente
SELECT DATEADD(DD, -DAY(DATEADD(M, 1, getdate())), DATEADD(M, 1, getdate())) AS UltimoDiaMes;

--=========================> Concatenar linhas (as [text()]) - Oracle
select listagg(grid.ender, ',') WITHIN GROUP ( ORDER BY grid.ender ) AS lista from DYNpao05 grid
--============> exemplo
SELECT 
  color as [@color]
  ,'Some info about ' + name AS [text()]
  ,name + ' likes ' + color AS [comment()]
  ,name
  ,name + ' has some ' + color + ' things' AS [info/text()]
FROM #favorite_colors
FOR XML PATH
--================================> Voltar a imagem da tela de login padrão
SELECT OIDLOGINLARGEBLOB FROM COSYSTEMSETTINGS
/* ff80808170aae9c10170c4ba730678ad */
UPDATE COSYSTEMSETTINGS SET OIDLOGINLARGEBLOB = NULL
DELETE FROM SEBLOB WHERE OID = 'ff80808170aae9c10170c4ba730678ad'
--================================>
select stuff((
select cast(';' as nvarchar(max)) + cast(usr.DSUSEREMAIL as varchar(max)) as [text()]
from aduser usr
inner join DCDOCACCESSROLE dcr on dcr.CDUSER = usr.CDUSER
inner join DCDOCREVISION rev on dcr.CDDOCUMENT = rev.CDDOCUMENT
where rev.iddocument = 'TINP003'
and dcr.FGPERMISSION = 1 and dcr.FGACCESSKNOW = 1
FOR XML PATH('')), 1, 1, '')
group by ...

--============================> nome do arquivo eletrônico
SELECT CDFILE, NMFILE FROM GNFILE WHERE CDCOMPLEXFILECONT IN(SELECT CDCOMPLEXFILECONT FROM DCFILE WHERE CDDOCUMENT IN(SELECT CDDOCUMENT FROM DCDOCREVISION WHERE IDDOCUMENT='identificador do documento'))
o comando irá retornar conforme exemplo abaixo:
cdfile  nmfile
33      Teste.doc
O nome do arquivo no diretório controlado, irá ser:
00000033.doc ou  00000033.doc.gz se estiver compactado.

--=====================> Competência

select * from (
select plano, grupo, position, nmhabtipo, nmuser
, sum(VLLEVEL) as nivel, sum(VLLEVELHAB) as habilidade, sum(VLLEVELGOAL) as meta, sum(vlnote) as nota
from (
select evlp.cdevalplan as cdplano, evlp.idevalplan as idplano, evlp.nmevalplan as nmplano, concat(evlp.idevalplan, '-', evlp.nmevalplan) as plano
, evle.cdevalexec as cdexec, evle.fgstatus as execstatus
, evl.cdeval as cdavalia, evl.cduser as cdusuarioavaliado, evl.cdusereval as cduseravaliador, evl.fgtype as tipoavalia, evl.fgstatus as avaliastatus
, teh.cdhability as cdhabilidade, teh.cdlevel as habinivel, teh.cdscale as cdescala, teh.nrrevision as habversao, teh.cdmapping as tehmapping, teh.VLNOTE
, hab.idhability as idhabilidade, hab.nmhability as nmhabilidade
, habt.cdhabilitytype as cdhabtipo, habt.idhabilitytype as idhabtipo, habt.nmhabilitytype nmhabtipo
, trusr.*, concat(pos.idposition, '-', pos.nmposition) as position, concat(dep.iddepartment, '-', dep.nmdepartment) as department
, CASE WHEN EVL.FGTYPE=1 THEN CAST('#{113632}' AS VARCHAR (255)) WHEN EVL.FGTYPE=2 THEN CAST('#{113644}' AS VARCHAR (255)) WHEN EVL.FGTYPE=3 THEN CAST('#{109227}' AS VARCHAR (255)) WHEN EVL.FGTYPE=4 THEN CAST('#{100585}' AS VARCHAR (255)) WHEN EVL.FGTYPE=5 THEN CAST('#{104231}' AS VARCHAR (255)) END AS tipoaval
, EVL.VLLEVEL, EVL.VLLEVELHAB, EVL.VLPROGRESS, EVL.VLLEVELGOAL
, case when pos.nmposition like '%supervisor%' or pos.nmposition like '%gerente%' then 'Supervisores e Gerentes' else 'Demais cargos' end grupo
FROM TREVALPLAN EVLP
inner join TREVALEXEC EVLE on evle.cdevalplan = evlp.cdevalplan
inner join TREVAL EVL ON EVLE.CDEVALEXEC = EVL.CDEVALEXEC
INNER JOIN TREVALHAB TEH ON TEH.CDEVAL = EVL.CDEVAL and teh.CDEVALEXEC = evl.CDEVALEXEC
inner join trhability hab on hab.cdhability = TEH.cdhability
inner join TREVALEXECHAB TEHE on TEHE.CDEVALEXEC = TEH.CDEVALEXEC and TEHE.cdhability = TEH.cdhability
inner join TRHABILITYTYPE habt on habt.cdhabilitytype = hab.cdhabilitytype
inner join (select usr.cduser, usr.nmuser, usr.idlogin, truser.cdevalexec
from aduser usr
inner join TREVALEXECMEMBER truser on truser.cduser = usr.cduser
) trusr on trusr.cdevalexec = EVL.CDEVALEXEC and trusr.cduser = teh.cduser
inner join aduserdeptpos rel on rel.cduser = trusr.cduser and rel.fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
where evl.fgstatus = 4
and evlp.cdevalplan=33
  ) sub
group by rollup (plano, grupo, position, nmhabtipo, nmuser)
  ) sub1
where nmuser is not null


--====================> Pivot
SELECT *
FROM
(
    SELECT [PolNumber],
           [PolType],
           [Effective Date],
           [DocName],
           [Submitted]
    FROM [dbo].[InsuranceClaims]
) AS SourceTable PIVOT(AVG([Submitted]) FOR [DocName] IN([Doc A],
                                                         [Doc B],
                                                         [Doc C],
                                                         [Doc D],
                                                         [Doc E])) AS PivotTable;

--========================> Equipes a que um usuário pertence
select adt.idteam,adt.nmteam
from adteam adt
inner join adteammember adtm on adtm.cdteam = adt.cdteam
where adtm.cduser = (select cduser from aduser where idlogin = 'pberaldo')

--=======================> Parte do texto entre 2 #
select substring(adr.nmrole, charindex('#',adr.nmrole)+2,len(left(substring(adr.nmrole, charindex('#',adr.nmrole)+2,255),charindex('#',substring(adr.nmrole, charindex('#',adr.nmrole)+2,255))))-2) as nmobjeto
, adr.idrole as idobjeto, nmrole as donoapr
from adrole adr
where cdroleowner = 1430 and (right(adr.idrole,4) = :unid or right(adr.idrole,4) = 'CORP')

--=======================> WFSTRUCT
wfs.FGSTATUS -> Situação [1 - A iniciar; 2 - Habilitado; 3 - Executado; 4 - Suspenso; 5 - Cancelado; 6 - Recusado; 7 - Aprovação de retorno]
wfs.fgtype -> Tipo [1 - Processo; 2 - Atividade; 3 - Decisão; 4 - Conector fork; 5 - Conector join; 6 - Finalizador; 7 - Início; 20 - Início com timer; 22 - Evento de timer; 23 - Evento de mensagem]

--========================> Categorias com retenção diferente de tudo
select IDCATEGORY, conf.QTREVRETENTION
from dccategory cat
inner join gnrevconfig conf on conf.CDREVCONFIG = cat.CDCATEGORY
where conf.QTREVRETENTION is not null and conf.QTREVRETENTION not like '99%'
--and exists (select 1 from dcdocrevision rev where rev.cdcategory = cat.cdcategory)

--========================> Ad-hoc
select gnact.idactivity, gnact.nmactivity, gnactowner.nmactivity as nmactowner
from wfactivity wfa
inner join WFSTRUCT wfs on wfs.idobject = wfa.IDOBJECT
inner join WFPROCESS wfp on wfp.idobject = wfs.idprocess
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
inner join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wfa.FGACTIVITYTYPE = 3 and wfp.idobject = (select idobject from wfprocess where idprocess = '016669')
--=======================> Campos da entidade
select attr.*
from emattrmodel attr
left join EMENTITYMODEL tab on tab.oid = attr.oidentity
where tab.idname = 'con001'

--==================> Base de conhecimento
select *
from kbarticlerevision kbr
inner join kbarticlerevlanguage kbri on kbri.oidrevisionarticle = kbr.oid
inner join kbknowledgebase kbc on kbc.oid = kbr.oidknowledgebase
where fgstatus = 2 and fgcurrent = 1 and idKnowledgebase = 'ITSM' and fglanguage = (select fglanguage from aduser where cduser = :cduser)

-----------

SELECT
        COUNT(KBV.OIDARTICLE) AS TOTAL,
        TBREV.ID,
        TBREV.TITLE,
        TBREV.IDKNOWLEDGEBASE,
        TBREV.NMKNOWLEDGEBASE,
        to_timestamp(KBV.BNTIMEVIEWED / 1000)::date AS DtDayViewed 
    FROM
        KBARTICLEVIEWED KBV 
    INNER JOIN
        (
            SELECT
                KBREV.OIDARTICLE,
                KBREV.OID,
                KBREV.IDARTICLE AS ID,
                KBARL.NMARTICLE AS TITLE,
                KB.IDKNOWLEDGEBASE,
                KB.NMKNOWLEDGEBASE 
            FROM
                KBKNOWLEDGEBASE KB 
            INNER JOIN
                KBARTICLEREVISION KBREV 
                    ON KBREV.OIDKNOWLEDGEBASE = KB.OID 
            INNER JOIN
                KBARTICLEREVLANGUAGE KBARL 
                    ON (
                        KBARL.OIDREVISIONARTICLE = KBREV.OID
                    ) 
            INNER JOIN
                (
                    SELECT
                        CASE 
                            WHEN MAX(USERLANG) > 0 THEN MAX(USERLANG) 
                            WHEN MAX(BASELANG) > 0 
                            AND MAX(USERLANG) = 0 THEN MAX(BASELANG) 
                            ELSE MIN(FIRSTENABLEDLANG) 
                        END AS FGLANGUAGE,
                        KBAR1.OID,
                        KBAR1.OIDKNOWLEDGEBASE 
                    FROM
                        KBARTICLEREVISION KBAR1 
                    INNER JOIN
                        (
                            SELECT
                                KBAR.OID,
                                KLD.FGLANGUAGE AS USERLANG,
                                0 AS BASELANG,
                                99 AS FIRSTENABLEDLANG 
                            FROM
                                KBARTICLEREVISION KBAR    
                            INNER JOIN
                                KBLANGUAGEDATA KLD 
                                    ON (
                                        KBAR.OIDKNOWLEDGEBASE = KLD.OIDKNOWLEDGEBASE 
                                        AND KLD.FGENABLED = 1 
                                        AND KLD.FGLANGUAGE = 2 
                                    ) 
                            INNER JOIN
                                KBARTICLEREVLANGUAGE KBARL 
                                    ON (
                                        KBARL.OIDREVISIONARTICLE = KBAR.OID 
                                        AND KLD.FGLANGUAGE = KBARL.FGLANGUAGE
                                    ) 
                            WHERE
                                KBARL.NMARTICLE IS NOT NULL 
                            UNION
                            SELECT
                                KBAR.OID,
                                0 AS USERLANG,
                                BASELANG.CDBASELANGUAGE AS BASELANG,
                                99 AS FIRSTENABLEDLANG 
                            FROM
                                KBARTICLEREVISION KBAR     
                            INNER JOIN
                                KBBASELANGCONFIG BASELANG 
                                    ON (
                                        BASELANG.CDLANGUAGE = 2
                                    ) 
                            INNER JOIN
                                KBLANGUAGEDATA KLD 
                                    ON (
                                        KBAR.OIDKNOWLEDGEBASE = KLD.OIDKNOWLEDGEBASE 
                                        AND KLD.FGLANGUAGE = BASELANG.CDBASELANGUAGE 
                                        AND KLD.FGENABLED = 1 
                                        AND KLD.FGLANGUAGE <> 2 
                                    ) 
                            INNER JOIN
                                KBARTICLEREVLANGUAGE KBARL 
                                    ON (
                                        KBARL.OIDREVISIONARTICLE = KBAR.OID 
                                        AND KLD.FGLANGUAGE = KBARL.FGLANGUAGE
                                    ) 
                            WHERE
                                KBARL.NMARTICLE IS NOT NULL 
                            UNION
                            SELECT
                                KBAR.OID,
                                0 AS USERLANG,
                                0 AS BASELANG,
                                MIN(KLD.FGLANGUAGE) AS FIRSTENABLEDLANG 
                            FROM
                                KBARTICLEREVISION KBAR 
                            INNER JOIN
                                KBLANGUAGEDATA KLD 
                                    ON (
                                        KBAR.OIDKNOWLEDGEBASE = KLD.OIDKNOWLEDGEBASE 
                                        AND KLD.FGENABLED = 1 
                                        AND KLD.FGLANGUAGE <> 2 
                                    ) 
                            INNER JOIN
                                KBARTICLEREVLANGUAGE KBARL 
                                    ON (
                                        KBARL.OIDREVISIONARTICLE = KBAR.OID 
                                        AND KLD.FGLANGUAGE = KBARL.FGLANGUAGE
                                    ) 
                            WHERE
                                KBARL.NMARTICLE IS NOT NULL 
                            GROUP BY
                                KBAR.OID,
                                KLD.OID 
                        ) KBASELANGINNER 
                            ON (
                                KBAR1.OID = KBASELANGINNER.OID
                            ) 
                    GROUP BY
                        KBAR1.OID,
                        KBAR1.OIDKNOWLEDGEBASE 
                ) KBASELANG 
                    ON (
                        KBASELANG.OID = KBARL.OIDREVISIONARTICLE 
                        AND KBARL.FGLANGUAGE = KBASELANG.FGLANGUAGE
                    ) 
            INNER JOIN
                KBLANGUAGEDATA KBLD 
                    ON (
                        KBLD.OIDKNOWLEDGEBASE = KBASELANG.OIDKNOWLEDGEBASE 
                        AND KBASELANG.FGLANGUAGE = KBLD.FGLANGUAGE
                    ) 
            WHERE
                1 = 1 
                AND KBREV.FGCURRENT = 1 
        ) TBREV 
            ON KBV.OIDARTICLE = TBREV.OIDARTICLE 
    GROUP BY
        KBV.OIDARTICLE,
        TBREV.OID,
        TBREV.ID,
        TBREV.TITLE,
        TBREV.IDKNOWLEDGEBASE,
        TBREV.NMKNOWLEDGEBASE,
        DtDayViewed 
    ORDER BY
        TOTAL DESC
--==================> SLA (dev)
select wf.idprocess, wf.CDSLACONTROL, wf.FGSLASTATUS, wf.FGSLAFINISHSTATUS, wf.FGFIRSTRESPSTATUS, wf.FGFSTRFINISHSTATUS
, wf.dtstart + wf.tmstart as prstart
, DATEADD(ms, gnslactrl.BNSLASTART % 1000, DATEADD(ss, gnslactrl.BNSLASTART/1000, CONVERT(DATETIME2(3),'19700101'))) as inicio
, DATEADD(ms, gnslactrl.BNSLAFINISHPLAN % 1000, DATEADD(ss, gnslactrl.BNSLAFINISHPLAN/1000, CONVERT(DATETIME2(3),'19700101'))) as fimPlan
, DATEADD(ms, gnslactrl.BNFSTRFINISHPLAN % 1000, DATEADD(ss, gnslactrl.BNFSTRFINISHPLAN/1000, CONVERT(DATETIME2(3),'19700101'))) as FSfimPlan
from wfprocess wf
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
inner join GNSLA gnsla on gnsla.cdsla = gnslactrl.cdsla and gnsla.FGENABLED = 1
--inner join GNSLALEVEL sla on sla.cdsla = gnslactrl.cdsla
--inner join GNSLASTATUS slast on slast.cdsla = gnsla.cdsla
--where cdprocessmodel=

fgslastatus / FGFIRSTRESPSTATUS
    40 = Stop
    10 = Play
    30 = Pause
	20 = FirstResponse
FGSLAFINISHSTATUS / FGFSTRFINISHSTATUS
	1 = em dia
	2 = atrasado

FGSLAFINISHSTATUS	Diferença entre [Início real do SLA - Início do SLA]
BNSLASTART	Data de início
BNSLASTARTREAL	Início real
BNSLAFINISHPLAN	Prazo
BNSLAFINISH	Data de término
QTSLAWAITTIME	
QTSLAWAITTIMECAL	Diferença entre [Início real do SLA - Início do SLA] considerando calendário
QTSLAWORKTIME	Tempo de processamento, tempo real: Inicia a contagem após usuário aceitar a tarefa. Diferença entre [Término do SLA - Início real do SLA]
QTSLAWORKTIMECAL	Tempo de processamento, tempo real: Inicia a contagem após usuário aceitar a tarefa. Diferença entre [Término do SLA - Início real do SLA] considerando calendário
QTSLAPAUSETIME	Quantidade de tempo que o SLA ficou em "Pause"
QTSLAPAUSETIMECAL	Quantidade de tempo que o SLA ficou em "Pause" considerando o calendário
QTSLATOTALTIME	Tempo total. Diferença entre [Término do SLA - Início do SLA]
QTSLATOTALTIMECAL	Tempo total. Diferença entre [Término do SLA - Início do SLA] considerando calendário
FGFIRSTRESPSTATUS	Status de primeira resposta [20 - Em primeira resposta; 40 - Encerrado]
FGFSTRFINISHSTATUS	Status do término de primeira resposta [1 - Em dia; 2 - Em atraso]
BNFSTRSTART	Início da primeira resposta
BNFSTRSTARTREAL	Início real de primeira resposta [Contagem após usuário aceitar a tarefa]
BNFSTRFINISHPLAN	Início real do SLA [Contagem após usuário aceitar a tarefa] considerando calendário
BNFSTRFINISH	Término da primeira resposta
QTFSTRWAITTIME	Diferença entre [Início real da primeira resposta - Início da primeira resposta]
QTFSTRWAITTIMECAL	Diferença entre [Início real da primeira resposta - Início da primeira resposta] considerando calendário
QTFSTRWORKTIME	Tempo de processamento, tempo real: Inicia a contagem após usuário aceitar a tarefa. Diferença entre [Término da primeira resposta - Início real de primeira resposta]
QTFSTRWORKTIMECAL	Tempo de processamento, tempo real: Inicia a contagem após usuário aceitar a tarefa. Diferença entre [Término da primeira resposta - Início real de primeira resposta] considerando calendário
QTFSTRTOTALTIME	Tempo total. Diferença entre [Término da primeira resposta - Início da primeira resposta]
QTFSTRTOTALTIMECAL	Tempo total. Diferença entre [Término da primeira resposta - Início da primeira resposta] considerando o calendário
FGSLAVERSION	Versão
QTTIMECAL	Tempo decorrido (materializado)
QTTIMEFRSTCAL	Tempo decorrido de primeira resposta (materializado)
QTRESOLUTIONTIME	Tempo para resolução (em minutos)
QTTIME	Quantidade de tempo em segundos que o SLA ficou nesta situação
--============================
select slar.*
from PMACTREVISION pmar
inner join pmactivity p on p.CDACTIVITY = pmar.cdactivity
inner join GNSLALEVEL slar on slar.cdsla = pmar.cdsla
where fgcurrent = 1 and fgsla = 1
--=======================> Entidades que podem ser manipuladas no módulo - 0 não 1 sim
select idname,nmdisplayname,FGPUBLICENTITY
from EMENTITYMODEL model
order by FGPUBLICENTITY

--========================> Chamados de acesso
select wf.idprocess, form.sol014, wf.dtstart + wf.tmstart as dtstart, wf.dtfinish + wf.tmfinish as dtfinish
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS status
--
, case when datediff(DD, coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject), 0),
                         coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE str.fgstatus = 2 and str.idprocess = wf.idobject), 0)
                     ) <= 0 then (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
                                 WHERE str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject and str.idobject = wfa.idobject)
       else null 
   end as executor
, case when datediff(DD, coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject), 0),
                         coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE str.fgstatus = 2 and str.idprocess = wf.idobject), 0)
                     ) <= 0 then (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
                                 WHERE  str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject)
       else null 
   end as habilitada
, case when datediff(DD, coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject), 0),
                         coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE str.fgstatus = 2 and str.idprocess = wf.idobject), 0)
                     ) <= 0 then (SELECT str.DTEXECUTION + str.TMEXECUTION FROM WFSTRUCT STR
                                 WHERE str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject)
       else null 
   end as excutada
, case when datediff(DD, coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE  str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject), 0),
                         coalesce((SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR WHERE str.fgstatus = 2 and str.idprocess = wf.idobject), 0)
                     ) <= 0 then datediff(hh, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
                                              WHERE  str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject),
                                             (SELECT str.DTEXECUTION + str.TMEXECUTION FROM WFSTRUCT STR
                                              WHERE str.idstruct = 'Atividade1981103642935' and str.idprocess=wf.idobject))
       else null 
   end as tempo_hh
, (SELECT str.nmstruct FROM WFSTRUCT STR
   WHERE str.fgstatus = 2 and str.idprocess=wf.idobject) as atvatual
, (SELECT str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
   WHERE str.fgstatus = 2 and str.idprocess = wf.idobject) as atvatual_habilitada
, (SELECT str.DTEXECUTION + str.TMEXECUTION FROM WFSTRUCT STR
   WHERE str.fgstatus = 2 and str.idprocess=wf.idobject) as atvatual_excutada
, (SELECT case wfa.FGEXECUTORTYPE
               when 1 then nmrole
               when 3 then nmuser
               when 4 then nmuser
               else 'indefinido'
          end
   FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.fgstatus = 2 and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as atvatual_executor
from DYNsolws form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
where wf.cdprocessmodel = 5283 and form.sol014 like '%0010%'

--========================> Relatório de acessos ao módulo Treinamento em XLS
select distinct 'TRE' as idprocess, 'Treinamento' as nmprocess, ga.nmgroup as quem
, case when ga.idgroup = 'TRE_ADMIN' then 'Gestor corporativo de treinamneto'
       when ga.idgroup = 'TRE_ONLINE' then 'Partiipante em treinamentos online'
       when ga.idgroup = 'TRE_GEST' then 'Gestor de treinamento'
       when ga.idgroup = 'TRE_EXE' then 'Executor de treinamento'
       when ga.idgroup = 'TRE_CONSA' then 'Consulta avançada de treinamentos'
       when ga.idgroup = 'TRE_CONSB' then 'Consulta básica de treinamentos'
end as acesso
, '1' as tpacesso, ga.idgroup as idqq, ga.cdgroup as cdqq, usr.idlogin, usr.nmuser, usr.fguserenabled, pos.nmposition, dep.nmdepartment
from aduser usr
inner join aduseraccgroup gau on gau.cduser = usr.cduser
inner join adaccessgroup ga on ga.cdgroup = gau.cdgroup and ga.cdgroup in (36,37,38,44,46,69,85)
inner join aduserdeptpos rel on rel.cduser=usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment -- and dep.CDDEPTOWNER = (select CDDEPARTMENT from addepartment where IDDEPARTMENT = '0010 - UA')
inner join adposition pos on pos.cdposition = rel.cdposition
where usr.fguserenabled = 1
--inner join addepartment adc on adc.fgdepttype = 2 and adc.cddepartment = dep.cddeptowner
--=======================> Serviço rodando a mais de uma hora
select DATEADD(ms, BNSTART % 1000,DATEADD(ss, BNSTART/1000, CONVERT(DATETIME2(3),'19700101'))) dtstart, *
from gnqueuejob
where DATEADD(ms, BNSTART % 1000,DATEADD(ss, BNSTART/1000, CONVERT(DATETIME2(3),'19700101'))) < dateadd(hh, -1, getdate()) and BNFINISH is null
order by nmnamegroup,IDSERVICE,NMNAMEQUEUE,IDQUEUE

--==========================> Chamados entre um horario

select wf.idprocess, wf.dtstart+tmstart
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
where wf.cdprocessmodel = 5251 and wf.dtstart+tmstart between '2021-04-26 17:30' and '2021-04-27 12:00'
and wf.fgstatus = 1


--=======================> Retorno webservice
SELECT *
, DATEADD(ms, BNexecstart % 1000,DATEADD(ss, BNexecstart/1000, CONVERT(DATETIME2(3),'19700101'))) as dtexec
fROM emwslog
where IDDATASOURCE like '%workflow%'
ORDER BY bnexecstart DESC

--=============================================> Membros do grupo de acesso de uma unidade
select usr.idlogin
from aduseraccgroup urol
inner join aduser usr on usr.cduser = urol.cduser and FGUSERENABLED = 1
inner join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies = 17
where urol.cdgroup = (select cdgroup from adaccessgroup where idgroup = 'TRE_ADMIN')
--==============================================> Erros de sincronismo
select DATEADD(ms, BNFINISH % 1000,DATEADD(ss, BNFINISH/1000, CONVERT(DATETIME2(3),'19700101'))) as dtexec
, syn.NMERRORMESSAGE, IDLOGINCURRENT, NMUSERCURRENT, IDLOGINNEW, NMUSERNEW
from ADSYNCHRONIZATIONPROCESS syn
inner join ADSYNCHRONIZATIONRECORD rec on rec.oidprocesserror = syn.oid

--========================> Lista de Cubos públicos
select ana.IDIDENTIFIER, ana.NMNAME
from BI2ANALYSIS ana
inner join GNPERMISSION perm on perm.oid = ana.oid
where FGPUBLICREAD = 1

--=====> verificar problemas em Análise de causa
select * from GNSTRUCTRELATION where CDSTRUCTRELATION=CDRELATIONTO
delete from GNSTRUCTRELATION  where CDSTRUCTRELATION=CDRELATIONTO and CDANALISYS = xxxxxx

--==============================> Erro de fluxo de revisão
SELECT * FROM GNREVISIONSTAGMEM WHERE CDREVISION IN(preencher com os códigos retornados no primeiro comando separados por vírgula)
ORDER BY CDREVISION, NRCYCLE, FGSTAGE, NRSEQUENCE, DTAPPROVAL

SELECT * FROM GNREVUPDATE WHERE CDREVISION IN(preencher com os códigos retornados no primeiro comando separados por vírgula)
ORDER BY CDREVISION, CDUPDATE

UPDAT GNREVUPDATE SET NRCYCLE = 3 WHERE CDREVISION = 154455 AND CDUPDATE IN(6247463, 6247465)
UPDAT GNREVUPDATE SET NRCYCLE = 4 WHERE CDREVISION = 154455 AND CDUPDATE > 6247465

--=========================
with _sub as (
select iddocument as iddoc
, ROW_NUMBER() OVER(ORDER BY iddocument) as RowNum
from dcdocrevision
where fgcurrent = 1 and iddocument like 'pop-tds-g%'
) select * from _sub where RowNum = 2

select *
from (
	select form.oid, form.itsm001 as iddoc, 'https://sesuite.uniaoquimica.com.br/se/document/dc_view_document/api_view_document.php?nrdoc=' + form.itsm001 as link
	, ROW_NUMBER() OVER(ORDER BY form.itsm001) as RowNum
	from DYNitsm005 form
	where form.OIDABCOF6I5OE0ST0Q = (select oid from DYNitsm001) and form.itsm001 = :ident
)  _sub
where RowNum = :item



select distinct rev.iddocument
from  wfdocrequest wfr
inner join wfprocdocument wfd on wfd.idprocess = wfr.idprocess
inner join dcdocrevision rev on rev.cddocument = wfd.cddocument
where wfr.fgdoctype = 2 and wfd.idprocess = (select idobject from wfprocess where IDPROCESS = :idproc)

--========================> Dados do modelo do processo
select pmact.NMACTION
from pmprocess p
inner join PMPROCSTRUCT pstr on pstr.cdproc = p.cdproc
inner join pmstruct pms on pms.cdstruct = pstr.cdstruct
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join PMSTRUCTACTION pmact on pmact.cdstruct = pstr.cdstruct
where p.cdproc = 86

--========================> Relatório de acessos a propcessos em XLS
select _sub.*, usr.idlogin, usr.nmuser, usr.fguserenabled, pos.nmposition, dep.nmdepartment
from (
/* Lista de Roles */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-cm'
union all
/* Papeis funcionais do MEP */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join (select * from adrole) adr on adr.cdroleowner in (select cdrole from adrole where cdroleowner = (select cdrole from adrole where idrole = 'DHO-MEP'))
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'DHO-MEP' and pmap.idactivity = 'in-cm'
union all
/* Possíveis gestores de contrato */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = (select cdrole from adrole where idrole = 'JUR-GERCON_SENIORS')
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity like 'JUR-GERCON%' and pmap.idactivity = 'in-cm'
union all
/* Aprovadores GQ-ACESSO */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Aprovação VSC' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join (Select * from DYNuq055) adro on adro.ac004 is not null
inner join adrole adr on adr.idrole = adro.ac004
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'in-cm'
union all
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Aprovação Técnica' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join (Select * from DYNuq055) adro on adro.ac004 is not null
inner join adrole adr on (adr.idrole = adro.ac002 or adr.idrole = adro.ac005)
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'in-cm'
union all
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Operador do Sistema' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join (Select * from DYNuq055) adro on adro.ac004 is not null
inner join adrole adr on adr.idrole = adro.ac003
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'in-cm'
union all
/* Aprovadores de CM */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole in (select cdrole from adrole where cdroleowner in (select cdrole from adrole where substring(idrole, charindex('-', idrole), len(idrole)) = '-CM_APR'))
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-cm' and adr.idrole like case when pmap.idactivity = 'tds-cm' then 'an-cm_apr-%' else substring(pmap.idactivity, 1, 2) +'-cm_apr-%' end
union all
/* Investigadores de DE */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole in (select cdrole from adrole where substring(idrole, charindex('-', idrole), len(idrole)) = '-DE_INV')
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-cm' and adr.idrole like case when pmap.idactivity = 'tds-de' then 'an-de_inv' else substring(pmap.idactivity, 1, 2) +'-de_inv' end
union all
/* Gestores */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Gestor do processo' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
where pmp.fgprocenabled = 1
and pmap.fgstatus < 3
and pmap.idactivity = 'in-cm'
union all
/* Segurança do processo */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, qqq.qqnm as quem
, substring((select ' | '+ NMACCESSROLEFIELD as [text()] from PMPROCSECURITYCTRL pmps1 inner join PMACCESSROLEFIELD pmpsn1 on pmpsn1.cdACCESSROLEFIELD = pmps1.cdACCESSROLEFIELD and pmpsn1.FGOBJECTTYPE > 0
where pmps1.cdproc = pmpac.cdproc and pmps1.cdaccesslist = pmpac.cdaccesslist for XML path('')), 4, 4000) as acesso, pmpac.FGPERMISSION as tpacesso
, substring(qqq.qqnm, 1, charindex(' ', qqq.qqnm)) as idqq
, case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
where pmp.fgprocenabled = 1 and pmap.fgstatus < 3
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 00 or pmpac.cdteam is null)
and pmap.idactivity = 'in-cm'
union all
/* Aprovadores e Responsáveis de EQ */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq') then 'Lista QUA-009' 
       when (pmap.idactivity = 'ua-qe') then 'List QUA-031' else 'NA' end as quem
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq') then 'Aprovador Indicado' 
       when (pmap.idactivity = 'ua-qe') then 'Approver' else 'NA' end as acesso
, 1 as tpacesso
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq') then 'QUA-009' 
       when (pmap.idactivity = 'ua-qe') then 'QUA-031' else 'NA' end as idqq
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq') then (select cdattribute from adattribute where nmattribute = 'QUA-009')
       when (pmap.idactivity = 'ua-qe') then (select cdattribute from adattribute where nmattribute = 'QUA-031') else 0 end as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and (substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-qe' or substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-eq')
and pmap.idactivity = 'in-cm'
union all
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, case when (pmap.idactivity = 'tds-eq') then 'Lista QUA-012'
       when (pmap.idactivity = 'in-eq') then 'Lista QUA-023'
       when (pmap.idactivity = 'ua-qe') then 'List QUA-034' else 'NA' end as quem
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq') then 'Responsável pelo Evento de Qualidade'
       when (pmap.idactivity = 'ua-qe') then 'Quality Event Responsible' else 'NA' end as acesso
, 1 as tpacesso
, case when (pmap.idactivity = 'tds-eq') then 'QUA-012'
       when (pmap.idactivity = 'in-eq') then 'QUA-023'
       when (pmap.idactivity = 'ua-qe') then 'QUA-034' else 'NA' end as idqq
, case when (pmap.idactivity = 'tds-eq') then (select cdattribute from adattribute where nmattribute = 'QUA-012')
       when (pmap.idactivity = 'in-eq') then (select cdattribute from adattribute where nmattribute = 'QUA-023')
       when (pmap.idactivity = 'ua-qe') then (select cdattribute from adattribute where nmattribute = 'QUA-034') else 0 end as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and (substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-qe' or substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-eq')
and pmap.idactivity = 'in-cm'
union all
/* Lilsta de Aprovadores (Sistema/Area) GQ-Acesso */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, 'Lista - DYNuq057 - AC003' as quem, 'Aprovação - Responsável pelo Sistema/Área' as acesso
, 1 as tpacesso
, 'DYN057' as idqq, 3 as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'in-cm'
) _sub
inner join (select teamm.cdteam as cdqq, idteam as idqq, cduser from adteammember teamm inner join adteam team on team.cdteam = teamm.cdteam
            union all select rolem.cdrole as cdqq, idrole as idqq, cduser from aduserrole rolem inner join adrole rolek on rolek.cdrole = rolem.cdrole
            union all select distinct 3 as cdqq, 'DYNuq057' as idqq, (select cduser from aduser where nmuser = form.ac003) as cduser from DYNuq057 form
          ) rel on rel.cdqq = _sub.cdqq and rel.idqq = _sub.idqq
inner join aduser usr on usr.cduser = rel.cduser
inner join aduserdeptpos relu on relu.cduser = rel.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = relu.cddepartment --and dep.CDDEPTOWNER = (select CDDEPARTMENT from addepartment where IDDEPARTMENT = '0010 - UA')
inner join adposition pos on pos.cdposition = relu.cdposition
order by idprocess, acesso

--=============> Gerentes de Qualidade
select usr.nmuser, usr.dsuseremail
, dep.iddepartment, pos.nmposition
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join adposition pos on pos.cdposition = rel.cdposition
inner join addepartment dep on dep.cddepartment = rel.cddepartment
where usr.FGUSERENABLED = 1 and pos.idposition like '%ger%'and (dep.iddepartment like '%GQ%' or dep.iddepartment like '%CQ%')

--=========================> Aprovadores em celular
select usr.nmuser, pos.nmposition, idlogin, DSUSEREMAIL
from aduser usr
inner join aduseraccgroup uag on uag.cduser = usr.cduser and uag.CDGROUP = 40
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join adposition pos on pos.cdposition = rel.cdposition and (pos.nmposition like 'Dire%' or pos.nmposition like 'Vice%' or pos.nmposition like 'Ger%' or pos.nmposition like 'Manag%' or pos.nmposition like 'Coord%')
where usr.FGUSERENABLED = 1

--========================> Lista de chamados Iniciador x Solicitante (Guilhermo)

select wf.idprocess, wf.dtstart+wf.tmstart as abertura, wf.dtfinish+wf.tmfinish as fechamento, wf.nmuserstart as iniciador, form.itsm041 as solicitante, dep.iddepartment
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join aduserdeptpos rel on rel.cduser = wf.cduserstsart and fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
where wf.cdprocessmodel = 5251


--========================> Relatório de acessos a documentos em XLS
select quem, categoria, nmcat, permissoes, codeq, tpacesso, tppermissao
, usr1.nmuser, usr1.fguserenabled, dep.nmdepartment, pos.nmposition
from (select doc.FGACCESSTYPE as tpacesso
	, case doc.FGPERMISSION when 1 then 'Acesso concedido' when 2 then 'Acesso negado' end as tppermissao
	, case FGACCESSTYPE
              when 1 then case when doc.cdteam is null then 'Outros' else	(select eq.IDTEAM + ' - ' + eq.NMTEAM from adteam eq where eq.cdteam = doc.cdteam) end
              when 2 then (select dep.iddepartment +' - '+ dep.nmdepartment from addepartment dep where dep.cddepartment = doc.cddepartment)
              when 3 then (select dep.iddepartment +' - '+ dep.nmdepartment from addepartment dep where dep.cddepartment = doc.cddepartment) +' | '+
                  (select pos.idposition +' - '+ pos.nmposition from adposition pos where pos.cdposition = doc.cdposition)
              when 4 then (select pos.idposition +' - '+ pos.nmposition from adposition pos where pos.cdposition = doc.cdposition)
              when 5 then (select usr.idlogin +' - '+ usr.nmuser from aduser usr where usr.cduser = doc.cduser)
              when 6 then 'Todos'
	end as Quem, doc.cdteam as codeq
, cat.idcategory as categoria, cat.nmcategory as nmcat
, cat.idcategory, doc.CDACCESSROLE
, cast ((select substring(__sub.__permissoes, 2, 4000) as [text()] from (
        select case dcc.FGACCESSADD when 1 then '|Incluir' else '' end
        + case dcc.FGACCESSEDIT when 1 then '|Alterar' else '' end
        + case dcc.FGACCESSDELETE when 1 then '|Excluir' else '' end
        + case dcc.FGACCESSKNOW when 1 then '|Conhecimento' else '' end
        + case dcc.FGACCESSTRAIN when 1 then '|Treinamento' else '' end
        + case dcc.FGACCESSVIEW when 1 then '|Visualizar' else '' end
        + case dcc.FGACCESSPRINT when 1 then '|Imprimir' else '' end
        + case dcc.FGACCESSPHYSFILE when 1 then '|Arquivar' else '' end
        + case dcc.FGACCESSREVISION when 1 then '|Revisar' else '' end
        + case dcc.FGACCESSCOPY when 1 then '|Distribuir cópia' else '' end
        + case dcc.FGACCESSREGTRAIN when 1 then '|Registrar treinamento'  else '' end
        + case dcc.FGACCESSCANCEL when 1 then '|Cancelar' else '' end
        + case dcc.FGACCESSSAVE when 1 then '|Salvar localmente' else '' end
        + case dcc.FGACCESSSIGN when 1 then '|Assinatura' else '' end
        + case dcc.FGACCESSNOTIFY when 1 then '|Notificação' else '' end
        + case dcc.FGACCESSEDITKNOW when 1 then '|Avaliar aplicabilidade' else '' end
        + case dcc.FGACCESSADDCOMMENT when 1 then '|Incluir comentário' else '' end as __permissoes
from DCCATEGORYDOCROLE dcc
where dcc.CDACCESSROLE = doc.CDACCESSROLE) __sub
for XML path('')) as varchar(4000)) as permissoes
from DCCATEGORYDOCROLE doc
inner join dccategory cat on cat.CDCATEGORY = doc.CDCATEGORY and cat.fgenabled = 1
where 1 = 1
) sub
inner join adteammember equ on equ.cdteam = sub.codeq
inner join aduser usr1 on equ.cduser = usr1.cduser
inner join aduserdeptpos rel on rel.cduser = usr1.cduser and rel.fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment --and dep.CDDEPTOWNER = (select CDDEPARTMENT from addepartment where IDDEPARTMENT = '0010 - UA')
inner join adposition pos on pos.cdposition = rel.cdposition

where  (codeq <> 00 or codeq is null) and categoria in ('DCEP TDS','IN TDS','ME TDS','MG TDS','MP TDS','PA TDS','POP TDS','RA GERAIS TDS','SOL TDS','VL TDS','AM IN','INP IN','LGB IN','LVL IN','ME IN','MP IN','PA IN','POP IN','PPX IN','REG IN','AF','AF REG','CONS','DCEP BSB','EE','MAVL BSB','MG HUM','MP HUM','PA HUM','POP BSB','TERC','GQ PA','POP PA','DCEP EG','MAVL EG','MG VET','MP VET','PA VET','POP EG','EMP AP','IT AP','LGB AP','ME AP','POP AP','TAB AP','AF BT','ME BT','MGF BT','MP BT','PA BT','POPS BT','POP EX','FORMHL TDS','1 - VM IN','2 - VC IN','EXPEDIÇÃO EX','1 - POP EX','2 - AVAL EX','3 - FORM EX','1 - POP VET GA','2 - AVAL VET GA','3 - FORM VET GA','DCEP PA','INV PA','1 - POP HUM BSB','2 - AVAL HUM BSB','3 - FORM HUM BSB','1 - POP HUM EG','2 - AVAL HUM EG','3 - FORM HUM EG','1 - FEIN TDS','2 - MAIN TDS','3 - RAIN TDS','1 - EINP IN','2 - MINP IN','HUM MAVL EG','VET MAVL EG','EE BT','RCME BT','1 - AF IN','2 - FEME IN','3 - MAE IN','4 - DT IN','1 - AF TDS','2 - FEME TDS','3 - DT TDS','4 - MAEM TDS','5 - RAEM TDS','1','2','FR BT','MG BT','EM BT','EMI BT','MMP BT','RCMP BT','DMP HUM','EM DA','EM HUM','EMI HUM','MMP HUM','RCMP HUM','RET HUM','1 - EMP IN','2 - MAMP IN','1 - FEMP TDS','2 - MAMP TDS','3 - RAMP TDS','EM VET','EMI VET','MMP VET','EA BT','MA BT','RCMA BT','DMA HUM','EA HUM','EA HUM PA','MA HUM','MA HUM PA','RCMA HUM','1 - EPA IN','2 - MAPA IN','1 - FEPA TDS','2 - MAPA FQ TDS','3 - MAPA MIC','4 - RAPA LIB TDS','5 - RAPA EST TDS','EA VET','MA VET','1 - POP AP','2 - AVAL AP','3 - FORM AP','HUM BSB','VET BSB','GA EG','HUM EG','VET EG','1 - POP IN','2 - AVAL IN','3 - FORM IN','1 - POP HUM PA','2 - AVAL PA','3 - FORM PA','1 - POP TDS','2 - AVAL TDS','3 - FORM TDS','4 - LGB TDS','AVAL BT','FORM BT','POP BT','1 - RAMIC TDS','2 - RAMIC MA TDS','3 - RA GERAL TDS','ER HUM','MR HUM','AF TERC','EA TERC','EE TERC','EM TERC','MA TERC','MP TERC','1 - POP VET BSB','2 - AVAL VET BSB','3 - FORM VET BSB','1 - POP VET EG','2 - AVAL VET EG','3 - FORM VET EG','1 - MAVL TDS','2 - RAVL TDS','VSC','INV VSC')
order by categoria, tpacesso, quem, usr1.nmuser


--=====================> Título do DOcumento
select rev.*
from dcdocrevision rev
inner join GNTRANSLATION tr on tr.cdtranslation = rev.cdtranslation
inner join GNTRANSLATIONLANGUAGE ln on ln.cdtranslation = rev.cdtranslation
where rev.cddocument = zzzzzz

update dcdocrevision set nmtitle = '<novo_título>'
where cdrevision = xxxxxx
update GNTRANSLATIONLANGUAGE set NMTRANSLATION = '<novo_título>'
where CDTRANSLATION = yyyyy


--update GNTRANSLATIONLANGUAGE set NMTRANSLATION='<novo_título>'
--select * from GNTRANSLATIONLANGUAGE
where cdtranslation = 61948

--========================> Lista de usuários de TIME
select usr.idlogin,usr.nmuser
, case team.idteam when 'TI_SISTEMAS' then 'Sistemas' when 'TI_INFRA' then 'Infra' when 'TI_GOVERNANÇA' then 'Governança' end area
from aduser usr
inner join adteammember teamm on teamm.cduser = usr.cduser
inner join adteam team on team.cdteam = teamm.cdteam
where team.idteam = 'TI_SISTEMAS' or team.idteam = 'TI_INFRA' or team.idteam = 'TI_GOVERNANÇA'

--==================> Usuários e seus líderes
select usr.nmuser, ld.nmuser as nmleader
from aduser usr
left join aduser ld on ld.cduser = usr.cdleader
inner join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddeptowner = 326
where usr.fguserenabled = 1
--========================> Lista de e-mails dos usuários com notificação e responsáveis por recebimento de doc

select email from (
select cast(usr.dsuseremail as varchar(max)) as email
--, csr.cdcopystation as cdestacao,cs.nmcopystation as estacao, csr.cduser as cdresp, usr.nmuser as resp
from dccopystation cs
inner join DCCOPYSTATIONRESP csr on csr.cdcopystation = cs.cdcopystation
inner join aduser usr on usr.cduser = csr.CDuser
where csr.cdcopystation in (select CDCOPYSTATION from DCDOCCOPYSTATION where cdrevision = (
select max(cdrevision) from dcdocrevision where iddocument = 'pop-tds-a-001'))
union all
select stuff((
select cast(';' as nvarchar(max)) + cast(usr.DSUSEREMAIL as varchar(max)) as [text()]
from aduser usr
inner join DCDOCACCESSROLE dcr on dcr.CDUSER = usr.CDUSER
inner join DCDOCREVISION rev on dcr.CDDOCUMENT = rev.CDDOCUMENT
where rev.iddocument = 'TINP003'
and dcr.FGPERMISSION = 1 and dcr.FGACCESSKNOW = 1
FOR XML PATH('')), 1, 1, '') as email) __sub
where email is not null
--==============================> Desvincular um usuário do AD
update aduser set NMDOMAINUID=null where idlogin='xxxx';
update COACCOUNT set NMDOMAINUID=null, OIDCONNECTION=null where IDLOGIN='xxxx';

--============================================> Rollback
DECLARE @TransactionName varchar(20) = 'Transaction1';
BEGIN TRAN @TransactionName  
       INSERT INTO xxxxx ...;
ROLLBACK TRAN;

--===========================================> Lista de usuários em áreas e/ou funções inativas
SELECT AD.iduser AS matricula, AD.nmuser AS nomeDoUsuario, ADP.iddepartment AS idArea, ADP.nmdepartment AS nomeArea, ADPOS.idposition AS idFuncao, ADPOS.nmposition AS nmFuncao, 
CASE 
WHEN ADP.fgdeptenabled <> 1 AND ADPOS.fgposenabled = 1 THEN 'Área inativa'
WHEN ADP.fgdeptenabled = 1 AND ADPOS.fgposenabled <> 1 THEN 'Função inativa'
WHEN ADP.fgdeptenabled <> 1 AND ADPOS.fgposenabled <> 1 THEN 'Área e função inativa'
END AS status

FROM ADUSERDEPTPOS ADU
INNER JOIN ADUSER AD
ON (
AD.CDUSER = ADU.CDUSER
)
INNER JOIN addepartment ADP ON (ADP.cddepartment = ADU.cddepartment)
INNER JOIN adposition ADPOS ON (ADPOS.cdposition = ADU.cdposition)
WHERE AD.FGUSERENABLED = 1
AND (ADP.fgdeptenabled <> 1 OR ADPOS.fgposenabled <> 1)
--==================================================> Itens da semana

case when dateadd(dd, 32, [dtFimR]) > getdate() then 1
         when [dtFimR] is null and dateadd(dd, 11, [dtFimP]) > dateadd(dd,11,getdate()) then 1
         else 0
end

--============================================>Campo hora no forms
--Em SQL Server:
CONVERT(VARCHAR(19), DATEADD(second, DATEDIFF(second, GETUTCDATE(), GETDATE()), DATEADD(S, atrib001, '1970-01-01')), 108)
--Em Oracle:
TO_CHAR(TO_DATE('01/01/1970', 'DD/MM/YYYY') + atrib001 / 86400 + ((EXTRACT(TIMEZONE_HOUR FROM SYSTIMESTAMP))  60  60) / 86400, 'HH24:MI')
--============================================> Log do sistema
SELECT DISTINCT SCTS.DTDATE,SCTS.NRTIME,SCTS.NMOPERATION,SCTS.CDISOSYSTEM,SCTS.NMWINDOWTITLE, CAST (SCTS.DSKEYS AS VARCHAR(4000)) AS DSKEYS, SCTS.NMUSER, SCTS.IDIPADDRESS, SCTS.IDTRANSACTION
FROM SECHANGETRANS SCTS WHERE 1=1 AND SCTS.NMOPERATION IN ('INSERT','UPDATE','DELETE','VIEW') AND SCTS.CDISOSYSTEM IN (153,180,144,109,13,171,0,205,16,21,49,-1,160,174,202,15,41,17,215,146,26,39) AND UPPER(SCTS.NMUSER) LIKE UPPER('%abeck - Alvaro Adriano Beck%') AND SCTS.DSKEYS LIKE '%500056%' AND SCTS.DTDATE >= '2018-03-20' AND SCTS.DTDATE <= '2018-03-20'
--Detalhe
SELECT DISTINCT NMFIELD, NMDATATYPE, CAST(DSOLDVALUE AS VARCHAR(4000)) AS DSOLDVALUE, NMOLDVALUE, CAST(DSNEWVALUE AS VARCHAR(4000)) AS DSNEWVALUE, NMNEWVALUE, IDOWNER
FROM SECHANGEFIELD WHERE OIDSECHANGE IN (SELECT OID FROM SECHANGETRANS
WHERE IDTRANSACTION=SCTS.IDTRANSACTION) AND (IDOWNER != '-1' OR IDOWNER IS NULL)
ORDER BY NMFIELD
--Detalhes (antigos)
nas tabelas SEhistCHANGETRANS e SEhistCHANGEFIELD
-- Busca completa:
SELECT SCTS.DTDATE,SCTS.NRTIME,SCTS.NMOPERATION,SCTS.CDISOSYSTEM,SCTS.NMWINDOWTITLE, CAST (SCTS.DSKEYS AS VARCHAR(4000)) AS DSKEYS, SCTS.NMUSER, SCTS.IDIPADDRESS, SCTS.IDTRANSACTION
, ttt.NMFIELD, ttt.NMDATATYPE, CAST(ttt.DSOLDVALUE AS VARCHAR(4000)) AS DSOLDVALUE, ttt.NMOLDVALUE, CAST(ttt.DSNEWVALUE AS VARCHAR(4000)) AS DSNEWVALUE, ttt.NMNEWVALUE, ttt.IDOWNER
FROM SECHANGETRANS SCTS
inner join SECHANGEFIELD ttt on ttt.OIDSECHANGE = scts.oid and (ttt.IDOWNER != '-1' OR ttt.IDOWNER IS NULL)
WHERE 1=1 AND SCTS.NMOPERATION IN ('INSERT','UPDATE','DELETE','VIEW') AND SCTS.CDISOSYSTEM IN (153,180,144,109,13,171,0,205,16,21,49,-1,160,174,202,15,41,17,215,146,26,39) 
AND (SCTS.DSKEYS LIKE '%tds-cm-00236%' or SCTS.DSKEYS LIKE '%12613%')
union
SELECT SCTS.DTDATE,SCTS.NRTIME,SCTS.NMOPERATION,SCTS.CDISOSYSTEM,SCTS.NMWINDOWTITLE, CAST (SCTS.DSKEYS AS VARCHAR(4000)) AS DSKEYS, SCTS.NMUSER, SCTS.IDIPADDRESS, SCTS.IDTRANSACTION
, ttt.NMFIELD, ttt.NMDATATYPE, CAST(ttt.DSOLDVALUE AS VARCHAR(4000)) AS DSOLDVALUE, ttt.NMOLDVALUE, CAST(ttt.DSNEWVALUE AS VARCHAR(4000)) AS DSNEWVALUE, ttt.NMNEWVALUE, ttt.IDOWNER
FROM SEhistCHANGETRANS SCTS
inner join SEhistCHANGEFIELD ttt on ttt.OIDSECHANGE = scts.oid and (ttt.IDOWNER != '-1' OR ttt.IDOWNER IS NULL)
WHERE 1=1 AND SCTS.NMOPERATION IN ('INSERT','UPDATE','DELETE','VIEW') AND SCTS.CDISOSYSTEM IN (153,180,144,109,13,171,0,205,16,21,49,-1,160,174,202,15,41,17,215,146,26,39) 
AND (SCTS.DSKEYS LIKE '%tds-cm-00236%' or SCTS.DSKEYS LIKE '%12613%')
ORDER BY SCTS.DTDATE, ttt.NMFIELD
--============================================>
SELECT
    idlogin,nmuser
FROM
    aduser
WHERE
   nmuser COLLATE Latin1_General_CS_AS like '%A'
OR nmuser COLLATE Latin1_General_CS_AS like '%E'
OR nmuser COLLATE Latin1_General_CS_AS like '%I'
OR nmuser COLLATE Latin1_General_CS_AS like '%O'
OR nmuser COLLATE Latin1_General_CS_AS like '%U'
order by nmuser
--=========================> Lista dos checklists
select * from (select ckl.idchecklist,ckl.nmchecklist, ickl.nmitemchecklist,ickl.cditemchecklist,ickl.cditemowner,concat(Coalesce(ickl.cditemowner,ickl.cditemchecklist),ickl.cditemchecklist) as ordem
from adchecklist ckl
inner join ADITEMCHECKLIST ickl on ickl.cdchecklist = ckl.cdchecklist
where ckl.idchecklist like 'FORM%' and ckl.fgenabled=1) sub
order by idchecklist,ordem
--=========================> Status de Treinamento da TI
select usr.nmuser, cou.nmcourse, case treusr.fgpend when 2 then 'Executado' else 'Pendente' end Status
, format(treusr.dtpendres,'dd/MM/yyyy') as dtexecut
, datepart(yyyy,treusr.dtpendres) as dtexecut_ano, datepart(MM,treusr.dtpendres) as dtexecut_mes
, treusr.dtpendres as dtexecutado
, 1 as Quantidade
from trtrainuser treusr
inner join trtraining tre on tre.cdtrain = treusr.cdtrain
inner join trcourse cou on cou.cdcourse = tre.cdcourse and cou.cdcoursetype=46
inner join aduser usr on usr.cduser = treusr.cduser
--==============================================> Lista de Treinamentos sem objeto
select tr.IDTRAIN, tr.NMTRAIN, tr.NMUSERUPD, tr.FGSTATUS
from trtraining tr
left join DCDOCTRAIN tdoc on tr.cdtrain = tdoc.cdtrain
inner join trcourse cou on cou.cdcourse = tr.cdcourse
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
where tdoc.CDDOCUMENT is null and gnt.cdgentypeowner=137

--> Para TI:
select tr.IDTRAIN, tr.NMTRAIN, tr.NMUSERUPD, tr.FGSTATUS
from trtraining tr
left join DCDOCTRAIN tdoc on tr.cdtrain = tdoc.cdtrain
inner join trcourse cou on cou.cdcourse = tr.cdcourse
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
where tdoc.CDDOCUMENT is null and cou.cdcoursetype in (110,46)
and cou.cdcourse not in (
select cou.cdcourse
from trcourse cou
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
where cdcourse not in (select cdcourse from DCDOCCOURSE)
and cou.cdcoursetype in (110,46)
)
--==============================================> Lista de cursos sem objeto
select cou.*
from trcourse cou
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
where cdcourse not in (select cdcourse from DCDOCCOURSE)
and gnt.cdgentypeowner=137
--and idcourse like 'pop-tds%'

--==============================================> Usuário x papel funcional DHO
select usr.cduser,usr.idlogin,usr.nmuser
, pf.idrole,pf.nmrole
from aduser usr
inner join aduserrole pfusr on pfusr.cduser = usr.cduser
inner join adrole pf on pf.cdrole = pfusr.cdrole
where  usr.fguserenabled = 1 and (cdroleowner = 58 or cdroleowner in (select cdrole from adrole where cdroleowner = 58))
order by pf.idrole,usr.nmuser
--  58 = DHO | 16 = AN-EQ | IN-CM = 240
--==========================> Usuários x Equipes x Papeis funcionais x Grupos de acesso
select usr.cduser,usr.idlogin,usr.nmuser
, eqp.idteam,eqp.nmteam
, pf.idrole,pf.nmrole
, grp.idgroup,grp.nmgroup
from aduser usr
inner join adteammember eqpusr on eqpusr.cduser = usr.cduser
inner join adteam eqp on eqp.cdteam = eqpusr.cdteam
inner join aduserrole pfusr on pfusr.cduser = usr.cduser
inner join adrole pf on pf.cdrole = pfusr.cdrole
inner join aduseraccgroup grpusr on grpusr.cduser = usr.cduser
inner join adaccessgroup grp on grp.cdgroup = grpusr.cdgroup

--=========================> Controle de chamados (Renato)

select distinct *
from (
select wf.idprocess, wf.nmprocess
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
, case when (exists (select 1
                    FROM WFSTRUCT wfs, WFHISTORY HIS
                    WHERE wfs.idstruct = 'Atividade20111012624715' and wfs.idprocess = wf.idobject
                    and HIS.IDSTRUCT = wfs.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and his.nmaction = 'Submeter / Submit') and wf.fgstatus = 1) then 'Entregue'
       when wf.fgstatus = 2 then 'Suspenso'
       when wf.fgstatus = 3 then 'Cancelado'
       when wf.fgstatus = 4 then 'Finalizado'
       when (docs.iddocument is null and wf.fgstatus = 1) then 'Não iniciado'
       when (docs.iddocument like 'APL-DE-%' and wf.fgstatus = 1) then 'Em andamento'
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
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-DC-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-DC-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DC
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-DP-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-DP-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DP
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-DE-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-DE-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as DE
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-EF-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-EF-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as EF
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-ET-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-ET-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as ET
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-QO-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-QO-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as QO
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-QR-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-QR-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as QR
, (select top 1 dr.iddocument from dcdocrevision dr inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-RP-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) +
' / '+ (select top 1 case doc.fgstatus when 1 then 'Em fluxo' when 2 then 'Homologado' when 3 then 'Em fluxo' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc from dcdocrevision dr inner join dcdocument doc on doc.cddocument = dr.cddocument inner join dcdocumentattrib atr on atr.cdrevision = dr.cdrevision and atr.cdattribute = 235 and atr.cdrevision = dr.cdrevision where dr.iddocument like 'APL-RP-%' and atr.vlvalue = docs.vlvalue order by dr.cdrevision desc) as RP
, 1 as quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left join (
            select wfs.idprocess, rev.iddocument, att.VLVALUE, rev.cddocument, rev.cdrevision
            from wfstruct wfs
            inner join wfprocdocument wfdoc on wfdoc.idstruct = wfs.idobject
            inner join dcdocrevision rev on rev.cddocument = wfdoc.cddocument and (rev.cdrevision = wfdoc.cddocumentrevis or (wfdoc.cddocumentrevis is null and rev.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)))
            inner join dcdocumentattrib att on att.cdrevision = rev.cdrevision and att.cdattribute = 235 and att.cdrevision = rev.cdrevision
            where rev.iddocument like 'APL-__-%'
) docs on docs.idprocess = wf.idobject
--his.fgtype = 52 -- comentário editado
where wf.cdprocessmodel = 5679 and form.itsm035 like 'sesuite%' -- and wf.fgstatus <> 4
) sub
where status2 is not null and idprocess like '%330'
order by idprocess

--================> Encontrar chamado executado
select wfp.idprocess --, wfs.nmstruct, wfs.DTEXECUTION, wfa.NMUSER
from wfactivity wfa
inner join WFSTRUCT wfs on wfs.idobject = wfa.IDOBJECT
inner join WFPROCESS wfp on wfp.idobject = wfs.idprocess
where wfp.cdprocessmodel = 5251
and wfa.NMUSER like 'marcos ed%'
and wfs.DTEXECUTION is not null
and wfs.DTEXECUTION = '2021-11-11'
and wfs.NMSTRUCT like '%level 1%'
order by wfs.DTEXECUTION desc

--=======================> cadastro de processos SAP no atributo SAP0005
--=CONCATENAR("insert into adattribvalue (CDATTRIBUTE,CDVALUE,NMATTRIBUTE,FGDEFAULTVALUE,FGATTRIBVLENABLE) values (223,";A1;",'";B1;"',2,1);")
select (select coalesce(max(CDVALUE)+1,0) from adattribvalue where cdattribute = 223),subsql.* from (select idactivity +' - '+ nmactivity as processo 
from pmactivity 
where CDACTTYPE in (9,10,11,12,13,14,15,16,17,18,19) 
union 
select distinct 'SAP - Documentos VSC' from pmactivity 
where CDACTTYPE in (9,10,11,12,13,14,15,16,17,18,19) )  subsql
where processo not in (select NMATTRIBUTE from adattribvalue where cdattribute=223)

--========> POPs TDS e seus filhos
select rev.iddocument, rev.nmtitle --, gnrev.idrevision
, att.dsvalue as indexacaoanterior, gn.nmfile as nomearquivo
, revc.iddocument as idfilho,revc.nmtitle as nmfilho
--, coalesce((select substring((select ' | '+ revc.iddocument +' - '+ revc.nmtitle as [text()] from GNREVISIONASSOC assoc inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision where assoc.cdrevision = rev.cdrevision FOR XML PATH('')), 4, 4000)), 'NA') as compostode --listadocfilho--
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
inner join GNREVISIONASSOC assoc on assoc.cdrevision = rev.cdrevision
inner join dcdocrevision revc on assoc.cdrevisionassoc = revc.cdrevision
inner join dcdocumentattrib att on att.cdrevision = rev.cdrevision and cdattribute = 132
inner join dcfile arq on arq.cdrevision = rev.cdrevision
inner join gnfile gn on gn.cdcomplexfilecont = arq.cdcomplexfilecont
where doc.fgstatus < 4 and rev.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
and cat.cdcategory in (105) and rev.fgcurrent = 1
order by cat.idcategory, rev.iddocument

------

select iddocument from dcdocrevision where cdrevision = (
select cdrevision from dcfile where cdcomplexfilecont = 720203)

--=============================> Lista de contratos com os principais campos
Select docproc.idprocess
, case dc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc
, gr.dtrevision as dtrevisao, gr.dtvalidity as dtvalidade
, ct.idcategory, dr.iddocument, dr.nmtitle, gr.idrevision
, form.con012 as depsol
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
                      case when form.con063 = 1 then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
                      case when form.con127 = 1 then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
                      case when form.con064 = 1 then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
                      case when form.con126 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
                      case when form.con065 = 1 then ' | 0059 - Centro Logístico Pouso Alegre/MG' else '' end +
                      case when form.con066 = 1 then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
                      case when form.con068 = 1 then ' | 0090 - Laboratil' else '' end +
                      case when form.con124 = 1 then ' | RobFerma' else '' end +
                      case when form.con135 = 1 then ' | Claris' else '' end +
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
                      case when form.con063 = 1 then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
                      case when form.con127 = 1 then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
                      case when form.con064 = 1 then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
                      case when form.con126 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
                      case when form.con065 = 1 then ' | 0059 - Centro Logístico Pouso Alegre/MG' else '' end +
                      case when form.con066 = 1 then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
                      case when form.con068 = 1 then ' | 0090 - Laboratil' else '' end +
                      case when form.con124 = 1 then ' | RobFerma' else '' end +
                      case when form.con135 = 1 then ' | Claris' else '' end +
                      case when form.con137 = 1 then ' | 0500 - UQFN Goiânia/GO' else '' end +
                      case when form.con129 = 1 then ' | Union Agener Inc.' else '' end +
                      case when form.con131 = 1 then ' | Union Agener Holding' else '' end +
                      case when form.con070 = 1 then ' | UQFN Bandeirantes' else '' end, 4, 500)
       end as unidade
, form.con022 as RazaoSocialContraria, form.con045 as tipoAtividade
, form.con019 as Objeto
, form.con013 as diretorapr
, cast(coalesce((select substring((select ' | '+ rev.iddocument as [text()] from dcdocumentattrib atrel
                 inner join dcdocrevision rev on rev.cdrevision = atrel.cdrevision
                 where atrel.cdrevision = rev.cdrevision and ((atrel.cdattribute = 230 or atrel.cdattribute = 231) and nmvalue = docproc.idprocess) FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as contrato
, 'Em Desenvolvimento' as contratoVigente
, 'Em Desenvolvimento' as vigencia
, 'Em Desenvolvimento' as status
, 'Em Desenvolvimento' as regularizacaoAndamento
, 'Em Desenvolvimento' as prazoTermino
, 'Em Desenvolvimento' as Contratante
, 'Em Desenvolvimento' as Contratada

, 1 as quantidade
FROM dcdocrevision dr
INNER JOIN dcdocument dc ON dc.cddocument = dr.cddocument
INNER JOIN dccategory ct ON dr.cdcategory = ct.cdcategory
INNER JOIN gnrevision gr ON gr.cdrevision = dr.cdrevision
inner join (
select wdoc.cdrevision, wf.cdassocreg, wfdoc.cddocument, wf.idprocess
from wfprocdocument wfdoc
INNER JOIN wfstruct wfs ON wfdoc.idstruct = wfs.idobject
INNER JOIN wfprocess wf ON wfs.idprocess = wf.idobject
inner join dcdocrevision wdoc on wdoc.cddocument = wfdoc.cddocument and (wdoc.cdrevision = wfdoc.cddocumentrevis OR (wfdoc.cddocumentrevis IS NULL AND wdoc.fgcurrent = 1))
where wf.cdprocessmodel = 2808 or wf.cdprocessmodel = 2909
union ALL
select drev.cdrevision, wfp.cdassocreg, drev.cddocument, wfp.idprocess
from dcdocrevision drev
inner join dcdocumentattrib att on att.cdrevision = drev.cdrevision and (att.cdattribute = 230 or att.cdattribute = 231)
inner join wfprocess wfp on wfp.idprocess = att.nmvalue
where wfp.cdprocessmodel = 2808 or wfp.cdprocessmodel = 2909
) docproc on docproc.cdrevision = gr.cdrevision and dr.cddocument = docproc.cddocument
/*
INNER JOIN wfprocdocument wfdoc ON dr.cddocument = wfdoc.cddocument AND (dr.cdrevision = wfdoc.cddocumentrevis 
           OR (wfdoc.cddocumentrevis IS NULL AND dr.fgcurrent = 1))
INNER JOIN wfstruct wfs ON wfdoc.idstruct = wfs.idobject
INNER JOIN wfprocess wf ON wfs.idprocess = wf.idobject
*/
left join gnassocformreg gnf on (docproc.cdassocreg = gnf.cdassoc)
left join DYNcon001 form on (gnf.oidentityreg = form.oid)
where ct.cdcategory = 174 or ct.cdcategory = 175

--===============> Contratos principais campos (limpo)

Select docproc.idprocess
, case dc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc
, CASE docproc.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, gr.dtrevision as dtrevisao, gr.dtvalidity as dtvalidade
, ct.idcategory, dr.iddocument, dr.nmtitle, gr.idrevision
, form.con012 as depsol
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
                      case when form.con063 = 1 then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
                      case when form.con127 = 1 then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
                      case when form.con064 = 1 then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
                      case when form.con126 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
                      case when form.con065 = 1 then ' | 0059 - Centro Logístico Pouso Alegre/MG' else '' end +
                      case when form.con066 = 1 then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
                      case when form.con068 = 1 then ' | 0090 - Laboratil' else '' end +
                      case when form.con124 = 1 then ' | RobFerma' else '' end +
                      case when form.con135 = 1 then ' | Claris' else '' end +
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
                      case when form.con063 = 1 then ' | 0056 - UQFN Gráfica ArtPack/SP' else '' end +
                      case when form.con127 = 1 then ' | 0040 - UQ Ind. Gráfica e de Emb. Ltda/MG' else '' end +
                      case when form.con064 = 1 then ' | 0058 - UQFN Industrial Bthek/BF' else '' end +
                      case when form.con126 = 1 then ' | 0059 - UQFN Centro de Distribuição/MG' else '' end +
                      case when form.con065 = 1 then ' | 0059 - Centro Logístico Pouso Alegre/MG' else '' end +
                      case when form.con066 = 1 then ' | 0060 - F&F Distribuidora de Produtos Farmacêuticos' else '' end +
                      case when form.con068 = 1 then ' | 0090 - Laboratil' else '' end +
                      case when form.con124 = 1 then ' | RobFerma' else '' end +
                      case when form.con135 = 1 then ' | Claris' else '' end +
                      case when form.con137 = 1 then ' | 0500 - UQFN Goiânia/GO' else '' end +
                      case when form.con129 = 1 then ' | Union Agener Inc.' else '' end +
                      case when form.con131 = 1 then ' | Union Agener Holding' else '' end +
                      case when form.con070 = 1 then ' | UQFN Bandeirantes' else '' end, 4, 500)
       end as unidade
, form.con022 as RazaoSocialContraria, form.con045 as tipoAtividade
, form.con019 as Objeto
, form.con013 as diretorapr
, cast(coalesce((select substring((select ' | '+ rev.iddocument as [text()] from dcdocumentattrib atrel
                 inner join dcdocrevision rev on rev.cdrevision = atrel.cdrevision
                 where atrel.cdrevision = rev.cdrevision and ((atrel.cdattribute = 230 or atrel.cdattribute = 231) and nmvalue = docproc.idprocess) FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as contrato
, (SELECT top 1 str.nmstruct FROM WFSTRUCT STR
   WHERE str.fgstatus = 2 and str.idprocess=docproc.idobject) as atvatual
, (SELECT top 1 str.DTENABLED + str.TMENABLED FROM WFSTRUCT STR
   WHERE str.fgstatus = 2 and str.idprocess=docproc.idobject) as atvatualdt
, (SELECT top 1 case wfa.FGEXECUTORTYPE
               when 1 then wfa.nmrole
               when 3 then wfa.nmuser
               when 4 then wfa.nmuser
               else case when wfa.nmuser is not null then wfa.nmuser else 'indefinido' end
          end
   FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.fgstatus = 2 and str.idprocess=docproc.idobject and str.idobject = wfa.idobject) as atvatual_executor
, 1 as quantidade
FROM dcdocrevision dr
INNER JOIN dcdocument dc ON dc.cddocument = dr.cddocument
INNER JOIN dccategory ct ON dr.cdcategory = ct.cdcategory
INNER JOIN gnrevision gr ON gr.cdrevision = dr.cdrevision
right join (
	select wdoc.cdrevision, wf.cdassocreg, wfdoc.cddocument, wf.idprocess, wf.idobject, wf.fgstatus
	from wfprocdocument wfdoc
	INNER JOIN wfstruct wfs ON wfdoc.idstruct = wfs.idobject
	INNER JOIN wfprocess wf ON wfs.idprocess = wf.idobject
	inner join dcdocrevision wdoc on wdoc.cddocument = wfdoc.cddocument and (wdoc.cdrevision = wfdoc.cddocumentrevis OR (wfdoc.cddocumentrevis IS NULL AND wdoc.fgcurrent = 1))
	where wf.cdprocessmodel = 2808 or wf.cdprocessmodel = 2909
	union ALL
	select drev.cdrevision, wfp.cdassocreg, drev.cddocument, wfp.idprocess, wfp.idobject, wfp.fgstatus
	from dcdocrevision drev
	inner join dcdocumentattrib att on att.cdrevision = drev.cdrevision and (att.cdattribute = 230 or att.cdattribute = 231)
	inner join wfprocess wfp on wfp.idprocess = att.nmvalue
	where wfp.cdprocessmodel = 2808 or wfp.cdprocessmodel = 2909
) docproc on docproc.cdrevision = gr.cdrevision and dr.cddocument = docproc.cddocument
left join gnassocformreg gnf on (docproc.cdassocreg = gnf.cdassoc)
left join DYNcon001 form on (gnf.oidentityreg = form.oid)
where ct.cdcategory = 174 or ct.cdcategory = 175


--==========================> Associação de documentos no projeto
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
, rev.iddocument, gnrev.idrevision
, 1 as qtd
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join PRTASKDOCUMENT prdoc on prdoc.cdtask = p.cdtask
left join dcdocrevision rev on rev.cddocument = prdoc.cddocument and rev.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
left join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
where p.cdtasktype = 4 and P.FGTASKTYPE = 1 and P.NRTASKINDEX = 0
--=====================================> Lista de documentos em fluxo nos quais um usuário está
select rev.iddocument, stag.*, gnrev.dtrevrelease, gnrev.dtrevision
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
inner join aduser usr on usr.cduser = stag.cduser
where usr.nmuser = 'Marcos Kioshi' and (rev.fgcurrent = 2 or (rev.fgcurrent = 1 and doc.fgstatus = 1)) and stag.dtapproval is null and gnrev.dtrevrelease is null

--====================================> Arquivo eletrônico
select cdfile, nmfile, dtinsert, dtupdate, nmuserupd from gnfile where cdcomplexfilecont in (
select cdcomplexfilecont from dcfile where cdrevision in (
select cdrevision from dcdocrevision where iddocument='LGB-TDS-C-0148'))


select case cfg.FGSAVETOREV when 1 then 'Banco de dados' when 2 then 'Diretório controlado' else 'Banco de dados' end onde, sum(gnf.nrsize) as tamanho, count(1) as quant
from gnfile gnf
inner join dcfile dcf on dcf.cdcomplexfilecont = gnf.cdcomplexfilecont
inner join dcdocrevision rev on rev.cdrevision = dcf.cdrevision
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join GNELETRONICFILECFG cfg on cfg.CDELETRONICFILECFG = cat.CDELETRONICFILECFG
where gnf.nrsize is not null
group by cfg.FGSAVETOREV


update gnfile set dtinsert='2014/05/16', dtupdate='2017/02/22', nmuserupd='Gustavo Xavier de Sousa Alves' where cdfile = 70743.

UPDATE DCDOCREVISION SET CDCOMPLEXFILECONT =607253 WHERE CDREVISION = 3714077

select cdrevision,iddocument from dcdocrevision where cdrevision in (
select cdrevision from dcfile where cdcomplexfilecont in (
select cdcomplexfilecont from gnfile where cdfile = xxxx))

select dc.cddocument,cat.idcategory, dr.iddocument, dr.cdrevision, gnrev.idrevision, dc.FGSTATUS, gn.nmfile as file_name, dr.nmtitle, gn.cdfile
from dcdocument dc
inner join dcdocrevision dr on dc.cddocument = dr.cddocument --and dr.FGCURRENT=1
inner join dccategory cat on cat.cdcategory = dr.cdcategory
inner join dcfile arq on arq.cdrevision = dr.cdrevision
inner join gnfile gn on gn.cdcomplexfilecont = arq.cdcomplexfilecont
inner join GNREVISION gnrev on gnrev.cdrevision = dr.cdrevision
where dr.iddocument in ('tipo020')
order by cat.idcategory, dr.cdrevision

select cat.idcategory, round(sum(gn.nrsize) / 1048576, 2)
--, dr.iddocument, gnrev.idrevision, gn.nmfile, gn.nrsize
from dcdocument dc
inner join dcdocrevision dr on dc.cddocument = dr.cddocument
inner join dccategory cat on cat.cdcategory = dr.cdcategory
inner join dcfile arq on arq.cdrevision = dr.cdrevision
inner join gnfile gn on gn.cdcomplexfilecont = arq.cdcomplexfilecont
inner join GNREVISION gnrev on gnrev.cdrevision = dr.cdrevision
where gn.flfile is not null
group by cat.idcategory
with rollup
order by cat.idcategory


select round(sum(gn.nrsize) / 1048576, 2)
from ADATTACHMENT ata
inner join ADATTACHFILE ataf on ataf.CDATTACHMENT = ata.CDATTACHMENT
inner join gnfile gn on gn.cdcomplexfilecont = ataf.cdcomplexfilecont
where ata.FGATTACHMENTTYPE = 1


--- Treinamento -> 80%
select * from (select  rev.iddocument, gnrev.idrevision, count(tr.IDTRAIN) as qtd
from trtraining tr
inner join DCDOCTRAIN tdoc on tr.cdtrain = tdoc.cdtrain
inner join gnrevision gnrev on gnrev.cdrevision = tdoc.cdrevision
inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision
inner join trtrainuser trusr on trusr.cdtrain = tr.cdtrain
inner join aduser usr on usr.cduser = trusr.cduser
inner join trcourse cou on cou.cdcourse = tr.cdcourse
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
where tdoc.CDDOCUMENT is not null and gnt.cdgentypeowner=137
group by rev.iddocument, gnrev.idrevision
with rollup) _sub where idrevision is not null


select mcour.cdmapping, mcour.cdcourse, count(mcour.cduser) as usuarios
from adposition pos
inner join addeptposition deppos on deppos.cdposition = pos.cdposition and deppos.cddepartment = 164
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
inner join TRCOURSE trc on trc.cdcourse = relc.cdcourse
inner join TRUSERCOURSE mcour on mcour.cdmapping = relc.cdmapping and mcour.cdcourse = trc.cdcourse
group by mcour.cdcourse, mcour.cdmapping



select *
, (select count(mcour.cduser) as usuarios
from adposition pos
inner join addeptposition deppos on deppos.cdposition = pos.cdposition and deppos.cddepartment = 164
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
inner join TRCOURSE trc on trc.cdcourse = relc.cdcourse
inner join TRUSERCOURSE mcour on mcour.cdmapping = relc.cdmapping and mcour.cdcourse = trc.cdcourse
where mcour.cdcourse = _sub.cdcourse) as cemporcento
, (qtd * 100) / case when (select count(mcour.cduser) as usuarios
from adposition pos
inner join addeptposition deppos on deppos.cdposition = pos.cdposition and deppos.cddepartment = 164
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
inner join TRCOURSE trc on trc.cdcourse = relc.cdcourse
inner join TRUSERCOURSE mcour on mcour.cdmapping = relc.cdmapping and mcour.cdcourse = trc.cdcourse
where mcour.cdcourse = _sub.cdcourse) = 0 then 100 else (select count(mcour.cduser) as usuarios
from adposition pos
inner join addeptposition deppos on deppos.cdposition = pos.cdposition and deppos.cddepartment = 164
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
inner join TRCOURSE trc on trc.cdcourse = relc.cdcourse
inner join TRUSERCOURSE mcour on mcour.cdmapping = relc.cdmapping and mcour.cdcourse = trc.cdcourse
where mcour.cdcourse = _sub.cdcourse) end as oitenta
from (select  rev.iddocument, cou.cdcourse, gnrev.idrevision, count(tr.IDTRAIN) as qtd
from trtraining tr
inner join DCDOCTRAIN tdoc on tr.cdtrain = tdoc.cdtrain
inner join gnrevision gnrev on gnrev.cdrevision = tdoc.cdrevision
inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision
inner join trtrainuser trusr on trusr.cdtrain = tr.cdtrain
inner join aduser usr on usr.cduser = trusr.cduser
inner join trcourse cou on cou.cdcourse = tr.cdcourse
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
where tdoc.CDDOCUMENT is not null and gnt.cdgentypeowner=137
group by rev.iddocument, gnrev.idrevision, cou.cdcourse
with rollup) _sub where idrevision is not null and cdcourse is not null

--===========================> Ajuste de máscara de identificação
inSERT INTO GNMASKseq (CDMASK, IDMASKBEGIN,NRSEQ,IDMASKEND) VALUES (352,'GMUDTI-2021',611,' ');
upDATE PMACTREVISION SET FGINSTANCEIDFORMAT=3 WHERE CDACTIVITY=5679 AND CDREVISION=263399;
upDATE PMPROCESS SET FGINSTANCEIDFORMAT=3,CDMASK=352 WHERE CDPROC=5679;

--=========================> Tabelas e seus tamanhos
SELECT
    t.NAME AS Entidade,
    p.rows AS Registros,
    SUM(a.total_pages) * 8 AS EspacoTotalKB,
    SUM(a.used_pages) * 8 AS EspacoUsadoKB,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS EspacoNaoUsadoKB
FROM
    sys.tables t
INNER JOIN
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN
    sys.schemas s ON t.schema_id = s.schema_id
WHERE
    t.NAME NOT LIKE 'dt%'
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
GROUP BY
    t.Name, s.Name, p.Rows
ORDER BY
    Registros DESC
--====================================> Documentos que o usuário executou
select rev.iddocument as ID, gnrev.idrevision as Rev, case stag.FGSTAGE when 1 then 'Elaborator' when 2 then 'Reviewer' when 3 then 'Approver' when 4 then 'Finisher' end Phase
, max(stag.DTAPPROVAL) as exeDate
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
inner join aduser usr on usr.cduser = stag.cduser
where usr.idlogin = 'plevy'
group by rev.IDDOCUMENT, gnrev.idrevision, stag.fgstage
--====================================> Participantes da revisão (Vivian)
select  rev.iddocument,gnrev.idrevision,usr.nmuser, case stag.FGSTAGE when 1 then 'Elaborador' when 2 then 'Consensador' when 3 then 'Aprovador' when 4 then 'Homologador' end Fase
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
left join aduser usr on usr.cduser = stag.cduser
left join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS=1
left join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies = 7
where rev.FGCURRENT = 1 and rev.cdcategory in (105,106,107,108)
order by rev.iddocument,gnrev.idrevision, stag.FGSTAGE, stag.nrsequence

--===========================> Shirley - chamados da central
select wf.idprocess, wf.cduserstart
, (select wfs.nmstruct from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273') and wfs.DTEXECUTION+wfs.TMEXECUTION = (
        select max(wfs.DTEXECUTION+wfs.TMEXECUTION) from WFSTRUCT wfs where wfs.idprocess = wf.idobject and wfs.fgstatus = 3 and wfs.idstruct in ('Atividade20131101317429','Atividade20131102332506','Atividade20131102646273'))
) as atendN
, CASE wf.fgstatus
    WHEN 1 THEN 'Em andamento'
    WHEN 2 THEN 'Suspenso'
    WHEN 3 THEN 'Cancelado'
    WHEN 4 THEN 'Encerrado'
    WHEN 5 THEN 'Bloqueado para edição'
END AS status
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join aduserdeptpos rel on rel.cduser = wf.cduserstart and fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and (dep.nmdepartment like '%tecnologia da informa%' or dep.nmdepartment like '%information techno%')
inner join (select cduser, idrole, nmrole from aduserrole cdru  inner join adrole cdr on cdr.cdrole = cdru.cdrole and cdr.cdroleowner = 1404) grsol on grsol.cduser = rel.cduser and grsol.nmrole like '%N1%'
where wf.cdprocessmodel = 5251

--====================> Usuários nas roles (Afonso)
select adr.nmrole, usr.nmuser
from aduserrole usrr
inner join aduser usr on usr.cduser = usrr.cduser
inner join adrole adr on adr.cdrole = usrr.cdrole and cdroleowner = 1404
--========================================> LIsta de documentos relacionados a um atributo
select rev.iddocument, gnrev.idrevision, val.nmattribute
from DCDOCMULTIATTRIB atrib
inner join dcdocrevision rev on rev.cdrevision = atrib.cdrevision
inner join adattribvalue val on val.cdattribute = atrib.cdattribute and atrib.cdvalue = val.cdvalue
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
where atrib.cdattribute = 223 and (rev.iddocument like 'APL-DC-%' or rev.iddocument like 'SAP-DC-%')
and rev.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
order by rev.iddocument

--======================================> Processos cancelados em uma data
select * from (
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado'
WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, his.nmaction
, case his.nmaction when 'Cancelar' then his.dthistory+his.tmhistory else his.dthistory+tmhistory end dtcancela
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and (HIS.FGTYPE = 9 or HIS.FGTYPE = 3 or HIS.FGTYPE = 31) and his.dthistory+his.tmhistory =
(select max(his2.dthistory+his2.tmhistory) from wfhistory his2 where his2.idprocess = wf.idobject and (his2.FGTYPE = 9 or his2.FGTYPE = 3 or HIS2.FGTYPE = 31))
where cdprocessmodel=1
) _sub
where (status = 'Cancelado' or statusproc = 'Cancelado') and datepart(year,dtcancela) = 2019 and datepart(month,dtcancela) = 10
--====================================> Usuários que participam do fluxo de revisão como Elaboradores ou Consensadores (Sabrina)
select distinct usr.nmuser
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL and stag.FGSTAGE in (1,2)
inner join aduser usr on usr.cduser = stag.cduser
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS=1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies = 7

--====================> Arquivo eletrônico
select gnf.cdfile, rev.iddocument as id, gnr.idrevision as rev
from dcdocrevision rev
inner join dcfile dcf on dcf.CDDOCUMENT = rev.CDDOCUMENT
inner join gnfile gnf on gnf.CDCOMPLEXFILECONT = dcf.CDCOMPLEXFILECONT
inner join gnrevision gnr on gnr.cdrevision = rev.cdrevision
where gnf.cdfile in (277970, 298890, 475248, 522503, 551270, 612607, 718578, 787601)

--======================> Problemas com arquivo eletrônico
SELECT * FROM DCDOCREVISION WHERE CDCOMPLEXFILECONT IS NULL



--====================================> Kanban - Atividades
select idt.idtask, tst.nmtitle
from TSWORKSPACECHANGESHISTORY idt
inner join tstask tst on tst.cdtask = idt.cdtask

--
select tst.nmtitle, seq.vlfloat as seq, dep.cdvalue as dep, mod.cdvalue as mod
from TStask tst
inner join wfprocess wf on wf.idobject = tst.idobject
inner join wfprocattrib seq on seq.idprocess = wf.idobject and seq.cdattribute = 755
inner join wfprocattrib dep on dep.idprocess = wf.idobject and dep.cdattribute = 761
inner join wfprocattrib mod on mod.idprocess = wf.idobject and mod.cdattribute = 760


---
select wf.idprocess, wf.nmprocess, form.itsm034, wf.idprocess +' - '+ wf.nmprocess as titulo
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
where wf.cdprocessmodel = 5679
and wf.fgstatus = 1 and form.itsm066 = 'sesuite'
and not exists (select 1 
    from TSWORKSPACECHANGESHISTORY idt
    inner join tstask tst on tst.cdtask = idt.cdtask
    where substring(tst.nmtitle, 1, 19) like '%'+ substring(wf.idprocess,8,9) +'%')

---

select idt.idtask
, tst.nmtitle, tst.dtstart, tst.dtfinish
, ws.nmprefix, ws.nmworkspace
, his.dthistory, his.tmhistory, his.fgtype, his.dscomment
, usr.idlogin, usr.nmuser
from tstask tst
inner join TSWORKSPACECHANGESHISTORY idt on tst.cdtask = idt.cdtask
inner join TSWORKSPACE ws on ws.cdworkspace = idt.cdworkspace
left join TSSPRINT sprint on sprint.cdsprint = tst.cdsprint
inner join TSSTEP step on step.cdstep = tst.cdstep
inner join WFPROCESS wf on wf.idobject = idt.idobject
inner join wfhistory his on his.idobject = tdt.idobject
left join aduser usr on usr.cduser = his.cduser

--====================================> Usuários da unidade Anovis
select distinct usr.idlogin, usr.nmuser
, case usr.fguserenabled when 1 then 'habilitado' when 2 then 'desabilitado' end as status
, dep.iddepartment, pos.nmposition
from aduser usr
inner join aduserdeptpos rel on rel.cduser=usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and cddeptowner = 316
inner join adposition pos on pos.cdposition = rel.cdposition
where usr.fguserenabled = 1
order by status,nmuser
-- cdcompanies: 7 = ANOVIS / 5 = PA / 4 = EG / 14 = Inovat / 2 = BSB / 17 = Union Agener
--==========================================> Lista de usuários e suas funções secundárias
select _sub.cduser, usr.nmuser from (
select usr2.*
from (
select usr.cduser
from aduser usr
inner join aduserdeptpos rel on rel.cduser=usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies in (5,4,2)
inner join adposition pos on pos.cdposition = rel.cdposition
where usr.fguserenabled = 1
) usr2
left join (
select distinct usr.cduser
from aduser usr
inner join aduserdeptpos rel on rel.cduser=usr.cduser and rel.FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
where usr.fguserenabled = 1 and dep.iddepartment = 'tre' and exists (select usr1.cduser from aduser usr1
inner join aduserdeptpos rel1 on rel1.cduser=usr1.cduser and rel1.FGDEFAULTDEPTPOS = 1
inner join addepartment dep1 on dep1.cddepartment = rel1.cddepartment and dep1.cdcompanies in (5,4,2)
where usr1.cduser = usr.cduser)) ttt on ttt.cduser = usr2.cduser
where ttt.cduser is null
) _sub
inner join aduser usr on usr.cduser = _sub.cduser
-----------------------------------------------------
select distinct usr.cduser, usr.idlogin, usr.nmuser, pos.idposition, pos.nmposition
from aduser usr
inner join aduserdeptpos rel on rel.cduser=usr.cduser and rel.FGDEFAULTDEPTPOS = 2
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
where usr.fguserenabled = 1 and dep.iddepartment = 'tre' and exists (select usr1.cduser from aduser usr1
inner join aduserdeptpos rel1 on rel1.cduser=usr1.cduser and rel1.FGDEFAULTDEPTPOS = 1
inner join addepartment dep1 on dep1.cddepartment = rel1.cddepartment and dep1.cdcompanies in (5,4,2)
where usr1.cduser = usr.cduser)
--=====================================> Lista de áreas e funções
select dep.nmdepartment, pos.nmposition
from  addepartment dep
inner join addeptposition rel on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
where dep.cddepartment = rel.cddepartment and dep.cdcompanies = 2
order by dep.cddepartment,pos.cdposition
--====================> Indicadores sql feito pela sof
select * from stscmetric where cdscmetric in (
select cdscmetric from stscorecardtree where cdscorecardtreeowner in (
select cdscorecardtree from stscorecardtree where cdscstructitem=204 and cdscorecard=3  and cdrevision=3776970)
and cdscorecard=3  and cdrevision=3776970)
and cdscorecard=3  and cdrevision=3776970
--=====================================> Usuários que não tem ROLE
select * from (
select distinct usr.cduser, usr.idlogin, usr.nmuser, dep.iddepartment, pos.nmposition
from aduser usr
inner join aduserdeptpos rel on rel.cduser=usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies = 14
inner join adposition pos on pos.cdposition = rel.cdposition
where usr.fguserenabled = 1) _sub
where cduser not in (select cduser from aduserdeptpos where cduser = _sub.cduser and CDDEPARTMENT = 164)

--====================================> Jurídico - tempo de execução da atividade de avaliação
SELECT wf.idprocess, gnrev.NMREVISIONSTATUS AS STATUS, wf.nmprocess
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS statusproc
, format(wf.dtstart,'dd/MM/yyyy') AS dtabertura
, format(wf.dtfinish,'dd/MM/yyyy') AS dtfechamento
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
inner join INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join WFHISTORY HIS ON his.idprocess = wf.idobject and HIS.FGTYPE = 9
inner join wfstruct stru on stru.idobject = his.idstruct
WHERE (wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909)
and stru.idstruct = 'Decisão1696121412176'

--====================================> Usuários duplicados
select usr.idlogin,usr.iduser,usr.nmuser, usr.FGUSERENABLED
from aduser usr
where (select count(usr1.idlogin) from aduser usr1 where usr1.idlogin = usr.idlogin and idlogin not like '%desativado') > 1 --order by idlogin
--where (select count(usr1.idlogin) from aduser usr1 where usr1.nmuser = usr.nmuser and idlogin not like '%desativado') > 1 --order by nmuser
order by idlogin

--===================================> datas das fases da revisão (Guilhermo)
select rev.iddocument, rev.nmtitle
, format(stag.dtapproval,'dd/MM/yyyy') as dtexecut --, datepart(yyyy,stag.dtapproval) as dtexecut_ano, datepart(MM,stag.dtapproval) as dtexecut_mes
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, 1 as quantidade
, gnrev.idrevision
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Em revisão' when 4 then 'Cancelado' when 5 then 'Em indexação' when 7 then 'Contrato encerrado' end statusdoc
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' when rev.fgcurrent = 2 then 'Obsoleto' end statusrev
, stag.NRCYCLE as ciclo, stag.NRSEQUENCE, stag.CDMEMBERINDEX
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
where rev.cdcategory in (161)
order by rev.iddocument, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE, stag.CDMEMBERINDEX

--====================================> Lita de documentos e seus aprovadores (Nalepa)
select rev.iddocument, rev.nmtitle
, stag.dtapproval
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Approver
, case stag.FGSTAGE when 1 then 'Draft' when 2 then 'Review' when 3 then 'Approval' when 4 then 'Release' when 5 then 'Releasing' when 6 then ' Finishing' end phase
, gnrev.idrevision, gnrev.dtrevision
, stag.NRCYCLE, stag.NRSEQUENCE, stag.CDMEMBERINDEX
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
where rev.cdcategory in (274,311) and gnrev.dtrevision <= '2021-11-23' and gnrev.dtrevision >= '2021-04-19'
order by rev.iddocument, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE, stag.CDMEMBERINDEX

--==========================> Útimos documentos aprovados

select rev.iddocument,gnrev.idrevision,usr.nmuser, case stag.FGSTAGE when 1 then 'Elaborador' when 2 then 'Consensador' when 3 then 'Aprovador' when 4 then 'Homologador' end Fase
, DTAPPROVAL
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
--left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
left join aduser usr on usr.cduser = stag.cduser
left join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS=1
left join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies = 7
where rev.cdcategory in (161,170) and DTAPPROVAL is not null
and usr.nmuser like 'Roberta Aparecida%' and stag.FGSTAGE = 3
and DTAPPROVAL > '02-13-2020'
order by rev.iddocument,gnrev.idrevision, stag.FGSTAGE, stag.nrsequence

--==========================> Data de cancelamento dos processos
Select wf.idprocess, max(dthistory) as datacancelamento
from wfprocess wf
inner join wfhistory his on his.idprocess = wf.idobject and his.fgtype = 3
where wf.cdprocessmodel = 1 and wf.fgstatus = 3
group by wf.idprocess
order by wf.idprocess

--===================================> Lista de Solciitações de extenção de prazo ou cancelamento de ações
Select wf.idprocess, wf.NMUSERSTART as iniciador, wf.dtstart as dtabertura
, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade1572217288432' and str.idprocess=wf.idobject) as dtexecucao
from DYNtds038 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.cdprocessmodel=72 and wf.fgstatus = 4 and gnrev.IDREVISIONSTATUS <> '016' and gnrev.IDREVISIONSTATUS <> '029'
and form.tds003 = 2 and form.tds005 in (2,3)
and (1 in (select TDS009 from DYNtds041 where OIDABCFHvABCauy = form.oid)
     or null not in (select TDS008 from DYNtds041 where OIDABCFHvABCauy = form.oid))

--=================================THAINARA========> Ações de planos com extenção de prazo
Select wf.idprocess, wf.dtstart as dtabertura
, acao.tds013 as plano, acao.tds014 as acao
from DYNtds038 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
inner join DYNtds041 acao on acao.OIDABCFHVABCAUY = form.oid
where wf.cdprocessmodel=72 and wf.fgstatus = 4 and gnrev.IDREVISIONSTATUS <> '016' and gnrev.IDREVISIONSTATUS <> '029'
and form.tds003 = 2 and form.tds005 = 2 and acao.tds009 = 0

--==================================> Lista de atividades com suas predecessoras
select plano.idactivity as Plano, atv.idactivity as idAtividade
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
, coalesce(substring((select ' | '+ atvlink.idactivity as [text()] from GNACTIVITYLINKS link
 left join gnactivity atvlink on atvlink.cdgenactivity = link.cdpredecessor where link.cdactivity = atv.CDGENACTIVITY for XML path('')), 4, 250), 'Não tem predecessora') as predecessoras
from gnactivity atv
inner join gnactivity plano on plano.cdgenactivity = atv.cdactivityowner
INNER JOIN gntask gntk on atv.cdgenactivity = gntk.cdgenactivity
inner join gnactionplan actpl on atv.cdactivityowner = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
where atv.CDISOSYSTEM in (174,160,202) and atv.cdactivityowner is not null
and gntype.cdgentype = 23
order by plano.idactivity, atv.idactivity

--===================================> LIsta de treinamentos x Usuários x Documentos x Revisão
select tr.IDTRAIN, rev.iddocument, gnrev.idrevision, usr.idlogin, usr.nmuser, dep.nmdepartment, pos.nmposition
from trtraining tr
inner join DCDOCTRAIN tdoc on tr.cdtrain = tdoc.cdtrain
inner join gnrevision gnrev on gnrev.cdrevision = tdoc.cdrevision
inner join dcdocrevision rev on rev.cdrevision = tdoc.cdrevision
inner join trtrainuser trusr on trusr.cdtrain = tr.cdtrain
inner join aduser usr on usr.cduser = trusr.cduser
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition

--===================================> Ações do Plano para aprovação de determinado usuário
select plano.idactivity as Plano, atv.idactivity as idAtividade
, atv.nmactivity as nomeAtividade
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
, aprov.nmuser
from gnactivity atv
inner join gnactivity plano on plano.cdgenactivity = atv.cdactivityowner
inner join gnvwapprovresp aprov on aprov.cdapprov = atv.cdexecroute and cdprod=174
where atv.CDISOSYSTEM in (174,160,202) and atv.fgstatus <5 and (aprov.cduser in (1385) or aprov.cdteam = 166) and FGAPPROV is null

--===================================> Usuários sem ROLE
select usr0.nmuser,usr0.idlogin, rel0.FGDEFAULTDEPTPOS
from aduser usr0
inner join aduserdeptpos rel0 on rel0.cduser = usr0.CDUSER
inner join addepartment dep0 on dep0.cddepartment = rel0.cddepartment
where usr0.cduser not in (
select usr.cduser
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.CDUSER
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cddepartment = 164
)
and dep0.CDCOMPANIES = 7 and usr0.FGUSERENABLED = 1
--===================================> Responsáveis pelos EQ em Execução de plano de ação
select wf.idprocess
, (select nmstring from wfprocattrib where idprocess = wf.idobject and cdattribute = 179) as responsavel
from wfprocess wf
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where cdprocessmodel=28 and gnrev.NMREVISIONSTATUS = 'Execução do Plano de ação'

--===================================> Reabrir atividade
update gnactivity
set fgstatus=3, vlpercentagem=null,qtdurationreal=null,qtminutesreal=null,qttimefinish=null,dtfinish=null
where cdgenactivity=xxx
--===================================> Usuários com treinamento como área padrão
select *
from aduser usr
inner join aduserdeptpos rel on rel.cduser=usr.cduser
where rel.cddepartment in (164) and rel.FGDEFAULTDEPTPOS = 1


--==================================> Usuários da planta com área
select usr.nmuser,dep.nmdepartment
from aduser usr
inner join aduserdeptpos rel on usr.cduser = rel.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and dep.cdcompanies = 7 and dep.cddepartment <> 164
order by usr.nmuser

--==================================> Revisão do documento do treinamento x Revisão do Documento vigente
select IDTRAIN, rev.iddocument, gnrev.idrevision
, (select gnr.idrevision from dcdocrevision dr inner join gnrevision gnr on dr.cdrevision = gnr.cdrevision where dr.cddocument = dctr.cddocument and dr.fgcurrent = 1) as revatual
from trtraining tr
inner join DCDOCTRAIN dctr on dctr.cdtrain = tr.cdtrain
inner join dcdocrevision rev on rev.cdrevision = dctr.cdrevision
inner join gnrevision gnrev on gnrev.cdrevision = dctr.cdrevision

--==================================> Lead time de revisão
select cat.idcategory, docrev.iddocument, gnrev.idrevision, gnrev.DTREVCREATE, gnrev.dtrevision
, datediff(dd,gnrev.DTREVCREATE,gnrev.dtrevision) as leadtime
from dcdocrevision docrev
inner join gnrevision gnrev on gnrev.cdrevision = docrev.cdrevision
inner join dccategory cat on cat.cdcategory = docrev.cdcategory
where gnrev.dtrevision > '2015/01/01' and gnrev.dtrevision < '2015/12/31'
and docrev.cdcategory in (105)

--=================================> Solicitação de cancelamento
select req.IDREQUEST
from GNREQUEST req
inner join GNAPPROVRESP apro on apro.CDPROD = req.CDPROD and apro.CDAPPROV = req.CDAPPROV
inner join DCDOCCANCELREQUEST assrev on assrev.cdrequest = req.cdrequest
inner join dcdocument doc on doc.cddocument = assrev.cddocument
inner join dcdocrevision rev on rev.cddocument = doc.cddocument
where rev.iddocument = 'form-ua-m-051'

--==================================> Tempo de aprovação e atendimento de solicitação
select req.IDREQUEST
, format(req.DTREQUEST,'dd/MM/yyyy') as aberta, format(apro.DTAPPROV,'dd/MM/yyyy') as aprovada
, format(gnrev.DTREVCREATE,'dd/MM/yyyy') as atendida --, format(req.DTREQUESTENDDATE,'dd/MM/yyyy') as fechada
, case when revrev.iddocument is null then revdoc.iddocument else revrev.iddocument end as identificador
, gnrev.idrevision
from GNREQUEST req
inner join GNAPPROVRESP apro on apro.CDPROD = req.CDPROD and apro.CDAPPROV = req.CDAPPROV
inner join GNREVISIONREQASSOC assrev on assrev.cdrequest = req.cdrequest
inner join gnrevision gnrev on gnrev.cdrevision = assrev.cdrevision
inner join dcdocrevision docrev on docrev.cdrevision = assrev.cdrevision
--
left join DCDOCREVREQUEST reqrev on reqrev.cdrequest = req.cdrequest
left join dcdocrevision revrev on revrev.cddocument = reqrev.cddocument and revrev.fgcurrent = 1
left join DCDOCUMENTREQUEST reqdoc on reqdoc.cdrequest = req.cdrequest
left join dcdocrevision revdoc on revdoc.cddocument = reqdoc.cddocument and revdoc.fgcurrent = 1
where revdoc.cddocument is not null or revrev.cddocument is not null
and docrev.cdcategory in (105, 106, 107, 108)

--==================================> Acessos aos processos
select distinct nmuser, unidade, processo, acesso
from (
select adt.idteam, usr.nmuser
, case substring(adt.idteam,1,2) when 'IN' then 'INOVAT'
                                 when 'AN' then 'ANOVIS'
                                 when 'UA' then 'Union Agener'
end unidade
, case substring(adt.idteam,4,2) when 'CM' then 'Controle de Mudança'
                                 when 'RM' then 'Reclamação de Mercado'
                                 when 'CC' then 'Reclamação de Mercado'
                                 when 'LA' then 'Investigação de Laboratório'
                                 when 'DE' then 'Desvio'
                                 when 'EQ' then 'Evento de Qualidade'
                                 when 'QE' then 'Evento de Qualidade'
                                 when 'SO' then 'Solicitação'
                                 when 'RE' then 'Solicitação'
end processo
, case substring(adt.idteam,charindex('_', adt.idteam)+1,4) when 'CONS' then 'EQ_Consulta'
                                                            when 'GEST' then 'EQ_Gestão'
end acesso
from adteam adt
inner join adteammember adtm on adtm.cdteam = adt.cdteam
inner join aduser usr on usr.cduser = adtm.cduser
where adt.idteam like '%-LAB_%' or adt.idteam like '%-DE_%' or adt.idteam like '%-RM_%' or adt.idteam like '%-CM_%' or adt.idteam like '%-SOL_%' or adt.idteam like '%-EQ_%'
or adt.idteam like '%-QE_%' or adt.idteam like '%-CC_%' or adt.idteam like '%-REQ_%'
union all
select adt.idteam, usr.nmuser
, case substring(adt.idteam,1,2) when 'IN' then 'INOVAT'
                                 when 'AN' then 'ANOVIS'
                                 when 'UA' then 'Union Agener'
end unidade
, case substring(adt.idteam,4,2) when 'CM' then 'Controle de Mudança'
                                 when 'RM' then 'Reclamação de Mercado'
                                 when 'CC' then 'Reclamação de Mercado'
                                 when 'LA' then 'Investigação de Laboratório'
                                 when 'DE' then 'Desvio'
                                 when 'EQ' then 'Evento de Qualidade'
                                 when 'QE' then 'Evento de Qualidade'
                                 when 'SO' then 'Solicitação'
                                 when 'RE' then 'Solicitação'
end processo
, 'PF_'+adr.nmrole as acesso
from adteam adt
inner join adteammember adtm on adtm.cdteam = adt.cdteam
inner join aduser usr on usr.cduser = adtm.cduser
inner join aduserrole adru on adru.cduser = usr.cduser
inner join adrole adr on adr.cdrole = adru.cdrole and substring(adt.idteam,4,2) = substring(adr.idrole,4,2)
where adt.idteam like '%-LAB_%' or adt.idteam like '%-DE_%' or adt.idteam like '%-RM_%' or adt.idteam like '%-CM_%' or adt.idteam like '%-SOL_%' or adt.idteam like '%-EQ_%'
or adt.idteam like '%-QE_%' or adt.idteam like '%-CC_%' or adt.idteam like '%-REQ_%'
union all
select adt.idteam, usr.nmuser
, case substring(adt.idteam,1,2) when 'IN' then 'INOVAT'
                                 when 'AN' then 'ANOVIS'
                                 when 'UA' then 'Union Agener'
end unidade
, case substring(adt.idteam,4,2) when 'CM' then 'Controle de Mudança'
                                 when 'RM' then 'Reclamação de Mercado'
                                 when 'CC' then 'Reclamação de Mercado'
                                 when 'LA' then 'Investigação de Laboratório'
                                 when 'DE' then 'Desvio'
                                 when 'EQ' then 'Evento de Qualidade'
                                 when 'QE' then 'Evento de Qualidade'
                                 when 'SO' then 'Solicitação'
                                 when 'RE' then 'Solicitação'
end processo
, 'RR_'+adap.nmapprovalroute as acesso
from adteam adt
inner join adteammember adtm on adtm.cdteam = adt.cdteam
inner join aduser usr on usr.cduser = adtm.cduser
inner join adapprovrouteresp adapu on adapu.cduser = usr.cduser
inner join adapprovalroute adap on adap.cdapprovalroute = adapu.cdapprovalroute and substring(adt.idteam,4,2) = substring(adap.idapprovalroute,4,2)
where adt.idteam like '%-LAB_%' or adt.idteam like '%-DE_%' or adt.idteam like '%-RM_%' or adt.idteam like '%-CM_%' or adt.idteam like '%-SOL_%' or adt.idteam like '%-EQ_%'
or adt.idteam like '%-QE_%' or adt.idteam like '%-CC_%' or adt.idteam like '%-REQ_%'
) _sub
where substring(idteam,1,2) = 'IN'
order by nmuser
--order by Unidade, processo, acesso, nmuser

--==================================> data do consenso de GEDOC
select cat.idcategory, docrev.iddocument, gnrev.idrevision
--, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.NRCYCLE as ciclo
, format(gnrev.DTREVCREATE,'dd/MM/yyyy') as inicio, format(stag.DTAPPROVAL,'dd/MM/yyyy') as consensoGEDOC
, datediff(dd,gnrev.DTREVCREATE,stag.DTAPPROVAL) as tempo
, format((select top 1 stg.DTAPPROVAL from GNREVISIONSTAGMEM stg where gnrev.CDREVISION = stg.CDREVISION and stg.NRCYCLE=stag.NRCYCLE and stg.FGSTAGE=1 Order by stg.DTAPPROVAL desc),'dd/MM/yyyy') as elaboradonociclo
, datediff(dd,(select top 1 stg.DTAPPROVAL from GNREVISIONSTAGMEM stg where gnrev.CDREVISION = stg.CDREVISION and stg.NRCYCLE=stag.NRCYCLE and stg.FGSTAGE=1 Order by stg.DTAPPROVAL desc),stag.DTAPPROVAL) as tempo2
from dcdocrevision docrev
inner join gnrevision gnrev on gnrev.cdrevision = docrev.cdrevision
inner join dccategory cat on cat.cdcategory = docrev.cdcategory
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
where gnrev.dtrevision > '2015/01/01' and gnrev.dtrevision < '2015/12/31' and stag.FGSTAGE = 2 and stag.FGAPPROVAL is not null and stag.cdteam=87 and docrev.cdcategory in (105, 106, 107, 108)
order by cat.idcategory, docrev.iddocument, gnrev.idrevision, stag.FGSTAGE, stag.NRCYCLE

--==================================> Id do plano, id da atividade, responsável e ciclo
select (select idactivity from gnactivity where cdgenactivity = gnact.cdactivityowner) as plano,
gnact.idactivity, (select nmuser from aduser where cduser = gnact.cduser) as repensavel,aprov.cdcycle
from (select max(cdcycle) as maxcycle, cdapprov
      from gnvwapprovresp where cdprod=174
      group by cdapprov) max_cycle, gnactionplan actpl
inner join gnactivity gnact on gnact.cdactivityowner = actpl.cdgenactivity
inner join gnvwapprovresp aprov on aprov.cdapprov = gnact.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
where aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
and gnact.cduser in (1486,1123) and ((select idactivity from gnactivity where cdgenactivity = gnact.cdactivityowner) like 'TDS-EQ%' or
(select idactivity from gnactivity where cdgenactivity = gnact.cdactivityowner) like 'QUA%' or (select idactivity from gnactivity where cdgenactivity = gnact.cdactivityowner) like 'AN-EQ%')
order by plano,gnact.idactivity

--===================================> Deletar revisões novas deixando apenas a(s) mais antiga(s)
select rev.cddocument, rev.cdrevision, gnrev.fgstatus, rev.fgcurrent, gnrev.idrevision
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
where iddocument = 'TST_ADM000009'

--delete from GNREVISIONREQASSOC where cdrevision in (57977,55289,54841)
--delete from GNREVISIONCRITIC where cdrevision in (57977,55289,54841)
--delete from GNREVUPDATE where cdrevision in (57977,55289,54841)
--delete from GNREVISIONSTAGMEM where cdrevision in (57977,55289,54841)
--delete from DCDOCUMENTATTRIB where cdrevision in (57977,55289,54841)
--delete from gnfile where CDCOMPLEXFILECONT in (select CDCOMPLEXFILECONT from DCFILE where cdrevision in (57977,55289,54841))
--delete from DCFILE where cdrevision in (57977,55289,54841)
--delete from dcdocrevision where cdrevision in (57977,55289,54841)
--delete from GNREVISIONCHANGES where cdrevision in (57977,55289,54841)
--delete from gnrevision where cdrevision in (57977,55289,54841)
--update dcdocrevision set fgcurrent = 1 where cdrevision = 53344

--Crítica
select crit.*
from dcdocrevision rev
inner join GNREVISIONCRITIC crit on crit.cdrevision = rev.cdrevision
where rev.iddocument = 'PA-C.0467'
and rev.cdrevision = (select max(cdrevision) from dcdocrevision re where re.cddocument = rev.cddocument)

--==================================> Alterar status das atividades em Planejamento cujo plano está em execução
select filho.* from gnactivity filho, gnactivity pai where pai.cdgenactivity = filho.cdactivityowner and filho.fgstatus=1 and pai.fgstatus = 3
--
update gnactivity set fgstatus=3 where cdgenactivity in (
select filho.cdgenactivity from gnactivity filho, gnactivity pai where pai.cdgenactivity = filho.cdactivityowner and filho.fgstatus=1 and pai.fgstatus = 3
)
--Transferência de usuários de equipe para Papel funcional
--OOS'
insert into aduserrole
(cdrole,cduser,fgmanager,fgdefaultrole,dtinsert,dtupdate,nmuserupd)
select 89,cduser,0,0,getdate(),'','Alvaro Adriano Beck' from adteammember where cdteam =165
--EQ
insert into aduserrole
(cdrole,cduser,fgmanager,fgdefaultrole,dtinsert,dtupdate,nmuserupd)
select 82,cduser,0,0,getdate(),'','Alvaro Adriano Beck' from adteammember where cdteam =167
--DE
insert into aduserrole
(cdrole,cduser,fgmanager,fgdefaultrole,dtinsert,dtupdate,nmuserupd)
select 91,cduser,0,0,getdate(),'','Alvaro Adriano Beck' from adteammember where cdteam =168
--CM
insert into aduserrole
(cdrole,cduser,fgmanager,fgdefaultrole,dtinsert,dtupdate,nmuserupd)
select 85,cduser,0,0,getdate(),'','Alvaro Adriano Beck' from adteammember where cdteam =78

select * from adteam where idteam='TDS-IOOS'
select * from adrole where idrole='QUA-OOS-INI'
--======================================> Seleção de atividades de processo com todos so dados
select atv.*, str.*, wf.*
from wfprocess wf
inner join wfhistory his on his.idprocess = wf.idobject
inner join wfstruct str on str.idobject = his.idstruct
inner join wfactivity atv on atv.idobject=str.idobject
where wf.idprocess ='ANVTDE150717141210'
--=====================================> Id do processo e data de conclusão (atributo) - Paloma
select wf.idprocess, format(att.dtdate, 'dd/MM/yyyy')
from wfprocess wf
inner join wfprocattrib att on att.idprocess = wf.idobject and CDATTRIBUTE=194
where att.dtdate is not null
--==============================> Lista de CMs aprovados em determinado mês
Select wf.idprocess, wf.nmprocess
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) as dtaprovarea
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) as nmaprovarea
--
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
)) his) as dtaprovGQ1
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) as nmaprovGQ1
--
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) as dtaprovGQ2
, (select HIS.NMUSER from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) as nmaprovGQ2
from WFPROCESS wf
where cdprocessmodel=1
and (select datepart(MM,HIS.DTHISTORY) from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) = 9

------ karine - Lista de atividades de usuários de CM
select atv.nmuser as nome, wf.idprocess as Plano_ou_Processo, str.nmSTRUCT as Atividade, 'Executora' as O_que
from wfprocess wf
inner join wfstruct str on str.idprocess = wf.idobject
inner join wfactivity atv on atv.idobject=str.idobject
where wf.cdprocessmodel=28 and atv.QTDURATION is null
and atv.nmuser in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka')
union
select 'Resp.: '+ respon.NMSTRING +' | Aprov.: '+ aprova.NMSTRING as nome, wf.idprocess as Plano_ou_Processo, 'NA' as Atividade--, respon.NMSTRING, aprova.NMSTRING
, case when respon.NMSTRING not in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka')
 then case when aprova.NMSTRING not in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka')
 then 'NA' else 'Aprovadora' end else 'Responsável' end O_que
from wfprocess wf
inner join wfprocattrib respon on respon.cdattribute = 179 and respon.idprocess=wf.idobject
inner join wfprocattrib aprova on aprova.cdattribute = 172 and aprova.idprocess=wf.idobject
where (respon.NMSTRING in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka')
or aprova.NMSTRING in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka'))
union
select aprov.nmuser as nome, (select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Aprovador' as O_que
from (select max(cdcycle) as maxcycle, cdapprov
      from gnvwapprovresp
      group by cdapprov) max_cycle, gnactionplan actpl
inner join gnactivity gnact on gnact.cdactivityowner = actpl.cdgenactivity
inner join gnvwapprovresp aprov on aprov.cdapprov = gnact.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
where aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle and aprov.nmuser in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka')
and aprov.cduserapprov is null
union
select usr.nmuser as nome, (select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Executor' as O_que
from gnactivity gnact
left join aduser usr on usr.cduser = gnact.cduser
where cdisosystem = 174 and gnact.fgstatus < 4 and gnact.cdactivityowner is not null
and gnact.cduser in (select cduser from aduser where nmuser in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka'))
-------------------
union
select usr.nmuser as nome, coalesce((select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner), gnact.idactivity) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Planejador' as O_que
from gnactivity gnact
left join aduser usr on usr.cduser = gnact.cduser
where cdisosystem = 174 and gnact.fgstatus = 1 and gnact.cdactivityowner is null
and gnact.cduser in (select cduser from aduser where nmuser in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka'))
union
select usr.nmuser as nome, coalesce((select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner), gnact.idactivity) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Responsável pelo Plano de ação' as O_que
from gnactivity gnact
left join aduser usr on usr.cduser = gnact.cduser
where cdisosystem = 174 and gnact.fgstatus < 4 and gnact.cdactivityowner is null
and gnact.CDUSERACTIVRESP in (select cduser from aduser where nmuser in ('Bruna Lima Quintão', 'Raisa Capuchinho Pires', 'Camila De Carvalho Tanaka'))
order by nome

----- Lista de atividades de processo de um usuário - EQ
select atv.nmuser as nome, wf.idprocess as Plano_ou_Processo, str.nmSTRUCT as Atividade, 'Executora' as O_que
from wfprocess wf
inner join wfstruct str on str.idprocess = wf.idobject
inner join wfactivity atv on atv.idobject=str.idobject
where wf.cdprocessmodel=28 and atv.QTDURATION is null
and atv.nmuser in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos')
union
select 'Resp.: '+ respon.NMSTRING +' | Aprov.: '+ aprova.NMSTRING as nome, wf.idprocess as Plano_ou_Processo, 'NA' as Atividade--, respon.NMSTRING, aprova.NMSTRING
, case when respon.NMSTRING not in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos')
 then case when aprova.NMSTRING not in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos')
 then 'NA' else 'Aprovadora' end else 'Responsável' end O_que
from wfprocess wf
inner join wfprocattrib respon on respon.cdattribute = 179 and respon.idprocess=wf.idobject
inner join wfprocattrib aprova on aprova.cdattribute = 172 and aprova.idprocess=wf.idobject
where wf.cdprocessmodel=28 and (respon.NMSTRING in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos')
or aprova.NMSTRING in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos'))
union
select aprov.nmuser as nome, (select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Aprovador' as O_que
from (select max(cdcycle) as maxcycle, cdapprov
      from gnvwapprovresp
      group by cdapprov) max_cycle, gnactionplan actpl
inner join gnactivity gnact on gnact.cdactivityowner = actpl.cdgenactivity
inner join gnvwapprovresp aprov on aprov.cdapprov = gnact.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
where aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle and aprov.nmuser in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos')
and aprov.cduserapprov is null
union
select usr.nmuser as nome, (select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Executor' as O_que
from gnactivity gnact
left join aduser usr on usr.cduser = gnact.cduser
where cdisosystem = 174 and gnact.fgstatus < 4 and gnact.cdactivityowner is not null
and gnact.cduser in (select cduser from aduser where nmuser in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos'))
-------------------
union
select usr.nmuser as nome, coalesce((select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner), gnact.idactivity) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Planejador' as O_que
from gnactivity gnact
left join aduser usr on usr.cduser = gnact.cduser
where cdisosystem = 174 and gnact.fgstatus = 1 and gnact.cdactivityowner is null
and gnact.cduser in (select cduser from aduser where nmuser in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos'))
union
select usr.nmuser as nome, coalesce((select idactivity from gnactivity where cdgenactivity=gnact.cdactivityowner), gnact.idactivity) as Plano_ou_Processo
, gnact.idactivity as Atividade, 'Responsável pelo Plano de ação' as O_que
from gnactivity gnact
left join aduser usr on usr.cduser = gnact.cduser
where cdisosystem = 174 and gnact.fgstatus < 4 and gnact.cdactivityowner is null
and gnact.CDUSERACTIVRESP in (select cduser from aduser where nmuser in ('Elaine Cristina Ferreira', 'Flavio Henrique Ferraz Arruda', 'Josiane Luiza Nepomoceno', 'Luiz Carlos Parente dos Santos'))

--====================================> Lista de usuários em um grupo de acesso
select usr.nmuser, dep.nmdepartment
from aduseraccgroup grp
inner join aduser usr on usr.cduser = grp.cduser
inner join aduserdeptpos rel on rel.cduser = grp.cduser and fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
where grp.cdgroup in (10,34)

--==========================================> usuários de grupos de acesso Sò de uma unidade
select usr.cduser,usr.idlogin,usr.nmuser
, grp.idgroup,grp.nmgroup
from aduser usr
inner join aduseraccgroup grpusr on grpusr.cduser = usr.cduser
inner join adaccessgroup grp on grp.cdgroup = grpusr.cdgroup
inner join aduserdeptpos rel on rel.cduser=usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies = 7
where usr.fguserenabled = 1 and grp.idgroup like 'DOC%'

--============================> Análises do Analytic
SELECT DISTINCT A.IDIDENTIFIER AS ID_ANALISE, A.NMNAME AS NOME_ANALISE, T.TXDATA
FROM SETEXT T 
INNER JOIN BI2DATASETSQLQUERY D ON T.OID=D.OIDCLOB 
INNER JOIN BI2ANALYSIS A ON A.OID=D.OIDANALYSIS

--====================================> Fórmulas em processos
select pma.idactivity as idprocess, pma.nmactivity as nmprocess, pma.cdacttype, pma.fgstatus, pma.cdgenactivity
, pmp.cdproc as cdprocessmodel
, ativ.idactivity, ativ.nmactivity
, ativ.txformula as executor_formula
from pmprocess pmp
inner join pmactivity pma on pma.cdactivity = pmp.cdproc
inner join PMACTREVISION pmr on pmr.cdactivity = pma.cdactivity and pmr.FGCURRENT = 1
inner join ( select pms.cdrevision, pms.cdproc, f.txformula, pms.idstruct, pms.nmstruct, pmaa.idactivity, pmaa.nmactivity
			from PMSTRUCT pms
            inner join gnformula f on f.cdformula = pms.CDFORMULAEXECUTOR
			inner join pmactivity pmaa on pmaa.cdactivity = pms.cdactivity
) ativ on ativ.cdproc = pmp.cdproc and ativ.cdrevision = pmr.cdrevision
Where ativ.txformula like '%$208512%'


-- pmprocess / gnrevision / pmflow
-- CDFORMULAEXECUTOR, CDFORMULADURATION, CDFORMULAWFMNG, CDFORMULA, CDFORMULABEFORE, CDFORMULAAFTER, 

--====================================> desbloquear os relatórios
update adreport set cdcheckoutuser = null

--====================================> Avaliação 10 por GS
select count(1) as total
from (
select form.itsm030, form.itsm035, form.itsm056
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join WFSTRUCT wfs on wf.idobject = wfs.idprocess and wfs.idstruct = 'Atividade2142111325145' and wfs.DTENABLED is not null
where wf.cdprocessmodel = 5251 and form.itsm030 > (
    select max(form1.itsm030)
    from DYNitsm form1
    inner join gnassocformreg gnf1 on (gnf1.oidentityreg = form1.oid)
    inner join wfprocess wf1 on (wf1.cdassocreg = gnf1.cdassoc)
    inner join WFSTRUCT wfs1 on wf1.idobject = wfs1.idprocess and wfs1.idstruct = 'Atividade2049154312401' and wfs1.DTENABLED is not null
    where wf1.cdprocessmodel = wf.cdprocessmodel
    and form1.itsm056 = form.itsm056
)
and form.itsm056 = 'SAPQM'
) _sub

--------Lista de ações em aprovação
Select wf.idprocess --, wf.nmprocess
, gnactp.idactivity as idplano --, gnactp.nmactivity as nomeplano
, atividade.idactivity--, atividade.fgstatus, atividade.DTSTART, atividade.nmactivity
, case atividade.fgstatus
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
, aprov.cdcycle--, case when (select DTFINISH+qtduetime from gnactivity where cdgenactivity = atividade.cdgenactivity) < getdate() then 'Atrasado' else 'Em dia' end as Prazo
--, convert(varchar(10),aprov.dtapprov, 103) as dataaprova
, convert(varchar(10),aprov.DTDEADLINE, 103) as datafimaprov
, aprov.QTDUETIME as prazoaprov
, convert(varchar(10),aprov.DTDEADLINE - aprov.QTDUETIME, 103) as dtrecebeuaprov
--, case when aprov.fgapprov = 1 then 'Aprovou a atividade' when aprov.fgapprov = 2 then 'Reprovou a atividade' end as aprovacao
, case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, nmuser)) when aprov.cdteam is not null then (select nmteam from adteam where cdteam = aprov.cdteam) end as aprovador
, (select nmuser from aduser where cduser=atividade.cduser) as executor
, atividade.DTSTARTPLAN as inicioplanejado, atividade.QTDURATIONPLAN as prazoatividade
, convert(varchar(10),atividade.dtfinish, 103) as fim_atividade--, atividade.dtstartplan,atividade.dtfinishplan
from wfprocess wf
INNER JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
inner join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
INNER JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
INNER JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
inner join gnactivity atividade on atividade.cdactivityowner = gnactp.cdgenactivity
inner join gnvwapprovresp aprov on aprov.cdapprov = atividade.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
inner join (select max(cdcycle) as maxcycle, cdapprov from gnvwapprovresp group by cdapprov) max_cycle
         on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where wf.cdprocessmodel in (28) --and atividade.fgstatus=4
--Lista de Atividades de um plano de ação com "todos" os campos
select CAST(gntype.IDGENTYPE + CASE WHEN gntype.IDGENTYPE IS NULL THEN NULL ELSE ' - ' END + gntype.NMGENTYPE AS VARCHAR(510)) AS tipoplano
, plano.idactivity as Plano, atv.idactivity as idAtividade, (select nmuser from aduser where cduser=atv.cduser) as executor
, atv.nmactivity as nomeAtividade, atv.VLPERCENTAGEM as porcentagem
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
, format((select DTFINISH from gnactivity where cdgenactivity = atv.cdgenactivity), 'dd/MM/yyyy') as dtrecebeu_paraaprovar
, format((select coalesce (dtfinish,dtfinishplan)+qtduetime from gnactivity where cdgenactivity = atv.cdgenactivity), 'dd/MM/yyyy') as dtprevaprov
, aprov.cdcycle, case when (select DTFINISH+qtduetime from gnactivity where cdgenactivity = atv.cdgenactivity) < getdate() then 'Atrasado' else 'Em dia' end as Prazo
, convert(varchar(10),aprov.dtapprov, 103) as dataaprova
, case when aprov.fgapprov = 1 then 'Aprovou a atividade' when aprov.fgapprov = 2 then 'Reprovou a atividade' end as aprovacao
, case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, nmuser)) when aprov.cdteam is not null then (select nmteam from adteam where cdteam = aprov.cdteam) end as aprovador
, CAST(aprov.dsobs AS VARCHAR(4000)) as obserrvacao
, CAST(atv.DSACTIVITY AS VARCHAR(4000)) as resultado
, CAST(atv.dsdescription AS VARCHAR(4000)) AS como
, CAST(gntk.dswhy AS VARCHAR(4000)) AS porque
,CAST(gntk.dswhere AS VARCHAR(4000)) AS onde
--, iduseraprov, aprov.cdapprov, atv.cdgenactivity, actpl.cdactionplan, aprov.qtduetime
from gnactivity atv
inner join gnactivity plano on plano.cdgenactivity = atv.cdactivityowner
INNER JOIN gntask gntk on atv.cdgenactivity = gntk.cdgenactivity
inner join gnactionplan actpl on atv.cdactivityowner = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
inner join gnvwapprovresp aprov on aprov.cdapprov = atv.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
inner join (select max(cdcycle) as maxcycle, cdapprov from gnvwapprovresp group by cdapprov) max_cycle
         on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where atv.CDISOSYSTEM in (174,160,202) and atv.cdactivityowner is not null --and atv.fgstatus in (2,4)
and gntype.cdgentype = 23
order by tipoplano, plano.idactivity, atv.idactivity, atv.fgstatus, aprov.dtapprov, aprov.nmuserapprov

--Lista formulário do processo
SELECT wf.IDPROCESS, form.*
FROM DYNtds016 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
WHERE wf.idprocess = 'ANVTDE151020084835'

--v2.0

select form.*
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.idprocess = 'ANVTCM170824130645'

--

select form.*
from wfprocess wf
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNtds015 form on (gnf.oidentityreg = form.oid)
left outer join gnrevisionstatus gnrs on (wf.cdstatus = gnrs.cdrevisionstatus)
where wf.idprocess = 'ANVTCM170824130645'

--
select *
from pbproblem pb
inner join inoccurrence ino on (pb.cdoccurrence = ino.CDOCCURRENCE)
inner join wfprocess wf on (ino.IDWORKFLOW = wf.idobject)
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNtds015 form on (gnf.oidentityreg = form.oid)
left outer join gnrevisionstatus gnrs on (wf.cdstatus = gnrs.cdrevisionstatus)

--> Usuários criados manualmente:
select coa.cduser,coa.idlogin, usr.fguserenabled
from coaccount coa
inner join aduser usr on usr.cduser = coa.cduser
where coa.nmdomainuid is null
and exists (select 1 from aduseraccgroup acc where acc.cduser = usr.cduser and cdgroup <> 76)

--lista atividades ad-hoc
select gnact.nmactivity, gnact.idactivity
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
from wfactivity wfa
inner join WFSTRUCT wfs on wfs.idobject = wfa.IDOBJECT
inner join WFPROCESS wfp on wfp.idobject = wfs.idprocess
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
inner join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wfa.FGACTIVITYTYPE=3 and wfp.idprocess='ANVTRM151001165140'
--==============================> Solicitações em aprovação
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.dtstart as dtabertura, wf.nmprocess
, (select his.nmuser from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as aprovador
, (select convert(varchar(10),his.DTHISTORY, 103) from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (6) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtrecebeu
, (select convert(varchar(10),his.DTESTIMATEDFINISH, 103) from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.DTESTIMATEDFINISH
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (6) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as prazo
from DYNtds038 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where wf.cdprocessmodel=72 and form.tds003 = 4 and gnrev.NMREVISIONSTATUS='Em aprovação'
union
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.dtstart as dtabertura, wf.nmprocess
, (select his.nmuser from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as aprovador
, (select convert(varchar(10),his.DTHISTORY, 103) from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (6) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtrecebeu
, (select convert(varchar(10),his.DTESTIMATEDFINISH, 103) from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION, str.DTESTIMATEDFINISH
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão1517164719957'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (6) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as prazo
from DYNtbs038 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where wf.cdprocessmodel=72 and form.tbs004 = 4 and gnrev.NMREVISIONSTATUS='Em aprovação'


--===================> Conteúdo do treinamento
select trc.idcourse, trc.nmcourse, trcn.FGTYPEREVISION
, case trcn.FGTYPEREVISION when 1 then 'Specific' when 2 then 'Current' when 3 then 'Object' end contentType
from trcourse trc
inner join TRCOURSECONTENT trcc on trcc.cdcourse = trc.cdcourse
inner join TRCONTENTGRP trcg on trcg.CDCONTENTGRP = trcc.CDCONTENTGRP and FGCONTENTTYPE = 4
inner join TRCONTENT trcn on trcn.CDCONTENT = trcg.CDCONTENTGRP
inner join gngentype gnt on gnt.cdgentype = trc.cdcoursetype
where gnt.cdgentypeowner=137

--=========================> Fumagalli - Chamados cancelados
select wf.idprocess, wf.nmprocess, wf.dtstart
, CASE WHEN HIS.FGTYPE=1 THEN '#{214623}' WHEN HIS.FGTYPE=2 THEN '#{214626}' WHEN HIS.FGTYPE=3 THEN '#{214624}' WHEN HIS.FGTYPE=4 THEN '#{214622}' WHEN HIS.FGTYPE=5 THEN '#{214625}' WHEN HIS.FGTYPE=6 THEN '#{108524}' WHEN HIS.FGTYPE=7 THEN '#{108521}' WHEN HIS.FGTYPE=8 THEN '#{108523}'
WHEN HIS.FGTYPE=9 OR HIS.FGTYPE=13 THEN CASE WHEN HIS.FGEXECACTIVITY=1 THEN '#{109792}' ELSE '#{108515}' END WHEN HIS.FGTYPE=10 THEN '#{108522}' WHEN HIS.FGTYPE=11 THEN '#{207321}' WHEN HIS.FGTYPE=12 THEN '#{111081}' WHEN HIS.FGTYPE=14 THEN '#{202998}' WHEN HIS.FGTYPE=15 THEN '#{203001}' WHEN HIS.FGTYPE=16 THEN '#{203157}' WHEN HIS.FGTYPE=17 THEN '#{300627}' WHEN HIS.FGTYPE=18 THEN '#{205986}' WHEN HIS.FGTYPE=19 THEN '#{206047}' WHEN HIS.FGTYPE=20 THEN '#{206045}' WHEN HIS.FGTYPE=21 THEN '#{206395}' WHEN HIS.FGTYPE=22 THEN '#{206396}' WHEN HIS.FGTYPE=23 THEN '#{206397}' WHEN HIS.FGTYPE=24 THEN '#{206398}' WHEN HIS.FGTYPE=25 THEN '#{206399}' WHEN HIS.FGTYPE=26 THEN '#{206400}' WHEN HIS.FGTYPE=27 THEN '#{206401}' WHEN HIS.FGTYPE=28 THEN '#{206402}' WHEN HIS.FGTYPE=29 THEN '#{300628}' WHEN HIS.FGTYPE=30 THEN '#{300629}' WHEN HIS.FGTYPE=31 THEN '#{207878}' WHEN HIS.FGTYPE=32 THEN '#{212328}' WHEN HIS.FGTYPE=33 THEN '#{214355}' WHEN HIS.FGTYPE=34 THEN '#{214354}' WHEN HIS.FGTYPE=35 THEN '#{205979}' WHEN HIS.FGTYPE=36 THEN '#{214357}' WHEN HIS.FGTYPE=37 THEN '#{214356}' WHEN HIS.FGTYPE=40 THEN '#{218247}' WHEN HIS.FGTYPE=41 THEN '#{202818}' WHEN HIS.FGTYPE=42 THEN '#{300509}' WHEN HIS.FGTYPE=43 THEN '#{300510}' WHEN HIS.FGTYPE=44 THEN '#{300511}' WHEN HIS.FGTYPE=45 THEN '#{300512}' WHEN HIS.FGTYPE=46 THEN '#{300513}' WHEN HIS.FGTYPE=47 THEN '#{300514}' WHEN HIS.FGTYPE=48 THEN '#{219451}' WHEN HIS.FGTYPE=50 THEN '#{300296}' WHEN HIS.FGTYPE=51 THEN '#{300297}' WHEN HIS.FGTYPE=52 THEN '#{302481}' WHEN HIS.FGTYPE=53 THEN '#{302482}' WHEN HIS.FGTYPE=71 THEN '#{300310}' WHEN HIS.FGTYPE=72 THEN '#{308378}' WHEN HIS.FGTYPE=73 THEN '#{308379}' WHEN HIS.FGTYPE=74 THEN '#{308380}'
END AS nmTYPE
, his.DSCOMMENT as jutific, his.dthistory+his.tmhistory as dtcancel
, case his.fgtype when 3 then 'Instância cancelada' when 5 then 'Instância reativada' else cast(his.fgtype as varchar) end fgtype
, coalesce(SLALC.QTRESOLUTIONTIME, 0) / 60 as sla
, case when wf.fgstatus = 1 then round(((select coalesce(sum(QTTIMECALENDAR), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)), 2)
       else ROUND(( gnslactrl.QTTIMEFRSTCAL + gnslactrl.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2)
end as slapercent
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
, case when exists (select distinct(his2.idprocess) from wfhistory his2 where his2.idprocess = his.idprocess and his2.fgtype = 5 and his2.dthistory+his2.tmhistory < his.dthistory+his.tmhistory) then 'Sim' else 'Não' end reativado
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
inner JOIN GNSLACTRLHISTORY SLAH ON (gnslactrl.CDSLACONTROL = SLAH.CDSLACONTROL AND SLAH.FGCURRENT = 1) 
inner JOIN GNSLALEVEL SLALC ON (SLAH.CDLEVEL = SLALC.CDLEVEL)
inner join WFHISTORY HIS on his.idprocess = wf.idobject and his.FGTYPE = 3
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
where wf.cdprocessmodel = 5251 and wf.fgstatus = 3
and case when wf.fgstatus = 1 then round(((select coalesce(sum(QTTIMECALENDAR), 0) + coalesce((select datediff(ss, CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(BNSTART AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')), CONVERT(DATETIME, GETDATE())) from GNSLACTRLSTATUS where CDSLACONTROL = (select cdslacontrol from wfprocess where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is null and idprocess = wf.idprocess)),0)
          from GNSLACTRLSTATUS where (FGTRIGGER = 10 or FGTRIGGER = 20) and qttime is not null and CDSLACONTROL = wf.cdslacontrol) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60)), 2)
       else ROUND(( gnslactrl.QTTIMEFRSTCAL + gnslactrl.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2)
end >= 100
and his.dthistory between '2022/09/01' and '2022/09/30'
--==========================> Catálogo
select *
from DYNitsm001 form
inner join DYNitsm002 cat on form.OIDABCP4PNGD3QW8LP = cat.oid
inner join DYNitsm003 subc on form.OIDABC33MU921YCVUK = subc.oid
inner join DYNitsm019 agrup on form.OIDABC868DY7UV2HFM = agrup.oid

--========================> Desvios de TI
select idprocess, nmprocess, dtstart, status, quantidade
from (Select wf.idprocess, wf.nmprocess, wf.dtstart, wf.cdassocreg
      , case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as status
      , wf.idobject
      , 1 as quantidade
      From wfprocess wf
      where (wf.cdprocessmodel = 17 or wf.cdprocessmodel = 3235 or wf.cdprocessmodel = 4469)) _sub
inner join gnassocformreg gnf on (_sub.cdassocreg = gnf.cdassoc)
inner join DYNtds010 form on (gnf.oidentityreg = form.oid)
where exists (select 1
              from DYNtbs011 areaocor
              where areaocor.oid = form.OIDABCO2wABCqaO and (areaocor.tbs11 = 'TECNOLOGIA DA INFORMAÇÃO' or areaocor.tbs11 = 'Computer Systems' or areaocor.tbs11 = 'TI')
) or
exists (select 1
        from aduser usr
        inner join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
        inner join addepartment dep on dep.cddepartment = rel.cddepartment and (dep.nmdepartment = 'Tecnologia da Informação' or dep.nmdepartment = 'Information Technology')
        where usr.iduser = form.tds005
) or
exists (SELECT 1
        FROM WFSTRUCT STR, WFHISTORY HIS
        inner join aduserdeptpos rel on rel.cduser = his.cduser and rel.FGDEFAULTDEPTPOS = 1
        inner join addepartment dep on dep.cddepartment = rel.cddepartment
        WHERE  str.idstruct = 'Atividade141027113146417' and str.idprocess=_sub.idobject
        and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = _sub.idobject and HIS.FGTYPE = 9
        and (dep.nmdepartment = 'Tecnologia da Informação' or dep.nmdepartment = 'Information Technology')
)
--and <filtro de data se precisar>


--==============================> Log da execução de webservices dentro do próprio SESuite
select * from emwslog order by bnexecstart desc

--================================> Chamados de acesso
select wf.idprocess as chamado, wf.dtstart+wf.tmstart as dtsolicit, wf.nmuserstart as solicitante
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then gnrev.NMREVISIONSTATUS when 5 then 'Bloqueado para edição' end as status
, 'Acessos' as Categoria
, case form.sol031
    when 1 then 'Conceder acesso'
    when 2 then 'Remover acesso'
    else 'N/A'
end Subcategoria
from DYNSolWS form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
inner join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.cdprocessmodel = 5283 and wf.idprocess like 'GA-%'
order by wf.idprocess

--===============================> Atividade atual - prazo
select wf.idprocess, case when datediff(day, wfs.dtestimatedfinish, getdate()) > 0 then 'Atraso' else 'Em dia' end prazo
from wfprocess wf
inner join WFSTRUCT wfs on wfs.idprocess = wf.idobject
where wf.idprocess = 'ANVTRM210419224355' and wfs.idstruct = 'Atividade14102992133595'


--==============================> Lista de usuários de um papel funcional
select adr.idrole, adr.nmrole, usr.idlogin, usr.nmuser
, dep.iddepartment, dep.nmdepartment, pos.idposition, pos.nmposition
from aduser usr
inner join aduserrole adru on adru.cduser = usr.cduser
inner join adrole adr on adr.cdrole = adru.cdrole
inner join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join adposition pos on pos.cdposition = rel.cdposition
where adr.cdroleowner in (select cdrole from adrole where idrole = 'jur-gercon')

--===============================> CMs e checklists

Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess, wfs.nmstruct
, ava.NMITEMCHECKLIST, ava.DSANSWER, ava.father, ava.cditemchecklist, ava.nritemchecklist, case ava.fganswer when 1 then 'Sim' when 2 then 'Não' when 3 then 'N/A' else null end fganswer
from DYNtds015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
inner join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON INC.CDSTATUS = GNrev.CDREVISIONSTATUS
inner join (SELECT ASV1.NMITEMCHECKLIST, ASV1.DSANSWER, ASV1.IDACTIVITY
 , (select COUNT(cditemchecklist) from WFACTCHECKLIST asv2 where asv2.CDITEMOWNER  = asv1.cditemchecklist and ASV1.IDACTIVITY = ASV2.IDACTIVITY) AS FATHER
 , asv1.cditemchecklist
 , ASV1.nritemchecklist, ASV1.fganswer
  FROM WFACTCHECKLIST ASV1) ava on ava.IDACTIVITY = wfs.idobject
where cdprocessmodel=1 and wfa.nmchecklist is not null and ava.fganswer is not null
and wfs.nmstruct = '(15) REALIZAR AVALIAÇÃO DE IMPACTO - GQ:SQ:ASSUNTOS REGULATÓRIOS INDUSTRIAIS'
order by wf.idprocess, wfs.NMSTRUCT, wfs.DTEXECUTION+wfs.TMEXECUTION, ava.father, ava.nritemchecklist, ava.CDITEMCHECKLIST


--==============================> Ações de Plano de ação criados em um mês
select actp.idactivity as plano, actp.nmactivity as nmplano, act.idactivity as atividade, act.nmactivity as nmatividade, format(act.DTFINISHPLAN, 'dd/MM/yyyy') as prazo
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
from GNACTIONPLAN plano
inner join gnactivity actp on actp.CDGENACTIVITY = plano.CDGENACTIVITY and actp.cdactivityowner is null
inner join gnactivity act on act.cdactivityowner = actp.cdgenactivity
where ((act.DTFINISHPLAN > '2015-06-30' and act.DTFINISHPLAN < '2015-09-01') or act.DTFINISHPLAN < getdate())
--plano.dtinsert > '2015-06-30' and plano.dtinsert < '2015-09-01'
and substring(actp.idactivity, 5, 2) = 'EQ' and act.fgstatus = 3 --and act.fgstatus < 9 and act.fgstatus > 1
and (actp.CDUSERACTIVRESP in (1111,961,1048,1003,913,978,1117,1029,4050,1125,914,976) or actp.cduser in (1111,961,1048,1003,913,978,1117,1029,4050,1125,914,976))
--select * from aduser where nmuser like '%altran%' order by nmuser

--===============================> Lista de equipes e papeis funcionais de um usuário
select t.idteam as id, t.nmteam as nm, 'Equipe' as tp
from adteam t
inner join adteammember tm on tm.cdteam = t.cdteam
inner join aduser usr on usr.cduser = tm.cduser
where usr.idlogin = 'pberaldo'
union all
select t.idrole as id, t.nmrole as nm, 'Papel funcional' as tp
from adrole t
inner join aduserrole tm on tm.cdrole = t.cdrole
inner join aduser usr on usr.cduser = tm.cduser
where usr.idlogin = 'pberaldo'

--==============================> Lista de Desvios
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento,
wf.nmprocess, form.tbs012 as dtdetec, form.tbs014 as dtlimite, critf.tbs002 as critfim, criti.tbs005 as critini
, case form.tbs030 when 0 then 'Não' when 1 then 'Sim' end as recorrente
,prod.tbs002 as nmprod, prod.tbs003 as cdprod, prod.tbs004 as lotes
,(select exeaprov.DTHISTORY from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113714228'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.IDPROCESS = wf.idobject
AND HIS.FGTYPE IN (9)
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) exeaprov) as dtaprovfin
from DYNtbs010 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
inner join DYNtbs012 prod on form.oid = prod.OIDABCBZmABCZOW
left join DYNtbs005 criti on criti.oid = form.OIDABCbhdABCcG4
left join DYNtbs002 critf on critf.oid = form.OIDABClGPABCiPe
where wf.cdprocessmodel=17
--==============================
--Cecilia - OOS
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.dtstart as dtabertura, wf.dtfinish as dtfechamento, wf.nmprocess
, form.tbs004 as dtdeteccao, form.tbs005 as dtocorrencia, form.tbs006 as dtlimite, case form.tbs011 when 1 then 'Crítico' when 2 then 'Não crítico' end as critini,
case form.tbs035 when 1 then 'Crítico' when 2 then 'Não crítico' end as critfin,
case form.tbs029 when 1 then 'Sim' when 2 then 'Não' end as confirmada, form.tbs002 as respanalise, form.tbs037 as respinvestiga
, catraiz.tbs007 as catcausaraiz, catev.tbs001 as catevento, laboc.tbs001 as labocorrencia
from DYNtbs016 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs025 catev on catev.oid = form.OIDABCi3MABCjEA
left join DYNtbs026 laboc on laboc.oid = form.OIDABCYa3ABCdTh
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABC87ZABCfAP
where wf.cdprocessmodel=38

--===================================================================> Lista de área e funções de uma unidade
select dep.iddepartment,dep.nmdepartment, pos.idposition, pos.nmposition
from addepartment dep
inner join addeptposition rel on rel.cddepartment = dep.cddepartment
inner join adposition pos on rel.cdposition = pos.cdposition
where dep.cdcompanies = (
select cdcompanies from adcompanies where idcompanies = '0050 - BSB')
order by iddepartment,idposition

--===========================================================================> Lista dos itens dos checklists
select cl.NMCHECKLIST, cli.NRITEMCHECKLIST, cli.NMITEMCHECKLIST
, case when cli.CDITEMOWNER is not null then cast(cli.CDITEMOWNER as varchar) + 'b' else cast(cli.CDITEMCHECKLIST as varchar) + 'a' end CDITEMOWNER
from ADCHECKLIST cl
inner join ADITEMCHECKLIST cli on cli.CDCHECKLIST = cl.CDCHECKLIST
where cl.NMCHECKLIST like 'CM%'
order by cl.cdchecklist, case when cli.CDITEMOWNER is not null then cast(cli.CDITEMOWNER as varchar) + 'b' else cast(cli.CDITEMCHECKLIST as varchar) + 'a' end, cli.CDITEMCHECKLIST

--================================>Update das perguntas
select 'update ADITEMCHECKLIST set NMITEMCHECKLIST = '+ cast(char(39) as varchar)+cli.NMITEMCHECKLIST +cast(char(39) as varchar)+', NRITEMCHECKLIST = '+ cast(NRITEMCHECKLIST as varchar)
+', CDITEMOWNER = '+ cast(CDITEMOWNER as varchar)+' where CDITEMCHECKLIST='+ cast(cli.CDITEMCHECKLIST as varchar) +
' and CDCHECKLIST='+cast(cli.CDCHECKLIST as varchar)+cast(char(59) as varchar)
as tt
from ADCHECKLIST cl
inner join ADITEMCHECKLIST cli on cli.CDCHECKLIST = cl.CDCHECKLIST
where cl.idCHECKLIST like 'CM-ENG%'
order by cl.cdchecklist, case when cli.CDITEMOWNER is not null then cast(cli.CDITEMOWNER as varchar) + 'b' else cast(cli.CDITEMCHECKLIST as varchar) + 'a' end, cli.CDITEMCHECKLIST

--================================> Atualizar data da revisão em branco
update gnrevision set DTREVISION=dtrevrelease where cdrevision in (
select cdrevision from gnrevision where dtrevision is null and dtrevrelease is not null)

--===========================================================================================
--Cecilia - DE
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, format(wf.dtstart, 'dd/MM/yyyy') as dtabertura, format(wf.dtfinish, 'dd/MM/yyyy') as dtfechamento, wf.nmprocess
, format(form.tbs012, 'dd/MM/yyyy') as dtdeteccao, format(form.tbs013, 'dd/MM/yyyy') as dtocorrencia, format(form.tbs014, 'dd/MM/yyyy') as dtlimite
, case form.tbs027 when 1 then 'Sim' when 2 then 'Não' end as lotebloq
, case form.tbs030 when 0 then 'Não' when 1 then 'Sim' end recorrente
, case form.tbs041 when 1 then 'Sim' when 2 then 'Não' end as capa
, case form.tbs080 when 1 then 'Sim' when 2 then 'Não' end as clientefinal
, (select format(his.dthistory,'dd/MM/yyyy') as dthistory from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtaprovinicial
, (select format(his.dthistory,'dd/MM/yyyy') as dthistory from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141027113051875'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtsubmeteregistro
, (select his.nmuser from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141027113146417'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as investigador
, areadetec.tbs11 as areadetec, areaocor.tbs11 as areaocorrencia, classinic.tbs005 as classificini, catevent.tbs006 as catevento
, catraiz.tbs007 as catcausaraiz, equipo.tbs013 as equipamento
from DYNtbs010 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs011 areadetec on areadetec.oid = form.OIDABCDfwABC5KU
left join DYNtbs011 areaocor on areaocor.oid = form.OIDABCM6gABCRMJ
left join DYNtbs005 classinic on classinic.oid = form.OIDABCbhdABCcG4
left join DYNtbs006 catevent on catevent.oid = form.OIDABCPnPABCtlj
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABC3i7ABC2fm
left join DYNtbs013 equipo on equipo.oid = form.OIDABCcotABCnUs
where wf.cdprocessmodel=17
union
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, format(wf.dtstart, 'dd/MM/yyyy') as dtabertura, format(wf.dtfinish, 'dd/MM/yyyy') as dtfechamento, wf.nmprocess
, format(form.tds001, 'dd/MM/yyyy') as dtdeteccao, format(form.tds002, 'dd/MM/yyyy') as dtocorrencia, format(form.tds003, 'dd/MM/yyyy') as dtlimite
, case form.tds030 when 1 then 'Sim' when 2 then 'Não' end as lotebloq
, case form.tds052 when 0 then 'Não' when 1 then 'Sim' end recorrente
, case form.tds039 when 1 then 'Sim' when 2 then 'Não' end as capa
, 'NA' as clientefinal
, (select format(his.dthistory,'dd/MM/yyyy') as dthistory from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão141027113057548'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtaprovinicial
, (select format(his.dthistory,'dd/MM/yyyy') as dthistory from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141027113051875'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtsubmeteregistro
, (select his.nmuser from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade141027113146417'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as investigador
, areadetec.tbs11 as areadetec, areaocor.tbs11 as areaocorrencia, classinic.tbs005 as classificini, catevent.tbs006 as catevento
, catraiz.tbs007 as catcausaraiz, equipo.tbs013 as equipamento
from DYNtds010 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs011 areadetec on areadetec.oid = form.OIDABC1moABCe0S
left join DYNtbs011 areaocor on areaocor.oid = form.OIDABCO2wABCqaO
left join DYNtbs005 classinic on classinic.oid = form.OIDABCCM0ABCSbb
left join DYNtbs006 catevent on catevent.oid = form.OIDABCV3fABC895
left join DYNtbs007 catraiz on catraiz.oid = form.OIDABChG0ABCjLn
left join DYNtbs013 equipo on equipo.oid = form.OIDABCx5sABCIJb
where wf.cdprocessmodel=17

--========================================================> Lista de arquivos de procurações
select cast(case when charindex('|', documentos) < 1
            then left(documentos, len(documentos))
            else left(documentos, charindex('|', documentos) - 2)
       end as varchar(255)) as arquivo1
, cast(case when charindex('|', substring(documentos, charindex('|', documentos)+2,len(documentos))) < 1
       then case when (charindex('|', documentos) < 1)
                then null 
                else left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)) 
            end
       else left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), charindex('|', substring(documentos, charindex('|', documentos)+2,len(documentos))) - 2)
  end as varchar(255)) as arquivo2
, cast(case when charindex('|', substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', substring(documentos, charindex('|', documentos)+2,len(documentos)))+2, len(documentos))) < 1
       then case when charindex('|', substring(documentos, charindex('|', documentos)+2,len(documentos))) < 1
                then null
                else left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), len(documentos))
            end
       else left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), charindex('|', substring(left(substring(documentos, charindex('|', documentos)+ 2, len(documentos)), len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos))) - 2)
  end as varchar(255)) as arquivo3
, cast(case when charindex('|',substring(left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', 
  left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), len(documentos))) + 2, 
  len(documentos))) < 1 
       then case when charindex('|', substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', substring(documentos, charindex('|', documentos)+2,len(documentos)))+2, len(documentos))) < 1 then null
    else left(substring(left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos))) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', 
  left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), len(documentos))) + 2, 
  len(documentos)), len(documentos)) end
       else left(substring(left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos))) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', 
  left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), len(documentos))) + 2, 
  len(documentos)), charindex('|',substring(left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), len(documentos)), charindex('|', 
  left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), len(documentos))) + 2, 
  len(documentos))) - 2)
  end as varchar(255)) as arquivo4
, cast(case when charindex('|', left(substring(left(substring(left(substring(documentos, charindex('|', documentos) + 2, 
  len(documentos)), len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, 
  len(documentos)), len(documentos)), charindex('|', left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, 
  len(documentos)), len(documentos))) + 2, len(documentos)), len(documentos))) < 1 
       then null
      else substring(left(substring(left(substring(left(substring(documentos, charindex('|', documentos) + 2, 
  len(documentos)), len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, 
  len(documentos)), len(documentos)), charindex('|', left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, len(documentos)), 
  len(documentos))) + 2, len(documentos)), len(documentos)), charindex('|', left(substring(left(substring(left(substring(documentos, charindex('|', documentos) + 2, 
  len(documentos)), len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, 
  len(documentos)), len(documentos)), charindex('|', left(substring(left(substring(documentos, charindex('|', documentos) + 2, len(documentos)), 
  len(documentos)), charindex('|', left(substring(documentos, charindex('|', documentos)+2, len(documentos)), len(documentos))) + 2, 
  len(documentos)), len(documentos))) + 2, len(documentos)), len(documentos))) + 2, len(documentos)) 
  end as varchar(255)) as arquivo5
from (
select substring((select ' | '+ rev.iddocument as [text()]
from  wfprocdocument wfd
inner join dcdocrevision rev on rev.cddocument = wfd.cddocument and cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument)
inner join wfprocess wf on wfd.idprocess = wf.IDobject
where wf.IDPROCESS = :idprocesso for XML path('')), 4, 4000) as documentos) _sub


--========================================================> Ações perdidas de plano de ação
--update gnactivity set fgstatus=3 where cdgenactivity = (
select cdgenactivity
--,fgstatus, CDEXECROUTE
from gnactivity where cdactivityowner = (select cdgenactivity from gnactivity where idactivity = 'IN-LAB-00110') and idactivity = '000001'
)

UPDATE GNAPPROVRESP SET FGPEND = 1, DTDEADLINE = GETDATE() + 7 WHERE CDPROD = 174 AND CDAPPROV = 47048 AND CDCYCLE = 6 AND FGPEND IS NULL;

select distinct (select idactivity from gnactivity where cdgenactivity = act.cdactivityowner) as plano, act.idactivity, act.nmactivity
from gnactivity act
inner join GNAPPROVRESP apr on apr.CDAPPROV = act.CDEXECROUTE and apr.CDCYCLE = (select max(apr1.cdcycle) from GNAPPROVRESP apr1 where apr1.cdprod = 174 and apr1.cdapprov = apr.cdapprov and 
                        exists (select 1 from GNAPPROVRESP apr2 where apr2.cdprod = 174 and apr2.cdapprov = apr1.cdapprov and FGPEND = 2))
where VLPERCENTAGEM=100 and fgstatus = 4


select act.idactivity, act.nmactivity, apr.*
from gnactivity act
inner join GNAPPROVRESP apr on apr.CDAPPROV = act.CDPLANROUTE and apr.CDCYCLE = (select max(apr1.cdcycle) from GNAPPROVRESP apr1 where apr1.cdprod = 174 and apr1.cdapprov = apr.cdapprov)
where act.idactivity = 'AN-CM-02696'

--update GNAPPROVRESP set fgpend = 1 where CDPROD=174 and      CDAPPROV=64142 and      CDCYCLE = 2

--====================> Usuário na estrutura de TI
select distinct usr.nmuser
, coordgs.itsm001 as coordresp
, left(depsetor.itsm001, charindex('_', depsetor.itsm001) -1) as depart
, right(depsetor.itsm001, len(depsetor.itsm001) - charindex('_', depsetor.itsm001)) as setor
from aduser usr
inner join aduserrole adru on adru.cduser = usr.cduser
inner join adrole adr on adr.cdrole = adru.cdrole and adr.CDROLEOWNER = 1404
inner join DYNitsm017 lgs on lgs.itsm001 = substring(adr.idrole, 1, coalesce(charindex('_', adr.idrole)-1, len(adr.idrole)))
inner join DYNitsm016 coordgs on coordgs.oid = lgs.OIDABCBSAGZNWY2N0Q
inner join DYNitsm020 depsetor on depsetor.oid = coordgs.OIDABCKIK9UXB5HNKT
where usr.idlogin = 'abeck'

--========================================================> inclui os membroe da equipe fonte na equipe destino sem repetição
insert into adteammember (cdteam,cdteammember,cduser,fgteammember)
select (select destino.cdteam from adteam destino where destino.idteam = 'DMA HUM_ACESSO IMP'), ROW_NUMBER() OVER (ORDER BY tm.cdteam,tm.cduser)
+(select coalesce(max(cdteammember),0) from adteammember where cdteam = (select destino.cdteam from adteam destino where destino.idteam = 'DMA HUM_ACESSO IMP')), tm.cduser, 4
from adteammember tm where tm.cdteam = (select fonte.cdteam from adteam fonte where fonte.idteam = 'EA HUM_ACESSO IMP') and 
tm.cduser not in (select cduser from adteammember where cdteam = (select destino.cdteam from adteam destino where destino.idteam = 'DMA HUM_ACESSO IMP'))

--========================> Update com SELECT
update gnrevision set FGVALIDITY = 3, QTVALIDITY = 5, DTVALIDITY = dateadd(yyyy, 5, gnrev.DTREVISION)
-- select rev.iddocument, gnrev.idrevision, gnrev.DTREVISION, gnrev.DTVALIDITY
from gnrevision gnrev
inner join dcdocrevision rev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on doc.cddocument = rev.cddocument
where (rev.cdcategory in (select cdcategory from dccategory where idcategory in ('1 - AF IN', '2 - FEME IN', '3 - MAE IN'))
and rev.fgcurrent = 1) and (doc.fgstatus not in (1,4) or doc.fgstatus = 4 or rev.cdrevision in (select max(cdrevision) from dcdocrevision where cddocument = rev.cddocument))

select * from gnrevision where cdrevision in (select cdrevision from dcdocrevision where iddocument = 'FEME-IN-000023')

--==========================================================
select 
 PRC.IDPROCESS as Identificador
,(
SELECT top 1 format(HIS.DTHISTORY, 'dd/MM/yyyy')
 FROM WFHISTORY HIS  
         			LEFT OUTER JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT 
         			LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT  
         			WHERE STR.IDSTRUCT='Atividade14102914347264' AND HIS.FGTYPE IN (9) and HIS.IDPROCESS =prc.idobject
order by HIS.DTHISTORY) as data_submissao
,(
SELECT top 1 format(HIS.DTHISTORY, 'dd/MM/yyyy')
 FROM WFHISTORY HIS  
         			LEFT OUTER JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT 
         			LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT  
         			WHERE STR.IDSTRUCT='Decisão14102914536874' AND HIS.FGTYPE IN (9) and HIS.IDPROCESS =prc.idobject
order by HIS.DTHISTORY) as data_aprovacao
 , gnrev.NMREVISIONSTATUS  
 
 FROM WFPROCESS PRC  
  INNER JOIN PMACTIVITY PP ON PP.CDACTIVITY = PRC.CDPROCESSMODEL  
  INNER JOIN PMACTTYPE PT ON PT.CDACTTYPE = PP.CDACTTYPE  
  LEFT OUTER JOIN GNREVISION GREV ON PRC.CDREVISION = GREV.CDREVISION  
  LEFT OUTER JOIN GNACTIVITY GNP ON (PRC.CDGENACTIVITY = GNP.CDGENACTIVITY)  
  LEFT OUTER JOIN GNEVALRESULTUSED GNRUS ON (GNRUS.CDEVALRESULTUSED = GNP.CDEVALRSLTPRIORITY) 
  LEFT OUTER JOIN GNEVALRESULT GNR ON (GNRUS.CDEVALRESULT = GNR.CDEVALRESULT)  
  INNER JOIN INOCCURRENCE INC ON (PRC.IDOBJECT = INC.IDWORKFLOW)   
  left outer join pbproblem pbp on (inc.cdoccurrence = pbp.cdoccurrence) 
  LEFT OUTER JOIN GNGENTYPE GNT ON (INC.CDOCCURRENCETYPE = GNT.CDGENTYPE)   
  LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)  
where PRC.CDGENACTIVITY = GNP.CDGENACTIVITY 
  and INC.IDWORKFLOW = PRC.IDOBJECT and idgentype ='TDS-CM' and gnrev.NMREVISIONSTATUS not in ('Aberto', 'Cancelado', 'Em avaliação', 'Em aceitação', 'Em aceitação - URGENTE')
--========================================================
--Paloma - Plano de ação
select CAST(gntype.IDGENTYPE + CASE WHEN gntype.IDGENTYPE IS NULL THEN NULL ELSE ' - ' END + gntype.NMGENTYPE AS VARCHAR(510)) AS tipoplano
, plano.idactivity as Plano, atv.idactivity as idAtividade, (select nmuser from aduser where cduser=atv.cduser) as executor
, atv.nmactivity as nomeAtividade, atv.VLPERCENTAGEM as porcentagem
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
, format((select DTFINISH from gnactivity where cdgenactivity = atv.cdgenactivity), 'dd/MM/yyyy') as dtrecebeu_paraaprovar
, format((select coalesce (dtfinish,dtfinishplan)+qtduetime from gnactivity where cdgenactivity = atv.cdgenactivity), 'dd/MM/yyyy') as dtprevaprov
, aprov.cdcycle, case when (select DTFINISH+qtduetime from gnactivity where cdgenactivity = atv.cdgenactivity) < getdate() then 'Atrasado' else 'Em dia' end as Prazo
, convert(varchar(10),aprov.dtapprov, 103) as dataaprova
, case when aprov.fgapprov = 1 then 'Aprovou a atividade' when aprov.fgapprov = 2 then 'Reprovou a atividade' end as aprovacao
, case when aprov.cdteam is null then (coalesce(aprov.nmuserapprov, nmuser)) when aprov.cdteam is not null then (select nmteam from adteam where cdteam = aprov.cdteam) end as aprovador
, cast(aprov.dsobs as varchar(4000)) as dsobs
--, iduseraprov, aprov.cdapprov, atv.cdgenactivity, actpl.cdactionplan, aprov.qtduetime
from gnactivity atv
inner join gnactivity plano on plano.cdgenactivity = atv.cdactivityowner
inner join gnactionplan actpl on atv.cdactivityowner = actpl.cdgenactivity
INNER JOIN GNGENTYPE gntype ON gntype.CDGENTYPE = actpl.CDACTIONPLANTYPE
inner join gnvwapprovresp aprov on aprov.cdapprov = atv.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
left join (select max(cdcycle) as maxcycle, cdapprov from gnvwapprovresp group by cdapprov) max_cycle
         on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where atv.CDISOSYSTEM in (174,160,202) and atv.cdactivityowner is not null and atv.fgstatus in (2,4)
order by tipoplano, plano.idactivity, atv.idactivity, atv.fgstatus, aprov.dtapprov, aprov.nmuserapprov

--========================================================> Solicitações de itens fora da quantidade permitida
select pla.tds012, sol.tds004, 
(select count(pla1.tds012)
from dyntds041 pla1
inner join DYNtds038 sol1 on pla1.OIDABCFHvABCauy = sol1.oid
where sol1.tds003 = 4 and sol.tds005 = 2 and pla1.tds012=pla.tds012) as tt
from dyntds041 pla
inner join DYNtds038 sol on pla.OIDABCFHvABCauy = sol.oid
where sol.tds003 = 4 and sol.tds005 = 2 and (select count(pla1.tds012)
from dyntds041 pla1
inner join DYNtds038 sol1 on pla1.OIDABCFHvABCauy = sol1.oid
where sol1.tds003 = 4 and sol.tds005 = 2 and pla1.tds012=pla.tds012) >1
order by pla.tds012,sol.tds004

select pla.tds012, sol.tds004
from dyntds041 pla
inner join DYNtds038 sol on pla.OIDABCFHvABCauy = sol.oid
where pla.tds012='18601'

--Listagem Completa:
select pla.tds012, act.idactivity as atividade, plac.idactivity as plano, sol.tds004,
(select count(pla1.tds012)
from dyntds041 pla1
inner join DYNtds038 sol1 on pla1.OIDABCFHvABCauy = sol1.oid
where sol1.tds003 = 4 and sol.tds005 = 2 and pla1.tds012=pla.tds012) as qtd
from dyntds041 pla
inner join DYNtds038 sol on pla.OIDABCFHvABCauy = sol.oid
inner join gnactivity act on act.cdgenactivity = pla.tds012
inner join gnactivity plac on plac.cdgenactivity = act.cdactivityowner
where pla.tds012 in (select pla.tds012 from dyntds041 pla
inner join DYNtds038 sol on pla.OIDABCFHvABCauy = sol.oid
where sol.tds003 = 4 and sol.tds005 = 2 and (select count(pla1.tds012)
from dyntds041 pla1
inner join DYNtds038 sol1 on pla1.OIDABCFHvABCauy = sol1.oid
where sol1.tds003 = 4 and sol.tds005 = 2 and pla1.tds012=pla.tds012) >1)
order by pla.tds012

--========================================================
--Suelen - CM
Select wf.idprocess , gnrev.NMREVISIONSTATUS
, (select his.dthistory from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Atividade14102914347264'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtsubmis
, (select his.dthistory from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102914536874'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtaprov
from wfprocess wf
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where cdprocessmodel=1
--============================================
--Cecilia - RM
Select wf.idprocess, gnrev.NMREVISIONSTATUS, form.tbs004 as dtrecebimento, wf.dtfinish as dtfechamento, nmprocess
, tbs012 as descricao, tbs007 as cod, tbs008 as prod, tbs009 as lote, tbs010 as dtfabricacao, motiv.tbs001 as motivreclam
, crit.tbs001 as critini, classific.tbs003 as classificacao, equipo.tbs001 as equiplinha, craiz.tbs001 as causaraiz
, (select his.dthistory from (SELECT top 1 HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct = 'Decisão14102992143534'
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
ORDER BY HIS.DTHISTORY desc, HIS.TMHISTORY desc) his) as dtaprovtais
from DYNtbs014 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs029 motiv on motiv.oid = form.OIDABCgbXABC9QU
left join DYNtbs028 crit on crit.oid = form.OIDABCsKPABCl6W
left join DYNtbs003 classific on classific.oid = form.OIDABCnRSABCmHu
left join DYNtbs020 equipo on equipo.oid = form.OIDABC2qCABCls2
left join DYNtbs022 craiz on craiz.oid = form.OIDABCspBABCWrH
where wf.cdprocessmodel=53
--Trocar executor de atividades do plano de ação
Select GNGNTP.IDGENTYPE,GNACT.*
from gnactivity GNACT
INNER JOIN GNTASK GNTK ON (GNACT.CDGENACTIVITY = GNTK.CDGENACTIVITY)  
LEFT OUTER JOIN GNTASKTYPE GNTKTP ON (GNTKTP.CDTASKTYPE = GNTK.CDTASKTYPE)  
LEFT OUTER JOIN GNGENTYPE GNGNTP ON  (GNGNTP.CDGENTYPE = GNTKTP.CDTASKTYPE) 
where GNACT.cdactivityowner in (select cdgenactivity from gnactivity where idactivity in
('TDS-DE-00372')) and GNGNTP.IDGENTYPE = 'TDS-008'
--
update gnactivity set cduser=1071
where gnactivity.cdgenactivity in (select GNACT.cdgenactivity
from gnactivity GNACT
INNER JOIN GNTASK GNTK ON (GNACT.CDGENACTIVITY = GNTK.CDGENACTIVITY)  
LEFT OUTER JOIN GNTASKTYPE GNTKTP ON (GNTKTP.CDTASKTYPE = GNTK.CDTASKTYPE)  
LEFT OUTER JOIN GNGENTYPE GNGNTP ON  (GNGNTP.CDGENTYPE = GNTKTP.CDTASKTYPE) 
where GNACT.cdactivityowner in (select cdgenactivity from gnactivity where idactivity in
('TDS-DE-00654')) and GNGNTP.IDGENTYPE = 'TDS-008')

--Lista os planos de ação
SELECT gnact.idactivity,gnact.DTFINISHPLAN
FROM   gnassocactionplan stpl
INNER JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan 
INNER JOIN gnactivity gnact ON gnpl.cdgenactivity = gnact.cdgenactivity 
WHERE  stpl.cdassoc = 36839


----------------------------------
--Seleciona instâncias dos processos
select wfs.fgstatus, wf.idprocess, wf.nmprocess, wf.idobject, wfs.nmstruct, format(wfs.dtestimatedfinish, 'dd/MM/yyyy') as dtestimatedfinish  from wfprocess wf inner join wfstruct wfs on wfs.idprocess = wf.idobject inner join wfactivity wfa on wfa.idobject = wfs.IDOBJECT where wf.fgstatus in (1,5) and wfs.fgstatus in (2,5) and wfs.FGTYPE in (2,3) and wfa.FGACTIVITYTYPE in (1,2) and wfs.idstruct<>'Atividade1576102552943' and wf.CDPROCESSMODEL = 53 union select wfs.fgstatus, wf.idprocess, wf.nmprocess, wf.idobject, wfs.nmstruct, format(wfs.dtestimatedfinish, 'dd/MM/yyyy') as dtestimatedfinish  from wfprocess wf inner join wfstruct wfs on wfs.idprocess = wf.idobject inner join wfactivity wfa on wfa.idobject = wfs.IDOBJECT where wf.fgstatus in (1,5) and (wfs.fgstatus = 3 and wfs.nmstruct='Verificar Plano de Ação') and  wfs.FGTYPE in (2,3) and wfa.FGACTIVITYTYPE in (1,2) and not exists (select wf1.idprocess from wfprocess wf1 inner join wfstruct wfs1 on wfs1.idprocess = wf1.idobject inner join wfactivity wfa1 on wfa1.idobject = wfs1.IDOBJECT where wf.fgstatus in (1,5) and wfs1.fgstatus in (2,5) and  wfs1.FGTYPE in (2,3) and wfa1.FGACTIVITYTYPE in (1,2) and wfs1.idstruct<>'Atividade1576102552943' and wf1.CDPROCESSMODEL = 53 and  wf1.idprocess = wf.idprocess) and wf.CDPROCESSMODEL = 53

--Seleciona Planos de ação relacionados aos processos selecionados
sql = "select gnact.cdgenactivity,gnact.idactivity,gnact.nmactivity,gnact.idactivity+' - '+gnact.nmactivity as Plano from gnassocactionplan stpl INNER JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan INNER JOIN gnactivity gnact ON gnpl.cdgenactivity = gnact.cdgenactivity WHERE stpl.cdassoc in (select gnp.cdassoc from wfprocess prc LEFT OUTER JOIN GNACTIVITY GNP ON (PRC.CDGENACTIVITY = GNP.CDGENACTIVITY) where gnact.FGSTATUS = 3 and idprocess in (select tds001 from dyntds042 where tds004 = '"+ idprocesso +"')) order by gnact.idactivity,gnact.nmactivity"

--Seleciona ações dos planos selecionados
gnact.FGSTATUS in (3,4) and 
--Status para Planos de ação
WHEN GNACT.FGSTATUS = 1 THEN 'Planejamento' 
 WHEN GNACT.FGSTATUS = 2 THEN 'Aprovação do planejamento' 
 WHEN GNACT.FGSTATUS = 3 THEN 'Execução' 
 WHEN GNACT.FGSTATUS = 4 THEN 'Verificação da eficácia' / 'Aprovação da execução'
 WHEN GNACT.FGSTATUS = 5 THEN 'Encerrada' 
 WHEN GNACT.FGSTATUS = 6 THEN 'Cancelado' 
 WHEN GNACT.FGSTATUS = 7 THEN 'Cancelado' 
 WHEN GNACT.FGSTATUS = 8 THEN 'Cancelado' 
 WHEN GNACT.FGSTATUS = 9 THEN 'Cancelado' 
 WHEN GNACT.FGSTATUS = 10 THEN 'Cancelado' 
 WHEN GNACT.FGSTATUS = 11 THEN 'Cancelado'
--===============================> Lista de elaboradores de documento
select distinct executor from (
select cat.idcategory, rev.iddocument--, rev.nmtitle, gnrev.idrevision,rev.cdrevision,rev.cddocument
--, case rev.fgcurrent when 1 then 'Vigente' when 2 then 'Obsoleta' end statusrev
--, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' when 7 then 'Contrato encerrado' end statusdoc
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
left join GNREASON moti on moti.cdreason = gnrev.CDREASON
where rev.fgcurrent = 1 and stag.FGSTAGE = 1 and cat.idcategory in ('1 - POP HUM BSB', '2 - AVAL HUM BSB', '3 - FORM HUM BSB', '1 - POP VET BSB', '2 - AVAL VET BSB', '3 - FORM VET BSB')
--order by cat.idcategory, rev.iddocument, stag.NRCYCLE, stag.FGSTAGE, stag.NRSEQUENCE
) __subq
where executor in (select nmuser from aduser where fguserenabled = 1 and cduser in (select cduser from aduserdeptpos where cddepartment in (select cddepartment from addepartment where cdcompanies = 2)))
--===================================> Insert de usuários na lista de treinamento
insert into TRTRAINUSER
(CDTRAINUSER,CDTRAIN,CDUSER,CDTRAINSOLIC,CDUSERENROLL,NRORDER,
DSCOMMENTS,VLEVALPRE,DSEVALPRE,VLEVALREACTION,DSEVALREACTION,
VLEVALFREQ,VLEVAL,FGEVALRESULT,DSEVAL,VLEVALPOS,FGPOSRESULT,
DSEVALPOS,VLFREQ,VLNOTE,FGRESULT,FGPEND,DTPENDRES,DTPENDENROLL,
DTINSERT,DTUPDATE,NMUSERUPD)
values((select max(cdtrainuser)+1 from TRTRAINUSER),(select cdtrain from TRTRAINing where idtrain = 'TDS-TRE-0000014'),1548
, null,1548, (coalesce((select max(nrorder)+1 from TRTRAINUSER where cdtrain = (select cdtrain from TRTRAINing where idtrain = 'TDS-TRE-0000014')), 1))
, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 3, null, getdate(), getdate()
, null, 'Alvaro Adriano Beck')
--=============================>> Paloma - Atividades de certos executores com aprovadores e ciclos.
select (select idactivity from gnactivity where cdgenactivity = gnact.cdactivityowner) Plano
, gnact.idactivity, gnact.nmactivity
,usr.nmuser as executor, case gnact.fgstatus when 5 then 'Encerrada' when 1 then 'Planejamento' when 3 then 'Execução'
else cast(gnact.fgstatus as varchar(1)) end Status
,aprov.cdcycle, convert(varchar(10),aprov.dtapprov, 103) as dataaprova
,case
when aprov.cdteam is null then (select nmuser from aduser where cduser = aprov.cduserapprov)
when aprov.cdteam is not null then (select nmteam from adteam where cdteam = aprov.cdteam)
end as aprovador
from gnactivity gnact
LEFT OUTER JOIN aduser usr ON gnact.cduser = usr.cduser
left join gnactionplan actpl on gnact.cdactivityowner = actpl.cdgenactivity
left join gnvwapprovresp aprov on aprov.cdapprov = gnact.cdexecroute and cdprod=174
      and ((aprov.fgpend = 2 and aprov.fgapprov=1) or (aprov.fgpend = 1) or (fgpend is null and fgapprov is null))
left join (select max(cdcycle) as maxcycle, cdapprov
      from gnvwapprovresp
      group by cdapprov) max_cycle on aprov.cdapprov = max_cycle.cdapprov and aprov.cdcycle = max_cycle.maxcycle
where gnact.cdactivityowner is not null --and aprov.nmuserapprov is not null
and usr.cduser in (1050,1075,1486,1123) and (gnact.dtfinishplan > '2015-11-1' and gnact.dtfinishplan < '2015-12-31')
order by Plano, gnact.idactivity

--========================================> Lista de usuários que podem aprovar TI-GA e são de 0010
select usr.idlogin, usr.nmuser
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and fgdefaultdeptpos = 1
where usr.fguserenabled = 1
and exists (select 1 from aduserdeptpos rel1
     inner join addepartment dep1 on dep1.cddepartment = rel1.cddepartment where rel1.cduser = usr.cduser and dep1.cddeptowner = 326)
and exists (select 1 from aduseraccgroup acc where acc.cduser = usr.cduser and acc.cdgroup = 40)
and rel.cdposition in (select cdposition from adposition  where
                    nmposition like '%Gerente%' 
                    or nmposition like '%Coorden%' 
                    or nmposition like '%Dir%' 
                    or nmposition like '%Supe%' 
                    or nmposition like '%MANA%' 
                    or nmposition like '%QUALITY SITE%' 
                    or nmposition like '%lead%'  
                    or nmposition like '%dire%' 
                    or nmposition like '%accou%'  
                    or nmposition like '%Nur%'  
                    or nmposition like '%spec%' 
                    or nmposition like '%eng%' 
                    or nmposition like '%techn%'
            ) 
--=========================================> Lista de grupos de acesso faltantes UA (Tripp)
select * from (
select usr.idlogin
, case when usr.cduser not in (select uacc.cduser
from aduseraccgroup uacc
where uacc.cdgroup = 36 or uacc.cdgroup = 37 or uacc.cdgroup = 69)
then 'TRE_ONLINE' end as missing
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join addepartment unid on unid.cddepartment = dep.cddeptowner and dep.cddeptowner = 326
where usr.FGUSERENABLED = 1
                                    union all
select usr.idlogin
, case when usr.cduser not in (select uacc.cduser
from aduseraccgroup uacc
where uacc.cdgroup = 29)
then 'DOC_CONS' end as missing
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
inner join addepartment unid on unid.cddepartment = dep.cddeptowner and dep.cddeptowner = 326
where usr.FGUSERENABLED = 1
) sub
where sub.missing is not null
--select * from adaccessgroup

--=====================================> Roberton - Lita de Elaboradores dos POPs
select case when doc.fgstatus = 1 then 'Emissão' when doc.fgstatus = 2 then 'Homologado' when doc.fgstatus = 3 and rev.FGCURRENT = 1 then 'Homologado' when doc.fgstatus = 3 and rev.FGCURRENT = 2 then 'Revisão' end statusdoc
, rev.iddocument, rev.nmtitle, gnrev.idrevision, format(gnrev.dtrevrelease,'dd/MM/yyyy') as dtrevrelease
, usr.nmuser
--, case stag.FGSTAGE when 1 then 'Elaborador' when 2 then 'Consensador' when 3 then 'Aprovador' when 4 then 'Homologador' end Fase
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on doc.cddocument = rev.cddocument
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
left join aduser usr on usr.cduser = stag.cduser
left join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS=1
left join addepartment dep on dep.cddepartment = rel.cddepartment and cdcompanies = 7
where rev.cdcategory in (37) and stag.FGSTAGE = 1
and stag.nrcycle = (select max(stag1.nrcycle) from GNREVISIONSTAGMEM stag1 where stag.cdrevision = stag1.cdrevision and stag.fgstage = stag1.fgstage)
and (rev.FGCURRENT = case doc.fgstatus 
                        when 1 then 2
                        when 3 then 1
                        else 1
                    end
or (rev.FGCURRENT = case doc.fgstatus 
                        when 1 then 2
                        when 3 then 2
                        else 1
                    end
    and rev.cdrevision = (select max(doc1.cdrevision) from dcdocrevision doc1 where doc.cddocument = doc1.cddocument)
))
order by rev.iddocument,gnrev.idrevision, stag.FGSTAGE, stag.nrsequence

--=====================================> Karine - tempo entre aceitação e aprovação (leadtime)
select wf.idprocess
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) as dtaceita
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
)) his) as dtaprovGQ
,datediff(dd,
(select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his),
(case when (select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) is null then getdate() else (select HIS.DTHISTORY from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
)) his) end)) as tempo
from wfprocess wf
where cdprocessmodel=1
and (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) his) is not null
--================================> Grupos de acesso
select cduser from aduser
where nmuser in ('Leonardo Torres Pereira','Amaro Arialdo de Souza Júnior','Anderson Americo Schunck Pereira','Anderson Maranhão Icassatti','Carlos Eduardo de Arruda Longo Filho','Carlos Eduardo dos Santos Coutinho','Carlos Henrique Rocha Oliveira','Carolina Guimarães Brandão','Cláudio Roberto Martareli','Cléo Aparecido de Camargo','Daniel Francisco de Freitas Otaviano','Daniel Geraldo de Araújo','Daniela Batista de Paiva','Daniela Doria de Oliveira Santos','Danilo Silvério Nunes','Debora Patricia Pereira da Silva','Dejalma Batista de Souza Junior','Douglas Loureiro','Durval Fernandes de Almeida Junior','Elaine Cristina Mesquita','Emanuella Sousa Teles Monteiro','Fabiano Bitencourt Leal Barbosa','Fabio Kuniaki Andrade','Fernanda Coelho da Fonseca Deliao Harada','Fernanda de Carvalho Pedace Azevedo','Fernanda Marques','Fernando Antonio Aguiar Ribeiro','Fernando Augusto Schalch Belasco','Fernando Eustaquio de Freitas','Graziela de Fátima Andrade','Gustavo Almeida Aiello','Heder Anibal Goncalves','Hugo Cesar Ferreira de Araújo','Ize Scarso','João Batista Bernardes','João Ladeia de Oliveira','João Luiz Tondolo','Jorge Eduardo Quental de Barros','José Gomes de Amorim Junior','Jose Luiz Anacleto','José Luiz Junqueira Simões','Juarez dos Santos Gonçalves','Juliana Olivia F. Loureiro dos Santos Martins','Leonardo Leão Delfino','Luiz Felipe Lessa Azevedo Ribeiro','Marcos Pierre de Moraes Oliveira','Marcus Antonio Dias de Oliveira','Marília de Cássia Martins','Mário de Sousa Teixeira Bueno','Patricia Rosana de Souza','Paula Melo Suzana','Paula Rocha França','Roberto Gonçalves Ribeiro','Rogerio Berganini Ramos','Rosangela Trindade Mendonca Gerardi','Teresa Cristina Bonado Mattos','Vanessa Marques Carmo')
and cduser not in (select cduser from ADUSERACCGROUP where cdgroup in (28) --5,8,28,29)
)
--select * from ADUSERACCGROUP where cdgroup in (5,8,28,29)
--select * from ADUSERACCGROUP where cdgroup in (5) and cduser = 156
--select * from adaccessgroup where idgroup like 'in%'
--select * from aduser where cduser=1702

--==============================> Pessoal de uma Unidadeque tem grupo de acesso DOC
select nmuser from aduser where cduser in (select cduser from aduserdeptpos where cddepartment in (
select cddepartment from addepartment where cdcompanies=5)) and cduser in (
select cduser from aduseraccgroup where cdgroup in (select cdgroup from adaccessgroup where idgroup like 'DOC%'))

--===============================> Ad-hocs de RM (novas)
select * from (
Select wf.idprocess, wf.nmprocess, gnact.nmactivity
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
--, gnactowner.nmactivity as nmactowner
, format(gnact.dtstart,'dd/MM/yyyy') as data_ini, format(gnact.dtfinish,'dd/MM/yyyy') as data_fim
, datediff(DD, gnact.dtstart, coalesce(gnact.dtfinish, getdate())) as tempo
from DYNtds014 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs001 unid on unid.oid = form.OIDABCaWMABCqnd
left join WFSTRUCT wfs on wf.idobject = wfs.idprocess
inner join wfactivity wfa on wfs.idobject = wfa.IDOBJECT and wfa.FGACTIVITYTYPE=3
left join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
left join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
where wf.cdprocessmodel=53
) sub where sub.nmactivity like '%Produção%'

--=====================================> Leadtime de CM (Raisa)
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
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
)) is not null then cast(1+(SELECT STR.DTEXECUTION
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
)) - (SELECT STR.DTEXECUTION --WFA.dtstart
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) as integer) else
cast(1+ getdate() - (SELECT STR.DTEXECUTION --WFA.dtstart
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) as integer) end tempoaprov
from DYNtbs015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs039 areamud on areamud.oid = form.OIDABCQueABCNDM
left join DYNtbs039 areaini on areaini.oid = form.OIDABC3a2ABCLSW
left join DYNtbs001 unid on unid.oid = form.OIDABCTYWABCE9z
where cdprocessmodel=1
union
Select wf.idprocess, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
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
)) is not null then cast(1+(SELECT STR.DTEXECUTION
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
)) - (SELECT STR.DTEXECUTION --WFA.dtstart
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) as integer) else
cast(1+ getdate() - (SELECT STR.DTEXECUTION --WFA.dtstart
FROM WFHISTORY HIS
inner JOIN WFSTRUCT STR ON HIS.IDSTRUCT=STR.IDOBJECT and str.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA ON STR.IDOBJECT = WFA.IDOBJECT
WHERE  HIS.FGTYPE IN (9) and his.idprocess = wf.idobject
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
inner JOIN WFSTRUCT STR1 ON HIS1.IDSTRUCT=STR1.IDOBJECT and str1.idstruct in ('Atividade14102914355828','Atividade1518102355189')
LEFT OUTER JOIN WFACTIVITY WFA1 ON STR1.IDOBJECT = WFA1.IDOBJECT
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject
)) as integer) end tempoaprov
from DYNtds015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs039 areamud on areamud.oid = form.OIDABCk8DABCghk
left join DYNtbs001 unid on unid.oid = form.OIDABCVrhABCPrY
where cdprocessmodel=1

--==========================================> Erro na impressão do relatório de Treinamento (registros duplicados)
-- Verificar duplicidade comum:
--select cduser,idlogin from aduser where idlogin='vgiraldi'
select tu1.CDTRAINUSER, tr1.cdtrain, tr1.idtrain, tu1.cduser, usr.nmuser, tr1.DTINSERT
from trtraining tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain
inner join aduser usr on usr.cduser = tu1.cduser
where (select count(*)
from trtraining tr2
inner join TRTRAINUSER tu2 on tu2.cdtrain = tr1.cdtrain and tu2.cduser = tu1.cduser
where tr1.cdtrain = tr2.cdtrain) > 1

--========================================> Lista de usuários com login (desativado) que receberam crédito.
SELECT distinct(USU.IDUSER)
FROM TRCOURSE C,GNGENTYPE GN,TRTRAINUSER TU,ADUSER USU, TRCONFIGURATION TCONF , TRTRAINING T
WHERE T.CDCOURSE=C.CDCOURSE AND C.CDCOURSETYPE = GN.CDGENTYPE AND T.CDTRAIN=TU.CDTRAIN AND TU.CDUSER=USU.CDUSER 
AND T.CDCONFIGURATION = TCONF.CDCONFIGURATION AND T.FGSTATUS > 4
AND  ((EXISTS (SELECT 1 FROM GNTYPEROLE GNROLE_ALIAS WHERE GNROLE_ALIAS.CDTYPEROLE = GN.CDTYPEROLE AND GNROLE_ALIAS.FGTYPE = 1)) 
      OR ( EXISTS (SELECT 1 FROM GNTYPEPERMISSION GNROLEDEF_ALIAS WHERE GNROLEDEF_ALIAS.CDTYPEROLE = GN.CDTYPEROLE
                   AND GNROLEDEF_ALIAS.CDACCESSLIST = 1 AND GNROLEDEF_ALIAS.CDUSER = 1548 )
OR NOT EXISTS(SELECT 1 FROM GNTYPEPERMISSION WHERE CDACCESSEDIT =1 AND CDACCESSLIST = 1 AND CDTYPEROLE =GN.CDTYPEROLE)))
AND UPPER(USU.IDLOGIN) LIKE UPPER('%desativado%')

--============================> Adhocs finalizadas nos últimos 45 minutos
select gnact.fgstatus, gnactowner.fgstatus, wfa.nmuser as exe_adh, wfao.nmuser as exe_owner, wfp.idprocess, gnact.nmactivity, gnactowner.nmactivity as nmactowner, usr.dsuseremail
from wfactivity wfa
inner join WFSTRUCT wfs on wfs.idobject = wfa.IDOBJECT
inner join WFPROCESS wfp on wfp.idobject = wfs.idprocess
inner join gnactivity gnact on gnact.cdgenactivity=wfa.cdgenactivity
inner join gnactivity gnactowner on gnactowner.cdgenactivity = gnact.cdactivityowner
inner join wfactivity wfao on gnactowner.cdgenactivity=wfao.cdgenactivity
inner join aduser usr on usr.cduser = wfao.cduser
where wfa.FGACTIVITYTYPE=3 and wfp.cdprocessmodel = 5251 and gnact.fgstatus = 5 and gnactowner.fgstatus = 3 and 
(select exeadhoc.dthistory + exeadhoc.tmhistory from (SELECT top 1 HIS.DTHISTORY, HIS.TMHISTORY
    FROM WFHISTORY HIS
    Where HIS.IDSTRUCT = wfs.IDOBJECT
    AND HIS.FGTYPE IN (9)
    ORDER BY HIS.DTHISTORY, HIS.TMHISTORY) exeadhoc) > dateadd(mi,-46,getdate())

--=====================> Exclui usuários da licença BASIC se estiverem nos grupos PACK_EXE e PACK_CONS
delete
from aduseraccgroup
where cdgroup = 0 and 
cduser in ( 
select usr.cduser
from aduser usr
where exists (select 1 from aduseraccgroup accg where accg.cduser = usr.cduser and accg.cdgroup = 40) and
exists (select 1 from aduseraccgroup accg where accg.cduser = usr.cduser and accg.cdgroup = 41)
)
--========================================> Desassociar planos de ação de um processo--
select cdgenactivity from wfprocess where idprocess = 'ANVTRM160503133514'
--2
select *
from gnactivity gnact
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
where gnact.CDGENACTIVITY=122998
--3
select * from gnassocactionplan stpl where stpl.cdassoc = 73005
--4
select cdgenactivity from gnactionplan gnpl where gnpl.cdactionplan = 2698
--5
--delete from gnactionplan where cdactionplan = 2698
--delete from gnassocactionplan where cdassoc = 73005 and CDASSOCACTIONPLAN=2631 and cdactionplan=2698

--==================================> Textos de CM.
Select wf.idprocess as numero_cm, format(wf.dtstart,'dd/MM/yyyy') as dtabertura
, cast(form.tds008 as varchar(4000)) as sit_atual, cast(form.tds009 as varchar(4000)) as sit_proposta, cast(form.tds010 as varchar(4000)) as motivo
from DYNtds015 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join DYNtbs039 areamud on areamud.oid = form.OIDABCk8DABCghk
left join DYNtbs001 unid on unid.oid = form.OIDABCVrhABCPrY
where cdprocessmodel=1 and wf.dtstart > '2016/01/01'

--=================================> Quantidade de documentos trabalhados por pessoa
select _sub.executor, _sub.fase, count(*) as quantidade
from (select cat.idcategory +' - '+ cat.nmcategory as Categoria, rev.iddocument, rev.nmtitle, gnrev.idrevision
, rev.cdrevision, rev.cddocument,FGCURRENT
, case rev.fgcurrent when 1 then 'Vigente' when 2 then 'Obsoleta' end statusrev
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' when 7 then 'Contrato encerrado' end statusdoc
, moti.nmreason as motivorev
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.NRCYCLE as ciclo, stag.dtdeadline, stag.qtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
, format(stag.dtapproval,'dd/MM/yyyy') as dtexecut
, case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
INNER JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.CDUSER IS NOT NULL
left join GNREASON moti on moti.cdreason = gnrev.CDREASON
where rev.cdcategory in (select cdcategory from dccategory where idcategory in ('1 - POP TDS'))
and (stag.dtapproval >= '2016-06-01' and stag.dtapproval <= '2016-06-30')) _sub
group by _sub.executor, _sub.fase
with rollup
order by executor,fase

--========================================> Encerramentos MEP
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento
, form.crp043 as desligado
from DYNrhcp1 form
inner join GNFORMREG reg on reg.OIDENTITYREG = form.OID
inner join GNFORMREGGROUP grop on grop.CDFORMREGGROUP = reg.CDFORMREGGROUP
inner join WFPROCESS wf on wf.CDFORMREGGROUP = grop.CDFORMREGGROUP
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join aduser usr on usr.cduser = wf.CDUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
where form.crp001=4

--==================================> Postos de cópia seus documentos
select cps.idcopystation, cps.nmcopystation, rev.iddocument, rev.nmtitle
from DCCOPYSTATION cps
inner join DCDOCCOPYSTATION cpsdoc on cpsdoc.cdcopystation = cps.cdcopystation
inner join dcdocrevision rev on rev.cdrevision = cpsdoc.cdrevision and rev.fgcurrent=1
where cps.cdcopystationowner=189

--================================================> Usuários deposnsáveis por recebimento dos postos
select distinct cdestacao, estacao, cdresp, resp
from (
select cs.CDCOPYSTATION as cdestacao,cs.nmcopystation as estacao,cs.CDRECEIVERESP as cdresp,usr.nmuser as resp
from dccopystation cs
inner join aduser usr on usr.cduser = cs.CDRECEIVERESP
union all
select csr.cdcopystation as cdestacao,cs.nmcopystation as estacao, csr.cduser as cdresp, usr.nmuser as resp
from dccopystation cs
inner join DCCOPYSTATIONRESP csr on csr.cdcopystation = cs.cdcopystation
inner join aduser usr on usr.cduser = csr.CDuser
) _sub
order by 1,2

--============================> Excluir e-mails aguardando envio

_DELETE select * FROM ADMAILATTACHMENT WHERE CDMAILHISTORY IN (SELECT B.CDMAILHISTORY FROM ADMAILHISTORY B WHERE B.FGSTATUSMAIL <> 1 and b.NMTITLE like '%Aprovação de solicitação%');

_DELETE select * FROM ADMAILHISTORYLOG WHERE CDMAILHISTORY IN (SELECT B.CDMAILHISTORY FROM ADMAILHISTORY B WHERE B.FGSTATUSMAIL <> 1 and b.NMTITLE like '%Aprovação de solicitação%');

_DELETE select * FROM ADMAILHISTORY WHERE FGSTATUSMAIL <> 1 and NMTITLE like '%Aprovação de solicitação%' AND NOT EXISTS ( SELECT 1 FROM ADMAILHISTORYLOG B WHERE B.CDMAILHISTORY = ADMAILHISTORY.CDMAILHISTORY);
_DELETE select * FROM ADMAILHISTORYLOG WHERE CDMAILHISTORY IN (SELECT B.CDMAILHISTORY FROM ADMAILHISTORY B WHERE B.FGSTATUSMAIL <> 1 and b.NMTITLE like '%Aprovação de solicitação%');

_DELETE select * FROM ADMAILHISTORYLOG WHERE CDMAILHISTORY IN (SELECT CDMAILHISTORY FROM ADMAILHISTORY ADM WHERE ((ADM.FGSTATUSMAIL = 2 AND (SELECT COUNT(*) FROM ADMAILHISTORYLOG ADL WHERE ADL.CDMAILHISTORY=ADM.CDMAILHISTORY) < 3) OR ADM.FGSTATUSMAIL= 3) AND ADM.FLCONTENT IS NOT NULL); 

_DELETE select * FROM ADMAILATTACHMENT WHERE CDMAILHISTORY IN (SELECT CDMAILHISTORY FROM ADMAILHISTORY ADM WHERE ((ADM.FGSTATUSMAIL = 2 AND (SELECT COUNT(*) FROM ADMAILHISTORYLOG ADL WHERE ADL.CDMAILHISTORY=ADM.CDMAILHISTORY) < 3) OR ADM.FGSTATUSMAIL= 3) AND ADM.FLCONTENT IS NOT NULL); 

_DELETE select * FROM ADMAILHISTORY WHERE CDMAILHISTORY IN (SELECT CDMAILHISTORY FROM ADMAILHISTORY ADM WHERE ((ADM.FGSTATUSMAIL = 2 AND (SELECT COUNT(*) FROM ADMAILHISTORYLOG ADL WHERE ADL.CDMAILHISTORY=ADM.CDMAILHISTORY) < 3) OR ADM.FGSTATUSMAIL= 3) AND ADM.FLCONTENT IS NOT NULL); 

--==============================================================> Permissão nos documentos (adilson)
SELECT 
    DREV.IDDOCUMENT,
        DREV. NMTITLE,
   CASE 
        WHEN FGACCESSTYPE = 1 THEN 'Equipe'
        WHEN FGACCESSTYPE = 2 THEN 'Área' 
        WHEN FGACCESSTYPE = 3 THEN 'Área/Função'
        WHEN FGACCESSTYPE = 4 THEN 'Função'
        WHEN FGACCESSTYPE = 5 THEN 'Usuário' 
        WHEN FGACCESSTYPE = 6 THEN 'Todos' 
        WHEN FGACCESSTYPE = 7 THEN 'Usuário de inclusão' 
        WHEN FGACCESSTYPE = 8 THEN 'Área/Função usuário de inclusão'
        WHEN FGACCESSTYPE = 9 THEN 'Função usuário de inclusão'
        WHEN FGACCESSTYPE = 10 THEN 'Área usuário de inclusão'
    END AS tipo_acesso,
    NMDEPARTMENT AS area,
    NMPOSITION AS funcao,
    NMUSER AS usuario,
    NMTEAM AS EQUIPE,
    CASE 
        WHEN FGPERMISSION = 1 THEN 'Permitir'
        ELSE 'Negar'
    END AS tipo_permissao, 
    CASE 
        WHEN FGACCESSEDIT = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_ALTERACAO, 
    CASE 
        WHEN FGACCESSDELETE = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_EXCLUSAO , 
    CASE 
        WHEN FGACCESSKNOW = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_CONHECIMENTO , 
    CASE 
        WHEN FGACCESSTRAIN = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_TREINAMENTO , 
    CASE 
        WHEN FGACCESSVIEW = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_VISUALIZACAO , 
    CASE 
        WHEN FGACCESSPRINT = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_IMPRIMIR , 
    CASE 
        WHEN FGACCESSPHYSFILE = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_ARQUIVAMENTO , 
    CASE 
        WHEN FGACCESSREVISION = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_REVISAR , 
    CASE 
        WHEN FGACCESSCOPY = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_DISTRIBUIR_COPIA , 
    CASE 
        WHEN FGACCESSREGTRAIN = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_REGISTRAR_TREINAMENTO , 
    CASE 
        WHEN FGACCESSCANCEL = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_CANCELAR , 
    CASE 
        WHEN FGACCESSSAVE = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_SALVAR_LOCALMENTE , 
    CASE 
        WHEN FGACCESSSIGN = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_ASSINAR , 
    CASE 
        WHEN FGACCESSNOTIFY = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_NOTIFICACAO , 
    CASE 
        WHEN FGADDLOWERLEVEL = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_INCLUIR_SUBNIVEIS , 
    CASE 
        WHEN FGACCESSEDITKNOW = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_AVALIAR_APLICABILIDADE , 
    CASE 
        WHEN FGACCESSADDCOMMENT = 1 THEN 'Sim'
        ELSE 'Não'
    END AS PERMISSAO_INSERIR_COMENTARIO 
FROM DCDOCACCESSROLE DCR 
    LEFT OUTER JOIN ADDEPARTMENT DEP ON (DCR.CDDEPARTMENT = DEP.CDDEPARTMENT)
    LEFT OUTER JOIN ADPOSITION POS ON (DCR.CDPOSITION = POS.CDPOSITION)
    LEFT OUTER JOIN ADUSER USU ON (DCR.CDUSER = USU.CDUSER)
    LEFT OUTER JOIN ADTEAM TEA ON (DCR.CDTEAM = TEA.CDTEAM)
    INNER JOIN DCDOCREVISION DREV ON (DCR.CDDOCUMENT = DREV.CDDOCUMENT)
ORDER BY NRSEQUENCE

--=======================> Revisão de acesso

select _sub.*
, case when usr.idlogin = 'sesuite_conf' then 'Todos' else usr.idlogin end as idlogin
, case when usr.idlogin = 'sesuite_conf' then 'Todos' else usr.nmuser end as nmuser
, case when usr.idlogin = 'sesuite_conf' then 1 else usr.fguserenabled end as fguserenabled
, case when usr.idlogin = 'sesuite_conf' then 'N/A' else pos.nmposition end as nmposition
, case when usr.idlogin = 'sesuite_conf' then 'N/A' else dep.nmdepartment end nmdepartment
from (
/* Lista de Roles */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-cm'
union all
/* Aprovadores GQ-ACESSO */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Aprovação VSC' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join (Select * from DYNuq055) adro on adro.ac004 is not null
inner join adrole adr on adr.idrole = adro.ac004
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'GQ-ACESSO'
union all
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Aprovação Técnica' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join (Select * from DYNuq055) adro on adro.ac004 is not null
inner join adrole adr on (adr.idrole = adro.ac002 or adr.idrole = adro.ac005)
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'GQ-ACESSO'
union all
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Operador do Sistema' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join (Select * from DYNuq055) adro on adro.ac004 is not null
inner join adrole adr on adr.idrole = adro.ac003
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'GQ-ACESSO'
union all
/* Aprovadores de CM */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole in (select cdrole from adrole where cdroleowner in (select cdrole from adrole where substring(idrole, charindex('-', idrole), len(idrole)) = '-CM_APR'))
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-cm' and adr.idrole like case when pmap.idactivity = 'tds-cm' then 'an-cm_apr-%' else substring(pmap.idactivity, 1, 2) +'-cm_apr-%' end
union all
/* Gestores */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Gestor do processo' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
where pmp.fgprocenabled = 1
and pmap.fgstatus < 3
and pmap.idactivity = 'in-cm'
union all
/* Segurança do processo */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, qqq.qqnm as quem
, substring((select ' | '+ NMACCESSROLEFIELD as [text()] from PMPROCSECURITYCTRL pmps1 inner join PMACCESSROLEFIELD pmpsn1 on pmpsn1.cdACCESSROLEFIELD = pmps1.cdACCESSROLEFIELD and pmpsn1.FGOBJECTTYPE > 0
where pmps1.cdproc = pmpac.cdproc and pmps1.cdaccesslist = pmpac.cdaccesslist for XML path('')), 4, 4000) as acesso, pmpac.FGPERMISSION as tpacesso
, substring(qqq.qqnm, 1, charindex(' ', qqq.qqnm)) as idqq
, case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
where pmp.fgprocenabled = 1 and pmap.fgstatus < 3
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 00 or pmpac.cdteam is null)
and pmap.idactivity = 'in-cm'
union all
/* Lilsta de Aprovadores (Sistema/Area) GQ-Acesso */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, 'Lista - DYNuq057 - AC003' as quem, 'Aprovação - Responsável pelo Sistema/Área' as acesso
, 1 as tpacesso
, 'DYN057' as idqq, 3 as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 4
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'GQ-ACESSO' and pmap.idactivity = 'GQ-ACESSO'

union all

/* Lista de Roles */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-de'
union all
/* Investigadores de DE */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole in (select cdrole from adrole where substring(idrole, charindex('-', idrole), len(idrole)) = '-DE_INV')
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-de' and adr.idrole like case when pmap.idactivity = 'tds-de' then 'an-de_inv' else substring(pmap.idactivity, 1, 2) +'-de_inv' end
union all
/* Gestores */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Gestor do processo' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
where pmp.fgprocenabled = 1
and pmap.fgstatus < 3
and pmap.idactivity = 'in-de'
union all
/* Segurança do processo */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, qqq.qqnm as quem
, substring((select ' | '+ NMACCESSROLEFIELD as [text()] from PMPROCSECURITYCTRL pmps1 inner join PMACCESSROLEFIELD pmpsn1 on pmpsn1.cdACCESSROLEFIELD = pmps1.cdACCESSROLEFIELD and pmpsn1.FGOBJECTTYPE > 0
where pmps1.cdproc = pmpac.cdproc and pmps1.cdaccesslist = pmpac.cdaccesslist for XML path('')), 4, 4000) as acesso, pmpac.FGPERMISSION as tpacesso
, substring(qqq.qqnm, 1, charindex(' ', qqq.qqnm)) as idqq
, case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
where pmp.fgprocenabled = 1 and pmap.fgstatus < 3
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 00 or pmpac.cdteam is null)
and pmap.idactivity = 'in-de'

union all

/* Lista de Roles */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-lab'
union all
/* Gestores */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Gestor do processo' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
where pmp.fgprocenabled = 1
and pmap.fgstatus < 3
and pmap.idactivity = 'in-lab'
union all
/* Segurança do processo */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, qqq.qqnm as quem
, substring((select ' | '+ NMACCESSROLEFIELD as [text()] from PMPROCSECURITYCTRL pmps1 inner join PMACCESSROLEFIELD pmpsn1 on pmpsn1.cdACCESSROLEFIELD = pmps1.cdACCESSROLEFIELD and pmpsn1.FGOBJECTTYPE > 0
where pmps1.cdproc = pmpac.cdproc and pmps1.cdaccesslist = pmpac.cdaccesslist for XML path('')), 4, 4000) as acesso, pmpac.FGPERMISSION as tpacesso
, substring(qqq.qqnm, 1, charindex(' ', qqq.qqnm)) as idqq
, case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
where pmp.fgprocenabled = 1 and pmap.fgstatus < 3
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 00 or pmpac.cdteam is null)
and pmap.idactivity = 'in-lab'

union all

/* Lista de Roles */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-rm'
union all
/* Gestores */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Gestor do processo' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
where pmp.fgprocenabled = 1
and pmap.fgstatus < 3
and pmap.idactivity = 'in-rm'
union all
/* Segurança do processo */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, qqq.qqnm as quem
, substring((select ' | '+ NMACCESSROLEFIELD as [text()] from PMPROCSECURITYCTRL pmps1 inner join PMACCESSROLEFIELD pmpsn1 on pmpsn1.cdACCESSROLEFIELD = pmps1.cdACCESSROLEFIELD and pmpsn1.FGOBJECTTYPE > 0
where pmps1.cdproc = pmpac.cdproc and pmps1.cdaccesslist = pmpac.cdaccesslist for XML path('')), 4, 4000) as acesso, pmpac.FGPERMISSION as tpacesso
, substring(qqq.qqnm, 1, charindex(' ', qqq.qqnm)) as idqq
, case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
where pmp.fgprocenabled = 1 and pmap.fgstatus < 3
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 00 or pmpac.cdteam is null)
and pmap.idactivity = 'in-rm'
union all

/* Lista de Roles */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-eq'
union all
/* Gestores */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Gestor do processo' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
where pmp.fgprocenabled = 1
and pmap.fgstatus < 3
and pmap.idactivity = 'in-eq'
union all
/* Segurança do processo */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, qqq.qqnm as quem
, substring((select ' | '+ NMACCESSROLEFIELD as [text()] from PMPROCSECURITYCTRL pmps1 inner join PMACCESSROLEFIELD pmpsn1 on pmpsn1.cdACCESSROLEFIELD = pmps1.cdACCESSROLEFIELD and pmpsn1.FGOBJECTTYPE > 0
where pmps1.cdproc = pmpac.cdproc and pmps1.cdaccesslist = pmpac.cdaccesslist for XML path('')), 4, 4000) as acesso, pmpac.FGPERMISSION as tpacesso
, substring(qqq.qqnm, 1, charindex(' ', qqq.qqnm)) as idqq
, case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
where pmp.fgprocenabled = 1 and pmap.fgstatus < 3
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 00 or pmpac.cdteam is null)
and pmap.idactivity = 'in-eq'
union all
/* Aprovadores e Responsáveis de EQ */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq' or pmap.idactivity = 'sg-eq') then 'Lista QUA-009' 
       when (pmap.idactivity = 'ua-qe') then 'List QUA-031' else 'NA' end as quem
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq' or pmap.idactivity = 'sg-eq') then 'Aprovador Indicado' 
       when (pmap.idactivity = 'ua-qe') then 'Approver' else 'NA' end as acesso
, 1 as tpacesso
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq' or pmap.idactivity = 'sg-eq') then 'QUA-009' 
       when (pmap.idactivity = 'ua-qe') then 'QUA-031' else 'NA' end as idqq
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq' or pmap.idactivity = 'sg-eq') then (select cdattribute from adattribute where nmattribute = 'QUA-009')
       when (pmap.idactivity = 'ua-qe') then (select cdattribute from adattribute where nmattribute = 'QUA-031') else 0 end as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and (substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-qe' or substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-eq')
and pmap.idactivity = 'in-eq'
union all
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, case when (pmap.idactivity = 'tds-eq') then 'Lista QUA-012'
       when (pmap.idactivity = 'in-eq') then 'Lista QUA-023'
	   when (pmap.idactivity = 'sg-eq') then 'Lista QUA-041'
       when (pmap.idactivity = 'ua-qe') then 'List QUA-034' else 'NA' end as quem
, case when (pmap.idactivity = 'tds-eq' or pmap.idactivity = 'in-eq' or pmap.idactivity = 'sg-eq') then 'Responsável pelo Evento de Qualidade'
       when (pmap.idactivity = 'ua-qe') then 'Quality Event Responsible' else 'NA' end as acesso
, 1 as tpacesso
, case when (pmap.idactivity = 'tds-eq') then 'QUA-012'
       when (pmap.idactivity = 'in-eq') then 'QUA-023'
	   when (pmap.idactivity = 'sg-eq') then 'QUA-041'
       when (pmap.idactivity = 'ua-qe') then 'QUA-034' else 'NA' end as idqq
, case when (pmap.idactivity = 'tds-eq') then (select cdattribute from adattribute where nmattribute = 'QUA-012')
       when (pmap.idactivity = 'in-eq') then (select cdattribute from adattribute where nmattribute = 'QUA-023')
	   when (pmap.idactivity = 'sg-eq') then (select cdattribute from adattribute where nmattribute = 'QUA-041')
       when (pmap.idactivity = 'ua-qe') then (select cdattribute from adattribute where nmattribute = 'QUA-034') else 0 end as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and (substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-qe' or substring(pmap.idactivity, charindex('-', pmap.idactivity), len(pmap.idactivity)) = '-eq')
and pmap.idactivity = 'in-eq'

union all

/* Lista de Roles */
select distinct pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Papel Funcional' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc)
and pma.fgsystemactivity <> 1 and pmap.fgstatus < 3
and pmap.idactivity = 'in-sol'
union all
/* Gestores */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, adr.idrole +' - '+ adr.nmrole as quem, 'Gestor do processo' as acesso
, 1 as tpacesso
, adr.idrole as idqq, adr.cdrole as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
where pmp.fgprocenabled = 1
and pmap.fgstatus < 3
and pmap.idactivity = 'in-sol'
union all
/* Segurança do processo */
select pmap.idactivity as idprocess, pmap.nmactivity as nmprocess
, qqq.qqnm as quem
, substring((select ' | '+ NMACCESSROLEFIELD as [text()] from PMPROCSECURITYCTRL pmps1 inner join PMACCESSROLEFIELD pmpsn1 on pmpsn1.cdACCESSROLEFIELD = pmps1.cdACCESSROLEFIELD and pmpsn1.FGOBJECTTYPE > 0
where pmps1.cdproc = pmpac.cdproc and pmps1.cdaccesslist = pmpac.cdaccesslist for XML path('')), 4, 4000) as acesso, pmpac.FGPERMISSION as tpacesso
, substring(qqq.qqnm, 1, charindex(' ', qqq.qqnm)) as idqq
, case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end as cdqq
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
where pmp.fgprocenabled = 1 and pmap.fgstatus < 3
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 00 or pmpac.cdteam is null)
and pmap.idactivity = 'in-sol'

union all

/* Treinamento */
select distinct 'TRE' as idprocess, 'Treinamento' as nmprocess, ga.nmgroup as quem
, case when ga.idgroup = 'TRE_ADMIN' then 'Gestor corporativo de treinamneto'
       when ga.idgroup = 'TRE_ONLINE' then 'Partiipante em treinamentos online'
       when ga.idgroup = 'TRE_GEST' or ga.idgroup = 'TRE_GEST_NM' then 'Gestor de treinamento'
       when ga.idgroup = 'TRE_EXE' then 'Executor de treinamento'
       when ga.idgroup = 'TRE_CONSA' then 'Consulta avançada de treinamentos'
       when ga.idgroup = 'TRE_CONSB' then 'Consulta básica de treinamentos'
end as acesso
, 1 as tpacesso, ga.idgroup as idqq, ga.cdgroup as cdqq --, usr.idlogin, usr.nmuser, usr.fguserenabled, pos.nmposition, dep.nmdepartment
from aduser usr
inner join aduseraccgroup gau on gau.cduser = usr.cduser
inner join adaccessgroup ga on ga.cdgroup = gau.cdgroup and ga.cdgroup in (36,37,38,44,46,69,85)

union all

/* Documentos */
select 'DOC' as idprocess, 'Documento' as nmprocess
, case FGACCESSTYPE
              when 1 then case when doc.cdteam is null then 'Outros' else (select eq.IDTEAM + ' - ' + eq.NMTEAM from adteam eq where eq.cdteam = doc.cdteam) end
              when 2 then (select dep.iddepartment +' - '+ dep.nmdepartment from addepartment dep where dep.cddepartment = doc.cddepartment)
              when 3 then (select dep.iddepartment +' - '+ dep.nmdepartment from addepartment dep where dep.cddepartment = doc.cddepartment) +' | '+
                  (select pos.idposition +' - '+ pos.nmposition from adposition pos where pos.cdposition = doc.cdposition)
              when 4 then (select pos.idposition +' - '+ pos.nmposition from adposition pos where pos.cdposition = doc.cdposition)
              when 5 then (select usr.idlogin +' - '+ usr.nmuser from aduser usr where usr.cduser = doc.cduser)
              when 6 then 'Todos'
end as Quem
, cast ((select substring(__sub.__permissoes, 2, 4000) as [text()] from (
        select case dcc.FGACCESSADD when 1 then '|Incluir' else '' end
        + case dcc.FGACCESSEDIT when 1 then '|Alterar' else '' end
        + case dcc.FGACCESSDELETE when 1 then '|Excluir' else '' end
        + case dcc.FGACCESSKNOW when 1 then '|Conhecimento' else '' end
        + case dcc.FGACCESSTRAIN when 1 then '|Treinamento' else '' end
        + case dcc.FGACCESSVIEW when 1 then '|Visualizar' else '' end
        + case dcc.FGACCESSPRINT when 1 then '|Imprimir' else '' end
        + case dcc.FGACCESSPHYSFILE when 1 then '|Arquivar' else '' end
        + case dcc.FGACCESSREVISION when 1 then '|Revisar' else '' end
        + case dcc.FGACCESSCOPY when 1 then '|Distribuir cópia' else '' end
        + case dcc.FGACCESSREGTRAIN when 1 then '|Registrar treinamento'  else '' end
        + case dcc.FGACCESSCANCEL when 1 then '|Cancelar' else '' end
        + case dcc.FGACCESSSAVE when 1 then '|Salvar localmente' else '' end
        + case dcc.FGACCESSSIGN when 1 then '|Assinatura' else '' end
        + case dcc.FGACCESSNOTIFY when 1 then '|Notificação' else '' end
        + case dcc.FGACCESSEDITKNOW when 1 then '|Avaliar aplicabilidade' else '' end
        + case dcc.FGACCESSADDCOMMENT when 1 then '|Incluir comentário' else '' end as __permissoes
  from DCCATEGORYDOCROLE dcc
  where dcc.CDACCESSROLE = doc.CDACCESSROLE) __sub
  for XML path('')) as varchar(4000)) as acesso
, doc.FGPERMISSION as tpacesso
, case FGACCESSTYPE
              when 1 then (select eq.IDTEAM from adteam eq where eq.cdteam = doc.cdteam)
              when 2 then (select dep.iddepartment from addepartment dep where dep.cddepartment = doc.cddepartment)
              when 3 then (select pos.idposition from adposition pos where pos.cdposition = doc.cdposition)
              when 4 then (select pos.idposition from adposition pos where pos.cdposition = doc.cdposition)
              when 5 then (select usr.idlogin from aduser usr where usr.cduser = doc.cduser)
              when 6 then 'sesuite_conf'
end as idqq
, case FGACCESSTYPE
              when 1 then doc.cdteam
              when 2 then doc.cddepartment
              when 3 then doc.cdposition
              when 4 then doc.cdposition
              when 5 then doc.cduser
              when 6 then 1
end  as cdqq
from DCCATEGORYDOCROLE doc
inner join dccategory cat on cat.CDCATEGORY = doc.CDCATEGORY and cat.fgenabled = 1
where idcategory in 
(select idcategory from dccategory where idcategory in 
('0030 - IN') or cdcategoryowner in 
(select cdcategory from dccategory where idcategory in 
('0030 - IN')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0030 - IN'))) or cdcategoryowner in
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0030 - IN')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0030 - IN')))))
) _sub
inner join (select teamm.cdteam as cdqq, idteam as idqq, cduser from adteammember teamm inner join adteam team on team.cdteam = teamm.cdteam
            union all select rolem.cdrole as cdqq, idrole as idqq, cduser from aduserrole rolem inner join adrole rolek on rolek.cdrole = rolem.cdrole
            union all select grp.cdgroup as cdqq, gr.idgroup as idqq, cduser from aduseraccgroup grp inner join adaccessgroup gr on gr.cdgroup = grp.cdgroup
        union all select 1 as cdqq, 'sesuite_conf' as idqq, 1 as cduser from aduser where cduser = 1
            union all select distinct 3 as cdqq, 'DYNuq057' as idqq, (select cduser from aduser where nmuser = form.ac003) as cduser from DYNuq057 form
          ) rel on rel.cdqq = _sub.cdqq and rel.idqq = _sub.idqq
inner join aduser usr on usr.cduser = rel.cduser
inner join aduserdeptpos relu on relu.cduser = rel.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = relu.cddepartment
inner join adposition pos on pos.cdposition = relu.cdposition
where usr.fguserenabled = 1
order by idprocess, acesso


--==============================================================> Permissão nas categorias (Anelise)
select quem, categoria, nmcat, usr.nmuser, permissoes
from (select doc.FGACCESSTYPE,
case FGACCESSTYPE   when 1 then eq.IDTEAM + ' - ' + eq.NMTEAM
                    when 2 then (select dep.iddepartment +' - '+ dep.nmdepartment from addepartment dep where dep.cddepartment = doc.cddepartment)
                    when 3 then (select dep.iddepartment +' - '+ dep.nmdepartment from addepartment dep where dep.cddepartment = doc.cddepartment) +' | '+
                        (select pos.idposition +' - '+ pos.nmposition from adposition pos where pos.cdposition = doc.cdposition)
                    when 4 then (select pos.idposition +' - '+ pos.nmposition from adposition pos where pos.cdposition = doc.cdposition)
                    when 5 then (select usr.idlogin +' - '+ usr.nmuser from aduser usr where usr.cduser = doc.cduser)
                    when 6 then 'Todos'
end as Quem
, eq.cdteam as codeq
, cat.idcategory as categoria, cat.nmcategory as nmcat
, 'Tem acesso '+ case doc.FGPERMISSION when 1 then 'concedido' when 2 then 'negado' end
  +' na categoria: '+ cat.idcategory +' - '+ cat.NMCATEGORY as Oque, 'Documentos' as Modulo
,eq.idteam, cat.idcategory, doc.CDACCESSROLE
,cast ((select substring(__sub.__permissoes, 2, 4000) as [text()] from (
        select case dcc.FGACCESSADD when 1 then '|Incluir' else '' end
        + case dcc.FGACCESSEDIT when 1 then '|Alterar' else '' end
        + case dcc.FGACCESSDELETE when 1 then '|Excluir' else '' end
        + case dcc.FGACCESSKNOW when 1 then '|Conhecimento' else '' end
        + case dcc.FGACCESSTRAIN when 1 then '|Treinamento' else '' end
        + case dcc.FGACCESSVIEW when 1 then '|Visualizar' else '' end
        + case dcc.FGACCESSPRINT when 1 then '|Imprimir' else '' end
        + case dcc.FGACCESSPHYSFILE when 1 then '|Arquivar' else '' end
        + case dcc.FGACCESSREVISION when 1 then '|Revisar' else '' end
        + case dcc.FGACCESSCOPY when 1 then '|Distribuir cópia' else '' end
        + case dcc.FGACCESSREGTRAIN when 1 then '|Registrar treinamento'  else '' end
        + case dcc.FGACCESSCANCEL when 1 then '|Cancelar' else '' end
        + case dcc.FGACCESSSAVE when 1 then '|Salvar localmente' else '' end
        + case dcc.FGACCESSSIGN when 1 then '|Assinatura' else '' end
        + case dcc.FGACCESSNOTIFY when 1 then '|Notificação' else '' end
        + case dcc.FGACCESSEDITKNOW when 1 then '|Avaliar aplicabilidade' else '' end
        + case dcc.FGACCESSADDCOMMENT when 1 then '|Incluir comentário' else '' end as __permissoes
from DCCATEGORYDOCROLE dcc
where dcc.CDACCESSROLE = doc.CDACCESSROLE) __sub
for XML path('')) as varchar(4000)) as permissoes
from DCCATEGORYDOCROLE doc
left join ADTEAM eq on eq.cdteam = doc.CDTEAM
left join addepartment dep on dep.cddepartment = doc.CDdepartment
inner join dccategory cat on cat.CDCATEGORY = doc.CDCATEGORY
where (doc.CDTEAM is not null and doc.CDDEPARTMENT is null) or (doc.CDTEAM is null and doc.CDDEPARTMENT is not null)
) sub
inner join adteammember equ on equ.cdteam = sub.codeq
inner join aduser usr on usr.cduser = equ.cduser
where categoria in ('DCEP TDS','IN TDS','ME TDS','MG TDS','MP TDS','PA TDS','POP TDS','RA GERAIS TDS','SOL TDS','VL TDS','AM IN','INP IN','LGB IN','LVL IN','ME IN','MP IN','PA IN','POP IN','PPX IN','REG IN','AF','AF REG','CONS','DCEP BSB','EE','MAVL BSB','MG HUM','MP HUM','PA HUM','POP BSB','TERC','GQ PA','POP PA','DCEP EG','MAVL EG','MG VET','MP VET','PA VET','POP EG','EMP AP','IT AP','LGB AP','ME AP','POP AP','TAB AP','AF BT','ME BT','MGF BT','MP BT','PA BT','POPS BT','POP EX','FORMHL TDS','1 - VM IN','2 - VC IN','1 - POP EX','2 - AVAL EX','3 - FORM EX','1 - POP VET GA','2 - AVAL VET GA','3 - FORM VET GA','DCEP PA','INV PA','1 - POP HUM BSB','2 - AVAL HUM BSB','3 - FORM HUM BSB','1 - POP HUM EG','2 - AVAL HUM EG','3 - FORM HUM EG','1 - FEIN TDS','2 - MAIN TDS','3 - RAIN TDS','1 - EINP IN','2 - MINP IN','HUM MAVL EG','VET MAVL EG','EE BT','RCME BT','1 - AF IN','2 - FEME IN','3 - MAE IN','4 - DT IN','1 - AF TDS','2 - FEME TDS','3 - DT TDS','4 - MAEM TDS','5 - RAEM TDS','1','2','FR BT','MG BT','EM BT','EMI BT','MMP BT','RCMP BT','DMP HUM','EM DA','EM HUM','EMI HUM','MMP HUM','RCMP HUM','RET HUM','1 - EMP IN','2 - MAMP IN','1 - FEMP TDS','2 - MAMP TDS','3 - RAMP TDS','EM VET','EMI VET','MMP VET','EA BT','MA BT','RCMA BT','DMA HUM','EA HUM','EA HUM PA','MA HUM','MA HUM PA','RCMA HUM','1 - EPA IN','2 - MAPA IN','1 - FEPA TDS','2 - MAPA FQ TDS','3 - MAPA MIC','4 - RAPA LIB TDS','5 - RAPA EST TDS','EA VET','MA VET','1 - POP AP','2 - AVAL AP','3 - FORM AP','HUM BSB','VET BSB','GA EG','HUM EG','VET EG','1 - POP IN','2 - AVAL IN','3 - FORM IN','1 - POP HUM PA','2 - AVAL PA','3 - FORM PA','1 - POP TDS','2 - AVAL TDS','3 - FORM TDS','4 - LGB TDS','AVAL BT','FORM BT','POP BT','1 - RAMIC TDS','2 - RAMIC MA TDS','3 - RA GERAL TDS','ER HUM','MR HUM','AF TERC','EA TERC','EE TERC','EM TERC','MA TERC','MP TERC','1 - POP VET BSB','2 - AVAL VET BSB','3 - FORM VET BSB','1 - POP VET EG','2 - AVAL VET EG','3 - FORM VET EG','1 - MAVL TDS','2 - RAVL TDS','INV VSC')
and quem <> 'TI_ADMINISTRADOR - EQUIPE TI ADMINISTRADOR SE SUITE'
order by categoria, quem, nmuser, permissoes
--3 níveis de categoria
select idcategory from dccategory where idcategory in 
('0050 - BSB','0052 - PA','0053 - EG','0058 - BT','0059 - EX','0030 - IN','0020 - TDS') or cdcategoryowner in 
(select cdcategory from dccategory where idcategory in 
('0050 - BSB','0052 - PA','0053 - EG','0058 - BT','0059 - EX','0030 - IN','0020 - TDS')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0050 - BSB','0052 - PA','0053 - EG','0058 - BT','0059 - EX','0030 - IN','0020 - TDS'))) or cdcategoryowner in
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0050 - BSB','0052 - PA','0053 - EG','0058 - BT','0059 - EX','0030 - IN','0020 - TDS')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0050 - BSB','0052 - PA','0053 - EG','0058 - BT','0059 - EX','0030 - IN','0020 - TDS'))))

--========================================> Lista de documentos sem a marca de necessidade de treinamento na revisão - requerido:

select rev.iddocument, rev.nmtitle, gnrev.idrevision
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dccategory cat on cat.cdcategory = rev.cdcategory and rev.iddocument not like 'FORM%'
where rev.FGTRAINREQUIRED <> 1 and rev.fgcurrent = 1 and cat.idcategory in (
select idcategory from dccategory where idcategory in 
('TRNG UA', 'SOP HSE UA', 'SOP UA') or cdcategoryowner in 
(select cdcategory from dccategory where idcategory in 
('TRNG UA', 'SOP HSE UA', 'SOP UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('TRNG UA', 'SOP HSE UA', 'SOP UA'))) or cdcategoryowner in
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('TRNG UA', 'SOP HSE UA', 'SOP UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('TRNG UA', 'SOP HSE UA', 'SOP UA'))))
)

--===============================================> Itens de um combo
select ccr.tbs007
from DYNtbs007 ccr
inner join DYNtbs001 unid on unid.oid = ccr.OIDABCmtdABCygB
where ccr.fgenabled = 1 and unid.tbs001 like '0020%'
--================================================Lista de ações dos usuários (Ana Padilha)
select (select pl.idactivity from gnactivity pl where pl.cdgenactivity = gnact.cdactivityowner) as plano
, IDACTIVITY as id_atividade, NMACTIVITY as nome_atividade, usr.NMUSER as executor
--, gnact.CDUSERACTIVRESP, gnact.CDUSER, gnact.CDEXECROUTE
--, gnact.vlpercentagem as andamento
--, gnact.QTDURATIONPLAN as prazo
, case gnact.fgstatus
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
, format(gnact.dtfinishplan,'dd/MM/yyyy') as data_fim_planejado
, format(gnact.dtfinish,'dd/MM/yyyy') as data_fim_real
, CAST(gnact.dsdescription AS VARCHAR(4000)) AS como
, CAST(gnact.DSACTIVITY AS VARCHAR(4000)) AS resultado
, CAST(gntk.dswhere AS VARCHAR(4000)) AS onde
, CAST(gntk.dswhy AS VARCHAR(4000)) AS porque
, cast(coalesce((select substring((select ' | '+ wf.idprocess +' - '+ wf.nmprocess as [text()]
                 from wfprocess wf
				 inner JOIN gnactivity gnact1 ON wf.CDGENACTIVITY = gnact1.CDGENACTIVITY
				 inner join gnassocactionplan stpl on stpl.cdassoc = gnact1.cdassoc
				 inner JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
				 inner JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
				 where gnactp.cdgenactivity = gnact.cdactivityowner
       FOR XML PATH('')), 4, 4000)), 'NA') as varchar(4000)) as eventos
from gnactivity gnact
inner join aduser usr on usr.cduser = gnact.cduser
INNER JOIN gntask gntk ON gnact.cdgenactivity = gntk.cdgenactivity
where gnact.CDISOSYSTEM = 174 and gnact.cdactivityowner is not null
and usr.idlogin in ('Aqueiros','Apadilha','Cmaia','Cflopes','Doshiro','Ftenorio','Iferreira','Jpsantos','Mesparrell',
'Mfasano','Pmagalhaes','Rrezende','Vrodrigues')


--=============================================================> Alvaro (documentos com aprovadores)
select rev.iddocument, gnrev.idrevision, rev.nmtitle, rev.cdrevision
, CAST(CAST(ROUND(attrib.vlvalue,0) as int) as varchar(50)) as chamado
 , case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when doc.fgstatus = 4 then 'Cancelado' 
   when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' when rev.fgcurrent = 2 then 
   case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision 
   where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev 
 , case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase 
 , stag.NRCYCLE as ciclo, format(stag.dtdeadline,'dd/MM/yyyy') as dtdeadline, stag.qtdeadline 
 , case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA'  
   else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor 
 , format(stag.dtapproval,'dd/MM/yyyy') as dtexecut 
 , case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
 from dcdocrevision rev 
 inner join dcdocument doc on doc.cddocument = rev.cddocument 
 inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision 
 inner join dcdocumentattrib attrib on rev.cdrevision = attrib.cdrevision and attrib.CDATTRIBUTE = 235
 left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
      and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
      and stag.dtapproval is null
/*
and stag.nrcycle = 
 case when (rev.fgcurrent = 1 and doc.fgstatus = 1) or rev.fgcurrent = 2 or  
   (doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision 
   where CDDOCUMENT = rev.cddocument)) then (select min(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION AND stagx.dtdeadline IS NOT NULL and stagx.dtapproval is null)
 else (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
end
and stag.fgstage =
 case when (rev.fgcurrent = 1 and doc.fgstatus = 1) or rev.fgcurrent = 2 or  
   (doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision 
   where CDDOCUMENT = rev.cddocument)) then (select min(stagx.fgstage) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION AND stagx.dtdeadline IS NOT NULL and stagx.dtapproval is null)
 else (select max(stagx.fgstage) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION )
end
*/
--where attrib.vlvalue = 330572
--order by chamado, stag.NRCYCLE, stag.NRSEQUENCE, stag.dtdeadline

--===================> Treinamento e conteúdo:
SELECT TC.IDCOURSE AS Id_do_curso, T.NMCONTENT AS Conteudo, TR.IDTRAIN AS ID_treinamento, G.CDDOCUMENT, G.CDREVISION
FROM TRCONTENT T
INNER JOIN GNASSOCDOCUMENT G ON (G.CDASSOCDOCUMENT = T.CDASSOCDOCUMENT)
LEFT JOIN TRCOURSECONTENT T2 ON (T2.CDCONTENTGRP = T.CDCONTENT)
LEFT JOIN TRCOURSEREVISION TC ON (TC.CDCOURSE = T2.CDCOURSE AND TC.CDREVISION = T2.CDCOURSEREVISION)
LEFT JOIN TRTRAINCONTENT T3 ON (T3.CDCONTENT = T.CDCONTENT)
LEFT JOIN TRTRAINING TR ON (TR.CDTRAIN = T3.CDTRAIN)
WHERE G.CDREVISION = 3805209

--======================================================> Roteiro responsável
select rr.IDAPPROVALROUTE, rr.NMAPPROVALROUTE, usr.idlogin
from ADAPPROVALROUTE rr
inner join ADAPPROVROUTERESP rru on rru.CDAPPROVALROUTE = rr.CDAPPROVALROUTE
inner join aduser usr on usr.cduser = rru.cduser
where usr.idlogin in ('nvieira')

--==============================================================> Lucila (documentos em fluxo)
select iddocument, idrevision, nmtitle, fase, desde, executor from (
select rev.iddocument, gnrev.idrevision, rev.nmtitle, rev.cdrevision
 , case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when doc.fgstatus = 4 then 'Cancelado' 
   when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' when rev.fgcurrent = 2 then 
   case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision 
   where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev 
 , case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase 
 , stag.NRCYCLE as ciclo, format(stag.dtdeadline,'dd/MM/yyyy') as dtdeadline, stag.qtdeadline 
 , format(dateadd(day, -stag.qtdeadline, stag.dtdeadline),'dd/MM/yyyy') as desde
 , case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA'  
   else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor 
-- , format(stag.dtapproval,'dd/MM/yyyy') as dtexecut 
-- , case stag.fgapproval when 1 then 'Aprovado' when 2 then 'Reprovado' when 3 then 'Temporal' end acao
 from dcdocrevision rev 
 inner join dcdocument doc on doc.cddocument = rev.cddocument 
 inner join dccategory cat on cat.cdcategory = rev.cdcategory
 inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision 
 left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
      and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
      and stag.dtapproval is null
where cat.cdcategory in (15,17,25,26,165,166) ) sub
where fase is not null and statusrev in ('Em fluxo','Emissão')
--=======================> remover os pdfs
_update gnfile set FLPDFCONVERTED = null, FGPDFCONVERTED = null
where cdcomplexfilecont in (
select gn.cdcomplexfilecont
from dcdocument dc
inner join dcdocrevision dr on dc.cddocument = dr.cddocument
inner join dccategory cat on cat.cdcategory = dr.cdcategory
inner join dcfile arq on arq.cdrevision = dr.cdrevision
inner join gnfile gn on gn.cdcomplexfilecont = arq.cdcomplexfilecont
inner join GNREVISION gnrev on gnrev.cdrevision = dr.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
      and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
      and stag.dtapproval is null
where (dc.fgstatus in (1, 3, 5) and dr.cdrevision = (select max(cdrevision) from dcdocrevision 
   where CDDOCUMENT = dr.cddocument)) and gn.FLPDFCONVERTED is not null and gn.FGPDFCONVERTED is not null
and (stag.FGSTAGE = 4 or stag.FGSTAGE = 3 or stag.FGSTAGE = 2)
)
-----> Seleção dos docs
select dc.cddocument,cat.idcategory, dr.iddocument, dr.cdrevision, gnrev.idrevision, dc.FGSTATUS, dr.fgcurrent, FGPDFCONVERTED
--, gn.FLPDFCONVERTED as pdfblob
from dcdocument dc
inner join dcdocrevision dr on dc.cddocument = dr.cddocument
inner join dccategory cat on cat.cdcategory = dr.cdcategory
inner join dcfile arq on arq.cdrevision = dr.cdrevision
inner join gnfile gn on gn.cdcomplexfilecont = arq.cdcomplexfilecont
inner join GNREVISION gnrev on gnrev.cdrevision = dr.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL
      and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
      and stag.dtapproval is null
where (dc.fgstatus in (1, 3, 5) and dr.cdrevision = (select max(cdrevision) from dcdocrevision 
   where CDDOCUMENT = dr.cddocument)) --and gn.FLPDFCONVERTED is not null
and (stag.FGSTAGE = 4)
order by cat.idcategory, dr.cdrevision

--select * from gnfile where 1=2
--==================================================================> Lista de itens do menu
select * from (select isso.nmisosystem, adm.nmmenu as nome, adm.nrorder, adm.cdmenu, adm.nrmenutag
, case when adm.cdmenuowner is null then adm.cdmenu
  	else adm.cdmenuowner
  end cdmenuowner
, (select nmmenu from admenu where cdisosystem = adm.cdisosystem and cdmenu = adm.cdmenuowner) as nome1
, (select nmmenu from admenu where cdisosystem = adm.cdisosystem and cdmenu = (select cdmenuowner from admenu where cdisosystem = adm.cdisosystem and cdmenu = adm.cdmenuowner)) as nome2
, (select nmmenu from admenu where cdisosystem = adm.cdisosystem and cdmenu = (select cdmenuowner from admenu where cdisosystem = adm.cdisosystem and cdmenu = (select cdmenuowner from admenu where cdisosystem = adm.cdisosystem and cdmenu = adm.cdmenuowner))) as nome3
from admenu adm
inner join adisosystem isso on isso.cdisosystem = adm.cdisosystem
where adm.nmmenu is not null) _sub
where nome1 is not null and (
nome2 is not null or (nome2 is null and not exists (select cdmenuowner from admenu where cdmenuowner = _sub.cdmenu)))
order by nmisosystem, nmmenu

=CONCATENAR(A2;" > ";SE(H2="";G2;H2);" > ";SE(H2="";B2;G2);SE(H2="";"";" > ");SE(H2="";"";B2))

--=============================================================> Itens do menu de cada usuário
select acg.cdisosystem, usr.cduser, usr.idlogin, usr.nmuser, acgi.cdmenu
from aduser usr
inner join ADUSERACCGROUP acgu on acgu.cduser = usr.cduser
inner join ADACCESSGROUP acg on acg.cdgroup = acgu.cdgroup
inner join ADACCGROUPITEM acgi on acgi.cdgroup = acg.cdgroup
where usr.fguserenabled = 1 and acg.cdisosystem not in (145,121,136,133,142,165,92,209,100,106,151,96,103,156,204,87,130,154,158,201,43,139,178,173,119,127,57,108,207,176,148,110)
--2 para cada usuário--insert into ADACCESSGROUP (cdgroup,idgroup,nmgroup,cdisosystem,dtinsert,dtupdate,nmuserupd,fgdefault,oid,nrversion,oidlicensekey)
--2 para cada usuário--insert into ADUSERACCGROUP (cduser,cdgroup)
--insert into ADACCGROUPITEM (cdgroup,cdmenu,cdisosystem)
--tabela de licenças: COLICENSEKEY
O cdmenu é o o mesmo?
--========> Lista de Roles e usuários nelas
select pmp.CDPROC, pmp.CDROLEMANAGER
, pmap.idactivity, pmap.nmactivity
, pms.fgexecutortype, pms.cdrole
, pma.idactivity, pma.nmactivity, pma.fgsystemactivity, pma.idactivity, pma.nmactivity
, adr.idrole, adr.nmrole
, usr.iduser, usr.nmuser, usr.fguserenabled
from pmprocess pmp
inner join pmstruct pms on pms.cdproc = pmp.cdproc
inner join pmactivity pma on pms.cdactivity = pma.cdactivity
inner join pmactivity pmap on pmap.cdactivity = pms.cdproc
inner join adrole adr on adr.cdrole = pms.cdrole
left join aduserrole usrl on usrl.cdrole = adr.cdrole
left join aduser usr on usr.cduser = usrl.cduser
where pmp.fgprocenabled = 1 and pms.fgtype = 1 and pms.fgexecutortype = 1
and pms.cdrevision = (select max(cdrevision) from pmstruct where cdproc = pmp.cdproc and idstruct = pms.idstruct)
and pma.fgsystemactivity <> 1 and pmap.fgstatus = 1
and pmap.idactivity = 'tds-cm'
order by pmp.CDPROC, pms.idstruct, pma.idactivity, adr.idrole, usr.nmuser

--========> Gestores do processo
select pmp.CDPROC, pmp.CDROLEMANAGER
, pmap.idactivity, pmap.nmactivity
, usr.iduser, usr.nmuser, usr.fguserenabled
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join adrole adr on adr.cdrole = pmp.CDROLEMANAGER
inner join aduserrole usrl on usrl.cdrole = adr.cdrole
inner join aduser usr on usr.cduser = usrl.cduser
where pmp.fgprocenabled = 1
and pmap.fgstatus = 1
and pmap.idactivity = 'tds-cm'
order by pmp.CDPROC, pmap.idactivity, adr.idrole, usr.nmuser

--========> Segurança do processo
select pmp.CDPROC
, pmap.idactivity, pmap.nmactivity
, qqq.qqnm, usr.idlogin, usr.nmuser
, pmpsn.NMACCESSROLEFIELD
from pmprocess pmp
inner join pmactivity pmap on pmap.cdactivity = pmp.cdproc
inner join PMPROCACCESSLIST pmpac on pmpac.cdproc = pmp.cdproc
inner join PMPROCSECURITYCTRL pmps on pmps.cdproc = pmpac.cdproc and pmps.cdaccesslist = pmpac.cdaccesslist
inner join PMACCESSROLEFIELD pmpsn on pmpsn.cdACCESSROLEFIELD = pmps.cdACCESSROLEFIELD
inner join (select pmp1.cdproc, case when pmpac1.cdteam is null then (select idrole +' - '+ nmrole from adrole where cdrole = pmpac1.cdrole) else (select idteam +' - '+ nmteam from adteam where cdteam = pmpac1.cdteam) end qqnm
            , case when pmpac1.cdteam is null then pmpac1.cdrole else pmpac1.cdteam end qqcd
            from pmprocess pmp1 inner join PMPROCACCESSLIST pmpac1 on pmpac1.cdproc = pmp1.cdproc) qqq on qqq.cdproc = pmp.cdproc and qqq.qqcd = case when pmpac.cdteam is null then pmpac.cdrole else pmpac.cdteam end
left join (select cdteam as cdqq, cduser from adteammember union all select cdrole as cdqq, cduser from aduserrole) rel on rel.cdqq = qqq.qqcd
left join aduser usr on usr.cduser = rel.cduser
where pmp.fgprocenabled = 1 and pmap.fgstatus = 1 and pmpsn.FGOBJECTTYPE > 0
and pmpac.fgpermission = 1 and (pmpac.cdteam <> 42 or pmpac.cdteam is null)
and pmap.idactivity = 'tds-cm'
order by pmp.CDPROC, pmap.idactivity, qqnm, pmpsn.NMACCESSROLEFIELD


--=============================================================================> Lista de usuários de BSB que estão em algum grupo de acesso de DOC
select distinct usr.nmuser,dep.nmdepartment
from adaccessgroup acg
inner join aduseraccgroup acgu on acg.cdgroup = acgu.cdgroup
inner join aduser usr on usr.cduser = acgu.cduser and usr.fguserenabled = 1
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and iddepartment like '%bsb%'
where acg.cdisosystem in (73,87,88)

--=====================================================> Lista de documentos e status/fase (Meire)
select cat.idcategory, rev.iddocument, gnrev.idrevision
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' end statusdoc
, case when (rev.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when (rev.fgcurrent = 1 and doc.fgstatus = 1) then 'Emissão' 
       when rev.fgcurrent = 2 then case when doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument) then 'Em fluxo' else 'Obsoleto' end end statusrev
, (select top 1 case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
   from GNREVISIONSTAGMEM stag where gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and 
         stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION) and 
         ((rev.fgcurrent = 1 and doc.fgstatus = 1) or (rev.fgcurrent = 2 and doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument)))) as fase
from dcdocrevision rev
inner join dccategory cat on cat.cdcategory = rev.cdcategory
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on rev.cddocument = doc.cddocument
order by cat.idcategory, rev.iddocument, gnrev.idrevision, statusdoc, statusrev, fase

--==============================================================================================> Membros de uma equipe
select usr.nmuser, dep.iddepartment, dep.nmdepartment
from adteam te
inner join adteammember tem on tem.cdteam = te.cdteam
inner join aduser usr on usr.cduser = tem.cduser and usr.fguserenabled = 1
inner join aduserdeptpos rel on rel.cduser = tem.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
where te.idteam = 'FORMHL TDS_ACESSO IMP'
order by dep.iddepartment
--======================================================================> Usuários de um grupo de acesso.
select uac.cduser, usr.idlogin, usr.nmuser, agr.idgroup
from aduseraccgroup uac
inner join aduser usr on usr.cduser = uac.cduser
inner join adaccessgroup agr on agr.cdgroup = uac.cdgroup
where agr.idgroup = ''

--======================================================================> Ajustar usuários duplicados
select usr.*
from aduser usr
inner join coaccount acusr on acusr.cduser = usr.cduser
where usr.idlogin = 'lcpereira'
update aduser set idlogin='lcpereira_sabilitado', iduser='lcpereira_sabilitado'
where cduser=5409
update coaccount set idlogin='lcpereira_sabilitado', NMDOMAINUID = null
where cduser=5409
update coaccount set nmdomainuid='29056a3a0ffffffe8440ffffffc24a0ffffffb23f0ffffff8c0ffffffc80ffffffc9526879'
where cduser=196
.

--========================> Info para automação do ITSM
select formp.*, formf.*
from DYNitsm formp
inner join gnassocformreg gnfp on (gnfp.oidentityreg = formp.oid)
inner join wfprocess wf on (wf.cdassocreg = gnfp.cdassoc)

inner join gnassocformreg gnff on (wf.cdassocreg = gnff.cdassoc)
inner join DYNitsm018 formf on (gnff.oidentityreg = formf.oid)
inner join wfprocess wff on (wff.cdassocreg = gnff.cdassoc)
inner join wfstruct wfs on wfs.idprocess = wff.idobject
inner join wfactivity wfa on wfa.idobject = wfs.IDOBJECT

left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
where wf.fgstatus in (1,5) and wfs.fgstatus = 2 and wf.CDPROCESSMODEL = 2808 and wff.CDPROCESSMODEL = 5716 and wfs.idstruct = 'Atividade201125164831134'

--===============================================================> Dados do CM (Paula)
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
, prod.tbs002 as codigo, prod.tbs001 as descr, prod.tbs008 as cliente
, gnactp.idactivity as plAcao, aprov.nmuser, convert(varchar(10),aprov.dtapprov, 103) as dataaprova
, 1 as Quantidade
from DYNtbs015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left join DYNtbs024 prod on prod.OIDABCFCIABCMH0 = form.oid
left join DYNtbs040 cli on cli.OIDABC1pFABCwh3 = form.oid
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
union
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
, (select format(HIS.DTHISTORY,'dd/MM/yyyy') from (SELECT HIS.NMUSER, HIS.DTHISTORY, HIS.TMHISTORY, HIS.NMACTION
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
, prod.tbs002 as codigo, prod.tbs001 as descr, prod.tbs008 as cliente
, gnactp.idactivity as plAcao, aprov.nmuser, convert(varchar(10),aprov.dtapprov, 103) as dataaprova
, 1 as Quantidade
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left join DYNtbs024 prod on prod.OIDABCIQeABC45y = form.oid
left join DYNtbs040 cli on cli.OIDABCtTKABCkFM = form.oid
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
--==========================================> Doc sem DATA
select * from gnrevision
--update_ gnrevision set DTREVISION = DTREVRELEASE
where DTREVISION is null and DTREVRELEASE is not null

--======================================> Serviços duplicados no catãlogo de serviços
select form1.itsm001 as item1, form2.itsm001 as item2
, form1.itsm002p, form1.itsm003p, form1.itsm004p
, form1.itsm002e, form1.itsm003e, form1.itsm004e
from dynitsm001 form1
inner join dynitsm001 form2 on ((form2.itsm002p = form1.itsm002p and form2.itsm003p = form1.itsm003p and form2.itsm004p = form1.itsm004p) or
((form2.itsm002e = form1.itsm002e and form2.itsm003e = form1.itsm003e and form2.itsm004e = form1.itsm004e)))
and form1.oid <> form2.oid and substring(form2.itsm001, 9, 7) > substring(form1.itsm001, 9, 7)
--and form1.fgenabled = 1 and form2.fgenabled = 1

--==========================================> Lista de atividades do Jurídico
select * from (
Select wf.idprocess, gnrev.NMREVISIONSTATUS as status, wf.nmprocess
, case wf.fgstatus when 1 then 'Em andamento' when 2 then 'Suspenso' when 3 then 'Cancelado' when 4 then 'Encerrado' when 5 then 'Bloqueado para edição' end as statusproc
, format(wf.dtstart,'dd/MM/yyyy') as dtabertura, datepart(yyyy,wf.dtstart) as dtabertura_ano, datepart(MM,wf.dtstart) as dtabertura_mes
, format(wf.dtfinish,'dd/MM/yyyy') as dtfechamento, datepart(yyyy,wf.dtfinish) as dtfechamento_ano, datepart(MM,wf.dtfinish) as dtfechamento_mes
, stru.IDSTRUCT, stru.NMSTRUCT, coalesce(his.nmrole, 'Usuário') as tpexecut, his.nmuser, his.nmaction
, format(his.dthistory,'dd/MM/yyyy') as dthistory, his.tmhistory
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
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNREVISIONSTATUS GNrev ON (INC.CDSTATUS = GNrev.CDREVISIONSTATUS)
left join WFHISTORY HIS on his.idprocess = wf.idobject and HIS.FGTYPE IN (9) 
/*
and HIS.DTHISTORY+HIS.TMHISTORY = (
select max(HIS1.DTHISTORY+HIS1.TMHISTORY)
FROM WFHISTORY HIS1
WHERE  HIS1.FGTYPE IN (9) and his1.idprocess = wf.idobject and his.idstruct = his1.idstruct)
*/
left join wfstruct stru on stru.idobject = his.idstruct
where wf.cdprocessmodel=2808 or wf.cdprocessmodel=2909 or wf.cdprocessmodel=2951
) _sub
where --(nmstruct = 'Avaliar [Jurídico]' or nmstruct = 'Emitir DRAC' or nmstruct = 'Analisar') and
(nmuser = 'Isabella Sampaio Leal Netto' or nmuser = 'João Inácio da Silva Júnior')
and substring(dthistory,7,4) = '2017'
--======================================================================= Usuários gestores de categoria
select adt.IDTEAM, adt.NMTEAM, usr.idlogin, usr.nmuser
from adteam adt
inner join adteammember adtm on adtm.cdteam = adt.CDTEAM
inner join aduser usr on usr.cduser = adtm.cduser
where adt.IDTEAM like '%gest%doc%'

--===========================> documento x treinamento - associação de conteúdo
SELECT TC.IDCOURSE AS Id_do_curso, T.NMCONTENT AS Conteudo, TR.IDTRAIN AS ID_treinamento, G.CDDOCUMENT, G.CDREVISION
FROM TRCONTENT T
INNER JOIN GNASSOCDOCUMENT G ON (G.CDASSOCDOCUMENT = T.CDASSOCDOCUMENT)
LEFT JOIN TRCOURSECONTENT T2 ON (T2.CDCONTENTGRP = T.CDCONTENT)
LEFT JOIN TRCOURSEREVISION TC ON (TC.CDCOURSE = T2.CDCOURSE AND TC.CDREVISION = T2.CDCOURSEREVISION)
LEFT JOIN TRTRAINCONTENT T3 ON (T3.CDCONTENT = T.CDCONTENT)
LEFT JOIN TRTRAINING TR ON (TR.CDTRAIN = T3.CDTRAIN)
WHERE G.CDREVISION = 3805209


--==============================================================> Usuários de um grupo de acesso
select usr.nmuser
from aduseraccgroup uacc
inner join aduser usr on usr.cduser = uacc.cduser and usr.FGUSERENABLED = 1
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and CDCOMPANIES = 5
where uacc.cdgroup=25

--======================================================> Listar treinamentos com usuário repetido
select tr1.idtrain,nmuser
from trtraining tr1
inner join TRTRAINUSER tu1 on tu1.cdtrain = tr1.cdtrain
inner join aduser usr on tu1.cduser = usr.cduser
where tr1.IDTRAIN like 'in-tre%' and (select count(cduser) from TRTRAINUSER tu2 where tu2.cdtrain = tr1.cdtrain and tu2.cduser = tu1.cduser) > 1
--=====================================================> Lista de documentos com identificador repetido
select idcategory, iddocument from (
select cat.idcategory,rev.iddocument
from dcdocument doc
inner join dcdocrevision rev on rev.cddocument = doc.cddocument and rev.FGCURRENT = 1
inner join dccategory cat on cat.cdcategory = rev.cdcategory
where rev.cddocument in (select rev1.cddocument from dcdocrevision rev1 
      where (select count(*) from dcdocrevision rev2 
      inner join dcdocument doc1 on doc1.cddocument = rev2.cddocument and doc1.fgstatus < 4
      where rev2.iddocument = rev1.iddocument and rev2.cdcategory <> rev1.cdcategory) > 1)
and doc.fgstatus < 4
--order by rev.iddocument
) sub
order by iddocument
--=====================================================> Lista de documentos que trocarm de identificador
select idcategory, iddocument from (
select cat.idcategory,rev.iddocument
from dcdocument doc
inner join dcdocrevision rev on rev.cddocument = doc.cddocument and rev.FGCURRENT = 1
inner join dccategory cat on cat.cdcategory = rev.cdcategory
where rev.cddocument in (select rev1.cddocument from dcdocrevision rev1 
      where (select count(*) from dcdocrevision rev2 
      inner join dcdocument doc1 on doc1.cddocument = rev2.cddocument and doc1.fgstatus < 4
      where rev2.iddocument <> rev1.iddocument and rev1.cddocument = rev2.cddocument 
            and rev2.cdcategory = rev1.cdcategory and rev2.cdrevision <> rev1.cdrevision) > 1)
and doc.fgstatus < 4
--order by rev.iddocument
) sub
order by iddocument
--=====================================================> Carga de atributos
--insert into adattribvalue (CDATTRIBUTE,CDVALUE,NMATTRIBUTE,VLATTRIBUTE,DTATTRIBUTE,FGDEFAULTVALUE,FGATTRIBVLENABLE) select (select cdattribute from adattribute where nmattribute = 'codigosapmpmv'),(coalesce((Select MAX(cdvalue) FROM adattribvalue),0) + ROW_NUMBER() over (order by cdvalue)),NMATTRIBUTE,VLATTRIBUTE,DTATTRIBUTE,FGDEFAULTVALUE,FGATTRIBVLENABLE from adattribvalue where CDATTRIBUTE=(select cdattribute from adattribute where NMATTRIBUTE='codigosapmp')
--insert into adattribvalue (CDATTRIBUTE,CDVALUE,NMATTRIBUTE,VLATTRIBUTE,DTATTRIBUTE,FGDEFAULTVALUE,FGATTRIBVLENABLE) select (select cdattribute from adattribute where nmattribute = 'textosapmpmv'),(coalesce((Select MAX(cdvalue) FROM adattribvalue),0) + ROW_NUMBER() over (order by cdvalue)),NMATTRIBUTE,VLATTRIBUTE,DTATTRIBUTE,FGDEFAULTVALUE,FGATTRIBVLENABLE from adattribvalue where CDATTRIBUTE=(select cdattribute from adattribute where NMATTRIBUTE='textosapmp')
--update adattribute set CDATTRIBUTELINK=(select cdattribute from adattribute where NMATTRIBUTE='codigosapmpmv') where NMATTRIBUTE='textosapmpmv'
--insert into ADATTRIBRELATION (CDATTRIBRELATION,CDATTRIBUTE,CDVALUE,CDATTRIBUTEREL,CDVALUEREL,FGDEFAULT) 
select (coalesce((Select MAX(CDATTRIBRELATION) FROM ADATTRIBRELATION),0) + ROW_NUMBER() over (order by CDATTRIBRELATION))
,(select cdattribute from adattribute where nmattribute = 'textosapmpmv')
,(select CDVALUE from adattribvalue where nmattribute = (select nmattribute from adattribvalue where cdvalue = ttt.CDVALUE and CDATTRIBUTE=(select cdattribute from adattribute where nmattribute = 'textosapmp')) and CDATTRIBUTE=(select cdattribute from adattribute where nmattribute = 'textosapmpmv'))
,(select cdattribute from adattribute where nmattribute = 'codigosapmpmv')
,(select CDVALUE from adattribvalue where nmattribute = (select nmattribute from adattribvalue where cdvalue = ttt.CDVALUEREL and CDATTRIBUTE=(select cdattribute from adattribute where nmattribute = 'codigosapmp')) and CDATTRIBUTE=(select cdattribute from adattribute where nmattribute = 'codigosapmpmv'))
,2
from ADATTRIBRELATION ttt
where ttt.cdattribute=(select cdattribute from adattribute where nmattribute = 'textosapmp')
--=====================================================> Alterar a pasta de um processo
select inc.*
,GNT.idgentype, GNT.nmgentype
from wfprocess prc
INNER JOIN INOCCURRENCE INC ON (PRC.IDOBJECT = INC.IDWORKFLOW)
LEFT OUTER JOIN GNGENTYPE GNT ON (INC.CDOCCURRENCETYPE = GNT.CDGENTYPE)
where idprocess='ANVTDE180104143446'

--update INOCCURRENCE set CDOCCURRENCETYPE = 98 where CDOCCURRENCE=18906
--10 -> 98

--==========================================================> Roberton - Documentos cancelados e data
select rev.iddocument, format(his.dtaccess,'dd/MM/yyyy') as dtaccess
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
left join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype in (11) and doc.fgstatus = 4
where rev.CDCATEGORY=37 and doc.FGSTATUS = 4 and FGCURRENT = 1
--==============================================================> Roberton - documentos e sua data de primeira revisão
select rev.iddocument, gnrev.idrevision, format(gnrev.dtrevision,'dd/MM/yyyy') as dtrevrelease
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
where rev.CDCATEGORY=37 and doc.FGSTATUS <> 4 and rev.cdrevision in (
    select min(cdrevision) from dcdocrevision where cdrevision = rev.cdrevision)
and gnrev.dtrevision is not null
--=====================================================================> Transferencia de tarefas por ausência
select usrde.nmuser ,' para ', usrpara.nmuser
, case when adab.dtfinish is null then 'indefinidamente' else cast(adab.dtfinish as varchar(255)) end fim
from ADUSERABSENCE adab
inner join aduser usrde on usrde.cduser = adab.cduser
inner join aduser usrpara on usrpara.cduser = adab.cduserpendency
where adab.dtfinish is null or adab.dtfinish > getdate()

--===================================================================> Solicitações de CM canceladas e seus planos associados
select wf.idprocess
, --case when gnactp.idactivity is null then gnactpp.idactivity else gnactp.idactivity end idplano
gnactpP.idactivity, wf.dtupdate
from DYNtds038 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left JOIN gnactivity gnact ON wf.CDGENACTIVITY = gnact.CDGENACTIVITY
left join gnassocactionplan stpl on stpl.cdassoc = gnact.cdassoc
--????--left JOIN gnactionplan gnpl ON gnpl.cdactionplan = stpl.cdactionplan
--????--left JOIN gnactivity gnactp ON gnpl.cdgenactivity = gnactp.cdgenactivity
inner join gnactivity gnactpp ON stpl.cdactionplan = gnactpp.cdgenactivity
where wf.cdprocessmodel=72 and wf.fgstatus = 3 and form.tds003=2
order by wf.dtupdate
--select cdassoc from gnactivity where cdgenactivity = (select cdgenactivity from wfprocess where idprocess='ANVTSOL170706151616_CM') --108663
--select * from gnassocactionplan where cdassoc=108663
--select * from gnactionplan where cdactionplan=12613
--select * from gnactivity where cdgenactivity = 12613

--==========================================================> Exclusão de revisões anteriores
select rev.cddocument, rev.cdrevision, gnrev.fgstatus, rev.fgcurrent, gnrev.idrevision
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
where iddocument in ('EA-000699','MA-000687','RCMA-000608','EA-000698','MA-000688','RCMA-000607')

--delete from GNREVISIONREQASSOC where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from GNREVISIONCRITIC where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from GNREVUPDATE where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from GNREVISIONSTAGMEM where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from DCDOCUMENTATTRIB where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from gnfile where CDCOMPLEXFILECONT in (select CDCOMPLEXFILECONT from DCFILE where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876))
--delete from DCFILE where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from DCPRINTCOPYPROTDOC where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from DCDOCCOPYSTATION where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from dcdocrevision where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from GNREVISIONCHANGES where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from DCDOCUMENTUSER where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--delete from gnrevision where cdrevision in (79558,76870,78360,76872,78359,76871,79559,76874,78425,76875,78423,76876)
--update dcdocrevision set fgcurrent = 1 where cdrevision in (70376,70377,70379,70356,70380,70368)

--============================================================
/* Relatórios de Treinamento - Where para UQ
where usr.fguserenabled = 1 and exists(select dep.cddepartment from addepartment dep inner join aduserdeptpos rel on dep.cddepartment = rel.cddepartment and rel.cduser = usr.cduser 
and rel.FGDEFAULTDEPTPOS = 1 where dep.cdcompanies = (select cdcompanies from adcompanies where idcompanies like '0052%'))
and exists(select dep.cddepartment from addepartment dep inner join aduserdeptpos rel on dep.cddepartment = rel.cddepartment and rel.cduser = usr.cduser 
and rel.FGDEFAULTDEPTPOS = 2 inner join adposition pos on rel.cdposition = pos.cdposition
where dep.cddepartment = 164 and pos.idposition like 'PA0052-01%')
*/
/* Relatórios de Treinamento - Where para ANOVIS e INOVAT
where usr.fguserenabled = 1 and coalesce((select nmdepartment from addepartment where cddepartment = (
  select reldef.cddepartment from aduserdeptpos reldef where reldef.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1) 
  and cdcompanies = (select cdcompanies from adcompanies where idcompanies like '0052%')), 'NA') in ()
 */


--==============================================> Excluir arquivos eletrônicos
update gnfile set FLPDFCONVERTED = null, FLFILE = null,NRSIZE = null, NMFILEHASH=null, FLTHUMBNAIL=null

--==============================================> Arquivos modelo
select ct.idcategory, ct.nmcategory, tp.idtemplatefile, tp.nmtemplatefile, dr.iddocument, dr.nmtitle
from dccategory ct, gneletfilecfgtemp gnt, gntemplatefile tp, dcdocrevision dr
where ct.cdeletronicfilecfg=gnt.cdeletronicfilecfg
and gnt.cdtemplatefile=tp.cdtemplatefile
and tp.cddocument=dr.cddocument
and dr.fgcurrent=1

--======================================> Ação do formulário
Habilitar / Desabilitar / Obrigatório / Não obrigatório / Exibir / Ocultar / Limpar / Recarregar / atribuição (2)

--update aduser set nmdomainuid='770ffffff800ffffff8f0ffffffff0ffffff970b0ffffff8f480ffffffa60ffffffe5230ffffff80165d0fffffffb0ffffffc3' where cduser in (2037)
--update coaccount set nmdomainuid='770ffffff800ffffff8f0ffffffff0ffffff970b0ffffff8f480ffffffa60ffffffe5230ffffff80165d0fffffffb0ffffffc3' where cduser in (5037)

--=========================> Treinamentos sem objeto
--INSERT INTO dcdoctrain (cdtrain, cddocument,cdrevision)
select tr.IDTRAIN, co.idcourse, rev.iddocument, tr.NMTRAIN, gnrev.idrevision
, tr.cdtrain, rev.cddocument, rev.cdrevision
from trtraining tr
left join DCDOCTRAIN tdoc on tr.cdtrain = tdoc.cdtrain
inner join trcourse cou on cou.cdcourse = tr.cdcourse
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
inner join trcourse co on co.cdcourse = tr.CDCOURSE
inner join dcdoccourse codoc on codoc.cdcourse = co.cdcourse
inner JOIN DCDOCREVISION rev ON rev.cddocument = codoc.cddocument and rev.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = codoc.cddocument)
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
where tdoc.CDDOCUMENT is null and gnt.cdgentypeowner=110
order by tr.IDTRAIN

-------

SELECT tr.cdtrain, dcrev.cddocument, dcrev.cdrevision, tr.idtrain, dcrev.iddocument, gnrev.idrevision, dcrev.nmtitle
FROM dcdoccourse dccour
INNER JOIN trtraining tr ON (tr.cdcourse = dccour.cdcourse)
INNER JOIN DCDOCREVISION dcrev ON (dcrev.cddocument = dccour.cddocument)
inner join gnrevision gnrev on gnrev.cdrevision = dcrev.cdrevision
WHERE dcrev.FGTRAINREQUIRED = 1
AND dcrev.CDCATEGORY IN (select cdcategory from dccategory where idcategory in 
('0010 - UA') or cdcategoryowner in 
(select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA'))) or cdcategoryowner in
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA')))))
AND (dcrev.FGCURRENT = 1 OR dcrev.CDREVISION
> (SELECT DR.CDREVISION FROM DCDOCREVISION DR
WHERE DR.CDDOCUMENT = dcrev.CDDOCUMENT AND
DR.FGCURRENT = 1))
AND dcrev.CDCATEGORY IN (select cdcategory from dccategory where idcategory in 
('0010 - UA') or cdcategoryowner in 
(select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA'))) or cdcategoryowner in
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA')))))
AND NOT EXISTS (SELECT 1 FROM dcdoctrain dctr
WHERE dctr.cdtrain = tr.cdtrain and
dctr.cddocument = dcrev.cddocument AND
dctr.cdrevision = dcrev.cdrevision)
and tr.cdtrain in 
(select tr.CDTRAIN
from trtraining tr
left join DCDOCTRAIN tdoc on tr.cdtrain = tdoc.cdtrain
inner join trcourse cou on cou.cdcourse = tr.cdcourse
inner join gngentype gnt on gnt.cdgentype = cou.cdcoursetype
where tdoc.CDDOCUMENT is null and gnt.cdgentypeowner=137)
order by dcrev.iddocument

--======================> Lista de termos para tradução do processo e formulário
select distinct * from (
select NMACTIVITY as texto, 'processo' as tipo
from pmactivity
where cdactivity in (5251, 5470, 5679, 5692, 5716)
union all
select pma.nmartifact as texto, 'itens do processo' as tipo
from PMARTIFACT pma
where pma.nmartifact is not null and pma.cdproc in (5251, 5470, 5679, 5692, 5716)
union all
select pmf.idflow as texto, 'fluxos' as tipo
from PMFLOW pmf 
where pmf.idflow is not null and cdstructfrom in (select pms.cdstruct from pmstruct pms where pms.cdproc in (5251, 5470, 5679, 5692, 5716))
union all
select nmlane as texto, 'lanes' as tipo
from PMLANE pml
where pml.cdproc in (5251, 5470, 5679, 5692, 5716)
union all
select pms.nmactivity as texto, 'atividades' as tipo
from pmstruct pms
where pms.cdproc in (5251, 5470, 5679, 5692, 5716) and pms.nmactivity is not null and pms.fgtype in (1, 40, 41, 22, 5, 34, 23)
union all
select pmact.nmaction as texto, --pms.nmactivity +
' - ação da atividade' as tipo
from pmprocstruct pmps
inner join PMSTRUCTACTION pmact on pmact.cdstruct = pmps.cdstruct
inner join pmstruct pms on pms.cdstruct = pmps.cdstruct
where pmps.cdproc in (5251, 5470, 5679, 5692, 5716)
union all
select ef.NMLABEL as texto, --rf.idform +
' - itens e campos do form' as tipo
from efstructform ef
inner join EFREVISIONFORM rf on ef.OIDREVISIONFORM = rf.oid and rf.fgcurrent = 1
where ef.NMLABEL is not null and rf.idform like 'itsm%' and ef.FGHIDDEN = 2
union all
select grid.idtitle as texto, --ef.NMLABEL +
' - grid do form' as tipo
from efstructform ef
inner join EFSTRUCTFORMGRID grid on grid.OIDSTRUCTFORM = ef.OID
where grid.OIDENTITYMODEL in (select oid from EMENTITYMODEL where idname like 'itsm%')
union all
select attr.NMLABEL as texto, --dsm.NMDISPLAYNAME +
' - título de coluna de conjunto de dados' as tipo
from EMDATASETMODEL dsm
inner join EMATTRMODEL attr on attr.OIDDATASETMODEL = dsm.OID
where dsm.NMDISPLAYNAME like '%itsm%' and (attr.NMLABEL not like 'ITSM%' and attr.NMLABEL not like 'OID%')
) _sub
order by 1

--==================================> Conjunto de Dados
select em.idname, em.nmdisplayname
,bi.txdata
, cat.idcategory, cat.nmcategory
from EMdatasetmodel em
inner join SETEXT bi on bi.oid = em.oidcommand
left join EMCATEGORY cat on cat.oid = em.oidcategory

--================================> Documentos sem mapeamento de cursos
select revc.iddocument
, 1 as quantidade
from dcdocrevision revc
inner join dcdocument doc on doc.cddocument = revc.cddocument and doc.fgstatus <> 4
inner join gnrevision gnrevc on gnrevc.cdrevision = revc.cdrevision
where revc.cdrevision in
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
and revc.cddocument not in (select cddocument from DCDOCCOURSE docc where docc.cddocument = revc.cddocument and cdcourse <> -1)
and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
from dcdocrevision revi
inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub
where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3))
and revc.cdcategory in (274, 311)

--==============================> Atualizar revisão dos registros de um formulário:
update DYNitsm001
set OIDREVISIONFORM = (select rf.oid
    from EFREVISIONFORM rf
    where rf.idform = 'itsm001' and rf.fgcurrent = 1)

select rf.oid,rf.fgcurrent,gnrev.IDREVISION, gnrev.cdrevision
from EFREVISIONFORM rf
inner join gnrevision gnrev on gnrev.cdrevision = rf.cdrevision
where rf.idform = 'itsm' --and rf.fgcurrent = 1


update EFREVISIONFORM set FGCURRENT=1 where oid='e3f273e180d696c05e3fcbdda863df19'
update EFREVISIONFORM set FGCURRENT=2 where oid='ac55d155a4a4dfa950d4e1d9a462c940'

update gnrevision set idrevision = '05' where cdrevision=3788432
update gnrevision set idrevision = '06' where cdrevision=3788429

--===============================> Documentos de chamados do sesuite
select rev.iddocument, gnrev.idrevision, gnrev.dtrevision, rev.nmtitle, dcat.vlvalue as chamado
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left join dcdocumentattrib dcat on dcat.cdrevision = rev.cdrevision and dcat.cdattribute = 235
left join dcdocmultiattrib dcmat on dcmat.cdrevision = rev.cdrevision and dcmat.cdattribute = 223
left join adattribvalue atva on atva.cdattribute = dcmat.cdattribute and atva.cdvalue = dcmat.cdvalue
where rev.iddocument like 'APL-qr%' and doc.fgstatus >= 2 and doc.fgstatus <= 3
--and (atva.nmattribute like '%Suite%' or atva.nmattribute is null)
and rev.iddocument not like 'APL-QR-___-%'
order by dcat.vlvalue, gnrev.dtrevision
--rev.iddocument, gnrev.dtrevision

--========================================> Queries dos formulários
select revform.idform, revform.nmform, tab.IDNAME, tab.NMDISPLAYNAME, query.idquery, query.txquery
, case query.fgtype
	when 1 then 'Select'
	when 2 then 'Insert'
	when 3 then 'Update'
	when 4 then 'Delete'
	else cast(query.fgtype as varchar)
end tipo
, cat.idcategory, cat.nmcategory
from EFQUERY query
inner join EFREVISIONFORM revform on revform.oid = query.OIDREVISIONFORM
inner join efform form on form.oid = revform.OIDFORM
inner join EMENTITYMODEL tab on tab.oid = form.OIDENTITY
left join EMCATEGORY cat on cat.oid = tab.oidcategory
where revform.fgcurrent = 1
--and idform='itsm018'
and revform.cdrevision = (select max(cdrevision) from EFREVISIONFORM where OIDFORM = revform.OIDFORM)


--=============================================> Fórmulas dos fomrulários
select revform.idform, strucev.fgevent, strucf.nmlabel, revform.nmform, strucf.fgtype, tab.IDNAME, tab.NMDISPLAYNAME
,formula.txformula
, case strucf.fgtype
	when 1 then 'ComboBox'
	when 2 then 'CheckBox'
	when 3 then 'Input'
	when 5 then 'Zoom_Tabela'
	when 6 then 'RadioButton'
	when 11 then 'Spin'
	when 14 then 'Data'
	when 15 then 'Input'
	when 16 then 'Grid'
	when 19 then 'Zoom_Externo'
	when 23 then 'Botão'
	else case when strucf.fgtype is null then 'Formulário' else cast(strucf.fgtype as varchar) end
end +
case strucev.fgevent
	when 1 then ' - Entrada'
	when 2 then ' - Saída'
	when 3 then ' - Alteração'
	when 4 then ' - Clique'
	when 5 then ' - OnLoad'
	when 6 then ' - OnExit'
	else  ' - '+ cast(strucev.fgevent as varchar)
end as tipo
from gnformula formula
inner join EFSTRUCTFORMEVENT strucev on strucev.cdformula = formula.cdformula
left join EFSTRUCTFORM strucf on strucf.oid = strucev.OIDSTRUCTFORM
inner join EFREVISIONFORM revform on revform.oid = strucev.OIDREVISIONFORM
inner join efform form on form.oid = revform.OIDFORM
inner join EMENTITYMODEL tab on tab.oid = form.OIDENTITY
where revform.fgcurrent = 1
--and txformula like '%select%' --and idform='QUA010'
and revform.cdrevision = (select max(cdrevision) from EFREVISIONFORM where OIDFORM = revform.OIDFORM)

--EFEXECUTESQL
--EFQUERY
--EFFORMELEMENT
--select * from EFREVISIONFORM where 2=1

select revform.idform, strucev.fgevent, strucf.nmlabel, revform.nmform
, revform.cdrevision,formula.txformula
from gnformula formula
inner join EFSTRUCTFORMEVENT strucev on strucev.cdformula = formula.cdformula
left join EFSTRUCTFORM strucf on strucf.oid = strucev.OIDSTRUCTFORM
inner join EFREVISIONFORM revform on revform.oid = strucev.OIDREVISIONFORM
where revform.fgcurrent = 1 and 
txformula like '%0030%' and (idform like 'QUA%' or idform like 'TDS%' or idform like 'TBS%')
and revform.cdrevision = (select max(cdrevision) from EFREVISIONFORM where OIDFORM = revform.OIDFORM)


--==============================> Uso das linceças nominativas
select distinct adag.cduser
from aduseraccgroup adag
inner join adaccessgroup acc on acc.cdgroup = adag.cdgroup
where acc.idgroup in ('admFULL','BASIS_ADMIN','ITSM_TI') or acc.idgroup like '%nm'

--==============================> Subprocesso
SELECT wf2.idprocess as filho, wf.idprocess as pai
from wfstruct wfs
inner join WFSUBPROCESS wfsub on wfsub.IDOBJECT = wfs.IDOBJECT
inner join wfprocess wf on wfs.idprocess = wf.idobject
inner join wfprocess wf2 on wf2.idobject = wfsub.IDSUBPROCESS
where wf.idprocess = '<idprocess-chamado>'

--=============================================> Atividades com BASIS

select * from (
select wf.idprocess
, (SELECT str.idstruct FROM WFSTRUCT STR
   inner join wfactivity wfa on str.idobject = wfa.IDOBJECT
   WHERE str.fgstatus = 2 and wfa.FGACTIVITYTYPE <> 3
   and (str.idprocess = wf.idobject
    or str.idprocess in (select wf2.idobject from wfstruct wfs
                         inner join WFSUBPROCESS wfsub on wfsub.IDOBJECT = wfs.IDOBJECT
                         inner join wfprocess wf1 on wfs.idprocess = wf1.idobject
                         inner join wfprocess wf2 on wf2.idobject = wfsub.IDSUBPROCESS
                         where wfsub.CDPROCESSMODEL in (5679)
                         and wf1.idobject = wf.idobject
                        ))
) as atvatual
, (SELECT case wfa.FGEXECUTORTYPE
               when 1 then str.nmrole
               when 3 then str.nmuser
               when 4 then str.nmuser
               else 'indefinido'
          end
   FROM WFSTRUCT STR, WFACTIVITY WFA
   WHERE str.fgstatus = 2 and wfa.FGACTIVITYTYPE <> 3 and str.idobject = wfa.idobject
   and (str.idprocess = wf.idobject
    or str.idprocess in (select wf2.idobject from wfstruct wfs
                         inner join WFSUBPROCESS wfsub on wfsub.IDOBJECT = wfs.IDOBJECT
                         inner join wfprocess wf1 on wfs.idprocess = wf1.idobject
                         inner join wfprocess wf2 on wf2.idobject = wfsub.IDSUBPROCESS
                         where wfsub.CDPROCESSMODEL in (5679)
                         and wf1.idobject = wf.idobject
                        ))
) as atvatual_executor
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
where wf.CDPROCESSMODEL in (5679)
) _sub
where atvatual = 'Atividade20111012624715' and atvatual_executor like '%BASIS%'

--==========================================> Encontrar uso do Conjunto de dados
select idname, nmdisplayname, oid from EMDATASETMODEL where idname like 'itsm%' order by 1

select rf.idform, rf.nmform, rf.nrversion, ef.idstruct, ef.fgtype, ef.nmlabel, ef.fgrequired, ef.fgenabled, ef.fghidden
from efstructform ef
inner join EFREVISIONFORM rf on ef.OIDREVISIONFORM = rf.oid and rf.fgcurrent = 1
where rf.idform like 'itsm%' and OIDDATASETMODEL in (select oid from EMDATASETMODEL where idname like 'itsm023cj%')
--and ef.fgtype = 19 


--Nos botões:
select ef.oid, rf.idform, rf.nmform, rf.nrversion, ef.idstruct, ef.fgtype, ef.nmlabel, ef.fgrequired, ef.fgenabled, ef.fghidden
from efstructform ef
inner join EFREVISIONFORM rf on ef.OIDREVISIONFORM = rf.oid and rf.fgcurrent = 1
where rf.idform like 'itsm%' --and OIDDATASETMODEL in (select oid from EMDATASETMODEL where idname like 'itsm023cj%')
and ef.nmlabel like 'btn%'
and ef.oid like '3734968w1w%'
order by ef.oid


--==========================================> último caractere no excel
=DIREITA(O2;(NÚM.CARACT(O2)-PROCURAR("@";SUBSTITUIR(O2;"\";"@";NÚM.CARACT(O2)-NÚM.CARACT(SUBSTITUIR(O2;"\";"")));1)))
=ESQUERDA(S2;(PROCURAR("@";SUBSTITUIR(S2;".";"@";NÚM.CARACT(S2)-NÚM.CARACT(SUBSTITUIR(S2;".";"")));1)))
--======================================== > Tabelas de localização
EFITEMLANGUAGE, EFLISTLANGUAGE e EFGRIDLANGUAGE

select coluna, valor
,(select il.NMLABEL
from efitemlanguage il
inner join efstructform ef on ef.oid = il.OIDSTRUCTFORM
inner join emattrmodel em on ef.oidattributemodel = em.oid
inner join EFREVISIONFORM rf on ef.OIDREVISIONFORM = rf.oid and rf.fgcurrent = 1
where em.oidentity = (select oid from EMENTITYMODEL where idname = 'tds015')
and il.FGLANGUAGE = 1 and rf.idform = 'QUA015' and idname = coluna) as tpmud
from (select *
      from dyntds015
      where OID = $P{OID}
) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1

--==================================> campos do formulário

select rf.*
from EFREVISIONFORM rf
inner join efstructform ef on ef.OIDREVISIONFORM = rf.oid
inner join emattrmodel em on ef.oidattributemodel = em.oid
--inner join efitemlanguage il on ef.oid = il.OIDSTRUCTFORM
where rf.idform = 'f0'

--========================================================> Working days

SELECT
   (DATEDIFF(dd, @StartDate, @EndDate) + 1)
  -(DATEDIFF(wk, @StartDate, @EndDate) * 2)
  -(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, @EndDate) = 'Saturday' THEN 1 ELSE 0 END)

--========================================================
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
       else case when gnrevc.DTREVISION is null and (select min(fgstage) from (
select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle)
                from dcdocrevision revi
                inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision
                inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION
                where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub where dtdeadline is not null and fgapproval is null and dtapproval is null) <= 3 then 'Documento não aprovado'
                 when gnrevc.DTREVISION is not null then case when (getdate() - gnrevc.DTREVISION) <= 30 then 'Aguardando Treinamento' else 'Pendente' end else case when (getdate() - (select max(stag1.dtapproval)
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

 and (gnrevc.DTREVISION is not null or (gnrevc.DTREVISION is null and (select min(fgstage) from ( 
                 select fgstage,nrcycle,dtdeadline,fgapproval,dtapproval from GNREVISIONSTAGMEM where cdrevision = revc.cdrevision and nrcycle = (select max(stag1.nrcycle) 
                 from dcdocrevision revi 
                 inner join gnrevision gnrevi on gnrevi.cdrevision = revi.cdrevision 
                 inner join GNREVISIONSTAGMEM stag1 ON stag1.CDREVISION = revi.CDREVISION 
                 where revi.cdrevision = (select max(cdrevision) from dcdocrevision where cddocument = revc.cddocument))) _sub 
                 where dtdeadline is not null and fgapproval is null and dtapproval is null) > 3)) 


----------------------------------------------------------------
select  role.idrole +' - '+ role.nmrole, usr.nmuser
from aduserrole usrrl
inner join adrole role on role.cdrole = usrrl.cdrole
inner join aduser usr on usr.cduser = usrrl.cduser
where usrrl.cdrole in (
select cdrole from adrole where cdroleowner in (
select cdrole from adrole where idrole = 'an-de_apr')) or usrrl.cdrole in (286,50)

--=============================> Verificações de documentos:
01) Verifica inconsistências entre a situação indicada dentro da revisão e a real situação da mesmo

SELECT D.FGSTATUS AS SitDOC, R.FGSTATUS AS SitRev ,
DR.CDDOCUMENT, DR.CDREVISION, RSTM.CDMEMBERINDEX, RSTM.FGSTAGE,RSTM.NRCYCLE,RSTM.NRSEQUENCE, DR.CDCATEGORY,
RSTM.DTDEADLINE,RSTM.FGAPPROVAL,RSTM.QTDEADLINE,DR.IDDOCUMENT,
RSTM.DTAPPROVAL,RSTM.CDUSER,RSTM.CDDEPARTMENT,RSTM.CDPOSITION,RSTM.CDTEAM
FROM DCDOCREVISION DR, DCDOCUMENT D, GNREVISION R,  GNREVISIONSTAGMEM RSTM
WHERE D.CDDOCUMENT=DR.CDDOCUMENT AND DR.CDREVISION=R.CDREVISION
AND RSTM.CDREVISION=R.CDREVISION
AND R.CDREVISION=(SELECT MAX(CDREVISION) FROM DCDOCREVISION WHERE DCDOCREVISION.CDDOCUMENT=DR.CDDOCUMENT)
AND R.FGSTATUS NOT IN(5,6)
AND D.FGSTATUS <> 4
AND NOT EXISTS (SELECT 1 
					FROM GNREVISIONSTAGMEM STM2 
					WHERE STM2.CDREVISION=R.CDREVISION 
     				AND DTDEADLINE IS NOT NULL
					AND FGAPPROVAL IS NULL 
					AND R.FGSTATUS=STM2.FGSTAGE
					AND NRCYCLE=(SELECT MAX(NRCYCLE)
								FROM GNREVISIONSTAGMEM STAG
								WHERE R.CDREVISION=STAG.CDREVISION))
ORDER BY DR.CDDOCUMENT, DR.CDREVISION, RSTM.NRCYCLE, RSTM.FGSTAGE, RSTM.NRSEQUENCE							



02) Verifica se existe algum documento que aparece em revisão, no entanto não possui nenhuma revisão em aberto

SELECT  DR1.IDDOCUMENT AS IDDOC,D.* FROM DCDOCUMENT D, DCDOCREVISION DR1
	WHERE FGSTATUS IN (1,3) AND D.CDDOCUMENT=DR1.CDDOCUMENT
	AND 6 =
		(SELECT MIN(R.FGSTATUS)
			FROM GNREVISION R 
			WHERE CDREVISION IN(SELECT CDREVISION FROM DCDOCREVISION DR, DCCATEGORY C, GNREVCONFIG RC 
			WHERE C.CDCATEGORY=DR.CDCATEGORY AND RC.CDREVCONFIG=C.CDREVCONFIG AND FGTYPEREVISION=1 AND DR.CDDOCUMENT=DR1.CDDOCUMENT))
			
03)
Situaçao do documento em revisão mas não tem revisão em aberto

SELECT  DR1.IDDOCUMENT AS IDDOC,D.* FROM DCDOCUMENT D, DCDOCREVISION DR1
	WHERE FGSTATUS IN (1,3) AND D.CDDOCUMENT=DR1.CDDOCUMENT
	AND 6 =
		(SELECT MIN(R.FGSTATUS)
			FROM GNREVISION R 
			WHERE CDREVISION IN(SELECT CDREVISION FROM DCDOCREVISION DR
			WHERE DR.CDDOCUMENT=DR1.CDDOCUMENT))
			

04) Verifica se existe algum documento que aparece como homologado, no entanto deveria aparecer como "em revisão".

SELECT DISTINCT D.CDDOCUMENT 
	FROM DCDOCUMENT D, DCDOCREVISION DR 
	WHERE D.CDDOCUMENT=DR.CDDOCUMENT
	AND D.FGSTATUS=2 
	AND EXISTS(SELECT 1 FROM GNREVISION R, DCDOCREVISION DR1 WHERE R.CDREVISION=DR1.CDREVISION  AND DR1.CDDOCUMENT=D.CDDOCUMENT AND FGSTATUS<>6)
	
	
05) SELECT COUNT(1) FROM DCDOCREVISION DR, DCDOCUMENT D WHERE DR.CDDOCUMENT = D.CDDOCUMENT AND D.FGSTATUS = 3 AND DR.FGCURRENT = 1
AND EXISTS (SELECT 1 FROM GNREVISION R WHERE DR.CDREVISION = R.CDREVISION AND R.FGSTATUS < 6)


--================================> Novo bloco otimizado para busca de valores no histórico
, (select dthistory from (SELECT max(HIS.TMHISTORY) as maxtime, his.DTHISTORY
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY) _sub) as dtinvestigador

, (SELECT str.DTEXECUTION FROM WFSTRUCT STR
WHERE str.idstruct = 'Atividade14102914543984' and str.idprocess=wf.idobject) as dtencerrou


, (select nmuser from (SELECT top 1 max(HIS.TMHISTORY) as maxtime, his.NMUSER
FROM WFSTRUCT STR, WFHISTORY HIS
WHERE  str.idstruct = 'Decisão141027113714228' and str.idprocess=wf.idobject
and HIS.IDSTRUCT = STR.IDOBJECT and his.idprocess = wf.idobject and HIS.FGTYPE = 9 and HIS.DTHISTORY = (
select max(HIS1.DTHISTORY)
FROM WFHISTORY HIS1
WHERE HIS1.IDSTRUCT = STR.IDOBJECT and his1.idprocess = wf.idobject and HIS1.FGTYPE = 9)
group by his.DTHISTORY, his.TMHISTORY, his.NMUSER
order by his.TMHISTORY DESC) _sub) as nminvestigador

, (SELECT WFA.NMUSER FROM WFSTRUCT STR, WFACTIVITY WFA
WHERE str.idstruct = 'Atividade14102914543984' and str.idprocess=wf.idobject and str.idobject = wfa.idobject) as nmencerrou

--========================================> Lista de funções/roles não mapeadas para treinamento
select *
from adposition pos
inner join addeptposition rel on rel.cdposition = pos.cdposition and rel.cddepartment = 164
where pos.cdposition not in (
select pos.CDPOSITION
from adposition pos
inner join addeptposition deppos on deppos.cdposition = pos.cdposition and deppos.cddepartment = 164
inner join GNCOURSEMAPITEM relc on relc.cdmapping = deppos.cdmapping
inner join TRCOURSE trc on trc.cdcourse = relc.cdcourse)
and FGPOSENABLED = 1
and IDPOSITION like 'br0050-%'

--========================================> DOcumento x CURSO
select distinct rev.iddocument
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument and doc.fgstatus <> 4 and doc.fgstatus <> 7 and doc.fgstatus <> 1
where rev.cdcategory=16
and rev.FGCURRENT = 1
and rev.cddocument not in (select cddocument from DCDOCCOURSE)

--=========================================> Lista de cursos que não foram mapeados
select idcourse
from trcourse trcm
where trcm.cdcourse not in (select trc.cdcourse
from TRCOURSE trc
inner join GNCOURSEMAPITEM relc on trc.cdcourse = relc.cdcourse)
and cdcoursetype=114 and fgenabled = 1

--========================================> Lista dos valores dos atributos
select atb.nmlabel, atv.nmattribute
from adattribvalue atv
inner join adattribute atb on atb.cdattribute = atv.cdattribute
where atv.CDATTRIBUTE in (select CDATTRIBUTE from adattribute where nmlabel like '%áreas responsáveis%' or nmlabel like '%áreas de abrangência%')
order by atb.NMLABEL, atv.nmattribute

--=======================================> CM IN - Paula Beraldo
select wf.idprocess, wf.nmprocess, wf.dtstart, gnrev.NMREVISIONSTATUS as status
, areamud.tbs001 as areamudanca, wf.NMUSERSTART as iniciador, dep.nmdepartment as areainiciador
, (select substring((
select ' | '+ substring((select nmlabel from EMATTRMODEL where oidentity = (select oid from EMENTITYMODEL where idname = 'tds015') and idname=coluna),10,250) as [text()]
from (select * from dyntds015 where OID = form.oid) s
unpivot (valor for coluna in (tds027, tds028, tds029, tds030, tds031, tds032, tds033, tds034, tds035, tds036, tds037, tds038, tds039, tds040, tds041, tds042, tds043, tds044, tds045, tds046, tds047, tds048, tds049, tds050, tds051, tds052, tds053, tds054, tds055, tds056, tds057, tds058, tds059, tds060, tds061, tds062, tds063, tds064, tds065, tds066, tds104)) as tt
where valor = 1 FOR XML PATH('')), 4, 1000)) as listamudanca
from DYNtds015 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
left outer join gnrevisionstatus gnrev on (wf.cdstatus = gnrev.cdrevisionstatus)
left join DYNtbs039 areamud on areamud.oid = form.OIDABCk8DABCghk
inner join aduser usr on usr.cduser = wf.cdUSERSTART
inner join aduserdeptpos rel on rel.cduser = usr.cduser and rel.FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment
where wf.cdprocessmodel = 3234

--================================> Documentos complementares (Francini)
select distinct *
from (
    select rev.CDCATEGORY, rev.iddocument, gnrev.idrevision, rev.cdrevision
    , 'cpd_'+ rev_comp.iddocument as complementar
    --, gnrev_comp.idrevision as idrevisioncomp
    from dcdocrevision rev
    inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
    join GNREVISIONASSOC assoc_comp on assoc_comp.cdrevision = rev.cdrevision
    join dcdocrevision rev_comp on rev_comp.cdrevision = assoc_comp.cdrevisionassoc
    inner join gnrevision gnrev_comp on gnrev_comp.cdrevision = rev_comp.cdrevision
    union all
    select rev.CDCATEGORY, rev.iddocument, gnrev.idrevision, rev.cdrevision
    , 'oeu_'+ rev_onde.iddocument as complementar
    --, gnrev_onde.idrevision as idrevisioncomp
    from dcdocrevision rev
    inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
    join GNREVISIONASSOC assoc_onde on assoc_onde.cdrevisionassoc = rev.cdrevision
    join dcdocrevision rev_onde on rev_onde.cdrevision = assoc_onde.cdrevision
    inner join gnrevision gnrev_onde on gnrev_onde.cdrevision = rev_onde.cdrevision
) _sub
where _sub.CDCATEGORY = (select cdcategory from dccategory where idcategory = '3 - FORM HUM BSB')
order by _sub.iddocument, _sub.idrevision

---> Newbegin

select rev.iddocument
from dcdocrevision rev
where rev.cdcategory in (275, 277, 302, 312, 314)
and rev.iddocument not in (
    select rev_comp.iddocument as complementar
    --, gnrev_comp.idrevision as idrevisioncomp
    from dcdocrevision rev
    inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
    join GNREVISIONASSOC assoc_comp on assoc_comp.cdrevision = rev.cdrevision
    join dcdocrevision rev_comp on rev_comp.cdrevision = assoc_comp.cdrevisionassoc
    inner join gnrevision gnrev_comp on gnrev_comp.cdrevision = rev_comp.cdrevision
    where rev.cdcategory = 274 or rev.cdcategory = 311
    union all
    select rev_onde.iddocument as complementar
    --, gnrev_onde.idrevision as idrevisioncomp
    from dcdocrevision rev
    inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
    join GNREVISIONASSOC assoc_onde on assoc_onde.cdrevisionassoc = rev.cdrevision
    join dcdocrevision rev_onde on rev_onde.cdrevision = assoc_onde.cdrevision
    inner join gnrevision gnrev_onde on gnrev_onde.cdrevision = rev_onde.cdrevision
    where rev.cdcategory = 274 or rev.cdcategory = 311
)

--=======================> Competares Completo
select rev.CDCATEGORY, rev.cdrevision, rev.cddocument
, rev.iddocument, gnrev.idrevision, cat.idcategory

, rev_comp.CDCATEGORY as CDCATEGORY_comp, rev_comp.cdrevision as cdrevision_comp
, rev_comp.cddocument as cddocument_comp
, rev_comp.iddocument as iddocument_comp, gnrev_comp.idrevision as idrevision_comp
, cat_comp.idcategory as idcategory_comp

from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dccategory cat on cat.cdcategory = rev.cdcategory
join GNREVISIONASSOC assoc_comp on assoc_comp.cdrevision = rev.cdrevision
join dcdocrevision rev_comp on rev_comp.cdrevision = assoc_comp.cdrevisionassoc
inner join gnrevision gnrev_comp on gnrev_comp.cdrevision = rev_comp.cdrevision
inner join dccategory cat_comp on cat_comp.cdcategory = rev_comp.cdcategory


--==============================================> Abrir uma análise (ishikawa)
https://sesuite.uniaoquimica.com.br/se/v89008/generic/gn_analisys/1.0/gntoolanalisys_list.php?resize=1&classname=pb_toolanalisys&cdprod=202&cdoccurrence=45739&cdoccurrence=45739&cdoccurrence=45739 
 
--================================> Inserir itens da grid de uma instância em outra
_insert into DYNtbs024 (oid, FGSYSTEM, FGENABLED, NRVERSION, OIDREVISIONFORM, BNUPDATED, NMUSERUPDATE, tbs001, tbs002, tbs003, tbs004, tbs005, tbs006, tbs007, tbs008OIDABCIQeABC45y)
select 'idprocessdestino=idprocessorigem-'+cast((coalesce((select coalesce(max(cast(substring(oid,21,25) as integer)), 0) as oidn from DYNtbs024 where oid like 'idprocessdestino=idprocessorigem-%'),0) + ROW_NUMBER() over (order by oid)) as varchar) as oid
       , fgsystem, fgenabled, nrversion, OIDREVISIONFORM, bnupdated
       , '<idLogin_usuário_logado>' as NMUSERUPDATE
       , tbs001, tbs002, tbs003, tbs004, tbs005, tbs006, tbs007, tbs008
       , 'oiddestino' as OIDABCIQeABC45y
from DYNtbs024
where OIDABCIQeABC45y = 'oidorigem'

--=========================================> Safety Obs
select wf.idprocess, wf.nmprocess, wf.dtstart+tmstart as dtstart, wf.dtfinish+tmfinish as dtfinish
, case wf.fgstatus
    when 1 then 'Em andamento'
    when 2 then 'Suspenso'
    when 3 then 'Cancelado'
    when 4 then 'Encerrado'
    when 5 then 'Bloqueado para edição'
end as procstatus
, obstype.ua001 as type, obstopic.ua001 as topic, obsloc.ua001 as location, coalesce(obsstatus.ua001, 'N/A') as finalstatus
, case form.ua002
    when 1 then 'Yes'
    when 2 then 'No'
end as resolved_by_observer
, 1 as qt
from DYNua060 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join DYNua062 obstype on obstype.oid = form.OIDABCPDUHLYO05TNO
left join DYNua063 obsstatus on obsstatus.oid = form.OIDABCIEG083GK2BL2
inner join DYNua064 obstopic on obstopic.oid = form.OIDABC5DPJ5UZQEJ7Z
inner join DYNua065 obsloc on obsloc.oid = form.OIDABCH7ETPYIH2KXZ
where wf.cdprocessmodel = 4872 and wf.fgstatus in (1,4)

--=========================================> Wagner Fumagalli

select form.itsm006 as Servico, count(wf.idprocess) as Quant
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
where form.itsm006 in ('ITSM-CS-0000026','ITSM-CS-0000027','ITSM-CS-0000031','ITSM-CS-0000032','ITSM-CS-0000035','ITSM-CS-0000036','ITSM-CS-0000037','ITSM-CS-0000038','ITSM-CS-0000039','ITSM-CS-0000040','ITSM-CS-0000046','ITSM-CS-0000051','ITSM-CS-0000058','ITSM-CS-0000190','ITSM-CS-0000201','ITSM-CS-0000208','ITSM-CS-0000230','ITSM-CS-0000236','ITSM-CS-0000237','ITSM-CS-0000244','ITSM-CS-0000245','ITSM-CS-0000276','ITSM-CS-0000304','ITSM-CS-0000311','ITSM-CS-0000359','ITSM-CS-0000360','ITSM-CS-0000365','ITSM-CS-0000383','ITSM-CS-0000392','ITSM-CS-0000403','ITSM-CS-0000411','ITSM-CS-0000412','ITSM-CS-0000413','ITSM-CS-0000419','ITSM-CS-0000425','ITSM-CS-0000428','ITSM-CS-0000786','ITSM-CS-0000805')
and wf.fgstatus < 4
group by form.itsm006
with rollup
order by form.itsm006


--=========================================> Safety Inc
select wf.idprocess, wf.nmprocess, wf.dtstart+tmstart as dtstart, wf.dtfinish+tmfinish as dtfinish
, case wf.fgstatus
    when 1 then 'Em andamento'
    when 2 then 'Suspenso'
    when 3 then 'Cancelado'
    when 4 then 'Encerrado'
    when 5 then 'Bloqueado para edição'
end as procstatus
, case form.UA001
    when 1 then 'Employe'
    when 2 then 'Contractor/Guest'
end as envolved
, (cast(form.UA004 as datetime) + CAST(form.UA005 / 86400.0 as datetime)) as dtoccurrence
, case form.ua006
    when 1 then 'Overtime' else 'Worktime' end as wtime
, incloc.ua001 as location, inceqtp.ua001 as eqtype, incfailuremd.ua001 as failuremode, inctype.ua001 as inctype, increleaseloc.ua001 as releaseloc, coalesce(inclevel.ua001, 'N/A') as inclevel
, 1 as qt
from DYNua061 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
INNER JOIN INOCCURRENCE INC ON (wf.IDOBJECT = INC.IDWORKFLOW)
inner join DYNua065 incloc on incloc.oid = form.OIDABCZ6JVUDN25I7U
inner join DYNua066 inceqtp on inceqtp.oid = form.OIDABCZP0NQD9AM1AI
inner join DYNua067 incfailuremd on incfailuremd.oid = form.OIDABC8FBMPRAZC9GY
inner join DYNua068 inctype on inctype.oid = form.OIDABCEYNGGJ1JHL4W
inner join DYNua069 increleaseloc on increleaseloc.oid = form.OIDABCS6EPH7VXUDWO
left join DYNua070 inclevel on inclevel.oid = form.OIDABC22KVR1WETMCS
where wf.cdprocessmodel = 4884 and wf.fgstatus in (1,4)

--=========================================================> Projetos
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
, p.QTACTPERC as "Percentual realizado"
, prio.idPRIORITY
, case when ((p.DTPLANEND < getdate() and p.DTACTEND is null) or (ati.DTPLANEND < getdate() and ati.DTACTEND is null)) then 'Atraso' else 'Em dia' end statusprj
, 1 as qtd
, P.NMIDTASK +'/'+ ati.NMIDTASK as "Atividade em atraso", ati.NMTASK as "Nome da atividade", ati.DTPLANST as "Data fim planejado", usrati.nmuser, ati.QTACTPERC as "% realizado da atividade"
, (select p1.NMIDTASK +' - '+ p1.NMTASK from prtask p1 where cdtask = (select cdbasetask from prtask pr where pr.NMIDTASK = p.NMIDTASK and pr.FGTASKTYPE = 5 and pr.cdbasetask in (select cdtask from prtask where cdtasktype = 18 and nmidtask in ('PTI-0001','PTI-0002','PTI-0003','PTI-005') and cdtask = cdbasetask))) as programa
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
left join PRTASK ATI on P.CDTASK = ATI.CDBASETASK and ati.NMIDTASK <> P.NMIDTASK and (ati.DTPLANEND < getdate() and ati.DTACTEND is null)
--and ati.FGTASKREADY = 1
left join aduser usrati on usrati.cduser = ati.CDTASKRESP
where P.FGTASKTYPE = 1 and P.NRTASKINDEX = 0
and exists (select 1 from prtask pr where pr.NMIDTASK = p.NMIDTASK and pr.FGTASKTYPE = 5 and pr.cdbasetask in (select cdtask from prtask where cdtasktype = 18 and nmidtask in ('PTI-0001','PTI-0002','PTI-0003','PTI-005') and cdtask = cdbasetask))

--===================================> Novo indicador de projetos:
select P.NMIDTASK AS idprojeto, P.NMTASK AS nmprojeto
, case p.FGPHASE
    when 1 then 'Planejamento'
    when 2 then 'Execução'
    when 3 then 'Verificação'
    when 4 then 'Encerrado'
    when 5 then 'Aprovação'
    when 6 then 'Suspenso'
    when 7 then 'Cancelado'
end fase
, p.DTPLANST as iniplanproj, p.DTPLANEND as fimplanproj
, p.DTREPLST as inireplanproj, p.DTREPLEND as fimreplanproj
, p.DTACTST as inirealproj, p.DTACTEND as fimrealproj
, coalesce(pontoplan, 100) as pontoplan, pontoreplan, coalesce(pontoreal, 0) as pontoreal
, progr.nmidtask as programa
from PRTASK P
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
inner join prtask prog on prog.nmidtask = p.nmidtask and prog.fgtasktype = 5 and prog.cdtasktype = 4
inner join prtask progr on progr.cdtask = prog.CDBASETASK
inner join (select idprojeto
, ROUND((sum(duraplan) / sum(durplanact)) * 100,0,0) as pontoplan
, ROUND((sum(durareplan) / sum(durreplanact)) * 100,0,0) as pontoreplan
, ROUND((sum(durareal) / sum(durrealact)) * 100,0,0) as pontoreal
from (select P.NMIDTASK AS idprojeto
, act.QTPLANDUR as durplanact
, act.QTREPLDUR as durreplanact
, act.QTACTDUR as durrealorigact
, case when (act.QTACTDUR = 0 or act.QTACTDUR is null) then act.QTREPLDUR else act.QTACTDUR end as durrealact
, case when (act.DTPLANST > getdate() and act.DTPLANEND > getdate()) then 0
       when (act.DTPLANST < getdate() and act.DTPLANEND < getdate()) then act.QTPLANDUR
       else coalesce((SELECT (DATEDIFF(dd,act.DTPLANST, getdate())+1)
        -(DATEDIFF(wk,act.DTPLANST, getdate())*2)
        -(CASE WHEN DATENAME(dw, act.DTPLANST) = 'Sunday' THEN 1
          ELSE 0 END)
        -(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1
          ELSE 0 END)
        - (select count(1)
            from gncalendar cal
            inner join GNCALEXCEPTION cale on cale.cdcalendar = cal.cdcalendar
            where cal.idcalendar = 'TI_DU'
            and dtday between act.DTPLANST and getdate())), 0) end duraplan
, case when (act.DTREPLST > getdate() and act.DTREPLEND > getdate()) then 0
       when (act.DTREPLST < getdate() and act.DTREPLEND < getdate()) then act.QTREPLDUR
       else coalesce((SELECT (DATEDIFF(dd,act.DTREPLST, getdate())+1)
        -(DATEDIFF(wk,act.DTREPLST, getdate())*2)
        -(CASE WHEN DATENAME(dw, act.DTREPLST) = 'Sunday' THEN 1
          ELSE 0 END)
        -(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1
          ELSE 0 END)
        - (select count(1)
            from gncalendar cal
            inner join GNCALEXCEPTION cale on cale.cdcalendar = cal.cdcalendar
            where cal.idcalendar = 'TI_DU'
            and dtday between act.DTREPLST and getdate())), 0) end durareplan
, case when (act.DTACTST > getdate() and act.DTACTEND > getdate()) then 0
       when (act.DTACTST <= getdate() and act.DTACTEND <= getdate()) then act.QTACTDUR
       else (((act.QTACTPERC * case when (act.QTACTDUR = 0 or act.QTACTDUR is null) then act.QTREPLDUR else act.QTACTDUR end) / (
    coalesce((SELECT (DATEDIFF(dd,act.DTACTST, getdate())+1)
        -(DATEDIFF(wk,act.DTACTST, getdate())*2)
        -(CASE WHEN DATENAME(dw, act.DTACTST) = 'Sunday' THEN 1
          ELSE 0 END)
        -(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1
          ELSE 0 END)
        - (select count(1)
            from gncalendar cal
            inner join GNCALEXCEPTION cale on cale.cdcalendar = cal.cdcalendar
            where cal.idcalendar = 'TI_DU'
            and dtday between act.DTACTST and getdate())), 0) * 100)) *
    (coalesce((SELECT (DATEDIFF(dd,act.DTACTST, getdate())+1)
        -(DATEDIFF(wk,act.DTACTST, getdate())*2)
        -(CASE WHEN DATENAME(dw, act.DTACTST) = 'Sunday' THEN 1
          ELSE 0 END)
        -(CASE WHEN DATENAME(dw, getdate()) = 'Saturday' THEN 1
          ELSE 0 END)
        - (select count(1)
            from gncalendar cal
            inner join GNCALEXCEPTION cale on cale.cdcalendar = cal.cdcalendar
            where cal.idcalendar = 'TI_DU'
            and dtday between act.DTACTST and getdate())), 0) / case when (act.QTACTDUR = 0 or act.QTACTDUR is null) then act.QTREPLDUR else act.QTACTDUR end) *
        case when (act.QTACTDUR = 0 or act.QTACTDUR is null) then act.QTREPLDUR else act.QTACTDUR end) end as durareal
from PRTASK P
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
inner join prtask prog on prog.nmidtask = p.nmidtask and prog.fgtasktype = 5 and prog.cdtasktype = 4
inner join prtask progr on progr.cdtask = prog.CDBASETASK
inner join prtask act on act.cdbasetask = p.cdtask and act.NMIDTASK <> P.NMIDTASK and not exists (select 1 from prtask acto where acto.CDTASKOWNER = act.cdtask)
where p.cdtasktype = 4 and P.FGTASKTYPE = 1 and P.NRTASKINDEX = 0 and prog.cdtask <> prog.cdbasetask and p.FGPHASE between 2 and 5 and progr.FGPHASE between 2 and 5
and case when (act.QTACTDUR = 0 or act.QTACTDUR is null) then act.QTREPLDUR else act.QTACTDUR end <> 0
and (progr.NMIDTASK like '%'+ right(cast(datepart(yy, getdate()) as varchar), 2) +'%' or
	 progr.NMIDTASK like '%'+ right(cast(datepart(yy, dateadd(year,-1,getdate())) as varchar), 2) +'%')
) _sub
group by idprojeto) kpi on kpi.idprojeto = P.NMIDTASK
where p.cdtasktype = 4 and P.FGTASKTYPE = 1 and FGPHASE between 2 and 5
--and P.NMIDTASK in ('PRJ_TI-00000468', 'PRJ_TI-00000532', 'PRJ_TI-00000552')


--==================================> info do siscop
SELECT apo_Data, apo_HoraTrabalhada
, sol_ID = ( select sol_id from tbl_SOA_SolicitacaoAtividade where soa_ID = APO.soa_ID)
, ope_Nome = GCMONLINE_V300.dbo.scRetornaNomeFuncionario(OPE.gcmonline_usr_id)
, apo_Observacao
From tbl_APO_AtividadeApontamento As APO
INNER JOIN tbl_OPE_Operador AS OPE ON APO.ope_ID = OPE.ope_ID
WHERE ( APO.set_ID =  34 OR APO.set_ID = 52 OR APO.set_ID = 56 ) and APO.apo_Data >= '2020-01-01 00:00.001' and APO.apo_Data <= '2020-01-31 23:59.999'
union all
SELECT apo_Data, apo_HoraTrabalhada
, sol_ID = ( select sol_id from tbl_SOA_SolicitacaoAtividadeHistorico where soa_ID = APO.soa_ID)
, ope_Nome = GCMONLINE_V300.dbo.scRetornaNomeFuncionario(OPE.gcmonline_usr_id)
, apo_Observacao
From tbl_APO_AtividadeApontamentoHistorico As APO
INNER JOIN tbl_OPE_Operador AS OPE ON APO.ope_ID = OPE.ope_ID
WHERE ( APO.set_ID =  34 OR APO.set_ID = 52 OR APO.set_ID = 56 )  and APO.apo_Data >= '2020-01-01 00:00.001' and APO.apo_Data <= '2020-01-31 23:59.999'
order by ope_Nome
----
SELECT apo_Data, apo_HoraTrabalhada
, sol_ID = ( select sol_id from tbl_SOA_SolicitacaoAtividade where soa_ID = APO.soa_ID)
, ope_Nome = GCMONLINE_V300.dbo.scRetornaNomeFuncionario(OPE.gcmonline_usr_id)
, apo_Observacao
From tbl_APO_AtividadeApontamento As APO
INNER JOIN tbl_OPE_Operador AS OPE ON APO.ope_ID = OPE.ope_ID
WHERE ( APO.set_ID =  34 OR APO.set_ID = 52 OR APO.set_ID = 56 )
union all
SELECT apo_Data, apo_HoraTrabalhada
, sol_ID = ( select sol_id from tbl_SOA_SolicitacaoAtividadeHistorico where soa_ID = APO.soa_ID)
, ope_Nome = GCMONLINE_V300.dbo.scRetornaNomeFuncionario(OPE.gcmonline_usr_id)
, apo_Observacao
From tbl_APO_AtividadeApontamentoHistorico As APO
INNER JOIN tbl_OPE_Operador AS OPE ON APO.ope_ID = OPE.ope_ID
WHERE ( APO.set_ID =  34 OR APO.set_ID = 52 OR APO.set_ID = 56 ) 
---
select coord = GCMONLINE_V300.dbo.scRetornaNomeFuncionario(SETor.set_Coordenador), SETor.set_ID, SETor.set_Descricao, SETor.set_Status
from tbl_SET_Setor SETor
where SETor.set_ID = APO.set_ID
---
select * from (
SELECT apo_Data, apo_HoraTrabalhada
, (select sol_id from tbl_SOA_SolicitacaoAtividade where soa_ID = APO.soa_ID) as sol_ID
, GCMONLINE_V300.dbo.scRetornaNomeFuncionario(OPE.gcmonline_usr_id) collate SQL_Latin1_General_CP1_CI_AS as ope_Nome
, apo_Observacao
, (select distinct sol.cat_descricao from tbl_BI_Solicitacao sol where sol.sol_ID = (select sol_id from tbl_SOA_SolicitacaoAtividadeHistorico where soa_ID = APO.soa_ID)) as Categoria
, (select coord = GCMONLINE_V300.dbo.scRetornaNomeFuncionario(SETor.set_Coordenador) from tbl_SET_Setor SETor where SETor.set_ID = APO.set_ID) collate SQL_Latin1_General_CP1_CI_AS as Coordenador
, (select distinct sol.gcmonline_gru_descricao from tbl_BI_Solicitacao sol where sol.sol_ID = (select sol_id from tbl_SOA_SolicitacaoAtividade where soa_ID = APO.soa_ID)) as departamentoSol
, 1 as qtd
From tbl_APO_AtividadeApontamento As APO
INNER JOIN tbl_OPE_Operador AS OPE ON APO.ope_ID = OPE.ope_ID
union all
SELECT apo_Data, apo_HoraTrabalhada
, (select sol_id from tbl_SOA_SolicitacaoAtividadeHistorico where soa_ID = APO.soa_ID) as sol_ID
, GCMONLINE_V300.dbo.scRetornaNomeFuncionario(OPE.gcmonline_usr_id) collate SQL_Latin1_General_CP1_CI_AS as ope_Nome
, apo_Observacao
, (select distinct sol.cat_descricao from tbl_BI_Solicitacao sol where sol.sol_ID = (select sol_id from tbl_SOA_SolicitacaoAtividadeHistorico where soa_ID = APO.soa_ID)) as Categoria
, (select coord = GCMONLINE_V300.dbo.scRetornaNomeFuncionario(SETor.set_Coordenador) from tbl_SET_Setor SETor where SETor.set_ID = APO.set_ID) collate SQL_Latin1_General_CP1_CI_AS as Coordenador
, (select distinct sol.gcmonline_gru_descricao from tbl_BI_Solicitacao sol where sol.sol_ID = (select sol_id from tbl_SOA_SolicitacaoAtividadeHistorico where soa_ID = APO.soa_ID)) as departamentoSol
, 1 as qtd
From tbl_APO_AtividadeApontamentoHistorico As APO
INNER JOIN tbl_OPE_Operador AS OPE ON APO.ope_ID = OPE.ope_ID
) _sub
where categoria is not null

--=======================================> Lista de docuemnto de manutenção que foram liberados no dia anterior
select rev.iddocument, his.dtaccess+his.tmaccess as quando, usr.nmuser, usr.dsuseremail
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION) and stag.FGSTAGE = 1
inner join DCAUDITSYSTEM his on his.NMDOCTO = rev.iddocument and his.fgtype = 6
inner join aduser usr on usr.cduser = stag.cduser
where rev.fgcurrent = 1 and doc.fgstatus = 2 and rev.cdcategory in (161,170,172,367) and his.dtaccess+his.tmaccess > dateadd(dd,-1,getdate())
order by rev.iddocument
--===================> Transaction / Rollback
BEGIN TRANSACTION
comando SQL

ROLLBACK TRANSACTION / COMMIT
--======================================> Documentos com identificador repetido
select distinct rev.iddocument from dcdocrevision rev
where (select count(rev1.cddocument) from dcdocrevision rev1 where rev1.cddocument <> rev.cddocument and rev1.iddocument = rev.iddocument) > 1
--===================================> Lista de documentos de projetos para cobrar
select * from (
select CAST(CAST(ROUND(attrib.vlvalue,0) as int) as varchar(50)) as chamado
, stagio.fase, stagio.ciclo, stagio.dtdeadline, stagio.executor
, gnrev.idrevision, rev0.iddocument, rev0.nmtitle, gnrev.dtrevrelease as dtrev
, case when (rev0.fgcurrent = 1 and doc.fgstatus not in (1,4)) then 'Vigente' when doc.fgstatus = 4 then 'Cancelado'
  when (rev0.fgcurrent = 1 and doc.fgstatus = 1) then 'Em fluxo de Emissão' when rev0.fgcurrent = 2 then
  case when doc.fgstatus in (1, 3, 5) and rev0.cdrevision = (select max(cdrevision) from dcdocrevision
  where CDDOCUMENT = rev0.cddocument) then 'Em fluxo de Revisão' else 'Obsoleto' end end statusrev
, (select nmattribute from ADATTRIBVALUE where cdattribute = 215 and cdvalue = (select cdvalue from dcdocumentattrib where cdattribute = 215 and cdrevision = rev0.cdrevision)) as tipodoc
, 1 as quantidade
from dcdocumentattrib attrib
inner join dcdocument doc on doc.cddocument = attrib.cddocument
inner join dcdocrevision rev0 on rev0.cdrevision = attrib.cdrevision
inner join gnrevision gnrev on gnrev.cdrevision = attrib.cdrevision
left join (
    select rev.iddocument, gnrev.cdrevision
, case stag.FGSTAGE when 1 then 'Elaboração' when 2 then 'Consenso' when 3 then 'Aprovação' when 4 then 'Homologação' when 5 then 'Liberação' when 6 then ' Encerramento' end fase
, stag.NRCYCLE as ciclo, stag.dtdeadline as dtdeadline
, case when stag.CDUSER is null then case when stag.cddepartment is null then case when cdposition is null then case when cdteam is null then 'NA' 
  else (select nmteam from adteam where cdteam = stag.cdteam) end else (select nmposition from adposition where cdposition = stag.cdposition) end else (select nmdepartment from addepartment where cddepartment = stag.cddepartment) end else (select nmuser from aduser where cduser = stag.cduser) end Executor
from dcdocrevision rev
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
left JOIN GNREVISIONSTAGMEM stag ON gnrev.CDREVISION = stag.CDREVISION AND stag.dtdeadline IS NOT NULL and stag.nrcycle = (select max(stagx.nrcycle) from GNREVISIONSTAGMEM stagx where stagx.CDREVISION = gnrev.CDREVISION)
where stag.dtapproval is null and ((rev.fgcurrent = 1 and doc.fgstatus = 1) or
(
(rev.fgcurrent = 2) and (doc.fgstatus in (1, 3, 5) and rev.cdrevision = (select max(cdrevision) from dcdocrevision where CDDOCUMENT = rev.cddocument)))
)
) stagio on stagio.cdrevision = rev0.cdrevision
where attrib.CDATTRIBUTE = 235
) _sub
where statusrev in ('Em fluxo de Revisão', 'Em fluxo de Emissão')
and chamado in (select substring(nmtask, 2, charindex(' ',nmtask) -2)
from prtask
where cdtaskowner = (select cdtask from prtask where nmidtask = 'PRJ_TI-00000022')
and QTACTPERC < 100 and nmtask like '#%')
order by chamado, iddocument

--============================> Informações de configuração do processo de acesso
Select  form.p001 as Peril_acesso, p002 as Equipe_1, p008 as Equipe_2, p003 as PapelFuncional, p004 as Grupo_Acesso1, p005 as Grupo_acesso2, unidade_s.sigla as Sigla_unidade, modulo_s.sigla as Sigla_Processo
, 1 as quantidade
from DYNapefilacess form
left join DYNsolunid unidade_s on unidade_s.oid = form.OIDABCFUND8BQJSKMX
left join DYNmodulo modulo_s on modulo_s.oid = form.OIDABC2BI4S2NXPNEW

--==================================================> Fumagalli - Worktime dos chamados
select forms.itsm001, forms.itsm002p as objeto, forms.itsm003p as servico, forms.itsm004p as compl, forms.itsm021
, avg((QTSLATOTALTIMECAL - QTSLAPAUSETIMECAL + 60) / 3600) as worktime_horas
, count(wf.idprocess) as qtchamados
, case forms.itsm007
    when 1 then 'Solicitação'
    when 2 then 'Incidente'
    when 3 then 'Mudança'
    when 4 then 'Projeto'
    when 5 then 'Problema'
    when 6 then 'Evento'
end as tipo
from wfprocess wf
inner join gnassocformreg gnf on (wf.cdassocreg = gnf.cdassoc)
inner join DYNitsm form on (gnf.oidentityreg = form.oid)
inner join DYNitsm001 forms on forms.itsm001 = form.itsm006
inner join GNSLACONTROL gnslactrl on gnslactrl.CDSLACONTROL = wf.CDSLACONTROL
where cdprocessmodel=5251 and wf.fgstatus = 4 and forms.itsm033 <> 1
group by forms.itsm001, forms.itsm002p, forms.itsm003p, forms.itsm004p, forms.itsm021,forms.itsm007
order by forms.itsm001

--==============================================> SLA de instancias fechadas e outros dados do processo
select p.idprocess
, CASE WHEN GNR.NRORDER IS NULL THEN -999999999 ELSE GNR.NRORDER END AS NRORDERPRIORITY
, CASE P.FGSLASTATUS WHEN 10 THEN 'Play' WHEN 30 THEN 'Pause' WHEN 40 THEN 'Stop' END AS IDSLASTATUS
, (SELECT MAX(IDLEVEL) FROM GNSLACTRLHISTORY WHERE CDSLACONTROL=P.CDSLACONTROL AND FGCURRENT=1) AS IDLEVEL
,CONVERT(DATETIME, SWITCHOFFSET(CAST(DATEADD(MINUTE, (CAST(SLAC.BNSLAFINISH AS BIGINT) / 1000)/60, '1970-01-01') AS DATETIMEOFFSET),'-03:00')) AS DTSLAFINISH
,CASE WHEN ( SLAC.QTTIMEFRSTCAL + SLAC.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ) > 100 THEN 100 ELSE
 ROUND (( SLAC.QTTIMEFRSTCAL + SLAC.QTTIMECAL ) * 100 / (SLALC.QTRESOLUTIONTIME * 60 + 60 ), 2) END AS SLAPERCENT
from wfprocess p
INNER JOIN GNSLACONTROL SLAC ON (P.CDSLACONTROL = SLAC.CDSLACONTROL)
left JOIN GNEVALRESULTUSED GNRUS ON (GNRUS.CDEVALRESULTUSED=P.CDEVALRSLTPRIORITY) 
left JOIN GNEVALRESULT GNR ON (GNRUS.CDEVALRESULT=GNR.CDEVALRESULT)
--inner JOIN GNSLACONTROL SLACTRL ON (P.CDSLACONTROL=SLACTRL.CDSLACONTROL)
inner JOIN GNSLACTRLHISTORY SLAH ON (SLAC.CDSLACONTROL = SLAH.CDSLACONTROL AND SLAH.FGCURRENT = 1) 
inner JOIN GNSLALEVEL SLALC ON (SLAH.CDLEVEL = SLALC.CDLEVEL)
where P.CDPRODAUTOMATION = 39 --and P.FGSTATUS < 3

--=================================> Projetos
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
, case when p.QTACTPERC = 100 then 100
       when p.DTREPLST = p.DTREPLEND then 0
       else cast(datediff(dd, p.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTREPLST, p.DTREPLEND) as decimal(7,2)) * 100
  end as "% replanejado do projeto"
, case when p.QTACTPERC = 100 then 1
       when p.DTPLANST = p.DTPLANEND then 0
       else coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100)
  end as IDP
, prio.idPRIORITY as Prioridade
, case when p.DTPLANST = p.DTPLANEND then 'N/A'
       when ((cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) - p.QTACTPERC <= 0) then 'No prazo'
       else 'Atrasado'
  end statusPrj
, 1 as qtd
, (select nmidtask from prtask where cdtask = prog.CDBASETASK) as programa
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
inner join prtask prog on prog.nmidtask = p.nmidtask and prog.fgtasktype = 5 and prog.cdtasktype = 4
where p.cdtasktype = 4 and P.FGTASKTYPE = 1 and P.NRTASKINDEX = 0 and prog.cdtask <> prog.cdbasetask
--and prog.cdbasetask=7072
--cdtasktype in (select cdtasktype from prtasktype where CDTASKTYPEOWNER = 15)

--========================================> Programa
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
, coalesce(p.QTACTPERC, 0) as "% realizado do programa"
, case when p.QTACTPERC = 100 then 100
       when p.DTPLANST = p.DTPLANEND then 0
       else cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100
  end as "% planejado do programa"
, case when p.QTACTPERC = 100 then 100
       when p.DTREPLST = p.DTREPLEND then 0
       else cast(datediff(dd, p.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTREPLST, p.DTREPLEND) as decimal(7,2)) * 100
  end as "% replanejado do programa"
, case when p.QTACTPERC = 100 then 1
       when p.DTPLANST = p.DTPLANEND then 0
       else coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100)
  end as "IDP médio"
, prio.idPRIORITY as Prioridade
, case when p.DTPLANST = p.DTPLANEND then 'N/A'
       when ((cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) - p.QTACTPERC <= 0) then 'No prazo'
       else 'Atrasado'
  end statusProg
, 1 as qtd
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
where p.cdtasktype = 25 and P.FGTASKTYPE = 5 and p.cdtask = p.cdbasetask


-------------------------------------------------

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
/*
, coalesce(p.QTACTPERC, 0) as "% realizado do programa"
, cast(case when p.QTACTPERC = 100 then 100
       when p.DTPLANST = p.DTPLANEND then 0
       else cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100
  end as decimal(7,2)) as "% planejado do programa"
, cast(case when p.QTACTPERC = 100 then 100
       when p.DTREPLST = p.DTREPLEND then 0
       else cast(datediff(dd, p.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTREPLST, p.DTREPLEND) as decimal(7,2)) * 100
  end as decimal(7,2)) as "% replanejado do programa"
, cast(case when p.QTACTPERC = 100 then 1
       when p.DTPLANST = p.DTPLANEND then 0
       else coalesce(p.QTACTPERC, 0) / (cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100)
  end as decimal(7,2)) as IDP
, prio.idPRIORITY as Prioridade
, case when p.DTPLANST = p.DTPLANEND then 'N/A'
       when ((cast(datediff(dd, p.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, p.DTPLANST, p.DTPLANEND) as decimal(7,2)) * 100) - p.QTACTPERC <= 0) then 'No prazo'
       else 'Atrasado'
  end statusProg
*/
, (select cast(avg(case when proj.QTACTPERC = 100 then 100
               when proj.DTPLANST = proj.DTPLANEND then 0
               else coalesce(cast(datediff(dd, proj.DTPLANST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTPLANST, proj.DTPLANEND) as decimal(7,2)) * 100, 0)
          end) as decimal(7,2)) as porPlan
  from prtask proj
  where (coalesce(proj.QTACTPERC, 0) <> 0 and proj.DTPLANST <= getdate()) and proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.nmidtask in (
        select NMIDTASK
        from prtask proj1
        where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask)) porPlanPrj
, (select cast(avg(case when proj.QTACTPERC = 100 then 100
               when proj.DTREPLST = proj.DTREPLEND then 0
               else coalesce(cast(datediff(dd, proj.DTREPLST, getdate()) as decimal(7,2)) / cast(datediff(DD, proj.DTREPLST, proj.DTREPLEND) as decimal(7,2)) * 100, 0)
          end) as decimal(7,2)) as porReplan
  from prtask proj
  where (coalesce(proj.QTACTPERC, 0) <> 0 and proj.DTREPLST <= getdate()) and proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.nmidtask in (
        select NMIDTASK
        from prtask proj1
        where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask)) porReplanPrj
, (select cast(avg(coalesce(proj.QTACTPERC, 0)) as decimal(7,2)) as porReal
  from prtask proj
  where (coalesce(proj.QTACTPERC, 0) <> 0 and coalesce(proj.DTREPLST, proj.DTPLANST) <= getdate()) and proj.fgtasktype = 1 and proj.cdtasktype = 4 and proj.nmidtask in (
        select NMIDTASK
        from prtask proj1
        where proj1.cdtask <> proj1.cdbasetask and proj1.cdtasktype = 4 and proj1.fgtasktype = 5 and proj1.cdbasetask = p.cdtask)) porRealPrj
, 1 as qtd
from PRTASK P
inner join aduser usr on usr.cduser = p.CDTASKRESP
inner join prpriority prio on prio.cdpriority = p.cdpriority
inner join prtasktype pty on pty.cdtasktype = p.cdtasktype
where p.cdtasktype = 25 and P.FGTASKTYPE = 5 and p.cdtask = p.cdbasetask

--=================================================
select mtd.nmmetadata
, case
    when mtd.cdattribute is null then
        case fgtype
            when 1 then 
                case fgitem
                    when 3 then 'Identificador do Documento'
                    when 4 then 'Título do Documento'
                    when 5 then 'Revisão do Documento'
                    when 6 then 'Data da revisão do Documento' + ' - Formato: ' + cast(mtd.fgdateformat as varchar)
                    when 13 then 'Assinatura digital do Documento'
                    when 14 then 'Situação do Documento'
                end
            when 5 then 
                case fgitem
                    when 1 then 'Login do Usuário logado'
                    when 2 then 'Nome do Usuário logado'
                end
            when 6 then 
                case fgitem
                    when 1 then 'Situação da Revisão'
                    when 4 then 'Dados do Elaborador da Revisão' + ' - Formato: ' + cast(mtd.fgformat as varchar)
                    when 5 then 'Dados do Consensador da Revisão' + ' - Formato: ' + cast(mtd.fgformat as varchar)
                    when 6 then 'Dados do Aprovador da Revisão' + ' - Formato: ' + cast(mtd.fgformat as varchar)
                    when 7 then 'Dados do Homologador da Revisão' + ' - Formato: ' + cast(mtd.fgformat as varchar)
                    when 8 then 'Histórico de alterações da Revisão' + ' - Formato: ' + cast(mtd.fgformat as varchar)
                end
        end
    else (select 'Atributo: '+ nmlabel from adattribute where cdattribute = mtd.cdattribute)
  end as tipo
--, mtd.*
from GNMETADATA mt
inner join GNMETADATAFIELD mtd on mtd.cdmetadata = mt.cdmetadata
where mt.cdmetadata = 1
order by fgtype, fgitem,fgformat,fgdateformat

--=====================> Ativos com manutenção
select obj.cdobject, obj.idobject, obj.nmobject
, FORMAT (manut.dtregister, 'dd/MMM/yyyy') as dtregister
, FORMAT (manut.dtcheckout, 'dd/MMM/yyyy') as dtcheckout
, FORMAT (manut.dtcheckin, 'dd/MMM/yyyy') as dtcheckin
, (select count(*) as quant
   from ASMAINTEVENT man
   where man.cdasset = manut.cdasset and man.cdrevision = manut.cdrevision
) as quantlav
from OBOBJECT OBJ 
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION=OBJ.CDREVISION)
INNER JOIN OBOBJECTGROUP OBJGRP ON (OBJGRP.CDOBJECTGROUP=OBJ.CDOBJECT) 
INNER JOIN OBOBJECTTYPE OBJTYPE ON (OBJTYPE.CDOBJECTTYPE=OBJGRP.CDOBJECTTYPE)
left join ASMAINTEVENT manut on manut.cdasset = asast.cdasset and manut.cdrevision = asast.cdrevision
where OBJTYPE.cdobjecttype = 14

--=============================================> Ativos com parada
select obj.cdobject, obj.idobject, obj.nmobject
, FORMAT (parada.dtinsert, 'dd/MMM/yyyy') as dtinsert
, FORMAT (parada.dtstart, 'dd/MMM/yyyy') as dtstart
, FORMAT (parada.dtend, 'dd/MMM/yyyy') as dtend
, (select count(*) as quant
   from ASDOWNTIME man
   where man.cdasset = parada.cdasset and man.cdrevision = parada.cdrevision
) as quantlav
from OBOBJECT OBJ 
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION=OBJ.CDREVISION)
INNER JOIN OBOBJECTGROUP OBJGRP ON (OBJGRP.CDOBJECTGROUP=OBJ.CDOBJECT) 
INNER JOIN OBOBJECTTYPE OBJTYPE ON (OBJTYPE.CDOBJECTTYPE=OBJGRP.CDOBJECTTYPE)
left join ASDOWNTIME parada on parada.cdasset = asast.cdasset and parada.cdrevision = asast.cdrevision
where OBJTYPE.cdobjecttype = 14
--==============================================> Ativos (computadores)
SELECT OBJ.CDOBJECT, OBJ.CDREVISION, OBJ.IDOBJECT, OBJ.NMOBJECT, OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT AS NM_FULLNAME, OBJ.FGCURRENT, OBJ.FGAPPLICATION, OBJ.FGREADY, OBJGRP.CDOBJECTGROUP, OBJGRP.FGSTATUS
, CASE 
    WHEN OBJGRP.FGSTATUS=1 THEN '#{103645}'
    WHEN OBJGRP.FGSTATUS=2 THEN '#{104235}'
    WHEN OBJGRP.FGSTATUS=3 THEN '#{104705}'
    WHEN OBJGRP.FGSTATUS=4 THEN '#{104230}'
END AS NMSTATUS
, OBJGRP.FGENABLED
, CASE 
    WHEN OBJGRP.FGENABLED=1 THEN '#{102270}'
    WHEN OBJGRP.FGENABLED=2 THEN '#{102291}'
END AS NMENABLED
, OBJGRP.CDFAVORITE, OBJTYPE.CDOBJECTTYPE, OBJTYPE.IDOBJECTTYPE, OBJTYPE.NMOBJECTTYPE, OBJTYPE.IDOBJECTTYPE + ' - ' + OBJTYPE.NMOBJECTTYPE AS NMTYPE_FULLNAME, OBJTYPE.FGUSEREVISION
, GNREV.IDREVISION, GNREV.DTREVISION, GNREV.FGSTATUS AS FGREVSTATUS
, CASE GNREV.FGSTATUS 
    WHEN 1 THEN '#{200242}'
    WHEN 2 THEN '#{200243}'
    WHEN 3 THEN '#{200244}'
    WHEN 4 THEN '#{200245}'
    WHEN 5 THEN '#{104238}'
    WHEN 6 THEN '#{100651}'
END AS NMREVSTATUS
, CASE WHEN GNREVCFG.FGUSEREVISION=2 THEN 1 ELSE (CASE WHEN GNREV.FGSTATUS=1 AND EXISTS (SELECT DISTINCT GN.CDREVISION
  FROM GNREVISION GN LEFT OUTER JOIN GNREVISIONSTATUS GRS ON (GRS.CDREVISIONSTATUS=GN.CDREVISIONSTATUS) INNER JOIN GNREVISIONSTAGMEM GS ON (GN.CDREVISION=GS.CDREVISION)
  WHERE GN.CDISOSYSTEM IN(SELECT CDISOSYSTEM FROM ADISOSYSTEM) AND GS.FGSTAGE=GN.FGSTATUS AND GS.DTAPPROVAL IS NULL AND GS.NRCYCLE=(SELECT MAX(NRCYCLE)
  FROM GNREVISIONSTAGMEM WHERE CDREVISION=GN.CDREVISION AND DTAPPROVAL IS NULL) AND GS.NRSEQUENCE=(SELECT MIN(NRSEQUENCE) FROM GNREVISIONSTAGMEM
  WHERE CDREVISION=GN.CDREVISION AND DTAPPROVAL IS NULL AND NRCYCLE=GS.NRCYCLE AND FGSTAGE=GS.FGSTAGE) AND (GS.FGACCESSTYPE=6 OR (GS.FGACCESSTYPE=2 AND GS.CDDEPARTMENT IN (
  SELECT DISTINCT (CDDEPARTMENT) FROM ADUSERDEPTPOS WHERE CDUSER=1548)) OR (GS.FGACCESSTYPE=3 AND EXISTS (SELECT DISTINCT T.CDDEPARTMENT, T.CDPOSITION FROM ADUSERDEPTPOS T
  WHERE T.CDUSER=1548 AND T.CDPOSITION=GS.CDPOSITION AND T.CDDEPARTMENT=GS.CDDEPARTMENT)) OR (GS.FGACCESSTYPE=4 AND GS.CDPOSITION IN (
  SELECT DISTINCT (CDPOSITION) FROM ADUSERDEPTPOS WHERE CDUSER=1548)) OR (GS.FGACCESSTYPE=5 AND GS.CDUSER=1548) OR (GS.FGACCESSTYPE=1 AND GS.CDTEAM IN (
  SELECT DISTINCT(CDTEAM) FROM ADTEAMUSER WHERE CDUSER=1548))) AND GS.FGSTAGE IN (1) AND GNREV.CDREVISION=GN.CDREVISION) THEN 1 WHEN GNREV.FGSTATUS=6
  AND OBJGRP.FGSTATUS=2 THEN 1 WHEN GNREV.FGSTATUS=6 AND (SELECT COUNT(GNREVSTAGEMEMBERS.CDMEMBERINDEX) FROM GNREVISIONSTAGMEM GNREVSTAGEMEMBERS
WHERE GNREVSTAGEMEMBERS.CDREVISION=GNREV.CDREVISION AND GNREVSTAGEMEMBERS.FGSTAGE=1 AND GNREVSTAGEMEMBERS.NRCYCLE=(SELECT MAX(CHKMAX.NRCYCLE) FROM GNREVISIONSTAGMEM CHKMAX
WHERE CHKMAX.CDREVISION=GNREVSTAGEMEMBERS.CDREVISION))=0 AND GNREVCFG.FGTYPEREVISION=1 THEN 1 WHEN OBJGRP.FGSTATUS=1 AND (SELECT COUNT(GNREVSTAGEMEMBERS.CDMEMBERINDEX)
FROM GNREVISIONSTAGMEM GNREVSTAGEMEMBERS WHERE GNREVSTAGEMEMBERS.CDREVISION=GNREV.CDREVISION AND GNREVSTAGEMEMBERS.FGSTAGE=1 AND GNREVSTAGEMEMBERS.NRCYCLE=(
SELECT MAX(CHKMAX.NRCYCLE) FROM GNREVISIONSTAGMEM CHKMAX WHERE CHKMAX.CDREVISION=GNREVSTAGEMEMBERS.CDREVISION))=0 THEN 1 ELSE 2 END) END AS FGALLOWEDIT
, CONTOBJSDS.CONTMSDS, CONTOBJSDS.FGHASSDS, RESPTEAM.IDTEAM, RESPTEAM.NMTEAM, RESPTEAM.IDTEAM + ' - ' + RESPTEAM.NMTEAM AS NMTEAM_FULLNAME, ASAST.FGASSTATUS
, ASAST.VLASSETCOST, ASAST.DTPURCHASE, ASAST.IDSERIALNUMBER, ASAST.IDMODEL, CASE WHEN TBL_ASSETDEPRECIATION.VLDEPRECATED IS NOT NULL THEN TBL_ASSETDEPRECIATION.VLDEPRECATED
ELSE ASAST.VLACTUALASSETCOST END VLREALACTUALASSETCOST
, CASE WHEN ASAST.FGASSTATUS=1 THEN '#{100303}' WHEN ASAST.FGASSTATUS=2 THEN '#{102647}' WHEN ASAST.FGASSTATUS=3 THEN '#{102646}' WHEN ASAST.FGASSTATUS=4 THEN '#{104499}' 
WHEN ASAST.FGASSTATUS=5 THEN '#{104232}' WHEN ASAST.FGASSTATUS=6 THEN '#{102645}' WHEN ASAST.FGASSTATUS=7 THEN '#{101556}' WHEN ASAST.FGASSTATUS=10 THEN '#{100289}' END NMASSTATUS
, ASHISTSITE.CDHISTASSETSITE, AS_SITE.IDSITE, AS_SITE.NMSITE
, CASE WHEN AS_SITE.CDSITE IS NOT NULL THEN AS_SITE.IDSITE + ' - ' + AS_SITE.NMSITE ELSE '' END AS NMSITE_FULLNAME
, AD_USER.IDUSER AS IDUSERSITE, AD_USER.NMUSER AS NMUSERSITE
, CASE WHEN AD_USER.CDUSER IS NOT NULL THEN AD_USER.IDUSER + ' - ' + AD_USER.NMUSER ELSE '' END AS NMUSERSITE_FULLNAME
, (CASE WHEN AS_SITE.CDSITE IS NOT NULL THEN '#{100358}: ' + AS_SITE.IDSITE + ' - ' + AS_SITE.NMSITE ELSE '' END + CASE WHEN AD_USER.CDUSER IS NOT NULL AND AS_SITE.CDSITE IS NOT NULL 
THEN ' | #{100044}: ' + AD_USER.IDUSER + ' - ' + AD_USER.NMUSER WHEN AD_USER.CDUSER IS NOT NULL THEN '#{100044}: ' + AD_USER.IDUSER + ' - ' + AD_USER.NMUSER ELSE '' END) AS NMLOCATION_FULLNAME
, ASHISTSTATE.CDHISTASSETSTATE, CASE WHEN AS_STATE.CDSTATE IS NOT NULL THEN AS_STATE.IDSTATE + ' - ' + AS_STATE.NMSTATE ELSE '' END AS NMSTATE_FULLNAME
, MANUFACTURER.NMCOMPANY AS IDMANUFACTURER, MANUFACTURER.IDCOMMERCIAL AS NMMANUFACTURER
, CASE WHEN MANUFACTURER.CDCOMPANY IS NOT NULL THEN MANUFACTURER.NMCOMPANY + ' - ' + MANUFACTURER.IDCOMMERCIAL ELSE '' END AS NMMAN_FULLNAME
, SUPPLIER.NMCOMPANY AS IDSUPPLIER, SUPPLIER.IDCOMMERCIAL AS NMSUPPLIER
, CASE WHEN SUPPLIER.CDCOMPANY IS NOT NULL THEN SUPPLIER.NMCOMPANY + ' - ' + SUPPLIER.IDCOMMERCIAL ELSE '' END AS NMSUPPLIER_FULLNAME
, ASINV.DTIMPORT, ASINV.QTTIMEIMPORT, ASINVPC.NMNAME, ASINVPC.NMDOMAIN, ASINVPC.NMOS, ASINVPC.NMIPADDRESS, ASINVPC.NMUSERNAME, ASINVPC.NMARCHITECTURE, ASINVPC.NMPRODUCTKEY
, ASINVPC.CDASSET AS CDASSETINV, ASINVPC.CDREVISION AS CDREVISIONINV, ASINVCPU.NMTYPE
, (SELECT SUM(VLCAPACITYMB) FROM ASASTINVCPMEMORY WHERE CDASTINVITCOMPUTER=ASINVPC.CDASTINVITCOMPUTER) AS FULLMEMORY FROM OBOBJECT OBJ 
INNER JOIN OBOBJECTGROUP OBJGRP ON (OBJGRP.CDOBJECTGROUP=OBJ.CDOBJECT) 
INNER JOIN OBOBJECTTYPE OBJTYPE ON (OBJTYPE.CDOBJECTTYPE=OBJGRP.CDOBJECTTYPE) 
LEFT JOIN GNREVISION GNREV ON (GNREV.CDREVISION=OBJ.CDREVISION) 
LEFT JOIN GNREVCONFIG GNREVCFG ON (GNREVCFG.CDREVCONFIG=OBJTYPE.CDREVCONFIG) 
INNER JOIN ADTEAM RESPTEAM ON (RESPTEAM.CDTEAM=OBJ.CDTEAMRESPONSABLE) 
LEFT JOIN (SELECT OBOBJSDS.CDREVISION, COUNT(CDDOCUMENT) AS CONTMSDS
, CASE WHEN COUNT(CDDOCUMENT) > 0 THEN 1 ELSE 0 END FGHASSDS
FROM OBOBJECTSDS OBOBJSDS
GROUP BY OBOBJSDS.CDREVISION) CONTOBJSDS ON (CONTOBJSDS.CDREVISION=OBJ.CDREVISION)
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION=OBJ.CDREVISION)
LEFT JOIN ASCONTROLS ASCTRL ON (ASCTRL.CDCONTROLS=ASAST.CDCONTROLS)
LEFT JOIN ASHISTASSETSITE ASHISTSITE ON (ASHISTSITE.CDASSET=ASAST.CDASSET AND ASHISTSITE.CDREVISION=ASAST.CDREVISION)
LEFT JOIN ASSITE AS_SITE ON (AS_SITE.CDSITE=ASHISTSITE.CDSITE)
LEFT JOIN ADUSER AD_USER ON (AD_USER.CDUSER=ASHISTSITE.CDUSERSITE)
LEFT JOIN ASHISTASSETSTATE ASHISTSTATE ON (ASHISTSTATE.CDASSET=ASAST.CDASSET AND ASHISTSTATE.CDREVISION=ASAST.CDREVISION)
LEFT JOIN ASSTATE AS_STATE ON (AS_STATE.CDSTATE=ASHISTSTATE.CDSTATE)
LEFT JOIN ADCOMPANY MANUFACTURER ON (MANUFACTURER.CDCOMPANY=ASAST.CDMANUFACTURER)
LEFT JOIN ADCOMPANY SUPPLIER ON (SUPPLIER.CDCOMPANY=ASAST.CDSUPPLIER)
LEFT JOIN (SELECT ASASTDEPRECVAL.CDASSET, ASASTDEPRECVAL.VLDEPRECATED FROM ASASSETDEPRECVAL ASASTDEPRECVAL) TBL_ASSETDEPRECIATION ON (TBL_ASSETDEPRECIATION.CDASSET=ASAST.CDASSET)
LEFT JOIN ASUSAGEEVENT ASUSGEVT ON (ASUSGEVT.CDASSET=ASAST.CDASSET AND ASAST.CDLASTUSAGEEVENT=ASUSGEVT.CDPROTOCOL)
LEFT JOIN ADDEPARTMENT ADDEPT ON (ASUSGEVT.CDUSAGEDEPT=ADDEPT.CDDEPARTMENT)
INNER JOIN ASASTINVITCOMPUTER ASINVPC ON (ASAST.CDASSET=ASINVPC.CDASSET AND ASAST.CDREVISION=ASINVPC.CDREVISION)
LEFT JOIN ASASTINVCPCPU ASINVCPU ON (ASINVCPU.CDASTINVITCOMPUTER=ASINVPC.CDASTINVITCOMPUTER)
INNER JOIN ASASTINVENTORY ASINV ON (ASINVPC.CDASTINVENTORY=ASINV.CDASTINVENTORY)
WHERE 1=1 AND OBJ.FGCURRENT=1 AND OBJ.FGTEMPLATE <> 1 AND (ASHISTSITE.CDHISTASSETSITE IS NULL OR ASHISTSITE.FGLASTSITE=1)
AND (ASHISTSTATE.CDHISTASSETSTATE IS NULL OR ASHISTSTATE.FGLASTSTATE=1)
AND (ASINVPC.CDASTINVENTORY IS NULL OR ASINVPC.CDASTINVENTORY=(
     SELECT MAX(CDASTINVENTORY) FROM ASASTINVITCOMPUTER ASPC WHERE ASPC.CDASSET=ASAST.CDASSET AND ASPC.CDREVISION=ASAST.CDREVISION))
AND (ASAST.FGVIEWACCESS=2 OR (ASAST.FGVIEWACCESS=1 AND ASAST.CDTEAMVIEWACCESS IN (SELECT DISTINCT(CDTEAM) FROM ADTEAMUSER WHERE CDUSER=1548)))
AND ASAST.FGASSTATUS <> 4 AND (((OBJTYPE.CDTYPEROLE IS NULL OR EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER 
     FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
     UNION ALL
     SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE
     FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE
     GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
     WHERE CHKPERMTYPEROLE.CDTYPEROLE=OBJTYPE.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=1548 OR 1548=-1)))))
--===========> Ativo (computadores - resumido 1)	 
SELECT OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT AS NM_FULLNAME
, ASINV.DTIMPORT, ASINV.QTTIMEIMPORT, ASINVPC.NMOS, ASINVPC.NMIPADDRESS, ASINVPC.NMUSERNAME
FROM OBOBJECT OBJ 
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION=OBJ.CDREVISION)
INNER JOIN ASASTINVITCOMPUTER ASINVPC ON (ASAST.CDASSET=ASINVPC.CDASSET AND ASAST.CDREVISION=ASINVPC.CDREVISION)
INNER JOIN ASASTINVENTORY ASINV ON (ASINVPC.CDASTINVENTORY=ASINV.CDASTINVENTORY)

WHERE OBJ.FGCURRENT=1 AND OBJ.FGTEMPLATE <> 1
AND (ASINVPC.CDASTINVENTORY IS NULL OR ASINVPC.CDASTINVENTORY=(
     SELECT MAX(CDASTINVENTORY) FROM ASASTINVITCOMPUTER ASPC WHERE ASPC.CDASSET=ASAST.CDASSET AND ASPC.CDREVISION=ASAST.CDREVISION))
AND (ASAST.FGVIEWACCESS=2 OR (ASAST.FGVIEWACCESS=1 AND ASAST.CDTEAMVIEWACCESS IN (SELECT DISTINCT(CDTEAM) FROM ADTEAMUSER WHERE CDUSER=1548)))
AND ASAST.FGASSTATUS <> 4 AND (((EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER 
     FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
     UNION ALL
     SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE
     FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE
     GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE))))

--======================> Tabelas dos devices
--select CDASTINVENTORY, dtimport + CONVERT(VARCHAR(19), DATEADD(second, DATEDIFF(second, GETUTCDATE(), GETDATE()), DATEADD(S, qttimeimport, '1970-01-01')), 108) from ASASTINVENTORY
--select * from  ASASTINVITCOMPUTER where cdasset = 14
--select * from ASASTINVCPSTORAGE where CDASTINVITCOMPUTER in (2,3)
--====================================================> Ativos e seus monitores
SELECT OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT AS NM_FULLNAME
, monit.*
FROM OBOBJECT OBJ 
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION=OBJ.CDREVISION)
INNER JOIN ASASTINVITCOMPUTER ASINVPC ON (ASAST.CDASSET=ASINVPC.CDASSET AND ASAST.CDREVISION=ASINVPC.CDREVISION)
inner join ASASTINVCPMONITOR monit on monit.cdastinvitcomputer = ASINVPC.cdastinvitcomputer
WHERE OBJ.FGCURRENT=1 AND OBJ.FGTEMPLATE <> 1
AND (ASINVPC.CDASTINVENTORY IS NULL OR ASINVPC.CDASTINVENTORY=(
     SELECT MAX(CDASTINVENTORY) FROM ASASTINVITCOMPUTER ASPC WHERE ASPC.CDASSET=ASAST.CDASSET AND ASPC.CDREVISION=ASAST.CDREVISION))
AND ASAST.FGASSTATUS <> 4
--======================================================> anexo dos ativos
select OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT AS NM_FULLNAME
, adatta.idattachment, adatta.nmattachment, adatta.dsattachment, adatta.dtinsert
FROM OBOBJECT OBJ 
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET = OBJ.CDOBJECT AND ASAST.CDREVISION = OBJ.CDREVISION)
inner join OBOBJECTATTACH atta on atta.CDOBJECT = ASAST.CDASSET and atta.CDREVISION = ASAST.CDREVISION
inner join ADATTACHMENT adatta on adatta.CDATTACHMENT = atta.CDATTACHMENT
WHERE OBJ.FGCURRENT=1 AND OBJ.FGTEMPLATE <> 1
AND ASAST.FGASSTATUS <> 4

-- Bios.
SELECT OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT AS NM_FULLNAME
, tt.*
FROM OBOBJECT OBJ 
INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION=OBJ.CDREVISION)
INNER JOIN ASASTINVITCOMPUTER ASINVPC ON (ASAST.CDASSET=ASINVPC.CDASSET AND ASAST.CDREVISION=ASINVPC.CDREVISION) and 
                                                                                        ASINVPC.CDASTINVITCOMPUTER = (select max(CDASTINVITCOMPUTER) from ASASTINVITCOMPUTER where cdasset = ASINVPC.CDASSET AND CDREVISION = ASINVPC.CDREVISION)
inner join ASASTINVCPBIOS tt on tt.cdastinvitcomputer = ASINVPC.CDASTINVITCOMPUTER
where nmserialnumber='L1BXK4D'

----------------------------------------------------------------

ASASTINVCPBIOS
ASASTINVCPCPU
ASASTINVCPCTRLLER
ASASTINVCPDRIVE
ASASTINVCPINPUT
ASASTINVCPMEMORY
ASASTINVCPMONITOR
ASASTINVCPNETWORK
ASASTINVCPPORT
ASASTINVCPPRINTER
ASASTINVCPSLOT
ASASTINVCPSOFTWARE
ASASTINVCPSOUND
ASASTINVCPSTORAGE
ASASTINVCPVIDEO
ASASTINVITCOMPUTER
OBOBJECTATTACH
--================================> Ativos x atributos
select obj.*, ADATV.NMATTRIBUTE, OBATTR.NMVALUE
from obobject obj
left JOIN OBOBJECTATTRIB OBATTR on (OBATTR.CDOBJECT=OBJ.CDOBJECT AND OBATTR.CDREVISION=OBJ.CDREVISION)
left join ADATTRIBVALUE ADATV on (ADATV.CDATTRIBUTE=OBATTR.CDATTRIBUTE AND ADATV.CDVALUE=OBATTR.CDVALUE)
WHERE obj.IDOBJECT='DTI-COMP-0000031'
--==================================> Ativo (software)
	 SELECT TBSOFTWARE_TEMP.*, OBJ.NMOBJECT
, CASE WHEN TBSOFTWARE_TEMP.QTCOMPUTER=1 THEN OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT ELSE CAST(TBSOFTWARE_TEMP.QTCOMPUTER AS VARCHAR(255)) + ' ' + 'Computadores' END AS OBJECT_FULLNAME
, OBJ.CDOBJECT, ASAST.FGASSTATUS
FROM (SELECT ASINVSOFT.NMEDITOR, ASINVSOFT.NMNAME, ASINVSOFT.NMVERSION, ASINVSOFT.NMFOLDER, ASINVSOFT.NMGUID, ASINVSOFT.NMLANGUAGE, ASINVSOFT.NMARCHITECTURE, MIN(ASINVPC.CDREVISION) AS CDREVISION
    , COUNT(DISTINCT ASINVPC.CDREVISION) AS QTCOMPUTER, 1 AS QTREGCOUNTER
select * 
    FROM ASASTINVITCOMPUTER ASINVPC
    INNER JOIN ASASTINVCPSOFTWARE ASINVSOFT ON (ASINVSOFT.CDASTINVITCOMPUTER=ASINVPC.CDASTINVITCOMPUTER)
    INNER JOIN OBOBJECT OBOBJ ON (OBOBJ.CDOBJECT=ASINVPC.CDASSET AND OBOBJ.CDREVISION=ASINVPC.CDREVISION)
    INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBOBJ.CDOBJECT AND ASAST.CDREVISION=OBOBJ.CDREVISION)
    LEFT JOIN OBOBJECTGROUP OBJGRP ON (OBJGRP.CDOBJECTGROUP=OBOBJ.CDOBJECT)
    LEFT JOIN OBOBJECTTYPE OBJTYPE ON (OBJTYPE.CDOBJECTTYPE=OBJGRP.CDOBJECTTYPE)
    WHERE 1=1 AND ASINVPC.CDASTINVITCOMPUTER=(SELECT MAX(CDASTINVITCOMPUTER)
    FROM ASASTINVITCOMPUTER MAXASTINVITCP
    INNER JOIN ASASTINVENTORY MAXASTINV ON (MAXASTINVITCP.CDASTINVENTORY=MAXASTINV.CDASTINVENTORY)
    WHERE MAXASTINVITCP.CDASSET=ASINVPC.CDASSET AND MAXASTINVITCP.CDREVISION=ASINVPC.CDREVISION) AND (ASAST.FGVIEWACCESS=2 OR (ASAST.FGVIEWACCESS=1
    AND ASAST.CDTEAMVIEWACCESS IN (SELECT DISTINCT(CDTEAM) FROM ADTEAMUSER WHERE CDUSER=1548))) AND (((OBJTYPE.CDTYPEROLE IS NULL OR EXISTS (
    SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE 
    FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
    UNION ALL 
    SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE 
    FROM GNUSERPERMTYPEROLE PM 
    CROSS JOIN ADUSER US 
    WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE 
    GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER 
    HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
    WHERE CHKPERMTYPEROLE.CDTYPEROLE=OBJTYPE.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=1548 OR 1548=-1))))) 
    GROUP BY ASINVSOFT.NMEDITOR, ASINVSOFT.NMNAME, ASINVSOFT.NMVERSION, ASINVSOFT.NMFOLDER, ASINVSOFT.NMGUID, ASINVSOFT.NMLANGUAGE, ASINVSOFT.NMARCHITECTURE) TBSOFTWARE_TEMP
LEFT JOIN OBOBJECT OBJ ON (OBJ.CDREVISION=TBSOFTWARE_TEMP.CDREVISION AND QTCOMPUTER=1)
LEFT JOIN ASASSET ASAST ON (ASAST.CDREVISION=TBSOFTWARE_TEMP.CDREVISION AND QTCOMPUTER=1)
LEFT JOIN OBOBJECTGROUP OBJGRP ON (OBJGRP.CDOBJECTGROUP=OBJ.CDOBJECT)
LEFT JOIN OBOBJECTTYPE OBJTYPE ON (OBJTYPE.CDOBJECTTYPE=OBJGRP.CDOBJECTTYPE)
WHERE 1=1 AND (ASAST.FGASSTATUS IS NULL OR ASAST.FGASSTATUS <> 4) AND (((OBJTYPE.CDTYPEROLE IS NULL OR EXISTS (
    SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE 
    FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */
    UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE 
    FROM GNUSERPERMTYPEROLE PM 
    CROSS JOIN ADUSER US 
    WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE 
    GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER 
    HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE 
    WHERE CHKPERMTYPEROLE.CDTYPEROLE=OBJTYPE.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=1548 OR 1548=-1)))))
--=====================================> Ativos dados da bios e rede
select ass.CDASSET, comp.CDASTINVITCOMPUTER, comp.CDASTINVENTORY, netw.*
--, bios.NMTYPE, bios.NMMANUFACTURER, netw.NMIPADDRESS
from ASASSET ass
INNER JOIN OBOBJECT obobj ON obobj.CDOBJECT = ass.CDASSET AND obobj.CDREVISION = ass.CDREVISION
inner join ASASTINVITCOMPUTER comp on comp.CDASSET = obobj.CDOBJECT and comp.CDREVISION = obobj.CDREVISION
inner join ASASTINVCPBIOS bios on bios.CDASTINVITCOMPUTER = comp.CDASTINVITCOMPUTER
inner join ASASTINVCPNETWORK netw on netw.CDASTINVITCOMPUTER = comp.CDASTINVITCOMPUTER and netw.DSDESCRIPTION like '%Ethernet%'
    --and netw.DSDESCRIPTION not like '%Loopback%'
    --and netw.DSDESCRIPTION not like '%VirtualBox%'
    --and netw.DSDESCRIPTION not like '%Fortinet%'
    --and netw.DSDESCRIPTION not like '%Hyper-V%'
where ass.CDREVISION = (select max(ass1.CDREVISION) from ASASSET ass1 where ass1.cdasset = ass.cdasset)
and comp.CDASTINVITCOMPUTER = ( select max(comp1.CDASTINVITCOMPUTER)
                                from ASASTINVITCOMPUTER comp1
                                inner join ASASTINVENTORY asinv on asinv.CDASTINVENTORY = comp1.CDASTINVENTORY
                                where comp1.CDASSET = comp.CDASSET and comp1.CDREVISION = comp.CDREVISION )

--===========================> Ajuste dos treinamentos com erro até atualização

DELETE FROM trusercourse WHERE FGINHERITED = 1 AND NOT EXISTS (SELECT 1 FROM gncoursemapitem WHERE gncoursemapitem.CDMAPPING = trusercourse.CDMAPPING AND gncoursemapitem.cdcourse = trusercourse.cdcourse);

--=================================> Segurança dos atributos
select atr.nmattribute
from adattribute atr
inner join GNPERMISSION per on per.oid = atr.oidpermission
-- inner join GNTEAMPERMISSION gnt on per.oid = gnt.oidpermission
--where not exists (select 1 from GNTEAMPERMISSION where oidpermission = per.oid and cdteam <> 42)
where not exists (select 1 from GNTEAMPERMISSION where oidpermission = per.oid and cdteam <> 5416)

--==============================> Encontrar o processo à partir do erro de análise.
select wf.idprocess, pbp.cdtoolsanalisys, analisys.cdanalisys
from wfprocess wf
inner JOIN INOCCURRENCE INC ON wf.IDOBJECT = INC.IDWORKFLOW
inner join pbproblem pbp on inc.cdoccurrence = pbp.cdoccurrence
inner join (
                SELECT gana.IDANALISYS, gana.NMANALISYS, gana.FGTYPEANALISYS, gana.CDANALISYS, gana.CDTOOLSANALISYS
                FROM GNANALISYS gana
                WHERE gana.FGTYPEANALISYS IN (2, 3, 4, 5, 6)
                union all
                SELECT assoc.IDANALISYS, assoc.NMANALISYS, assoc.FGTYPEANALISYS, assoc.CDANALISYS, assoc.CDTOOLSANALISYS
                FROM GNANALISYS ana
                inner join GNANALISYS assoc on ana.CDANALISYSEXT = assoc.cdANALISYS
                WHERE ana.CDANALISYSEXT is not null AND assoc.FGTYPEANALISYS IN (2, 3, 4, 5, 6)
) analisys on analisys.CDTOOLSANALISYS = pbp.CDTOOLSANALISYS
where analisys.cdanalisys in (select err.cdanalisys from GNSTRUCTRELATION err where err.CDSTRUCTRELATION = err.CDRELATIONTO)

--=========================> Questionário
select gnact.IDACTIVITY, usr.NMUSER
, sur.CDSURVEY, sur.NMSURVEY, sur.CDSURVEYTYPE, sur.FGENABLED, sur.FGCORRECTION, sur.FGVIEWTEMPLATE, sur.FGEXECCOPY
, resp.CDQUESTIONANSWER, resp.CDQUESTION, resp.DSANSWER, resp.FGREQOBSERVATIONS, resp.FGHIDDENLABEL, resp.FGDEFAULT, resp.FGOBSREQUIRED
, ses.NMSURVEYSESSION, ses.DSSURVEYSESSION, ses.IDSURVEYSESSION, ses.CDSURVEYSESSION, ses.FGRANDOMQUESTION, ses.FGRANDOMANSWER
, perg.CDQUESTIONGROUP, perg.DSQUESTION, perg.FGTYPEQUESTION
, marc.FGSELECTED, se.CDSURVEYEXEC
, seusr.DTFINISHEXECUSER
from gnactivity gnact
inner join svsurvey srv on gnact.cdgenactivity = srv.cdgenactivity
inner join gnsurvey sur on sur.cdsurvey = srv.cdsurvey
inner join gngentype gntp  on gntp.cdgentype = sur.cdsurveytype
inner join gnsurveyexec se on se.cdsurveyexec = srv.cdsurveyexec
inner join GNSURVEYSESSION ses on ses.cdsurvey = se.cdsurvey
inner join GNSURVEYQUESTION ques on QUES.CDSURVEYSESSION = SES.CDSURVEYSESSION and ques.cdsurvey = se.cdsurvey
inner join GNQUESTION perg on perg.cdquestion = ques.CDQUESTION
inner join GNSURVEYEXECUSER seusr on seusr.cdsurveyexec = se.cdsurveyexec
inner join aduser usr on usr.cduser = seusr.cduser
inner join GNSURVEXECQUESTION gnsq on  gnsq.CDSURVEYEXEC = se.CDSURVEYEXEC and ques.CDSURVEYQUESTION = gnsq.CDSURVEYQUESTION
inner join gnsurveyexecanswer marc  on marc.CDSURVEXECQUESTION = gnsq.CDSURVEXECQUESTION
inner join GNQUESTIONANSWER resp on resp.CDQUESTIONANSWER = marc.CDQUESTIONANSWER
where gnact.idactivity = '0024.23'

--> Questionário resumido:
SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, NULL AS STATUS, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 0 AS NRONE, 0 AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION
FROM GNSURVEYSESSION GNSS
INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYSESSION=GNSS.CDSURVEYSESSION)
INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY)
INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEY=GNSRV.CDSURVEY)
INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC)
INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY)
WHERE (GNACT.CDISOSYSTEM=214 AND GNQ.FGTYPEQUESTION IN (1, 2) AND NOT EXISTS (SELECT 1 FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) WHERE GNSEQ.CDSURVEYEXEC IN (119) AND GNSA.FGSELECTED=1 AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER))
UNION ALL
SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 1 AS NRONE, CASE WHEN GNSA.FGSELECTED=1 THEN 1 ELSE 0 END AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(GNSA.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION
FROM GNSURVEYEXECANSWER GNSA
INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION)
INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYQUESTION=GNSEQ.CDSURVEYQUESTION)
INNER JOIN GNSURVEYSESSION GNSS ON (GNSS.CDSURVEYSESSION=GNSQ.CDSURVEYSESSION)
INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION)
INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER)
INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNEXECUSR.CDSURVEYEXECUSER=GNSEQ.CDSURVEYEXECUSER)
INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) WHERE GNS.CDSURVEY IN (254)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER)
INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY)
INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC)
INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER)
WHERE (GNACT.CDISOSYSTEM=214 AND GNQ.FGTYPEQUESTION IN (1, 2) AND GNSA.FGSELECTED=1)
--------
SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(NULL AS VARCHAR(50)) AS DSREASON, NULL AS DTSTARTEXECUSER, NULL AS DTFINISHEXECUSER, CAST(NULL AS NUMERIC) AS VLNOTE, CAST(NULL AS NUMERIC(19)) AS QTTMTEXECUSER, NULL AS NMFGAVOID, NULL AS STATUS, NULL AS NMDEPARTMENT, NULL AS NMPOSITION, NULL AS NMEMAIL, NULL AS IDUSER, NULL AS NMPARTICIPANT, CAST(NULL AS INTEGER) AS CDCOMPANY, NULL AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 0 AS NRONE, 0 AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYSESSION GNSS INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYSESSION=GNSS.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEY=GNSRV.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSUREXEC.CDSURVEYEXEC not IN (0) AND GNQ.FGTYPEQUESTION not IN (0) AND NOT EXISTS (SELECT 1 FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) WHERE GNSEQ.CDSURVEYEXEC not IN (0) AND GNSA.FGSELECTED=1 AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER)) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(GNEXECUSR.DSREASON AS VARCHAR(MAX)) AS DSREASON, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.VLNOTE , CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMDEPARTMENT, ADDEP.NMDEPARTMENT) END AS NMDEPARTMENT, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMPOSITION, ADPOS.NMPOSITION) END AS NMPOSITION, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(CAST(AUSER.DSUSEREMAIL AS VARCHAR(255)), CAST(AUSER.NMUSEREMAIL AS VARCHAR(255)), GNEXECUSR.NMPARTICIPANTEMAIL) END AS NMEMAIL, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN AUSER.IDUSER END AS IDUSER, CASE WHEN GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4 THEN '#{210696}' + ' ' + TEMPORDERANO.NRORDER ELSE COALESCE(AUSER.NMUSER, GNEXECUSR.NMPARTICIPANT, GNEXECUSR.NMPARTICIPANTEMAIL, '#{210696}' + ' ' + TEMPORDERANO.NRORDER) END AS NMPARTICIPANT, ADEC.CDCOMPANY, CASE WHEN ADEC.IDCOMMERCIAL IS NOT NULL THEN ADEC.IDCOMMERCIAL+' - '+ADEC.NMCOMPANY ELSE NULL END AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 1 AS NRONE, CASE WHEN GNSA.FGSELECTED=1 THEN 1 ELSE 0 END AS FGSELECTED, CAST(GNQA.DSANSWER AS VARCHAR(MAX)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(GNSA.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION, GNQA.VLNOTE AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYQUESTION=GNSEQ.CDSURVEYQUESTION) INNER JOIN GNSURVEYSESSION GNSS ON (GNSS.CDSURVEYSESSION=GNSQ.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNQUESTIONANSWER GNQA ON (GNQA.CDQUESTION=GNQ.CDQUESTION AND GNSA.CDQUESTIONANSWER=GNQA.CDQUESTIONANSWER) INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNEXECUSR.CDSURVEYEXECUSER=GNSEQ.CDSURVEYEXECUSER) INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) WHERE GNS.CDSURVEY not IN (0)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) LEFT JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=AUSER.CDEXTERNALUSER) LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=COALESCE(GNEXECUSR.CDCOMPANY, ADEU.CDCOMPANY)) LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT AND GNEXECUSR.CDUSER IS NOT NULL) LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION AND GNEXECUSR.CDUSER IS NOT NULL)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSEQ.CDSURVEYEXEC not IN (0) AND GNQ.FGTYPEQUESTION not IN (0) AND GNSA.FGSELECTED=1) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(NULL AS VARCHAR(50)) AS DSREASON, NULL AS DTSTARTEXECUSER, NULL AS DTFINISHEXECUSER, CAST(NULL AS NUMERIC) AS VLNOTE, CAST(NULL AS NUMERIC(19)) AS QTTMTEXECUSER, NULL AS NMFGAVOID, NULL AS STATUS, NULL AS NMDEPARTMENT, NULL AS NMPOSITION, NULL AS NMEMAIL, NULL AS IDUSER, NULL AS NMPARTICIPANT, CAST(NULL AS INTEGER) AS CDCOMPANY, NULL AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 0 AS NRONE, 0 AS FGSELECTED, CAST(NULL AS VARCHAR(50)) AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, CAST(NULL AS NUMERIC) AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYSESSION GNSS INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYSESSION=GNSS.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEY=GNSRV.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNSUREXEC.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSUREXEC.CDSURVEYEXEC not IN (0) AND GNQ.FGTYPEQUESTION not IN (0) AND NOT EXISTS (SELECT 1 FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) WHERE GNSEQ.CDSURVEYEXEC not IN (0) AND (GNSA.DSOBSERVATION IS NOT NULL OR GNSA.DTDATE IS NOT NULL OR GNSA.QTTIME IS NOT NULL) AND GNSEQ.CDSURVEYQUESTION=GNSQ.CDSURVEYQUESTION)) UNION ALL SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(GNEXECUSR.DSREASON AS VARCHAR(MAX)) AS DSREASON, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.VLNOTE , CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMDEPARTMENT, ADDEP.NMDEPARTMENT) END AS NMDEPARTMENT, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMPOSITION, ADPOS.NMPOSITION) END AS NMPOSITION, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(CAST(AUSER.DSUSEREMAIL AS VARCHAR(255)), CAST(AUSER.NMUSEREMAIL AS VARCHAR(255)), GNEXECUSR.NMPARTICIPANTEMAIL) END AS NMEMAIL, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN AUSER.IDUSER END AS IDUSER, CASE WHEN GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4 THEN '#{210696}' + ' ' + TEMPORDERANO.NRORDER ELSE COALESCE(AUSER.NMUSER, GNEXECUSR.NMPARTICIPANT, GNEXECUSR.NMPARTICIPANTEMAIL, '#{210696}' + ' ' + TEMPORDERANO.NRORDER) END AS NMPARTICIPANT, ADEC.CDCOMPANY, CASE WHEN ADEC.IDCOMMERCIAL IS NOT NULL THEN ADEC.IDCOMMERCIAL+' - '+ADEC.NMCOMPANY ELSE NULL END AS NMCONTACTCOMPANY, CASE WHEN GNSS.NMSURVEYSESSION IS NULL THEN CAST(GNSS.NRORDER AS VARCHAR(50)) ELSE CAST(GNSS.NRORDER AS VARCHAR(50)) + ' - ' + GNSS.NMSURVEYSESSION END AS NMSESSION, 1 AS NRONE, CASE WHEN (GNQ.FGTYPEQUESTION IN (3,6) AND GNSA.DSOBSERVATION IS NOT NULL) OR (GNQ.FGTYPEQUESTION IN (7,8) AND GNSA.DTDATE IS NOT NULL) OR (GNQ.FGTYPEQUESTION=9 AND GNSA.QTTIME IS NOT NULL) THEN 1 ELSE 0 END AS FGSELECTED, CASE WHEN GNQ.FGTYPEQUESTION IN (3,6) THEN CAST(GNSA.DSOBSERVATION AS VARCHAR(MAX)) WHEN GNQ.FGTYPEQUESTION=7 THEN CAST (CAST(GNSA.DTDATE AS DATE) AS VARCHAR(50)) + ' ' + CASE WHEN GNSA.QTTIME > 0 THEN CAST(CEILING((GNSA.QTTIME/60)) AS VARCHAR(50)) + ':' + COALESCE( CASE WHEN (GNSA.QTTIME % 60) < 10 THEN '0' END,'') + CAST(GNSA.QTTIME % 60 AS VARCHAR(50)) ELSE CAST(NULL AS VARCHAR(50)) END WHEN GNQ.FGTYPEQUESTION=8 THEN CAST (CAST(GNSA.DTDATE AS DATE) AS VARCHAR(50)) WHEN GNQ.FGTYPEQUESTION=9 THEN CASE WHEN GNSA.QTTIME > 0 THEN CAST(CEILING((GNSA.QTTIME/60)) AS VARCHAR(50)) + ':' + COALESCE( CASE WHEN (GNSA.QTTIME % 60) < 10 THEN '0' END,'') + CAST(GNSA.QTTIME % 60 AS VARCHAR(50)) ELSE CAST(NULL AS VARCHAR(50)) END ELSE CAST(NULL AS VARCHAR(50)) END AS DSANSWER, CAST(NULL AS VARCHAR(50)) AS DSMATRIX, CAST(CAST(GNSS.NRORDER AS VARCHAR(50)) + '.' + CAST(GNSQ.NRORDER AS VARCHAR(50)) + ' ' + CAST(GNQ.DSQUESTION AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS DSQUESTION, CAST(NULL AS VARCHAR(50)) AS DSOBSERVATION, CAST(NULL AS NUMERIC) AS VLNOTEQUESTION, CAST(NULL AS NUMERIC) AS NRRANK FROM GNSURVEYEXECANSWER GNSA INNER JOIN GNSURVEXECQUESTION GNSEQ ON (GNSEQ.CDSURVEXECQUESTION=GNSA.CDSURVEXECQUESTION) INNER JOIN GNSURVEYQUESTION GNSQ ON (GNSQ.CDSURVEYQUESTION=GNSEQ.CDSURVEYQUESTION) INNER JOIN GNSURVEYSESSION GNSS ON (GNSS.CDSURVEYSESSION=GNSQ.CDSURVEYSESSION) INNER JOIN GNQUESTION GNQ ON (GNQ.CDQUESTION=GNSQ.CDQUESTION) INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNEXECUSR.CDSURVEYEXECUSER=GNSEQ.CDSURVEYEXECUSER) INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) WHERE GNS.CDSURVEY not IN (0)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER) INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=GNSQ.CDSURVEY) INNER JOIN SVSURVEY SRV ON (SRV.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) INNER JOIN GNACTIVITY GNACT ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) LEFT JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=AUSER.CDEXTERNALUSER) LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=COALESCE(GNEXECUSR.CDCOMPANY, ADEU.CDCOMPANY)) LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT AND GNEXECUSR.CDUSER IS NOT NULL) LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION AND GNEXECUSR.CDUSER IS NOT NULL)  WHERE (GNACT.CDISOSYSTEM=214 AND GNSEQ.CDSURVEYEXEC not IN (0) AND GNQ.FGTYPEQUESTION not IN (0) AND (GNSA.DSOBSERVATION IS NOT NULL OR GNSA.DTDATE IS NOT NULL OR GNSA.QTTIME IS NOT NULL))

-----------------> Refinado:
SELECT wf.idprocess, GNEXECUSR.VLNOTE
, wf.dtfinish
--, GNSRV.CDSURVEYTYPE, GNTP.CDGENTYPE -- 198 é itsm
--, GNACT.DTSTART, GNACT.DTFINISH
--, GNSUREXEC.FGSTATUS AS FGSTATUSEXEC -- 3 é executado
--, GNACT.CDASSOC, GNACT.cdgenACTIVITY, GNACT.IDACTIVITY
, form.itsm035 as GS, case when (form.itsm035 = '' or form.itsm035 is null) then 'N/A' else substring(form.itsm035, 1, coalesce(charindex('_', form.itsm035)-1, len(form.itsm035))) end as GSB
, coord.itsm001 as coordresp
, usr.nmuser
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
inner join DYNitsm017 lgs on lgs.itsm001 = case when (form.itsm035 is null or form.itsm035 = '') then '' else left(form.itsm035, charindex('_', form.itsm035)-1) end
inner join DYNitsm016 coord on lgs.OIDABCBSAGZNWY2N0Q = coord.oid
inner join aduser usr on usr.cduser = (select cdleader from aduser where idlogin = coord.itsm002)
WHERE wf.cdprocessmodel = 5251 and wf.fgstatus = 4
--and GNACT.CDISOSYSTEM = 214 AND SRV.FGMODEL = 2 and GNTP.CDGENTYPE = 198
--and GNSUREXEC.FGSTATUS = 3 and GNACT.FGSTATUS = 5
and vlnote is not null

-----------------------------------------------
select pma.*
from pmactivity pma
inner join pmprocess pm
where pma.idactivity like '%itsm%'

--================> Scorecard:

select score.idscorecard, score.nmscorecard, ind.idmetric, ind.nmmetric, indsc.IDSCMETRIC
, (select atv.nmattribute from STMETRICATTRIB atrI
inner join adattribvalue atv on atv.cdvalue = atrI.cdvalue
where atrI.cdattribute = 1 and ind.cdmetric=atrI.cdmetric) as Tipo
, (select item1.idscstructitem
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
) as pai
, (select idscstructitem +' - '+ NMSCOREITEM from (
(select item1.idscstructitem, item1.CDSCSTRUCTITEOWNER, ele.NMSCOREITEM
from STSCSTRUCTITEM item1
inner join STSCOREITEM ele on ele.CDSCOREITEM = item1.CDSCOREITEM
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)
union all
(select item2.idscstructitem, item2.CDSCSTRUCTITEOWNER, ele.NMSCOREITEM
from STSCSTRUCTITEM item2
inner join STSCOREITEM ele on ele.CDSCOREITEM = item2.CDSCOREITEM
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
))
union all
(select item3.idscstructitem, item3.CDSCSTRUCTITEOWNER, ele.NMSCOREITEM
from STSCSTRUCTITEM item3
inner join STSCOREITEM ele on ele.CDSCOREITEM = item3.CDSCOREITEM
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
))))
union all
(select item4.idscstructitem, item4.CDSCSTRUCTITEOWNER, ele.NMSCOREITEM
from STSCSTRUCTITEM item4
inner join STSCOREITEM ele on ele.CDSCOREITEM = item4.CDSCOREITEM
where item4.CDREVISION = score.cdrevision and item4.CDSCSTRUCTITEM = (
select item3.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item3
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)))))
union all
(select item5.idscstructitem, item5.CDSCSTRUCTITEOWNER, ele.NMSCOREITEM
from STSCSTRUCTITEM item5
inner join STSCOREITEM ele on ele.CDSCOREITEM = item5.CDSCOREITEM
where item5.CDREVISION = score.cdrevision and item5.CDSCSTRUCTITEM = (
(select item4.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item4
where item4.CDREVISION = score.cdrevision and item4.CDSCSTRUCTITEM = (
select item3.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item3
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)))))))
union all
(select item6.idscstructitem, item6.CDSCSTRUCTITEOWNER, ele.NMSCOREITEM
from STSCSTRUCTITEM item6
inner join STSCOREITEM ele on ele.CDSCOREITEM = item6.CDSCOREITEM
where item6.CDREVISION = score.cdrevision and item6.CDSCSTRUCTITEM = (
(select item5.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item5
where item5.CDREVISION = score.cdrevision and item5.CDSCSTRUCTITEM = (
(select item4.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item4
where item4.CDREVISION = score.cdrevision and item4.CDSCSTRUCTITEM = (
select item3.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item3
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)))))))))
) sub
where CDSCSTRUCTITEOWNER is null and idscstructitem is not null
) as niveltop
from STMETRIC ind
inner join STSCMETRIC indsc on indsc.CDMETRIC = ind.CDMETRIC
inner join STSCORECARD score on score.CDSCORECARD = indsc.CDSCORECARD
where indsc.CDREVISION = score.cdrevision
and score.cdrevision = (select max(score1.CDREVISION) from STSCORECARD score1 where score1.CDSCORECARD = 3)
and indsc.idscmetric = 'DTI-IND-0073 - 002'


--====================================================> Apontamento de horas
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


--==================> Indicadores

select score.idscorecard, score.nmscorecard, ind.idmetric, ind.nmmetric, indsc.IDSCMETRIC, metamed.nrsubperiod, metamed.nrperiod, metamed.nryear, metamed.vlweight, metamed.vltarget, metamed.vlactual
, item.IDSCSTRUCTITEM
from STMETRIC ind
inner join STSCMETRIC indsc on indsc.CDMETRIC = ind.CDMETRIC and indsc.CDREVISION = (select max(CDREVISION) from STSCMETRIC where CDMETRIC = indsc.CDMETRIC)
inner join STSCORECARD score on score.CDSCORECARD = indsc.CDSCORECARD
left join STSCMETRICTARGET metamed on metamed.CDSCMETRIC = indsc.CDSCMETRIC
left join STSCSTRUCTMETRIC struct on struct.CDSCMETRIC = indsc.CDSCMETRIC
left join STSCSTRUCTITEM item on item.CDSCSTRUCTITEM = struct.CDSCSTRUCTITEM
where score.CDSCORECARD = 3

select score.idscorecard, score.nmscorecard, ind.idmetric, ind.nmmetric, indsc.IDSCMETRIC, metamed.nrsubperiod, metamed.nrperiod, metamed.nryear, metamed.vlweight, metamed.vltarget, metamed.vlactual
, item.IDSCSTRUCTITEM
from STMETRIC ind
inner join STSCMETRIC indsc on indsc.CDMETRIC = ind.CDMETRIC and indsc.CDREVISION = (select max(CDREVISION) from STSCMETRIC where CDMETRIC = indsc.CDMETRIC)
inner join STSCORECARD score on score.CDSCORECARD = indsc.CDSCORECARD
--inner join STSCSUBMETRIC subindsc on subindsc.cdscmetric = indsc.cdscmetric and subindsc.CDREVISION = indsc.CDREVISION
left join STSCMETRICTARGET metamed on metamed.CDSCMETRIC = indsc.CDSCMETRIC
inner join STSCSTRUCTMETRIC struct on struct.CDSCMETRIC = indsc.CDSCMETRIC
inner join STSCSTRUCTITEM item on item.CDSCSTRUCTITEM = struct.CDSCSTRUCTITEM
where score.CDSCORECARD = 3

--select * from STSCSTRUCTITEM where CDSCORECARD=3
--select * from STSCMETRIC where CDSCORECARD=3
--select * from STSCSTRUCTMETRIC
select * from STMETRIC where CDMETRIC = 96
select * from STSCMETRIC where CDSCMETRIC = 610 and CDMETRIC = 96
select * from STSCMETRICTARGET where CDSCMETRIC = 610


select score.idscorecard, score.nmscorecard, ind.idmetric, ind.nmmetric, indsc.IDSCMETRIC
, item.IDSCSTRUCTITEM, struct.CDREVISION
from STMETRIC ind
inner join STSCMETRIC indsc on indsc.CDMETRIC = ind.CDMETRIC
inner join STSCORECARD score on score.CDSCORECARD = indsc.CDSCORECARD
inner join STSCSTRUCTMETRIC struct on struct.CDSCMETRIC = indsc.CDSCMETRIC and struct.CDREVISION = score.cdrevision
inner join STSCSTRUCTITEM item on item.CDSCSTRUCTITEM = struct.CDSCSTRUCTITEM and item.CDREVISION = score.cdrevision
where indsc.CDREVISION = score.cdrevision
and score.cdrevision = (select max(score1.CDREVISION) from STSCORECARD score1 where score1.CDSCORECARD = 3)


------------------------------------------------------------------------------------------------

update DYNitsm set itsm058 = 3 where oid in
(
select form.oid
from DYNitsm form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
where wf.idprocess in (SELECT --wf2.idprocess as filho, 
wf.idprocess as pai--, wf.fgstatus, wf.nmprocessmodel, wf.nmprocess, wf.nmuserstart, wf.fgconcludedstatus
from wfstruct wfs
inner join WFSUBPROCESS wfsub on wfsub.IDOBJECT = wfs.IDOBJECT
inner join wfprocess wf on wfs.idprocess = wf.idobject
inner join wfprocess wf2 on wf2.idobject = wfsub.IDSUBPROCESS
where wfsub.CDPROCESSMODEL in (--5251, 5470, 5692, 
5679 --,5716
) and wf.fgstatus <> 3
--and wf2.idprocess = 'GMUDTI-202100192'
)
and form.itsm058 <> 3
--and wf.idprocess = '202106847'
)



--==============================> Leandro - Dados do processo leadtime
select wf.idprocess, usr.nmuser, wf.dtstart+wf.tmstart as wfstart
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS status
--, wfs.idstruct, wfs.nmstruct, wfs.dtexecution+wfs.tmexecution as wfdtexec
, (SELECT wfs.dtenabled + wfs.tmenabled FROM WFSTRUCT wfs WHERE wfs.idprocess = wf.idobject and wfs.idstruct = 'Atividade1910214049995') as abertura_dtini
, (SELECT wfs.DTESTIMATEDFINISH FROM WFSTRUCT wfs WHERE wfs.idprocess = wf.idobject and wfs.idstruct = 'Atividade1910214049995') as abertura_prazo
, (SELECT wfs.DTEXECUTION + wfs.TMEXECUTION FROM WFSTRUCT wfs WHERE wfs.idprocess = wf.idobject and wfs.idstruct = 'Atividade1910214049995') as abertura_dtexec
from DYNprojetos form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
--inner join wfstruct wfs on wfs.idprocess = wf.idobject
--inner join wfactivity wfa on wfa.idobject = wfs.idobject
inner join aduser usr on usr.cduser = wf.cduserstart
where wf.cdprocessmodel = 5210


--==================================> Elisangela - Scorecard, Indicador, 
select score.idscorecard, score.nmscorecard, ind.idmetric, ind.nmmetric, indsc.IDSCMETRIC
, (select item1.idscstructitem
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
) as pai
, (select idscstructitem from (
(select item1.idscstructitem, item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)
union all
(select item2.idscstructitem, item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
))
union all
(select item3.idscstructitem, item3.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item3
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
))))
union all
(select item4.idscstructitem, item4.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item4
where item4.CDREVISION = score.cdrevision and item4.CDSCSTRUCTITEM = (
select item3.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item3
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)))))
union all
(select item5.idscstructitem, item5.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item5
where item5.CDREVISION = score.cdrevision and item5.CDSCSTRUCTITEM = (
(select item4.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item4
where item4.CDREVISION = score.cdrevision and item4.CDSCSTRUCTITEM = (
select item3.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item3
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)))))))
union all
(select item6.idscstructitem, item6.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item6
where item6.CDREVISION = score.cdrevision and item6.CDSCSTRUCTITEM = (
(select item5.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item5
where item5.CDREVISION = score.cdrevision and item5.CDSCSTRUCTITEM = (
(select item4.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item4
where item4.CDREVISION = score.cdrevision and item4.CDSCSTRUCTITEM = (
select item3.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item3
where item3.CDREVISION = score.cdrevision and item3.CDSCSTRUCTITEM = (
(select item2.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item2
where item2.CDREVISION = score.cdrevision and item2.CDSCSTRUCTITEM = (
select item1.CDSCSTRUCTITEOWNER
from STSCSTRUCTITEM item1
inner join STSCSTRUCTMETRIC struct1 on item1.CDSCSTRUCTITEM = struct1.CDSCSTRUCTITEM and struct1.CDREVISION = score.cdrevision
where struct1.CDSCMETRIC = indsc.CDSCMETRIC and item1.CDREVISION = score.cdrevision
)))))))))
) sub
where CDSCSTRUCTITEOWNER is null and idscstructitem is not null
) as niveltop
from STMETRIC ind
inner join STSCMETRIC indsc on indsc.CDMETRIC = ind.CDMETRIC
inner join STSCORECARD score on score.CDSCORECARD = indsc.CDSCORECARD
where indsc.CDREVISION = score.cdrevision
and score.cdrevision = (select max(score1.CDREVISION) from STSCORECARD score1 where score1.CDSCORECARD = 3)
and indsc.idscmetric = 'DTI-IND-0073 - 002'

--=================================================> Relatório de Categoria (EF/ET)
select IDCATEGORY, NMCATEGORY
, FGENABLEPHYSFILE as ctrl_arqfis, FGENABLEREVISION as ctrl_revis, FGENABLEREVKNOW as ctrl_cpeletr, FGENABLEVALID as ctrl_valid
, QTREVKNOWDUEDATE as pzconhpub, FGREVKNOWSENDAFTER as tarefconh, FGREVKNOWSENDTYPE as tarefquem
, FGAUTOADDRESS as enderautom
-- empréstimo / Temporalidade
from dccategory cat

--==================================> Fórmula de filtro para data dos indicadores:
case when (
           (datepart(month, [dtfinish]) = datepart(month, <!%TODAY%>) and datepart(year, [dtfinish]) = datepart(year, <!%TODAY%>)) or
           (datepart(month, [dtfinish]) = datepart(month, <!%TODAY%>)-1 and datepart(year, [dtfinish]) = datepart(year, <!%TODAY%>) and datepart(day, <!%TODAY%>) in (1)
           )) then 1 else 0 end
		   
case when (
           (datepart(month, [dtstart]) = datepart(month, <!%TODAY%>) and datepart(year, [dtstart]) = datepart(year, <!%TODAY%>)) or
           (datepart(month, [dtstart]) = datepart(month, <!%TODAY%>)-1 and datepart(year, [dtstart]) = datepart(year, <!%TODAY%>) and datepart(day, <!%TODAY%>) in (1)
           )) then 1 else 0 end

--========================================> COntratos de TI
select wf.idprocess, rev.iddocument
, CASE wf.fgstatus WHEN 1 THEN 'Em andamento' WHEN 2 THEN 'Suspenso' WHEN 3 THEN 'Cancelado' WHEN 4 THEN 'Encerrado' WHEN 5 THEN 'Bloqueado para edição' END AS status
, case doc.fgstatus when 1 then 'Emissão' when 2 then 'Homologado' when 3 then 'Revisão' when 4 then 'Cancelado' when 5 then 'Indexação' when 7 then 'Contrato encerrado' end statusdoc
from DYNcon001 form
inner join gnassocformreg gnf on (gnf.oidentityreg = form.oid)
inner join wfprocess wf on (wf.cdassocreg = gnf.cdassoc)
left join dcdocumentattrib att on att.nmvalue = wf.idprocess
left join dcdocrevision rev on rev.cdrevision = att.cdrevision
left join dcdocument doc on doc.cddocument = rev.cddocument
where form.con012 like '%Tec%'
and wf.fgstatus = 4
order by wf.idprocess desc

--=====================> Usuários de um grupo de acesso de uma unidade:
select usr.idlogin,nmuser
from aduser usr
inner join aduseraccgroup usrr on usrr.cduser = usr.cduser
inner join adaccessgroup adr on adr.cdgroup = usrr.cdgroup
inner join aduserdeptpos rel on rel.cduser = usr.cduser and FGDEFAULTDEPTPOS = 1
inner join addepartment dep on dep.cddepartment = rel.cddepartment and CDDEPTOWNER = 385
where adr.idgroup = 'QUA_PLAN'

--========================> conjunto de dados para verificar doc publicado:
select count(*) as ok from wfprocess wfp where
'Ok' in (
SELECT case doc.fgstatus when 1 then 'NOk' when 2 then 'Ok' when 3 then 'NOk' when 4 then 'Ok' when 5 then 'NOk' when 7 then 'Ok' end status
from wfprocess wf
inner join WFDOCREQUEST req on req.IDPROCESS = wf.idobject
INNER JOIN wfprocdocument wfdoc ON wfdoc.CDPROCDOCUMENT = req.CDPROCDOCUMENT
INNER JOIN dcdocrevision rev ON rev.cddocument = wfdoc.cddocument AND(rev.cdrevision = wfdoc.cddocumentrevis OR (wfdoc.cddocumentrevis IS NULL))
inner join dcdocument doc on doc.cddocument = rev.cddocument
WHERE wf.cdprocessmodel in (5679) and wf.idobject = wfp.idobject)
and wfp.idprocess = 'GMUDTI-202144275.01'
--202135342


 table_name          string                           
 ------------------  -------------------------------- 
 EMATTRMODEL         ff8080816634eae60166631331c46eef 
 EMDATASETMODEL      ff8080816634eae60166631331c46eef 
 EMDATASETPARAMETER  ff8080816634eae60166631331c46eef 
 GNFORMULA           ff8080816634eae60166631331c46eef 
 SECHANGEFIELD       ff8080816634eae60166631331c46eef 
 SEHISTCHANGETRANS   ff8080816634eae60166631331c46eef 



--------------------------> Ativos - original
SELECT OBJ.CDOBJECT, OBJ.CDREVISION, OBJ.IDOBJECT, OBJ.NMOBJECT, OBJ.IDOBJECT + ' - ' + OBJ.NMOBJECT AS NM_FULLNAME, OBJ.FGCURRENT, OBJ.FGAPPLICATION, OBJ.FGREADY, OBJGRP.CDOBJECTGROUP, OBJGRP.FGSTATUS, CASE WHEN OBJGRP.FGSTATUS=1 THEN '#{103645}' WHEN OBJGRP.FGSTATUS=2 THEN '#{104235}' WHEN OBJGRP.FGSTATUS=3 THEN '#{104705}' WHEN OBJGRP.FGSTATUS=4 THEN '#{104230}' END AS NMSTATUS, OBJGRP.FGENABLED, CASE WHEN OBJGRP.FGENABLED=1 THEN '#{102270}' WHEN OBJGRP.FGENABLED=2 THEN '#{102291}' END AS NMENABLED, OBJGRP.CDFAVORITE, OBJTYPE.CDOBJECTTYPE, OBJTYPE.IDOBJECTTYPE, OBJTYPE.NMOBJECTTYPE, OBJTYPE.IDOBJECTTYPE + ' - ' + OBJTYPE.NMOBJECTTYPE AS NMTYPE_FULLNAME, OBJTYPE.FGUSEREVISION, GNREV.IDREVISION, GNREV.DTREVISION, GNREV.FGSTATUS AS FGREVSTATUS, CASE GNREV.FGSTATUS WHEN 1 THEN '#{200242}' WHEN 2 THEN '#{200243}' WHEN 3 THEN '#{200244}' WHEN 4 THEN '#{200245}' WHEN 5 THEN '#{104238}' WHEN 6 THEN '#{100651}' END AS NMREVSTATUS, CASE WHEN GNREVCFG.FGUSEREVISION=2 THEN 1 ELSE (CASE WHEN GNREV.FGSTATUS=1 AND EXISTS (SELECT DISTINCT GN.CDREVISION FROM GNREVISION GN LEFT OUTER JOIN GNREVISIONSTATUS GRS ON (GRS.CDREVISIONSTATUS=GN.CDREVISIONSTATUS) INNER JOIN GNREVISIONSTAGMEM GS ON (GN.CDREVISION=GS.CDREVISION) WHERE GN.CDISOSYSTEM IN(SELECT CDISOSYSTEM FROM ADISOSYSTEM) AND GS.FGSTAGE=GN.FGSTATUS AND GS.DTAPPROVAL IS NULL AND GS.NRCYCLE=(SELECT MAX(NRCYCLE) FROM GNREVISIONSTAGMEM WHERE CDREVISION=GN.CDREVISION AND DTAPPROVAL IS NULL) AND GS.NRSEQUENCE=(SELECT MIN(NRSEQUENCE) FROM GNREVISIONSTAGMEM WHERE CDREVISION=GN.CDREVISION AND DTAPPROVAL IS NULL AND NRCYCLE=GS.NRCYCLE AND FGSTAGE=GS.FGSTAGE) AND (GS.FGACCESSTYPE=6 OR (GS.FGACCESSTYPE=2 AND GS.CDDEPARTMENT IN (SELECT DISTINCT (CDDEPARTMENT) FROM ADUSERDEPTPOS WHERE CDUSER=1548)) OR (GS.FGACCESSTYPE=3 AND EXISTS (SELECT DISTINCT T.CDDEPARTMENT, T.CDPOSITION FROM ADUSERDEPTPOS T WHERE T.CDUSER=1548 AND T.CDPOSITION=GS.CDPOSITION AND T.CDDEPARTMENT=GS.CDDEPARTMENT)) OR (GS.FGACCESSTYPE=4 AND GS.CDPOSITION IN (SELECT DISTINCT (CDPOSITION) FROM ADUSERDEPTPOS WHERE CDUSER=1548)) OR (GS.FGACCESSTYPE=5 AND GS.CDUSER=1548) OR (GS.FGACCESSTYPE=1 AND GS.CDTEAM IN (SELECT DISTINCT(CDTEAM) FROM ADTEAMUSER WHERE CDUSER=1548))) AND GS.FGSTAGE IN (1) AND GNREV.CDREVISION=GN.CDREVISION) THEN 1 WHEN GNREV.FGSTATUS=6 AND OBJGRP.FGSTATUS=2 THEN 1 WHEN GNREV.FGSTATUS=6 AND (SELECT COUNT(GNREVSTAGEMEMBERS.CDMEMBERINDEX) FROM GNREVISIONSTAGMEM GNREVSTAGEMEMBERS WHERE GNREVSTAGEMEMBERS.CDREVISION=GNREV.CDREVISION AND GNREVSTAGEMEMBERS.FGSTAGE=1 AND GNREVSTAGEMEMBERS.NRCYCLE=(SELECT MAX(CHKMAX.NRCYCLE) FROM GNREVISIONSTAGMEM CHKMAX WHERE CHKMAX.CDREVISION=GNREVSTAGEMEMBERS.CDREVISION))=0 AND GNREVCFG.FGTYPEREVISION=1 THEN 1 WHEN OBJGRP.FGSTATUS=1 AND (SELECT COUNT(GNREVSTAGEMEMBERS.CDMEMBERINDEX) FROM GNREVISIONSTAGMEM GNREVSTAGEMEMBERS WHERE GNREVSTAGEMEMBERS.CDREVISION=GNREV.CDREVISION AND GNREVSTAGEMEMBERS.FGSTAGE=1 AND GNREVSTAGEMEMBERS.NRCYCLE=(SELECT MAX(CHKMAX.NRCYCLE) FROM GNREVISIONSTAGMEM CHKMAX WHERE CHKMAX.CDREVISION=GNREVSTAGEMEMBERS.CDREVISION))=0 THEN 1 ELSE 2 END) END AS FGALLOWEDIT, CONTOBJSDS.CONTMSDS, CONTOBJSDS.FGHASSDS, RESPTEAM.IDTEAM, RESPTEAM.NMTEAM, RESPTEAM.IDTEAM + ' - ' + RESPTEAM.NMTEAM AS NMTEAM_FULLNAME, ASAST.FGASSTATUS, ASAST.VLASSETCOST, ASAST.DTPURCHASE, ASAST.IDSERIALNUMBER, ASAST.IDMODEL, CASE WHEN TBL_ASSETDEPRECIATION.VLDEPRECATED IS NOT NULL THEN TBL_ASSETDEPRECIATION.VLDEPRECATED ELSE ASAST.VLACTUALASSETCOST END VLREALACTUALASSETCOST, CASE WHEN ASAST.FGASSTATUS=1 THEN '#{100303}' WHEN ASAST.FGASSTATUS=2 THEN '#{102647}' WHEN ASAST.FGASSTATUS=3 THEN '#{102646}' WHEN ASAST.FGASSTATUS=4 THEN '#{104499}' WHEN ASAST.FGASSTATUS=5 THEN '#{104232}' WHEN ASAST.FGASSTATUS=6 THEN '#{102645}' WHEN ASAST.FGASSTATUS=7 THEN '#{101556}' WHEN ASAST.FGASSTATUS=10 THEN '#{100289}' END NMASSTATUS, ASHISTSITE.CDHISTASSETSITE, AS_SITE.IDSITE, AS_SITE.NMSITE, CASE WHEN AS_SITE.CDSITE IS NOT NULL THEN AS_SITE.IDSITE + ' - ' + AS_SITE.NMSITE ELSE '' END AS NMSITE_FULLNAME, AD_USER.IDUSER AS IDUSERSITE, AD_USER.NMUSER AS NMUSERSITE, CASE WHEN AD_USER.CDUSER IS NOT NULL THEN AD_USER.IDUSER + ' - ' + AD_USER.NMUSER ELSE '' END AS NMUSERSITE_FULLNAME, (CASE WHEN AS_SITE.CDSITE IS NOT NULL THEN '#{100358}: ' + AS_SITE.IDSITE + ' - ' + AS_SITE.NMSITE ELSE '' END + CASE WHEN AD_USER.CDUSER IS NOT NULL AND AS_SITE.CDSITE IS NOT NULL THEN ' | #{100044}: ' + AD_USER.IDUSER + ' - ' + AD_USER.NMUSER WHEN AD_USER.CDUSER IS NOT NULL THEN '#{100044}: ' + AD_USER.IDUSER + ' - ' + AD_USER.NMUSER ELSE '' END + CASE WHEN ASHISTSITE.NMCOORD IS NOT NULL AND (AD_USER.CDUSER IS NOT NULL OR AS_SITE.CDSITE IS NOT NULL) THEN ' | #{108303}: ' + ASHISTSITE.NMCOORD WHEN ASHISTSITE.NMCOORD IS NOT NULL THEN '#{108303}: ' + ASHISTSITE.NMCOORD ELSE '' END) AS NMLOCATION_FULLNAME, AS_SITE.NMCOUNTRY, AS_SITE.NMSTATE, AS_SITE.NMCITY, AS_SITE.NMCOORD, AS_SITE.DSADDRESS, AS_SITE.NMPOSTALCODE, CASE WHEN ADPT.IDDEPARTMENT IS NOT NULL THEN ADPT.IDDEPARTMENT + '-' + ADPT.NMDEPARTMENT ELSE '' END DEPARTMENT_FULLNAME, ASHISTSTATE.CDHISTASSETSTATE, CASE WHEN AS_STATE.CDSTATE IS NOT NULL THEN AS_STATE.IDSTATE + ' - ' + AS_STATE.NMSTATE ELSE '' END AS NMSTATE_FULLNAME, MANUFACTURER.NMCOMPANY AS IDMANUFACTURER, MANUFACTURER.IDCOMMERCIAL AS NMMANUFACTURER, CASE WHEN MANUFACTURER.CDCOMPANY IS NOT NULL THEN MANUFACTURER.NMCOMPANY + ' - ' + MANUFACTURER.IDCOMMERCIAL ELSE '' END AS NMMAN_FULLNAME, SUPPLIER.NMCOMPANY AS IDSUPPLIER, SUPPLIER.IDCOMMERCIAL AS NMSUPPLIER, CASE WHEN SUPPLIER.CDCOMPANY IS NOT NULL THEN SUPPLIER.NMCOMPANY + ' - ' + SUPPLIER.IDCOMMERCIAL ELSE '' END AS NMSUPPLIER_FULLNAME ,CASE  WHEN ASIT.FGWARRANTY=1 THEN DATEADD(DAY, ASIT.QTWARRANTY, ASIT.DTPURCHASE) WHEN ASIT.FGWARRANTY=2 THEN DATEADD(WEEK, ASIT.QTWARRANTY, ASIT.DTPURCHASE) WHEN ASIT.FGWARRANTY=3 THEN DATEADD(MONTH, ASIT.QTWARRANTY, ASIT.DTPURCHASE) WHEN ASIT.FGWARRANTY=4 THEN DATEADD(YEAR, ASIT.QTWARRANTY, ASIT.DTPURCHASE) ELSE NULL END AS DTWARRANTY FROM OBOBJECT OBJ INNER JOIN OBOBJECTGROUP OBJGRP ON (OBJGRP.CDOBJECTGROUP=OBJ.CDOBJECT) INNER JOIN OBOBJECTTYPE OBJTYPE ON (OBJTYPE.CDOBJECTTYPE=OBJGRP.CDOBJECTTYPE) LEFT JOIN GNREVISION GNREV ON (GNREV.CDREVISION=OBJ.CDREVISION) LEFT JOIN GNREVCONFIG GNREVCFG ON (GNREVCFG.CDREVCONFIG=OBJTYPE.CDREVCONFIG) INNER JOIN ADTEAM RESPTEAM ON (RESPTEAM.CDTEAM=OBJ.CDTEAMRESPONSABLE) LEFT JOIN (SELECT OBOBJSDS.CDREVISION, COUNT(CDDOCUMENT) AS CONTMSDS, CASE WHEN COUNT(CDDOCUMENT) > 0 THEN 1 ELSE 0 END FGHASSDS FROM OBOBJECTSDS OBOBJSDS GROUP BY OBOBJSDS.CDREVISION) CONTOBJSDS ON (CONTOBJSDS.CDREVISION=OBJ.CDREVISION) INNER JOIN ASASSET ASAST ON (ASAST.CDASSET=OBJ.CDOBJECT AND ASAST.CDREVISION=OBJ.CDREVISION) LEFT JOIN ASCONTROLS ASCTRL ON (ASCTRL.CDCONTROLS=ASAST.CDCONTROLS) LEFT JOIN ASHISTASSETSITE ASHISTSITE ON (ASHISTSITE.CDASSET=ASAST.CDASSET AND ASHISTSITE.FGLASTSITE=1) LEFT JOIN ASSITE AS_SITE ON (AS_SITE.CDSITE=ASHISTSITE.CDSITE) LEFT JOIN ADUSER AD_USER ON (AD_USER.CDUSER=ASHISTSITE.CDUSERSITE) LEFT JOIN ADDEPARTMENT ADPT ON (ADPT.CDDEPARTMENT=AS_SITE.CDCOMPANY) LEFT JOIN ASHISTASSETSTATE ASHISTSTATE ON (ASHISTSTATE.CDASSET=ASAST.CDASSET AND ASHISTSTATE.FGLASTSTATE=1) LEFT JOIN ASSTATE AS_STATE ON (AS_STATE.CDSTATE=ASHISTSTATE.CDSTATE) LEFT JOIN ADCOMPANY MANUFACTURER ON (MANUFACTURER.CDCOMPANY=ASAST.CDMANUFACTURER) LEFT JOIN ADCOMPANY SUPPLIER ON (SUPPLIER.CDCOMPANY=ASAST.CDSUPPLIER) LEFT JOIN (SELECT ASASTDEPRECVAL.CDASSET, ASASTDEPRECVAL.VLDEPRECATED FROM ASASSETDEPRECVAL ASASTDEPRECVAL WHERE ASASTDEPRECVAL.QTMONTH=(DATEPART(month, (<!%TODAY%>))) AND ASASTDEPRECVAL.QTYEAR=(DATEPART(year, (<!%TODAY%>)))) TBL_ASSETDEPRECIATION ON (TBL_ASSETDEPRECIATION.CDASSET=ASAST.CDASSET) LEFT JOIN ASUSAGEEVENT ASUSGEVT ON (ASUSGEVT.CDASSET=ASAST.CDASSET AND ASAST.CDLASTUSAGEEVENT=ASUSGEVT.CDPROTOCOL) LEFT JOIN ADDEPARTMENT ADDEPT ON (ASUSGEVT.CDUSAGEDEPT=ADDEPT.CDDEPARTMENT) LEFT JOIN ASASSET ASIT ON (ASAST.CDASSET=ASIT.CDASSET AND ASAST.CDREVISION=ASIT.CDREVISION) LEFT JOIN DCDOCREVISION DCDOC ON (ASIT.CDWARRANTYDOC=DCDOC.CDDOCUMENT AND DCDOC.FGCURRENT=1) LEFT JOIN GNREVISION GNRV ON (DCDOC.CDREVISION=GNRV.CDREVISION) WHERE 1=1 AND OBJ.FGCURRENT=1 AND OBJ.FGTEMPLATE <> 1 AND (ASAST.FGVIEWACCESS=2 OR (ASAST.FGVIEWACCESS=1 AND ASAST.CDTEAMVIEWACCESS IN (SELECT DISTINCT(CDTEAM) FROM ADTEAMUSER WHERE CDUSER=1548))) AND ASAST.FGASSTATUS <> 4 AND (((OBJTYPE.CDTYPEROLE IS NULL OR EXISTS (SELECT NULL FROM (SELECT CHKUSRPERMTYPEROLE.CDTYPEROLE AS CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER FROM (SELECT PM.FGPERMISSIONTYPE, PM.CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM WHERE 1=1 AND PM.CDUSER <> -1 AND PM.CDPERMISSION=5 /* Nao retirar este comentario */UNION ALL SELECT PM.FGPERMISSIONTYPE, US.CDUSER AS CDUSER, PM.CDTYPEROLE FROM GNUSERPERMTYPEROLE PM CROSS JOIN ADUSER US WHERE 1=1 AND PM.CDUSER=-1 AND US.FGUSERENABLED=1 AND PM.CDPERMISSION=5) CHKUSRPERMTYPEROLE GROUP BY CHKUSRPERMTYPEROLE.CDTYPEROLE, CHKUSRPERMTYPEROLE.CDUSER HAVING MAX(CHKUSRPERMTYPEROLE.FGPERMISSIONTYPE)=1) CHKPERMTYPEROLE WHERE CHKPERMTYPEROLE.CDTYPEROLE=OBJTYPE.CDTYPEROLE AND (CHKPERMTYPEROLE.CDUSER=1548 OR 1548=-1)))))


-----------------------------------------> Questionário original
SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(GNEXECUSR.DSREASON AS VARCHAR(MAX)) AS DSREASON
, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.VLNOTE , CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER
, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID
, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS
, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMDEPARTMENT, ADDEP.NMDEPARTMENT) END AS NMDEPARTMENT
, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMPOSITION, ADPOS.NMPOSITION) END AS NMPOSITION
, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(CAST(AUSER.DSUSEREMAIL AS VARCHAR(255))
, CAST(AUSER.NMUSEREMAIL AS VARCHAR(255)), GNEXECUSR.NMPARTICIPANTEMAIL) END AS NMEMAIL, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN AUSER.IDUSER END AS IDUSER
, CASE WHEN GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4 THEN '#{210696}' + ' ' + TEMPORDERANO.NRORDER ELSE COALESCE(AUSER.NMUSER, GNEXECUSR.NMPARTICIPANT
, GNEXECUSR.NMPARTICIPANTEMAIL, '#{210696}' + ' ' + TEMPORDERANO.NRORDER) END AS NMPARTICIPANT, ADEC.CDCOMPANY
, CASE WHEN ADEC.IDCOMMERCIAL IS NOT NULL THEN ADEC.IDCOMMERCIAL+' - '+ADEC.NMCOMPANY ELSE NULL END AS NMCONTACTCOMPANY, ANS29821_31980.DSANSWER AS DSANSWER29821_31980
,ANS29821_31980.DSOBSERVATION AS DSOBSERVATION29821_31980,ANS29821_31981.DSANSWER AS DSANSWER29821_31981,ANS29821_31981.DSOBSERVATION AS DSOBSERVATION29821_31981
,ANS29821_31982.DSANSWER AS DSANSWER29821_31982,ANS29821_31982.DSOBSERVATION AS DSOBSERVATION29821_31982,ANS29821_31983.DSANSWER AS DSANSWER29821_31983
,ANS29821_31983.DSOBSERVATION AS DSOBSERVATION29821_31983,ANS29821_31984.DSANSWER AS DSANSWER29821_31984,ANS29821_31984.DSOBSERVATION AS DSOBSERVATION29821_31984
,ANS29821_31985.DSANSWER AS DSANSWER29821_31985,ANS29821_31985.DSOBSERVATION AS DSOBSERVATION29821_31985,ANS29821_31986.DSANSWER AS DSANSWER29821_31986
,ANS29821_31986.DSOBSERVATION AS DSOBSERVATION29821_31986,ANS29821_31987.DSANSWER AS DSANSWER29821_31987,ANS29821_31987.DSOBSERVATION AS DSOBSERVATION29821_31987
,ANS29821_31988.DSANSWER AS DSANSWER29821_31988,ANS29821_31988.DSOBSERVATION AS DSOBSERVATION29821_31988,ANS29821_31989.DSANSWER AS DSANSWER29821_31989
,ANS29821_31989.DSOBSERVATION AS DSOBSERVATION29821_31989 
FROM GNACTIVITY GNACT 
INNER JOIN SVSURVEY SRV ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) 
INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=SRV.CDSURVEY) 
INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEYEXEC=SRV.CDSURVEYEXEC) 
INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNSUREXEC.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) 
INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END 
            ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) 
            INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) 
            INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) 
            WHERE GNS.CDSURVEY IN (5898)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) 
LEFT JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=AUSER.CDEXTERNALUSER) 
LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=COALESCE(GNEXECUSR.CDCOMPANY, ADEU.CDCOMPANY)) 
LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT) 
LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
           FROM GNSURVEXECQUESTION 
           INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
           INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
           WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31980) 
           AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31980 ON (ANS29821_31980.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
            FROM GNSURVEXECQUESTION 
            INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
            INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
            WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31981) 
            AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31981 ON (ANS29821_31981.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
           FROM GNSURVEXECQUESTION 
            INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
            INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
            WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31982) 
            AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31982 ON (ANS29821_31982.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER)
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31983) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31983 ON (ANS29821_31983.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER)
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31984) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31984 ON (ANS29821_31984.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31985) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31985 ON (ANS29821_31985.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31986) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31986 ON (ANS29821_31986.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31987) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31987 ON (ANS29821_31987.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31988) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31988 ON (ANS29821_31988.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31989) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31989 ON (ANS29821_31989.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
WHERE (GNACT.CDISOSYSTEM=214 AND GNSUREXEC.CDSURVEY IN (5898))

----------------------> Questionário - Respostas
SELECT GNACT.IDACTIVITY, GNACT.NMACTIVITY, GNACT.DTSTART, GNACT.DTFINISH, GNACT.DTSTARTPLAN, GNACT.DTFINISHPLAN, CAST(GNEXECUSR.DSREASON AS VARCHAR(MAX)) AS DSREASON
, GNEXECUSR.DTSTARTEXECUSER, GNEXECUSR.DTFINISHEXECUSER, GNEXECUSR.VLNOTE , CAST(CAST(GNEXECUSR.QTTMTOTALEXECUSER AS NUMERIC(19)) * 1000 AS NUMERIC(19)) AS QTTMTEXECUSER
, CASE GNEXECUSR.FGAVOID WHEN 1 THEN '#{100092}' WHEN 2 THEN '#{100093}' ELSE '' END AS NMFGAVOID
, CASE GNEXECUSR.FGSTATUS WHEN 1 THEN '#{100481}' WHEN 2 THEN '#{209659}' WHEN 3 THEN '#{100667}' WHEN 4 THEN '#{104919}' END AS STATUS
, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMDEPARTMENT, ADDEP.NMDEPARTMENT) END AS NMDEPARTMENT
, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(ADEU.NMPOSITION, ADPOS.NMPOSITION) END AS NMPOSITION
, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN COALESCE(CAST(AUSER.DSUSEREMAIL AS VARCHAR(255))
, CAST(AUSER.NMUSEREMAIL AS VARCHAR(255)), GNEXECUSR.NMPARTICIPANTEMAIL) END AS NMEMAIL, CASE WHEN NOT(GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4) THEN AUSER.IDUSER END AS IDUSER
, CASE WHEN GNSRV.FGANONYMOUSSURVEY=1 AND GNEXECUSR.FGSTATUS <> 4 THEN '#{210696}' + ' ' + TEMPORDERANO.NRORDER ELSE COALESCE(AUSER.NMUSER, GNEXECUSR.NMPARTICIPANT
, GNEXECUSR.NMPARTICIPANTEMAIL, '#{210696}' + ' ' + TEMPORDERANO.NRORDER) END AS NMPARTICIPANT, ADEC.CDCOMPANY
, CASE WHEN ADEC.IDCOMMERCIAL IS NOT NULL THEN ADEC.IDCOMMERCIAL+' - '+ADEC.NMCOMPANY ELSE NULL END AS NMCONTACTCOMPANY, ANS29821_31980.DSANSWER AS DSANSWER29821_31980
,ANS29821_31980.DSOBSERVATION AS DSOBSERVATION29821_31980,ANS29821_31981.DSANSWER AS DSANSWER29821_31981,ANS29821_31981.DSOBSERVATION AS DSOBSERVATION29821_31981
,ANS29821_31982.DSANSWER AS DSANSWER29821_31982,ANS29821_31982.DSOBSERVATION AS DSOBSERVATION29821_31982,ANS29821_31983.DSANSWER AS DSANSWER29821_31983
,ANS29821_31983.DSOBSERVATION AS DSOBSERVATION29821_31983,ANS29821_31984.DSANSWER AS DSANSWER29821_31984,ANS29821_31984.DSOBSERVATION AS DSOBSERVATION29821_31984
,ANS29821_31985.DSANSWER AS DSANSWER29821_31985,ANS29821_31985.DSOBSERVATION AS DSOBSERVATION29821_31985,ANS29821_31986.DSANSWER AS DSANSWER29821_31986
,ANS29821_31986.DSOBSERVATION AS DSOBSERVATION29821_31986,ANS29821_31987.DSANSWER AS DSANSWER29821_31987,ANS29821_31987.DSOBSERVATION AS DSOBSERVATION29821_31987
,ANS29821_31988.DSANSWER AS DSANSWER29821_31988,ANS29821_31988.DSOBSERVATION AS DSOBSERVATION29821_31988,ANS29821_31989.DSANSWER AS DSANSWER29821_31989
,ANS29821_31989.DSOBSERVATION AS DSOBSERVATION29821_31989 
FROM GNACTIVITY GNACT 
INNER JOIN SVSURVEY SRV ON (GNACT.CDGENACTIVITY=SRV.CDGENACTIVITY) 
INNER JOIN GNSURVEY GNSRV ON (GNSRV.CDSURVEY=SRV.CDSURVEY) 
INNER JOIN GNSURVEYEXEC GNSUREXEC ON (GNSUREXEC.CDSURVEYEXEC=SRV.CDSURVEYEXEC) 
INNER JOIN GNSURVEYEXECUSER GNEXECUSR ON (GNSUREXEC.CDSURVEYEXEC=GNEXECUSR.CDSURVEYEXEC) 
INNER JOIN (SELECT GNSU2.CDSURVEYEXECUSER, CAST(ROW_NUMBER() OVER (PARTITION BY GNSU2.CDSURVEYEXEC, CASE WHEN GNSU2.FGSTATUS <> 4 AND GN.FGANONYMOUSSURVEY=1 THEN 1 END 
            ORDER BY GNSU2.CDSURVEYEXECUSER) AS VARCHAR(255)) AS NRORDER FROM GNSURVEYEXECUSER GNSU2 INNER JOIN SVSURVEY SV ON (SV.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC) 
            INNER JOIN GNSURVEY GN ON (GN.CDSURVEY=SV.CDSURVEY) 
            INNER JOIN GNSURVEYEXEC GNS ON (GNS.CDSURVEYEXEC=GNSU2.CDSURVEYEXEC)) TEMPORDERANO ON (TEMPORDERANO.CDSURVEYEXECUSER=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN ADALLUSERS AUSER ON (AUSER.CDUSER=GNEXECUSR.CDUSER) 
LEFT JOIN ADUSEREXTERNALDATA ADEU ON (ADEU.CDEXTERNALUSER=AUSER.CDEXTERNALUSER) 
LEFT JOIN ADCOMPANY ADEC ON (ADEC.CDCOMPANY=COALESCE(GNEXECUSR.CDCOMPANY, ADEU.CDCOMPANY)) 
LEFT JOIN ADDEPARTMENT ADDEP ON (ADDEP.CDDEPARTMENT=GNEXECUSR.CDDEPARTMENT) 
LEFT JOIN ADPOSITION ADPOS ON (ADPOS.CDPOSITION=GNEXECUSR.CDPOSITION) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
           FROM GNSURVEXECQUESTION 
           INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
           INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
           WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31980) 
           AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31980 ON (ANS29821_31980.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
            FROM GNSURVEXECQUESTION 
            INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
            INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
            WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31981) 
            AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31981 ON (ANS29821_31981.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
           FROM GNSURVEXECQUESTION 
            INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
            INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
            WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31982) 
            AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31982 ON (ANS29821_31982.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER)
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
           , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31983) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31983 ON (ANS29821_31983.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER)
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31984) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31984 ON (ANS29821_31984.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31985) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31985 ON (ANS29821_31985.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31986) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31986 ON (ANS29821_31986.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31987) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31987 ON (ANS29821_31987.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION 
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31988) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31988 ON (ANS29821_31988.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
LEFT JOIN (SELECT GNSURVEXECQUESTION.CDSURVEYEXECUSER AS CDSVSUR, CAST(GNQUESTIONANSWER.DSANSWER AS VARCHAR(MAX)) AS DSANSWER
        , CAST(GNSURVEYEXECANSWER.DSOBSERVATION AS VARCHAR(MAX)) AS DSOBSERVATION
        FROM GNSURVEXECQUESTION 
        INNER JOIN GNSURVEYEXECANSWER ON ( GNSURVEYEXECANSWER.CDSURVEXECQUESTION=GNSURVEXECQUESTION.CDSURVEXECQUESTION) 
        INNER JOIN GNQUESTIONANSWER ON ( GNSURVEYEXECANSWER.CDQUESTIONANSWER=GNQUESTIONANSWER.CDQUESTIONANSWER) 
        WHERE GNSURVEYEXECANSWER.FGSELECTED=1 AND GNSURVEXECQUESTION.CDSURVEYQUESTION IN (29821) AND GNSURVEXECQUESTION.CDMATRIXQUESTION IN (31989) 
        AND GNSURVEXECQUESTION.CDSURVEYEXEC IN (2469)) ANS29821_31989 ON (ANS29821_31989.CDSVSUR=GNEXECUSR.CDSURVEYEXECUSER) 
WHERE (GNACT.CDISOSYSTEM=214) and GNACT.IDACTIVITY like 'bsb-ind%' and GNACT.fgmodel = 2

--------------------------> treinamneto - Elaine - não terminado:
Alvaro, 
Sinto a falta de dados sobre treinamento no portal.
Eu gostaria de ver, em uma aba especifica se possivel, todos os treinamentos em andamento na UA.
E para cada treinamento vigente, a % de pessoas treinadas para facilitar a homologação.
Assim, toda vez que o treinaemnto atingir 80% sabemos que pode ser homologado.
Ainda gostaria de ver, o dia que foi iniciado o treinamento e a contagem com o dia atual para acompanhar se os 80% foram atingidos dentro dos 60dias estabelecidos no SOP.
Se possivel, o nome do responsavel pelo procedimento para fazermos o FUP.
A ideia ‘e deixar esse portal disponivel para todos os funcionarios acompanharem o status dos documentos e pessoas responsaveis.

select rev.iddocument, gnrev.idrevision, tr.idtrain, trusr.cduser
from dcdocrevision rev
inner join gnrevision gnrev on gnrev.cdrevision = rev.cdrevision
inner join dcdocument doc on doc.cddocument = rev.cddocument
inner join DCDOCTRAIN tdoc on tdoc.cdrevision = rev.cdrevision and tdoc.cddocument = doc.cddocument
inner join trtraining tr on tr.cdtrain = tdoc.cdtrain
inner join trtrainuser trusr on trusr.cdtrain = tr.cdtrain
--inner join trcourse cou on cou.cdcourse = tr.cdcourse
where FGTRAINREQUIRED = 1 and rev.cdcategory in (select cdcategory from dccategory where idcategory in 
('0010 - UA') or cdcategoryowner in 
(select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA'))) or cdcategoryowner in
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA')) or cdcategoryowner in 
(select cdcategory from dccategory where cdcategoryowner in (select cdcategory from dccategory where idcategory in 
('0010 - UA')))))
and (rev.cdrevision = (select max(rev2.cdrevision) from dcdocrevision rev2 where rev2.cddocument = doc.cddocument)
or doc.fgstatus = 3 and rev.cdrevision = (select max(rev3.cdrevision) from dcdocrevision rev3 inner join gnrevision gnrev1 on gnrev1.cdrevision = rev3.cdrevision where rev3.cddocument = doc.cddocument and gnrev1.dtrevision is not null))
and rev.iddocument like 'sop%'

select usr.cduser
from aduser usr
inner join aduserdeptpos rel on rel.cduser = usr.cduser
inner join addepartment dep on dep.cddepartment = rel.cddepartment
where dep.cddepartment in (select cddepartment from addepartment where iddepartment in 
('0010 - UA') or CDDEPTOWNER in 
(select cddepartment from addepartment where iddepartment in 
('0010 - UA')) or CDDEPTOWNER in 
(select cddepartment from addepartment where CDDEPTOWNER in (select cddepartment from addepartment where iddepartment in 
('0010 - UA'))) or CDDEPTOWNER in
(select cddepartment from addepartment where CDDEPTOWNER in (select cddepartment from addepartment where iddepartment in 
('0010 - UA')) or CDDEPTOWNER in 
(select cddepartment from addepartment where CDDEPTOWNER in (select cddepartment from addepartment where iddepartment in 
('0010 - UA')))))


--==================================================> Busca de termo nas tabelas do banco de dados
declare @idtabela int, @tabela varchar(255), @coluna varchar(255), @valorProcurado varchar(255)

--Coloque aqui a palavra ou expressão que deseja procurar
set @valorProcurado = 'SE Suite - Suporte técnico - Transferência de tarefas - Transferência'

drop table ##tmpFindString

create table ##tmpFindString (table_name varchar(255), string varchar(255))

DECLARE db_cursor CURSOR FOR  
		select id from sys.sysobjects where xtype = 'u'
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @idtabela

WHILE @@FETCH_STATUS = 0   
BEGIN   

		DECLARE db_cursorColunas CURSOR FOR  
			select a.name as tabela, b.name as coluna from sys.sysobjects a
				inner join
					sys.syscolumns b
				on a.id = b.id 
			 where b.xtype in (167,231) and a.xtype = 'u'
					and a.id = @idtabela

			/*
			34 image
			35 text
			36 uniqueidentifier
			48 tinyint
			52 smallint
			56 int
			58 smalldatetime
			59 real
			60 money
			61 datetime
			62 float
			98 sql_variant
			99 ntext
			104 bit
			106 decimal
			108 numeric
			122 smallmoney
			127 bigint
			165 varbinary
			167 varchar
			173 binary
			175 char
			189 timestamp
			231 nvarchar
			231 sysname
			239 nchar
			241 xml
			*/

			/*
			C: Check constraint
			D: Default constraint
			F: Foreign Key constraint
			L: Log
			P: Stored procedure
			PK: Primary Key constraint
			RF: Replication Filter stored procedure
			S: System table
			TR: Trigger
			U: User table
			UQ: Unique constraint
			V: View
			X: Extended stored procedure
			*/
		OPEN db_cursorColunas   
		FETCH NEXT FROM db_cursorColunas INTO @tabela, @coluna

		WHILE @@FETCH_STATUS = 0   
		BEGIN   
				exec('
				insert ##tmpFindString
				select '''  + @tabela + ''', string = '''+@valorProcurado+'''
						from ' + @tabela + ' where '+@coluna+' like ''%'+@valorProcurado+'%''')
			   
			   FETCH NEXT FROM db_cursorColunas INTO @tabela, @coluna 
		END   

		CLOSE db_cursorColunas   
		DEALLOCATE db_cursorColunas 
	   
	   FETCH NEXT FROM db_cursor INTO @idtabela 
END   

CLOSE db_cursor   
DEALLOCATE db_cursor 

	   
select distinct * from ##tmpFindString
-------

select w.idobject, w.idobjstruct, w3.idprocess, w3.nmprocess, w2.idstruct, w2.nmstruct, count(1) as qt
from wfsurveyexecproc w
inner join wfstruct w2 ON (w2.idobject = w.idobjstruct)
inner join wfprocess w3 on (w3.idobject = w.idobject)
group by w.idobject, w.idobjstruct, w3.idprocess, w3.nmprocess, w2.idstruct, w2.nmstruct
having count(1)>1



--==========================> Verificações de documento
01) Verifica inconsistências entre a situação indicada dentro da revisão e a real situação da mesmo

SELECT D.FGSTATUS AS SitDOC, R.FGSTATUS AS SitRev ,
DR.CDDOCUMENT, DR.CDREVISION, RSTM.CDMEMBERINDEX, RSTM.FGSTAGE,RSTM.NRCYCLE,RSTM.NRSEQUENCE, DR.CDCATEGORY,
RSTM.DTDEADLINE,RSTM.FGAPPROVAL,RSTM.QTDEADLINE,DR.IDDOCUMENT,
RSTM.DTAPPROVAL,RSTM.CDUSER,RSTM.CDDEPARTMENT,RSTM.CDPOSITION,RSTM.CDTEAM
FROM DCDOCREVISION DR, DCDOCUMENT D, GNREVISION R, GNREVISIONSTAGMEM RSTM
WHERE D.CDDOCUMENT=DR.CDDOCUMENT AND DR.CDREVISION=R.CDREVISION
AND RSTM.CDREVISION=R.CDREVISION
AND R.CDREVISION=(SELECT MAX(CDREVISION) FROM DCDOCREVISION WHERE DCDOCREVISION.CDDOCUMENT=DR.CDDOCUMENT)
AND R.FGSTATUS NOT IN(5,6)
AND NOT EXISTS (SELECT 1
FROM GNREVISIONSTAGMEM STM2
WHERE STM2.CDREVISION=R.CDREVISION
AND DTDEADLINE IS NOT NULL
AND FGAPPROVAL IS NULL
AND R.FGSTATUS=STM2.FGSTAGE
AND NRCYCLE=(SELECT MAX(NRCYCLE)
FROM GNREVISIONSTAGMEM STAG
WHERE R.CDREVISION=STAG.CDREVISION))
ORDER BY DR.CDDOCUMENT, DR.CDREVISION, RSTM.NRCYCLE, RSTM.FGSTAGE, RSTM.NRSEQUENCE



02) Verifica se existe algum documento que aparece em revisão, no entanto não possui nenhum revisão em aberto

SELECT DR1.IDDOCUMENT AS IDDOC,D.* FROM DCDOCUMENT D, DCDOCREVISION DR1
WHERE FGSTATUS IN (1,3) AND D.CDDOCUMENT=DR1.CDDOCUMENT
AND 6 =
(SELECT MIN(R.FGSTATUS)
FROM GNREVISION R
WHERE CDREVISION IN(SELECT CDREVISION FROM DCDOCREVISION DR, DCCATEGORY C, GNREVCONFIG RC
WHERE C.CDCATEGORY=DR.CDCATEGORY AND RC.CDREVCONFIG=C.CDREVCONFIG AND FGTYPEREVISION=1 AND DR.CDDOCUMENT=DR1.CDDOCUMENT))

03)SELECT DR1.IDDOCUMENT AS IDDOC,D.* FROM DCDOCUMENT D, DCDOCREVISION DR1
WHERE FGSTATUS IN (1,3) AND D.CDDOCUMENT=DR1.CDDOCUMENT
AND 6 =
(SELECT MIN(R.FGSTATUS)
FROM GNREVISION R
WHERE CDREVISION IN(SELECT CDREVISION FROM DCDOCREVISION DR
WHERE DR.CDDOCUMENT=DR1.CDDOCUMENT))


04) Verifica se existe algum documento que aparece como homologado, no entanto deveria aparecer como "em revisão".

SELECT DISTINCT D.CDDOCUMENT
FROM DCDOCUMENT D, DCDOCREVISION DR
WHERE D.CDDOCUMENT=DR.CDDOCUMENT
AND D.FGSTATUS=2
AND EXISTS(SELECT 1 FROM GNREVISION R, DCDOCREVISION DR1 WHERE R.CDREVISION=DR1.CDREVISION AND DR1.CDDOCUMENT=D.CDDOCUMENT AND FGSTATUS<>6)

-------------------------------------------------------------------------------------
