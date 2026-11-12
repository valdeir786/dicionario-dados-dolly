# Conferência da AT2 recebida

Data da conferência: 11/11/2026. Documento examinado: PDF de 18 páginas enviado nesta conversa. O arquivo recebido tem o mesmo conteúdo e SHA-256 da cópia encontrada em `D:\atividade`; por isso, não consigo identificar alterações recentes em relação à cópia que já estava disponível para esta revisão.

## O que foi atualizado no documento

- O detalhamento contém RF01 a RF09, embora o quadro-resumo ainda liste quatro requisitos antigos.
- A seção de entidades agora cita fornecedor, lote, entrega, pagamento e promoção, e usa `preco_unitario_venda` na descrição de `item_pedido`.
- O RNF03 cita armazenamento de senha com hash Argon2id.
- Não encontrei campos literais entre colchetes nem a página “COMO UTILIZAR ESTE MODELO”.
- O histórico contém quatro entradas, de 0.1 até 1.0.

## Correções que ainda faltam para coerência com o DDL e o DER do Workbench

1. **Páginas 6, 12 e 13 — nome do preço:** o RF01, a RN04 e a regra monetária ainda usam `item_pedido.preco_unitario`. O DDL define `item_pedido.preco_unitario_venda`. Padronizar o nome e a fórmula em todas as seções.
2. **Páginas 6 e 18 — rastreabilidade:** o quadro-resumo lista RF01–RF04 com títulos diferentes dos detalhamentos RF01–RF09; a matriz também só cobre quatro RFs e associa títulos antigos. Recriar ambos a partir dos nove requisitos detalhados e conferir cada vínculo com RN, PR e RNF.
3. **Páginas 4, 7 e 10 — escopo fiscal:** a introdução exclui integração com a SEFAZ nesta versão, enquanto RF03 promete cálculo tributário e RNF01 exige integração. Decidir se a integração fica para versão futura ou se o escopo e o modelo serão ampliados. A tabela atual não registra tributos nem protocolo de autorização.
4. **Página 8 — DRE e rentabilidade:** o RF06 promete DRE/rentabilidade, mas o DDL não modela custos, despesas nem plano de contas. Restringir o relatório ao que os dados suportam ou ampliar o escopo e o modelo com aprovação do grupo.
5. **Páginas 7 e 10 — roteirização:** RF04/RNF02 falam em capacidade de veículo, localização e otimização de rotas; não há entidades de veículo, capacidade, coordenadas ou rota no DDL. Limitar a promessa a agrupamento pelos dados existentes ou modelar esses elementos.
6. **Página 12 — estoque e FEFO:** RN01 aponta para tabela `estoque`, que não existe. No DDL, o saldo agregado fica em `produto.saldo_estoque` e o saldo por lote em `lote.quantidade_atual`. A procedure de FEFO descrita também não está no DDL. A documentação deve distinguir a estrutura existente da rotina ainda não implementada.
7. **Páginas 12 e 13 — regras automáticas:** triggers, view, recomposição de estoque, imutabilidade, auditoria automática e cálculo agregado do total são descritos como implementação prevista, mas o script fornecido não contém `CREATE TRIGGER`, `CREATE PROCEDURE` nem `CREATE VIEW`. Implementar e documentar essas rotinas ou registrar claramente que estão pendentes/fora do escopo da entrega.
8. **Página 14 — rastreabilidade por lote:** PR02 exige `id_lote` diretamente em `item_pedido`. Isso diverge do DDL e do DER, que usam a associação `item_pedido_lote` para permitir vários lotes por item e vários itens por lote. Corrigir a regra para essa tabela de associação e manter as FKs compostas que garantem o mesmo produto.
9. **Páginas 15–16 — inventário de entidades:** ainda faltam `preco_regiao`, `item_pedido_lote`, `nota_fiscal`, `conta_receber`, `comprovante_entrega` e `estorno`. Completar também colunas e relacionamentos omitidos nas entidades listadas, usando o catálogo gerado do DDL.
10. **Página 15 — entrega/canhoto:** a lista põe `assinatura_digital_canhoto` em `entrega`, mas o DDL a define em `comprovante_entrega`. A regra de ligação deve seguir `comprovante_entrega.id_pedido` e `entrega.id_pedido`; conferir as cardinalidades 0..1 resultantes das constraints UNIQUE.
11. **Páginas 5 e 17 — exclusão e integridade:** `data_exclusao` não aparece no DDL; a frase sobre impedir DELETE em produção não é uma constraint do script. A integridade de domínio também diverge: a seção declara `preco_unitario_venda >= 0` e `valor > 0`, mas o DDL permite `pedido.valor_total = 0` em estados não finalizados e exige preço unitário positivo. Ajustar cada descrição aos CHECKs reais e não apresentar regra operacional como garantida pelo banco quando não está implementada.
12. **Páginas 12–13 — identificadores de regras:** a seção é de regras RN, mas a recomposição aparece como RNF06 e a integridade monetária como RNF07. Corrigir a numeração e referências cruzadas; na página 12 também corrigir “Valid�a� FEFO” e, na página 11, “RNFO8” para RNF08.
13. **Página 14 — instrução de template:** permanece o bloco iniciado por “Orientação:”. Removê-lo depois de validar as políticas aplicáveis ao projeto.
14. **Página 3 — anexos:** o sumário anuncia anexos A, B e C que não aparecem nas 18 páginas do arquivo. Incluir os anexos reais ou retirar essas entradas do sumário.
15. **Página 18 — validação:** o texto afirma que o documento foi revisado e validado na versão 1.0, e lista professor e representante como aprovadores, mas as células de assinatura estão vazias. Confirmar as aprovações e obter as assinaturas reais; caso ainda não tenham ocorrido, alterar o texto para “pendente de validação”. Não inventar aprovação.
16. **Página 1 e banco:** a versão continua 1.0, com data 29/10/2026, e o histórico termina em 1.0. Registrar a revisão atual somente após as correções, com data e autores reais. Para que os `CHECK` do DDL sejam aplicados pelo MySQL, especificar a versão mínima compatível (8.0.16 ou superior).

## Sobre o DER e a publicação

O DER foi importado do DDL e exportado pelo MySQL Workbench 8.0.47. A imagem contém as 19 tabelas e 21 relacionamentos; o modelo editável `.mwb` também está no pacote. A auditoria de nomes, tipos, nulabilidade e mapeamentos de FKs foi comparada ao catálogo do DDL. O PNG não exibe todos os CHECKs, defaults ou valores de ENUM; para esses detalhes, o DDL e o dicionário permanecem as referências.

O dicionário e o DER podem ser apresentados como produtos preparados, mas o documento da AT2 ainda não corresponde integralmente ao banco. Antes de declarar a AT6 concluída, aplicar as correções no arquivo editável oficial, exportar o PDF preservando o modelo exigido pelo professor e conferir novamente o PDF, o DER e o dicionário lado a lado. O conteúdo deste relatório é uma revisão técnica; aprovação acadêmica cabe ao grupo e ao orientador.

