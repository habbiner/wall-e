<#
.SYNOPSIS
    Calcula as datas de vencimento (último e próximo boleto) numa troca de dia de vencimento.

.DESCRIPTION
    Regra de referência da Com4:
      - Vencimentos 05/10/15 cobram o mês ANTERIOR (referência = mês do vencimento - 1)
      - Vencimentos 20/25    cobram o mês VIGENTE  (referência = mês do vencimento)

    Chamado pelo Espanso (/venc e /logvenc):
      powershell.exe -NoProfile -ExecutionPolicy Bypass -File calc_vencimento.ps1 `
          -Atual 25 -Novo 10 -UltimoGerado 25/10 -Modo cliente

    Modo "cliente": texto para enviar ao cliente.
    Modo "interno": registro para o SAP.
    Mensagens iniciadas com ⚠️ são avisos para o atendente (NÃO enviar ao cliente).
    Validações: dia atual = dia novo; data inválida; dia do último boleto diferente do dia atual.
#>
param(
    [Parameter(Mandatory = $true)][ValidateSet(5, 10, 15, 20, 25)][int]$Atual,
    [Parameter(Mandatory = $true)][ValidateSet(5, 10, 15, 20, 25)][int]$Novo,
    [Parameter(Mandatory = $true)][string]$UltimoGerado,
    [Parameter(Mandatory = $true)][ValidateSet('cliente', 'interno')][string]$Modo
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$cultura = [System.Globalization.CultureInfo]::InvariantCulture
$mesesPt = @('janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
             'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro')
$diasMesAnterior = 5, 10, 15   # vencimentos que cobram o mês anterior

# --- 1. Validações -----------------------------------------------------------
if ($Atual -eq $Novo) {
    Write-Output "⚠️ [NÃO ENVIAR AO CLIENTE] O dia atual e o novo são iguais (dia $Novo). Não há alteração de vencimento a ser feita."
    exit
}

# --- 2. Leitura da data do último boleto (dd/mm ou dd/mm/aaaa) ---------------
$entrada   = $UltimoGerado.Trim()
$ultimoDue = $null

if ($entrada -match '^(\d{1,2})/(\d{1,2})/(\d{4})$') {
    $dia = [int]$Matches[1]; $mes = [int]$Matches[2]; $ano = [int]$Matches[3]
    try { $ultimoDue = [datetime]::new($ano, $mes, $dia) } catch { $ultimoDue = $null }
}
elseif ($entrada -match '^(\d{1,2})/(\d{1,2})$') {
    # Sem ano: usa o ano (anterior, atual ou seguinte) cuja data fica mais perto de hoje.
    $dia = [int]$Matches[1]; $mes = [int]$Matches[2]
    $hoje = (Get-Date).Date
    $melhor = $null
    foreach ($ano in ($hoje.Year - 1), $hoje.Year, ($hoje.Year + 1)) {
        try {
            $cand = [datetime]::new($ano, $mes, $dia)
            if ($null -eq $melhor -or [math]::Abs(($cand - $hoje).TotalDays) -lt [math]::Abs(($melhor - $hoje).TotalDays)) {
                $melhor = $cand
            }
        } catch { }
    }
    $ultimoDue = $melhor
}

if ($null -eq $ultimoDue) {
    Write-Output "⚠️ [NÃO ENVIAR AO CLIENTE] Data inválida ('$entrada'). Use dd/mm ou dd/mm/aaaa e rode o atalho novamente."
    exit
}

# --- 2.1 Conferência: o último boleto deve vencer no dia ATUAL informado ----
if ($ultimoDue.Day -ne $Atual) {
    Write-Output ("⚠️ [NÃO ENVIAR AO CLIENTE] O último boleto informado vence no dia " + $ultimoDue.Day + ", mas o vencimento atual indicado foi dia $Atual. Confira no sistema e rode o atalho novamente.")
    exit
}

# --- 3. Cálculo das referências e dos vencimentos ----------------------------
$deslocaAtual = if ($Atual -in $diasMesAnterior) { -1 } else { 0 }
$refUltimo    = $ultimoDue.AddMonths($deslocaAtual)
$refProximo   = $refUltimo.AddMonths(1)

$baseProximo  = if ($Novo -in $diasMesAnterior) { $refProximo.AddMonths(1) } else { $refProximo }
$proximoDue   = [datetime]::new($baseProximo.Year, $baseProximo.Month, $Novo)

$mesUltimo    = $mesesPt[$refUltimo.Month - 1]
$mesProximo   = $mesesPt[$refProximo.Month - 1]
$ultimoStr    = $ultimoDue.ToString('dd/MM', $cultura)
$proximoStr   = $proximoDue.ToString('dd/MM', $cultura)
$intervalo    = [int]($proximoDue - $ultimoDue).TotalDays

# --- 4. Saída ----------------------------------------------------------------
if ($Modo -eq 'cliente') {

    if (($Atual -in $diasMesAnterior) -and ($Novo -in 20, 25)) {
        $regra = '📅 Você pagará 2 boletos no mesmo mês: como o vencimento mudou para o mês vigente, você pagará o referente ao mês passado no início do mês e o deste mês no final.'
    }
    elseif (($Atual -in 20, 25) -and ($Novo -in $diasMesAnterior)) {
        $regra = "📅 Haverá um intervalo maior entre vencimentos: o próximo boleto será referente ao mês anterior e só vencerá no mês seguinte, gerando um intervalo de $intervalo dias entre o último e o próximo boleto."
    }
    else {
        $regra = '📅 Apenas ajuste no dia: a referência do mês de cobrança continuará a mesma, alterando apenas o dia exato do pagamento dentro do mês.'
    }

    Write-Output ("Compreendo a sua solicitação para alterar a data de vencimento para o dia $Novo.`n`n" +
        "Para alinharmos as expectativas, como as nossas datas possuem referências de cobrança diferentes (mês anterior vs. mês vigente), essa mudança gerará o seguinte ajuste no seu faturamento:`n`n" +
        "$regra`n`n" +
        "O cenário da sua assinatura ficará assim:`n" +
        "• Último boleto gerado: vencimento em $ultimoStr (referente ao mês de $mesUltimo).`n" +
        "• Próximo boleto a faturar: vencimento em $proximoStr (referente ao mês de $mesProximo).`n`n" +
        "Você está de acordo com este ajuste para que eu possa encaminhar a solicitação de alteração ao nosso setor Financeiro?")
}
else {
    Write-Output ("Alteração Data Vencimento`n`n" +
        "Cliente entrou em contato solicitando para alterar a data de vencimento de seus boletos do dia $Atual para todo dia $Novo.`n`n" +
        "Foram passadas as seguintes informações ao cliente:`n" +
        "Último boleto gerado: $ultimoStr - Referente ao mês de $mesUltimo`n" +
        "Próximo boleto gerado: $proximoStr - Referente ao mês de $mesProximo`n`n" +
        "Por gentileza, verificar.")
}
