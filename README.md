## Install tesseract and tools

```bash
git clone https://github.com/agiletechvn/tesseract5-macos.git
cd tesseract5-macos
mkdir build && cd build && cmake ..
make all && make install
```

## Train custom data

`./finetune-model.sh -m eng -f '"Arial"' -o digits`
