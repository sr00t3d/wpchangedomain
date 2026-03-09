# WP Change Domain

Readme: [EN](README.md)

![License](https://img.shields.io/github/license/sr00t3d/wordpress-wpchangedomain) ![Shell Script](https://img.shields.io/badge/shell-script-green)

<img src="wpchangedomain-cover.webp" width="700">

Este script em Shell Bash foi desenvolvido para automatizar o processo de alteração de domínio em instalações `WordPress`. Ele realiza a busca e substituição (`search and replace`) diretamente no banco de dados MySQL/MariaDB, garantindo que todas as referências ao domínio antigo sejam atualizadas para o novo.

## Descrição

Ao mover um site WordPress para um novo domínio, não basta apenas alterar os arquivos. É necessário atualizar diversas entradas no banco de dados, incluindo URLs de posts, links de imagens e configurações globais. Este script simplifica esse processo, executando comandos SQL de forma segura e rápida via terminal.

## Funcionalidades

- **Atualização de Opções**: Altera siteurl e home na tabela `wp_options`.
- **Busca e Substituição Global**: Atualiza URLs em posts, páginas, comentários e metadados.
- **Limpeza de Cache (Opcional)**: Ajuda a evitar conflitos após a migração.
- **Simplicidade**: Interface interativa via terminal que solicita os dados necessários.

## Pré-requisitos

Antes de utilizar o script, certifique-se de que o ambiente atenda aos seguintes requisitos:

- Sistema Operacional Linux/Unix.
- Acesso via terminal (SSH).
- Cliente MySQL/MariaDB instalado.
- **Backup atualizado do banco de dados** (obrigatório para segurança).

## Installation

### Hosted mode

1. **Download the file to the server:**

```bash
curl -O https://raw.githubusercontent.com/sr00t3d/plesk-checkdomain/refs/heads/main/wpchange_domain.sh
```

2. **Give execution permission:**

```bash
chmod +x wpchange_domain.sh
```

3. **Execute the script:**

```bash
./wpchange_domain.sh
```

### Direct mode

```bash
bash <(curl -fsSL 'https://raw.githubusercontent.com/sr00t3d/wpchangedomain/refs/heads/main/wpchange_domain.sh')
```

Example:

```bash
./wpchange_domain.sh 
[!] Starting...
[+] File wp-config.php was found.
[+] Database values found:
------------------------
| Database: sql_wpdomain_com
| User:     sql_wpdomain_com
| Host:     localhost
------------------------
[!] Checking the current domain...
[!] Trying to establish a connection, please wait...
[+] The actual database domain for: http://wpdomain.com (Prefix: wp_8b7fba_)
[!] Dumping database, please wait...
[+] Database dump created at: /www/wwwroot/wpdomain.com/backup_sql_wpdomain_com_20260228_001024.sql

Insert the NEW domain (e.g., domain.com.br): wpnewdomain.com

[!] This script will change wpdomain.com to wpnewdomain.com
Do you want to continue? (y/n): y

[!] Continuing...
[+] Changing database domain...

mysql: [Warning] Using a password on the command line interface can be insecure.

[+] All values were updated successfully.
```

## Utilização

```bash
./wpchange_domain.sh [-s|--skip] [-n|--noversion]
```

- `--noversion` Ignorar a verificação de versão na fonte remota.
- `--skip`      Ignorar a criação de backup do banco de dados.
- `--help`      Exibir mensagem de ajuda.

## Avisos Importantes

- **Backup**: **Nunca execute scripts que alteram o banco de dados sem ter um backup completo**. Se algo der errado, você poderá restaurar seu site.
- **Dados Serializados**: Note que substituições diretas via SQL podem corromper dados serializados do PHP (comuns em alguns plugins de construtores de páginas como Elementor). Após o script, recomenda-se revisar o site.
- **Permissões**: Certifique-se de executar o script com um usuário que tenha permissões de leitura/escrita no banco de dados.

## Aviso Legal

> [!WARNING]
> Este software é fornecido "tal como está". Certifique-se sempre de ter permissão explícita antes de executar. O autor não se responsabiliza por qualquer uso indevido, consequências legais ou impacto nos dados causados ​​por esta ferramenta.

## Detailed Tutorial

Para um guia completo, passo a passo, confira meu artigo completo:

👉 [**Change WordPress Domain in Shell**](https://perciocastelo.com.br/blog/change-wordpress-domain-in-shell.html)

## Licença

Este projeto está licenciado sob a **GNU General Public License v3.0**. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.