# vsd2svg
Библиотека для конвертации VSD файлов в SVG. Работает на основе [libvisio](https://github.com/LibreOffice/libvisio)
собранного для WebAssembly.

## Установка
`npm install vsd2svg --save`

## Использование
### В Node.JS или браузере
```js
const { VSDConverter } = require("vsd2svg");
const converter = new VSDConverter();

(async () => {
    await converter.init();
    
    // ...тут чтение файла
    
    const svgString = converter.toSVGString(vsdDataUint8Array);
})();
```
### CLI
`vsd2svg input/file.vsd otput/file.svg`