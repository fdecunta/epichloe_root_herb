#MAGICK=  magick
#MONTAGE= magick montage

MAGICK=  convert
MONTAGE= montage

FOTO1=   cap3_corte_raiz.jpg
FOTO2=   foliar_clipping.jpg
FOTO3=   cap3_plants.jpg
FOTO4=   cap3_larva_recu.jpg

BOX=50
OFF=2

collage_final.jpg: _tmp1.jpg _tmp2.jpg _tmp3.jpg _tmp4.jpg
	${MONTAGE} _tmp1.jpg _tmp2.jpg _tmp3.jpg _tmp4.jpg \
	-background white -tile 2x2 -geometry +10+10 $@
	rm _tmp1.jpg _tmp2.jpg _tmp3.jpg _tmp4.jpg

_tmp1.jpg: ${FOTO1}
	${MAGICK} "${FOTO1}" -resize "400x400^" -gravity center -extent 400x400 \
	\( -size ${BOX}x${BOX} xc:"rgba(80,80,80,0.75)" \
	-gravity center -fill white -pointsize 30 -annotate 0 "a" \) \
	-gravity northwest -geometry +${OFF}+${OFF} -composite $@

_tmp2.jpg: ${FOTO2}
	${MAGICK} "${FOTO2}" -resize "400x400^" -gravity center -extent 400x400 \
	\( -size ${BOX}x${BOX} xc:"rgba(80,80,80,0.75)" \
	-gravity center -fill white -pointsize 30 -annotate 0 "b" \) \
	-gravity northwest -geometry +${OFF}+${OFF} -composite $@

_tmp3.jpg: ${FOTO3}
	${MAGICK} "${FOTO3}" -resize "400x400^" -gravity center -extent 400x400 \
	\( -size ${BOX}x${BOX} xc:"rgba(80,80,80,0.75)" \
	-gravity center -fill white -pointsize 30 -annotate 0 "c" \) \
	-gravity northwest -geometry +${OFF}+${OFF} -composite $@

_tmp4.jpg: ${FOTO4}
	${MAGICK} "${FOTO4}" -rotate 90 -resize "400x400^" -gravity center -extent 400x400 \
	\( -size ${BOX}x${BOX} xc:"rgba(80,80,80,0.75)" \
	-gravity center -fill white -pointsize 30 -annotate 0 "d" \) \
	-gravity northwest -geometry +${OFF}+${OFF} -composite $@

