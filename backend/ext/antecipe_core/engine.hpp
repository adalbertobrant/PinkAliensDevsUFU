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
    std::string data_vencimento;     // dd/mm/aaaa (original)
    long data_vencimento_dias = 0;   // dias desde epoch (para NAO_VENCIDA)
    double valor_nominal = 0.0;
    long prazo_dias = 0;             // vencimento - aquisicao
    // resultados
    std::vector<std::string> motivos;
    double valor_liquido = 0.0;
};

struct Config {
    int prazo_maximo_dias = 180;
    int prazo_minimo_dias = 30;                 // PRAZO_MINIMO (inativo por padrão)
    double valor_minimo = 100.0;
    double concentracao_percentual = 10.0;      // CONCENTRACAO_MAXIMA_SACADO
    double concentracao_cedente_percentual = 8.0; // CONCENTRACAO_MAXIMA_CEDENTE (inativo)
    double taxa_mensal_percentual = 2.0;        // precificacao
    int base_dias = 30;                         // precificacao
    std::string agrupamento = "RAIZ_CNPJ";      // agrupamento da concentração
    long data_base_dias = 0;                    // data base p/ NAO_VENCIDA (22/10/2026)
    std::unordered_set<std::string> tipos_aceitos;
    std::unordered_set<std::string> situacoes_aceitas;   // ["ATIVA"]
    std::unordered_set<std::string> validadores_ativos;  // códigos com ativo:true
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
    if (d.size() < 10) return 0;
    int dia = std::stoi(d.substr(0,2));
    int mes = std::stoi(d.substr(3,2));
    int ano = std::stoi(d.substr(6,4));
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

// Valida CNPJ (14 dígitos + dígitos verificadores)
inline bool cnpj_valido(const std::string& cnpj) {
    std::string d = so_digitos(cnpj);
    if (d.size() != 14) return false;
    bool todos_iguais = true;
    for (int i = 1; i < 14; i++) if (d[i] != d[0]) { todos_iguais = false; break; }
    if (todos_iguais) return false;
    static const int p1[] = {5,4,3,2,9,8,7,6,5,4,3,2};
    static const int p2[] = {6,5,4,3,2,9,8,7,6,5,4,3,2};
    int soma = 0;
    for (int i = 0; i < 12; i++) soma += (d[i]-'0') * p1[i];
    int r = soma % 11;
    int d1 = r < 2 ? 0 : 11 - r;
    if (d1 != d[12]-'0') return false;
    soma = 0;
    for (int i = 0; i < 13; i++) soma += (d[i]-'0') * p2[i];
    r = soma % 11;
    int d2 = r < 2 ? 0 : 11 - r;
    return d2 == d[13]-'0';
}

class MotorRegras {
public:
    Config cfg;
    std::unordered_set<std::string> estoque;      // nu_doc|doc_cedente
    std::unordered_map<std::string, std::string> situacao; // cnpj_normalizado -> situacao

