#pragma once
#include <string>
#include <vector>
#include <unordered_set>
#include <unordered_map>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cctype>
#include <chrono>

namespace antecipe {

struct Nota {
    std::string nu_documento;
    std::string doc_cedente;
    std::string nome_cedente;
    std::string nome_sacado;
    std::string doc_sacado;
    std::string tipo_recebivel;
    std::string doc_fundo;
    std::string data_vencimento;   // dd/mm/aaaa (original)
    double valor_nominal = 0.0;
    long prazo_dias = 0; // vencimento - aquisicao
    // resultados
    std::vector<std::string> motivos;
    double valor_liquido = 0.0;
};

struct Config {
    int prazo_maximo_dias = 180;
    double valor_minimo = 100.0;
    double concentracao_percentual = 10.0;
    double taxa_desconto = 0.02;
    std::unordered_set<std::string> tipos_aceitos;
    std::unordered_set<std::string> situacoes_irregulares;
};

inline std::string trim(const std::string& s) {
    size_t a = s.find_first_not_of(" \t\r\n");
    if (a == std::string::npos) return "";
    size_t b = s.find_last_not_of(" \t\r\n");
    return s.substr(a, b - a + 1);
}

inline std::string so_digitos(const std::string& s) {
    std::string r;
    r.reserve(s.size());
    for (char c : s) if (std::isdigit((unsigned char)c)) r.push_back(c);
    return r;
}

inline std::string upper(std::string s) {
    for (char& c : s) c = (char)std::toupper((unsigned char)c);
    return s;
}

// data dd/mm/aaaa -> dias desde epoch (aproximado)
inline long data_para_dias(const std::string& d) {
    // d = "dd/mm/aaaa"
    if (d.size() < 10) return 0;
    int dia = std::stoi(d.substr(0,2));
    int mes = std::stoi(d.substr(3,2));
    int ano = std::stoi(d.substr(6,4));
    // dias desde ano 0 (formula simples)
    long dias = 365L * ano + ano/4 - ano/100 + ano/400;
    static const int dm[] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
    for (int i = 1; i < mes; i++) dias += dm[i];
    dias += dia;
    return dias;
}

inline double parse_valor(const std::string& s) {
    std::string t = s;
    std::replace(t.begin(), t.end(), ',', '.');
    try { return std::stod(t); } catch (...) { return 0.0; }
}

class MotorRegras {
public:
    Config cfg;
    std::unordered_set<std::string> estoque;      // nu_doc|doc_cedente
    std::unordered_map<std::string, std::string> situacao; // cnpj_normalizado -> situacao

    void carregar_config(const std::string& json_path) {
        cfg.tipos_aceitos = {"Duplicata", "Duplicata de Serviço"};
        cfg.situacoes_irregulares = {"BAIXADA", "INAPTA", "SUSPENSA"};
        std::ifstream f(json_path);
        if (!f.is_open()) return;
        std::stringstream ss; ss << f.rdbuf();
        std::string j = ss.str();
        // extrair limites via busca simples (evita dependencia de jsoncpp)
        auto find_num = [&](const std::string& key, double def) -> double {
            size_t p = j.find(key);
            if (p == std::string::npos) return def;
            size_t c = j.find(':', p);
            if (c == std::string::npos) return def;
            size_t e = j.find_first_of(",}]", c);
            std::string v = trim(j.substr(c+1, e-c-1));
            try { return std::stod(v); } catch (...) { return def; }
        };
        cfg.prazo_maximo_dias = (int)find_num("\"limite_dias\"", 180.0);
        cfg.valor_minimo = find_num("\"limite_minimo\"", 100.0);
        cfg.concentracao_percentual = find_num("\"limite_percentual\"", 10.0);
        cfg.taxa_desconto = find_num("\"taxa\"", 0.02);
    }

    void carregar_estoque(const std::string& path) {
        std::ifstream f(path);
        if (!f.is_open()) return;
        std::string linha;
        std::getline(f, linha); // header
        while (std::getline(f, linha)) {
            // NU_DOCUMENTO(6) | DOC_CEDENTE(3)
            size_t i = 0; std::string campos[8]; int n = 0;
            std::stringstream ss(linha);
            while (std::getline(ss, campos[n], ';') && n < 7) n++;
            if (n >= 7) {
                estoque.insert(trim(campos[6]) + "|" + trim(campos[3]));
            }
        }
    }

    void carregar_situacao(const std::string& path) {
        std::ifstream f(path);
        if (!f.is_open()) return;
        std::string linha;
        std::getline(f, linha); // header
        while (std::getline(f, linha)) {
            size_t p = linha.find(';');
            if (p == std::string::npos) continue;
            std::string doc = so_digitos(linha.substr(0, p));
            std::string st = upper(trim(linha.substr(p+1)));
            situacao[doc] = st;
        }
    }

