<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./README/vapelogo-white.png">
    <source media="(prefers-color-scheme: light)" srcset="./README/vapelogo-dark.png">
    <img width="420" alt="Vape V4" src="./README/vapelogo.png">
  </picture>
</p>

<p align="center">
  Interface modular para Roblox Luau, com carregamento resiliente e camada de compatibilidade Orion.
</p>

<p align="center">
  <a href="docs/ARCHITECTURE.md">Arquitetura</a> ·
  <a href="docs/UI_API.md">API da UI</a> ·
  <a href="docs/ORION_COMPATIBILITY.md">Compatibilidade Orion</a>
</p>

## Início rápido

```luau
loadstring(game:HttpGet(
	'https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/NewMainScript.lua',
	true
))()
```

> Este fork aponta para `vze7/VapeCompiled`. Para trocar o destino, defina `shared.VapeRepository = 'usuario/repositorio'` antes do loader.

## Estrutura

| Área | Responsabilidade |
|---|---|
| `NewMainScript.lua` | Bootstrap, versão, cache e recuperação de falhas |
| `src/main.lua` | Carregamento paralelo da UI e módulos |
| `src/guis/new` | Interface, componentes, temas e perfis |
| `src/games/universal - base` | Módulos disponíveis em qualquer experiência |
| `src/games/<jogo>` | Integrações específicas por `PlaceId` |
| `src/libraries/orioncompat.lua` | Ponte da API Orion para componentes Vape |
| `OrionLoader.lua` | Entrypoint drop-in que retorna a ponte Orion do Vape |

Exemplos executáveis: [`examples/OrionVapeSmokeTest.lua`](examples/OrionVapeSmokeTest.lua) e [`examples/FireHubUiCompatibilityTest.lua`](examples/FireHubUiCompatibilityTest.lua).

## Melhorias desta versão

- cache preservado durante falhas temporárias;
- downloads com validação, retry e backoff;
- UI, universal e módulo do jogo buscados paralelamente;
- assets Roblox nativos sem download redundante;
- perfis gravados somente quando mudam;
- build com Node fixado, instalação enxuta e cancelamento de execução antiga;
- tabs e múltiplas sections no adaptador Orion;
- dropdown único/múltiplo, pesquisável, agrupado, com ícones e players dinâmicos.

## Desenvolvimento

O fonte é montado pelo [VapeBundler](https://github.com/7GrandDadPGN/VapeBundler). Arquivos parciais em `src/` não são necessariamente executáveis sozinhos. Leia a [arquitetura](docs/ARCHITECTURE.md) antes de alterar a publicação.

### Usar script Orion existente

Carregue o Vape primeiro usando o link acima. Depois, no script Orion, substitua somente a URL do `Loader.lua` por:

```text
https://raw.githubusercontent.com/vze7/VapeV4ForRoblox/codex/orion-compat/OrionLoader.lua
```

Todo o restante (`MakeWindow`, tabs, sections e controles) permanece igual. Script que aponta para a URL fixa de outro repositório não pode ser redirecionado pelo Vape de forma segura.

`OrionVapeSmokeTest.lua` e `FireHubUiCompatibilityTest.lua` são testes de UI; não use URL de teste como loader do script principal. Para o Fire Hub, use `OrionLoader.lua`, que retorna `shared.OrionLib` sem criar uma segunda janela.

Para contribuir, consulte [CONTRIBUTING.md](CONTRIBUTING.md).

## Solução de problemas

1. Feche o jogo antes de limpar cache.
2. Remova somente `newvape` caso o cache esteja corrompido.
3. Confirme acesso ao loader e ao repositório compilado.
4. Confira suporte a arquivos, `loadstring` e APIs usadas pelo ambiente autorizado.
5. Desative interfaces que disputem entrada de teclado ou mouse.

## Créditos e licença

- [7GrandDad](https://github.com/7GrandDadPGN) — mantenedor original.
- [Fiu](https://github.com/rce-incorporated/Fiu) — execução de bytecode Luau.
- [HashLib](https://devforum.roblox.com/t/open-source-hashlib/416732/1) — hashing.
- [Projectile prediction](https://devforum.roblox.com/t/predict-projectile-ballistics-including-gravity-and-motion/1842434) — referência de previsão.

Distribuído sob os termos de [LICENSE](LICENSE).
