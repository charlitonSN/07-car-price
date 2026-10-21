# Car Price: análise exploratória em SQL

Análise de 2.500 carros de sete marcas para entender o que influencia o preço: ano, quilometragem, motor, combustível, marca e condição. Todas as perguntas foram respondidas com SQL (SQLite).

O principal resultado é que nenhuma dessas variáveis explica o preço, e os padrões indicam que os dados foram gerados aleatoriamente. O relatório completo, com tabelas, gráficos e a discussão de cada resultado, está em [`relatorio.pdf`](relatorio.pdf).

## Perguntas respondidas

1. Quais são a média, a mediana e o desvio padrão do preço?
2. Como é a distribuição dos preços (histograma e boxplot)?
3. Qual é a proporção de carros por tipo de combustível e por condição?
4. Quantas marcas há e quais são as cinco mais comuns?
5. O ano de fabricação se relaciona com o preço? Como o tamanho dos motores mudou ao longo do tempo?
6. Como a condição do carro se relaciona com o preço médio?
7. Qual é a quilometragem média por condição, e quais marcas aparecem mais em cada uma?
8. Quantos carros de cada condição há em cada ano?
9. Como se combinam combustível, câmbio e condição?
10. O preço médio mudou ao longo do tempo dentro de cada condição?
11. As diferenças de preço entre condições são estatisticamente significativas (teste t)?

## Principais resultados

- O preço médio é de 52.638, com mediana de 53.485 e desvio padrão de 27.296.
- Os preços seguem uma distribuição uniforme entre 5 mil e 100 mil, com cerca de 10% dos carros em cada faixa de 10 mil. Não é o formato típico de preços de veículos.
- Preço não tem correlação com ano (r = −0,04), quilometragem (r = −0,01) nem tamanho do motor (r = 0,00).
- Carros novos são, em média, os mais baratos (51.905), e o teste t não encontra diferença significativa entre novos, seminovos e usados.
- Carros novos têm em média quase 150 mil de quilometragem, elétricos aparecem com motores de 1 a 6 litros e há Teslas movidos a diesel e a gasolina.
- Conclusão: a base não tem o sinal necessário para estudar o mercado de veículos nem para treinar um modelo de preço.

## Dados

- Fonte: [Car Price Prediction](https://www.kaggle.com/datasets/zafarali27/car-price-prediction), no Kaggle.
- 2.500 carros e 10 colunas, sem valores ausentes.
- A fonte não informa a origem dos dados nem a moeda dos preços.

## Como reproduzir

O banco `car-price.db` já está no repositório. Para gerá-lo do zero, baixe o CSV e rode o script:

```bash
kaggle datasets download -d zafarali27/car-price-prediction -p . --unzip
python gerar_banco.py
```

Depois, abra o banco em qualquer cliente SQLite e execute as consultas de [`car_price.sql`](car_price.sql), que seguem a ordem das perguntas.

## Arquivos

| Arquivo | Conteúdo |
|---|---|
| `car_price.sql` | Consultas SQL de todas as perguntas |
| `relatorio.pdf` | Relatório com os resultados e a interpretação |
| `car-price.db` | Banco SQLite com a tabela `car_price_prediction` |
| `gerar_banco.py` | Script que converte o CSV em banco SQLite |
| `perguntas.pdf` | Enunciado das perguntas de negócio |

## Ferramentas

SQLite, com funções de janela para mediana e quartis, correlação de Pearson e teste t de Welch calculados em SQL.

---

Charliton Nogueira · Projeto 07 do portfólio de análise de dados
