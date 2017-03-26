#!/bin/bash

export DOCKER_IMAGE="asciidoctor/docker-asciidoctor"
export FILE="rapport.adoc"
export PDF_ASSETS="/documents/pdf-assets" 
export FONTS="$PDF_ASSETS/fonts"
export THEME="$PDF_ASSETS/themes"
export LAST="last-page.adoc"

# Export to HTML
docker run -v $CURRENT_DIR:/documents/ --name asciidoc-to-html ${DOCKER_IMAGE} asciidoctor -D /documents/output ${FILE}
# Export to PDF
docker run -v $CURRENT_DIR:/documents/ --name asciidoc-to-pdf-whole -D /documents/output -a "pdf-fontsdir=$FONTS" -a "pdf-stylesdir=$THEMES" -a pdf-style=serif "${FILE}"
docker run -v $CURRENT_DIR:/documents/ --name asciidoc-to-pdf-last -D /documents/output -a "pdf-fontsdir=$FONTS" -a "pdf-stylesdir=$THEMES" -a pdf-style=last "${LAST}"
docker run -v $CURRENT_DIR/output:/opt/docs stevvooe/pdftk pdftk ${FILE%.*}.pdf ${LAST%.*.pdf} output complete-rapport.pdf
# Export to EPUB
docker run -v $CURRENT_DIR:/documents/ --name asciidoc-to-epub -D /documents/output asciidoctor-epub3 ${FILE}
# Export to MOBI
docker run -v $CURRENT_DIR:/documents/ --name asciidoc-to-epub -D /documents/output -a ebook-format=kf8 asciidoctor-epub3 ${FILE}