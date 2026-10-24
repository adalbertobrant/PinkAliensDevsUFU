/**
 * Divide CSV em chunks menores para envio ao backend
 * Frontend já validou estrutura
 */
export class CsvChunkSplitter {
  constructor(chunkSize = 10000) {
    this.chunkSize = chunkSize;
  }

  split(texto) {
    const lines = texto.split('\n');
    const header = lines[0];
    const dataLines = lines.slice(1).filter(l => l.trim());
    
    const chunks = [];
    for (let i = 0; i < dataLines.length; i += this.chunkSize) {
      const chunkLines = dataLines.slice(i, i + this.chunkSize);
      const chunkTexto = [header, ...chunkLines].join('\n');
      chunks.push({
        index: Math.floor(i / this.chunkSize),
        totalLines: chunkLines.length,
        conteudo: chunkTexto
      });
    }
    return chunks;
  }

  async enviarChunks(chunks, apiUrl, onProgress) {
    const resultados = [];
    for (let i = 0; i < chunks.length; i++) {
      const chunk = chunks[i];
      try {
        const response = await fetch(`${apiUrl}/api/v1/lotes`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            nome_arquivo: 'lote.csv',
            chunk_index: chunk.index,
            conteudo: chunk.conteudo,
            total_lines: chunk.totalLines
          })
        });
        const data = await response.json();
        resultados.push(data);
        if (onProgress) onProgress(i + 1, chunks.length);
      } catch (err) {
        console.error('Erro ao enviar chunk:', err);
        throw err;
      }
    }
    return resultados;
  }
}

export default CsvChunkSplitter;
EOF
