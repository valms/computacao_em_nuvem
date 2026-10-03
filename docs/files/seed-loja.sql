-- Dados de exemplo para o Metabase: rede de lojas fictícia (Lab 04/10)
-- Executado pelo servico "seed" do docker-compose dentro do banco "loja".
DROP TABLE IF EXISTS vendas, produtos, lojas;

CREATE TABLE lojas (
  id      serial PRIMARY KEY,
  nome    text NOT NULL,
  cidade  text NOT NULL,
  uf      char(2) NOT NULL,
  regiao  text NOT NULL
);

CREATE TABLE produtos (
  id         serial PRIMARY KEY,
  nome       text NOT NULL,
  categoria  text NOT NULL,
  preco      numeric(10,2) NOT NULL
);

CREATE TABLE vendas (
  id          bigserial PRIMARY KEY,
  data_venda  date NOT NULL,
  loja_id     int NOT NULL REFERENCES lojas(id),
  produto_id  int NOT NULL REFERENCES produtos(id),
  quantidade  int NOT NULL,
  valor_total numeric(12,2) NOT NULL,
  canal       text NOT NULL
);

INSERT INTO lojas (nome, cidade, uf, regiao) VALUES
 ('Loja Aldeota','Fortaleza','CE','Nordeste'), ('Loja Centro','Fortaleza','CE','Nordeste'),
 ('Loja Boa Viagem','Recife','PE','Nordeste'), ('Loja Pituba','Salvador','BA','Nordeste'),
 ('Loja Ponta Negra','Natal','RN','Nordeste'), ('Loja Paulista','São Paulo','SP','Sudeste'),
 ('Loja Copacabana','Rio de Janeiro','RJ','Sudeste'), ('Loja Savassi','Belo Horizonte','MG','Sudeste'),
 ('Loja Asa Sul','Brasília','DF','Centro-Oeste'), ('Loja Moinhos','Porto Alegre','RS','Sul'),
 ('Loja Batel','Curitiba','PR','Sul'), ('Loja Umarizal','Belém','PA','Norte');

INSERT INTO produtos (nome, categoria, preco) VALUES
 ('Protetor solar FPS 50','Dermocosméticos',79.90), ('Hidratante facial','Dermocosméticos',59.90),
 ('Shampoo anticaspa','Higiene',32.50), ('Creme dental','Higiene',8.90),
 ('Escova dental','Higiene',12.90), ('Vitamina C 1g','Suplementos',29.90),
 ('Whey protein 900g','Suplementos',149.90), ('Ômega 3','Suplementos',54.90),
 ('Fralda infantil G','Infantil',89.90), ('Lenço umedecido','Infantil',14.90),
 ('Termômetro digital','Saúde',24.90), ('Medidor de pressão','Saúde',189.90),
 ('Álcool em gel','Higiene',9.90), ('Repelente','Saúde',27.90), ('Colágeno','Suplementos',99.90);

-- ~20 mil vendas espalhadas pelos últimos 12 meses
INSERT INTO vendas (data_venda, loja_id, produto_id, quantidade, valor_total, canal)
SELECT d, l, p, q, round((q * pr.preco * (0.9 + random()*0.2))::numeric, 2), c
FROM (
  SELECT (current_date - (random()*365)::int)                         AS d,
         1 + (random()*11)::int                                        AS l,
         1 + (random()*14)::int                                        AS p,
         1 + (random()*4)::int                                         AS q,
         (ARRAY['Loja física','App','Site','Televendas'])[1 + (random()*3)::int] AS c
  FROM generate_series(1, 20000)
) s JOIN produtos pr ON pr.id = s.p;

CREATE INDEX ON vendas (data_venda);
CREATE INDEX ON vendas (loja_id);

-- Usuário somente leitura para o Metabase consultar (boa prática: não usar o master)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'metabase_leitura') THEN
    CREATE ROLE metabase_leitura LOGIN;
  END IF;
END $$;
ALTER ROLE metabase_leitura PASSWORD :'leitura_pw';
GRANT CONNECT ON DATABASE loja TO metabase_leitura;
GRANT USAGE ON SCHEMA public TO metabase_leitura;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO metabase_leitura;

SELECT 'lojas' AS tabela, count(*) FROM lojas
UNION ALL SELECT 'produtos', count(*) FROM produtos
UNION ALL SELECT 'vendas', count(*) FROM vendas;
