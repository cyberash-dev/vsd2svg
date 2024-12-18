const fs = require("fs");
const {VSDConverter} = require("../src/index");

(async () => {
    if (process.argv.length !== 4) {
        console.error("Usage: <file.vsd> <output.svg>");

        return 1;
    }

    const converter = new VSDConverter();
    await converter.init();

    const vsdData = fs.readFileSync(process.argv[2]);
    const svgData = converter.toSVGString(vsdData);

    fs.writeFileSync(process.argv[3], svgData);

    return 0;
})();