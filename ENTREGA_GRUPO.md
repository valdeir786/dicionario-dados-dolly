# Entrega do Grupo 03 — situação em 11/11/2026

Site: https://carlosjb7.github.io/dicionario-dados-dolly/
Repositório: https://github.com/carlosjb7/dicionario-dados-dolly

## Arquivos preparados

- `index.html`, `style.css` e `script.js`: dicionário interativo baseado no DDL, com 19 tabelas e 115 atributos.
- `docs/ddl_original.sql`: DDL preservado; referência para tipos, chaves, CHECKs e demais constraints.
- `docs/Especificacao_Requisitos_Regras_Negocio_BD.pdf`: AT2 enviada nesta conversa.
- `assets/der.png` e `docs/dolly_vendas.mwb`: DER exportado diretamente do MySQL Workbench 8.0.47 e modelo editável.
- `docs/CONFERENCIA_AT2.md`: lista das divergências que ainda precisam de decisão/correção.

## Estado da AT6

O DER está preparado e conferido: 19 tabelas, 115 colunas e 21 relacionamentos. O PDF da AT2 ainda diverge do DDL em pontos listados no relatório. Não declarar a atividade concluída até revisar e exportar o documento no modelo oficial, conferir os três artefatos em conjunto e atualizar a publicação final.

As divergências mais importantes são: resumo e matriz não acompanham RF01–RF09; `item_pedido.preco_unitario` aparece no lugar de `preco_unitario_venda`; RN01 aponta para tabela `estoque` inexistente; PR02 pede `id_lote` em `item_pedido` em vez de `item_pedido_lote`; faltam entidades no inventário; SEFAZ e DRE excedem o modelo; e triggers/procedure/view são prometidas sem constarem do DDL. A lista completa traz páginas e correções sugeridas.

O histórico atual termina na versão 1.0 (29/10/2026). A página 14 ainda tem “Orientação:”, o sumário anuncia anexos que não estão no PDF e a validação da página 18 declara aprovações com campos de assinatura vazios. Confirmar esses pontos com os autores/professor e registrar apenas revisões e aprovações reais.

## Próximo passo do grupo

Corrigir a AT2 no arquivo editável oficial preservando seu layout. Quando houver um novo PDF, compará-lo novamente com `docs/ddl_original.sql`, `assets/der.png` e `docs/dolly_vendas.mwb`. Só então retirar o aviso de revisão pendente e atualizar a versão pública do GitHub Pages.
