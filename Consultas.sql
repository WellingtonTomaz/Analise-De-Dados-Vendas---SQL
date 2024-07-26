--Consulta 01 Verificar a quantidade de registros das tabelas

SELECT COUNT(*) as Qtd, 'Categorias' as Tabela FROM categorias
UNION ALL
SELECT COUNT(*) as Qtd, 'Clientes' as Tabela FROM clientes
UNION ALL
SELECT COUNT(*) as Qtd, 'Fornecedores' as Tabela FROM fornecedores
UNION ALL
SELECT COUNT(*) as Qtd, 'ItensVenda' as Tabela FROM itens_venda
UNION ALL
SELECT COUNT(*) as Qtd, 'Marcas' as Tabela FROM marcas
UNION ALL
SELECT COUNT(*) as Qtd, 'Produtos' as Tabela FROM produtos
UNION ALL
SELECT COUNT(*) as Qtd, 'Vendas' as Tabela FROM vendas;

--Atuliazando dados dos produtos
UPDATE produtos
SET preco = CASE
    WHEN nome_produto = 'Chocolate' THEN 14
    WHEN nome_produto = 'Bola de Futebol' THEN 65
    WHEN nome_produto = 'Celular' THEN 2300
    WHEN nome_produto = 'Livro de Ficção' THEN 80
    WHEN nome_produto = 'Camisa' THEN 59
END
WHERE nome_produto IN ('Chocolate', 'Bola de Futebol', 'Celular', 'Livro de Ficção', 'Camisa');

-- Verificando os anos das vendas
SELECT DISTINCT(strftime('%Y', data_venda)) as ano FROM vendas
ORDER BY data_venda


--Quantidade de venda agrupado por ano e mes
SELECT strftime('%Y', data_venda) AS ano,strftime('%m', data_venda) as mes,COUNT(id_venda) as total_venda
FROM vendas
GROUP BY ano,mes
ORDER BY ano;
 
 
SELECT strftime('%Y', data_venda) AS ano,strftime('%m', data_venda) as mes,COUNT(id_venda) as total_venda
FROM vendas
WHERE mes= '01' OR mes = '11' or mes = '12'
GROUP BY ano,mes
ORDER BY ano;



--Analisando dados para vendas na black friday 

--Papel dos fornecedores na black friday 

SELECT strftime('%Y/%m', v.data_venda) AS 'Ano/Mes', f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
FROM itens_venda iv
JOIN vendas v ON v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id
WHERE strftime('%m', v.data_venda) = '11'
GROUP BY strftime('%Y/%m', v.data_venda), f.nome
ORDER BY f.nome;

--Quantidade de vendas dos produtos por categoria

SELECT strftime('%Y/%m', v.data_venda) AS 'Ano/Mes', c.nome_categoria AS Nome_Categoria, COUNT(iv.produto_id) AS Qtd_Vendas
FROM itens_venda iv
JOIN vendas v ON v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN categorias c ON c.id_categoria = p.categoria_id
WHERE strftime('%m', v.data_venda) = '11'
GROUP BY strftime('%Y/%m', v.data_venda), c.nome_categoria
ORDER BY Qtd_Vendas;

-- Comparação de vendas entre as distribuidoras (Grafico no Google Planilhas)

SELECT 
    AnoMes,
    SUM(CASE WHEN Nome_Fornecedor = 'NebulaNetworks' THEN Qtd_Vendas ELSE 0 END) AS Qtd_vendas_NebulaNetworks,
    SUM(CASE WHEN Nome_Fornecedor = 'HorizonDistributors' THEN Qtd_Vendas ELSE 0 END) AS Qtd_vendas_HorizonDistributors,
    SUM(CASE WHEN Nome_Fornecedor = 'AstroSupply' THEN Qtd_Vendas ELSE 0 END) AS Qtd_vendas_AstroSupply,
