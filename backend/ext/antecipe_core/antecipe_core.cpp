#include "rice/rice.hpp"
#include "rice/stl.hpp"
#include "engine.hpp"
#include <sstream>
#include <string>
#include <vector>

using namespace Rice;
using namespace antecipe;

// Escapa uma string para uso em JSON (aspas e barra invertida)
static std::string json_esc(const std::string& s) {
    std::string r;
    r.reserve(s.size() + 8);
    for (char c : s) {
        if (c == '"') r += "\\\"";
        else if (c == '\\') r += "\\\\";
        else r += c;
    }
    return r;
}

class Processador {
public:
    Processador() {}

    // Recebe caminhos dos arquivos e carrega tudo em memória
    void configurar(const std::string& config_path,
                    const std::string& estoque_path,
                    const std::string& situacao_path) {
        motor.carregar_config(config_path);
        motor.carregar_estoque(estoque_path);
        motor.carregar_situacao(situacao_path);
    }

    // Processa um lote CSV (conteúdo) e retorna JSON string.
    // checar_integridade: aplica ERR_STOCK_ALREADY_SOLD e ERR_BATCH_DUPLICATE.
    std::string processar(const std::string& conteudo_csv, bool checar_integridade = true) {
        auto notas = motor.parse_csv(conteudo_csv);
        long aprovadas = 0, recusadas = 0;
        double total_liquido = 0.0;
        motor.processar(notas, aprovadas, recusadas, total_liquido, checar_integridade);

        std::ostringstream out;
        out << "{\"resumo\":{\"aprovadas\":" << aprovadas
            << ",\"recusadas\":" << recusadas
            << ",\"total_liquido\":" << total_liquido
            << "},\"notas\":[";
        bool first = true;
        for (auto& n : notas) {
            if (!first) out << ",";
            first = false;
            out << "{\"nu_documento\":\"" << json_esc(n.nu_documento)
                << "\",\"doc_cedente\":\"" << json_esc(n.doc_cedente)
                << "\",\"nome_cedente\":\"" << json_esc(n.nome_cedente)
                << "\",\"nome_sacado\":\"" << json_esc(n.nome_sacado)
                << "\",\"doc_sacado\":\"" << json_esc(n.doc_sacado)
                << "\",\"tipo_recebivel\":\"" << json_esc(n.tipo_recebivel)
                << "\",\"data_vencimento\":\"" << json_esc(n.data_vencimento)
                << "\",\"valor_nominal\":" << n.valor_nominal
                << ",\"prazo_dias\":" << n.prazo_dias
                << ",\"aprovada\":" << (n.motivos.empty() ? "true" : "false")
                << ",\"valor_liquido\":" << n.valor_liquido
                << ",\"motivos\":[";
            for (size_t j = 0; j < n.motivos.size(); j++) {
                if (j) out << ",";
                out << "\"" << json_esc(n.motivos[j]) << "\"";
            }
            out << "]}";
        }
        out << "]}";
        return out.str();
    }

private:
    MotorRegras motor;
};

extern "C"
void Init_antecipe_core() {
    Module rb_m = define_module("AntecipeCore");
    Class rb_c = define_class_under<Processador>(rb_m, "Processador")
        .define_constructor(Constructor<Processador>())
        .define_method("configurar", &Processador::configurar)
        .define_method("processar", &Processador::processar, Arg("checar_integridade") = true);
}
