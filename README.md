<div align="center">
  <h1>📂 Verificar Banco de Dados - Monitoramento do Tamanho dos Bancos de Dados das Lojas</h1>
  <img src="https://img.shields.io/badge/Ruby-2.7%2B-red" alt="Ruby Version">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License">
  <img src="https://img.shields.io/badge/Status-Finalizado-green" alt="Status">
</div>

<div>
  <h2>📝 Descrição</h2>
  <p>
    <strong>Verificar Banco de Dados</strong> é um projeto em Ruby que verifica o tamanho dos bancos de dados SQL Server das lojas, controlados por um banco de dados
    <code>SQLite</code> local e configurações armazenadas em <code>config.yml</code>. 
    O aplicativo se conecta a cada banco de dados das lojas, executa um comando específico do SQL Server para obter o espaço utilizado e, caso o tamanho seja maior que 
    <strong>8,5 GB</strong>, registra a loja e o tamanho do banco. Em seguida, envia um e-mail com as informações das lojas que excederam o limite definido.
  </p>
</div>

<div>
  <h2>🚀 Funcionalidades</h2>
  <ul>
    <li>🔗 <strong>Conexão com Bancos de Dados das Lojas</strong>: Conecta-se aos bancos de dados SQL Server de cada loja individualmente.</li>
    <li>📏 <strong>Verificação do Tamanho do Banco de Dados</strong>: Executa um comando SQL (<code>EXEC sp_spaceused</code>) para obter o tamanho atual do banco de dados.</li>
    <li>⚠️ <strong>Detecção de Excedentes</strong>: Verifica se o tamanho do banco de dados é maior que 8,5 GB.</li>
    <li>📝 <strong>Registro das Lojas</strong>: Salva as informações das lojas que excederam o limite definido.</li>
    <li>✉️ <strong>Envio de E-mails</strong>: Envia um e-mail com a lista das lojas e os respectivos tamanhos dos bancos de dados que excederam o limite.</li>
    <li>⏰ <strong>Verificação de Horário</strong>: O script só roda em dias úteis (de segunda a sexta) e entre as 18h e 19h, exceto em 25/12 e 1/1.</li>
  </ul>
</div>

<div>
  <h2>🛠️ Tecnologias Utilizadas</h2>
  <ul>
    <li><strong>Linguagem</strong>: <img src="https://img.shields.io/badge/-Ruby-red" alt="Ruby"> Ruby 2.7+</li>
    <li><strong>Banco de Dados</strong>: 
      <ul>
        <li>SQL Server (lojas)</li>
        <li>SQLite (armazenamento local)</li>
      </ul>
    </li>
    <li><strong>Gemas</strong>:
      <ul>
        <li><code>tiny_tds</code>: Conexão com bancos de dados SQL Server.</li>
        <li><code>sqlite3</code>: Conexão com o banco de dados SQLite.</li>
        <li><code>mail</code>: Envio de e-mails para notificações (ou <code>actionmailer</code>, dependendo de sua implementação).</li>
        <li><code>yaml</code>: Carregamento de arquivos de configuração.</li>
      </ul>
    </li>
  </ul>
</div>

<div>
  <h2>📋 Pré-requisitos</h2>
  <ul>
    <li>Ruby instalado na versão 2.7 ou superior.</li>
    <li>Acesso aos bancos de dados SQL Server das lojas.</li>
    <li>Configuração adequada do arquivo <code>config.yml</code> com as credenciais de acesso aos bancos de dados e configurações do aplicativo.</li>
    <li>Dependências instaladas listadas no <code>Gemfile</code>.</li>
  </ul>
</div>

<div>
  <h2>🔧 Instalação</h2>
  <ol>
    <li>
      <p><strong>Clone o repositório</strong>:</p>
      <pre><code>git clone https://github.com/JoaoVicttorsMelo/Verificar-Banco-de-Dados.git
