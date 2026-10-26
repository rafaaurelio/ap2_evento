# ⚔️ Tibia Championship 2026 - App de Ingressos & Check-in

Aplicativo mobile desenvolvido em Flutter para gestão de ingressos e validação de presença via QR Code, com temática customizada de campeonato de Tibia.

Este projeto foi desenvolvido como requisito avaliativo (AP2) para a disciplina de Desenvolvimento Mobile.

---

## 📌 Funcionalidades

- **Emissão de Ingressos:** Formulário para nome e e-mail com geração de passe personalizado e QR Code integrado.
- **Validação de Entrada:** Leitura de QR Code via câmera utilizando a biblioteca `mobile_scanner`.
- **Regras de Negócio e Validação:**
  - `✓ Check-in confirmado`: Entrada liberada para novos participantes.
  - `⚠️ Já fez check-in`: Alerta para QR Codes repetidos.
  - `❌ QR inválido`: Recusa de QR Codes fora do padrão `CHECKIN|nome|e-mail`.
- **Lista de Presença:** Contador dinâmico e listagem dos jogadores confirmados na arena (mantidos em memória durante a execução).

---

## 🛠️ Tecnologias e Pacotes

- **[Flutter](https://flutter.dev/)** (SDK)
- **[qr_flutter (^4.1.0)](https://pub.dev/packages/qr_flutter)** - Geração visual do QR Code do ingresso.
- **[mobile_scanner (^5.0.0)](https://pub.dev/packages/mobile_scanner)** - Leitura e escaneamento do QR Code pela câmera.

---
