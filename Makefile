PAPER=         Decunta_et_al.docx

BIB=           bib/refs.bib
CSL=           bib/plant-and-soil.csl
DOCX_TEMPLATE= docx_template/ms_template.docx

CITES=         --citeproc --bibliography=${BIB} --csl=${CSL}
DOCX_REF=      --reference-doc=${DOCX_TEMPLATE}

PNG_DIR=       figures/png

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

FIGURES=       ${PNG_DIR}/lolines.png           \
	       ${PNG_DIR}/rgr.png               \
	       ${PNG_DIR}/rgr_x_lolines.png     \
	       ${PNG_DIR}/shoot_root.png        \
	       ${PNG_DIR}/fig5.png

all: ${ROUT} ${FIGURES} ${PAPER} sup.docx

${PAPER}: ${SECTIONS} ${FIGURES} ${DOCX_TEMPLATE}
	m4 -P m4/macros.m4 ${SECTIONS} | \
	pandoc - -o ${PAPER} ${DOCX_REF} ${CITES}

${PNG_DIR}/lolines.png:       R/lolines.Rout
${PNG_DIR}/rgr.png:           R/rgr.Rout
${PNG_DIR}/rgr_x_lolines.png: R/rgr_x_lolines.Rout
${PNG_DIR}/shoot_root.png:    R/shoot_root_ratio.Rout
${PNG_DIR}/cn.png:            R/cn.Rout
${PNG_DIR}/np.png:            R/np.Rout
${PNG_DIR}/fig5.png:          ${PNG_DIR}/cn.png ${PNG_DIR}/np.png
	magick ${PNG_DIR}/cn.png ${PNG_DIR}/np.png \
	-size "%[fx:u.w>v.w?u.w:v.w]x2" xc:black -swap 2,1 \
	-append ${PNG_DIR}/fig5.png

.R.Rout:
	@mkdir -p ${PNG_DIR}
	R CMD BATCH --vanilla $< $@

sup.docx:
	make -C supplementary/
	cp supplementary/sup.docx .

clean:
	rm -f ${PAPER} R/*.Rout sup.docx
	rm -rf ${PNG_DIR}


.PHONY: all clean
