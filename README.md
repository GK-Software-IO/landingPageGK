# Landing page — GK Software

Landing institucional da GK Software. HTML estático: sem build, sem runtime,
sem dependência de pacote. O que vai ao ar são um `index.html` e seis PNGs,
cerca de 150 KB.

## Estrutura

| caminho | o que é |
|---|---|
| `landing-scattered.html` | a página (fonte) |
| `assets/` | ativos da marca, extraídos do PNG original |
| `deploy/` | build, envio e configuração de servidor |

## Publicar

```bash
./deploy/build.sh gksoftware.com.br            # gera public/ com o domínio embutido
./deploy/sync.sh  deploy@VPS:/opt/gk-landing   # envia via rsync
```

O passo a passo completo — DNS, Caddy, bind mount em container e os pontos onde
isso costuma quebrar — está em [`deploy/README.md`](deploy/README.md).

## Marca

- **Slogan:** Ideias que viram operação.
- **Headline:** Você traz o problema. A gente devolve o sistema.
- **Lockup:** vertical, sem assinatura embutida. Versão horizontal (símbolo +
  nome) para header; só o símbolo abaixo de ~70px.

Os ativos em `assets/` foram extraídos de `gk-lockup-original.png` — o fundo
gradiente foi modelado por regressão linear por linha e o alfa resolvido por
canal, o que dá recortes com transparência real em vez de recorte duro.

> **Só existe PNG.** Não há vetor da marca nem a fonte original do lettering
> (Archivo e Poppins são aproximações). Os ativos servem na web até uns 180 px
> de largura; acima disso, ou para impressão, será preciso o original vetorial.

## Pendências

- Os oito itens de serviço da seção espalhada são **rascunho**, não o catálogo
  real da GK.
- O e-mail e o prazo de resposta no rodapé são **placeholders**.
- Domínio ainda não definido.
