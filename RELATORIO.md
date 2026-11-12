# Revisão de coerência e governança

> **Atualização de situação — 11/11/2026:** este relatório registra a auditoria inicial de 05/11/2026. O DER físico foi posteriormente importado do DDL e exportado pelo MySQL Workbench 8.0.47; ele está em `assets/der.png`, com o modelo editável em `docs/dolly_vendas.mwb`. A AT2 recebida em 10/11/2026 continua com divergências documentadas em `docs/CONFERENCIA_AT2.md`. Onde este relatório mencionar DER pendente, essa parte está superada; as pendências de requisitos e regras de negócio continuam válidas até nova correção e conferência.

Projeto: Sistema de Gestão Operacional e Vendas. Empresa: Ragi Refrigerantes Ltda. (Dolly), conforme documentação acadêmica, sem verificação de representação institucional. Equipe: Grupo 03. Orientador solicitado: Prof. Dr. Diego Carvalho; documento: Diego Marques de Carvalho. Tecnologia: MySQL/InnoDB/utf8mb4, mínimo 8.0.16 recomendado para CHECK. Data: 05/11/2026. Status: revisão técnica 1.1 proposta, sem aprovação formal.

Para a Ragi Refrigerantes Ltda. (Dolly), cultura de dados significa que comercial, estoque, logística e financeiro compartilhem o significado de lote, saldo, preço de venda e conclusão do pedido. Este dicionário transforma nomes técnicos em regras verificáveis, reduz erros de FEFO e facilita rastrear uma venda até seu lote. A gestão de metadados e responsabilidades segue a orientação do DAMA-DMBOK; o objetivo APO14 do COBIT orienta a gestão dos dados como ativos. Estes referenciais orientam a proposta e não constituem certificação de conformidade.

## Responsáveis

Caio Kenji Nabuosuke, Carlos Gomes de Souza Júnior, Eduarda Amorim, Guilherme Couto de Souza, Henrique de Medeiros Elias, Jenifer Rufino, Otávio Teixeira de Oliveira Marcílio, Pedro Pinheiro Martins de Lima, Robert Jhonny de Lima, Valdeir Almeida Silva, Willy Dourado.

Papéis documentados: Carlos Gomes é líder do grupo; Eduarda Amorim é analista de requisitos. Proposta para validação: Carlos como Data Owner (decisões de negócio), Eduarda como Data Steward (glossário e qualidade); demais integrantes como corresponsáveis pela modelagem e revisão. Papéis não constituem nomeação formal. Não publicar RGMs no site.

## Resultado técnico

19 tabelas, 115 colunas, 21 FKs, 28 CHECKs. Nenhuma FK estrutural órfã ou incompatibilidade de tipos nas FKs foi encontrada no script. Não há dados para testar órfãos reais. Todas as FKs usam ON DELETE RESTRICT e ON UPDATE RESTRICT. Nenhum gatilho, procedimento, view ou GRANT foi fornecido. Dicionário fiel ao DDL; nenhum ajuste proposto altera silenciosamente o schema.

O dicionário não pode ser publicado como versão aprovada sem as devidas alterações nos requisitos. O DER foi exportado pelo Workbench e está disponível no pacote; a aprovação e a implementação das regras ausentes permanecem pendentes.

## Ajustes manuais por localização

1. **Alta | Requisitos p.6, §2.1 e pp.6-9**: Substituir o resumo RF01-RF04 pelos nove RFs efetivamente detalhados. RF01 é registro de pedidos, RF02 baixa FEFO, RF03 faturamento, RF04 roteirização, RF05 canhoto, RF06 relatório financeiro, RF07 vendas por região, RF08 usuários, RF09 cadastros B2B. Atualizar a matriz da p.18 para RF01-RF09.

2. **Alta | Requisitos p.4 §1.2; p.7 RF03; p.10 RNF01**: Resolver conflito de escopo: SEFAZ está excluída na p.4 e obrigatória em RNF01. Proposta: manter integração fiscal futura; RF03 registra metadados fiscais recebidos e parcelas, sem prometer cálculo tributário/transmissão. O DDL não tem tributos, protocolo ou autorização.

3. **Alta | Requisitos p.4; p.8 RF06**: Trocar promessa de DRE/rentabilidade por relatório de vendas e recebimentos. Não há custos, despesas ou plano de contas no DDL; contabilidade gerencial foi excluída do escopo.

4. **Alta | Requisitos pp.6,12,13**: Substituir item_pedido.preco_unitario por item_pedido.preco_unitario_venda, inclusive fórmulas. Na p.12 RN01 substituir tabela de estoque/saldo por produto.saldo_estoque e lote.quantidade_atual, preservando as regras mais fortes dos CHECKs.

5. **Alta | Requisitos p.12 RN02/RN03/RN04/RN05/RNF06; p.13 RNF07**: Corrigir RNF06 para RN06 e RNF07 para RN07 nesta seção. Marcar procedure FEFO, view regional, congelamento de preço, imutabilidade, recomposição e cálculo do total como pendentes: não há CREATE TRIGGER/PROCEDURE/VIEW no DDL. Índice FEFO não executa alocação.

