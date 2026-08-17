# Registro de ajustes

Este documento registra o estado inicial do projeto, os principais ajustes
tecnicos feitos durante o desenvolvimento e como cada um foi validado.

## Estado inicial

O projeto partiu do zero: nenhuma pipeline, banco ou dashboard existia antes
do desenvolvimento. A unica base de partida foi o dataset publico
[Air Quality](https://archive.ics.uci.edu/dataset/360/air+quality) e as
instrucoes do trabalho final do Modulo 6.

## Ajustes durante o desenvolvimento

### Remocao das linhas vazias do export do CSV

O arquivo `AirQualityUCI.csv` termina com 114 linhas totalmente vazias,
resultado do processo de exportacao original do dataset. A pipeline
`pl_01_ingestao_tratamento` inclui um `FilterRows` logo apos a leitura do CSV
para descartar essas linhas antes de qualquer tratamento, evitando que elas
gerem registros invalidos por um motivo que nao tem relacao com qualidade do
ar.

### Selecao de campos no SelectValues

A primeira versao da pipeline combinava, no mesmo `SelectValues`, uma lista de
selecao de campos e uma lista de remocao de campos ja implicitamente
excluidos pela selecao. O Hop rejeitou a combinacao porque, com
`select_unspecified = N`, os campos nao listados na selecao ja saem do fluxo
antes da etapa de remocao tentar remove-los novamente. O ajuste foi remover a
lista de remocao redundante e deixar a propria selecao decidir quais campos
seguem adiante.

### Formula para montar a data e hora

A funcao `CONCATENATE` do passo Formula usa a sintaxe do Excel, com virgula
separando os argumentos, e nao ponto e virgula. O ajuste foi trocar o
separador na expressao que combina as colunas de data e hora originais em um
unico texto, antes da conversao para o tipo Data.

### Gravacao da chave no Insert/Update

Na primeira versao, o campo `data_hora` aparecia apenas na clausula de chave
do `InsertUpdate`, e nao na lista de valores. Isso fazia com que a coluna
`data_hora` fosse gravada como nula na insercao de registros novos, violando a
restricao `NOT NULL`. O ajuste foi incluir `data_hora` tambem na lista de
valores (sem marcar para atualizacao, ja que e a propria chave).

### Faixas de classificacao de CO e NO2

A primeira versao das faixas classificava cerca de 38% das leituras como
CRITICO, o que tornava o indicador pouco informativo. As faixas foram
recalculadas a partir dos percentis reais do dataset (mediana, p75, p90 e p95
de cada poluente), de forma que a faixa CRITICO representasse
aproximadamente o decimo mais alto de cada poluente. Apos o ajuste, o
percentual de horas em condicao critica caiu para 13,11%, um valor mais util
para destacar os periodos realmente piores.

## Como cada ajuste foi validado

Cada ajuste foi validado executando a pipeline ou o workflow completo pela
linha de comando (`hop-run.sh`) contra o banco de dados real, conferindo o
log de execucao (sem erros, contagem de linhas esperada) e, quando aplicavel,
consultando o resultado diretamente no PostgreSQL. O historico completo dos
testes esta em [evidencias-testes.md](evidencias-testes.md).
