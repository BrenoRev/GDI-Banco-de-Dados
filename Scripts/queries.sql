-- SQL --
-- SQL --
-- SQL --
-- SQL --
-- SQL --

-- 1 e 6
-- ALTER TABLE
-- SELECT FROM WHERE
-- Adicionar última atualização a Carro
ALTER TABLE Carro
ADD ultima_atualizacao DATE DEFAULT SYSDATE;
/
CREATE OR REPLACE TRIGGER trg_update_ultima_atualizacao
BEFORE UPDATE ON Carro
FOR EACH ROW
BEGIN
    :NEW.ultima_atualizacao := SYSDATE;
END trg_update_ultima_atualizacao;
/
DECLARE
    v_chassi Carro.chassi%TYPE := '1HGBH41JXMN109186';
	v_preco Carro.preco%TYPE := 75000.0;
    v_ultima_atualizacao Carro.ultima_atualizacao%TYPE;
BEGIN
    UPDATE Carro SET preco = v_preco WHERE chassi = v_chassi;
    SELECT ultima_atualizacao INTO v_ultima_atualizacao FROM Carro WHERE chassi = v_chassi;
    DBMS_OUTPUT.PUT_LINE('ultima_atualizacao: ' || TO_CHAR(v_ultima_atualizacao, 'YYYY-MM-DD'));
END;
/

-- 2
-- CREATE_INDEX
CREATE INDEX idx_carro_preco
ON Carro(preco);
/

-- 5
-- DELETE
DELETE FROM Telefone WHERE cpf_usu = '21784356298';
DELETE FROM Cliente WHERE cpf_usu = '21784356298';
DELETE FROM Usuario WHERE cpf = '21784356298';
/

-- 7
-- BETWEEN
SELECT chassi, modelo_mc, preco
FROM Carro
WHERE preco BETWEEN 80000 AND 90000;
/

-- 8
-- IN
SELECT chassi, modelo_mc, ano
FROM Carro
WHERE ano IN (2019, 2020);
/

-- 9
-- LIKE
SELECT chassi, modelo_mc, preco
FROM Carro
WHERE modelo_mc LIKE 'C%';
/

-- 10
-- IS NULL ou IS NOT NULL
SELECT cpf, numero FROM Usuario WHERE numero IS NOT NULL;
/

-- 11
-- INNER JOIN
SELECT f.cpf_usu, f.cargo_func, c.salario
FROM Funcionario f
INNER JOIN Cargo c ON f.cargo_func = c.cargo_func;
/

-- 12
-- MAX
SELECT MAX(salario) AS maior_salario
FROM Cargo;
/

-- 13
-- MIN
SELECT MIN(salario) AS menor_salario
FROM Cargo;
/

-- 14
-- AVG
SELECT AVG(salario) AS media_salario_novos
FROM Funcionario f
JOIN Cargo c ON f.cargo_func = c.cargo_func
WHERE f.data_de_contratacao > TO_DATE('2020-01-01', 'YYYY-MM-DD');
/

-- 15
-- COUNT
SELECT COUNT(DISTINCT cargo_func)
FROM Funcionario;
/

-- 16
-- LEFT ou RIGHT ou FULL OUTER JOIN
SELECT f.cpf_usu, f.cargo_func, c.salario
FROM Funcionario f
LEFT JOIN Cargo c ON f.cargo_func = c.cargo_func;
/

SELECT f.cpf_usu, f.cargo_func, c.salario
FROM Funcionario f
RIGHT JOIN Cargo c ON f.cargo_func = c.cargo_func;
/

SELECT f.cpf_usu, f.cargo_func, c.salario
FROM Funcionario f
FULL OUTER JOIN Cargo c ON f.cargo_func = c.cargo_func;
/

-- 17
-- SUBCONSULTA COM OPERADOR RELACIONAL
SELECT f.cpf_usu, f.cargo_func, c.salario
FROM Funcionario f
JOIN Cargo c ON f.cargo_func = c.cargo_func
WHERE c.salario < (
    SELECT MAX(c2.salario)
    FROM Cargo c2
);
/

