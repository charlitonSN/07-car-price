 -- Banco completo de Car Price
 -- Tabela: car_price_prediction (2500 carros)
 -- Colunas com espaço no nome são escritas entre aspas duplas ("Engine Size", "Fuel Type")
 -- Condition: New (novo), Like New (seminovo), Used (usado)



-- Quais são as principais estatísticas descritivas do preço do carro (média, mediana, desvio padrão)?
WITH ordenado AS (
    SELECT
        Price AS preco,
        ROW_NUMBER() OVER (ORDER BY Price) AS posicao,
        COUNT(*) OVER () AS qtd

    FROM car_price_prediction
)

SELECT
    MAX(qtd) AS qtd_carros,
    ROUND(AVG(preco), 2) AS media_preco,
    ROUND(AVG(CASE WHEN posicao IN ((qtd + 1) / 2, (qtd + 2) / 2) THEN preco END), 2) AS mediana_preco,
    ROUND(
        SQRT((SUM(preco * preco) - COUNT(*) * AVG(preco) * AVG(preco)) / (COUNT(*) - 1)),
        2
    ) AS desvio_padrao_preco,
    MIN(preco) AS minimo_preco,
    MAX(preco) AS maximo_preco

FROM ordenado;



-- Trace um histograma e um boxplot para os preços dos carros e discorra sobre o observado.
-- Histograma: preço em faixas de 10.000
-- Verificar o gráfico no power bi
SELECT
    CAST(Price / 10000 AS INT) * 10000 AS faixa_preco,
    COUNT(*) AS qtd_carros,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM car_price_prediction), 2) AS percentual

FROM car_price_prediction

GROUP BY faixa_preco

ORDER BY faixa_preco;


-- Boxplot: mínimo, quartis e máximo do preço
-- Verificar o gráfico no power bi
WITH ordenado AS (
    SELECT
        Price AS preco,
        ROW_NUMBER() OVER (ORDER BY Price) AS posicao,
        COUNT(*) OVER () AS qtd

    FROM car_price_prediction
)

SELECT
    MIN(preco) AS minimo,
    MAX(CASE WHEN posicao = CAST(0.25 * qtd + 0.5 AS INT) THEN preco END) AS q1,
    ROUND(AVG(CASE WHEN posicao IN ((qtd + 1) / 2, (qtd + 2) / 2) THEN preco END), 2) AS mediana,
    MAX(CASE WHEN posicao = CAST(0.75 * qtd + 0.5 AS INT) THEN preco END) AS q3,
    MAX(preco) AS maximo

FROM ordenado;



-- Qual a proporção de carros para cada tipo de combustível e para cada condição?
SELECT
    "Fuel Type" AS tipo_combustivel,
    COUNT(*) AS qtd_carros,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM car_price_prediction), 2) AS percentual

FROM car_price_prediction

GROUP BY "Fuel Type"

ORDER BY qtd_carros DESC;


SELECT
    Condition AS condicao,
    COUNT(*) AS qtd_carros,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM car_price_prediction), 2) AS percentual

FROM car_price_prediction

GROUP BY Condition

ORDER BY qtd_carros DESC;



-- Quantas marcas o dataset possui e quais as 5 marcas mais comuns?
SELECT
    COUNT(DISTINCT Brand) AS qtd_marcas

FROM car_price_prediction;


SELECT
    Brand AS marca,
    COUNT(*) AS qtd_carros,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM car_price_prediction), 2) AS percentual

FROM car_price_prediction

GROUP BY Brand

ORDER BY qtd_carros DESC

LIMIT 5;



-- Existe relação entre o ano do carro e o preço (preço médio por ano)?
-- Como o tamanho dos motores mudou ao longo do tempo?
SELECT
    Year AS ano,
    COUNT(*) AS qtd_carros,
    ROUND(AVG(Price), 2) AS media_preco,
    ROUND(AVG("Engine Size"), 2) AS media_motor

FROM car_price_prediction

GROUP BY Year

ORDER BY Year;


-- Coeficiente de Pearson entre ano e preço, e entre ano e tamanho do motor
SELECT
    ROUND(
        (AVG(Year * Price) - AVG(Year) * AVG(Price))
        / (SQRT(AVG(Year * Year) - AVG(Year) * AVG(Year))
         * SQRT(AVG(Price * Price) - AVG(Price) * AVG(Price))),
        2
    ) AS correlacao_ano_preco,

    ROUND(
        (AVG(Year * "Engine Size") - AVG(Year) * AVG("Engine Size"))
        / (SQRT(AVG(Year * Year) - AVG(Year) * AVG(Year))
         * SQRT(AVG("Engine Size" * "Engine Size") - AVG("Engine Size") * AVG("Engine Size"))),
        2
    ) AS correlacao_ano_motor

FROM car_price_prediction;


-- Questão Bônus: distribuição do preço por ano (boxplot)
-- Verificar o gráfico no power bi
WITH ordenado AS (
    SELECT
        Year AS ano,
        Price AS preco,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Price) AS posicao,
        COUNT(*) OVER (PARTITION BY Year) AS qtd

    FROM car_price_prediction
)

