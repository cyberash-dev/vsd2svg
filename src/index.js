const Lib  = require("../wasm/wasm.js");

class VSDConverter {
    #converterLibrary;

    async init() {
        this.#converterLibrary = await Lib();
    }

    /**
     * @param {Uint8Array} vsdDataBytes
     * @return {string}
     */
    toSVGString(vsdDataBytes) {
        if (!this.#converterLibrary) {
            throw new Error(`VSDConverter is not initialized.`);
        }

        return this.#converterLibrary.convertVSDToSVG_JS(vsdDataBytes);
    }
}

module.exports = {
    VSDConverter
}