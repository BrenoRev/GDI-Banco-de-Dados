-- Tipo para CEP
CREATE TYPE tp_CEP AS OBJECT (
    CEP VARCHAR2(10),
    RUA VARCHAR2(100),
    CIDADE VARCHAR2(100),
    ESTADO VARCHAR2(2)
);
/
-- Tabela para armazenar CEPs
CREATE TABLE CEP_TABLE OF tp_CEP (
    PRIMARY KEY (CEP)
);

-- Tipo para USUARIO
CREATE TYPE tp_Usuario AS OBJECT (
    CPF VARCHAR2(14),
    CEP tp_CEP,  -- Referência ao tipo de objeto CEP
    EMAIL VARCHAR2(100),
    SENHA VARCHAR2(50),
    NUMERO NUMBER
) not final;
/
-- Tabela para USUARIOS, referenciando o tipo de CEP
CREATE TABLE USUARIO_TABLE OF tp_Usuario (
    PRIMARY KEY (CPF),
    CONSTRAINT FK_CEP FOREIGN KEY (CEP.CEP) REFERENCES CEP_TABLE(CEP)
);

-- Tipo para CARGO
CREATE TYPE tp_Cargo AS OBJECT (
    CARGO_FUNC VARCHAR2(50),
    SALARIO NUMBER
);
/
-- Tabela para CARGOS
CREATE TABLE CARGO_TABLE OF tp_Cargo (
    PRIMARY KEY (CARGO_FUNC)
);

CREATE TYPE tp_Funcionario UNDER tp_Usuario (
    CARGO_FUNC tp_Cargo,
    DATA_DE_CONTRATACAO DATE,
    CPF_SUPERVISOR VARCHAR2(14)
);
/
-- Tabela para FUNCIONARIO, referenciando tipos de USUARIOS e CARGOS
CREATE TABLE FUNCIONARIO_TABLE OF tp_Funcionario (
    PRIMARY KEY (CPF),
    CONSTRAINT FK_USUARIO FOREIGN KEY (CPF) REFERENCES USUARIO_TABLE(CPF),
    CONSTRAINT FK_SUPERVISOR FOREIGN KEY (CPF_SUPERVISOR) REFERENCES FUNCIONARIO_TABLE(CPF),
    CONSTRAINT FK_CARGO_FUNC FOREIGN KEY (CARGO_FUNC.CARGO_FUNC) REFERENCES CARGO_TABLE(CARGO_FUNC)
);

CREATE TYPE tp_Cliente UNDER tp_Usuario (
    DATA_DE_ADESAO DATE
);
/
-- Tabela para CLIENTE
CREATE TABLE CLIENTE_TABLE OF tp_Cliente (
    PRIMARY KEY (CPF_USU),
    CONSTRAINT FK_CLIENTE FOREIGN KEY (CPF_USU) REFERENCES USUARIO_TABLE(CPF)
);

-- Tipo para TELEFONE
CREATE TYPE tp_Telefone AS OBJECT (
    NUM_TELEFONE VARCHAR2(15)
) not final;
/
-- Definindo coleção de telefones
CREATE TYPE tp_Telefones AS TABLE OF tp_Telefone;
/
-- Tabela para Telefone usando NESTED TABLE para armazenar múltiplos números **TEM problema
CREATE TABLE TELEFONE_TABLE (
    CPF_USU VARCHAR2(14),   -- CPF do usuário
    TELEFONES tp_Telefones, -- Coleção de telefones
    PRIMARY KEY (CPF_USU)  -- Definindo CPF como chave primária
    --CONSTRAINT FK_USUARIO FOREIGN KEY (CPF_USU) REFERENCES USUARIO_TABLE(CPF)  -- Referência ao CPF na tabela de usuários
)
NESTED TABLE TELEFONES STORE AS TELEFONES_NT;  -- Definindo onde armazenar a NESTED TABLE

-- Tipo para MODELOMARCA
CREATE TYPE tp_ModeloMarca AS OBJECT (
    MODELO VARCHAR2(50),
    MARCA VARCHAR2(50),
);
/

-- Tipo para CARRO
CREATE TYPE tp_Carro AS OBJECT (
    CHASSI VARCHAR2(17),
    MODELO tp_ModeloMarca,  -- Referência ao tipo de objeto MODELOMARCA
    ANO NUMBER,
    PRECO NUMBER,
    KM NUMBER,
    COR VARCHAR2(30)
);
/
-- Tabela para CARROS 
CREATE TABLE CARRO_TABLE OF tp_Carro (
    PRIMARY KEY (CHASSI)
);

-- Tipo para PEDIDO
CREATE TYPE tp_Pedido AS OBJECT (
    HASH VARCHAR2(64),
    TIPO VARCHAR2(50),
    DATA DATE,
    DATA_ENTREGA DATE,
    STATUS VARCHAR2(20)
);
/
-- Tabela para PEDIDOS
CREATE TABLE PEDIDO_TABLE OF tp_Pedido (
    PRIMARY KEY (HASH)
);

-- Tipo para EQUIPAMENTO
CREATE TYPE tp_Equipamento AS OBJECT (
    ID NUMBER,
    NOME VARCHAR2(50),
    DESCRICAO VARCHAR2(255)
);
/
-- Tabela para EQUIPAMENTOS
CREATE TABLE EQUIPAMENTO_TABLE OF tp_Equipamento (
    PRIMARY KEY (ID)
);