SELECT
    ano,
    MAX(qtd) AS qtd_carros,
    MIN(preco) AS minimo,
    MAX(CASE WHEN posicao = CAST(0.25 * qtd + 0.5 AS INT) THEN preco END) AS q1,
    ROUND(AVG(CASE WHEN posicao IN ((qtd + 1) / 2, (qtd + 2) / 2) THEN preco END), 2) AS mediana,
    MAX(CASE WHEN posicao = CAST(0.75 * qtd + 0.5 AS INT) THEN preco END) AS q3,
    MAX(preco) AS maximo

FROM ordenado

GROUP BY ano

ORDER BY ano;



-- Como as condições do carro se relacionam com o preço médio?
SELECT
    Condition AS condicao,
    COUNT(*) AS qtd_carros,
    ROUND(AVG(Price), 2) AS media_preco,
    MIN(Price) AS minimo_preco,
    MAX(Price) AS maximo_preco

FROM car_price_prediction

GROUP BY Condition

ORDER BY media_preco DESC;



-- Qual a média de quilometragem por condição? Quais as marcas mais presentes em cada condição?
SELECT
    Condition AS condicao,
    COUNT(*) AS qtd_carros,
    ROUND(AVG(Mileage), 2) AS media_quilometragem

FROM car_price_prediction

GROUP BY Condition

ORDER BY media_quilometragem;


WITH contagem AS (
    SELECT
        Condition AS condicao,
        Brand AS marca,
        COUNT(*) AS qtd_carros,
        ROW_NUMBER() OVER (PARTITION BY Condition ORDER BY COUNT(*) DESC) AS ranking

    FROM car_price_prediction

    GROUP BY
        Condition,
        Brand
)

SELECT
    condicao,
    ranking,
    marca,
    qtd_carros

FROM contagem

WHERE ranking <= 3

ORDER BY
    condicao,
    ranking;



-- Crie um gráfico empilhado, ano a ano, com a quantidade de carros por condição.
-- Verificar o gráfico no power bi
SELECT
    Year AS ano,
    SUM(CASE WHEN Condition = 'New' THEN 1 ELSE 0 END) AS qtd_new,
    SUM(CASE WHEN Condition = 'Like New' THEN 1 ELSE 0 END) AS qtd_like_new,
    SUM(CASE WHEN Condition = 'Used' THEN 1 ELSE 0 END) AS qtd_used,
    COUNT(*) AS qtd_carros

FROM car_price_prediction

GROUP BY Year

ORDER BY Year;



-- Crie um treemap para visualizar tipos de combustível e câmbio por condição.
-- Verificar o gráfico no power bi
SELECT
    Condition AS condicao,
    "Fuel Type" AS tipo_combustivel,
    Transmission AS cambio,
    COUNT(*) AS qtd_carros,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM car_price_prediction), 2) AS percentual

FROM car_price_prediction

GROUP BY
    Condition,
    "Fuel Type",
    Transmission

ORDER BY
    condicao,
    qtd_carros DESC;



-- Houve mudança nos valores médios dos carros ao longo do tempo por condição?
SELECT
    Year AS ano,
    ROUND(AVG(CASE WHEN Condition = 'New' THEN Price END), 2) AS media_preco_new,
    ROUND(AVG(CASE WHEN Condition = 'Like New' THEN Price END), 2) AS media_preco_like_new,
    ROUND(AVG(CASE WHEN Condition = 'Used' THEN Price END), 2) AS media_preco_used

FROM car_price_prediction

GROUP BY Year

ORDER BY Year;



-- Questão Bônus: teste de hipóteses para validar se a diferença de preços por condição é significativa.
-- Teste t de Welch entre cada par de condições | H0: médias iguais | H1: médias diferentes
-- Com amostras grandes, |t| > 1,96 rejeita H0 a 5% de significância
WITH estatisticas AS (
    SELECT
        Condition AS condicao,
        COUNT(*) AS qtd,
        AVG(Price) AS media,
        (SUM(Price * Price) - COUNT(*) * AVG(Price) * AVG(Price)) / (COUNT(*) - 1) AS variancia

    FROM car_price_prediction

    GROUP BY Condition
)

SELECT
    a.condicao AS condicao_a,
    b.condicao AS condicao_b,
    ROUND(a.media, 2) AS media_preco_a,
    ROUND(b.media, 2) AS media_preco_b,
    ROUND((a.media - b.media) / SQRT(a.variancia / a.qtd + b.variancia / b.qtd), 2) AS estatistica_t,
    CASE
        WHEN ABS((a.media - b.media) / SQRT(a.variancia / a.qtd + b.variancia / b.qtd)) > 1.96
            THEN 'Diferença significativa'
        ELSE 'Sem diferença significativa'
    END AS conclusao

FROM estatisticas a, estatisticas b

WHERE a.condicao < b.condicao;
