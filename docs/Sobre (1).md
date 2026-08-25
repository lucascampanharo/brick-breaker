# Projeto Integrador - Brick Breaker

Sobre o projeto:

A tecnologia escolhida para o projeto é o Godot 4 + GDScript. A escolha dessas tecnologias foi feita com o intuito de facilitar o desenvolvimento, tendo em vista que a linguagem GDScript é uma linguagem de script simples e fácil de aprender, mas com poder de desenvolvimento robusto.

Godot 4 é a engine utilizada para desenvolver o jogo, enquanto o GDScript é a linguagem de programação usada dentro dela para criar as regras, comportamentos e interações do jogo.

Os ambientes de desenvolvimento serão Visual Studio Code, Zed IDE e Godot Engine. Esses ambientes de desenvolvimento serão usados para escrever e testar o código do projeto.

## Geração do arquivo APK:

Para a geração do arquivo APK, serão possíveis duas formas, a primeira é via exportação do projeto no Godot Engine e a segunda é via a linha de comando.

### Exportação via Godot Engine:

Para exportar o projeto via Godot Engine, siga os seguintes passos:

1. Abra o Godot Engine e carregue o projeto.
2. Vá para o menu `Export` e selecione `Export Project`.
3. Escolha a plataforma desejada (Android, Windows, etc.) e configure as opções de exportação.
4. Clique em `Export` para gerar o arquivo APK.

### Exportação via linha de comando:

Para exportar o projeto via linha de comando, use o seguinte comando:

```
godot --headless --export <plataforma> <caminho_do_arquivo>
```