cd Verificar-Banco-de-Dados
</code></pre>
    </li>
    <li>
      <p><strong>Instale as dependências</strong>:</p>
      <pre><code>bundle install</code></pre>
    </li>
    <li>
      <p><strong>Configure o arquivo <code>config.yml</code></strong>:</p>
      <p>Crie um arquivo <code>config.yml</code> na raiz do projeto com as seguintes informações (exemplo):</p>
      <pre><code>database:
  db: "/caminho/para/seu_banco_local.db"

database_server:
  username: 'usuario_sql_server'
  password: 'senha_sql_server'
  database:
    - 'nome_banco_padrao'
    - 'nome_banco_alternativo'  # Exemplo para a filial 102
  host: 'ip_ou_endereco_da_filial'
  port: 1433

offline:
  filial:
    - 999

sql:
  script: "SELECT ip, cod_filial, nome_filial FROM sua_tabela_sqlite"

email_settings:
  address: 'smtp.seuprovedor.com'
  port: 587
  domain: 'seudominio.com'
  user_name: 'seu_email'
  password: 'sua_senha'
  authentication: 'plain'
  enable_starttls_auto: true
  recipients:
    - 'destinatario1@dominio.com'
    - 'destinatario2@dominio.com'
</code></pre>
      <p>Certifique-se de substituir os valores pelas credenciais reais e adicionar todas as lojas que deseja monitorar no SQL Server e no banco de dados local (SQLite).</p>
    </li>
  </ol>
</div>

<div>
  <h2>🚀 Uso</h2>
  <ol>
    <li>
      <p><strong>Executando a Verificação de Bancos de Dados</strong>:</p>
      <p>Você pode executar o script principal para iniciar o processo de verificação:</p>
      <pre><code>ruby main.rb</code></pre>
      <p>Onde <code>main.rb</code> (ou o nome que você definiu) é o arquivo que inicia a aplicação.</p>
    </li>
    <li>
      <p><strong>Visualizando os Resultados</strong>:</p>
      <p>As lojas que possuem bancos de dados maiores que 8,5 GB serão registradas no log, e um e-mail será enviado com essas informações (caso haja configurações de envio de e-mail).</p>
    </li>
  </ol>
</div>

<div>
  <h2>🗂️ Estrutura do Projeto</h2>
  <pre><code>Verificar-Banco-de-Dados/
├── classes/
│   ├── services.rb        # Classe principal Services, que verifica os bancos
│   ├── logger_setup.rb    # Classe responsável pela configuração de logs
│   └── filial_ip.rb       # Modelo (exemplo) para manipular a tabela filiais_ip no SQLite
├── lib/
│   ├── enviar_email.rb    # Módulo para envio de e-mails
│   ├── util.rb            # Módulo com funções de utilidade (verifica horário, converte MB->GB, etc.)
│   └── conexao_banco.rb   # Módulo para gerenciar a conexão com o banco de dados
├── config.yml             # Arquivo de configuração
├── main.rb                # Script principal que inicia a aplicação
├── Gemfile                # Lista de gems necessárias para o projeto
└── README.md              # Este arquivo
</code></pre>
  <ul>
    <li><code>classes/</code>: Contém a lógica principal do projeto (classe <code>Services</code>, configuração de logs, etc.).</li>
    <li><code>lib/</code>: Módulos auxiliares (envio de e-mail, utilidades, conexões).</li>
    <li><code>config.yml</code>: Arquivo de configuração com as credenciais e configurações do aplicativo.</li>
    <li><code>main.rb</code>: Script principal que inicia o processo de verificação.</li>
    <li><code>Gemfile</code>: Lista de gemas necessárias para o projeto.</li>
    <li><code>README.md</code>: Documentação do projeto.</li>
  </ul>
</div>

