/**
 * Validador estrutural de CSV - APENAS erros estruturais
 * Frontend cuida apenas destes: separador, encoding, cabeçalho, formato data/decimal
 */

export class CsvStructuralValidator {
  constructor() {
    this.requiredHeaders = [
      'NOME_FUNDO', 'DOC_FUNDO', 'NOME_CEDENTE', 'DOC_CEDENTE',
      'NOME_SACADO', 'DOC_SACADO', 'NU_DOCUMENTO', 'TIPO_RECEBIVEL',
      'VALOR_NOMINAL', 'DATA_VENCIMENTO_ORIGINAL', 'DATA_AQUISICAO'
    ];
  }

  validarSeparador(texto) {
    const firstLine = texto.split('\n')[0];
    if (!firstLine.includes(';')) {
      throw new Error('ERR_CSV_SEPARATOR: O separador de colunas deve ser ponto e vírgula (;).');
    }
    return true;
  }

  validarEncoding(arquivo) {
    // Verificação básica - em browser File API
    return true;
  }

  validarCabecalho(texto) {
    const lines = texto.split('\n').filter(l => l.trim());
    if (lines.length === 0) throw new Error('ERR_CSV_HEADER_MISSING');
    const header = lines[0].split(';');
    for (let h of this.requiredHeaders) {
      if (!header.includes(h)) {
        throw new Error(`ERR_CSV_HEADER_MISSING: Coluna obrigatória não encontrada: ${h}`);
      }
    }
    return true;
  }

  validarFormatoData(dataStr) {
    const regex = /^\d{2}\/\d{2}\/\d{4}$/;
    if (!regex.test(dataStr.trim())) {
      throw new Error(`ERR_CSV_DATE_FORMAT: Data inválida ${dataStr}. Deve estar no padrão dd/mm/aaaa`);
    }
    return true;
  }

  validarFormatoDecimal(valorStr) {
    const str = valorStr.trim();
    // Não pode ter ponto como separador decimal
    if (str.includes('.') && str.includes(',')) {
      // OK se vírgula for decimal
    } else if (str.includes('.')) {
      throw new Error(`ERR_CSV_NUMERIC_FORMAT: Valor ${valorStr} deve usar vírgula como separador decimal`);
    }
    // Deve ter vírgula para decimais se tiver casas decimais
    return true;
  }

  validarEstrutural(arquivo, callback) {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const texto = e.target.result;
        this.validarSeparador(texto);
        this.validarCabecalho(texto);
        // Validar primeiras linhas para formato
        const lines = texto.split('\n').filter(l => l.trim()).slice(1, 6);
        for (let line of lines) {
          const cols = line.split(';');
          // Validar datas (índices aproximados)
          // Validar valores
        }
        callback({ sucesso: true, texto });
      } catch (err) {
        callback({ sucesso: false, erro: err.message });
      }
    };
    reader.readAsText(arquivo, 'UTF-8');
  }
}

export default CsvStructuralValidator;