    // Parseia CSV (cabeçalho + linhas de dados) em vetor de Nota
    std::vector<Nota> parse_csv(const std::string& conteudo) {
        std::vector<Nota> notas;
        notas.reserve(100000);
        std::stringstream ss(conteudo);
        std::string linha;
        bool primeiro = true;
        while (std::getline(ss, linha)) {
            if (linha.empty()) continue;
            if (primeiro) { primeiro = false; continue; } // skip header
            std::vector<std::string> c;
            c.reserve(11);
            std::stringstream ls(linha);
            std::string campo;
            while (std::getline(ls, campo, ';')) c.push_back(trim(campo));
            if (c.size() < 11) continue;
            Nota n;
            n.doc_fundo = c[1];
            n.nome_cedente = c[2];
            n.doc_cedente = c[3];
            n.nome_sacado = c[4];
            n.doc_sacado = c[5];
            n.nu_documento = c[6];
            n.tipo_recebivel = c[7];
            n.valor_nominal = parse_valor(c[8]);
            n.data_vencimento = c[9];
            long dv = data_para_dias(c[9]);
            long da = data_para_dias(c[10]);
            n.prazo_dias = dv - da;
            notas.push_back(std::move(n));
        }
        return notas;
    }

    // Processa o lote e aplica regras. Retorna contagem via parâmetros.
    void processar(std::vector<Nota>& notas, long& aprovadas, long& recusadas,
                   double& total_liquido, bool checar_integridade = false) {
        // Passo 1: agregar total por fundo e por (fundo, raiz sacado)
        std::unordered_map<std::string, double> fundo_total;
        std::unordered_map<std::string, double> conc; // "fundo|raiz" -> valor
        fundo_total.reserve(32);
        conc.reserve(notas.size());
        for (const auto& n : notas) {
            fundo_total[n.doc_fundo] += n.valor_nominal;
            std::string raiz = so_digitos(n.doc_sacado).substr(0, 8);
            conc[n.doc_fundo + "|" + raiz] += n.valor_nominal;
        }

        // Passo 2: avaliar cada nota (integridade + regras de negócio)
        aprovadas = recusadas = 0;
        total_liquido = 0.0;
        std::unordered_set<std::string> visto_no_lote;
        visto_no_lote.reserve(notas.size());
        for (auto& n : notas) {
            n.motivos.clear();
            // INTEGRIDADE (apenas no fluxo real de submissão de lote)
            if (checar_integridade) {
                std::string chave = n.nu_documento + "|" + n.doc_cedente;
                // título já negociado no estoque histórico
                if (estoque.count(chave)) {
                    n.motivos.push_back("ERR_STOCK_ALREADY_SOLD");
                }
                // duplicado dentro do próprio lote
                if (visto_no_lote.count(chave)) {
                    n.motivos.push_back("ERR_BATCH_DUPLICATE");
                } else {
                    visto_no_lote.insert(chave);
                }
            }
            // TIPO_RECEBIVEL
            if (!cfg.tipos_aceitos.count(n.tipo_recebivel)) {
                n.motivos.push_back("TIPO_RECEBIVEL");
            }
            // PRAZO_MAXIMO
            if (n.prazo_dias > cfg.prazo_maximo_dias) {
                n.motivos.push_back("PRAZO_MAXIMO");
            }
            // VALOR_MINIMO
            if (n.valor_nominal < cfg.valor_minimo) {
                n.motivos.push_back("VALOR_MINIMO");
            }
            // CONCENTRACAO_MAXIMA_SACADO
            std::string raiz = so_digitos(n.doc_sacado).substr(0, 8);
            double ft = fundo_total[n.doc_fundo];
            double cv = conc[n.doc_fundo + "|" + raiz];
            if (ft > 0 && (cv / ft) * 100.0 > cfg.concentracao_percentual) {
                n.motivos.push_back("CONCENTRACAO_MAXIMA_SACADO");
            }
            // SITUACAO_CADASTRAL_SACADO
            std::string doc = so_digitos(n.doc_sacado);
            auto it = situacao.find(doc);
            if (it != situacao.end() && cfg.situacoes_irregulares.count(it->second)) {
                n.motivos.push_back("SITUACAO_CADASTRAL_SACADO");
            }

            if (n.motivos.empty()) {
                aprovadas++;
                n.valor_liquido = n.valor_nominal * (1.0 - cfg.taxa_desconto);
                total_liquido += n.valor_liquido;
            } else {
                recusadas++;
            }
        }
    }
};

} // namespace antecipe
