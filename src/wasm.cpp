#include <emscripten/bind.h>
#include "converter.cpp"

emscripten::val convertVSDToSVG_JS(emscripten::val inputArray) {
    unsigned length = inputArray["length"].as<unsigned>();
    std::vector<unsigned char> buffer(length);

    for (unsigned i = 0; i < length; i++) {
        buffer[i] = (unsigned char)inputArray[i].as<unsigned>();
    }

    std::string svg = convertVSDBytesToSVGString(buffer.data(), buffer.size());

    return emscripten::val(svg);
}

EMSCRIPTEN_BINDINGS(my_module) {
    emscripten::function("convertVSDToSVG_JS", &convertVSDToSVG_JS);
}