    void carregar_config(const std::string& json_path) {
        // Padrões seguros
        cfg.tipos_aceitos = {"Duplicata", "Duplicata de Serviço"};
        cfg.situacoes_aceitas = {"ATIVA"};
        cfg.validadores_ativos = {"CNPJ_SACADO_VALIDO", "SITUACAO_CADASTRAL_SACADO",
                                  "TIPO_RECEBIVEL", "VALOR_MINIMO", "NAO_VENCIDA",
                                  "PRAZO_MAXIMO", "CONCENTRACAO_MAXIMA_SACADO"};
        cfg.data_base_dias = data_para_dias("22/10/2026"); // data base do edital

        std::ifstream f(json_path);
        if (!f.is_open()) return;
        std::stringstream ss; ss << f.rdbuf();
        std::string j = ss.str();

        cfg.validadores_ativos.clear();

        // ---- Precificação (objeto "precificacao") ----
        {
            size_t p = j.find("\"precificacao\"");
            if (p != std::string::npos) {
                size_t ob = j.find('{', p);
                size_t cb = ob != std::string::npos ? j.find('}', ob) : std::string::npos;
                if (ob != std::string::npos && cb != std::string::npos) {
                    std::string bloco = j.substr(ob, cb - ob + 1);
                    auto num = [&](const std::string& key, double def) -> double {
                        size_t k = bloco.find(key);
                        if (k == std::string::npos) return def;
                        size_t c = bloco.find(':', k);
                        if (c == std::string::npos) return def;
                        size_t e = bloco.find_first_of(",}", c);
                        try { return std::stod(trim(bloco.substr(c+1, e-c-1))); } catch (...) { return def; }
                    };
                    cfg.taxa_mensal_percentual = num("\"taxa_mensal_percentual\"", cfg.taxa_mensal_percentual);
                    cfg.base_dias = (int)num("\"base_dias\"", cfg.base_dias);
                }
            }
        }

        // ---- Validadores (array "validadores") ----
        size_t pos = j.find("\"validadores\"");
        if (pos != std::string::npos) pos = j.find('[', pos);
        while (pos != std::string::npos) {
            size_t open = j.find('{', pos);
            if (open == std::string::npos) break;
            size_t close = j.find('}', open);
            if (close == std::string::npos) break;
            std::string bloco = j.substr(open, close - open + 1);

            std::string codigo;
            size_t pc = bloco.find("\"codigo\"");
            if (pc != std::string::npos) {
                size_t q1 = bloco.find('"', pc + 8);
                size_t q2 = q1 != std::string::npos ? bloco.find('"', q1 + 1) : std::string::npos;
                if (q1 != std::string::npos && q2 != std::string::npos)
                    codigo = bloco.substr(q1 + 1, q2 - q1 - 1);
            }

            bool ativo = true;
            size_t pa = bloco.find("\"ativo\"");
            if (pa != std::string::npos) ativo = bloco.find("true", pa) != std::string::npos;

            if (!codigo.empty() && ativo) cfg.validadores_ativos.insert(codigo);

            auto num = [&](const std::string& key, double def) -> double {
                size_t k = bloco.find(key);
                if (k == std::string::npos) return def;
                size_t c = bloco.find(':', k);
                if (c == std::string::npos) return def;
                size_t e = bloco.find_first_of(",}]", c);
                try { return std::stod(trim(bloco.substr(c+1, e-c-1))); } catch (...) { return def; }
            };
            auto arr = [&](const std::string& key) -> std::unordered_set<std::string> {
                std::unordered_set<std::string> out;
                size_t k = bloco.find(key);
                if (k == std::string::npos) return out;
                size_t ob = bloco.find('[', k);
                size_t cb = ob != std::string::npos ? bloco.find(']', ob) : std::string::npos;
                if (ob == std::string::npos || cb == std::string::npos) return out;
                std::string content = bloco.substr(ob + 1, cb - ob - 1);
                size_t s = 0;
                while (true) {
                    size_t q1 = content.find('"', s);
                    if (q1 == std::string::npos) break;
                    size_t q2 = content.find('"', q1 + 1);
                    if (q2 == std::string::npos) break;
                    out.insert(content.substr(q1 + 1, q2 - q1 - 1));
                    s = q2 + 1;
                }
                return out;
            };
            auto str = [&](const std::string& key, const std::string& def) -> std::string {
                size_t k = bloco.find(key);
                if (k == std::string::npos) return def;
                size_t q1 = bloco.find('"', k + key.size());
                size_t q2 = q1 != std::string::npos ? bloco.find('"', q1 + 1) : std::string::npos;
                if (q1 == std::string::npos || q2 == std::string::npos) return def;
                return bloco.substr(q1 + 1, q2 - q1 - 1);
            };

            if (codigo == "TIPO_RECEBIVEL") {
                auto v = arr("\"tipos_aceitos\"");
                if (!v.empty()) cfg.tipos_aceitos = v;
            } else if (codigo == "SITUACAO_CADASTRAL_SACADO") {
                auto v = arr("\"situacoes_aceitas\"");
                if (!v.empty()) cfg.situacoes_aceitas = v;
            } else if (codigo == "VALOR_MINIMO") {
                cfg.valor_minimo = num("\"valor_minimo\"", cfg.valor_minimo);
            } else if (codigo == "PRAZO_MAXIMO") {
                cfg.prazo_maximo_dias = (int)num("\"prazo_maximo_dias\"", cfg.prazo_maximo_dias);
            } else if (codigo == "PRAZO_MINIMO") {
                cfg.prazo_minimo_dias = (int)num("\"prazo_minimo_dias\"", cfg.prazo_minimo_dias);
            } else if (codigo == "CONCENTRACAO_MAXIMA_SACADO") {
                cfg.concentracao_percentual = num("\"percentual_maximo\"", cfg.concentracao_percentual);
                cfg.agrupamento = str("\"agrupamento\"", cfg.agrupamento);
            } else if (codigo == "CONCENTRACAO_MAXIMA_CEDENTE") {
                cfg.concentracao_cedente_percentual = num("\"percentual_maximo\"", cfg.concentracao_cedente_percentual);
            }
            // CNPJ_SACADO_VALIDO e NAO_VENCIDA não têm parâmetros; só o flag ativo importa

            pos = close + 1;
        }
    }

