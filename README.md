# +Vocab — Flutter App

App mobile de aprendizado de inglês com repetição espaçada (Sistema de Leitner) e exercícios gerados por IA.

## Organização do Projeto

Utilizamos o padrão **feature-first**, onde cada funcionalidade do app tem sua própria pasta com tudo que precisa.

```
lib/
├── main.dart
├── core/                  → serviços e utilitários compartilhados (não visuais)
│   ├── services/          → ApiClient, StorageService, AuthInterceptor
│   ├── common_models/     → modelos globais (User, etc)
│   └── theme/             → paleta de cores e estilos
├── components/            → widgets visuais compartilhados entre features
└── features/
    ├── auth/              → login, cadastro, recuperação de senha
    ├── home/              → tela principal com resumos
    ├── temas/             → CRUD de temas e cards
    ├── pratica/           → criação e execução dos exercícios
    ├── vocabulario/       → lista de palavras do usuário
    ├── progresso/         → estatísticas e progresso
    └── configs/           → configurações e logout
```

Cada feature segue a mesma estrutura interna:

```
feature/
├── views/        → telas completas
├── components/   → widgets específicos da feature
├── controllers/  → gerência de estado (Provider / ChangeNotifier)
└── models/       → chamadas à API e lógica de negócio
```

## Tecnologias

- Flutter 3.41.7 (gerenciado via FVM)
- Provider — gerência de estado
- Dio — cliente HTTP
- Flutter Secure Storage — armazenamento seguro de tokens
- Google Fonts (Lexend)

## Como rodar

```bash
fvm flutter pub get
fvm flutter run
```
