#include <ostream>
#include <sstream>

inline std::ostream& operator<<(std::ostream &os, const std::ostringstream &oss) {
    return os << oss.str();
}

