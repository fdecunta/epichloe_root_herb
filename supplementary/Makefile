DOCX_TEMPLATE= ../docx_template/ms_template.docx
DOCX_REF=      --reference-doc=${DOCX_TEMPLATE}
TOC=           --toc -s --number-section

HEADER=        header.m4
MACROS=        ../m4/macros.m4

SUP_TABLES= 01_lolines.m4       \
	02_rgr_x_lolines.m4     \
	03_rgr_x_lolines_2.m4   \
	04_rgr_x_lolines_3.m4   \
	05_rgr.m4               \
	06_total_biomass.m4     \
	07_shoot_biomass.m4     \
	08_root_biomass.m4      \
        09_shoot_root_ratio.m4  \
	10_cn.m4                \
	11_np.m4                \
	12_carbon.m4            \
	13_nitrogen.m4          \
	14_phosphorus.m4        \
	15_pics.m4

sup.docx: sup.md
	pandoc sup.md -o $@ ${DOCX_REF} ${TOC}

sup.md: ${MACROS} ${HEADER} ${SUP_TABLES}
	m4 -P ${MACROS} ${HEADER} ${SUP_TABLES} > $@

clean:
	rm -f sup.md sup.docx
