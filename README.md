## Install tesseract and tools

```bash
git clone https://github.com/agiletechvn/tesseract5-macos.git
cd tesseract5-macos
mkdir build && cd build && cmake ..
make all && make install
```

## Train custom data

```bash
# if running
pkill text2image
# text2image --list_available_fonts --fonts_dir .fonts
# -dlcr : distort_image and ligatures continue remain(no invert)
./finetune-model.sh -m eng -f "Arial" -f "Arial Bold" -f "Arial Italic" -f "Arial Bold Italic" -o idcard [-dlcr]
```
