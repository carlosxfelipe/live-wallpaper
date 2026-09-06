# Live Wallpaper

Um aplicativo stand-alone e nativo para macOS que permite definir degradês personalizados e vídeos em loop como papel de parede, rodando perfeitamente no background da mesa (nível `.desktopWindow`) e atrás de todos os ícones.

## 🚀 Como baixar vídeos compatíveis do YouTube

O macOS (através do seu motor nativo `AVFoundation`) **não suporta** nativamente a reprodução de arquivos MP4 que utilizem codecs como AV1 ou VP9. Infelizmente, o YouTube prioriza esses codecs para vídeos em alta resolução (como 4K). 

Se você baixar um vídeo AV1 e tentar usá-lo, a tela ficará apenas cinza. Para que o vídeo funcione no Live Wallpaper, ele precisa ser baixado usando o codec **H.264** (também chamado de `avc1`).

Se você utiliza o `yt-dlp` via terminal (com o `uvx`), **use o comando abaixo** para baixar o vídeo já no formato 100% compatível com a Apple:

```bash
uvx yt-dlp -f "bestvideo[vcodec^=avc1]/best[ext=mp4]" --merge-output-format mp4 "COLOQUE_A_URL_AQUI"
```

### Por que usar esse comando?
- **`[vcodec^=avc1]`**: Força a ferramenta a baixar a trilha de vídeo em H.264. Como o papel de parede roda sem som, não baixamos trilhas de áudio extras.
- **Eficiência**: Vídeos H.264 (geralmente em 1080p) são acelerados via hardware pelo Mac. Usá-los como Live Wallpaper economiza bastante processamento e bateria em comparação com vídeos pesados em 4K.

---

## 💻 Como rodar o projeto

1. Abra o projeto `LiveWallpaper.xcodeproj` no Xcode.
2. Na aba **Signing & Capabilities** do target `LiveWallpaper`, adicione o seu **Development Team** (sua conta Apple ID).
3. Selecione o seu Mac como destino de build.
4. Aperte **Run (⌘ + R)**.

## 🛠️ Tecnologias Utilizadas

- **SwiftUI**: Para toda a construção da interface do tipo "System Settings" (Painel nativo).
- **AppKit**: Para manipulação profunda de janelas (`NSWindow.Level`) e renderização nativa de views via `NSHostingView` e `NSView`.
- **AVFoundation / AVKit**: Para a reprodução otimizada, silenciosa e em loop perfeito do vídeo na janela de desktop.


## 📄 Licença

Este projeto está licenciado sob os termos descritos no arquivo [LICENSE](LICENSE).
