"""Verifica a cobertura do catálogo sem executar o banco de dados."""
from pathlib import Path
from html.parser import HTMLParser
import re,json,sys
ROOT=Path(__file__).resolve().parent
class CatalogHTML(HTMLParser):
    def __init__(self):
        super().__init__();self.ids=[];self.links=[];self.tables={};self.current=None;self.row=None;self.cell=None;self.cells=[]
    def handle_starttag(self,tag,attrs):
        a=dict(attrs)
        if 'id' in a:self.ids.append(a['id'])
        if tag=='section' and 'data-table' in a:
            self.current=a['data-table'];self.tables[self.current]={}
        if tag=='tr' and 'data-column' in a:
            self.row=a['data-column'];self.cells=[]
        if self.row and tag in ('th','td'):self.cell=[]
        for key in ('href','src'):
            if key in a:self.links.append(a[key])
    def handle_data(self,data):
        if self.cell is not None:self.cell.append(data)
    def handle_endtag(self,tag):
        if self.row and tag in ('th','td') and self.cell is not None:
            self.cells.append(' '.join(''.join(self.cell).split()));self.cell=None
        if tag=='tr' and self.row:
            assert len(self.cells)==7,(self.current,self.row,'7 colunas esperadas')
            self.tables[self.current][self.row]=self.cells;self.row=None
        if tag=='section':self.current=None

def main():
    sql=(ROOT/'docs/ddl_original.sql').read_text(encoding='utf-8-sig')
    model=json.loads((ROOT/'docs/catalogo.json').read_text(encoding='utf-8-sig'))
    expected={}
    for name,body in re.findall(r'CREATE TABLE IF NOT EXISTS `dolly_vendas`\.`(\w+)` \((.*?)\)\s*ENGINE = InnoDB;',sql,re.S):
        cols={}
        for n,t,d in re.findall(r'^\s*`(\w+)`\s+((?:ENUM\([^\n]+?\)|[A-Z]+(?:\(\d+(?:,\d+)?\))?))\s+([^\n]+)',body,re.M):
            cols[n]=(t,d.rstrip(',').strip())
        expected[name]=cols
    page=CatalogHTML();page.feed((ROOT/'index.html').read_text(encoding='utf-8-sig'))
    actual={t['name']:t for t in model}
    assert len(page.ids)==len(set(page.ids)),'IDs HTML duplicados'
    assert expected.keys()==actual.keys()==page.tables.keys(),'Inventários de tabelas divergentes'
    for name,columns in expected.items():
        js={c['name']:c for c in actual[name]['columns']}
        assert columns.keys()==js.keys()==page.tables[name].keys(),('Colunas divergentes',name)
        for col,(typ,definition) in columns.items():
            assert js[col]['type']==typ,(name,col,'Tipo JSON')
            assert js[col]['definition']==definition,(name,col,'Definição JSON')
            row=page.tables[name][col]
            assert row[0]==col and row[2]==typ,(name,col,'Tipo HTML')
            assert ('[NOT NULL]' if 'NOT NULL' in definition else '[NULL]') in row[3],(name,col,'Nulabilidade HTML')
            if col in actual[name]['pk']:assert '[PK]' in row[3],(name,col,'PK HTML')
            for f in actual[name]['fks']:
                if col in f['columns']:assert f['name'] in row[3],(name,col,'FK HTML')
        for fk in actual[name]['fks']:
            for col,ref in zip(fk['columns'],fk['refs']):
                assert columns[col][0]==expected[fk['table']][ref][0],(name,col,'FK tipo incompatível')
        for ck in actual[name]['checks']:
            assert any(ck['name'] in row[3] for row in page.tables[name].values()),(name,'CHECK ausente',ck['name'])
    for link in page.links:
        if link.startswith('#'):assert link[1:] in page.ids,('Âncora quebrada',link)
        elif not re.match(r'^[a-z]+:',link):assert (ROOT/link.split('?',1)[0]).is_file(),('Arquivo ausente',link)
    counts={'tabelas':len(expected),'atributos':sum(map(len,expected.values())),'FKs':sum(len(t['fks']) for t in model),'CHECKs':sum(len(t['checks']) for t in model)}
    assert counts=={'tabelas':19,'atributos':115,'FKs':21,'CHECKs':28},counts
    print('OK:',json.dumps(counts,ensure_ascii=False))
    print('DDL, JSON e HTML coerentes no inventário verificado. O DER já foi exportado pelo MySQL Workbench; as pendências da AT2 permanecem descritas em ENTREGA_GRUPO.md e docs/CONFERENCIA_AT2.md.')
if __name__=='__main__':
    try:main()
    except (AssertionError,KeyError,ValueError) as error:
        print('FALHA:',error,file=sys.stderr);sys.exit(1)