<div>
  <h2>✨ Funcionalidades Detalhadas</h2>
  <h3>🔗 Conexão com Bancos de Dados das Lojas</h3>
  <p>
    O aplicativo se conecta a cada banco de dados das lojas usando as credenciais fornecidas no arquivo <code>config.yml</code>. Ele utiliza a gem <code>tiny_tds</code> para estabelecer a conexão com o SQL Server,
    e a gem <code>sqlite3</code> para se conectar ao banco local (armazenando informações de IPs, filiais etc.).
  </p>

  <h3>📏 Verificação do Tamanho do Banco de Dados</h3>
  <p>
    Executa um comando SQL específico para obter o tamanho atual do banco de dados. O comando utilizado é:
  </p>
  <pre><code>EXEC sp_spaceused</code></pre>
  <p>
    Este comando retorna o tamanho total do banco de dados em MB (ou KB, dependendo da versão/configuração do SQL Server). O valor retornado é convertido em Gigabytes pela função 
    <code>converter_string_mb_to_gb</code> do módulo <code>Util</code>.
  </p>

  <h3>⚠️ Detecção de Excedentes</h3>
  <p>
    O aplicativo verifica se o tamanho obtido é maior que <strong>8,5 GB</strong>. Caso seja, registra as informações da loja para notificação.
  </p>

  <h3>✉️ Envio de E-mails</h3>
  <p>
    O módulo <code>enviar_email.rb</code> envia um e-mail para os destinatários configurados com a lista das lojas que possuem bancos de dados maiores que o limite definido, incluindo o tamanho dos bancos de dados.
  </p>

  <h3>⏰ Verificação de Horário</h3>
  <p>
    A aplicação verifica se o dia e o horário atual são válidos para executar o processo. Por padrão:
    <ul>
      <li>O script não roda aos sábados e domingos.</li>
      <li>O script não roda em 25/12 (Natal) e 1/1 (Ano Novo).</li>
      <li>O script roda apenas entre 18h e 19h (horário permitido).</li>
    </ul>
  </p>
</div>

<div>
  <h2>⚙️ Configuração</h2>
  <h3>Arquivo <code>config.yml</code></h3>
  <p>
    Contém todas as configurações necessárias para a execução do aplicativo, incluindo credenciais de acesso aos bancos de dados (SQL Server) e as configurações de e-mail.
    Certifique-se de incluir todas as lojas que deseja monitorar, listando seus hosts e nomes de bancos de dados correspondentes, além de configurar a conexão SQLite adequadamente.
  </p>

  <h3>Módulos Personalizados</h3>
  <p>
    <ul>
      <li><strong><code>services.rb</code></strong>: Classe que gerencia a lógica de conexão e verificação do tamanho dos bancos de dados das lojas, bem como o envio de e-mail em caso de excedentes.</li>
      <li><strong><code>util.rb</code></strong>: Módulo com métodos utilitários (verificação de horário, conversão de MB para GB, etc.).</li>
      <li><strong><code>enviar_email.rb</code></strong>: Módulo responsável pelo envio de e-mails com as informações das lojas que excederam o limite.</li>
    </ul>
  </p>
</div>

<div>
  <h2>🤝 Contribuição</h2>
  <p>Contribuições são bem-vindas! Sinta-se à vontade para abrir <strong>issues</strong> e <strong>pull requests</strong>.</p>
  <ol>
    <li>Faça um <strong>fork</strong> do projeto.</li>
    <li>Crie uma nova branch: <code>git checkout -b feature/nova-funcionalidade</code>.</li>
    <li>Commit suas alterações: <code>git commit -m 'Adiciona nova funcionalidade'</code>.</li>
    <li>Faça um push para a branch: <code>git push origin feature/nova-funcionalidade</code>.</li>
    <li>Abra um <strong>pull request</strong>.</li>
  </ol>
</div>

<div>
  <h2>📄 Licença</h2>
  <p>Este projeto está sob a licença <a href="LICENSE">MIT</a>.</p>
</div>

<div>
  <h2>📞 Contato</h2>
  <p>✉️ Email:
    <a href="mailto:joaovicttorsilveiramelo@gmail.com">joaovicttorsilveiramelo@gmail.com</a>
  </p>
</div>
