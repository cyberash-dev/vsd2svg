#include <stdexcept>
#include <string>
#include <iostream>

#include <libvisio/VisioDocument.h>
#include <librevenge/librevenge.h>
#include <librevenge-generators/librevenge-generators.h>

std::string convertVSDBytesToSVGString(const unsigned char* data, size_t size) {
    librevenge::RVNGStringStream input(data, size);
    libvisio::VisioDocument doc;
    librevenge::RVNGStringVector svgData;
    librevenge::RVNGString nmspace("");
    librevenge::RVNGSVGDrawingGenerator svgGen(svgData, nmspace);

    if (!doc.parse(&input, &svgGen)) {
        throw std::runtime_error("Failed to parse VSD data.");
    }

    std::string result;

    for (unsigned i = 0; i < svgData.size(); ++i) {
        result += svgData[i].cstr();
        result += "\n";
    }

    return result;
}
