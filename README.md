# Dicionário de dados Dolly

Revisão local 1.3, 11/11/2026. A pasta contém o dicionário baseado no DDL, o PDF da AT2 enviado pelo grupo e o DER exportado pelo MySQL Workbench 8.0.47. O DER foi conferido com 19 tabelas, 115 colunas e 21 relacionamentos. A AT2 ainda tem divergências em relação ao DDL; consulte `docs/CONFERENCIA_AT2.md`. Esta versão não deve ser apresentada como documentalmente aprovada até corrigirem o PDF e conferirem os três artefatos.

Site publicado anteriormente: https://carlosjb7.github.io/dicionario-dados-dolly/ . Repositório: https://github.com/carlosjb7/dicionario-dados-dolly . Esta pasta é uma versão local preparada; ainda não foi publicada a revisão atual.

## Estrutura

```text
/meu-dicionario
├── index.html
├── style.css
├── script.js
├── README.md
├── ENTREGA_GRUPO.md
├── RELATORIO.md
├── CONFERENCIA_AT2_11-11-2026.md
├── docs/
│   ├── Especificacao_Requisitos_Regras_Negocio_BD.pdf
│   ├── dolly_vendas.mwb
│   ├── ddl_original.sql
│   ├── catalogo.json
│   └── CONFERENCIA_AT2.md
└── assets/
    ├── der.png
    └── der.mmd
```

Abra `index.html` no navegador. A página usa caminhos relativos, portanto preserve os nomes e a posição das pastas. A pesquisa, o tema e os controles de zoom usam JavaScript nativo.

## Conteúdo e pendências

O dicionário descreve 19 tabelas e 115 atributos do DDL. O DER PNG foi exportado do Workbench e o `.mwb` pode ser reaberto para edição. O PDF da AT2 atual está incluído para revisão, mas ainda contém divergências descritas em `docs/CONFERENCIA_AT2.md`. As regras que não estão no DDL não são implementadas pelo site. O PDF recebido contém nomes e RGMs de integrantes; revise a exposição desses identificadores antes de publicar a versão pública.

## Atualização do GitHub Pages

O repositório público existente é `carlosjb7/dicionario-dados-dolly`, na branch `main`. Depois da aprovação do grupo:

1. Atualize os arquivos do site e mantenha `index.html` na raiz, junto de `style.css` e `script.js`.
2. Preserve as pastas `docs/` e `assets/` e seus nomes, incluindo maiúsculas e minúsculas. O servidor do GitHub diferencia, por exemplo, `DER.png` de `der.png`.
3. Faça o commit na branch `main`. A configuração esperada está em Settings > Pages > Build and deployment > Source: Deploy from a branch > Branch: main > Folder: /(root) > Save.
4. Aguarde o GitHub Pages concluir a publicação e confira os links de documentos, o DER e as funções da página.

Antes de declarar a AT6 concluída, use o documento editável oficial para corrigir a AT2, exporte o PDF preservando o modelo do professor e compare requisitos, DDL, DER e dicionário. Veja também `ENTREGA_GRUPO.md`.

