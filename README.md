<div align="center">

# ⚡ WDCx64 (WinDebloatCleanX64)
### *Otimizador Definitivo para Windows 10 e 11 – Menos Latência, Foco Gamer e Máximo Desempenho*

[![Windows](https://img.shields.io/badge/Plataforma-Windows%2010%20%7C%2011%20(x64)-0078D6?style=for-the-badge&logo=windows)](https://github.com/EduTechSoftware/WDCx64)
[![PowerShell](https://img.shields.io/badge/Linguagem-PowerShell%20%2F%20WPF-5391FE?style=for-the-badge&logo=powershell)](https://github.com/EduTechSoftware/WDCx64)
[![License](https://img.shields.io/badge/Licen%C3%A7a-MIT-00FF9D?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Est%C3%A1vel-brightgreen?style=for-the-badge)]()

<br/>

> **WDCx64 (WinDebloatClean)** é uma suíte completa de limpeza, privacidade e otimização profunda para Windows 10 e 11. Desenvolvido para erradicar bloatwares, encerrar telemetrias abusivas, exterminar processos pesados em segundo plano e entregar a menor latência possível para jogos e produtividade.

</div>

---

## 📊 Resultados Reais de Desempenho

Diferente de ferramentas que prometem "milagres" sem comprovação, o **WDCx64** atua diretamente nos gargalos do kernel do Windows.

| Métrica | Windows Padrão de Fábrica | Com WDCx64 | Ganho Obtido |
| :--- | :---: | :---: | :---: |
| **Processos Ativos em Repouso** | 160 ~ 220+ | **~74 processos** | **-60% de processos** |
| **Uso de CPU em Repouso** | 3% ~ 12% oscilando | **0% Estável** | **Zero consumo inútil** |
| **Memória RAM (Base 32 GB)** | 5,5 GB ~ 6,5 GB | **2,7 GB (0 MB compactada)** | **+3,5 GB livres** |
| **Micro-travamentos (*Stuttering*)** | Frequentes (Telemetria/WebView2) | **Eliminados (Timer em 0.5ms)** | **Fluidez constante** |

> *(Testado em ambiente real: Intel Xeon E5-2698 v3 + AMD Radeon RX 5500 XT + 32 GB RAM).*

---

## ✨ Principais Funcionalidades

### 🎮 1. Turbo Gamer & Latência Mínima
* **HAGS (Hardware-Accelerated GPU Scheduling):** Passa a gestão de memória de vídeo diretamente para a placa de vídeo.
* **Prioridade de GPU MMCSS (Nível 8):** Dá prioridade máxima de processamento gráfico aos jogos sobre qualquer outro software.
* **Ping Turbo (TCP NoDelay / Sem algoritmo de Nagle):** Envia pacotes de rede imediatamente sem tempo de espera, diminuindo o ping em jogos online.
* **Timer Resolution BCD (0.5ms):** Força o relógio interno do sistema para alta precisão, erradicando micro-stutters em jogos competitivos.
* **CPU Foreground Quantum:** Aloca tempo máximo de ciclos de processador para o jogo ou aplicativo em tela cheia.
* **Plano de Desempenho Máximo:** Desbloqueia o perfil oculto de energia de maior desempenho da Microsoft.

### 🛡️ 2. Privacidade, Telemetria & Extermínio de Processos Pesados
* **Extermínio do Microsoft Edge WebView2 na Pesquisa:** Aplica *override* definitivo de engenharia para que o `SearchHost.exe` volte a ser 100% nativo e local, sem abrir 6 processos comedores de RAM em segundo plano.
* **Bloqueio Silencioso do Google Updater (`updater.exe`):** Impede via Diretivas de Grupo (GPO) e permissões restritas que o Google abra dezenas de tarefas em segundo plano (sem erros de RunDLL).
* **Desativação Total de Telemetria:** Bloqueia envio de diagnósticos, dados de uso, anúncios no Iniciar e sugestões da tela de bloqueio.
* **Remoção de Copilot e Recall:** Desativa inteligências artificiais invasivas que realizam capturas e varreduras em segundo plano.

### 🗑️ 3. Limpeza Profunda de Bloatwares & Sistema
* **Remoção de 70+ Bloatwares:** Limpeza completa de jogos promocionais, apps inúteis pré-instalados e aplicativos corporativos desnecessários.
* **Limpeza de Arquivos Temporários (%TEMP% e Prefetch):** Liberação imediata de espaço em disco ocupado por resíduos digitais.
* **Limpeza Profunda do Windows Update (DISM):** Remove arquivos de versões antigas de atualizações para enxugar gigabytes do SSD.
* **Desativação da Inicialização Rápida (*Hiberboot*):** Impede o acúmulo de cache corrompido de drivers ao longo do tempo.

### 🏪 4. Loja de Programas Integrada (WinUtil / Winget)
* Catálogo com mais de **100 programas essenciais** divididos por categorias (Navegadores, Jogos/Launchers, Comunicação, Desenvolvimento, Ferramentas Pro).
* Instalação silenciosa e automatizada em lote utilizando o gerenciador oficial `winget`.

---

## 🔒 Segurança em Primeiro Lugar

O **WDCx64** foi construído com foco em segurança do usuário:
1. **Ponto de Restauração Obrigatório:** A ferramenta bloqueia as otimizações e só permite a execução após criar um Ponto de Restauração no Windows.
2. **Sem cortes destrutivos:** Não remove componentes vitais do sistema nem quebra o funcionamento de drivers, áudio ou rede.
3. **Reinicialização Segura:** Conta com aviso visual em destaque e cronômetro com cancelamento caso o usuário deseje reiniciar mais tarde.

---

## 🚀 Como Executar

### Opção 1: Baixando o Executável (.exe)
1. Acesse a aba de **[Releases](https://github.com/EduTechSoftware/WDCx64/releases)** à direita.
2. Baixe o arquivo **`WDCx64.exe`**.
3. Execute como **Administrador**.

### Opção 2: Via Script PowerShell (.ps1)
1. Baixe o arquivo `WDCx64.ps1`.
2. Clique com o botão direito no arquivo e escolha **"Executar com o PowerShell"** como Administrador.

---

## 💡 Presets Pré-configurados

* **Padrão:** Otimizações essenciais de privacidade, limpeza de temporários e remoção de bloatwares comuns sem alterar o visual.
* **Recomendado:** Ajustes finos de rede, remoção do OneDrive, ativação do plano de Desempenho Máximo e bloqueio de telemetria.
* **Ativar Modo Gamer:** Liga todos os motores de hardware, HAGS, TCP NoDelay, Timer Resolution e prioridade total de GPU.
* **Desmarcar Tudo:** Limpa as opções para você personalizar manualmente cada checkbox conforme sua preferência.

---

## 🛡️ Nota sobre Falsos Positivos

Como o arquivo executável `.exe` é gerado a partir de um script PowerShell empacotado e executa comandos de registro e sistema como Administrador, alguns antivírus mais sensíveis podem exibir alertas de "aplicativo desconhecido". 
* **O código-fonte é 100% aberto e transparente.**
* Você pode inspecionar cada linha do arquivo `.ps1` antes de executar.

---

## 🤝 Desenvolvedor & Créditos

* Criado e desenvolvido por: **EduTechSoftware**
* Inspirado na arquitetura de catálogo modular do WinUtil e ferramentas similares da atualidade.
* Compilado através do utilitário open-source **Win-PS2EXE**.

---

## 📜 Licença

Distribuído sob a licença **MIT**. Consulte o arquivo `LICENSE` para obter mais detalhes.
