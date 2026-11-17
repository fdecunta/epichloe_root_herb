DOCX_TEMPLATE= ../docx_template/ms_template.docx
DOCX_REF=      --reference-doc=${DOCX_TEMPLATE}
TOC=           --toc -s --number-section

HEADER=        header.m4
MACROS=        ../m4/macros.m4

SUP_TABLES= lolines.m4       \
	rgr_x_lolines.m4     \
	rgr_x_lolines_2.m4   \
	rgr_x_lolines_3.m4   \
	rgr.m4               \
	total_biomass.m4     \
	shoot_biomass.m4     \
	root_biomass.m4      \
        shoot_root_ratio.m4  \
	cn.m4                \
	np.m4                \
	carbon.m4            \
	nitrogen.m4          \
	phosphorus.m4        \
	pics.m4

sup.docx: sup.md
	pandoc sup.md -o $@ ${DOCX_REF} ${TOC}

sup.md: ${MACROS} ${HEADER} ${SUP_TABLES}
	m4 -P ${MACROS} ${HEADER} ${SUP_TABLES} > $@

clean:
	rm -f sup.md sup.docx
