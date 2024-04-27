BUILD_DIR=./build

build-latex:
	mkdir -p $(BUILD_DIR)
	pdflatex -shell-escape -synctex=1 -interaction=nonstopmode -file-line-error -recorder -output-directory=$(BUILD_DIR) "doc.tex"
	bibtex $(BUILD_DIR)/doc.aux
	pdflatex -shell-escape -synctex=1 -interaction=nonstopmode -file-line-error -recorder -output-directory=$(BUILD_DIR) "doc.tex"
	pdflatex -shell-escape -synctex=1 -interaction=nonstopmode -file-line-error -recorder -output-directory=$(BUILD_DIR) "doc.tex"
	cp $(BUILD_DIR)/doc.pdf doc.pdf
