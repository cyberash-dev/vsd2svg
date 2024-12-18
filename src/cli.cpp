#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "converter.cpp"

int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cerr << "Использование: " << argv[0] << " <file.vsd> <output.svg>\n";
        return 1;
    }

    std::string filename = argv[1];
    std::ifstream file(filename, std::ios::binary | std::ios::ate);
    if (!file.is_open()) {
        std::cerr << "Не удалось открыть файл: " << filename << "\n";
        return 1;
    }

    std::streamsize fileSize = file.tellg();
    if (fileSize < 0) {
        std::cerr << "Ошибка определения размера файла.\n";
        return 1;
    }
    file.seekg(0, std::ios::beg);

    std::vector<unsigned char> buffer(static_cast<size_t>(fileSize));

    if (!file.read(reinterpret_cast<char*>(buffer.data()), fileSize)) {
        std::cerr << "Ошибка чтения данных.\n";
        return 1;
    }

    const unsigned char* data = buffer.data();

    auto result = convertVSDBytesToSVGString(data, buffer.size());

    std::ofstream outFile(argv[2], std::ios::out | std::ios::trunc);
    if (!outFile) {
        std::cerr << "Не удалось открыть файл для записи.\n";
        return 1;
    }

    outFile << result;

    return 0;
}
