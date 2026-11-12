SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
CREATE SCHEMA IF NOT EXISTS `dolly_vendas` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `dolly_vendas` ;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`usuario` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `login` VARCHAR(100) NOT NULL,
  `senha_hash` VARCHAR(255) NOT NULL,
  `perfil` ENUM('Admin', 'Gerente', 'Operador') NOT NULL,
  `ativo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `uk_usuario_login` (`login` ASC) VISIBLE)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`cliente` (
  `id_cliente` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `email` VARCHAR(150) NULL DEFAULT NULL,
  `cpf_cnpj` VARCHAR(14) NOT NULL,
  `telefone` VARCHAR(20) NULL DEFAULT NULL,
  `consent_lgpd` TINYINT NOT NULL DEFAULT 0,
  `data_consentimento` DATETIME NULL DEFAULT NULL,
  `ativo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_cliente`),
  UNIQUE INDEX `uk_cliente_cpf_cnpj` (`cpf_cnpj` ASC) VISIBLE)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`endereco` (
  `id_endereco` INT NOT NULL AUTO_INCREMENT,
  `id_cliente` INT NOT NULL,
  `logradouro` VARCHAR(200) NOT NULL,
  `numero` VARCHAR(20) NOT NULL,
  `complemento` VARCHAR(100) NULL DEFAULT NULL,
  `bairro` VARCHAR(100) NOT NULL,
  `cidade` VARCHAR(100) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `cep` CHAR(8) NOT NULL,
  PRIMARY KEY (`id_endereco`),
  UNIQUE INDEX `uk_endereco_cliente` (`id_endereco` ASC, `id_cliente` ASC) VISIBLE,
  INDEX `idx_endereco_cliente` (`id_cliente` ASC) VISIBLE,
  INDEX `idx_endereco_regiao` (`uf` ASC, `cidade` ASC, `cep` ASC) VISIBLE,
  CONSTRAINT `fk_endereco_cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `dolly_vendas`.`cliente` (`id_cliente`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`fornecedor` (
  `id_fornecedor` INT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(150) NOT NULL,
  `cnpj` VARCHAR(14) NOT NULL,
  `contato` VARCHAR(100) NULL DEFAULT NULL,
  `ativo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_fornecedor`),
  UNIQUE INDEX `uk_fornecedor_cnpj` (`cnpj` ASC) VISIBLE)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`categoria` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `ativo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_categoria`),
  UNIQUE INDEX `uk_categoria_nome` (`nome` ASC) VISIBLE)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`produto` (
  `id_produto` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `id_fornecedor` INT NOT NULL,
  `descricao` VARCHAR(200) NOT NULL,
  `preco_tabela` DECIMAL(10,2) NOT NULL,
  `saldo_estoque` INT NOT NULL DEFAULT 0,
  `ativo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_produto`),
  INDEX `idx_produto_categoria` (`id_categoria` ASC) VISIBLE,
  INDEX `idx_produto_fornecedor` (`id_fornecedor` ASC) VISIBLE,
  CONSTRAINT `fk_produto_categoria`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `dolly_vendas`.`categoria` (`id_categoria`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,

  CONSTRAINT `fk_produto_fornecedor`
    FOREIGN KEY (`id_fornecedor`)
    REFERENCES `dolly_vendas`.`fornecedor` (`id_fornecedor`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`lote` (
  `id_lote` INT NOT NULL AUTO_INCREMENT,
  `id_produto` INT NOT NULL,
  `numero_lote` VARCHAR(50) NOT NULL,
  `quantidade_inicial` INT NOT NULL,
  `quantidade_atual` INT NOT NULL,
  `data_fabricacao` DATE NOT NULL,
  `data_validade` DATE NOT NULL,
  PRIMARY KEY (`id_lote`),
  UNIQUE INDEX `uk_lote_numero_produto` (`id_produto` ASC, `numero_lote` ASC) VISIBLE,
  UNIQUE INDEX `uk_lote_produto` (`id_lote` ASC, `id_produto` ASC) VISIBLE,
  INDEX `idx_lote_fefo` (`id_produto` ASC, `data_validade` ASC, `id_lote` ASC) VISIBLE,
  CONSTRAINT `fk_lote_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `dolly_vendas`.`produto` (`id_produto`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`preco_regiao` (
  `id_preco_regiao` INT NOT NULL AUTO_INCREMENT,
  `id_produto` INT NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `preco_vigente` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_preco_regiao`),
  UNIQUE INDEX `uk_preco_regiao_produto_uf` (`id_produto` ASC, `uf` ASC) VISIBLE,
  CONSTRAINT `fk_preco_regiao_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `dolly_vendas`.`produto` (`id_produto`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`promocao` (
  `id_promocao` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(150) NOT NULL,
  `percentual_desconto` DECIMAL(5,2) NOT NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NOT NULL,
  `ativo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_promocao`))
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`pedido` (
  `id_pedido` INT NOT NULL AUTO_INCREMENT,
  `id_cliente` INT NOT NULL,
  `id_usuario` INT NOT NULL,
  `id_endereco` INT NOT NULL,
  `data_hora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `situacao` ENUM('ABERTO', 'FINALIZADO', 'CANCELADO') NOT NULL DEFAULT 'ABERTO',
  `forma_pagamento` VARCHAR(50) NOT NULL,
  `valor_total` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `valor_desconto` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `data_cancelamento` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_pedido`),
  INDEX `idx_pedido_cliente` (`id_cliente` ASC) VISIBLE,
  INDEX `idx_pedido_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `idx_pedido_data_hora` (`data_hora` ASC) VISIBLE,
  INDEX `idx_pedido_endereco_cliente` (`id_endereco` ASC, `id_cliente` ASC) VISIBLE,
  CONSTRAINT `fk_pedido_cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `dolly_vendas`.`cliente` (`id_cliente`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_pedido_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `dolly_vendas`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_pedido_endereco_cliente`
    FOREIGN KEY (`id_endereco` , `id_cliente`)
    REFERENCES `dolly_vendas`.`endereco` (`id_endereco` , `id_cliente`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`item_pedido` (
  `id_item` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `id_produto` INT NOT NULL,

  `id_promocao` INT NULL DEFAULT NULL,
  `quantidade` INT NOT NULL,
  `preco_unitario_venda` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_item`),
  UNIQUE INDEX `uk_item_produto` (`id_item` ASC, `id_produto` ASC) VISIBLE,
  INDEX `idx_item_pedido` (`id_pedido` ASC) VISIBLE,
  INDEX `idx_item_produto` (`id_produto` ASC) VISIBLE,
  INDEX `idx_item_promocao` (`id_promocao` ASC) VISIBLE,
  CONSTRAINT `fk_item_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `dolly_vendas`.`pedido` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `dolly_vendas`.`produto` (`id_produto`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_promocao`
    FOREIGN KEY (`id_promocao`)
    REFERENCES `dolly_vendas`.`promocao` (`id_promocao`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`item_pedido_lote` (
  `id_item_pedido_lote` INT NOT NULL AUTO_INCREMENT,
  `id_item` INT NOT NULL,
  `id_lote` INT NOT NULL,
  `id_produto` INT NOT NULL,
  `quantidade` INT NOT NULL,
  `quantidade_estornada` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_item_pedido_lote`),
  UNIQUE INDEX `uk_item_lote` (`id_item` ASC, `id_lote` ASC) VISIBLE,
  INDEX `idx_alocacao_item_produto` (`id_item` ASC, `id_produto` ASC) VISIBLE,
  INDEX `idx_alocacao_lote_produto` (`id_lote` ASC, `id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_alocacao_item`
    FOREIGN KEY (`id_item` , `id_produto`)
    REFERENCES `dolly_vendas`.`item_pedido` (`id_item` , `id_produto`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_alocacao_lote`
    FOREIGN KEY (`id_lote` , `id_produto`)
    REFERENCES `dolly_vendas`.`lote` (`id_lote` , `id_produto`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`nota_fiscal` (
  `id_nota_fiscal` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `chave_acesso` CHAR(44) NOT NULL,
  `valor_total_nf` DECIMAL(10,2) NOT NULL,
  `data_emissao` DATETIME NOT NULL,
  PRIMARY KEY (`id_nota_fiscal`),
  UNIQUE INDEX `uk_nf_chave` (`chave_acesso` ASC) VISIBLE,
  UNIQUE INDEX `uk_nf_pedido` (`id_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_nf_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `dolly_vendas`.`pedido` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`conta_receber` (
  `id_conta` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `numero_parcela` INT NOT NULL,
  `valor_parcela` DECIMAL(10,2) NOT NULL,
  `data_vencimento` DATE NOT NULL,
  `status_parcela` ENUM('PENDENTE', 'PAGO', 'CANCELADO') NOT NULL DEFAULT 'PENDENTE',
  PRIMARY KEY (`id_conta`),
  UNIQUE INDEX `uk_conta_pedido_parcela` (`id_pedido` ASC, `numero_parcela` ASC) VISIBLE,
  INDEX `idx_conta_status_vencimento` (`status_parcela` ASC, `data_vencimento` ASC) VISIBLE,
  CONSTRAINT `fk_conta_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `dolly_vendas`.`pedido` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`pagamento` (
  `id_pagamento` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `forma_pagamento` ENUM('BOLETO', 'PIX', 'CARTAO') NOT NULL,
  `valor_pago` DECIMAL(10,2) NOT NULL,
  `status_pagamento` ENUM('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'ESTORNADO') NOT NULL DEFAULT 'PENDENTE',

  `data_transacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pagamento`),
  INDEX `idx_pagamento_pedido` (`id_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_pagamento_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `dolly_vendas`.`pedido` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`entrega` (
  `id_entrega` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `id_usuario_motorista` INT NOT NULL,
  `status_entrega` ENUM('PENDENTE', 'EM_ROTA', 'CONCLUIDA') NOT NULL DEFAULT 'PENDENTE',
  `data_prevista` DATE NOT NULL,
  `data_realizada` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_entrega`),
  UNIQUE INDEX `uk_entrega_pedido` (`id_pedido` ASC) VISIBLE,
  INDEX `idx_entrega_motorista` (`id_usuario_motorista` ASC) VISIBLE,
  INDEX `idx_entrega_status_data` (`status_entrega` ASC, `data_prevista` ASC) VISIBLE,
  CONSTRAINT `fk_entrega_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `dolly_vendas`.`pedido` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_entrega_motorista`
    FOREIGN KEY (`id_usuario_motorista`)
    REFERENCES `dolly_vendas`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`comprovante_entrega` (
  `id_comprovante` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `assinatura_digital_canhoto` TEXT NOT NULL,
  `data_registro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_comprovante`),
  UNIQUE INDEX `uk_comprovante_pedido` (`id_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_comprovante_entrega`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `dolly_vendas`.`entrega` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`estorno` (
  `id_estorno` INT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `motivo` TEXT NOT NULL,
  `data_estorno` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_estorno`),
  UNIQUE INDEX `uk_estorno_pedido` (`id_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_estorno_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `dolly_vendas`.`pedido` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `dolly_vendas`.`log_auditoria` (
  `id_log` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT NOT NULL,
  `tabela_afetada` VARCHAR(100) NOT NULL,
  `operacao` VARCHAR(20) NOT NULL,
  `data_hora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `valor_anterior` JSON NULL DEFAULT NULL,
  `valor_novo` JSON NULL DEFAULT NULL,
  PRIMARY KEY (`id_log`),
  INDEX `idx_log_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `idx_log_tabela_data` (`tabela_afetada` ASC, `data_hora` ASC) VISIBLE,
  CONSTRAINT `fk_log_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `dolly_vendas`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
USE dolly_vendas;
ALTER TABLE `usuario`
  ADD CONSTRAINT ck_usuario_ativo CHECK (ativo IN (0,1));

ALTER TABLE `cliente`
  ADD CONSTRAINT ck_cliente_ativo CHECK (ativo IN (0,1)),
  ADD CONSTRAINT ck_cliente_consentimento CHECK (consent_lgpd IN (0,1)),
  ADD CONSTRAINT ck_cliente_data_consentimento CHECK (consent_lgpd = 0 OR data_consentimento IS NOT NULL);
ALTER TABLE `fornecedor`
  ADD CONSTRAINT ck_fornecedor_ativo CHECK (ativo IN (0,1));
ALTER TABLE `categoria`
  ADD CONSTRAINT ck_categoria_ativo CHECK (ativo IN (0,1));
ALTER TABLE `produto`
  ADD CONSTRAINT ck_produto_preco CHECK (preco_tabela > 0),
  ADD CONSTRAINT ck_produto_saldo CHECK (saldo_estoque >= 0),
  ADD CONSTRAINT ck_produto_ativo CHECK (ativo IN (0,1));
ALTER TABLE `lote`
  ADD CONSTRAINT ck_lote_quantidades CHECK (quantidade_inicial > 0 AND quantidade_atual >= 0 AND quantidade_atual <= quantidade_inicial),
  ADD CONSTRAINT ck_lote_datas CHECK (data_validade >= data_fabricacao);
ALTER TABLE `preco_regiao`
  ADD CONSTRAINT ck_preco_regiao_valor CHECK (preco_vigente > 0);
ALTER TABLE `promocao`
  ADD CONSTRAINT ck_promocao_percentual CHECK (percentual_desconto > 0 AND percentual_desconto < 100),
  ADD CONSTRAINT ck_promocao_datas CHECK (data_fim >= data_inicio),
  ADD CONSTRAINT ck_promocao_ativo CHECK (ativo IN (0,1));
ALTER TABLE `pedido`
  ADD CONSTRAINT ck_pedido_valores CHECK (valor_total >= 0 AND valor_desconto >= 0),
  ADD CONSTRAINT ck_pedido_finalizado_valor CHECK (situacao <> 'FINALIZADO' OR valor_total > 0),
  ADD CONSTRAINT ck_pedido_cancelamento CHECK ((situacao = 'CANCELADO' AND data_cancelamento IS NOT NULL) OR (situacao <> 'CANCELADO' AND 
data_cancelamento IS NULL));
ALTER TABLE `item_pedido`
  ADD CONSTRAINT ck_item_quantidade CHECK (quantidade > 0),
  ADD CONSTRAINT ck_item_preco CHECK (preco_unitario_venda > 0);
ALTER TABLE `item_pedido_lote`
  ADD CONSTRAINT ck_alocacao_quantidade CHECK (quantidade > 0),
  ADD CONSTRAINT ck_alocacao_estorno CHECK (quantidade_estornada >= 0 AND quantidade_estornada <= quantidade);
ALTER TABLE `nota_fiscal`
  ADD CONSTRAINT ck_nf_valor CHECK (valor_total_nf > 0);
ALTER TABLE `conta_receber`
  ADD CONSTRAINT ck_conta_numero CHECK (numero_parcela > 0),
  ADD CONSTRAINT ck_conta_valor CHECK (valor_parcela > 0);
ALTER TABLE `pagamento`
  ADD CONSTRAINT ck_pagamento_valor CHECK (valor_pago > 0);
ALTER TABLE `entrega`
  ADD CONSTRAINT ck_entrega_conclusao CHECK ((status_entrega = 'CONCLUIDA' AND data_realizada IS NOT NULL) OR (status_entrega <> 'CONCLUIDA' 
AND data_realizada IS NULL));
ALTER TABLE `log_auditoria`
  ADD CONSTRAINT ck_log_operacao CHECK (operacao IN ('INSERT','UPDATE','DELETE'));