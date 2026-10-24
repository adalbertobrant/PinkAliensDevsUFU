/**
 * Relatório de erros estruturais de CSV.
 *
 * Responsabilidades (APENAS estrutura do arquivo, conforme regras_agentes.md):
 *  - Separador ponto e vírgula (;)
 *  - Cabeçalho obrigatório
 *  - Encoding UTF-8 (detectado na leitura do File)
 *  - Datas no padrão dd/mm/aaaa
 *  - Valores com vírgula decimal (e não ponto)
 *
 * Gera:
 *  1. Um relatório consolidado (contagem por tipo de erro).
 *  2. Um CSV contendo APENAS as linhas com erro, acrescido da coluna
 *     "MOTIVO_ERRO" com a explicação, para o usuário baixar e corrigir.
 */

const COLUNAS_OBRIGATORIAS = [
  'NOME_FUNDO', 'DOC_FUNDO', 'NOME_CEDENTE', 'DOC_CEDENTE',
  'NOME_SACADO', 'DOC_SACADO', 'NU_DOCUMENTO', 'TIPO_RECEBIVEL',
  'VALOR_NOMINAL', 'DATA_VENCIMENTO_ORIGINAL', 'DATA_AQUISICAO'
];

const REGEX_DATA = /^\d{2}\/\d{2}\/\d{4}$/;
// Valor válido: dígitos com vírgula como decimal (ex.: 1000,50). Ponto decimal é inválido.
const REGEX_VALOR = /^\d+(,\d+)?$/;

export class CsvErrorReport {
  constructor(texto) {
    this.texto = texto;
    this.linhas = texto.replace(/\r\n/g, '\n').split('\n');
    this.cabecalho = this.linhas[0] || '';
    this.colunas = this.cabecalho.split(';').map((c) => c.trim());
    this.erros = []; // { linha, tipo, mensagem, conteudo }
  }

  analisar() {
    this.erros = [];

    // 1. Separador
    if (!this.cabecalho.includes(';')) {
      this.erros.push({
        linha: 1,
        tipo: 'ERR_CSV_SEPARATOR',
        mensagem: 'O separador de colunas deve ser ponto e vírgula (;).',
        conteudo: this.cabecalho
      });
      // Sem separador correto, não dá para continuar a análise
      return this.resumo();
    }

    // 2. Cabeçalho
    const faltantes = COLUNAS_OBRIGATORIAS.filter((c) => !this.colunas.includes(c));
    if (faltantes.length > 0) {
      this.erros.push({
        linha: 1,
        tipo: 'ERR_CSV_HEADER_MISSING',
        mensagem: `Colunas obrigatórias ausentes: ${faltantes.join(', ')}`,
        conteudo: this.cabecalho
      });
      return this.resumo();
    }

    // Índices das colunas de data e valor
    const idxValor = this.colunas.indexOf('VALOR_NOMINAL');
    const idxVenc = this.colunas.indexOf('DATA_VENCIMENTO_ORIGINAL');
    const idxAquis = this.colunas.indexOf('DATA_AQUISICAO');

    // 3. Valida linha a linha (datas e valores)
    for (let i = 1; i < this.linhas.length; i++) {
      const linha = this.linhas[i];
      if (!linha || !linha.trim()) continue;
      const campos = linha.split(';');

      const problemas = [];

      // Formato de data
      for (const [idx, nome] of [[idxVenc, 'DATA_VENCIMENTO_ORIGINAL'], [idxAquis, 'DATA_AQUISICAO']]) {
        const v = (campos[idx] || '').trim();
        if (v && !REGEX_DATA.test(v)) {
          problemas.push(`${nome} deve estar no padrão dd/mm/aaaa (recebido: "${v}")`);
        }
      }

      // Formato de valor
      const valor = (campos[idxValor] || '').trim();
      if (valor && !REGEX_VALOR.test(valor)) {
        problemas.push(`VALOR_NOMINAL deve usar vírgula decimal, sem ponto (recebido: "${valor}")`);
      }

      if (problemas.length > 0) {
        this.erros.push({
          linha: i + 1, // 1-based (linha 1 = cabeçalho)
          tipo: problemas.some((p) => p.includes('VALOR_NOMINAL'))
            ? 'ERR_CSV_NUMERIC_FORMAT'
            : 'ERR_CSV_DATE_FORMAT',
          mensagem: problemas.join(' | '),
          conteudo: linha
        });
      }
    }

    return this.resumo();
  }

  resumo() {
    const porTipo = {};
    for (const e of this.erros) {
      porTipo[e.tipo] = (porTipo[e.tipo] || 0) + 1;
    }
    return {
      total_erros: this.erros.length,
      total_linhas: this.linhas.filter((l) => l && l.trim()).length,
      por_tipo: porTipo,
      erros: this.erros
    };
  }

  /**
   * Gera CSV contendo apenas as linhas com erro, com coluna MOTIVO_ERRO.
   * Retorna string pronta para download.
   */
  gerarCsvErros() {
    if (this.erros.length === 0) return '';

    const header = `${this.cabecalho};MOTIVO_ERRO`;
    const linhas = this.erros.map((e) => {
      // Para erro de cabeçalho/separador, usa o próprio conteúdo como linha
      const conteudo = e.conteudo || '';
      const motivo = `"${e.tipo}: ${e.mensagem.replace(/"/g, "'")}"`;
      return `${conteudo};${motivo}`;
    });

    return [header, ...linhas].join('\n');
  }

  /**
   * Dispara o download do CSV de erros no navegador.
   */
  baixarCsvErros(nomeArquivo = 'erros_lote.csv') {
    const csv = this.gerarCsvErros();
    if (!csv) return false;

    const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = nomeArquivo;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    return true;
  }
}

/**
 * Lê um arquivo (File) como UTF-8 e retorna o relatório.
 * Callback recebe { sucesso, resumo, csvErros, relatorio }.
 */
export function analisarArquivoCsv(arquivo, callback) {
  const reader = new FileReader();
  reader.onerror = () => {
    callback({
      sucesso: false,
      erro: { tipo: 'ERR_CSV_ENCODING', mensagem: 'Não foi possível ler o arquivo. Salve-o como UTF-8.' }
    });
  };
  reader.onload = (e) => {
    const texto = String(e.target.result);
    // Remove BOM se presente
    const limpo = texto.charCodeAt(0) === 0xfeff ? texto.slice(1) : texto;
    const relatorio = new CsvErrorReport(limpo);
    const resumo = relatorio.analisar();
    callback({
      sucesso: resumo.total_erros === 0,
      resumo,
      relatorio,
      csvErros: relatorio.gerarCsvErros()
    });
  };
  reader.readAsText(arquivo, 'UTF-8');
}

export default CsvErrorReport;