6. **Alta | Requisitos p.12 RN05; p.8 RF05; p.7 RF03**: Definir máquina de estados: FINALIZADO não pode significar simultaneamente separação, faturamento e entrega. Para a proposta alinhada, manter ABERTO até a confirmação logística e registrar separação/faturamento por evidências relacionadas; validar cancelamento após finalização e exceção autorizada à imutabilidade. Não há fluxo implementado no script.

7. **Alta | Requisitos p.14 PR02; pp.15-16 §6.1; DER p.1**: Substituir obrigação de id_lote em item_pedido pela associação item_pedido_lote. Um item pode consumir vários lotes; um lote pode atender vários itens. FKs compostas garantem o mesmo produto; não inserir id_lote em item_pedido.

8. **Alta | DER p.1**: Adicionar pagamento (6 colunas) e item_pedido_lote (6 colunas), ausentes. Adicionar produto.id_fornecedor, pedido.id_endereco e item_pedido.id_promocao, ausentes. Desenhar os 21 vínculos do DDL, incluindo promoção e associação por lote. O DER original possui 17 tabelas e 100 atributos; o DDL possui 19 e 115.

9. **Alta | DER p.1: entrega, nota_fiscal, comprovante_entrega, estorno**: Mostrar pedido 1 para 0..1 entrega, nota_fiscal e estorno devido a UNIQUE(id_pedido), e entrega 1 para 0..1 comprovante_entrega. Cada filho existente tem exatamente um pai; UNIQUE não obriga a criação do filho. Ligar comprovante_entrega a entrega.id_pedido, e não diretamente a pedido.

10. **Média | Requisitos p.15: entrega; p.16: promoção**: Remover assinatura_digital_canhoto de entrega: pertence a comprovante_entrega. Substituir N:1 ou 1:1 por pedido 1 para 0..1 entrega. Promoção é opcional no item; cada item tem 0..1 promoção, cada promoção 0..N itens. Não há associação campanha-produto/região no DDL.

11. **Média | Requisitos pp.15-16 §6.1**: Completar inventário com preco_regiao, item_pedido_lote, nota_fiscal, conta_receber, comprovante_entrega e estorno. A lista de atributos era preliminar: usar o catálogo completo desta revisão para não perder email, consentimentos, bairro, complemento, flags e demais colunas.

12. **Alta | DDL pp.1-5; Requisitos RNF06 e RN02**: Implementar transações com bloqueio de lotes, seleção FEFO por data_validade e id_lote, exclusão de vencidos, soma das alocações igual à quantidade do item, soma dos lotes igual ao saldo agregado, e estorno idempotente. CHECKs locais não garantem invariantes entre linhas/tabelas; regras devem ter testes concorrentes.

13. **Alta | DDL pp.2-5: totais, descontos e preços**: Definir precedência preco_regiao/preco_tabela, UF via endereço do pedido, ausência de preço regional, arredondamento e fórmula de desconto. Implementar soma dos itens/parcelas, conciliação de pagamentos, limites de desconto, validade/atividade de promoção e igualdade com nota fiscal. O DDL permite múltiplos pagamentos sem vínculo com uma parcela.

14. **Média | Requisitos p.17 §6.2**: Trocar CHECK(preco_unitario_venda >= 0) por > 0; pedido.valor_total pode ser zero em ABERTO/CANCELADO e deve ser > 0 em FINALIZADO. Não afirmar totais sempre positivos. ON DELETE RESTRICT bloqueia pais referenciados; não proíbe DELETE de folhas. DEFAULT CURRENT_TIMESTAMP não impede edição.

15. **Média | Requisitos p.5 e p.17**: Remover afirmação de campo data_exclusao em todas as tabelas: não existe no DDL. Documentar ativo somente onde existe e estados onde presentes; retenção depende de permissões/processos. AUTO_INCREMENT não prova que identificadores nunca serão reaproveitados após operações administrativas.

16. **Média | Requisitos p.17: referências de origem**: Corrigir auditoria de RNF01 para RNF09; preço congelado deve apontar RN04; integridade referencial deve citar RN01/RN02 e PR01/PR02 conforme vínculo. Reconstituir matriz RF/RN/PR/RNF com cobertura RF05-RF09, RN06/RN07, PR04 e RNF09.

17. **Alta | Requisitos p.10 RNF03; p.9 RF08; DER usuario**: Trocar senhas criptografadas por senhas armazenadas como hash seguro Argon2id. VARCHAR(255) não impõe algoritmo. Perfis são apenas Admin/Gerente/Operador; Motorista/Financeiro/Comercial/Marketing são funções de negócio ainda sem mapeamento aprovado. Não há CREATE ROLE/GRANT nem restrição por linha no DDL.

18. **Média | Requisitos p.7 RF04 e p.10 RNF02**: Trocar promessa de otimização de rotas/capacidade de veículo por agrupamento por UF/cidade/CEP ou ampliar o modelo mediante decisão explícita. Não existem veículo, capacidade, coordenadas ou sequência de rota; view de agrupamento também não foi fornecida.

