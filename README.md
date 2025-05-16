# 📷 Unifei Camera App

Aplicativo educativo para experimentos com composição de cores RGB, desenvolvido para aulas de física e tecnologia.

## 🎯 Objetivo
Demonstrar na prática como as cores vermelho, verde e azul (RGB) se combinam para formar imagens coloridas, através de:
- Captura de imagens com filtros de cores
- Processamento digital de imagens
- Recombinação dos canais de cores

## 👨‍🎓 Público-Alvo
| Nível | Aplicação |
|-------|-----------|
| Ensino Médio | Introdução à óptica e teoria das cores |
| Graduação em Física | Experimentos com processamento digital de imagens |

## 🛠️ Funcionalidades
1. **Captura Sequencial**
    - 3 imagens com filtros: 🔴 Vermelho, 🟢 Verde, 🔵 Azul
2. **Processamento**
    - Isolamento de canais de cor
    - Aplicação de filtros monocromáticos
3. **Combinação RGB**
    - Síntese aditiva de cores
    - Geração de imagem colorida final

## 📲 Como Usar
1. Conceder permissões de câmera e armazenamento
2. Capturar na ordem:
   Azul → 2. Verde → 3. Vermelho
3. Combinar as imagens
4. Visualizar o resultado colorido

## 🧪 Experimentos Sugeridos
1. **Efeito de ausência de canal**
- Omitir uma das capturas e observar o resultado
2. **Ordem de captura**
- Testar diferentes sequências de filtros
3. **Objetos coloridos**
- Comparar resultados com objetos de cores puras

## ⚙️ Tecnologias Utilizadas
- Flutter (Dart)
- Biblioteca `image` para processamento
- `image_picker` para captura
- `path_provider` para armazenamento

## 📚 Fundamentos Teóricos
```plaintext
Teoria Tricromática:
L + M + S → Visão colorida
(vermelho) (verde) (azul)

O aplicativo simula o processo de:
1. Separação espectral
2. Recombinação aditiva
