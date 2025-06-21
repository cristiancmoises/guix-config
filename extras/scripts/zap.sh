# VIDEO COMPRESSION USING FFMPEG WITHOUT LOSING QUALITY
ffmpeg -i video.mp4 -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p working.mp4