19. **Média | DDL p.1, p.2; Requisitos RF09**: Validar CPF/CNPJ, CEP, UF, telefone e email na aplicação ou futuro DDL; tamanhos não validam conteúdo. Definir unidade de quantidade (RF01 menciona fardos). fornecedor e produto são 1 para 0..N; múltiplos fornecedores por produto não são suportados.

20. **Média | DDL p.5; Requisitos p.11 RNF08**: Ajustar versão mínima operacional para MySQL 8.0.16 devido à efetivação de CHECKs. Validar utf8mb4_0900_ai_ci e índices VISIBLE no servidor alvo. Reexecução dos ALTER ADD CONSTRAINT falha por nomes já existentes: adotar migrações versionadas. Não executar script em produção sem revisão; restauração de FOREIGN_KEY_CHECKS não revalida dados inseridos antes.

21. **Alta | Requisitos p.14 PR01/PR02/PR04**: Validar fontes e aplicabilidade com responsável jurídico. Art.174 do CTN trata de prescrição de cobrança e isoladamente não define política universal de retenção fiscal. PR02 cita ANVISA genericamente. Registrar norma, hipótese legal, prazo, início da contagem, exceções, descarte e responsável; não inventar prazo. Consentimento não é base universal; anonimização e retenção não implementadas no DDL.

22. **Média | DDL log_auditoria e estorno; comprovante_entrega**: Definir minimização e mascaramento de JSON/textos livres; vedar cópia de senha_hash nos logs. Assinatura digital não comprova biometria: classificar DP e elevar a DPS somente se conteúdo sensível for confirmado. RBAC e linhagem operacional do catálogo são propostas, sem afirmar controles implementados.

23. **Alta | Requisitos p.18 §8**: Assinaturas estão vazias; nomes e datas impressos não comprovam aprovação. Não transportar aprovação da versão 1.0 para a revisão atual. Solicitar validação da equipe e do orientador após correções; professor no documento é Diego Marques de Carvalho, e no pedido é Prof. Dr. Diego Carvalho.

24. **Média | Template: requisitos p.14**: Remover a orientação em cinza: Orientação: Confirme quais políticas realmente se aplicam ao ramo da empresa escolhida; setores como alimentação, saúde e transporte possuem exigências adicionais.

25. **Média | Template: requisitos p.3**: Remover do sumário ou incluir de fato os anexos A (auditoria), B (Mermaid) e C (índices/gatilhos): não existem nas 18 páginas recebidas. Este pacote fornece auditoria e modelo, mas não gatilhos inexistentes.

26. **Média | Histórico p.2**: Preservar 0.1, 0.2, 0.3 e 1.0, com autores e datas originais. Acrescentar 1.1 em 05/11/2026 como revisão técnica assistida, pendente de aprovação: quinto registro. Não apagar uma revisão para chamar a atual de quarta. Não foi comprovado que os nomes históricos sejam fictícios.

27. **Baixa | Template e entrada do pedido**: Não foram encontrados textos literais entre colchetes nem página COMO UTILIZAR ESTE MODELO nos três PDFs. No pedido, permanecem sem preencher nome do projeto, papéis, cores, resumo e nomes dos anexos; os documentos permitem recuperar projeto, empresa e integrantes. Cores verde escuro, marfim e verde claro são escolha editorial proposta; designações Owner/Steward exigem validação. Corrigir Validçaõ FEFO para Validação FEFO e RNFO8 para RNF08.

## Limites da classificação

DP inclui identificadores e dados de transação vinculáveis a pessoas. CNPJ de pessoa jurídica isoladamente não é DP; o campo misto cpf_cnpj é classificado conservadoramente como DP. N/A não significa dado público. Nenhum DPS foi confirmado no DDL. A legenda DPS está disponível, com escalonamento condicionado ao conteúdo de canhotos e JSON. GDPR é aplicável somente se o contexto territorial/material o exigir, não comprovado pelos anexos. RBAC é proposta e não segurança do site estático. Linhagem estrutural via FK é verificável; origem operacional e consumidores são inferidos, sem integração comprovada.

## Histórico preservado

0.1 | 15/09/2026 | Criação inicial | Jenifer Rufino.

0.2 | 20/09/2026 | Regras e políticas | Carlos Gomes/Eduarda Amorim/Guilherme Couto/Willy Dourado/Caio Kenji.

0.3 | 22/09/2026 | Entidades e integridade | Henrique de Medeiros/Otávio Teixeira/Pedro Pinheiro/Valdeir Almeida/Robert Jhonny.

1.0 | 29/10/2026 | Revisão para entrega | Grupo Integrador 03.

1.1 | 05/11/2026 | Revisão técnica assistida; pendente de aprovação | Assistente, sob validação do Grupo 03.

## Fontes de referência

- [DAMA-DMBOK](https://dama.org/dama-dmbok-revision/)
- [COBIT APO14](https://www.isaca.org/resources/news-and-trends/industry-news/2020/cobit-2019-and-cobit-5-comparison)
- [LGPD - ANPD](https://www.gov.br/anpd/pt-br/acesso-a-informacao/perguntas-frequentes/perguntas-frequentes)
- [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