    void carregar_estoque(const std::string& path) {
        std::ifstream f(path);
        if (!f.is_open()) return;
        std::string linha;
        std::getline(f, linha);
        while (std::getline(f, linha)) {
            std::string campos[8]; int n = 0;
            std::stringstream ss(linha);
            while (std::getline(ss, campos[n], ';') && n < 7) n++;
            if (n >= 7) estoque.insert(trim(campos[6]) + "|" + trim(campos[3]));
        }
    }

    void carregar_situacao(const std::string& path) {
        std::ifstream f(path);
        if (!f.is_open()) return;
        std::string linha;
        std::getline(f, linha);
        while (std::getline(f, linha)) {
            size_t p = linha.find(';');
            if (p == std::string::npos) continue;
            situacao[so_digitos(linha.substr(0, p))] = upper(trim(linha.substr(p + 1)));
        }
    }

    std::vector<Nota> parse_csv(const std::string& conteudo) {
        std::vector<Nota> notas;
        notas.reserve(100000);
        std::stringstream ss(conteudo);
        std::string linha;
        bool primeiro = true;
        while (std::getline(ss, linha)) {
            if (linha.empty()) continue;
            if (primeiro) { primeiro = false; continue; }
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
            n.data_vencimento_dias = dv;
            n.prazo_dias = dv - da;
            notas.push_back(std::move(n));
        }
        return notas;
    }

