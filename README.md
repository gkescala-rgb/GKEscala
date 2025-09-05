# frontend

# Sistema de Gestão de Escalas - Frontend Flutter

Este é o frontend em Flutter para o Sistema de Gestão de Escalas, uma aplicação completa para gerenciamento de professores, salas de aula, temas e escalas educacionais.

## ✨ Características

- **🎨 Design Moderno**: Interface clean com cores laranja/terracota, modo claro e escuro
- **📱 Multiplataforma**: Funciona na Web, Android e iOS
- **🔐 Autenticação Completa**: Sistema de login/registro com JWT
- **⚡ Gerenciamento de Estado**: Utilizando BLoC pattern
- **🌐 Integração com API**: Consumo completo das rotas do backend NestJS
- **🎯 Arquitetura Escalável**: Organização modular e limpa

## 🚀 Instalação e Execução

### Pré-requisitos

- Flutter SDK (versão 3.9.0 ou superior)
- Dart SDK
- Backend NestJS rodando em `http://localhost:3000`

### Instalação

1. **Instale as dependências**:
```bash
flutter pub get
```

2. **Execute o projeto**:

Para Web:
```bash
flutter run -d chrome
```

Para Android (com dispositivo/emulador):
```bash
flutter run -d android
```

## 📋 Funcionalidades

### 🔐 Autenticação
- ✅ Tela de login com validação
- ✅ Tela de registro
- ✅ Gerenciamento de token JWT
- ✅ Proteção de rotas

### 🏠 Dashboard
- ✅ Visão geral do sistema
- ✅ Cards de navegação rápida
- ✅ Interface diferenciada para admin

### 👥 Professores, 🏫 Salas, 📚 Temas, 📅 Escalas
- 🔧 Em desenvolvimento

## 🎨 Design

Paleta de cores baseada em tons de laranja e terracota com suporte a modo claro e escuro.

## 📦 Dependências Principais

- flutter_bloc, go_router, dio, flutter_secure_storage, flex_color_scheme

## 🔧 Configuração

API configurada para `http://localhost:3000`. Para alterar, edite `lib/core/network/api_client.dart`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
