CREATE DATABASE ex9
GO
USE ex9
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civilização Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marília Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matemática da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Lingüística Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciências da Computacão pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Política',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Física I',26,68.00,4,104),
(10005,'Geometria Analítica',1,95.00,3,105),
(10006,'Gramática Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Física III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')

-- QUESTIONARIO

--1) Consultar nome, valor unitário, nome da editora e nome do autor dos livros do estoque que foram vendidos.
--Não podem haver repetições.	
SELECT DISTINCT es.nome, es.valor AS valor_unitario, ed.nome AS nome_editora, a.nome AS nome_autor
FROM autor a, estoque es, editora ed, compra c
WHERE a.codigo = es.codAutor AND ed.codigo = es.codEditora AND c.codEstoque = es.codigo 

--2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051	
SELECT es.nome, c.qtdComprada, c.valor
FROM estoque es, compra c
WHERE c.codEstoque = es.codigo AND c.codigo = 15051

--3) Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site tenha mais de 10 dígitos, remover o www.).	
SELECT es.nome,
	CASE WHEN LEN(ed.site) > 10
	THEN 
		SUBSTRING(ed.site,5,35)
	ELSE
		ed.site
	END AS site_editora
FROM estoque es, editora ed
WHERE ed.codigo = es.codEditora AND ed.nome = 'Makron Books'

--4) Consultar nome do livro e Breve Biografia do David Halliday	
SELECT es.nome, a.biografia
FROM estoque es, autor a
WHERE a.codigo = es.codAutor AND a.nome = 'David Halliday'

--5) Consultar código de compra e quantidade comprada do livro Sistemas Operacionais Modernos
SELECT c.codigo, c.qtdComprada
FROM estoque es, compra c
WHERE es.codigo = c.codEstoque AND es.nome = 'Sistemas Operacionais Modernos'

-- 6) Consultar quais livros não foram vendidos
SELECT es.nome
FROM estoque es LEFT OUTER JOIN compra c ON es.codigo = c.codEstoque
WHERE c.codigo IS NULL

-- 7) Consultar quais livros foram vendidos e não estão cadastrados
SELECT es.nome
FROM estoque es RIGHT OUTER JOIN compra c ON es.codigo = c.codEstoque
WHERE es.codigo IS NULL

--8) Consultar Nome e site da editora que não tem Livros no estoque (Caso o site tenha mais de 10 dígitos, remover o www.)	
SELECT ed.nome,
	CASE WHEN LEN(ed.site) > 10
	THEN 
		SUBSTRING(ed.site,5,35)
	ELSE
		ed.site
	END AS site_editora
FROM editora ed LEFT OUTER JOIN estoque es ON es.codEditora = ed.codigo
WHERE es.codEditora IS NULL

-- 9) Consultar Nome e biografia do autor que não tem Livros no estoque (Caso a biografia inicie com Doutorado, substituir por Ph.D.)
SELECT a.nome,
	CASE WHEN a.biografia LIKE 'Doutorado%'
	THEN 
		'Ph.D.' + SUBSTRING(a.biografia,10,90)
	ELSE
		a.biografia
	END AS biografia
FROM autor a LEFT OUTER JOIN estoque es ON es.codAutor = a.codigo
WHERE es.codAutor IS NULL

-- 10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor descendente	
SELECT a.nome, MAX(es.valor) AS maior_valor_livro
FROM autor a, estoque es
WHERE a.codigo = es.codAutor
GROUP BY a.nome
ORDER BY maior_valor_livro DESC

-- 11) Consultar o código da compra, o total de livros comprados e a soma dos valores gastos. Ordenar por Código da Compra ascendente.
SELECT c.codigo, SUM(c.qtdComprada) AS total_livros, SUM(c.valor) AS soma_valores
FROM compra c, estoque es
WHERE c.codEstoque = es.codigo
GROUP BY c.codigo
ORDER BY c.codigo ASC

-- 12) Consultar o nome da editora e a média de preços dos livros em estoque. Ordenar pela Média de Valores ascendente.
SELECT ed.nome, CAST(AVG(es.valor) AS DECIMAL(5,2)) AS media_preco
FROM editora ed, estoque es
WHERE ed.codigo = es.codEditora
GROUP BY ed.nome
ORDER BY media_preco ASC

-- 13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da editora (Caso o site tenha mais de 10 dígitos, remover o www.), criar uma coluna status onde:	
--	Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
--	Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
--	Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
--	A Ordenação deve ser por Quantidade ascendente

SELECT  es.nome, es.quantidade, ed.nome AS nome_editora,
	CASE WHEN LEN(ed.site) > 10
	THEN 
		SUBSTRING(ed.site,5,35)
	ELSE
		ed.site
	END AS site_editora,
	CASE WHEN es.quantidade < 5
	THEN 
		'Produto em Ponto de Pedido'
	ELSE
		CASE WHEN es.quantidade <= 10
		THEN 
			'Produto Acabando'
		ELSE
			'Estoque Suficiente'
		END
	END AS status
FROM estoque es, editora ed
WHERE ed.codigo = es.codEditora
ORDER BY es.quantidade ASC

-- 14) Para montar um relatório, é necessário montar uma consulta com a seguinte saída: Código do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site) de todos os livros	
--	Só pode concatenar sites que não são nulos

SELECT es.codigo, es.nome, a.nome,
	CASE WHEN e.site IS NOT NULL
	THEN 
		e.nome + ' - ' + e.site
	ELSE
		e.nome
	END AS info_site
FROM estoque es, autor a, editora e
WHERE es.codAutor = a.codigo AND es.codEditora = e.codigo

-- 15) Consultar Codigo da compra, quantos dias da compra até hoje e quantos meses da compra até hoje

SELECT DISTINCT codigo, DATEDIFF(DAY, dataCompra, GETDATE()) AS dias_ate_hoje, 
DATEDIFF(MONTH, dataCompra, GETDATE()) AS meses_ate_hoje
FROM compra

--16) Consultar o código da compra e a soma dos valores gastos das compras que somam mais de 200.00
SELECT c.codigo,  SUM(c.valor) AS soma_valores
FROM compra c, estoque es
WHERE c.codEstoque = es.codigo
GROUP BY c.codigo
HAVING SUM(c.valor) > 200
