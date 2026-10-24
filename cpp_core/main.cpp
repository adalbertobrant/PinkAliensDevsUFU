// Standalone test harness para o motor de regras
#include "engine.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <chrono>

using namespace antecipe;

int main(int argc, char** argv) {
    std::string estoque_path = "arquivos/estoque_antecipe.csv";
    std::string situacao_path = "arquivos/cnpj_situacao_mock.csv";
    std::string config_path = "arquivos/validadores_antecipe.json";
    std::string input_path = "arquivos/estoque_antecipe.csv"; // default: processa o proprio estoque

    if (argc > 1) estoque_path = argv[1];
    if (argc > 2) situacao_path = argv[2];
    if (argc > 3) config_path = argv[3];
    if (argc > 4) input_path = argv[4];

    MotorRegras m;
    auto t0 = std::chrono::high_resolution_clock::now();
    m.carregar_config(config_path);
    m.carregar_estoque(estoque_path);
    m.carregar_situacao(situacao_path);
    auto t1 = std::chrono::high_resolution_clock::now();

    // ler input
    std::ifstream f(input_path);
    std::stringstream ss; ss << f.rdbuf();
    std::string conteudo = ss.str();

    auto notas = m.parse_csv(conteudo);
    auto t2 = std::chrono::high_resolution_clock::now();

    long aprovadas = 0, recusadas = 0;
    double total_liquido = 0.0;
    m.processar(notas, aprovadas, recusadas, total_liquido);
    auto t3 = std::chrono::high_resolution_clock::now();

    auto ms = [](auto a, auto b){ return std::chrono::duration_cast<std::chrono::milliseconds>(b-a).count(); };

    std::cerr << "=== RESULTADOS ===" << std::endl;
    std::cerr << "carregamento (config+estoque+situacao): " << ms(t0,t1) << " ms" << std::endl;
    std::cerr << "parse CSV: " << ms(t1,t2) << " ms (" << notas.size() << " linhas)" << std::endl;
    std::cerr << "processamento: " << ms(t2,t3) << " ms" << std::endl;
    std::cerr << "TOTAL: " << ms(t0,t3) << " ms" << std::endl;
    std::cerr << "aprovadas=" << aprovadas << " recusadas=" << recusadas
              << " total_liquido=" << total_liquido << std::endl;

    // saída JSON
    std::cout << "[";
    for (size_t i = 0; i < notas.size(); i++) {
        auto& n = notas[i];
        if (i) std::cout << ",";
        std::cout << "{\"linha\":" << (i+2) << ",\"id\":\"" << n.nu_documento << "\",\"status\":\""
                  << (n.motivos.empty() ? "APROVADO" : "BARRADO") << "\"";
        if (!n.motivos.empty()) {
            std::cout << ",\"barrado_por\":[";
            for (size_t j = 0; j < n.motivos.size(); j++) {
                if (j) std::cout << ",";
                std::cout << "\"" << n.motivos[j] << "\"";
            }
            std::cout << "]";
        }
        std::cout << "}";
    }
    std::cout << "]" << std::endl;
    return 0;
}