-- Tipo para SERVICO
CREATE TYPE tp_Servico AS OBJECT (
    PROTOCOLO VARCHAR2(64),
    NOME VARCHAR2(100)
);
/
-- Tabela para SERVIÇOS
CREATE TABLE SERVICO_TABLE OF tp_Servico (
    PRIMARY KEY (PROTOCOLO)
);

-- Tipo para PAGAMENTO SERVICO
CREATE TYPE tp_PagamentoServico AS OBJECT (
    PROTOCOLO_SERV tp_Servico,
    ID_PAG NUMBER,
    METODO VARCHAR2(50)
);
/
-- Tabela para PAGAMENTO SERVICO
CREATE TABLE PAGAMENTO_SERVICO OF tp_PagamentoServico (
    PRIMARY KEY (ID_PAG)
);

-- Tipo para PROTOCOLO VALOR
CREATE TYPE tp_ProtocoloValor AS OBJECT (
    PROTOCOLO_SERV tp_Servico,
    VALOR NUMBER
);
/
-- Tabela para PAGAMENTO SERVICO 
CREATE TABLE PROTOCOLO_VALOR OF tp_ProtocoloValor (
    PRIMARY KEY (PROTOCOLO_SERV), 
    CONSTRAINT FK_PROTOCOLO FOREIGN KEY (PROTOCOLO_SERV.PROTOCOLO) REFERENCES tp_Servico(PROTOCOLO)  
);

-- Tipo para PAGAMENTO PEDIDO
CREATE TYPE tp_PagamentoPedido AS OBJECT (
    HASH_PED tp_Pedido,
    ID_PAG NUMBER,
    METODO VARCHAR2(50),
    VALOR NUMBER
);
/
-- Tabela PAGAMENTO PEDIDO
CREATE TABLE PAGAMENTO_PEDIDO OF tp_PagamentoPedido (
    PRIMARY KEY (ID_PAG),
    CONSTRAINT FK_HASH FOREIGN KEY (HASH_PED.HASH) REFERENCES tp_pedido(HASH)    
);

-- Tipo ANUNCIO
CREATE TYPE tp_Anuncio AS OBJECT (
    CHASSI_CAR tp_Carro,
    URL VARCHAR2(255)
);
/
-- Tabela ANUNCIO
CREATE TABLE ANUNCIO OF tp_Anuncio (
    PRIMARY KEY (URL),
    CONSTRAINT FK_CHASSI FOREIGN KEY (CHASSI_CAR.CHASSI) REFERENCES tp_Carro(CHASSI)  
);

-- Tipo SOLICITA
CREATE TYPE tp_Solicita AS OBJECT (
    CPF_CLI tp_Cliente,
    CPF_FUNC tp_Funcionario,
    PROTOCOLO_SERV tp_Servico
);
/
-- Tabela SOLICITA
CREATE TABLE SOLICITA OF tp_Solicita (
    PRIMARY KEY (CPF_CLI),
    PRIMARY KEY (CPF_FUNC),
    PRIMARY KEY (PROTOCOLO_SERV),
    CONSTRAINT FK_CHASSI FOREIGN KEY (CHASSI_CAR.CHASSI) REFERENCES tp_Carro(CHASSI),
    CONSTRAINT FK_CHASSI FOREIGN KEY (CHASSI_CAR.CHASSI) REFERENCES tp_Carro(CHASSI),
    CONSTRAINT FK_CHASSI FOREIGN KEY (CHASSI_CAR.CHASSI) REFERENCES tp_Carro(CHASSI)    
);

-- Tipo VENDE
CREATE TYPE tp_Vende AS OBJECT (
    CHASSI_CAR tp_Carro,
    HASH_PED tp_Pedido,
    CPF_FUNC tp_Funcionario,
    CPF_CLI tp_Cliente
);
/
-- Tabela VENDE

-- Tipo ENVOLVE
CREATE TYPE tp_Envolve AS OBJECT (
    PROTOCOLO_SERV tp_Servico,
    ID_EQUIP tp_Equipamento
);
/
-- Tabela ENVOLVE

-- Tipo COMENTA
CREATE TYPE tp_Comenta AS OBJECT (
    CPF_CLI tp_Cliente,
    CPF_FUNC tp_Funcionario,
    URL_ANUN tp_Anuncio,
    CONTEUDO VARCHAR2(500),
    DATA DATE
);
/
-- Tabela COMENTA

-- Tipo RESPONDE
CREATE TYPE tp_Responde AS OBJECT (
    CPF_FUNC tp_Funcionario,
    URL_ANUN tp_Anuncio,
    DATA DATE,
    CONTEUDO VARCHAR2(500)
);
/
-- Tabela RESPONDE

-- Tipo VENDA
CREATE TYPE tp_VendaAudit AS OBJECT (
    id_audit NUMBER,
    chassi_car VARCHAR2(17),
    hash_ped VARCHAR2(64),
    cpf_func VARCHAR2(14),
    nome_func VARCHAR2(100),
    cpf_cli VARCHAR2(14),
    nome_cli VARCHAR2(100),
    valor_total NUMBER,
    data_venda DATE
);
/
-- Tabela VENDA