    void processar(std::vector<Nota>& notas, long& aprovadas, long& recusadas,
                   double& total_liquido, bool checar_integridade = false) {
        // Passo 1: agregação (fundo + concentração por raiz CNPJ do sacado)
        std::unordered_map<std::string, double> fundo_total;
        std::unordered_map<std::string, double> conc_sacado;
        std::unordered_map<std::string, double> conc_cedente;
        fundo_total.reserve(32);
        conc_sacado.reserve(notas.size());
        conc_cedente.reserve(notas.size());
        for (const auto& n : notas) {
            fundo_total[n.doc_fundo] += n.valor_nominal;
            std::string raiz_sacado = so_digitos(n.doc_sacado).substr(0, 8);
            std::string raiz_cedente = so_digitos(n.doc_cedente).substr(0, 8);
            conc_sacado[n.doc_fundo + "|" + raiz_sacado] += n.valor_nominal;
            conc_cedente[n.doc_fundo + "|" + raiz_cedente] += n.valor_nominal;
        }

        aprovadas = recusadas = 0;
        total_liquido = 0.0;
        std::unordered_set<std::string> visto_no_lote;
        visto_no_lote.reserve(notas.size());

        for (auto& n : notas) {
            n.motivos.clear();

            // INTEGRIDADE (fluxo real de submissão)
            if (checar_integridade) {
                std::string chave = n.nu_documento + "|" + n.doc_cedente;
                if (estoque.count(chave)) n.motivos.push_back("ERR_STOCK_ALREADY_SOLD");
                if (visto_no_lote.count(chave)) n.motivos.push_back("ERR_BATCH_DUPLICATE");
                else visto_no_lote.insert(chave);
            }

            // CNPJ_SACADO_VALIDO
            if (cfg.validadores_ativos.count("CNPJ_SACADO_VALIDO") &&
                !cnpj_valido(n.doc_sacado)) {
                n.motivos.push_back("CNPJ_SACADO_VALIDO");
            }

            // SITUACAO_CADASTRAL_SACADO (allow-list: só situações aceitas)
            if (cfg.validadores_ativos.count("SITUACAO_CADASTRAL_SACADO")) {
                auto it = situacao.find(so_digitos(n.doc_sacado));
                if (it == situacao.end() || !cfg.situacoes_aceitas.count(it->second)) {
                    n.motivos.push_back("SITUACAO_CADASTRAL_SACADO");
                }
            }

            // TIPO_RECEBIVEL
            if (cfg.validadores_ativos.count("TIPO_RECEBIVEL") &&
                !cfg.tipos_aceitos.count(n.tipo_recebivel)) {
                n.motivos.push_back("TIPO_RECEBIVEL");
            }

            // VALOR_MINIMO
            if (cfg.validadores_ativos.count("VALOR_MINIMO") &&
                n.valor_nominal < cfg.valor_minimo) {
                n.motivos.push_back("VALOR_MINIMO");
            }

            // NAO_VENCIDA (data de vencimento >= data base)
            if (cfg.validadores_ativos.count("NAO_VENCIDA") &&
                n.data_vencimento_dias < cfg.data_base_dias) {
                n.motivos.push_back("NAO_VENCIDA");
            }

            // PRAZO_MAXIMO
            if (cfg.validadores_ativos.count("PRAZO_MAXIMO") &&
                n.prazo_dias > cfg.prazo_maximo_dias) {
                n.motivos.push_back("PRAZO_MAXIMO");
            }

            // PRAZO_MINIMO (inativo por padrão)
            if (cfg.validadores_ativos.count("PRAZO_MINIMO") &&
                n.prazo_dias < cfg.prazo_minimo_dias) {
                n.motivos.push_back("PRAZO_MINIMO");
            }

            // CONCENTRACAO_MAXIMA_SACADO
            if (cfg.validadores_ativos.count("CONCENTRACAO_MAXIMA_SACADO")) {
                std::string raiz = so_digitos(n.doc_sacado).substr(0, 8);
                double ft = fundo_total[n.doc_fundo];
                double cv = conc_sacado[n.doc_fundo + "|" + raiz];
                if (ft > 0 && (cv / ft) * 100.0 > cfg.concentracao_percentual) {
                    n.motivos.push_back("CONCENTRACAO_MAXIMA_SACADO");
                }
            }

            // CONCENTRACAO_MAXIMA_CEDENTE (inativo por padrão)
            if (cfg.validadores_ativos.count("CONCENTRACAO_MAXIMA_CEDENTE")) {
                std::string raiz = so_digitos(n.doc_cedente).substr(0, 8);
                double ft = fundo_total[n.doc_fundo];
                double cv = conc_cedente[n.doc_fundo + "|" + raiz];
                if (ft > 0 && (cv / ft) * 100.0 > cfg.concentracao_cedente_percentual) {
                    n.motivos.push_back("CONCENTRACAO_MAXIMA_CEDENTE");
                }
            }

            if (n.motivos.empty()) {
                aprovadas++;
                // Precificação: desconto simples proporcional ao prazo
                double desconto = n.valor_nominal * (cfg.taxa_mensal_percentual / 100.0)
                                  * ((double)n.prazo_dias / cfg.base_dias);
                n.valor_liquido = n.valor_nominal - desconto;
                total_liquido += n.valor_liquido;
            } else {
                recusadas++;
            }
        }
    }
};

} // namespace antecipe
