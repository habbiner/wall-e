param(
    [Parameter(Mandatory=$true)][string]$Atual,
    [Parameter(Mandatory=$true)][string]$Novo,
    [Parameter(Mandatory=$true)][string]$UltimoGerado,
    [Parameter(Mandatory=$true)][ValidateSet("cliente","interno")][string]$Modo
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$atual = [int]$Atual
$novo  = [int]$Novo

$mesesPt = @("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")

$entrada = $UltimoGerado.Trim()
$ultimoDue = $null
try {
    $ultimoDue = [datetime]::ParseExact($entrada, "dd/MM/yyyy", $null)
} catch {
    try {
        $parcial = [datetime]::ParseExact($entrada, "dd/MM", $null)
        $ultimoDue = Get-Date -Year (Get-Date).Year -Month $parcial.Month -Day $parcial.Day
    } catch {
        Write-Output "Data inválida ('$entrada'). Use o formato dd/mm ou dd/mm/aaaa e rode o atalho novamente."
        exit
    }
}

if ($atual -eq $novo) {
    Write-Output "O dia informado como atual e o novo são iguais (dia $Novo). Não há alteração de vencimento a ser feita."
    exit
}

if ($atual -in 5,10,15) { $lastRefDate = $ultimoDue.AddMonths(-1) } else { $lastRefDate = $ultimoDue }
$nextRefDate = $lastRefDate.AddMonths(1)
if ($novo -in 5,10,15) { $nextDueDateMonth = $nextRefDate.AddMonths(1) } else { $nextDueDateMonth = $nextRefDate }
$proximoDue = Get-Date -Year $nextDueDateMonth.Year -Month $nextDueDateMonth.Month -Day $novo

$mesUltimo  = $mesesPt[$lastRefDate.Month - 1]
$mesProximo = $mesesPt[$nextRefDate.Month - 1]
$ultimoStr  = $ultimoDue.ToString("dd/MM")
$proximoStr = $proximoDue.ToString("dd/MM")

if ($Modo -eq "cliente") {
    if (($atual -in 5,10,15) -and ($novo -in 20,25)) {
        $regra = "📅 Você pagará 2 boletos no mesmo mês: como o vencimento mudou para o mês vigente, você pagará o referente ao mês passado no início do mês e o deste mês no final."
    } elseif (($atual -in 20,25) -and ($novo -in 5,10,15)) {
        $regra = "📅 Haverá um intervalo maior entre vencimentos: o próximo boleto será referente ao mês anterior e só vencerá no mês seguinte, gerando um intervalo de quase 40 dias sem boleto."
    } else {
        $regra = "📅 Apenas ajuste no dia: a referência do mês de cobrança continuará a mesma, alterando apenas o dia exato do pagamento dentro do mês."
    }

    Write-Output "Compreendo a sua solicitação para alterar a data de vencimento para o dia $Novo.`n`nPara alinharmos as expectativas, como as nossas datas possuem referências de cobrança diferentes (mês anterior vs. mês vigente), essa mudança gerará o seguinte ajuste no seu faturamento:`n`n$regra`n`nO cenário da sua assinatura ficará assim:`n• Último boleto gerado: vencimento em $ultimoStr (referente ao mês de $mesUltimo).`n• Próximo boleto a faturar: vencimento em $proximoStr (referente ao mês de $mesProximo).`n`nVocê está de acordo com este ajuste para que eu possa encaminhar a solicitação de alteração ao nosso setor Financeiro?"
} else {
    Write-Output "Alteração Data Vencimento`n`nCliente entrou em contato solicitando para alterar a data de vencimento de seus boletos do dia $Atual para todo dia $Novo.`n`nForam passadas as seguintes informações ao cliente:`nÚltimo boleto gerado: $ultimoStr - Referente ao mês de $mesUltimo`nPróximo boleto gerado: $proximoStr - Referente ao mês de $mesProximo`n`nPor gentileza, verificar."
}