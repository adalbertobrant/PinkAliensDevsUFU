#include "rice/rice.hpp"
#include "rice/stl.hpp"
#include <string>
#include <vector>
#include <map>
#include <unordered_set>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <iostream>
#include <chrono>
#include <iomanip>

using namespace Rice;

struct RecebivelLinha {
    std::string nu_documento;
    std::string doc_cedente;
    std::string nome_cedente;
    std::string nome_sacado;
    std::string doc_sacado;
    std::string tipo_recebivel;
    std::string valor_nominal_str;
    std::string data_vencimento;
    std::string data_aquisicao;
    double valor_nominal;
    int prazo_dias;
};

class ProcessadorRecebiveis {
private:
    std::unordered_set<std::string> estoque_hash_set;
    std::unordered_set<std::string> cnpj_situacao_hash_set;
    std::map<std::string, std::string> cnpj_situacao_map;
    int limite_prazo_maximo = 60;
    double limite_valor_minimo = 1000.0;
    
public:
    ProcessadorRecebiveis() {
        carregar_estoque();
        carregar_cnpj_situacao();
        carregar_validadores();
    }
    
    void carregar_estoque() {
        std::ifstream file("../../arquivos/estoque_antecipe.csv");
        if (!file.is_open()) {
            file.open("../arquivos/estoque_antecipe.csv");
        }
        if (!file.is_open()) {
            file.open("arquivos/estoque_antecipe.csv");
        }
        std::string linha;
        std::getline(file, linha); // header
        while (std::getline(file, linha)) {
            std::stringstream ss(linha);
            std::string campo;
            std::vector<std::string> campos;
            while (std::getline(ss, campo, ';')) {
                campos.push_back(campo);
            }
            if (campos.size() >= 7) {
                std::string chave = campos[6] + "|" + campos[3]; // NU_DOCUMENTO|DOC_CEDENTE
                estoque_hash_set.insert(chave);
            }
        }
        file.close();
    }
    
    void carregar_cnpj_situacao() {
        std::ifstream file("../../arquivos/cnpj_situacao_mock.csv");
        if (!file.is_open()) {
            file.open("../arquivos/cnpj_situacao_mock.csv");
        }
        if (!file.is_open()) {
            file.open("arquivos/cnpj_situacao_mock.csv");
        }
        std::string linha;
        std::getline(file, linha); // header
        while (std::getline(file, linha)) {
            std::stringstream ss(linha);
            std::string doc, situacao;
            std::getline(ss, doc, ';');
            std::getline(ss, situacao);
            // normalizar
            std::string doc_norm = doc;
            doc_norm.erase(std::remove_if(doc_norm.begin(), doc_norm.end(), 
                [](unsigned char c) { return !isdigit(c); }), doc_norm.end());
            std::string chave_hash = doc_norm; // simplificado
            cnpj_situacao_map[doc_norm] = situacao;
            cnpj_situacao_hash_set.insert(doc_norm);
        }
        file.close();
    }
    
    void carregar_validadores() {
        // Carrega validadores_antecipe.json
    }
    
    std::string normalizar_numero(const std::string& str) {
        std::string s = str;
        // Substituir vírgula por ponto
        for (size_t i = 0; i < s.length(); i++) {
            if (s[i] == ',') s[i] = '.';
        }
        return s;
    }
    
    int calcular_prazo_dias(const std::string& data_venc) {
        // Data base: 22/10/2026
        int dia_v = std::stoi(data_venc.substr(0,2));
        int mes_v = std::stoi(data_venc.substr(3,2));
        int ano_v = std::stoi(data_venc.substr(6,4));
        int dia_b = 22, mes_b = 10, ano_b = 2026;
        // Cálculo simplificado
        int dias = (ano_v - ano_b) * 365 + (mes_v - mes_b) * 30 + (dia_v - dia_b);
        return dias;
    }
    
    std::string normalizar_cnpj(const std::string& cnpj) {
        std::string s = cnpj;
        s.erase(std::remove_if(s.begin(), s.end(), 
            [](unsigned char c) { return !isdigit(c); }), s.end());
        return s;
    }
    
    Object processar_chunk(Object chunk_data) {
        Array resultado;
        // Processamento simplificado - será expandido
        return resultado;
    }
    
    std::string calcular_hash_chave(const std::string& nu_doc, const std::string& doc_cedente) {
        return nu_doc + "|" + doc_cedente;
    }
};

extern "C"
void Init_antecipe_core() {
    Module rb_mAntecipeCore = define_module("AntecipeCore");
    Class rb_cProcessador = define_class_under<ProcessadorRecebiveis>(rb_mAntecipeCore, "Processador")
        .define_constructor(Constructor<ProcessadorRecebiveis>())
        .define_method("processar_chunk", &ProcessadorRecebiveis::processar_chunk)
        .define_method("calcular_hash_chave", &ProcessadorRecebiveis::calcular_hash_chave);
}
