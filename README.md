# Wall-E — Atalhos Espanso (COM4)

Documentação completa para instalar o [Espanso](https://espanso.org/), usar este repositório e operar todos os atalhos de atendimento definidos em `base.yml`.

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

Este repositório contém:

- **`base.yml`** — atalhos de atendimento (financeiro, NOC, PMG, fibra, etc.)
- **`.env`** — nome do atendente, empresa e e-mail (personalização sem editar YAML)
- **`scripts/read-env.ps1`** — leitor das variáveis do `.env`

### 3.1 Instalação rápida (base.yml + .env + scripts)

1. Pare o Espanso (opcional, mas recomendado):

   ```powershell
   espanso stop
   ```

2. Copie os arquivos deste repositório para a pasta do Espanso:

   ```powershell
   # Ajuste o caminho do repositório se necessário
   $repo = "C:\Users\habbiner.andrade\Documents\00 - Atalhos Bot\wall-e"
   $match = "$env:APPDATA\espanso\match"

   Copy-Item -Path "$repo\base.yml" -Destination "$match\base.yml" -Force
   Copy-Item -Path "$repo\scripts" -Destination "$match\scripts" -Recurse -Force

   # Primeira vez: copie o exemplo e edite com seu nome
   if (-not (Test-Path "$match\.env")) {
     Copy-Item -Path "$repo\.env.example" -Destination "$match\.env"
   }
   ```

3. Edite o `.env` com seus dados (nome, empresa, e-mail):

   ```powershell
   notepad "$env:APPDATA\espanso\match\.env"
   ```

4. Reinicie o Espanso:

   ```powershell
   espanso start
   ```

5. Teste: digite `/dia` — deve aparecer **Sou [seu nome]** conforme o `.env`.

> Detalhes completos do `.env`: veja a [seção 4](#4-personalização-com-arquivo-env).

### 3.2 Editar os atalhos

**Opção A — pelo terminal (abre o Notepad por padrão):**

```powershell
espanso edit
```

**Opção B — editar este repositório e copiar de novo:**

Edite `base.yml` aqui no projeto, salve e repita o `Copy-Item` do passo 3.1.

**Opção C — abrir arquivo específico:**

```powershell
espanso edit match/base.yml
```

Após salvar, o Espanso recarrega a configuração automaticamente. Se não recarregar:

```powershell
espanso restart
```

### 3.3 Como disparar um atalho no dia a dia

1. Certifique-se de que o Espanso está **ativo** (ícone na bandeja).
2. Clique no campo de texto (Blip, e-mail, ticket, etc.).
3. Digite o trigger **exatamente** como está no YAML (ex.: `/unblock`).
4. Pressione **Espaço** ou **Enter** (comportamento padrão) para expandir.

**Dica:** triggers que usam **clipboard** (`/proto`) exigem que você copie o texto antes (Ctrl+C).

**Dica:** triggers com **formulário** (`/seg`, `/desbloq`) abrem uma janela para preencher campos antes de inserir o texto.

### 3.4 Estrutura esperada da pasta Espanso

```text
%AppData%\espanso\
├── config\
│   └── default.yml      ← comportamento global (velocidade, undo, etc.)
└── match\
    ├── base.yml         ← atalhos (este projeto)
    ├── .env             ← seu nome, empresa e e-mail
    └── scripts\
        └── read-env.ps1 ← leitor do .env
```

---

## 4. Personalização com arquivo `.env`

O projeto permite trocar **nome do atendente**, **empresa** e **e-mail** sem editar o `base.yml`. Basta alterar o arquivo `.env`.

### 4.1 Como funciona

O Espanso **não lê `.env` nativamente**. O fluxo é:

1. Você define valores em `match\.env` (pasta do Espanso).
2. O script `match\scripts\read-env.ps1` lê a chave solicitada.
3. O `base.yml` declara **variáveis globais** (`global_vars`) que chamam esse script via PowerShell.
4. Os atalhos usam placeholders como `{{atendente_nome}}`, `{{empresa_nome}}` e `{{email_atendimento}}`.

```text
.env  →  read-env.ps1  →  global_vars no base.yml  →  texto expandido
```

### 4.2 Onde fica o arquivo

| Local | Caminho | Observação |
|-------|---------|------------|
| **Em uso pelo Espanso** | `%AppData%\espanso\match\.env` | Este é o arquivo que importa no dia a dia |
| **No repositório (modelo)** | `.env.example` | Copie para criar seu `.env` |
| **No repositório (pessoal)** | `.env` | Ignorado pelo Git; só para desenvolvimento local |

O `.env` **deve ficar na mesma pasta** que o `base.yml` e a pasta `scripts\`.

### 4.3 Variáveis disponíveis

| Variável | Obrigatória | Valor padrão* | Descrição |
|----------|-------------|---------------|-----------|
| `ATENDENTE_NOME` | Não | `Bruno` | Nome exibido na abertura do atendimento |
| `EMPRESA_NOME` | Não | `COM4` | Nome da empresa nas mensagens ao cliente |
| `EMAIL_ATENDIMENTO` | Não | `atendimento@com4.com.br` | E-mail para solicitações formais (cPanel) |

\*Usados apenas se a chave estiver ausente no `.env` ou se o arquivo não existir.

**Formato do arquivo:**

```env
ATENDENTE_NOME=Seu Nome
EMPRESA_NOME=COM4
EMAIL_ATENDIMENTO=atendimento@com4.com.br
```

- Uma variável por linha: `CHAVE=valor`
- Linhas em branco e linhas que começam com `#` são ignoradas
- Não use espaços antes do nome da chave
- Aspas em volta do valor são opcionais (`"Maria"` ou `Maria`)

### 4.4 Atalhos que usam o `.env`

| Trigger | Variável `.env` | Trecho gerado (exemplo) |
|---------|-----------------|-------------------------|
| `/dia` | `ATENDENTE_NOME` | `Sou Maria e vou prosseguir com o seu atendimento.` |
| `/tchau` | `EMPRESA_NOME` | `A COM4 agradece o seu contato!...` |
| `/cpanel` | `EMAIL_ATENDIMENTO` | `...envio de um e-mail para atendimento@com4.com.br...` |
| `/loss` | `EMPRESA_NOME` | `...modem COM4 (aquele branco com o logo da COM4)...` |

Os demais atalhos **não** dependem do `.env` (texto fixo, formulário, clipboard ou datas).

### 4.5 Configurar pela primeira vez

```powershell
# 1. Copiar o modelo (se ainda não existir)
$match = "$env:APPDATA\espanso\match"
if (-not (Test-Path "$match\.env")) {
  Copy-Item ".\.env.example" "$match\.env"
}

# 2. Editar com seus dados
notepad "$match\.env"

# 3. Aplicar
espanso restart
```

### 4.6 Trocar de atendente ou empresa

1. Abra `%AppData%\espanso\match\.env`.
2. Altere apenas as linhas desejadas (ex.: `ATENDENTE_NOME=Ana`).
3. Salve o arquivo.
4. Execute `espanso restart`.
5. Teste com `/dia` ou `/tchau`.

Não é necessário editar o `base.yml` nem copiar arquivos de novo — só o `.env`.

### 4.7 Arquivos do repositório relacionados

| Arquivo | Função |
|---------|--------|
| `.env.example` | Modelo versionado no Git; copie para `.env` |
| `.env` | Sua configuração local (ignorada pelo `.gitignore`) |
| `scripts/read-env.ps1` | Script que lê uma chave do `.env` |
| `base.yml` | Define `global_vars` e referências `{{...}}` |

Trecho relevante no `base.yml`:

```yaml
global_vars:
  - name: atendente_nome
    type: shell
    params:
      shell: powershell
      cmd: '& "$env:CONFIG\match\scripts\read-env.ps1" -Key ATENDENTE_NOME -Default "Bruno"'
  # ... empresa_nome, email_atendimento
```

### 4.8 Adicionar uma nova variável ao `.env`

1. Inclua a chave em `.env.example` e no seu `.env`.
2. Adicione um bloco em `global_vars` no `base.yml` (copie o padrão de `atendente_nome`).
3. Use `{{nome_da_variavel}}` no `replace` do atalho desejado.
4. Copie `scripts\` e `base.yml` para `%AppData%\espanso\match\` e rode `espanso restart`.

### 4.9 Git e compartilhamento

- **Commit:** apenas `.env.example` (sem dados pessoais).
- **Não commitar:** `.env` (está no `.gitignore`).
- Cada atendente mantém seu próprio `.env` na máquina local.

---

## 5. Comandos do Espanso por categoria

Todos os comandos abaixo são executados no **PowerShell**, **CMD** ou **Terminal**, com o Espanso no PATH.

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

| Trigger | Nome | O que faz | Observação |
|---------|------|-----------|------------|
| `/dia` | Saudação dinâmica | Abre atendimento com bom dia / boa tarde / boa noite conforme horário | Usa `.env` (`ATENDENTE_NOME`) + PowerShell |
| `/proto` | Protocolo | Insere: `O número do protocolo...` + conteúdo da área de transferência | Copie o protocolo antes (Ctrl+C) |

### 6.2 Financeiro — desbloqueio e boletos

| Trigger | Nome | O que faz | Observação |
|---------|------|-----------|------------|
| `/unblock` | Desbloqueio em acordo | Mensagem ao cliente com prazo D+2 dias úteis | Data calculada automaticamente |
| `/seg` | 2ª via de boleto | Texto de envio da 2ª via | Abre formulário: informe o **vencimento** |
| `/desbloq` | Registro interno — desbloqueio | Nota interna com canal, nome, telefone e prazo D+2 | Formulário: Blip ou Ligação |
| `/baixa` | Registro interno — comprovante | Nota de compensação prevista D+1 dia útil | Formulário: canal Blip, E-mail ou Ligação |
| `/norm` | Normalização | Confirma que desbloqueio foi concluído | Texto fixo |
| `/comp` | Comprovante recebido | Confirma recebimento do comprovante | Texto fixo |
| `/bloqueado` | Serviço suspenso | Informa bloqueio por fatura em aberto | Formulário: data de **vencimento** |
| `/pagou` | Pagamento confirmado | Registro interno: compensado no sistema | Texto fixo |
| `/calote` | Acordo quebrado | Registro interno: suspensão retomada | Texto fixo |

### 6.3 Inatividade e encerramento (cliente)

| Trigger | Nome | O que faz | `.env` |
|---------|------|-----------|--------|
| `/alerta` | Alerta de inatividade | Avisa encerramento em 30 min sem resposta | — |
| `/final` | Encerramento por inatividade | Mensagem de encerramento ao cliente | — |
| `/aux` | Oferta de ajuda extra | Pergunta se pode ajudar em mais algo | — |
| `/tchau` | Despedida | Agradecimento e encerramento cordial | `EMPRESA_NOME` |
| `/cha` | Encerramento simples | Texto curto: `chamado encerrado` | — |

### 6.4 Registros internos (NOC / Gateway / timeout)

| Trigger | Nome | O que faz | Observação |
|---------|------|-----------|------------|
| `/instruir` | Orientação Gateway Antispam | Registro de instrução técnica ao cliente | Formulário: canal |
| `/timeout` | Encerramento por timeout | Registro longo de inatividade no Blip | Texto fixo |
| `/nada` | Encerramento interno | `Nada mais a mim cabia auxiliar` | Uso interno |

### 6.5 PMG / Antispam (cliente)

| Trigger | Nome | O que faz |
|---------|------|-----------|
| `/pmg` | Relatório PMG | Texto completo sobre relatório, quarentena, Whitelist/Blacklist e PDF de apoio |

### 6.6 Credenciais (cPanel)

| Trigger | Nome | O que faz | `.env` |
|---------|------|-----------|--------|
| `/cpanel` | Solicitação formal cPanel | Pedido de e-mail com dados obrigatórios para envio de credenciais | `EMAIL_ATENDIMENTO` |

### 6.7 Suporte técnico — fibra e modem

| Trigger | Nome | O que faz | `.env` |
|---------|------|-----------|--------|
| `/fibra` | Verificação do cabo drop | Orientação para checar conexão da fibra sem remover o cabo | — |
| `/loss` | LED LOS vermelho | Explica perda de sinal e encaminhamento à manutenção | `EMPRESA_NOME` |
| `/visita` | Agendamento de visita | Solicita endereço e disponibilidade com avisos importantes | — |
| `/eng` | Escalonamento N2 | Informa escalonamento para Engenharia | — |

---

## 7. Recursos avançados usados neste arquivo

O `base.yml` usa três tipos de extensão do Espanso além do texto fixo.

### 7.1 Variáveis globais e `.env`

Definidas no topo do `base.yml` em `global_vars`. São carregadas pelo script `read-env.ps1` a partir de `match\.env`.

Variáveis expostas nos atalhos:

- `{{atendente_nome}}` ← `ATENDENTE_NOME`
- `{{empresa_nome}}` ← `EMPRESA_NOME`
- `{{email_atendimento}}` ← `EMAIL_ATENDIMENTO`

### 7.2 Variável `shell` (PowerShell)

Usada em `/dia`, `/unblock`, `/desbloq` e `/baixa` para calcular datas ou saudação.

**Exemplo — saudação por horário (`/dia`):**

```yaml
vars:
  - name: saudacao
    type: shell
    params:
      cmd: "$h = (Get-Date).Hour; if ($h -lt 12) { 'bom dia' } elseif ($h -lt 18) { 'boa tarde' } else { 'boa noite' }"
      shell: powershell
```

**Exemplo — D+2 dias úteis (`/unblock`, `/desbloq`):**

O script avança a data pulando sábado e domingo até contar 2 dias úteis.

### 7.3 Variável `clipboard`

Usada em `/proto`:

1. Copie o número do protocolo (Ctrl+C).
2. Digite `/proto` e confirme.
3. O Espanso cola o texto copiado no lugar de `{{clipboard}}`.

### 7.4 Formulários (`form` e `type: form`)

**Formulário simples** — campo `[[nome]]` na própria linha `form:`:

```yaml
- trigger: "/seg"
  form: |
    ... vencimento em [[vencimento]] ...
```

**Formulário com campos estruturados** — usado em `/desbloq`, `/baixa`, `/instruir`:

```yaml
- name: formulario
  type: form
  params:
    layout: |
      Canal: [[canal]]
      Nome: [[nome]]
    fields:
      canal:
        type: choice
        values:
          - Blip
          - Ligação
```

No texto final, use `{{formulario.canal}}`, `{{formulario.nome}}`, etc.

### 7.5 Como adicionar um novo atalho

Adicione um bloco dentro de `matches:` no `base.yml`:

```yaml
  - trigger: "/meuatalho"
    replace: "Texto que será inserido."
```

Salve, reinicie se necessário (`espanso restart`) e teste.

**Regras importantes:**

- Use **espaços** para indentação (2 espaços por nível), não tabs.
- Cada item em `matches:` começa com `- trigger:`.
- Comentários no YAML usam `#`.

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
| Atalho não expande | Verifique `espanso status`; use `espanso restart` |
| Ícone não aparece na bandeja | Inicie pelo Menu Iniciar; reinstale se persistir |
| `/proto` vem vazio | Copie o texto (Ctrl+C) **antes** de disparar o trigger |
| Data ou saudação errada | Confirme que PowerShell funciona: `powershell -Command "Get-Date"` |
| Erro ao salvar YAML | Revise indentação; valide em [yamllint.com](https://www.yamllint.com/) |
| Espanso não recarrega após editar | `espanso restart` |
| Conflito em um app específico | Crie `config/nome-do-app.yml` com filtros — ver [documentação app-specific](https://espanso.org/docs/configuration/app-specific-configurations/) |
| Debug de scripts | Adicione `debug: true` em `params` do shell e rode `espanso log` |
| `/dia` ainda mostra "Bruno" (ou nome antigo) | Confira se editou `%AppData%\espanso\match\.env` (não só o `.env` do repositório); rode `espanso restart` |
| Variável `.env` não aparece no texto | Verifique se `match\scripts\read-env.ps1` existe; teste manualmente (veja abaixo) |
| Aparece `{{atendente_nome}}` literal | Pasta `scripts` ausente ou erro no PowerShell; veja `espanso log` |
| `.env` ignorado | Arquivo deve estar em `match\.env`, não na raiz de `espanso\` |

**Testar leitura do `.env` manualmente:**

```powershell
$env:CONFIG = "$env:APPDATA\espanso"
& "$env:CONFIG\match\scripts\read-env.ps1" -Key ATENDENTE_NOME -Default Bruno
```

Deve retornar o valor definido no seu `.env`.

**Validar sintaxe após copiar o arquivo:**

```powershell
espanso restart
espanso log
```

Digite um trigger com shell (`/dia`) e observe se há erros no log.

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
