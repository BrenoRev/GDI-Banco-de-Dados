-- SELECT REF + DEREF
-- Printando Endereços de forma estruturada
DECLARE
  cep_ref REF tp_CEP;
  cep_obj tp_CEP; 
BEGIN
  FOR rec IN (SELECT REF(e) AS cep_ref FROM CEP_TABLE e) LOOP
    SELECT DEREF(rec.cep_ref) INTO cep_obj FROM DUAL;

    cep_obj.display_info;
  END LOOP;
END;
/

-- Printando top-3 clientes mais antigos
DECLARE
  cli_ref REF tp_Cliente;
  cli_obj tp_Cliente; 
BEGIN
  FOR rec IN (SELECT REF(c) AS cli_ref FROM CLIENTE_TABLE c ORDER BY c.DATA_DE_ADESAO FETCH FIRST 3 ROWS ONLY) LOOP
    SELECT DEREF(rec.cli_ref) INTO cli_obj FROM DUAL;

    cli_obj.display_info;
  END LOOP;
END;
/

-- Printando funcionario mais antigo
DECLARE
  func_ref REF tp_Funcionario;
  func_obj tp_Funcionario; 
BEGIN
  FOR rec IN (SELECT REF(c) AS func_ref FROM FUNCIONARIO_TABLE c ORDER BY c.DATA_DE_CONTRATACAO FETCH FIRST 1 ROWS ONLY) LOOP
    SELECT DEREF(rec.func_ref) INTO func_obj FROM DUAL;

    func_obj.display_info;
  END LOOP;
END;
/

-- Printando o valor total a ser pago aos funcionários
DECLARE
  total_salario NUMBER;
BEGIN
  SELECT SUM(c.SALARIO) INTO total_salario 
  FROM CARGO_TABLE c;

  DBMS_OUTPUT.PUT_LINE('O valor devido aos funcionários é R$ ' || total_salario);
END;
/

-- Printando de forma estruturada as informações do carro mais caro
DECLARE
  carro_mais_caro REF tp_Carro; 
  carro_obj tp_Carro;
BEGIN
  SELECT REF(c)
  INTO carro_mais_caro
  FROM CARRO_TABLE c
  WHERE c.PRECO = (SELECT MAX(c2.PRECO) FROM CARRO_TABLE c2);

  SELECT DEREF(carro_mais_caro) INTO carro_obj FROM DUAL;
  carro_obj.display_info;
END;
/

-- Consultando clientes com mais de um telefone
SELECT u.CPF, u.EMAIL, COUNT(t.COLUMN_VALUE) AS Qtd_Telefones
FROM USUARIO_TABLE u, TABLE(u.TELEFONES) t
GROUP BY u.CPF, u.EMAIL
HAVING COUNT(t.COLUMN_VALUE) > 1;
/

-- Calculando a média salarial por cargo
SELECT DEREF(f.CARGO_FUNC).CARGO_FUNC AS Cargo_Func, 
       AVG(DEREF(f.CARGO_FUNC).SALARIO) AS Media_Salario
FROM FUNCIONARIO_TABLE f
GROUP BY DEREF(f.CARGO_FUNC).CARGO_FUNC;
/

-- Consultando funcionários contratados nos últimos 5 anos
SELECT f.CPF, f.DATA_DE_CONTRATACAO
FROM FUNCIONARIO_TABLE f
WHERE f.DATA_DE_CONTRATACAO >= ADD_MONTHS(SYSDATE, -60);
/

-- Printando top-5 funcionários mais bem pagos
DECLARE
  func_ref REF tp_Funcionario;
  func_obj tp_Funcionario;
BEGIN
  FOR rec IN (SELECT REF(f) AS func_ref FROM FUNCIONARIO_TABLE f ORDER BY DEREF(f.CARGO_FUNC).SALARIO DESC FETCH FIRST 5 ROWS ONLY) LOOP
    SELECT DEREF(rec.func_ref) INTO func_obj FROM DUAL;

    func_obj.display_info;
  END LOOP;
END;
/

-- CONSULTA À VARRAY
-- Pritando telefones do usuário 111.222.333-44
SELECT u.CPF, u.EMAIL, t.COLUMN_VALUE AS Telefone
FROM USUARIO_TABLE u, TABLE(u.TELEFONES) t 
WHERE u.CPF = '111.222.333-44';
/

-- CONSULTA À NESTED TABLE
-- Printando Serviços
SELECT s.PROTOCOLO, e.*
FROM SERVICO_TABLE s,
     TABLE(s.EQUIPAMENTOS) e;