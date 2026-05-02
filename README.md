# Integração CISS ERP → Fusion DMS

Este repositório contém customizações SQL e configuração de integração para adaptar dados do ERP CISS ao formato esperado pelo Fusion DMS.

O objetivo principal é expor informações de produtos, entregas, itens de entrega e endereços alternativos por meio de views DB2 e consultas configuradas no `viewDados.xml`, permitindo que o Fusion consuma os dados do ERP de forma padronizada.

## Contexto

O Fusion DMS consome dados por meio de consultas configuradas em XML, onde cada entrada representa uma fonte lógica de dados, como `PRODUTO`, `ENTREGA`, `ENTREGA_ITEM`, `CLIENTE`, `VEICULO`, `MOTORISTA` e outras.

Este projeto concentra as adaptações necessárias para que os dados originados no banco DB2 do CISS sejam apresentados com os nomes de campos, aliases e filtros esperados pelo Fusion.

## Banco de dados

As views foram escritas para IBM DB2, usando o schema `FUSIONT` como camada de integração e tabelas do schema `DBA` como origem dos dados do ERP CISS.

## Permissões

Após criar as views, conceda permissão de leitura ao usuário utilizado pelo Fusion.

Exemplo:

```sql
GRANT SELECT ON TABLE FUSIONT.FUSION_VW_PRODUTO TO USER FUSIONT;
GRANT SELECT ON TABLE FUSIONT.FUSION_VW_ENTREGA_ITEM TO USER FUSIONT;
```

## Regra de endereço alternativo

A integração segue a seguinte lógica operacional:

```text
Verificar código de endereço alternativo na entrega

Se COD_END_ALT_ERP = 0:
    usar endereço do cadastro principal do cliente

Se COD_END_ALT_ERP <> 0:
    buscar endereço na tabela de endereços alternativos/local de entrega
```

No CISS, os endereços alternativos são obtidos a partir de `DBA.LOCAL_ENTREGA`, com complemento de cidade em `DBA.CIDADES_IBGE`.

## Chave de produto/subproduto

O Fusion pode trabalhar com mercadoria no formato:

```text
idproduto@idsubproduto
```

Por isso, a view de itens de entrega monta o campo `MERC_PF_687` concatenando `IDPRODUTO` e `IDSUBPRODUTO`.

Essa regra é importante para evitar perda de precisão quando o produto possui grade ou subproduto no ERP.

## Observações importantes

- As views foram feitas para atender ao layout esperado pelo Fusion, portanto muitos aliases seguem nomenclatura interna do DMS.
- Alguns campos possuem valores fixos ou fallback para manter compatibilidade com o layout.
- Latitude e longitude podem ser mantidas como texto, conforme o formato existente no CISS e esperado pela integração.
- Antes de aplicar em produção, valide os filtros usados pelo Fusion para confirmar se os parâmetros recebidos são `:PRODUTO`, `:MERCADORIA`, `:CLIENTE`, `:COD_END`, `:PARAM` ou equivalentes no ambiente instalado.

## Fluxo geral da integração

## Validação

Após aplicar as views, recomenda-se testar manualmente as consultas principais:

```sql
SELECT *
FROM FUSIONT.FUSION_VW_PRODUTO
WHERE MERC_PK_461 = <IDPRODUTO>
  AND EMPRESA_PF_468 = <IDEMPRESA>;

SELECT *
FROM FUSIONT.FUSION_VW_ENTREGA_ITEM
WHERE IDPLANILHA = <IDPLANILHA>;
```

## Status

Projeto de integração/customização para ambiente CISS ERP + Fusion DMS.

Use com validação em homologação antes de aplicar em produção.