-- 18
-- SUBCONSULTA COM IN
SELECT cpf_usu, cargo_func
FROM Funcionario
WHERE cargo_func IN (
    SELECT cargo_func
    FROM Cargo
    WHERE salario BETWEEN 3000 AND 5000
);
/

-- 19
-- SUBCONSULTA COM ANY
SELECT f.cpf_usu, f.cargo_func, c.salario, f.data_de_contratacao
FROM Funcionario f
JOIN Cargo c ON f.cargo_func = c.cargo_func
WHERE c.salario > ANY (
    SELECT c2.salario
    FROM Funcionario f2
    JOIN Cargo c2 ON f2.cargo_func = c2.cargo_func
    WHERE c2.cargo_func = 'VENDEDOR'
    AND f2.data_de_contratacao < TO_DATE('2025-01-01', 'YYYY-MM-DD')
);
/

-- 20
-- SUBCONSULTA COM ALL
SELECT modelo_mc, preco
FROM Carro
WHERE preco > ALL (
    SELECT preco
    FROM Carro
    WHERE modelo_mc = 'Toyota'
);
/

-- 21
-- ORDER BY
-- lista os telefone do maior para o menor
SELECT
    *
FROM
    TELEFONE
ORDER BY
    NUM_TELEFONE DESC;

-- 22
-- GROUP BY + COUNT
-- lista todas quantidade de pedidos por status
SELECT
    STATUS,
    COUNT(*) AS QTD
FROM
    PEDIDO
GROUP BY
    STATUS;

-- 23
-- HAVING
-- lista todas quantidade de pedidos maiores que 1 (having + count)
SELECT
    STATUS,
    COUNT(*) AS QTD
FROM
    PEDIDO
GROUP BY
    STATUS
HAVING
    COUNT(*) > 1;

-- 23
-- INTERSECT
-- lista quais tipos de serviços já geraram um pagamento de servico
SELECT
    PROTOCOLO_SERV
FROM
    PAGAMENTOSERVICO INTERSECT
    SELECT
        PROTOCOLO
    FROM
        SERVICO;

-- 24
-- CREATE VIEW
-- cria uma view com o nome da rua e cpf de cada usuario (create view)
CREATE VIEW MORA AS
    SELECT
        U.CPF,
        C.RUA
    FROM
        USUARIO U,
        CEP     C
    WHERE
        C.CEP = U.CEP;

-- 25
-- GRANT
-- garantindo todos privilegios para todos (usuarios do sistema) sobre a tabela usuario
GRANT ALL PRIVILEGES ON USUARIO TO PUBLIC;

-- 26
-- REVOKE
-- removendo todos os privilegios de todos (usuarios do sistema) sobre a tabela usuario
REVOKE ALL PRIVILEGES ON USUARIO TO PUBLIC;

-- PL --
-- PL --
-- PL --
-- PL --
-- PL --
-- OBS: Alguns elementos estão incluídos no código de outros
-- (o elemento não ter código separado não significa que não utilizamos)


-- 1
-- RECORD
-- print do email cadastrado ao cpf - 62269750160
<<record_>> 
declare
    type cliente_type is record (
    	cpf usuario.cpf%type,
    	email usuario.email%type
    );

	cliente cliente_type;
begin
	select cpf, email into cliente from usuario
	where cpf = 62269750160; 

	dbms_output.put_line(cliente.cpf || ' | ' || cliente.email); -- printa o resultado
end record_;
/

-- 2
-- TABLE DS 
DECLARE
    TYPE funcionario_type IS RECORD (
        cpf     VARCHAR2(14),
        cargo   VARCHAR2(50),
        salario NUMBER
    );

    TYPE funcionario_table_type IS TABLE OF funcionario_type INDEX BY VARCHAR2(14);
	element VARCHAR2(100);

    funcionarios funcionario_table_type;
    CURSOR c_funcionarios IS
        SELECT f.cpf_usu, c.cargo_func, c.salario
        FROM FUNCIONARIO f
        JOIN CARGO c ON f.cargo_func = c.cargo_func
        WHERE c.cargo_func = 'GERENTE';

