# Imports
import re
import sys

from objdump_to_kmd import *


def translate_objdump(executable_source: str, raw_source: str) -> str:
    # Parse each line of the objdump, matching it with regex to check which func to apply
    # Finally merge byte data into (aligned) words so bennett doesn't get mad
    lines = ["KMD"]

    instruction_pattern = re.compile(r"([0-9a-fA-F]+):\t([0-9a-fA-F]+)[\s]*(.*?)$")
    section_pattern = re.compile(r"Disassembly of section (.*?):")
    segment_pattern = re.compile(r"([0-9a-fA-F]+) \<(.*?)>:")
    data_pattern = re.compile(
        r"([0-9a-fA-F]+):\t.*?\.insn\t([0-9]+)\, 0x([0-9a-fA-F]*)"
    )

    current_address = 0
    rodata_encountered = False
    for line in executable_source.splitlines():
        # Valid data is valid instruction, so check if it matches data first
        if data_pattern.match(line.strip()) is not None:
            match = data_pattern.match(line.strip())
            current_address = int(match[1], 16)
            data_size = int(match[2])
            data = match[3].rjust(data_size * 2, "0")

            lines.extend(data_to_kmd(current_address, data))
            continue

        if section_pattern.match(line.strip()) is not None:
            match = section_pattern.match(line.strip())
            if "rodata" in line:
                rodata_encountered = True

            # End at comment
            if "comment" in line or ".riscv.attributes" in line or "debug" in line:
                break

            lines.append(section_to_kmd(current_address // 4 + 4, match[1]))

        if segment_pattern.match(line.strip()) is not None:
            match = segment_pattern.match(line.strip())
            lines.append(segment_to_kmd(int(match[1], 16), match[2]))

        if instruction_pattern.match(line.strip()) is not None:
            match = instruction_pattern.match(line.strip())
            current_address = int(match[1], 16)

            if not rodata_encountered:
                lines.append(
                    instruction_to_kmd(current_address, int(match[2], 16), match[3])
                )
            else:
                data = match[2].rjust(8, "0")
                lines.extend(data_to_kmd(current_address, data))

    # Add rqw data lines now
    raw_data_pattern = re.compile(
        r"\s([0-9a-fA-F]*)\s([0-9a-fA-F]*)\s([0-9a-fA-F]*)\s([0-9a-fA-F]*)\s([0-9a-fA-F]*)(.*?)"
    )
    max_address = 0
    for line in raw_source.splitlines():
        if raw_data_pattern.match(line) is not None:
            match = raw_data_pattern.match(line)
            address = int(match[1], 16)
            if address <= max_address:
                break

            max_address = address

            # Convert words to KMD lines
            for i in range(4):
                if match[2 + i] != "":
                    # Endian swap
                    data = match[2 + i].ljust(8, "0")
                    data = "".join(
                        [data[n : n + 2] for n in range(0, len(data), 2)][::-1]
                    )
                    lines.extend(data_to_kmd(address + i * 4, data))

    # Merge bytes into words
    """
    data_words = {}
    bytes_pattern = re.compile(r'([0-9a-fA-F]+): ([0-9a-fA-F]{2}) ;')
    for line in lines:
        if bytes_pattern.match(line.strip()) is not None:
            match = bytes_pattern.match(line.strip())
            address = int(match[1], 16)
            
            if address % 4 == 0:
                data_words[address] = int(match[2], 16) << 24
                continue
            
            modulo = 3 -  (address % 4)
            data_words[address // 4 * 4] = data_words.get(address // 4 * 4, 0) + (int(match[2], 16) << (8 * modulo))
    """

    return "\n".join([l for l in lines if l])


if __name__ == "__main__":
    executable_source = open(sys.argv[1], "r").read()
    raw_source = open(sys.argv[2], "r").read()
    kmd_file = sys.argv[3]
    kmd = translate_objdump(executable_source, raw_source)

    with open(kmd_file, "w") as fp:
        fp.write(kmd)
