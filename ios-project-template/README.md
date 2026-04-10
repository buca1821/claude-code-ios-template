# iOS Project Template

Plantilla reutilizable para crear proyectos iOS con estructura MVVM, Swift 6 y configuraciones de linting/formatting preconfiguradas.

## Que incluye

- **`project.yml.template`** — Template de XcodeGen parametrizable (nombre, bundle ID, deployment target)
- **`.gitignore`** — Gitignore estandar para proyectos iOS
- **`.swiftlint.yml.template`** — Configuracion moderada de SwiftLint
- **`.swiftformat`** — Configuracion de SwiftFormat
- **`setup-project.sh`** — Script que genera toda la estructura del proyecto

### Estructura generada

```
MyApp/
├── MyApp/
│   ├── App/
│   │   ├── MyAppApp.swift
│   │   ├── AppEnvironment.swift
│   │   ├── Constants.swift
│   │   └── ContentView.swift
│   ├── Features/
│   ├── Services/
│   ├── Core/
│   │   ├── Models/
│   │   └── Utilities/
│   └── DesignSystem/
├── MyAppTests/
│   └── MyAppTests.swift
├── .gitignore
├── .swiftlint.yml
├── .swiftformat
├── project.yml
└── MyApp.xcodeproj/
```

## Requisitos previos

- **Xcode 16+**
- **xcodegen** — Instalar con `brew install xcodegen`
- (Opcional) **swiftlint** — `brew install swiftlint`
- (Opcional) **swiftformat** — `brew install swiftformat`

## Uso

1. Ejecutar el script de scaffolding:

   ```bash
   bash /path/to/ios-project-template/setup-project.sh
   ```

2. Seguir las instrucciones interactivas (nombre del proyecto, bundle ID, deployment target, directorio).

3. Aplicar la configuracion de Claude Code desde el repo principal:

   ```bash
   cd tu-proyecto && bash /path/to/claude-code-ios-template/setup.sh
   ```

4. Inicializar git:

   ```bash
   cd tu-proyecto && git init && git add . && git commit -m "chore: initial project scaffolding"
   ```

5. Abrir en Xcode:

   ```bash
   open tu-proyecto/NombreProyecto.xcodeproj
   ```