FROM (
    SELECT 
        strftime('%Y/%m', v.data_venda) AS AnoMes, 
        f.nome AS Nome_Fornecedor, 
        COUNT(iv.produto_id) AS Qtd_Vendas
    FROM 
        itens_venda iv
    JOIN 
        vendas v ON v.id_venda = iv.venda_id
    JOIN 
        produtos p ON p.id_produto = iv.produto_id
    JOIN 
        fornecedores f ON f.id_fornecedor = p.fornecedor_id
    WHERE 
        f.nome IN ('NebulaNetworks', 'HorizonDistributors', 'AstroSupply')
    GROUP BY 
        strftime('%Y/%m', v.data_venda), f.nome
) AS vendas_agrupadas
GROUP BY 
    AnoMes
ORDER BY 
    AnoMes;


--Porcentagem categorias 

SELECT nome_categoria, Qtd_Vendas, ROUND(100.0*Qtd_Vendas/(SELECT  COUNT(*) FROM itens_venda), 2) || '%' AS Porcentagem
FROM(
  SELECT c.nome_categoria AS Nome_Categoria, COUNT(iv.produto_id) AS Qtd_Vendas
  FROM itens_venda iv
  JOIN vendas v ON v.id_venda = iv.venda_id
  JOIN produtos p ON p.id_produto = iv.produto_id
  JOIN categorias c ON c.id_categoria = p.categoria_id
  GROUP BY c.nome_categoria
  ORDER BY Qtd_Vendas DESC);


--Porcentagem Fornecedores

SELECT nome_fornecedor, Qtd_Vendas, ROUND(100.0*Qtd_Vendas/(SELECT  COUNT(*) FROM itens_venda), 2) || '%' AS Porcentagem
FROM(
  SELECT f.nome AS Nome_Fornecedor, COUNT(iv.produto_id) AS Qtd_Vendas
  FROM itens_venda iv
  JOIN vendas v ON v.id_venda = iv.venda_id
  JOIN produtos p ON p.id_produto = iv.produto_id
  JOIN fornecedores f ON f.id_fornecedor = p.fornecedor_id
  GROUP BY f.nome
  ORDER BY Qtd_Vendas DESC);
  
--Porcentagem Marcas  
  
  SELECT Nome_Marca, Qtd_Vendas, ROUND(100.0*Qtd_Vendas/(SELECT  COUNT(*) FROM itens_venda), 2) || '%' AS Porcentagem
FROM(
  SELECT m.nome AS Nome_Marca, COUNT(iv.produto_id) AS Qtd_Vendas
  FROM itens_venda iv
  JOIN vendas v ON v.id_venda = iv.venda_id
  JOIN produtos p ON p.id_produto = iv.produto_id
  JOIN marcas m ON m.id_marca = p.marca_id
  GROUP BY m.nome
  ORDER BY Qtd_Vendas DESC);
  
-- Quadro geral de vendas

SELECT mes,
			SUM(case WHEN ano = '2020' THEN qtd_vendas ELSE 0 END) AS '2020',
            SUM(case WHEN ano = '2021' THEN qtd_vendas ELSE 0 END) AS '2021',
            SUM(case WHEN ano = '2022' THEN qtd_vendas ELSE 0 END) AS '2022',
            SUM(case WHEN ano = '2023' THEN qtd_vendas ELSE 0 END) AS '2023'

FROM ( SELECT strftime('%m', data_venda) as mes, strftime('%Y', data_venda) as ano, COUNT(*) as qtd_vendas
	FROM vendas
    GROUP BY ano,mes
    order by ano,mes)
GROUP by mes;


--Metrica 

-- Media de vendas Black Friday anteriores

SELECT AVG(qtd_vendas) as media_vendas
from(
  SELECT count(*) as qtd_vendas, strftime('%Y', data_venda) AS ano 
  from vendas v
  WHERE strftime('%m', data_venda) = '11'and strftime('%Y', data_venda) != '2022'
  GROUP by ano)
  
  
