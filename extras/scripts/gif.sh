# VIDEO TO GIF
ffmpeg -i input.mp4 -filter_complex "[0]split[a][b]; [a]palettegen[palette]; [b][palette]paletteuse" output.gif
