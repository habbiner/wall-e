# Wall-E — Atalhos Espanso (COM4)

Documentação para instalar o [Espanso](https://espanso.org/), configurar este repositório e usar os atalhos do `base.yml`.

Os **textos** dos atalhos foram revisados com foco em **clareza, coesão, quebras de linha legíveis** e **emoji** onde faz sentido (ex.: `/dia`, `/alerta`, `/pmg`). A personalização por pessoa (**nome, empresa, e-mail**) continua no arquivo **`.env`**, sem precisar editar cada frase dentro do YAML.

---

## Índice

1. [O que é o Espanso](#1-o-que-é-o-espanso)
2. [Instalação no Windows](#2-instalação-no-windows)
3. [Como usar este projeto (wall-e)](#3-como-usar-este-projeto-wall-e)
4. [Personalização com arquivo `.env`](#4-personalização-com-arquivo-env)
5. [Comandos do Espanso por categoria](#5-comandos-do-espanso-por-categoria)
6. [Atalhos do base.yml por categoria](#6-atalhos-do-baseyml-por-categoria)
7. [Recursos avançados usados neste arquivo](#7-recursos-avançados-usados-neste-arquivo)
8. [Atalhos de teclado do Espanso](#8-atalhos-de-teclado-do-espanso)
9. [Solução de problemas](#9-solução-de-problemas)
10. [Referências](#10-referências)

---

## 1. O que é o Espanso

O **Espanso** é um expansor de texto gratuito e open source. Você digita um **trigger** (atalho, por exemplo `/dia`) e o Espanso substitui por um texto maior, formulário ou conteúdo dinâmico.

| Conceito | Descrição |
|----------|-----------|
| **Trigger** | Palavra-chave que você digita (ex.: `/proto`) |
| **Match** | Regra que liga o trigger ao texto/ação |
| **Replace** | Texto final inserido |
| **Variável** | Valor dinâmico (data, clipboard, PowerShell, formulário) |
| **$CONFIG** | Pasta de configuração do Espanso no seu PC |

No Windows, a pasta padrão é:

```text
%AppData%\espanso
```

Exemplo: `C:\Users\SEU_USUARIO\AppData\Roaming\espanso`

---

## 2. Instalação no Windows

### 2.1 Baixar e instalar

> ⚠️ **Pré-requisito:** este projeto usa `shell: pwsh` nos scripts internos (mais rápido que o Windows PowerShell 5.1 padrão). Instale o **PowerShell 7** antes de usar o `base.yml`: https://aka.ms/powershell-release?tag=stable

1. Acesse [espanso.org/install](https://espanso.org/install/) e baixe o instalador para Windows.
2. Execute o instalador e conclua a instalação.
3. Inicie o Espanso pelo **Menu Iniciar** (ícone na bandeja do sistema).
4. Teste em qualquer campo de texto: digite `:espanso` — deve aparecer `Hi there!`.

### 2.2 Verificar se está rodando

Abra o **PowerShell** ou **Prompt de Comando** e execute:

```powershell
espanso status
```

Resposta esperada: `espanso is running`.

Se não estiver rodando:

```powershell
espanso start
```

### 2.3 Descobrir a pasta de configuração

```powershell
espanso path
```

Anote o caminho retornado — é onde você colará o `base.yml` deste projeto.

---

## 3. Como usar este projeto (wall-e)

### Conteúdo principal do repositório

- **`base.yml`** — todos os triggers (financeiro, NOC, PMG, fibra, etc.) e leitura do `.env` **dentro** do próprio arquivo (variáveis `global_vars` via PowerShell).
- **`.env.example`** — modelo de variáveis; copie para `.env` na pasta do Espanso (ver [seção 4](#4-personalização-com-arquivo-env)).
- **`sync.ps1`** *(opcional)* — chama `scripts/sync-to-espanso.ps1`, se você mantiver essa pasta no clone (copia para `%AppData%\espanso\match\` e reinicia o daemon).

Para funcionar na sua máquina, o Espanso precisa pelo menos:

- `%AppData%\espanso\match\base.yml`

e, para personalização por pessoa,

- `%AppData%\espanso\match\.env`

**Não** é obrigatório haver pasta `scripts\` no Espanso: o `base.yml` atual **não** depende de `read-env.ps1`.

### 3.1 Instalação manual (copiar arquivo na pasta do Espanso)

Caminho típico no Windows:

```text
C:\Users\SEU_USUARIO\AppData\Roaming\espanso\match\
```

Passos:

1. Copie o `base.yml` do repositório para `...\espanso\match\base.yml` (substituindo o existente).
2. Se ainda não tiver `.env` na pasta `match`, copie `.env.example` para `.env` e edite seus dados ([seção 4](#4-personalização-com-arquivo-env)).
3. Reinicie o Espanso pela bandeja ou com `espanso restart` (se `espanso` estiver no PATH), ou usando `espansod.exe` em `%LOCALAPPDATA%\Programs\Espanso\`.
4. Teste no **Bloco de Notas** ou no **Blip**: `/dia` + Espaço/Enter → deve aparecer **“Sou … e darei sequência…”** com o nome do `.env`.

Exemplo rápido no PowerShell (ajuste o caminho da pasta do projeto):

```powershell
$repo = "C:\CAMINHO\para\wall-e"
$match = "$env:APPDATA\espanso\match"
Copy-Item "$repo\base.yml" "$match\base.yml" -Force
if (-not (Test-Path "$match\.env")) {
  Copy-Item "$repo\.env.example" "$match\.env"
  notepad "$match\.env"
}
```

### 3.2 Sincronização automática *(opcional, se existir `scripts/sync-to-espanso.ps1`)*

Se o seu clone incluir `scripts\sync-to-espanso.ps1`, você pode usar:

```powershell
.\sync.ps1
```

```powershell
.\sync.ps1 -Watch
```

Parâmetros úteis: `-NoRestart`, `-AtualizarEnv` (consulte o próprio script).

| Origem típica | Destino |
|---------------|---------|
| `base.yml` | `%AppData%\espanso\match\base.yml` |
| `.env` *(primeira cópia, conforme flags do script)* | `%AppData%\espanso\match\.env` |

**CLI fora do PATH:** muitos PCs usam apenas `espansod.exe`; um script bem configurado pode apontar para `%LOCALAPPDATA%\Programs\Espanso\espansod.exe`. O daemon costuma também **detectar alteração** no `base.yml` e recarregar.

### 3.3 Editar os atalhos

**Opção A — pelo terminal do Espanso (se estiver no PATH):**

```powershell
espanso edit
```

**Opção B — editar na pasta do repositório e copiar manualmente:**

Edite `base.yml` no projeto, salve e copie de novo para `%AppData%\espanso\match\base.yml` (vide [3.1](#31-instalação-manual-copiar-arquivo-na-pasta-do-espanso)).

**Opção C — abrir arquivo específico:**

```powershell
espanso edit match/base.yml
```

Após salvar, o Espanso recarrega a configuração automaticamente. Se não recarregar:

```powershell
espanso restart
```

### 3.4 Como disparar um atalho no dia a dia

1. Certifique-se de que o Espanso está **ativo** (ícone na bandeja).
2. Clique no campo de texto (Blip, e-mail, ticket, etc.).
3. Digite o trigger **exatamente** como está no YAML (ex.: `/unblock`).
4. Pressione **Espaço** ou **Enter** (comportamento padrão) para expandir.

**Dica:** atalhos com **formulário** (`/proto`, `/seg`, `/bloqueado`, `/desbloq`) abrem uma janela: preencha **só** o que o texto pede (ex.: **`/proto`** → **somente o número do protocolo**).

**Dica:** em vários aplicativos, testar primeiro no **Bloco de Notas** evita dúvidas se o problema é o Espanso ou o chat.

### 3.5 Estrutura mínima da pasta do Espanso

```text
%AppData%\espanso\
├── config\
│ └── default.yml ← comportamento global (opcionalmente ajuste backend, etc.)
└── match\
├── base.yml ← atalhos (este projeto)
├── .env ← recomendado: nome / empresa / e-mail / valores financeiros
└── scripts\
└── calc_vencimento.ps1 ← lógica de cálculo de vencimento (/venc e /logvenc)
```

Pacotes do Hub ficam em `match\packages\` se você instalar algo extra.

---

## 4. Personalização com arquivo `.env`

O projeto permite trocar **nome do atendente**, **empresa** e **e-mail** sem alterar cada mensagem dentro do YAML: isso vai no arquivo `match\.env`.

### 4.1 Como funciona

O Espanso não lê .env nativamente, e **não existe uma forma de tratar o conteúdo de `match\.env` como variáveis de ambiente reais do Windows** — o tipo de variável `type: environment` do Espanso só enxerga variáveis de ambiente do sistema operacional, nunca esse arquivo. Por isso, cada valor é obtido assim:

1. Você mantém um arquivo `.env` na pasta `match` (ao lado do `base.yml`).
2. No topo do `base.yml`, há seis `global_vars` do tipo `shell` (rodando via **PowerShell 7 / `pwsh`**, não o Windows PowerShell padrão) que leem o arquivo `match\.env` e extraem linhas como `CHAVE=valor`.
3. Os triggers usam `{{atendente_nome}}`, `{{empresa_nome}}`, `{{email_atendimento}}`, `{{valor_mensalidade_fid}}`, `{{multa_comodato}}` e `{{contato_registro_br}}` no texto expandido.
4. Onde não houver arquivo ou não houver a linha da chave, entram os valores padrão definidos dentro do próprio script (fallback), então mantenha o `.env` sempre completo.

> ⚠️ Já tentamos migrar essas variáveis para `type: environment` para evitar abrir processos PowerShell — **não funciona**, porque isso quebra a leitura do `.env` (as variáveis vêm vazias e o rendering do trigger é abortado). Fica registrado aqui para não repetir o erro.

```text
match\.env  →  PowerShell em global_vars  →  {{...}} nos textos
```

**Implementação atual:** não é necessário arquivo `scripts\read-env.ps1`; tudo está embutido nos blocos `cmd:` sob `global_vars`.

### 4.2 Onde fica o arquivo

| Local | Caminho | Observação |
|-------|---------|------------|
| **Em uso pelo Espanso** | `%AppData%\espanso\match\.env` | Arquivo que vale no dia a dia |
| **No repositório (modelo)** | `.env.example` | Copie para criar seu `.env` |
| **No repositório (pessoal)** | `.env` | Opcional para backup local; pode estar no `.gitignore` |

O `.env` deve ficar **na mesma pasta** que `base.yml` dentro de `match\`.

### 4.3 Variáveis disponíveis

| Variável no .env | Obrigatória | Padrão se ausente | Onde aparece nos atalhos |
|---|---|---|---|
| ATENDENTE_NOME | Não | Bruno | `/ola` ("Sou … e darei sequência…") |
| EMPRESA_NOME | Não | COM4 | `/tchau`, `/los`, `/roteadores`, `/senhaemail`, `/senhacp` |
| EMAIL_ATENDIMENTO | Não | atendimento@com4.com.br | `/cpanel`, `/cancelapj` |
| VALOR_MENSALIDADE_FID | Não | 499.90 | `/fid` (cálculo de multa de fidelidade) |
| MULTA_COMODATO | Não | 525,00 | `/comodato` |
| CONTATO_REGISTRO_BR | Não | PHF5 | `/migracontato` |
| DESPEDIDA_MANHA | Não | Tenha um ótimo dia | `/tchau` (despedida dinâmica pela hora) |
| DESPEDIDA_TARDE | Não | Tenha uma ótima tarde | `/tchau` |
| DESPEDIDA_NOITE | Não | Tenha uma ótima noite | `/tchau` |

### 4.4 Formato do `.env`

```env
ATENDENTE_NOME=Seu nome
EMPRESA_NOME=COM4
EMAIL_ATENDIMENTO=atendimento@com4.com.br
```

Regras práticas:

- Uma variável por linha: `CHAVE=valor`.
- Linhas iniciadas por `#` costumam ser ignoradas porque **não** batem no padrão `CHAVE=valor` usado no script.
- Evite espaço antes da chave. Aspas ao redor do valor são opcionais.

### 4.5 Matches que devem usar `type: global` para o nome/empresa

No Espanso, variáveis globais às vezes precisam ser **declaradas de novo no bloco `vars`** do match com **`type: global`** para garantir que sejam avaliadas na expansão — isso já está feito onde necessário (`/dia`, `/tchau`, `/cpanel`, `/loss`).

### 4.6 Configurar pela primeira vez no PC

```powershell
$match = "$env:APPDATA\espanso\match"
if (-not (Test-Path "$match\.env")) {
  Copy-Item ".\.env.example" "$match\.env"   # ajuste o caminho de origem ao repo
}
notepad "$match\.env"
espanso restart   # ou reinicie pela bandeja / espansod.exe
```

### 4.7 Trocar de atendente

1. Edite `%AppData%\espanso\match\.env` (linha `ATENDENTE_NOME=…`).
2. Salve e reinicie o Espanso (ou aguarde o recarregamento automático ao salvar arquivo, conforme versão/comportamento).
3. Teste com `/dia`.

### 4.8 Adicionar nova variável

1. Crie uma linha em `.env.example` e no seu `.env`.
2. Copie um bloco existente em `global_vars:` (mesmo padrão de `ATENDENTE_NOME`), ajustando o nome da variável Espanso e o regex na linha `$_ -match '^\s*NOME_DA_CHAVE\s*='`.
3. Use `{{nome_da_variavel}}` no `replace`; se for global derivada disso, adicione `vars` com `- type: global` no match onde precisar.
4. Recarregue o Espanso.

### 4.9 Git e compartilhamento

**Commit:** apenas `.env.example` (sem dados pessoais).  
**Evite commitar:** `.env` com nome real ou e-mails internos — use `.gitignore` conforme combinado pela equipe.  
Quem clonar só precisa **`base.yml` + `.env` criado a partir do exemplo**.

---

## 5. Comandos do Espanso por categoria

Na linha de comando, o projeto costuma aparecer como **`espansod.exe`** ou pelo atalho **`espanso.cmd`** dentro de `%LOCALAPPDATA%\Programs\Espanso\`. Se `espanso` não resolver no PATH, use o caminho completo ao executável (ex.: `& "$env:LOCALAPPDATA\Programs\Espanso\espansod.exe" status`).

### 5.1 Serviço (iniciar / parar / status)

| Comando | Descrição |
|---------|-----------|
| `espanso start` | Inicia o Espanso em segundo plano |
| `espanso stop` | Encerra o Espanso |
| `espanso restart` | Reinicia (útil após editar YAML ou instalar pacote) |
| `espanso status` | Mostra se está em execução |

### 5.2 Configuração e caminhos

| Comando | Descrição |
|---------|-----------|
| `espanso path` | Exibe o caminho da pasta `$CONFIG` |
| `espanso edit` | Abre `match/base.yml` no editor padrão |
| `espanso edit config/default.yml` | Abre configurações globais |
| `espanso edit match/base.yml` | Abre o arquivo de atalhos |
| `espanso edit emails` | Atalho: abre `match/emails.yml` se existir |

**Personalizar o editor (Windows):**

```powershell
$env:EDITOR = "C:\Program Files\Notepad++\notepad++.exe"
espanso edit
```

Ou defina a variável de ambiente `EDITOR` permanentemente nas Configurações do Windows.

### 5.3 Pacotes (Espanso Hub)

| Comando | Descrição |
|---------|-----------|
| `espanso install NOME_PACOTE` | Instala pacote do [Espanso Hub](https://hub.espanso.org/) |
| `espanso uninstall NOME_PACOTE` | Remove pacote instalado |
| `espanso package list` | Lista pacotes instalados |
| `espanso package list --all` | Lista pacotes disponíveis no Hub |
| `espanso package update NOME` | Atualiza um pacote |
| `espanso package update --all` | Atualiza todos os pacotes |

Exemplo:

```powershell
espanso install basic-emojis
espanso restart
```

### 5.4 Diagnóstico e logs

| Comando | Descrição |
|---------|-----------|
| `espanso log` | Exibe logs em tempo real (útil para debug de scripts PowerShell) |
| `espanso --help` | Ajuda geral da CLI |
| `espanso COMANDO --help` | Ajuda de um subcomando específico |

### 5.5 Modo portátil e migração (avançado)

| Comando | Descrição |
|---------|-----------|
| `espanso cmd` | Abre interface de comandos (também via Search Bar com `>`) |
| `espanso launcher` | Gerencia integração com o launcher do sistema |

> Para a maioria dos usuários deste projeto, os comandos das seções **5.1**, **5.2** e **5.4** são os mais usados no dia a dia.

---

## 6. Atalhos do base.yml por categoria

Todos os triggers começam com **`/`**. Digite o comando e confirme com Espaço/Enter.

### 6.1 Abertura e protocolo

| Trigger | Função breve | Detalhes |
|---------|----------------|----------|
| `/dia` | Saudação com horário (`bom dia` / `boa tarde` / `boa noite`) 😊 | Corpo em parágrafos; nome vem do `.env` (`ATENDENTE_NOME`); fecha pedindo dados (nome / telefone / e-mail). |
| `/proto` | Frase padronizada com **nº do protocolo** | Formulário: **informe apenas o dígito/código do protocolo** (evita colar texto errado da área de transferência). |

### 6.2 Financeiro — desbloqueio e boletos

| Trigger | Função breve |
|---------|----------------|
| `/unblock` | Desbloqueio em acordo + aviso sobre possível novo bloqueio até data **D+2 úteis** |
| `/seg` | Texto da 2ª via + formulário **[[vencimento]]** |
| `/desbloq` | 📌 Nota interna (canal + solicitante + D+2) |
| `/baixa` | 📌 Nota interna (canal + comprovante + D+1) |
| `/norm` | Confirmar normalização da conexão após desbloqueio |
| `/comp` | Confirmação de comprovante recebido ✅ |
| `/bloqueado` | Suspensão por fatura; formulário **[[vencimento]]** |
| `/pagou` / `/calote` | Registros internos de compensação / retomada de suspensão |

### 6.3 Inatividade e encerramento (cliente)

| Trigger | Função breve |
|---------|----------------|
| `/alerta` | Lembrete de inatividade (30 min) 😊 |
| `/final` | Encerramento por falta de resposta 🤝 |
| `/aux` | Convite para nova demanda 😊 |
| `/tchau` | Despedida com nome da empresa (`EMPRESA_NOME` no `.env`) 😊 |
| `/cha` | “Chamado encerrado.” (curto) |

### 6.4 Registros internos (NOC / Gateway / timeout)

| Trigger | Função breve |
|---------|----------------|
| `/instruir` | 📌 Registro sobre orientação gateway antispam |
| `/timeout` | 📌 Timeout Blip sem incidentes novos |
| `/nada` | Frase interna de escopo (“Nada mais coube…” ) |

### 6.5 PMG / Antispam (cliente)

| Trigger | Função breve |
|---------|----------------|
| `/pmg` | Explica relatório PMG, link “web”, opções do painel (✅ ❌ 📨 🗑️), riscos ao desativar filtro + PDF 😊 |

### 6.6 Credenciais (cPanel)

| Trigger | Função breve |
|---------|----------------|
| `/cpanel` | Pedido formal de dados por e-mail para `{{email_atendimento}}` (⚠️ e-mail corporativo) |

### 6.7 Suporte — fibra, visita e N2

| Trigger | Função breve |
|---------|----------------|
| `/fibra` | Passo a passo da fibra física ✅ |
| `/loss` | LOS / luz vermelha + Modem `{{empresa_nome}}` |
| `/visita` | Coleta endereço/horários + avisos de visita |
| `/eng` | Escalonamento para Engenharia N2 |

> Os **emojis** e as **linhas em branco** fazem parte do texto final onde estão no `base.yml` — ajudam leitura no chat.

---

## 7. Recursos avançados usados neste arquivo

Combinamos **substituição longa**, **variáveis** e **PowerShell**.

### 7.1 `global_vars` + `.env` (PowerShell inline)

Os três campos vindos do `.env` são variáveis **globais** definidas como `shell: powershell` no topo do arquivo. Elas leem `Join-Path $env:CONFIG 'match\.env'` e localizam linhas como `CHAVE=valor`:

- `{{atendente_nome}}` ← `ATENDENTE_NOME`
- `{{empresa_nome}}` ← `EMPRESA_NOME`
- `{{email_atendimento}}` ← `EMAIL_ATENDIMENTO`

Em vários triggers, aparece também `vars: - type: global` para garantir que o Espanso avalie esse valor antes de montar o texto.

### 7.2 Blocos `replace: |` (parágrafos e espaço vertical)

Trechos corridos foram **quebrados em parágrafos** usando `|` (literal block scalar) no YAML, com linhas em branco onde o chat precisa respirar. Isso aparece forte em `/pmg`, `/fibra`, `/visita`, etc.

### 7.3 Variável local `shell` (datas e saudação)

No `/dia`, a saudação `{{saudacao}}` usa um `shell` curto pela hora do sistema. Nos financeiros `/unblock`, `/desbloq` e `/baixa`, outro `shell` calcula **D+N dias úteis** (pulando fins de semana).

### 7.4 Formulários

- **`form:` com `[[campo]]`** — usado em `/proto`, `/seg`, `/bloqueado` para preencher protocolo ou vencimento.
- **`type: form` em `vars`** — usado quando o texto final referencia campos estruturados (`{{formulario.canal}}`, etc.), como `/desbloq`, `/baixa`, `/instruir`.

### 7.5 Dica de edição YAML

Ao alterar só textos dentro de um `replace: |`, **não** recoloque `vars:` no meio do parágrafo (isso quebra o parse e faz **sumirem todos** os triggers). Liste `vars` **depois** de fechar o bloco da mensagem.

### 7.6 Adicionar um novo atalho

```yaml
  - trigger: "/novo"
    replace: |
      Primeira linha.

      Segunda linha — mantenha emojis 😊 quando fizer sentido.
```

Salve, recarregue o Espanso e teste. Use **indentação por espaços** (2 espaços por nível).

---

### 7.7 Script externo para cálculo de vencimento (`/venc` e `/logvenc`)

A lógica de cálculo de mudança de dia de vencimento (usada tanto na mensagem ao cliente quanto no log interno do Financeiro) foi extraída para um único arquivo `scripts\calc_vencimento.ps1`, para não duplicar ~80 linhas de PowerShell em dois triggers.

Uso no `base.yml`:

```yaml
cmd: |
  & "$env:CONFIG\match\scripts\calc_vencimento.ps1" -Atual "{{atual}}" -Novo "{{novo}}" -UltimoGerado "{{formulario.ultimo_gerado}}" -Modo cliente
```

O parâmetro `-Modo` aceita `cliente` (texto para enviar ao cliente) ou `interno` (texto para o log do Financeiro).

> ⚠️ Não use `%CONFIG%` (sintaxe de variável do CMD/batch) dentro do `cmd:` — o Espanso executa esse bloco via PowerShell, então a sintaxe correta é `$env:CONFIG`, chamada com o operador `&` (call operator) já que o caminho está entre aspas.

Se editar a regra de cálculo, mexa apenas em `scripts\calc_vencimento.ps1` — nenhum dos dois triggers precisa mudar.

---
## 8. Atalhos de teclado do Espanso

| Atalho | Ação |
|--------|------|
| **Alt + Espaço** | Abre a **Search Bar** (busca e insere qualquer match) |
| **Backspace** (logo após expansão) | **Desfaz** a última expansão acidental |
| Tecla de toggle (configurável) | Liga/desliga o Espanso sem fechar o app |

Na Search Bar, comandos que começam com `>` mostram opções de controle do Espanso.

---

## 9. Solução de problemas

| Problema | Solução |
|----------|---------|
| Atalho não expande | Confirme ícone Espanso ativo na bandeja; `espanso status`/reinício. Teste primeiro no Bloco de Notas. |
| Ícone não aparece na bandeja | Inicie pelo Menu Iniciar; reinstale se persistir |
| Saudação/Data errada nos financeiros (`/dia`, D+N útil) | Powershell deve executar comandos rápidos: `powershell -Command "Get-Date"` |
| `/proto` traz texto errado (nome, trecho anterior, etc.) | O campo deve receber **só** o código do protocolo. Se você colar outro texto, o Espanso insere esse texto mesmo. |
| Mensagem aparece como `{{nome}}` sem expandir | Erro ao renderizar: veja **`espanso log`**. Às vezes é YAML inválido (por exemplo **`vars:` colado no meio** de um texto em `replace` com bloco YAML `|`). |
| Variáveis `.env` não refletidas (ex.: sempre “Bruno”) | Use `%AppData%\espanso\match\.env` (ação no PC), não apenas `.env` da pasta do repositório, salvo que você sempre copie os dois arquivos juntos |
| `.env` ignorado ou placeholders estranhos | Arquivo deve estar em `match\.env`, **mesma pasta** do `base.yml` |
| Espanso não recarrega após editar | `espanso restart` *(ou pare/inicie pela bandeja)* |
| `espanso` não reconhecido no terminal | Use `espansod.exe` ou `espanso.cmd` sob `%LOCALAPPDATA%\Programs\Espanso\` |
| Conflitos só em um app (Blip x outro) | Considere [configurações por aplicativo](https://espanso.org/docs/configuration/app-specific-configurations/) |
| Scripts shell lentos ou falhos | Use `debug: true` dentro de `params` do shell e `espanso log` |
| Erro "program not found" ao rodar shell | Confirme que o **PowerShell 7** está instalado e que `pwsh` funciona no terminal; o `base.yml` usa `shell: pwsh`, não `shell: powershell` |
| `{{variavel}}` do .env sempre vazia após trocar para `type: environment` | Não use `type: environment` para ler o `.env` — o Espanso não carrega esse arquivo como variáveis de ambiente do sistema. Mantenha `type: shell` lendo `match\.env` via `Get-Content` |

**YAML inválido (erro grave):** valide com [yamllint.com](https://www.yamllint.com/) — um arquivo quebrado impede todos os triggers de carregar.

**Diagnosticar problema de YAML após edição:**

```powershell
espanso restart    # ou equivalente via espansod.exe
espanso log        # procure por "failed to parse" ou erro no base.yml
```

Dispare `/dia` e observe mensagens relacionadas ao **rendering**.

---

## 10. Referências

- Site oficial: [https://espanso.org/](https://espanso.org/)
- Instalação: [https://espanso.org/install/](https://espanso.org/install/)
- Primeiros passos: [https://espanso.org/docs/get-started/](https://espanso.org/docs/get-started/)
- Configuração: [https://espanso.org/docs/configuration/basics/](https://espanso.org/docs/configuration/basics/)
- Extensões (shell, clipboard, form): [https://espanso.org/docs/matches/extensions/](https://espanso.org/docs/matches/extensions/)
- Formulários: [https://espanso.org/docs/matches/forms/](https://espanso.org/docs/matches/forms/)
- Pacotes (Hub): [https://hub.espanso.org/](https://hub.espanso.org/)

---

## Licença

Este projeto está sob a licença MIT — veja o arquivo [LICENSE](LICENSE).
