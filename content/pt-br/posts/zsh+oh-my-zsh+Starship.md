---
title: "Instalando Zsh + Oh-My-Zsh + Starship"
subtitle: "Melhorando a produtividade"
date: 2020-05-08T23:10:26-03:00
draft: false
tags: ["linux","shell", "bash", "zsh"]
categories: ["tutoriais"]
align: justify
---

Olá, seja bem-vindo ao meu blog!

O objetivo deste artigo é compartilhar minha configuração de shell com você.
Penso que o meu trabalho e as tarefas do dia a dia se tornaram mais fáceis e produtivas comparando com o _bash_ "normal". Espero que seja útil para você.

Você precisará das seguintes ferramentas:

[Zsh](http://zsh.sourceforge.net/) - O shell Z.
[Oh-My-Zsh](https://ohmyz.sh/) - Um framework para gerenciar sua configuração do Zsh.
[Starship](https://starship.rs/) - Um prompt rápido e personalizável para qualquer shell que funciona muito bem com o Zsh!

Parto do princípio que você já tem o _git_ instalado e sabe utilizá-lo para clonar repositórios.

## Instalando o Zsh

Primeiro, você precisa instalar o Zsh. Você pode usar o gerenciador de pacotes da sua distribuição para instalá-lo facilmente.

Para o openSUSE:
>sudo zypper install zsh

Para o Ubuntu:
>sudo apt install zsh

Para o Fedora:
>sudo dnf install zsh

Depois disso, você deve definir o Zsh como seu shell padrão:

>chsh -s $(which zsh)

Agora reinicie sua máquina.

## Instalação do Oh-My-Zsh

Após a reinicialização, abra o seu terminal e você deverá se deparar com um assistente de configuração do Zsh. Neste momento, você pode digitar **q** e **ENTER** porque você vai instalar e configurar o Oh-My-Zsh e ele já traz um modelo do arquivo _.zshrc_ pronto:

* O programa curl ou o wget devem estar instalados.
* O git deve estar instalado.

> sh -c "$ (wget -O- <https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh>)"

Se o Oh-My-Zsh foi instalado com sucesso, você verá que seu prompt muda para verde. O arquivo de configuração do modelo é _~/.zshrc_ que oferece inúmeras possibilidades para configurar o comportamento do seu shell, como temas para o prompt e plugins.

## Carregando alguns plugins

Existem muitas configurações que podem ser feitas no Zsh + Oh-My-Zsh, aqui vou falar sobre uma lista de plugins legais que eu uso, mas você pode se aprofundar para descobrir mais possibilidades.
Os plugins devem ser colocados na sessão ```plugins = (...)``` do arquivo de configuração. Segue uma lista pessoal:  

| nome do plugin | breve descrição |
| :------------------ | :----------------- |
| colored-man-pages | adiciona cores às páginas de manual |
| command-not-found | usa o pacote command-not-found para o Zsh apresentar pacotes sugeridos |
| docker | adiciona "tab-completion" para Docker |
| git | fornece aliases e algumas funções úteis |
| npm | fornece "tab-completion" e muitos aliases úteis |
| pep8 | adiciona "tab-completion" para o comando pep8 |
| pip | adiciona "tab-completion" para o comando pip |
| pyenv | carrega pyenv e pyenv-virtualenv |
| python | adiciona vários aliases para comandos python úteis |
| sudo | prefixa o comando atual com _sudo_ pressionando **esc** duas vezes |
| systemd | fornece aliases úteis para systemd |
| ubuntu | adiciona "tab-completion" e aliases para o Ubuntu |
| zsh-reload | basta digitar _src_ para recarregar a sessão do Zsh |
| zsh-autosuggestions | sugere comandos enquanto você digita com base no histórico e nos "tab-completions" |
| zsh-syntax-highlighting | fornece destaque de sintaxe |

Você pode acessar <https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins> para ver uma lista completa dos plugins e suas respectivas documentações.

Os dois últimos plugins da minha lista não fazem parte da instalação padrão do Oh-My-Zsh e devem ser instalados separadamente. Talvez seja possível instalá-los com o gerenciador de pacotes da sua distribuição, mas eu prefiro instalar via Github para tirar proveito de possíveis novos recursos.

Como você está usando Oh-My-Zsh como um gerenciador de plug-ins, e os plug-ins já estão ativados em nosso arquivo _.zshrc_, tudo o que você precisa fazer é clonar o repositório do projeto direto no diretório _$ZSH_CUSTOM_.

Basta digitar o seguinte comando para _zsh-autosuggestions_:
>git clone <https://github.com/zsh-users/zsh-autosuggestions> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

E o seguinte para zsh-syntax-highlighting:
>git clone <https://github.com/zsh-users/zsh-syntax-highlighting.git> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

## Instalando uma fonte melhor

Para obter um melhor suporte para ícones e símbolos, você deve instalar uma fonte moderna como a Nerd Fonts. Eu uso Meslo, mas você pode escolher a sua e testar.

[Fonte Meslo Nerd](<https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip>)

Agora você precisa configurar o emulador de terminal para usar a fonte Meslo Nerd.

## Tema do prompt, o Starship

Para concluir a tarefa, o último passo é instalar o Starship, que trará muitas melhorias para o nosso shell Zsh.
A instalação é muito simples, basta digitar:

* o pacote curl deve estar instalado.

> curl -fsSL <https://starship.rs/install.sh> | zsh

Uma vez instalado, você precisa habilitá-lo. Basta colocar a seguinte linha no final _~/.zshrc_
> eval "$ (starship init zsh)"

É uma boa ideia comentar a linha _ZSH_THEME_ no _~/.zshrc_

## Configurando Starship

A configuração do Starship é de fácil entendimento. Primeiro, você precisa criar o arquivo de _starship.toml_. Ele deve ser colocado em _~/.config_:
>mkdir -p ~/.config && touch ~/.config/starship.toml

Depois disso, você deve preencher o arquivo com as opções que deseja alterar a configuração padrão. A propósito, a configuração padrão é bem legal! Como a configuração é um arquivo _.toml_, todas as opções são do tipo _chave : valor_.

As informações detalhadas sobre cada opção estão bem descritas na [documentação oficial](https://starship.rs/config/). Vou deixar aqui o que estou usando para servir como referência para você.  

```toml
add_newline = true

prompt_order = [
    "username",
    "memory_usage",
    "hostname",
    "kubernetes",
    "directory",
    "git_branch",
    "git_commit",
    "git_state",
    "git_status",
    "hg_branch",
    "package",
    "dotnet",
    "elixir",
    "elm",
    "golang",
    "haskell",
    "java",
    "nodejs",
    "php",
    "python",
    "ruby",
    "rust",
    "terraform",
    "nix_shell",
    "conda",
    "aws",
    "env_var",
    "crystal",
    "line_break",
    "battery",
    "cmd_duration",
    "jobs",
    "time",
    "character",
]

[battery]
full_symbol = "🔋"
charging_symbol = "⚡️"
discharging_symbol = "💀"

[[battery.display]]
threshold = 10
style = "bold red"

[[battery.display]]
threshold = 60
style = "bold yellow"

[[battery.display]]
threshold = 100
style = "bold green"

[character]
# symbol = "➜"
error_symbol = "✗"
use_symbol_for_status = true

[cmd_duration]
min_time = 500
prefix = "tooks "

[directory]
truncation_length = 6
truncate_to_repo = true
prefix = "in "
style = "bold cyan"
disabled = false

# [env_var]
# variable = "SHELL"
# default = "Zsh"
# prefix = "<"
# suffix = ">"

[git_branch]
# symbol = "🌱 "
truncation_length = 8
truncation_symbol = "..."
style = "bold purple"
disabled = false

[git_state]
cherry_pick = "CHERRY PICKING"
rebase = "REBASING"
merge = "MERGING"
revert = "REVERTING"
bisect = "BISECTING"
am = "AM"
am_or_rebase = "AM/REBASE"
progress_divider = " of "
style = "bold yellow"
disabled = false

# [git_status]
# conflicted = "🏳"
# ahead = "🏎💨"
# behind = "😰"
# diverged = "😵"
# untracked = "🤷‍"
# stashed = "📦"
# modified = "📝"
# staged.value = "++"
# staged.style = "green"
# staged_count.enabled = true
# staged_count.style = "green"
# renamed = "👅"
# deleted = "🗑"

# [[git_status.count]]
# enabled = true

[hostname]
ssh_only = false
prefix = "🤖"
# suffix = "⟫"
trim_at = "."
disabled = false

# [jobs]
# symbol = "+ "
# threshold = 1

[line_break]
disabled = false

# [memory_usage]
# disabled = false
# show_percentage = true
# show_swap = false
# threshold = -1
# symbol = " "
# separator = "/"
# style = "bold dimmed white"

[nodejs]
symbol = "⬢ "
style = "bold green"
disabled = false

# [package]
# symbol = "📦 "
# style = "bold red"
# disabled = false

[python]
symbol = "🐍 "
pyenv_version_name = false
pyenv_prefix = "pyenv"
style = "bold yellow"
disabled = false

# [time]
# format = "🕙%T"
# style_root = "bold red"
# style_user = "bold yellow"
# show_always = true
# disabled = false

[username]
style_root = "bold red"
style_user = "bold yellow"
show_always = false
disabled = false
```

Agora basta fechar seu terminal e abrir novamente para ver o resultado. Gostou?! :wink:

Espero que seja realmente útil para você e agradeço por ter lido!
