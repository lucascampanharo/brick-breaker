# Brick Breaker

Projeto Integrador VI-A - Entrega da 1ª etapa do grupo 8.

### Objetivo do Projeto

O objetivo do projeto é criar o jogo Brick Breaker para celular, aplicando os conhecimentos aprendidos nas matérias da disciplina.

Arquivos adicionados na pasta docs.

- [Definições do Projeto](docs/definicoes-projeto.md): Arquivo com as tecnologias escolhidas e com a definição de como será gerada a APK;
- [Construção Parede de Blocos](docs/construcao-parede-de-blocos.md): Arquivo com a definição de como será estruturada a parede de blocos do jogo;
- [Wireframes das Telas](docs/wireframes.md): Arquivo com o design criado para o jogo, todas as imagens foram adicionadas na pasta assets/imgs;

### Validação dos layouts

As telas usam uma largura lógica de 720 pixels e se adaptam à altura disponível.
Os estilos ficam em `scripts/ui_style.gd`; a arena, o cabeçalho e o painel final
das cinco fases são compartilhados em `scripts/level_base.gd`.

Execute com o Godot 4 disponível no PATH:

```powershell
godot --headless --path . --resolution 720x1280 --script tests/settings_integration.gd
godot --headless --path . --script tests/ball_collision_integration.gd
godot --headless --path . --script tests/layout_integration.gd
```

O teste de layout cobre 720×1280, 720×1560 e 1080×2340, incluindo as combinações
de grades e paletas em todas as fases e o redimensionamento durante a partida.
Para gerar capturas usando renderização gráfica:

```powershell
godot --path . --rendering-method gl_compatibility --script tests/layout_integration.gd -- --capture
```

As 27 capturas são salvas em `.godot/layout-captures/`, sem adicionar arquivos
gerados ao repositório. Compare-as com a área interna das telas em `docs/assets/imgs`.