BEGIN
    FOR func_rec IN c_funcionarios LOOP
        funcionarios(func_rec.cpf_usu).cpf := func_rec.cpf_usu;
        funcionarios(func_rec.cpf_usu).cargo := func_rec.cargo_func;
        funcionarios(func_rec.cpf_usu).salario := func_rec.salario;
    END LOOP;

    IF funcionarios.COUNT > 0 THEN
        element := funcionarios.FIRST;
        WHILE element IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE('CPF Gerente: ' || element);
            element := funcionarios.NEXT(element);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table vazia.');
    END IF;
END;
/

-- 6
-- TYPE
-- print do modelo de carro disponivel dado a marca
<<type_>>
declare
	modelo modelomarca.modelo%TYPE; 
	marca modelomarca.modelo%TYPE; 
begin
	select modelo, marca into modelo, marca from modelomarca
	where marca = 'Ford'; 

	dbms_output.put_line('modelo: ' || modelo); -- printa o resultado
end type_;
/

-- 7
-- ROWTYPE
-- print do email cadastrado ao cpf - 62269750160 (%ROWTYPE) [mesma função feita antes porém com %rowtype]
<<rowtype_>>
declare
	cliente usuario%ROWTYPE; 
begin
	select * into cliente from usuario
	where cpf = 62269750160; 

	dbms_output.put_line(cliente.cpf || ' | ' || cliente.email); -- printa o resultado
end rowtype_;
/

-- 8
-- IF ELSE IF
-- print em qual tipo de frete se encaixa o dado cpf
<<ifelseif_>>
declare
    cliente usuario.cpf%TYPE;
    cep_novo usuario.cep%TYPE;
    estado cep.estado%TYPE;
begin
    select cpf, cep into cliente, cep_novo from usuario
    where cpf = 04084917010;

    select estado into estado from cep
    where cep = cep_novo;

    if estado = 'PE' then
    	dbms_output.put_line(cliente || ' | ' || estado || ' - Frete gratuito'); -- printa o resultado
    elsif estado = 'SP' then
    	dbms_output.put_line(cliente || ' | ' || estado || ' - Frete gratuito'); -- printa o resultado
    else
    	dbms_output.put_line(cliente || ' | ' || estado || ' - Frete inclui taxas extras'); -- printa o resultado
    end if;
	
end ifelseif_;
/

-- 9
-- CASE WHEN
-- print em qual tipo de frete se encaixa o dado cpf
<<casewhen_>>
declare
    cliente usuario.cpf%TYPE;
    cep_novo usuario.cep%TYPE;
    estado cep.estado%TYPE;
begin
    select cpf, cep into cliente, cep_novo from usuario
    where cpf = 36274310495;

    select estado into estado from cep
    where cep = cep_novo;

	case estado
        when 'PE' then
        dbms_output.put_line(cliente || ' | ' || estado || ' - Frete gratuito'); -- printa o resultado
		when 'SP' then
        dbms_output.put_line(cliente || ' | ' || estado || ' - Frete gratuito'); -- printa o resultado
		else
        dbms_output.put_line(cliente || ' | ' || estado || ' - Frete inclui taxas extras'); -- printa o resultado
    end case;
	
end casewhen_;
/

-- 11
-- WHILE
-- Procura usuario baseado no seu numero de telefone
<<whileloop_>>
declare
    cpf_novo telefone.cpf_usu%TYPE;
    telefone_novo telefone.num_telefone%TYPE;

    CURSOR c1 IS 
    SELECT CPF_USU, NUM_TELEFONE FROM TELEFONE;

BEGIN
    OPEN c1; -- Abre o cursor
    
    FETCH c1 INTO cpf_novo, telefone_novo; -- Busca a primeira linha
    
    WHILE c1%FOUND LOOP -- Enquanto houver registros

		if telefone_novo = 978274156 then
    		dbms_output.put_line(cpf_novo || ' | ' || telefone_novo || ' - USUARIO ENCONTRADO'); -- printa o resultado
        else
        	dbms_output.put_line('------'); -- printa o resultado
        end if;

        FETCH c1 INTO cpf_novo, telefone_novo; -- Busca a próxima linha
    END LOOP;
    
    CLOSE c1; -- Fecha o cursor
END whileloop_;

-- 14
-- CURSOR (OPEN, FETCH, CLOSE)
-- Printar usuários ordenados por data de adesão
DECLARE
    v_cpf_usu Cliente.cpf_usu%TYPE;
    v_data_de_adesao Cliente.data_de_adesao%TYPE;

    CURSOR cliente_cursor IS
        SELECT cpf_usu, data_de_adesao 
        FROM Cliente
        ORDER BY data_de_adesao;

BEGIN
    OPEN cliente_cursor;

    LOOP
        FETCH cliente_cursor INTO v_cpf_usu, v_data_de_adesao;
        EXIT WHEN cliente_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('CPF: ' || v_cpf_usu || ', Adesao: ' || TO_CHAR(v_data_de_adesao, 'YYYY-MM-DD'));
    END LOOP;

    CLOSE cliente_cursor;
END;
/

-- 15
-- EXCEPTION WHEN
-- Tentando inserir cliente duplicado
BEGIN
    INSERT INTO Cliente (cpf_usu, data_de_adesao) VALUES ('84448753689', TO_DATE('2023-10-30', 'YYYY-MM-DD'));

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERRO: Cliente já cadastrado.');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);

END;
/

-- 16
-- IN, OUT, IN OUT
-- Atualizando preço de um carro
CREATE OR REPLACE PROCEDURE atualiza_preco_carro(
    p_chassi IN Carro.chassi%TYPE,
    p_preco_novo IN OUT Carro.preco%TYPE
) IS
BEGIN
    UPDATE Carro
    SET preco = p_preco_novo
    WHERE chassi = p_chassi;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Falha! O carro com chassi ' || p_chassi || ' não existe.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
END;
/
DECLARE
    v_chassi Carro.chassi%TYPE := '1HGBH41JXMN109186';
    v_preco_novo Carro.preco%TYPE := 90000.00;
    v_preco_antigo Carro.preco%TYPE;
    v_preco Carro.preco%TYPE;
BEGIN
    SELECT preco INTO v_preco_antigo FROM Carro WHERE chassi = v_chassi;
    DBMS_OUTPUT.PUT_LINE('Antes de atualizar: ' || v_preco_antigo);
    atualiza_preco_carro(v_chassi, v_preco_novo);
    SELECT preco INTO v_preco FROM Carro WHERE chassi = v_chassi;
    DBMS_OUTPUT.PUT_LINE('Novo preço: ' || v_preco);
END;
/

-- 17
-- CREATE OR REPLACE PACKAGE
CREATE OR REPLACE PACKAGE Carro_Info IS
    PROCEDURE atualiza_preco_carro(
        p_chassi IN Carro.chassi%TYPE,
        p_preco_novo IN OUT Carro.preco%TYPE
    );

    FUNCTION ver_preco_carro(
        p_chassi IN Carro.chassi%TYPE
    ) RETURN Carro.preco%TYPE;

    FUNCTION ver_detalhes_carro(
        p_chassi IN Carro.chassi%TYPE
    ) RETURN VARCHAR2;
END Carro_Info;
/

