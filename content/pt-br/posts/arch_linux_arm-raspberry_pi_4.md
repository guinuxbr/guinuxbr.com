---
title: "Arch linux ARM no Raspberry Pi 4"
subtitle: "Mantendo as coisas simples :smiley:"
date: 2020-04-03T20:55:50-03:00
draft: false
tags: ["linux", "raspberrypi", "arm", "archlinux"]
categories: ["tutoriais"]
align: justify
---

Olá, bem-vindo ao meu blog!

Nesse artigo irei mostrar como rodar o Arch Linux ARM no Raspberry Pi 4.

Creio que todos já conhecem o Raspberry Pi, mas caso ainda não tenha ouvido falar sobre ele, [clique aqui](https://www.raspberrypi.org/).

Agora que já sabe do que se trata, vamos ao que interessa.
Vale ressaltar que boa parte desse guia se encontra nas instruções na página do próprio projeto, disponível [aqui](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4).

A primeira coisa a fazer é formatar o seu cartão MicroSD. Recomendo um bom cartão Classe 10 ou melhor.

A ferramenta para particionamento é de livre escolha. Utilizarei o _fdisk_ que está disponível por padrão na maioria das distribuições Linux.

1. Primeiro iniciamos o microSD com o fdisk. Você precisa utilizar _sudo_ ou realizar o processo como _root_.
    >fdisk /dev/sdX  

Substitua o "X" pelo identificador do seu MicroSD.

2. No primeiro prompt, apague (!!!) as partições e crie uma nova:

* Tecle **o** e **ENTER**. Isso vai limpar as partições atuais.

* Tecle **p** para listar as partições. Não deve haver nenhuma listada.

* Tecle **n** e **ENTER** para uma nova partição e **p** para escolher o tipo "Primária". Agora **1** para a primeira partição e **ENTER** para aceitar o valor padrão para o primeiro setor. Agora digite **+100M** para o último setor.

* Tecle **t** e então **c** para configurar a primeira partição com o tipo **W95 FAT32 (LBA)**

* Agora tecle **n** para uma nova partição e **p** novamente para "Primária". E então **2** para segunda partição no cartão e pressione **ENTER** duas vezes para aceitar os valores padrão para primeiro e último setores da segunda partição.

* Pressione **w** para escrever a tabela de partições e sair.

Dessa maneira você garante o restante do cartão para o sistema. Falaremos disso mais adiante.

3. Crie e monte o sistema de arquivos FAT que abrigará os arquivos de _boot_:
    >mkfs.vfat /dev/sdX1  
    >mkdir boot  
    >mount /dev/sdX1 boot

4. Crie e monte o sistema de arquivos EXT4 que abrigará o sistema:
    >mkfs.ext4 /dev/sdX2  
    >mkdir root  
    >mount /dev/sdX2 root

5. Baixe e extraia o sistema de arquivos raiz (root filesystem). Os parâmetros do comando _bsdtar_ são: **x** para extrair, **p** para restaurar as permissões e **f** indica o arquivo de entrada. O *C* após o arquivo de entrada indica o diretório para o qual deveremos mudar antes de extrair os arquivos, no caso caso, o diretório _root_ que criamos.  
Essa parte deve, obrigatoriamente, ser feita como usuário root:
    >wget <http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz>  
    >bsdtar -xpf ArchLinuxARM-rpi-4-latest.tar.gz -C root  
    >sync  

Aqui vai uma dica: a URL informada na documentação apresentou um erro no dia que tentei fazer o download. Fui direto para o mirror do Brasil e descobri que estava desatualizado, aproveitei e reportei no IRC #archlinux-arm. Consegui baixar a última versão recorrendo diretamente ao mirror dinamarquês. Uma lista de mirrors está disponível em: <https://archlinuxarm.org/about/mirrors>

6. Mova os arquivos de boot para a primeira partição:
    >mv root/boot/* boot

7. Desmonte as duas partições:
    >umount boot root

8. Insira o cartão no Raspberry Pi, conecte o cabo ethernet e a fonte de energia.

9. Caso não utilize o Raspberry Pi ligado diretamente a um vídeo, teclado e mouse, pode conectar via SSH. Verifique o IP atribuído pelo DHCP do seu roteador, por exemplo.
    * Logue-se com o usuário padrão _alarm_ e a senha _alarm_.
    * A senha padrão de root é _root_.

10. Por último, mas não menos importante: Inicialize o chaveiro do Pacman e popule com as chaves do Arch Linux ARM.
    >pacman-key \-\-init  
    >pacman-key \-\-populate archlinuxarm

Pronto, o Arch Linux ARM já está pronto para ser utilizado para o projeto que quiser. Recomendo atualizar o sistema e reiniciar para começar a brincadeira.

>pacman -Syu  
>systemctl reboot

Nos próximos posts falaremos mais sobre configurações e utilização do sistema. Até mais.
