; Script di installazione per Quiz Generator Pro v1.0
; SALVARE IN: Cartella del progetto > devops > installer_script.iss

#define MyAppName "Quiz Generator Pro"
#define MyAppVersion "1.0"
#define MyAppPublisher "Gabriele"
#define MyAppExeName "quiz_generator_pro.exe"

[Setup]
; --- CONFIGURAZIONE ---
AppId={{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
; *** FIX PERMESSI: Installiamo in AppData/Local ***
DefaultDirName={localappdata}\{#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=QuizGeneratorSetup_v1
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Salva l'installer nella cartella principale del progetto
OutputDir=..\

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; --- FILE AUTOMATICI (Prende sempre l'ultima build fresca) ---

; 1. Backend (prende direttamente dalla cartella dist generata da PyInstaller)
Source: "..\backend\dist\quiz_backend\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs createallsubdirs

; 2. Frontend (prende direttamente dalla cartella build di Flutter)
Source: "..\frontend\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; 3. Launcher (prende il file .bat che hai nella cartella devops)
Source: "AVVIA_QUIZ.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Collegamento Desktop che lancia il BAT ma mostra l'icona dell'EXE
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\AVVIA_QUIZ.bat"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
; Collegamento Menu Start
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\AVVIA_QUIZ.bat"; IconFilename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\AVVIA_QUIZ.bat"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent