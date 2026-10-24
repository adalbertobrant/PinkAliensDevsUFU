// app/javascript/controllers/antecipe_feedback_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tabelaCorpo", "bannerRecusa", "mensagemRecusa", "cardSimulacao", "cardErroEstrutural", "mensagemErroEstrutural", "resumoTotal"];

  // Conecta e processa a resposta JSON vinda do Rails
  renderizarResposta(dados) {
    if (!dados.sucesso) {
      this.exibirErroEstrutural(dados.erro.mensagem);
      return;
    }

    this.limparErros();
    this.renderizarTabela(dados.notas);
    this.renderizarBannersDeRecusa(dados.notas);
    this.renderizarSimulacaoETotais(dados);
  }

  renderizarTabela(notas) {
    this.tabelaCorpoTarget.innerHTML = "";

    notas.forEach((nota) => {
      const isAprovada = nota.status === "Aprovada";
      const badgeClass = isAprovada
        ? "bg-emerald-600 text-white font-medium px-3 py-1 rounded text-xs"
        : "border border-red-500 text-red-600 font-medium px-3 py-1 rounded text-xs";

      const tr = document.createElement("tr");
      tr.className = "border-b border-gray-100 hover:bg-gray-50 cursor-pointer";
      tr.innerHTML = `
        <td class="py-3 px-4 font-semibold text-gray-800">${nota.nu_documento}</td>
        <td class="py-3 px-4 text-gray-600">${nota.sacado}</td>
        <td class="py-3 px-4 text-gray-600">${nota.dias_vencimento} dias</td>
        <td class="py-3 px-4 font-medium text-gray-800">R$ ${Number(nota.valor_nominal).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</td>
        <td class="py-3 px-4 text-right">
          <span class="${badgeClass}">${nota.status}</span>
        </td>
      `;

      // Ao clicar em uma linha aprovada, atualiza o card inferior de simulação
      if (isAprovada) {
        tr.addEventListener("click", () => this.destacarSimulacao(nota));
      }

      this.tabelaCorpoTarget.appendChild(tr);
    });
  }

  renderizarBannersDeRecusa(notas) {
    // Filtra as notas recusadas
    const recusadas = notas.filter(n => n.status === "Recusada");

    if (recusadas.length > 0) {
      // Exibe a mensagem da primeira nota recusada no banner do protótipo
      const primeiraRecusada = recusadas[0];
      this.mensagemRecusaTarget.textContent = primeiraRecusada.feedback.mensagem;
      this.bannerRecusaTarget.classList.remove("hidden");
    } else {
      this.bannerRecusaTarget.classList.add("hidden");
    }
  }

  renderizarSimulacaoETotais(dados) {
    const primeiraAprovada = dados.notas.find(n => n.status === "Aprovada");

    if (primeiraAprovada) {
      this.destacarSimulacao(primeiraAprovada);
    }

    if (this.hasResumoTotalTarget) {
      this.resumoTotalTarget.textContent = `R$ ${Number(dados.resumo.total_a_receber).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;
    }
  }

  destacarSimulacao(nota) {
    const valorFormatado = Number(nota.valor_liquido).toLocaleString('pt-BR', { minimumFractionDigits: 0 });
    this.cardSimulacaoTarget.innerHTML = `
      <div class="flex items-center justify-between text-white font-medium">
        <span>Simulação · ${nota.nu_documento}</span>
        <span class="text-xl font-bold">R$ ${valorFormatado}</span>
      </div>
    `;
    this.cardSimulacaoTarget.classList.remove("hidden");
  }

  exibirErroEstrutural(mensagem) {
    this.mensagemErroEstruturalTarget.textContent = mensagem;
    this.cardErroEstruturalTarget.classList.remove("hidden");
    this.bannerRecusaTarget.classList.add("hidden");
    this.cardSimulacaoTarget.classList.add("hidden");
  }

  limparErros() {
    this.cardErroEstruturalTarget.classList.add("hidden");
  }
}