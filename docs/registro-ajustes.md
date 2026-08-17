# Registro de ajustes

Este documento registra o estado inicial do projeto, os principais ajustes
técnicos feitos durante o desenvolvimento e como cada um foi validado.

## Estado inicial

O projeto partiu do zero: nenhuma pipeline, banco ou dashboard existia antes
do desenvolvimento. A única base de partida foi o dataset público
[Air Quality](https://archive.ics.uci.edu/dataset/360/air+quality) e as
instruções do trabalho final do Módulo 6.

## Ajustes durante o desenvolvimento

### Remocao das linhas vazias do export do CSV

O arquivo `AirQualityUCI.csv` termina com 114 linhas totalmente vazias,
resultado do processo de exportação original do dataset. A pipeline
`pl_01_ingestion_treatment` inclui um `FilterRows` logo após a leitura do CSV
para descartar essas linhas antes de qualquer tratamento, evitando que elas
gerem registros invalidos por um motivo que não tem relacao com qualidade do
ar.

### Seleção de campos no SelectValues

A primeira versão da pipeline combinava, no mesmo `SelectValues`, uma lista de
seleção de campos e uma lista de remocao de campos já implicitamente
excluidos pela seleção. O Hop rejeitou a combinacao porque, com
`select_unspecified = N`, os campos não listados na seleção já saem do fluxo
antes da etapa de remocao tentar remove-los novamente. O ajuste foi remover a
lista de remocao redundante e deixar a própria seleção decidir quais campos
seguem adiante.

### Formula para montar a data e hora

A função `CONCATENATE` do passo Formula usa a sintaxe do Excel, com virgula
separando os argumentos, e não ponto e virgula. O ajuste foi trocar o
separador na expressao que combina as colunas de data e hora originais em um
único texto, antes da conversão para o tipo Data.

### Gravacao da chave no Insert/Update

Na primeira versão, o campo `data_hora` aparecia apenas na clausula de chave
do `InsertUpdate`, e não na lista de valores. Isso fazia com que a coluna
`data_hora` fosse gravada como nula na insercao de registros novos, violando a
restrição `NOT NULL`. O ajuste foi incluir `data_hora` também na lista de
valores (sem marcar para atualização, já que e a própria chave).

### Faixas de classificação de CO e NO2

A primeira versão das faixas classificava cerca de 38% das leituras como
CRÍTICO, o que tornava o indicador pouco informativo. As faixas foram
recalculadas a partir dos percentis reais do dataset (mediana, p75, p90 e p95
de cada poluente), de forma que a faixa CRÍTICO representasse
aproximadamente o décimo mais alto de cada poluente. Após o ajuste, o
percentual de horas em condição crítica caiu para 13,11%, um valor mais util
para destacar os períodos realmente piores.

## Como cada ajuste foi validado

Cada ajuste foi validado executando a pipeline ou o workflow completo pela
linha de comando (`hop-run.sh`) contra o banco de dados real, conferindo o
log de execução (sem erros, contagem de linhas esperada) e, quando aplicavel,
consultando o resultado diretamente no PostgreSQL. O histórico completo dos
testes está em [evidencias-testes.md](evidencias-testes.md).
