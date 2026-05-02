SELECT
  LE.IDCLIFOR                                       AS CLI_FK_680,
  LE.IDLOCALENTREGA                                 AS COD_END_ERP,
  LE.BAIRROENTREGA                                  AS BAIRRO,
  CI.DESCRCIDADE                                    AS CIDADE,
  LE.UFENTREGA                                      AS UF,
  LE.CEPENTREGA                                     AS CEP,
  LE.ENDERECOENTREGA                                AS END,
  '0'                                               AS COD_PRACA_ERP,
  LE.NUMERO                                         AS NUM_END,
  LE.OBSERVACAO                                     AS REF_ENTREGA,
  'S'                                               AS SN_PADRAO,
  COALESCE(NULLIF(TRIM(LE.LONGITUDE), ''), '1000')  AS LONGITUDE,
  COALESCE(NULLIF(TRIM(LE.LATITUDE), ''), '1000')   AS LATITUDE
FROM DBA.LOCAL_ENTREGA LE
LEFT JOIN DBA.CIDADES_IBGE CI
  ON CI.IDCIDADE = LE.IDCIDADE_ENTREGA
WHERE LE.IDCLIFOR = :CLIENTE
  AND LE.IDLOCALENTREGA = :COD_END;