-- Vendas Black friday atual  
  
  SELECT qtd_vendas as qtd_vendas_atual
from(  
    SELECT count(*) as qtd_vendas, strftime('%Y', data_venda) AS ano 
    from vendas v
    WHERE strftime('%m', data_venda) = '11'and strftime('%Y', data_venda) = '2022'
    GROUP by ano  
);


--Comparação das vendas anteriores com a atual

WITH media_vendas_anteriores AS (
    SELECT AVG(qtd_vendas) AS media_vendas
    FROM (
        SELECT COUNT(*) AS qtd_vendas, strftime('%Y', data_venda) AS ano
        FROM vendas
        WHERE strftime('%m', data_venda) = '11' AND strftime('%Y', data_venda) != '2022'
        GROUP BY ano
    )
), 
vendas_atual AS (
    SELECT COUNT(*) AS qtd_vendas_atual
    FROM vendas
    WHERE strftime('%m', data_venda) = '11' AND strftime('%Y', data_venda) = '2022'
    GROUP BY strftime('%Y', data_venda)
)
SELECT mv.media_vendas, va.qtd_vendas_atual,
       ROUND((va.qtd_vendas_atual - mv.media_vendas) / mv.media_vendas * 100.0, 2) || '%' AS porcentagem
FROM media_vendas_anteriores mv, vendas_atual va;




--Vendas de 2022

SELECT COUNT(iv.produto_id) AS Qtd_Produtos_Vendidos
FROM vendas v
JOIN itens_venda iv ON v.id_venda = iv.venda_id
WHERE strftime('%Y', v.data_venda) = '2022';

--Categoria mais vendida em 2022

SELECT COUNT(*) as Qtd_Vendas, c.nome_categoria as Categoria 
from itens_venda iv
join vendas v ON v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN categorias c on c.id_categoria = p.categoria_id
where strftime('%Y', v.data_venda) = '2022'
GROUP by Categoria
order by COUNT(*) DESC
limit 1;

--Fornecedor com mais vendas em 2022

SELECT COUNT(*) as Qtd_Vendas, f.nome as Fornecedores 
from itens_venda iv
join vendas v ON v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN fornecedores f on f.id_fornecedor = p.categoria_id
where strftime('%Y', v.data_venda) = '2022'
GROUP by Fornecedores
order by COUNT(*) DESC
limit 1;

--Duas categorias com mais vendas em todo o periodo 

SELECT COUNT(*) as Qtd_Vendas, c.nome_categoria as Categoria 
from itens_venda iv
join vendas v ON v.id_venda = iv.venda_id
JOIN produtos p ON p.id_produto = iv.produto_id
JOIN categorias c on c.id_categoria = p.categoria_id
GROUP by Categoria
order by COUNT(*) DESC
limit 2;


--Porcentagem de vendas por categoria 2022

WITH Total_Vendas AS (
SELECT COUNT(*) as Total_Vendas_2022
From itens_venda iv
JOIN vendas v ON v.id_venda = iv.venda_id
WHERE strftime('%Y', v.data_venda) = '2022'
)
SELECT Nome_Categoria, Qtd_Vendas, ROUND(100.0*Qtd_Vendas/tv.Total_Vendas_2022, 2) || '%' AS Porcentagem
FROM(
  SELECT c.nome_categoria AS Nome_Categoria, COUNT(iv.produto_id) AS Qtd_Vendas
  from itens_venda iv
  JOIN vendas v ON v.id_venda = iv.venda_id
  JOIN produtos p ON p.id_produto = iv.produto_id
  JOIN categorias c ON c.id_categoria = p.categoria_id
  WHERE strftime('%Y', v.data_venda) = '2022'
  GROUP BY Nome_Categoria
  ORDER BY Qtd_Vendas DESC
  ), Total_Vendas tv
  
