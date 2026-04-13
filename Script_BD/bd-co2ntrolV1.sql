CREATE DATABASE co2ntrol;
USE co2ntrol;

-- Tabela de Usuario, aqui seria a Empresa, referente a qual empresa que está usando o sistema por exemplo, os auto-relacionamento está referindo a matriz, como se fosse filiais...
CREATE TABLE usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100),
    senha VARCHAR(200),
    situacao TINYINT CHECK (situacao IN (0,1)) NOT NULL DEFAULT 1,
    fk_matriz INT,
    CONSTRAINT fk_usuario_matriz FOREIGN KEY (fk_matriz) REFERENCES usuario(id)
);

-- Tabela telefone para armazenamento dos telefones de contato da empresa
CREATE TABLE telefone (
	id INT PRIMARY KEY AUTO_INCREMENT,
    telefone CHAR(11),
    fk_usuario INT, FOREIGN KEY (fk_usuario) REFERENCES usuario(id)
);

-- Tabela de endereço da empresa (usuario).
CREATE TABLE endereco (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_usuario INT NOT NULL,
    cep CHAR(8) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero INT,
    complemento VARCHAR(100),
    estado CHAR(2) NOT NULL,
    municipio VARCHAR(50) NOT NULL,
    CONSTRAINT fk_endereco_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(id)
);

-- Tabela de arm,azenamento é a tabela onde armazenamos a quantidade de lugares, guardando sua capacidade e utilização. 1 PARA SIM e 0 PARA NÃO!
CREATE TABLE armazenamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_identificador VARCHAR(100),
    fk_usuario INT NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('FOUDRE', 'TANQUE')) NOT NULL,
    capacidade DECIMAL(10,2) NOT NULL,
    utilizacao TINYINT CHECK (utilizacao IN (0,1)) NOT NULL,
    CONSTRAINT fk_armazenamento_usuario FOREIGN KEY (fk_usuario) REFERENCES usuario(id)
);

-- Tabela sensor para armazenar dados de qual armazenamento está o sensor.
CREATE TABLE sensor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_armazenamento INT NOT NULL,
    nivel_carbono_min DECIMAL(10,2) NOT NULL,
    nivel_carbono_max DECIMAL(10,2) NOT NULL,
    situacao TINYINT CHECK (situacao IN (0, 1)),
    CONSTRAINT fk_sensor_armazenamento FOREIGN KEY (fk_armazenamento) REFERENCES armazenamento(id)
);

-- Tabela de leitura onde é a captura do nivel de co2 e referenciamos qual sensor estamos falando.
CREATE TABLE leitura_sensor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_sensor INT NOT NULL,
    nivel_carbono DECIMAL(10,2),
    data_registro DATETIME DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_leitura_sensor FOREIGN KEY (fk_sensor) REFERENCES sensor(id)
);

-- Tabela de alerta, usada para armazenar os alertas caso tenham.
CREATE TABLE alerta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_sensor INT NOT NULL,
    mensagem VARCHAR(255),
    nivel VARCHAR(20) CHECK (nivel IN ('BAIXO', 'ALTO', 'CRITICO')),
    data_alerta DATETIME DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_alerta_sensor FOREIGN KEY (fk_sensor) REFERENCES sensor(id)
);

-- INSERTS 
-- 1. Inserindo as Empresas (Usuários)
-- Primeiro a Matriz (fk_matriz é NULL)
INSERT INTO usuario (nome, cnpj, email, senha, situacao, fk_matriz) 
	VALUES ('Vinícola Central Matriz', '12345678000100', 'contato@central.com', 'hash_senha_123', 1, NULL);

-- Agora a Filial (referenciando o ID 1 da Matriz)
INSERT INTO usuario (nome, cnpj, email, senha, situacao, fk_matriz) 
	VALUES ('Vinícola Filial Bento', '12345678000299', 'bento@central.com', 'hash_senha_456', 1, 1);

-- 2. Inserindo Telefones
INSERT INTO telefone (telefone, fk_usuario) 
	VALUES ('11988887777', 1),
		('54999991111', 2);


-- 3. Inserindo Endereços
INSERT INTO endereco (fk_usuario, cep, logradouro, numero, complemento, estado, municipio) 
	VALUES (1, '01234000', 'Avenida Paulista', 1000, 'Andar 15', 'SP', 'São Paulo');

INSERT INTO endereco (fk_usuario, cep, logradouro, numero, complemento, estado, municipio) 
	VALUES (2, '95700000', 'Rua dos Vinhedos', 50, 'Galpão B', 'RS', 'Bento Gonçalves');

-- 4. Inserindo Armazenamentos (Tanques e Foudres)
INSERT INTO armazenamento (nome_identificador, fk_usuario, tipo, capacidade, utilizacao) 
	VALUES ('Tanque de Inox T-01', 1, 'TANQUE', 5000.00, 1);

INSERT INTO armazenamento (nome_identificador, fk_usuario, tipo, capacidade, utilizacao) 
	VALUES ('Foudre de Carvalho F-01', 2, 'FOUDRE', 2000.00, 1);
    

-- 5. Inserindo Sensores
-- Vinculados aos armazenamentos criados acima
INSERT INTO sensor (fk_armazenamento, nivel_carbono_min, nivel_carbono_max, situacao) 
	VALUES (1, 300.00, 800.00, 1);

INSERT INTO sensor (fk_armazenamento, nivel_carbono_min, nivel_carbono_max, situacao) 
	VALUES (2, 400.00, 1000.00, 1);
    
    select * from leitura_sensor where nivel_carbono > 40;
    

-- 6. Inserindo Leituras de Sensores (Simulando capturas)
INSERT INTO leitura_sensor (fk_sensor, nivel_carbono) 
	VALUES (1, 450.50),
		(1, 460.20),
		(2, 1200.00);

-- 7. Inserindo Alerta
-- Exemplo de alerta baseado na leitura crítica do sensor 2
INSERT INTO alerta (fk_sensor, mensagem, nivel) 
	VALUES (2, 'Nível de CO2 acima do limite permitido no Foudre F-01!', 'CRITICO');
    
    
-- CONSULTAS
    
-- Consulta para visualizar a Empresa principal e suas filhiais
SELECT dono.nome AS "Empresa Principal", filial.nome AS "Empresas Filiais" FROM usuario dono
	INNER JOIN usuario filial ON dono.id = filial.fk_matriz;
    
-- CONSULTA PARA IDENTIFICAR A EMPRESA, TANQUE, NIVEL DE CARBONO ESTIPULADO, VALOR LIDO, O ALERTA, NÍVEL DESSE ALERTA E A DATA DE CAPTURA - LEITURA DO SENSOR.
SELECT u.nome AS 'empresa', a.tipo AS 'tipo_tanque', s.nivel_carbono_max AS 'limite_max', l.nivel_carbono AS 'valor_lido', al.mensagem AS 'alerta', al.nivel AS 'Nível' ,al.data_alerta AS 'momento_do_erro' 
	FROM alerta al
		INNER JOIN sensor s ON al.fk_sensor = s.id
		INNER JOIN leitura_sensor l ON l.fk_sensor = s.id
		INNER JOIN armazenamento a ON s.fk_armazenamento = a.id
		INNER JOIN usuario u ON a.fk_usuario = u.id
			WHERE al.nivel = 'critico'
				ORDER BY al.data_alerta DESC;