-- 4, 5, 18
-- CREATE OR REPLACE PACKAGE BODY, PROCEDURE, FUNCTION
CREATE OR REPLACE PACKAGE BODY Carro_Info IS
    PROCEDURE atualiza_preco_carro(
        p_chassi IN Carro.chassi%TYPE,
        p_preco_novo IN OUT Carro.preco%TYPE
    ) IS
    BEGIN
        UPDATE Carro
        SET preco = p_preco_novo
        WHERE chassi = p_chassi;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Falha! O carro com chassi ' || p_chassi || ' não existe.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    END atualiza_preco_carro;

    FUNCTION ver_preco_carro(
        p_chassi IN Carro.chassi%TYPE
    ) RETURN Carro.preco%TYPE IS
        v_preco Carro.preco%TYPE;
    BEGIN
        SELECT preco INTO v_preco FROM Carro WHERE chassi = p_chassi;
        RETURN v_preco;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END ver_preco_carro;

    FUNCTION ver_detalhes_carro(
        p_chassi IN Carro.chassi%TYPE
    ) RETURN VARCHAR2 IS
        v_info VARCHAR2(200);
    BEGIN
        SELECT 'Veículo: ' || modelo_mc || '-' || ano || ' | Cor: ' || cor || ' | Km: ' || km
        INTO v_info
        FROM Carro
        WHERE chassi = p_chassi;

        RETURN v_info;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Carro não encontrado';
        WHEN OTHERS THEN
            RETURN 'Não foi possível verificar detalhes do carro';
    END ver_detalhes_carro;
END Carro_Info;
/
DECLARE
    v_chassi Carro.chassi%TYPE := '1HGBH41JXMN109186';
    v_preco_novo Carro.preco%TYPE := 87250.00;
    v_preco_atual Carro.preco%TYPE;
    v_detalhes_carro VARCHAR2(200);
BEGIN
    v_detalhes_carro := Carro_Info.ver_detalhes_carro(v_chassi);
    DBMS_OUTPUT.PUT_LINE('Detalhes do carro: ' || v_detalhes_carro);

    v_preco_atual := Carro_Info.ver_preco_carro(v_chassi);
    DBMS_OUTPUT.PUT_LINE('Preço atual: ' || v_preco_atual);

    Carro_Info.atualiza_preco_carro(v_chassi, v_preco_novo);
    DBMS_OUTPUT.PUT_LINE('Preço ajustado: ' || v_preco_novo);
END;
/

-- 19
-- CREATE OR REPLACE TRIGGER (COMANDO)
CREATE OR REPLACE TRIGGER trg_audit_venda_comando
AFTER INSERT ON Vende
DECLARE
    v_nome_func VARCHAR2(100);
    v_nome_cli VARCHAR2(100);
    v_valor_total NUMBER;
BEGIN
    -- Loop para capturar os dados de cada venda inserida
    FOR r IN (SELECT v.chassi_car, v.hash_ped, v.cpf_func, v.cpf_cli, p.valor
              FROM Vende v
              JOIN PagamentoPedido p ON v.hash_ped = p.hash_ped) LOOP
              
        -- Obter nome do funcionário
        SELECT u.email INTO v_nome_func
        FROM Usuario u
        WHERE u.cpf = r.cpf_func;

        -- Obter nome do cliente
        SELECT u.email INTO v_nome_cli
        FROM Usuario u
        WHERE u.cpf = r.cpf_cli;

        -- Inserir registro na tabela de auditoria
        INSERT INTO VendaAudit (id_audit, chassi_car, hash_ped, cpf_func, nome_func, cpf_cli, nome_cli, valor_total, data_venda)
        VALUES (SEQ_VENDA_AUDIT_ID.NEXTVAL, r.chassi_car, r.hash_ped, r.cpf_func, v_nome_func, r.cpf_cli, v_nome_cli, r.valor, SYSDATE);
    END LOOP;
END;
/

-- Test
-- INSERT INTO Vende (chassi_car, hash_ped, cpf_func, cpf_cli) VALUES ('1HGBH41JXMN109186', '4a1e45d6f63a4d8b9aafad0c3ec4e8cd', '04084917010', '16307696575');

-- 20
-- CREATE OR REPLACE TRIGGER (LINHA)
CREATE OR REPLACE TRIGGER trg_validacao_carro
BEFORE UPDATE ON Carro
FOR EACH ROW
BEGIN
    -- Validação do preço: não pode ser reduzido para menos de 80% do valor anterior
    IF :OLD.preco IS NOT NULL AND :NEW.preco < (:OLD.preco * 0.8) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Tentativa de reduzir o preço para menos de 80% do valor anterior.');
    END IF;
END;
/

-- Test
-- UPDATE Carro SET preco = 75000 WHERE chassi = '1HGBH41JXMN109186';
