PAPER=         Decunta_et_al.docx

BIB=           bib/refs.bib
CSL=           bib/plant-and-soil.csl
DOCX_TEMPLATE= docx_template/ms_template.docx

CITES=         --citeproc --bibliography=${BIB} --csl=${CSL}
DOCX_REF=      --reference-doc=${DOCX_TEMPLATE}

PNG=       figures/png

SECTIONS=      sections/title_page.m4           \
	       sections/body.m4                 \
	       sections/author_contributions.md \
	       sections/acknowledgements.md     \
	       sections/funding.md              \
	       sections/data_statement.m4       \
	       sections/references_title.md

.SUFFIXES: .R .Rout
ROUT=          R/lolines.Rout                \
	       R/lolines_x_biom.Rout         \
	       R/rgr.Rout                    \
	       R/rgr_x_lolines.Rout          \
	       R/rgr_x_lolines_absolute.Rout \
	       R/shoot_root_ratio.Rout       \
	       R/total_biomass.Rout          \
	       R/shoot_biomass.Rout          \
	       R/root_biomass.Rout           \
	       R/cn.Rout                     \
	       R/np.Rout                     \
	       R/carbon.Rout                 \
	       R/nitrogen.Rout               \
	       R/phosphorus.Rout             \
	       R/foliar_clipping.Rout

FIGURES=       ${PNG}/fig1.png              \
	       ${PNG}/fig2.png              \
	       ${PNG}/fig3.png              \
	       ${PNG}/fig4.png              \
	       ${PNG}/fig5.png

all: ${ROUT} ${FIGURES} ${PAPER} sup.docx

${PAPER}: ${SECTIONS} ${FIGURES} ${DOCX_TEMPLATE}
	m4 -P m4/macros.m4 ${SECTIONS} | \
	pandoc - -o ${PAPER} ${DOCX_REF} ${CITES}

${PNG}/lolines.png:       R/lolines.Rout
${PNG}/rgr_x_lolines.png: R/rgr_x_lolines.Rout
${PNG}/rgr.png:           R/rgr.Rout
${PNG}/shoot_root.png:    R/shoot_root_ratio.Rout
${PNG}/cn.png:            R/cn.Rout
${PNG}/np.png:            R/np.Rout

${PNG}/fig1.png: ${PNG}/lolines.png
	cp ${PNG}/lolines.png $@

${PNG}/fig2.png: ${PNG}/rgr_x_lolines.png
	cp ${PNG}/rgr_x_lolines.png $@

${PNG}/fig3.png: ${PNG}/rgr.png
	cp ${PNG}/rgr.png $@

${PNG}/fig4.png: ${PNG}/shoot_root.png
	cp ${PNG}/shoot_root.png $@

${PNG}/fig5.png: ${PNG}/cn.png ${PNG}/np.png
	magick ${PNG}/cn.png ${PNG}/np.png \
	-size "%[fx:u.w>v.w?u.w:v.w]x2" xc:black -swap 2,1 \
	-append ${PNG}/fig5.png

.R.Rout:
	@mkdir -p ${PNG}
	R CMD BATCH --vanilla $< $@

sup.docx:
	make -C supplementary/
	cp supplementary/sup.docx .

clean:
	rm -f ${PAPER} R/*.Rout sup.docx
	rm -rf ${PNG}

.PHONY: all clean
