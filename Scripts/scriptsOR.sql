-- ============================================================
-- PT1: DEFININDO OS TIPOS
-- ============================================================

-- Tipo para CEP
CREATE OR REPLACE TYPE tp_CEP AS OBJECT (
    CEP VARCHAR2(10),
    RUA VARCHAR2(100),
    CIDADE VARCHAR2(100),
    ESTADO VARCHAR2(2),
    CONSTRUCTOR FUNCTION tp_CEP(
        CEP VARCHAR2,
        RUA VARCHAR2,
        CIDADE VARCHAR2,
        ESTADO VARCHAR2
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info,
    MAP MEMBER FUNCTION get_cep RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY tp_CEP AS
    CONSTRUCTOR FUNCTION tp_CEP(
        CEP VARCHAR2,
        RUA VARCHAR2,
        CIDADE VARCHAR2,
        ESTADO VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.CEP := CEP;
        SELF.RUA := RUA;
        SELF.CIDADE := CIDADE;
        SELF.ESTADO := ESTADO;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('CEP: ' || CEP || ', Rua: ' || RUA || ', Cidade: ' || CIDADE || ', Estado: ' || ESTADO);
    END;

    MAP MEMBER FUNCTION get_cep RETURN VARCHAR2 IS
    BEGIN
        RETURN SELF.CEP;
    END;
END;
/

-- Tipo para Telefones (VARRAY)
CREATE OR REPLACE TYPE tp_Telefones AS VARRAY(3) OF VARCHAR2(15);
/

-- Tipo base para Pessoa (abstract)
CREATE OR REPLACE TYPE tp_Pessoa AS OBJECT (
    CPF VARCHAR2(14),
    EMAIL VARCHAR2(100),
    SENHA VARCHAR2(50),
    CONSTRUCTOR FUNCTION tp_Pessoa(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info,
    NOT INSTANTIABLE MEMBER PROCEDURE abstract_method
) NOT INSTANTIABLE NOT FINAL;
/
CREATE OR REPLACE TYPE BODY tp_Pessoa AS
    CONSTRUCTOR FUNCTION tp_Pessoa(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.CPF := CPF;
        SELF.EMAIL := EMAIL;
        SELF.SENHA := SENHA;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('CPF: ' || CPF || ', Email: ' || EMAIL);
    END;

    NOT INSTANTIABLE MEMBER PROCEDURE abstract_method IS
    BEGIN
        NULL; -- Método abstrato
    END;
END;
/

-- Tipo para Usuario (herda de Pessoa)
CREATE OR REPLACE TYPE tp_Usuario UNDER tp_Pessoa (
    CEP REF tp_CEP,
    NUMERO NUMBER,
    TELEFONES tp_Telefones,
    CONSTRUCTOR FUNCTION tp_Usuario(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2,
        CEP REF tp_CEP,
        NUMERO NUMBER,
        TELEFONES tp_Telefones
    ) RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE display_info,
    OVERRIDING MEMBER PROCEDURE abstract_method -- Implementação do método abstrato
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY tp_Usuario AS
    CONSTRUCTOR FUNCTION tp_Usuario(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2,
        CEP REF tp_CEP,
        NUMERO NUMBER,
        TELEFONES tp_Telefones
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.CPF := CPF;
        SELF.EMAIL := EMAIL;
        SELF.SENHA := SENHA;
        SELF.CEP := CEP;
        SELF.NUMERO := NUMERO;
        SELF.TELEFONES := TELEFONES;
        RETURN;
    END;

    OVERRIDING MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Usuário CPF: ' || CPF || ', Email: ' || EMAIL || ', Número: ' || NUMERO);
        IF TELEFONES IS NOT NULL THEN
            FOR i IN 1..TELEFONES.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE('Telefone ' || i || ': ' || TELEFONES(i));
            END LOOP;
        END IF;
    END;

    OVERRIDING MEMBER PROCEDURE abstract_method IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Implementação do método abstrato em tp_Usuario.');
    END;
END;
/

-- Tipo para Cliente (herda de Usuario)
CREATE OR REPLACE TYPE tp_Cliente UNDER tp_Usuario (
    DATA_DE_ADESAO DATE,
    CONSTRUCTOR FUNCTION tp_Cliente(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2,
        CEP REF tp_CEP,
        NUMERO NUMBER,
        TELEFONES tp_Telefones,
        DATA_DE_ADESAO DATE
    ) RETURN SELF AS RESULT,
    OVERRIDING FINAL MEMBER PROCEDURE display_info
) FINAL;
/
CREATE OR REPLACE TYPE BODY tp_Cliente AS
    CONSTRUCTOR FUNCTION tp_Cliente(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2,
        CEP REF tp_CEP,
        NUMERO NUMBER,
        TELEFONES tp_Telefones,
        DATA_DE_ADESAO DATE
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.CPF := CPF;
        SELF.EMAIL := EMAIL;
        SELF.SENHA := SENHA;
        SELF.CEP := CEP;
        SELF.NUMERO := NUMERO;
        SELF.TELEFONES := TELEFONES;
        SELF.DATA_DE_ADESAO := DATA_DE_ADESAO;
        RETURN;
    END;

    OVERRIDING FINAL MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Cliente CPF: ' || CPF || ', Data de Adesão: ' || TO_CHAR(DATA_DE_ADESAO, 'DD/MM/YYYY'));
    END;
END;
/

-- Tipo para Cargo
CREATE OR REPLACE TYPE tp_Cargo AS OBJECT (
    CARGO_FUNC VARCHAR2(50),
    SALARIO NUMBER,
    CONSTRUCTOR FUNCTION tp_Cargo(
        CARGO_FUNC VARCHAR2,
        SALARIO NUMBER
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info,
    ORDER MEMBER FUNCTION compare (other tp_Cargo) RETURN INTEGER
);
/
CREATE OR REPLACE TYPE BODY tp_Cargo AS
    CONSTRUCTOR FUNCTION tp_Cargo(
        CARGO_FUNC VARCHAR2,
        SALARIO NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        IF SALARIO <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Salário deve ser maior que zero.');
        END IF;
        SELF.CARGO_FUNC := CARGO_FUNC;
        SELF.SALARIO := SALARIO;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Cargo: ' || CARGO_FUNC || ', Salário: ' || SALARIO);
    END;

    ORDER MEMBER FUNCTION compare (other tp_Cargo) RETURN INTEGER IS
    BEGIN
        RETURN SELF.SALARIO - other.SALARIO;
    END;
END;
/

-- Tipo para Funcionario (herda de Usuario)
CREATE OR REPLACE TYPE tp_Funcionario UNDER tp_Usuario (
    CARGO_FUNC REF tp_Cargo,
    DATA_DE_CONTRATACAO DATE,
    CPF_SUPERVISOR REF tp_Funcionario, -- Self-referencing REF
    CONSTRUCTOR FUNCTION tp_Funcionario(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2,
        CEP REF tp_CEP,
        NUMERO NUMBER,
        TELEFONES tp_Telefones,
        CARGO_FUNC REF tp_Cargo,
        DATA_DE_CONTRATACAO DATE,
        CPF_SUPERVISOR REF tp_Funcionario
    ) RETURN SELF AS RESULT,
    OVERRIDING MEMBER PROCEDURE display_info
) FINAL;
/
CREATE OR REPLACE TYPE BODY tp_Funcionario AS
    CONSTRUCTOR FUNCTION tp_Funcionario(
        CPF VARCHAR2,
        EMAIL VARCHAR2,
        SENHA VARCHAR2,
        CEP REF tp_CEP,
        NUMERO NUMBER,
        TELEFONES tp_Telefones,
        CARGO_FUNC REF tp_Cargo,
        DATA_DE_CONTRATACAO DATE,
        CPF_SUPERVISOR REF tp_Funcionario
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.CPF := CPF;
        SELF.EMAIL := EMAIL;
        SELF.SENHA := SENHA;
        SELF.CEP := CEP;
        SELF.NUMERO := NUMERO;
        SELF.TELEFONES := TELEFONES;
        SELF.CARGO_FUNC := CARGO_FUNC;
        SELF.DATA_DE_CONTRATACAO := DATA_DE_CONTRATACAO;
        SELF.CPF_SUPERVISOR := CPF_SUPERVISOR;
        RETURN;
    END;

    OVERRIDING MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Funcionário CPF: ' || CPF || ', Data de Contratação: ' || TO_CHAR(DATA_DE_CONTRATACAO, 'DD/MM/YYYY'));
    END;
END;
/

-- Tipo para ModeloMarca
CREATE OR REPLACE TYPE tp_ModeloMarca AS OBJECT (
    MODELO VARCHAR2(50),
    MARCA VARCHAR2(50),
    CONSTRUCTOR FUNCTION tp_ModeloMarca(
        MODELO VARCHAR2,
        MARCA VARCHAR2
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info
);
/
CREATE OR REPLACE TYPE BODY tp_ModeloMarca AS
    CONSTRUCTOR FUNCTION tp_ModeloMarca(
        MODELO VARCHAR2,
        MARCA VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.MODELO := MODELO;
        SELF.MARCA := MARCA;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Modelo: ' || MODELO || ', Marca: ' || MARCA);
    END;
END;
/

-- Tipo para Carro
CREATE OR REPLACE TYPE tp_Carro AS OBJECT (
    CHASSI VARCHAR2(17),
    MODELO REF tp_ModeloMarca,
    ANO NUMBER,
    PRECO NUMBER,
    KM NUMBER,
    COR VARCHAR2(30),
    CONSTRUCTOR FUNCTION tp_Carro(
        CHASSI VARCHAR2,
        MODELO REF tp_ModeloMarca,
        ANO NUMBER,
        PRECO NUMBER,
        KM NUMBER,
        COR VARCHAR2
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info
);
/
CREATE OR REPLACE TYPE BODY tp_Carro AS
    CONSTRUCTOR FUNCTION tp_Carro(
        CHASSI VARCHAR2,
        MODELO REF tp_ModeloMarca,
        ANO NUMBER,
        PRECO NUMBER,
        KM NUMBER,
        COR VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        IF PRECO < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Preço não pode ser negativo.');
        END IF;
        IF KM < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'KM não pode ser negativo.');
        END IF;
        SELF.CHASSI := CHASSI;
        SELF.MODELO := MODELO;
        SELF.ANO := ANO;
        SELF.PRECO := PRECO;
        SELF.KM := KM;
        SELF.COR := COR;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Carro Chassi: ' || CHASSI || ', Ano: ' || ANO || ', Preço: ' || PRECO || ', KM: ' || KM || ', Cor: ' || COR);
    END;
END;
/

-- Tipo para Equipamento
CREATE OR REPLACE TYPE tp_Equipamento AS OBJECT (
    ID NUMBER,
    NOME VARCHAR2(50),
    DESCRICAO VARCHAR2(255),
    CONSTRUCTOR FUNCTION tp_Equipamento(
        ID NUMBER,
        NOME VARCHAR2,
        DESCRICAO VARCHAR2
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info
);
/
CREATE OR REPLACE TYPE BODY tp_Equipamento AS
    CONSTRUCTOR FUNCTION tp_Equipamento(
        ID NUMBER,
        NOME VARCHAR2,
        DESCRICAO VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID := ID;
        SELF.NOME := NOME;
        SELF.DESCRICAO := DESCRICAO;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Equipamento ID: ' || ID || ', Nome: ' || NOME || ', Descrição: ' || DESCRICAO);
    END;
END;
/

-- Tipo para coleção de Equipamentos (NESTED TABLE)
CREATE OR REPLACE TYPE tp_Equipamentos AS TABLE OF tp_Equipamento;
/

-- Tipo para Serviço
CREATE OR REPLACE TYPE tp_Servico AS OBJECT (
    PROTOCOLO VARCHAR2(64),
    NOME VARCHAR2(100),
    EQUIPAMENTOS tp_Equipamentos,
    CONSTRUCTOR FUNCTION tp_Servico(
        PROTOCOLO VARCHAR2,
        NOME VARCHAR2,
        EQUIPAMENTOS tp_Equipamentos
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info
);
/
CREATE OR REPLACE TYPE BODY tp_Servico AS
    CONSTRUCTOR FUNCTION tp_Servico(
        PROTOCOLO VARCHAR2,
        NOME VARCHAR2,
        EQUIPAMENTOS tp_Equipamentos
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.PROTOCOLO := PROTOCOLO;
        SELF.NOME := NOME;
        SELF.EQUIPAMENTOS := EQUIPAMENTOS;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Serviço Protocolo: ' || PROTOCOLO || ', Nome: ' || NOME);
        IF EQUIPAMENTOS IS NOT NULL THEN
            FOR i IN 1..EQUIPAMENTOS.COUNT LOOP
                EQUIPAMENTOS(i).display_info;
            END LOOP;
        END IF;
    END;
END;
/

-- Tipo para Pedido
CREATE OR REPLACE TYPE tp_Pedido AS OBJECT (
    HASH VARCHAR2(64),
    TIPO VARCHAR2(50),
    DATA_PEDIDO DATE,
    DATA_ENTREGA DATE,
    STATUS_PEDIDO VARCHAR2(20),
    CONSTRUCTOR FUNCTION tp_Pedido(
        HASH VARCHAR2,
        TIPO VARCHAR2,
        DATA_PEDIDO DATE,
        DATA_ENTREGA DATE,
        STATUS_PEDIDO VARCHAR2
    ) RETURN SELF AS RESULT,
    MEMBER PROCEDURE display_info
);
/
CREATE OR REPLACE TYPE BODY tp_Pedido AS
    CONSTRUCTOR FUNCTION tp_Pedido(
        HASH VARCHAR2,
        TIPO VARCHAR2,
        DATA_PEDIDO DATE,
        DATA_ENTREGA DATE,
        STATUS_PEDIDO VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.HASH := HASH;
        SELF.TIPO := TIPO;
        SELF.DATA_PEDIDO := DATA_PEDIDO;
        SELF.DATA_ENTREGA := DATA_ENTREGA;
        SELF.STATUS_PEDIDO := STATUS_PEDIDO;
        RETURN;
    END;

    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Pedido Hash: ' || HASH || ', Tipo: ' || TIPO || ', Status: ' || STATUS_PEDIDO);
    END;
END;
/

-- Tipo para PagamentoServico
CREATE OR REPLACE TYPE tp_PagamentoServico AS OBJECT (
    ID_PAGSERV NUMBER,
    PROTOCOLO_SERV REF tp_Servico,
    ID_PAG NUMBER,
    METODO VARCHAR2(50),
    CONSTRUCTOR FUNCTION tp_PagamentoServico(
        ID_PAGSERV NUMBER,
        PROTOCOLO_SERV REF tp_Servico,
        ID_PAG NUMBER,
        METODO VARCHAR2
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_PagamentoServico AS
    CONSTRUCTOR FUNCTION tp_PagamentoServico(
        ID_PAGSERV NUMBER,
        PROTOCOLO_SERV REF tp_Servico,
        ID_PAG NUMBER,
        METODO VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_PAGSERV := ID_PAGSERV;
        SELF.PROTOCOLO_SERV := PROTOCOLO_SERV;
        SELF.ID_PAG := ID_PAG;
        SELF.METODO := METODO;
        RETURN;
    END;
END;
/

-- Tipo para ProtocoloValor
CREATE OR REPLACE TYPE tp_ProtocoloValor AS OBJECT (
    ID_PROTOVALOR NUMBER,
    PROTOCOLO_SERV REF tp_Servico,
    VALOR NUMBER,
    CONSTRUCTOR FUNCTION tp_ProtocoloValor(
        ID_PROTOVALOR NUMBER,
        PROTOCOLO_SERV REF tp_Servico,
        VALOR NUMBER
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_ProtocoloValor AS
    CONSTRUCTOR FUNCTION tp_ProtocoloValor(
        ID_PROTOVALOR NUMBER,
        PROTOCOLO_SERV REF tp_Servico,
        VALOR NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_PROTOVALOR := ID_PROTOVALOR;
        SELF.PROTOCOLO_SERV := PROTOCOLO_SERV;
        SELF.VALOR := VALOR;
        RETURN;
    END;
END;
/

-- Tipo para PagamentoPedido
CREATE OR REPLACE TYPE tp_PagamentoPedido AS OBJECT (
    ID_PAGPEDIDO NUMBER,
    HASH_PED REF tp_Pedido,
    ID_PAG NUMBER,
    METODO VARCHAR2(50),
    VALOR NUMBER,
    CONSTRUCTOR FUNCTION tp_PagamentoPedido(
        ID_PAGPEDIDO NUMBER,
        HASH_PED REF tp_Pedido,
        ID_PAG NUMBER,
        METODO VARCHAR2,
        VALOR NUMBER
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_PagamentoPedido AS
    CONSTRUCTOR FUNCTION tp_PagamentoPedido(
        ID_PAGPEDIDO NUMBER,
        HASH_PED REF tp_Pedido,
        ID_PAG NUMBER,
        METODO VARCHAR2,
        VALOR NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_PAGPEDIDO := ID_PAGPEDIDO;
        SELF.HASH_PED := HASH_PED;
        SELF.ID_PAG := ID_PAG;
        SELF.METODO := METODO;
        SELF.VALOR := VALOR;
        RETURN;
    END;
END;
/

-- Tipo para Anuncio
CREATE OR REPLACE TYPE tp_Anuncio AS OBJECT (
    URL VARCHAR2(255),
    CHASSI_CAR REF tp_Carro,
    CONSTRUCTOR FUNCTION tp_Anuncio(
        URL VARCHAR2,
        CHASSI_CAR REF tp_Carro
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_Anuncio AS
    CONSTRUCTOR FUNCTION tp_Anuncio(
        URL VARCHAR2,
        CHASSI_CAR REF tp_Carro
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.URL := URL;
        SELF.CHASSI_CAR := CHASSI_CAR;
        RETURN;
    END;
END;
/

-- Tipo para Solicita
CREATE OR REPLACE TYPE tp_Solicita AS OBJECT (
    ID_SOLICITA NUMBER,
    CPF_CLI REF tp_Cliente,
    CPF_FUNC REF tp_Funcionario,
    PROTOCOLO_SERV REF tp_Servico,
    CONSTRUCTOR FUNCTION tp_Solicita(
        ID_SOLICITA NUMBER,
        CPF_CLI REF tp_Cliente,
        CPF_FUNC REF tp_Funcionario,
        PROTOCOLO_SERV REF tp_Servico
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_Solicita AS
    CONSTRUCTOR FUNCTION tp_Solicita(
        ID_SOLICITA NUMBER,
        CPF_CLI REF tp_Cliente,
        CPF_FUNC REF tp_Funcionario,
        PROTOCOLO_SERV REF tp_Servico
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_SOLICITA := ID_SOLICITA;
        SELF.CPF_CLI := CPF_CLI;
        SELF.CPF_FUNC := CPF_FUNC;
        SELF.PROTOCOLO_SERV := PROTOCOLO_SERV;
        RETURN;
    END;
END;
/

-- Tipo para Vende
CREATE OR REPLACE TYPE tp_Vende AS OBJECT (
    ID_VENDE NUMBER,
    CHASSI_CAR REF tp_Carro,
    HASH_PED REF tp_Pedido,
    CPF_FUNC REF tp_Funcionario,
    CPF_CLI REF tp_Cliente,
    CONSTRUCTOR FUNCTION tp_Vende(
        ID_VENDE NUMBER,
        CHASSI_CAR REF tp_Carro,
        HASH_PED REF tp_Pedido,
        CPF_FUNC REF tp_Funcionario,
        CPF_CLI REF tp_Cliente
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_Vende AS
    CONSTRUCTOR FUNCTION tp_Vende(
        ID_VENDE NUMBER,
        CHASSI_CAR REF tp_Carro,
        HASH_PED REF tp_Pedido,
        CPF_FUNC REF tp_Funcionario,
        CPF_CLI REF tp_Cliente
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_VENDE := ID_VENDE;
        SELF.CHASSI_CAR := CHASSI_CAR;
        SELF.HASH_PED := HASH_PED;
        SELF.CPF_FUNC := CPF_FUNC;
        SELF.CPF_CLI := CPF_CLI;
        RETURN;
    END;
END;
/

-- Tipo para Envolve
CREATE OR REPLACE TYPE tp_Envolve AS OBJECT (
    ID_ENVOLVE NUMBER,
    PROTOCOLO_SERV REF tp_Servico,
    ID_EQUIP REF tp_Equipamento,
    CONSTRUCTOR FUNCTION tp_Envolve(
        ID_ENVOLVE NUMBER,
        PROTOCOLO_SERV REF tp_Servico,
        ID_EQUIP REF tp_Equipamento
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_Envolve AS
    CONSTRUCTOR FUNCTION tp_Envolve(
        ID_ENVOLVE NUMBER,
        PROTOCOLO_SERV REF tp_Servico,
        ID_EQUIP REF tp_Equipamento
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_ENVOLVE := ID_ENVOLVE;
        SELF.PROTOCOLO_SERV := PROTOCOLO_SERV;
        SELF.ID_EQUIP := ID_EQUIP;
        RETURN;
    END;
END;
/

-- Tipo para Comenta
CREATE OR REPLACE TYPE tp_Comenta AS OBJECT (
    ID_COMENTA NUMBER,
    CPF_CLI REF tp_Cliente,
    CPF_FUNC REF tp_Funcionario,
    URL_ANUN REF tp_Anuncio,
    CONTEUDO VARCHAR2(500),
    DATA_COMENT DATE,
    CONSTRUCTOR FUNCTION tp_Comenta(
        ID_COMENTA NUMBER,
        CPF_CLI REF tp_Cliente,
        CPF_FUNC REF tp_Funcionario,
        URL_ANUN REF tp_Anuncio,
        CONTEUDO VARCHAR2,
        DATA_COMENT DATE
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_Comenta AS
    CONSTRUCTOR FUNCTION tp_Comenta(
        ID_COMENTA NUMBER,
        CPF_CLI REF tp_Cliente,
        CPF_FUNC REF tp_Funcionario,
        URL_ANUN REF tp_Anuncio,
        CONTEUDO VARCHAR2,
        DATA_COMENT DATE
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_COMENTA := ID_COMENTA;
        SELF.CPF_CLI := CPF_CLI;
        SELF.CPF_FUNC := CPF_FUNC;
        SELF.URL_ANUN := URL_ANUN;
        SELF.CONTEUDO := CONTEUDO;
        SELF.DATA_COMENT := DATA_COMENT;
        RETURN;
    END;
END;
/

-- Tipo para Responde
CREATE OR REPLACE TYPE tp_Responde AS OBJECT (
    ID_RESPONDE NUMBER,
    CPF_FUNC REF tp_Funcionario,
    URL_ANUN REF tp_Anuncio,
    DATA_RESP DATE,
    CONTEUDO VARCHAR2(500),
    CONSTRUCTOR FUNCTION tp_Responde(
        ID_RESPONDE NUMBER,
        CPF_FUNC REF tp_Funcionario,
        URL_ANUN REF tp_Anuncio,
        DATA_RESP DATE,
        CONTEUDO VARCHAR2
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_Responde AS
    CONSTRUCTOR FUNCTION tp_Responde(
        ID_RESPONDE NUMBER,
        CPF_FUNC REF tp_Funcionario,
        URL_ANUN REF tp_Anuncio,
        DATA_RESP DATE,
        CONTEUDO VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_RESPONDE := ID_RESPONDE;
        SELF.CPF_FUNC := CPF_FUNC;
        SELF.URL_ANUN := URL_ANUN;
        SELF.DATA_RESP := DATA_RESP;
        SELF.CONTEUDO := CONTEUDO;
        RETURN;
    END;
END;
/

-- Tipo para VendaAudit
CREATE OR REPLACE TYPE tp_VendaAudit AS OBJECT (
    ID_AUDIT NUMBER,
    CHASSI_CAR REF tp_Carro,
    HASH_PED REF tp_Pedido,
    CPF_FUNC REF tp_Funcionario,
    NOME_FUNC VARCHAR2(100),
    CPF_CLI REF tp_Cliente,
    NOME_CLI VARCHAR2(100),
    VALOR_TOTAL NUMBER,
    DATA_VENDA DATE,
    CONSTRUCTOR FUNCTION tp_VendaAudit(
        ID_AUDIT NUMBER,
        CHASSI_CAR REF tp_Carro,
        HASH_PED REF tp_Pedido,
        CPF_FUNC REF tp_Funcionario,
        NOME_FUNC VARCHAR2,
        CPF_CLI REF tp_Cliente,
        NOME_CLI VARCHAR2,
        VALOR_TOTAL NUMBER,
        DATA_VENDA DATE
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY tp_VendaAudit AS
    CONSTRUCTOR FUNCTION tp_VendaAudit(
        ID_AUDIT NUMBER,
        CHASSI_CAR REF tp_Carro,
        HASH_PED REF tp_Pedido,
        CPF_FUNC REF tp_Funcionario,
        NOME_FUNC VARCHAR2,
        CPF_CLI REF tp_Cliente,
        NOME_CLI VARCHAR2,
        VALOR_TOTAL NUMBER,
        DATA_VENDA DATE
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID_AUDIT := ID_AUDIT;
        SELF.CHASSI_CAR := CHASSI_CAR;
        SELF.HASH_PED := HASH_PED;
        SELF.CPF_FUNC := CPF_FUNC;
        SELF.NOME_FUNC := NOME_FUNC;
        SELF.CPF_CLI := CPF_CLI;
        SELF.NOME_CLI := NOME_CLI;
        SELF.VALOR_TOTAL := VALOR_TOTAL;
        SELF.DATA_VENDA := DATA_VENDA;
        RETURN;
    END;
END;
/

-- ============================================================
-- PT2: CRIAÇÃO DAS TABELAS (Ajustadas)
-- ============================================================

-- Tabela para CEPs
CREATE TABLE CEP_TABLE OF tp_CEP
( PRIMARY KEY (CEP) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Tabela para Cargos
CREATE TABLE CARGO_TABLE OF tp_Cargo
( PRIMARY KEY (CARGO_FUNC) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Tabela para Usuários
CREATE TABLE USUARIO_TABLE OF tp_Usuario
( PRIMARY KEY (CPF) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para CEP em USUARIO_TABLE
ALTER TABLE USUARIO_TABLE
  MODIFY (CEP SCOPE IS CEP_TABLE);
/

-- Tabela para Clientes
CREATE TABLE CLIENTE_TABLE OF tp_Cliente
( PRIMARY KEY (CPF) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para CEP em CLIENTE_TABLE
ALTER TABLE CLIENTE_TABLE
  MODIFY (CEP SCOPE IS CEP_TABLE);
/

-- Tabela para Funcionários
CREATE TABLE FUNCIONARIO_TABLE OF tp_Funcionario
( PRIMARY KEY (CPF) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para CEP, CARGO_FUNC e CPF_SUPERVISOR em FUNCIONARIO_TABLE
ALTER TABLE FUNCIONARIO_TABLE
  MODIFY (
    CEP SCOPE IS CEP_TABLE,
    CARGO_FUNC SCOPE IS CARGO_TABLE,
    CPF_SUPERVISOR SCOPE IS FUNCIONARIO_TABLE
  );
/

-- Tabela para ModeloMarca
CREATE TABLE MODELOMARCA_TABLE OF tp_ModeloMarca
( PRIMARY KEY (MODELO, MARCA) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Tabela para Carros
CREATE TABLE CARRO_TABLE OF tp_Carro
( PRIMARY KEY (CHASSI) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para MODELO em CARRO_TABLE
ALTER TABLE CARRO_TABLE
  MODIFY (MODELO SCOPE IS MODELOMARCA_TABLE);
/

-- Tabela para Equipamentos
CREATE TABLE EQUIPAMENTO_TABLE OF tp_Equipamento
( PRIMARY KEY (ID) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Tabela para Serviços
CREATE TABLE SERVICO_TABLE OF tp_Servico
( PRIMARY KEY (PROTOCOLO) )
OBJECT IDENTIFIER IS PRIMARY KEY
NESTED TABLE EQUIPAMENTOS STORE AS EQUIPAMENTOS_NT;
/

-- Tabela para Pedidos
CREATE TABLE PEDIDO_TABLE OF tp_Pedido
( PRIMARY KEY (HASH) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Tabela para PagamentoServico
CREATE TABLE PAGAMENTOSERVICO_TABLE OF tp_PagamentoServico
( PRIMARY KEY (ID_PAGSERV) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para PROTOCOLO_SERV em PAGAMENTOSERVICO_TABLE
ALTER TABLE PAGAMENTOSERVICO_TABLE
  MODIFY (PROTOCOLO_SERV SCOPE IS SERVICO_TABLE);
/

-- Tabela para ProtocoloValor
CREATE TABLE PROTOCOLOVALOR_TABLE OF tp_ProtocoloValor
( PRIMARY KEY (ID_PROTOVALOR) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para PROTOCOLO_SERV em PROTOCOLOVALOR_TABLE
ALTER TABLE PROTOCOLOVALOR_TABLE
  MODIFY (PROTOCOLO_SERV SCOPE IS SERVICO_TABLE);
/

-- Tabela para PagamentoPedido
CREATE TABLE PAGAMENTOPEDIDO_TABLE OF tp_PagamentoPedido
( PRIMARY KEY (ID_PAGPEDIDO) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para HASH_PED em PAGAMENTOPEDIDO_TABLE
ALTER TABLE PAGAMENTOPEDIDO_TABLE
  MODIFY (HASH_PED SCOPE IS PEDIDO_TABLE);
/

-- Tabela para Anuncio
CREATE TABLE ANUNCIO_TABLE OF tp_Anuncio
( PRIMARY KEY (URL) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para CHASSI_CAR em ANUNCIO_TABLE
ALTER TABLE ANUNCIO_TABLE
  MODIFY (CHASSI_CAR SCOPE IS CARRO_TABLE);
/

-- Tabela para Solicita
CREATE TABLE SOLICITA_TABLE OF tp_Solicita
( PRIMARY KEY (ID_SOLICITA) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para referências em SOLICITA_TABLE
ALTER TABLE SOLICITA_TABLE
  MODIFY (
    CPF_CLI SCOPE IS CLIENTE_TABLE,
    CPF_FUNC SCOPE IS FUNCIONARIO_TABLE,
    PROTOCOLO_SERV SCOPE IS SERVICO_TABLE
  );
/

-- Tabela para Vende
CREATE TABLE VENDE_TABLE OF tp_Vende
( PRIMARY KEY (ID_VENDE) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para referências em VENDE_TABLE
ALTER TABLE VENDE_TABLE
  MODIFY (
    CHASSI_CAR SCOPE IS CARRO_TABLE,
    HASH_PED SCOPE IS PEDIDO_TABLE,
    CPF_FUNC SCOPE IS FUNCIONARIO_TABLE,
    CPF_CLI SCOPE IS CLIENTE_TABLE
  );
/

-- Tabela para Envolve
CREATE TABLE ENVOLVE_TABLE OF tp_Envolve
( PRIMARY KEY (ID_ENVOLVE) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para referências em ENVOLVE_TABLE
ALTER TABLE ENVOLVE_TABLE
  MODIFY (
    PROTOCOLO_SERV SCOPE IS SERVICO_TABLE,
    ID_EQUIP SCOPE IS EQUIPAMENTO_TABLE
  );
/

-- Tabela para Comenta
CREATE TABLE COMENTA_TABLE OF tp_Comenta
( PRIMARY KEY (ID_COMENTA) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para referências em COMENTA_TABLE
ALTER TABLE COMENTA_TABLE
  MODIFY (
    CPF_CLI SCOPE IS CLIENTE_TABLE,
    CPF_FUNC SCOPE IS FUNCIONARIO_TABLE,
    URL_ANUN SCOPE IS ANUNCIO_TABLE
  );
/

-- Tabela para Responde
CREATE TABLE RESPONDE_TABLE OF tp_Responde
( PRIMARY KEY (ID_RESPONDE) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Ajustar SCOPE para referências em RESPONDE_TABLE
ALTER TABLE RESPONDE_TABLE
  MODIFY (
    CPF_FUNC SCOPE IS FUNCIONARIO_TABLE,
    URL_ANUN SCOPE IS ANUNCIO_TABLE
  );
/

-- Tabela para VendaAudit
CREATE TABLE VENDAAUDIT_TABLE OF tp_VendaAudit
( PRIMARY KEY (ID_AUDIT) )
OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Sequência para ID_AUDIT
CREATE SEQUENCE SEQ_VENDA_AUDIT_ID
START WITH 1
INCREMENT BY 1
NOCACHE;
/

-- ============================================================
-- PT3: ADICIONANDO CONSTRAINTS E CHECKS
-- ============================================================

-- Constraints CHECK para métodos de pagamento
ALTER TABLE PAGAMENTOSERVICO_TABLE
  ADD CONSTRAINT CHK_METODO_PAGSERVICO CHECK (
    METODO IN ('CARTAO', 'DINHEIRO', 'PIX')
  );
/

ALTER TABLE PAGAMENTOPEDIDO_TABLE
  ADD CONSTRAINT CHK_METODO_PAGPEDIDO CHECK (
    METODO IN ('CARTAO', 'DINHEIRO', 'PIX')
  );
/

-- ============================================================
-- PT4: POVOANDO AS TABELAS
-- ============================================================

-- Inserindo CEPs na tabela de CEPs
INSERT INTO CEP_TABLE VALUES (tp_CEP('01000-000', 'Av. Paulista', 'São Paulo', 'SP'));
INSERT INTO CEP_TABLE VALUES (tp_CEP('20000-000', 'Rua do Ouvidor', 'Rio de Janeiro', 'RJ'));
INSERT INTO CEP_TABLE VALUES (tp_CEP('70000-000', 'Esplanada dos Ministérios', 'Brasília', 'DF'));
INSERT INTO CEP_TABLE VALUES (tp_CEP('40000-000', 'Pelourinho', 'Salvador', 'BA'));
INSERT INTO CEP_TABLE VALUES (tp_CEP('60000-000', 'Av. Beira Mar', 'Fortaleza', 'CE'));

-- Inserindo instancias de usuarios
DECLARE
    cep1 REF tp_CEP;
    cep2 REF tp_CEP;
BEGIN
    -- Recuperando referências de CEP
    SELECT REF(c) INTO cep1 FROM CEP_TABLE c WHERE c.CEP = '01000-000';
    SELECT REF(c) INTO cep2 FROM CEP_TABLE c WHERE c.CEP = '20000-000';

    -- Inserindo usuários
    INSERT INTO USUARIO_TABLE VALUES (
        tp_Usuario('123.456.789-00', 'user1@example.com', 'senha123', cep1, 100, tp_Telefones('11999999999', '11888888888'))
    );
    INSERT INTO USUARIO_TABLE VALUES (
        tp_Usuario('987.654.321-00', 'user2@example.com', 'senha456', cep2, 200, tp_Telefones('21999999999'))
    );
    INSERT INTO USUARIO_TABLE VALUES (
        tp_Usuario('555.666.777-88', 'user3@example.com', 'senha789', cep1, 150, tp_Telefones('11999999999', '11777777777'))
    );
    INSERT INTO USUARIO_TABLE VALUES (
        tp_Usuario('999.888.777-66', 'user4@example.com', 'senhaabc', cep2, 250, tp_Telefones('21888888888'))
    );
    INSERT INTO USUARIO_TABLE VALUES (
        tp_Usuario('111.222.333-44', 'user5@example.com', 'senhadef', cep1, 300, tp_Telefones('11999999999', '11888888888', '11777777777'))
    );
END;
/

-- inserindo instancias de clientes
DECLARE
    cep3 REF tp_CEP;
BEGIN
    -- Recuperando referência de CEP
    SELECT REF(c) INTO cep3 FROM CEP_TABLE c WHERE c.CEP = '70000-000';

    -- Inserindo clientes
    INSERT INTO CLIENTE_TABLE VALUES (
        tp_Cliente('444.555.666-77', 'cliente1@example.com', 'senhacliente1', cep3, 500, tp_Telefones('61999999999'), SYSDATE)
    );
    INSERT INTO CLIENTE_TABLE VALUES (
        tp_Cliente('888.999.000-11', 'cliente2@example.com', 'senhacliente2', cep3, 600, tp_Telefones('61988888888'), SYSDATE - 30)
    );
    INSERT INTO CLIENTE_TABLE VALUES (
        tp_Cliente('222.333.444-55', 'cliente3@example.com', 'senhacliente3', cep3, 700, tp_Telefones('61977777777'), SYSDATE - 60)
    );
    INSERT INTO CLIENTE_TABLE VALUES (
        tp_Cliente('999.111.222-33', 'cliente4@example.com', 'senhacliente4', cep3, 800, tp_Telefones('61966666666'), SYSDATE - 90)
    );
    INSERT INTO CLIENTE_TABLE VALUES (
        tp_Cliente('123.321.456-78', 'cliente5@example.com', 'senhacliente5', cep3, 900, tp_Telefones('61955555555'), SYSDATE - 120)
    );
END;
/

-- Inserindo cargos
DECLARE
    cargo1 tp_Cargo := tp_Cargo('Vendedor', 2000);
    cargo2 tp_Cargo := tp_Cargo('Gerente', 6000);
BEGIN
    INSERT INTO CARGO_TABLE VALUES (cargo1);
    INSERT INTO CARGO_TABLE VALUES (cargo2);
END;
/

-- Inserindo funcionarios
DECLARE
    cargo1 REF tp_Cargo;
    cargo2 REF tp_Cargo;
	cep4 REF tp_CEP;
    cep5 REF tp_CEP;
    funcionario1 REF tp_Funcionario;
BEGIN
    -- Recuperando referências de cargos
    SELECT REF(c) INTO cargo1 FROM CARGO_TABLE c WHERE c.CARGO_FUNC = 'Vendedor';
    SELECT REF(c) INTO cargo2 FROM CARGO_TABLE c WHERE c.CARGO_FUNC = 'Gerente';
	SELECT REF(a) INTO cep4 FROM CEP_TABLE a WHERE a.cep = '01000-000';
    SELECT REF(a) INTO cep5 FROM CEP_TABLE a WHERE a.cep = '70000-000';

    -- Inserindo funcionários
    INSERT INTO FUNCIONARIO_TABLE VALUES (
        tp_Funcionario('123.456.789-11', 'funcionario1@example.com', 'senha1', cep4, 101, tp_Telefones('61999999999','61999999799'),
        cargo1, SYSDATE, NULL)
    );
    INSERT INTO FUNCIONARIO_TABLE VALUES (
        tp_Funcionario('987.654.321-99', 'funcionario2@example.com', 'senha2', cep5, 102, tp_Telefones('61998899999','61994499799'),
        cargo2, SYSDATE - 10, NULL)
    );
END;
/

-- Inserindo modelos e marcas
DECLARE
    modelo1 tp_ModeloMarca := tp_ModeloMarca('Fusca', 'Volkswagen');
    modelo2 tp_ModeloMarca := tp_ModeloMarca('Civic', 'Honda');
    modelo3 tp_ModeloMarca := tp_ModeloMarca('Corolla', 'Toyota');
    modelo4 tp_ModeloMarca := tp_ModeloMarca('Palio', 'Fiat');
    modelo5 tp_ModeloMarca := tp_ModeloMarca('Onix', 'Chevrolet');
BEGIN
    INSERT INTO MODELOMARCA_TABLE VALUES (modelo1);
    INSERT INTO MODELOMARCA_TABLE VALUES (modelo2);
    INSERT INTO MODELOMARCA_TABLE VALUES (modelo3);
    INSERT INTO MODELOMARCA_TABLE VALUES (modelo4);
    INSERT INTO MODELOMARCA_TABLE VALUES (modelo5);
END;
/

-- Inserindo carros
DECLARE
    modelo1 REF tp_ModeloMarca;
    modelo2 REF tp_ModeloMarca;
BEGIN
    -- Recuperando referências de modelos e marcas
    SELECT REF(m) INTO modelo1 FROM MODELOMARCA_TABLE m WHERE m.MODELO = 'Fusca';
    SELECT REF(m) INTO modelo2 FROM MODELOMARCA_TABLE m WHERE m.MODELO = 'Civic';

    -- Inserindo carros
    INSERT INTO CARRO_TABLE VALUES (
        tp_Carro('1HGBH41JXMN109186', modelo1, 1975, 15000, 50000, 'Azul')
    );
    INSERT INTO CARRO_TABLE VALUES (
        tp_Carro('2HGBH41JXMN109187', modelo2, 2020, 60000, 15000, 'Preto')
    );
END;
/

-- Inserindo equipamentos
DECLARE
    eq1 tp_Equipamento := tp_Equipamento(1, 'Chave de roda', 'chave com 4 cabeças');
    eq2 tp_Equipamento := tp_Equipamento(2, 'Oleo de motor', 'marca carcomm 10w20s');
    eq3 tp_Equipamento := tp_Equipamento(3, 'Farol', 'Farol de Vidro laminado');
BEGIN
    INSERT INTO EQUIPAMENTO_TABLE VALUES (eq1);
    INSERT INTO EQUIPAMENTO_TABLE VALUES (eq2);
    INSERT INTO EQUIPAMENTO_TABLE VALUES (eq3);
END;
/

-- Inserindo servicos
DECLARE
    equipamentos tp_Equipamentos := tp_Equipamentos(
        tp_Equipamento(2, 'Oleo de motor', 'marca carcomm 10w20s')
    );
    servico1 tp_Servico := tp_Servico('PROTO12345', 'Troca de oleo', equipamentos);
BEGIN
    INSERT INTO SERVICO_TABLE VALUES (servico1);
END;
/

-- Inserindo pedidos
DECLARE
    pedido1 REF tp_Pedido;
    pedido2 REF tp_Pedido;
    pedido3 REF tp_Pedido;
BEGIN
    INSERT INTO PEDIDO_TABLE VALUES (
        tp_Pedido('HASH1234567890', 'Compra', SYSDATE - 5, SYSDATE + 10, 'Em Andamento')
    );

    INSERT INTO PEDIDO_TABLE VALUES (
        tp_Pedido('HASH0987654321', 'Venda', SYSDATE - 10, SYSDATE + 5, 'Concluído')
    );

    INSERT INTO PEDIDO_TABLE VALUES (
        tp_Pedido('HASH1122334455', 'Troca', SYSDATE - 3, SYSDATE + 7, 'Cancelado')
    );

    -- Recuperar referências dos pedidos inseridos
    SELECT REF(p) INTO pedido1 FROM PEDIDO_TABLE p WHERE p.HASH = 'HASH1234567890';
    SELECT REF(p) INTO pedido2 FROM PEDIDO_TABLE p WHERE p.HASH = 'HASH0987654321';
    SELECT REF(p) INTO pedido3 FROM PEDIDO_TABLE p WHERE p.HASH = 'HASH1122334455';

END;
/


-- inserindo pagamentoservicos *NÃO ESTÁ FUNCIONANDO*
DECLARE
    servico1 REF tp_Servico;
BEGIN
    INSERT INTO PAGAMENTOSERVICO_TABLE VALUES (
        tp_PagamentoServico(1, servico1, 101, 'Cartão de Crédito')
    );
END;
/

-- Inserir Protocolo Valor
DECLARE
    servico1 REF tp_Servico;
BEGIN
    INSERT INTO PROTOCOLOVALOR_TABLE VALUES (
        tp_ProtocoloValor(1, servico1, 200.00)
    );
    INSERT INTO PROTOCOLOVALOR_TABLE VALUES (
        tp_ProtocoloValor(2, servico1, 350.00)
    );
END;
/

-- Inserir Pagamento pedido
DECLARE
    pedido1 REF tp_Pedido;
BEGIN
    INSERT INTO PAGAMENTOPEDIDO_TABLE VALUES (
        tp_PagamentoPedido(1, pedido1, 201, 'Cartão de Crédito', 1500.00)
    );
END;
/

-- Inserir Anuncio
DECLARE
    carro1 REF tp_Carro;
    anuncio1 REF tp_Anuncio;
BEGIN
    INSERT INTO ANUNCIO_TABLE VALUES (
        tp_Anuncio('http://example.com/anuncio1', carro1)
    );

    INSERT INTO ANUNCIO_TABLE VALUES (
        tp_Anuncio('http://example.com/anuncio2', carro1)
    );

    INSERT INTO ANUNCIO_TABLE VALUES (
        tp_Anuncio('http://example.com/anuncio3', carro1)
    );

    -- Recuperar referências dos anúncios inseridos
    SELECT REF(a) INTO anuncio1 FROM ANUNCIO_TABLE a WHERE a.URL = 'http://example.com/anuncio1';
END;
/

-- inserir Solicita
DECLARE
    cliente1 REF tp_Cliente;
    funcionario1 REF tp_Funcionario;
    servico1 REF tp_Servico;
    solicita1 REF tp_Solicita;
BEGIN
    INSERT INTO SOLICITA_TABLE VALUES (
        tp_Solicita(1, cliente1, funcionario1, servico1)
    );

    INSERT INTO SOLICITA_TABLE VALUES (
        tp_Solicita(2, cliente1, funcionario1, servico1)
    );

    INSERT INTO SOLICITA_TABLE VALUES (
        tp_Solicita(3, cliente1, funcionario1, servico1)
    );

    -- Recuperar referências das solicitações inseridas
    SELECT REF(s) INTO solicita1 FROM SOLICITA_TABLE s WHERE s.ID_SOLICITA = 1;
END;
/

--inserir vende
DECLARE
    carro1 REF tp_Carro;
    pedido1 REF tp_Pedido;
    funcionario1 REF tp_Funcionario;
    cliente1 REF tp_Cliente;
    vende1 REF tp_Vende;
BEGIN
    INSERT INTO VENDE_TABLE VALUES (
        tp_Vende(1, carro1, pedido1, funcionario1, cliente1)
    );

    INSERT INTO VENDE_TABLE VALUES (
        tp_Vende(2, carro1, pedido1, funcionario1, cliente1)
    );

    INSERT INTO VENDE_TABLE VALUES (
        tp_Vende(3, carro1, pedido1, funcionario1, cliente1)
    );

    -- Recuperar referências das vendas inseridas
    SELECT REF(v) INTO vende1 FROM VENDE_TABLE v WHERE v.ID_VENDE = 1;
END;
/

--inserir envolve 
DECLARE
    servico1 REF tp_Servico;
    equipamento1 REF tp_Equipamento;
    envolve1 REF tp_Envolve;
BEGIN
    INSERT INTO ENVOLVE_TABLE VALUES (
        tp_Envolve(1, servico1, equipamento1)
    );

    INSERT INTO ENVOLVE_TABLE VALUES (
        tp_Envolve(2, servico1, equipamento1)
    );

    INSERT INTO ENVOLVE_TABLE VALUES (
        tp_Envolve(3, servico1, equipamento1)
    );

    -- Recuperar referências dos envolvimentos inseridos
    SELECT REF(e) INTO envolve1 FROM ENVOLVE_TABLE e WHERE e.ID_ENVOLVE = 1;
END;
/

-- inserir comenta 
DECLARE
    cliente1 REF tp_Cliente;
    funcionario1 REF tp_Funcionario;
    anuncio1 REF tp_Anuncio;
    comenta1 REF tp_Comenta;
BEGIN
    INSERT INTO COMENTA_TABLE VALUES (
        tp_Comenta(1, cliente1, funcionario1, anuncio1, 'Comentário 1', SYSDATE)
    );

    INSERT INTO COMENTA_TABLE VALUES (
        tp_Comenta(2, cliente1, funcionario1, anuncio1, 'Comentário 2', SYSDATE)
    );

    INSERT INTO COMENTA_TABLE VALUES (
        tp_Comenta(3, cliente1, funcionario1, anuncio1, 'Comentário 3', SYSDATE)
    );

    -- Recuperar referências dos comentários inseridos
    SELECT REF(c) INTO comenta1 FROM COMENTA_TABLE c WHERE c.ID_COMENTA = 1;
END;
/

-- inserir responde
DECLARE
    funcionario1 REF tp_Funcionario;
    anuncio1 REF tp_Anuncio;
    responde1 REF tp_Responde;
BEGIN
    INSERT INTO RESPONDE_TABLE VALUES (
        tp_Responde(1, funcionario1, anuncio1, SYSDATE, 'Resposta 1')
    );

    INSERT INTO RESPONDE_TABLE VALUES (
        tp_Responde(2, funcionario1, anuncio1, SYSDATE, 'Resposta 2')
    );

    INSERT INTO RESPONDE_TABLE VALUES (
        tp_Responde(3, funcionario1, anuncio1, SYSDATE, 'Resposta 3')
    );

    -- Recuperar referências das respostas inseridas
    SELECT REF(r) INTO responde1 FROM RESPONDE_TABLE r WHERE r.ID_RESPONDE = 1;
END;
/

--inserir vendas 
DECLARE
    carro1 REF tp_Carro;
    pedido1 REF tp_Pedido;
    funcionario1 REF tp_Funcionario;
    cliente1 REF tp_Cliente;
    vendaAudit1 REF tp_VendaAudit;
BEGIN
    INSERT INTO VENDAAUDIT_TABLE VALUES (
        tp_VendaAudit(1, carro1, pedido1, funcionario1, 'Funcionario 1', cliente1, 'Cliente 1', 1500.00, SYSDATE)
    );

    INSERT INTO VENDAAUDIT_TABLE VALUES (
        tp_VendaAudit(2, carro1, pedido1, funcionario1, 'Funcionario 2', cliente1, 'Cliente 2', 2500.00, SYSDATE)
    );

    INSERT INTO VENDAAUDIT_TABLE VALUES (
        tp_VendaAudit(3, carro1, pedido1, funcionario1, 'Funcionario 3', cliente1, 'Cliente 3', 3000.00, SYSDATE)
    );

    -- Recuperar referências das auditorias de venda inseridas
    SELECT REF(v) INTO vendaAudit1 FROM VENDAAUDIT_TABLE v WHERE v.ID_AUDIT = 1;
END;
/
