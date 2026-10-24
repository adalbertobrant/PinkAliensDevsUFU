# Carrega o wrapper Ruby do motor de regras (extensão C++ via Rice).
# O arquivo define `Antecipe::Motor` e já carrega `antecipe_core.so`.
require Rails.root.join('lib', 'antecipe_core').to_s
