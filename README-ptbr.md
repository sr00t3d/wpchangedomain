# WP Change Domain 🚀

Readme: [English](README.md)

![License](https://img.shields.io/github/license/sr00t3d/wpchangedomain)
![Shell Script](https://img.shields.io/badge/shell-script-green)

<img src="wpchangedomain-cover.webp" width="700">

Este script em Shell Bash foi desenvolvido para automatizar o processo de alteração de domínio em instalações `WordPress`. Ele realiza a busca e substituição (`search and replace`) diretamente no banco de dados MySQL/MariaDB, garantindo que todas as referências ao domínio antigo sejam atualizadas para o novo.

## 📝 Descrição

Ao mover um site WordPress para um novo domínio, não basta apenas alterar os arquivos. É necessário atualizar diversas entradas no banco de dados, incluindo URLs de posts, links de imagens e configurações globais. Este script simplifica esse processo, executando comandos SQL de forma segura e rápida via terminal.

## ✨ Funcionalidades

- **Atualização de Opções**: Altera siteurl e home na tabela `wp_options`.
- **Busca e Substituição Global**: Atualiza URLs em posts, páginas, comentários e metadados.
- **Limpeza de Cache (Opcional)**: Ajuda a evitar conflitos após a migração.
- **Simplicidade**: Interface interativa via terminal que solicita os dados necessários.

## 📋 Pré-requisitos

Antes de utilizar o script, certifique-se de que o ambiente atenda aos seguintes requisitos:

- Sistema Operacional Linux/Unix.
- Acesso via terminal (SSH).
- Cliente MySQL/MariaDB instalado.
- **Backup atualizado do banco de dados** (obrigatório para segurança).

## 🚀 Instalação e Uso

1. Clone o repositorio:

```bash
git clone https://github.com/sr00t3d/wpchangedomain
cd wpchangedomain
chmod +x wpchangedomain.sh
```
2. Execute o script e siga as instruções na tela:

```bash
./wpchange_domain.sh
```

## Utilização

```bash
./wpchange_domain.sh [-s|--skip] [-n|--noversion]
```
- `--noversion`   Ignorar a verificação de versão na fonte remota
- `--skip`        Ignorar a criação de backup do banco de dados
- `--help`        Exibir mensagem de ajuda

## ⚠️ Avisos Importantes

- **Backup**: **Nunca execute scripts que alteram o banco de dados sem ter um backup completo**. Se algo der errado, você poderá restaurar seu site.
- **Dados Serializados**: Note que substituições diretas via SQL podem corromper dados serializados do PHP (comuns em alguns plugins de construtores de páginas como Elementor). Após o script, recomenda-se revisar o site.
- **Permissões**: Certifique-se de executar o script com um usuário que tenha permissões de leitura/escrita no banco de dados.

## ⚠️ Aviso Legal

> [!WARNING]
> Este software é fornecido "como está". Certifique-se sempre de testar primeiro em um ambiente de desenvolvimento. O autor não se responsabiliza por qualquer uso indevido, consequências legais ou impacto em dados causado por esta ferramenta.

## 📚 Tutorial Detalhado

Para um guia completo, passo a passo, confira meu artigo completo:

👉 [**Change WordPress Domain in Shell**](https://perciocastelo.com.br/blog/change-wordPress-domain-in-shell.html)

## Licença 📄

Este projeto está licenciado sob a **GNU General Public License v3.0**. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.
