*[English](README.md) · **Português (Brasil)***

# TMS Smart Setup — Projeto de Exemplo

Uma pequena aplicação VCL em Delphi cuja única função é demonstrar o
[TMS Smart Setup](https://www.smartsetup.org): instalar componentes, salvar um snapshot com as
versões exatas, restaurá-las em outra máquina e compilar tudo — dependências incluídas — a partir
de um agente de CI/CD.

Ela depende de duas bibliotecas de terceiros, nenhuma delas um produto TMS, ambas vindas do
[registro da comunidade](https://github.com/tmssoftware/smartsetup-registry):

| Biblioteca | Id do produto | Usada na aplicação para |
|---|---|---|
| [Spring4D](https://bitbucket.org/sglienke/spring4d) | `sglienke.spring4d` | o smart pointer `Shared<TStringList>` |
| [Virtual TreeView](https://github.com/JAM-Software/Virtual-TreeView) | `jam.virtualtreeview` | o `TVirtualStringTree` no formulário |

**Requisitos:** [Smart Setup 3.5+](https://github.com/tmssoftware/smartsetup/releases),
Delphi 13 / RAD Studio 37.0 com Win32, e Git. Não são necessárias credenciais — as duas
dependências são open source.

---

## De onde você executa o `tms` faz diferença

O Smart Setup é baseado em pastas: a pasta de onde você executa o `tms` é o **workspace**, e é
nela que ele baixa, compila e controla os componentes.

- **Como desenvolvedor**, você executa o `tms` a partir do seu próprio workspace do Smart Setup —
  a pasta que contém todos os componentes instalados na sua IDE. Esse workspace pertence à sua
  *IDE*, não a um projeto específico, então todos os projetos em que você trabalha o compartilham.
  Ele não é a pasta onde o `tms.exe` está, nem este repositório: instalar um componente novo é
  sempre `tms install` a partir do workspace.
- **Em um agente de CI/CD**, você executa o `tms` a partir da raiz do repositório. O
  [tms.config.yaml](tms.config.yaml) versionado aqui transforma essa pasta em um workspace
  descartável (`__smartsetup/`, ignorado pelo git) e desliga o registro na IDE, de modo que o build
  nunca altera o estado da máquina.

Todo o resto abaixo decorre dessa separação.

---

## 1. Instalar as dependências (desenvolvedor)

A partir da pasta do seu workspace do Smart Setup — *não* deste repositório:

```
cd C:\seu-workspace-smartsetup
tms install sglienke.spring4d jam.virtualtreeview
```

O Smart Setup clona as duas bibliotecas, resolve suas dependências, compila os pacotes e registra
os de design-time na IDE. Agora abra [source/SampleProject.dproj](source/SampleProject.dproj): o
`TVirtualStringTree` está na paleta, o formulário abre no designer, o projeto compila. Nenhum
library path foi editado à mão.

Úteis: `tms list`, `tms list-remote`, `tms log-view`, [`tms doctor`](https://doc.tmssoftware.com/smartsetup/guide/doctor.html).

## 2. Salvar o snapshot (desenvolvedor)

Ainda a partir do seu workspace, gravando neste repositório com o caminho completo:

```
tms snapshot C:\caminho\para\econ2026\tms.snapshot.yaml
```

O [tms.snapshot.yaml](tms.snapshot.yaml) é versionado e registra as versões exatas — um hash de
commit do git para o Virtual TreeView e a release `2.0.2` para o Spring4D.

## 3. Restaurar em uma máquina nova ou em uma IDE nova (desenvolvedor)

O motivo de o snapshot estar no repositório. Em uma instalação nova do Delphi, a partir do seu
workspace:

```
cd C:\seu-workspace-smartsetup
tms restore C:\caminho\para\econ2026\tms.snapshot.yaml -auto-register
```

Mesmos componentes, mesmas versões, registrados e prontos. Use `-latest` para restaurar o mesmo
*conjunto* de produtos nas versões mais recentes, em vez das versões fixadas.

## 4. Compilar no CI/CD

Só aqui você executa o `tms` a partir da raiz do repositório:

```
cd C:\caminho\para\econ2026
tms restore tms.snapshot.yaml -skip-register
```

Um único comando: ele baixa as versões fixadas em `__smartsetup/`, compila essas dependências e em
seguida compila todo projeto do repositório que tenha um `tmsbuild.yaml` — inclusive a própria
aplicação. O executável é gerado em `source/Win32/Release/SampleProject.exe`. Nada é registrado em
nenhuma IDE.

Depois disso, use `tms build` para builds incrementais (`-full` para forçar um build completo).

Veja o [guia de integração contínua](https://doc.tmssoftware.com/smartsetup/guide/continuous-integration.html).

---

## Os arquivos que fazem isso funcionar

| Arquivo | Papel |
|---|---|
| [tms.config.yaml](tms.config.yaml) | **Só para CI.** Define `working folder: __smartsetup`, `skip register: true` e fixa o build em `delphi13` / `win32intel`, para que um agente mal configurado falhe de forma visível. Seu workspace de desenvolvimento usa a configuração dele, não esta. |
| [tms.snapshot.yaml](tms.snapshot.yaml) | As versões exatas das dependências. Versionado. |
| [source/tmsbuild.yaml](source/tmsbuild.yaml) | Declara a *própria* aplicação como um produto do Smart Setup: `SampleProject: [exe, vcl]` mais `dependencies: all.installed.components`, de modo que o Smart Setup compile o Spring4D e o Virtual TreeView antes de linkar o executável. Veja [creating bundles](https://doc.tmssoftware.com/smartsetup/guide/creating-bundles.html). |

O que *não* está no repositório: nenhum fonte de terceiros copiado, nenhum `.dcu`/`.bpl`, nenhum
library path absoluto no `.dproj`.

Usa outra versão do Delphi? Ajuste `delphi versions` e `platforms` no `tms.config.yaml`, e
`ide since:` no `source/tmsbuild.yaml`. Nada além disso.

---

## Roteiro da demonstração

O histórico foi construído um passo por vez e serve como roteiro de apresentação:

| Commit | Passo |
|---|---|
| `32be5e0` | `tms install sglienke.spring4d` → usar `Shared<T>` no formulário |
| `df1613b` | `tms install jam.virtualtreeview` → arrastar um `TVirtualStringTree` da paleta |
| `4d178ea` | `tms snapshot` → versionar as versões |
| `3673660` | Commitar a saída do `tms config` sem alterações, para que… |
| `f43f70f` | …`git show f43f70f -- tms.config.yaml` seja um diff limpo de seis configurações de CI, e não 210 linhas de boilerplate |

---

Documentação completa: [doc.tmssoftware.com/smartsetup](https://doc.tmssoftware.com/smartsetup) ·
`tms help <command>`
