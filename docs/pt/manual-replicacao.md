# Manual de replicação

Este manual descreve, passo a passo, como reproduzir o projeto AeroTrack do
zero em uma máquina limpa: banco de dados, pipelines, workflow e dashboard.
Também está reproduzido no relatório de desenvolvimento
(`docs/evidencias/relatorio-desenvolvimento-aerotrack.pdf`).

## 1. Pré-requisitos

| Ferramenta | Versão mínima | Uso |
| --- | --- | --- |
| Docker Engine | 24 | Executar o PostgreSQL local |
| Docker Compose | 2.20 | Orquestrar o container do banco |
| Java (JDK) | 21 | Executar o Apache Hop |
| Apache Hop | 2.18 | Executar as pipelines e o workflow |
| Python | 3.10 | Exportar os indicadores para o dashboard |
| Navegador atual | — | Visualizar o dashboard |

O Apache Hop pode ser baixado em <https://hop.apache.org/download/>. Após
extrair, adicione a pasta `hop/` do Hop ao `PATH` ou anote o caminho completo
para `hop-run.sh` e `hop-conf.sh`, usados abaixo.

## 2. Clonar o repositório

```bash
git clone https://github.com/JulianaBallin/AeroTrack.git
cd AeroTrack
```

## 3. Subir o banco de dados

```bash
cd database
docker compose up -d
docker compose ps
```

Aguarde o container `aerotrack-hop-postgres` ficar com status `healthy`. O
script `database/init_aerotrack.sql` cria automaticamente as tabelas e as
visões na primeira subida.

## 4. Registrar o projeto no Apache Hop

Esse passo só precisa ser feito uma vez por máquina:

```bash
cd ..
hop-conf.sh -pc -p aerotrack -ph "$(pwd)/hop" -pf project-config.json -pkf \
  -ps "AeroTrack - trabalho final Módulo 6 Apache Hop"
```

Confirme que o projeto foi registrado:

```bash
hop-conf.sh -pl
```

## 5. Executar o processo completo

```bash
hop-run.sh -j aerotrack -f hop/workflows/wf_air_quality_orchestration.hwf -r local -l Basic
```

O workflow executa `pl_01_ingestion_treatment` (ingestão, tratamento e carga)
e, em caso de sucesso, `pl_02_indicator_consolidation` (indicadores diários e
mensais). Uma execução completa leva poucos segundos e processa as 9357
leituras do dataset.

## 6. Conferir os dados carregados (opcional)

```bash
docker exec aerotrack-hop-postgres psql -U aerotrack -d aerotrack -c \
  "SELECT count(*) FROM leituras_qualidade_ar;"
```

O valor esperado é 8131 leituras válidas. Reexecutar o passo 5 não altera essa
contagem, pois a carga usa Insert/Update pela chave `data_hora`.

## 7. Gerar e abrir o dashboard

```bash
scripts/export_dashboard.sh
cd dashboard
python3 -m http.server 8000
```

Acesse `http://localhost:8000` no navegador.

## 8. Script único de replicação

Os passos 3, 5 e 7 estão automatizados em um único script:

```bash
scripts/replicate.sh
```

O script verifica os pré-requisitos, sobe o banco, registra o projeto no Hop
se necessário, executa o workflow e exporta o dashboard, imprimindo o
progresso de cada etapa.

## 9. Compilar o relatório em PDF (opcional)

Requer uma distribuição LaTeX com `pdflatex` (por exemplo, TeX Live):

```bash
cd docs/evidencias
pdflatex -interaction=nonstopmode relatorio-desenvolvimento-aerotrack.tex
pdflatex -interaction=nonstopmode relatorio-desenvolvimento-aerotrack.tex
```

Rodar duas vezes garante que o sumário e as referências de página fiquem
corretos.

## 10. Solução de problemas

| Sintoma | Causa provável | Solução |
| --- | --- | --- |
| `hop-run.sh` não encontra o projeto `aerotrack` | Projeto não registrado nesta máquina | Repita o passo 4 |
| Erro de conexão com o PostgreSQL | Container ainda não está saudável | Aguarde `docker compose ps` mostrar `healthy` |
| Porta 5434 ocupada | Outro serviço já usa a porta | Ajuste a porta em `database/docker-compose.yml` e em `hop/metadata/rdbms/PostgreSQL_AeroTrack.json` |
| `dashboard/data/indicadores.json` vazio ou desatualizado | Dashboard exportado antes do workflow terminar | Execute o passo 5 e só depois o passo 7 |
| Página do dashboard em branco no navegador | Aberta diretamente como arquivo (`file://`) | Sirva a pasta com `python3 -m http.server`, como no passo 7 |
