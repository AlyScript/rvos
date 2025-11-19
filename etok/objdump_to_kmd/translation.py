from typing import Optional


def to_kmd(address: int, data: Optional[int], disassembly: str) -> str:
    if data is not None:
        return f"{str(hex(address))[2:].rjust(8, '0')}: {str(hex(data))[2:].rjust(8, '0')} ; {disassembly}"

    return f"{str(hex(address))[2:].rjust(8, '0')}: ; {disassembly}"


def instruction_to_kmd(address: int, data: int, disassembly: str):
    return to_kmd(address, data, disassembly)


def section_to_kmd(address: int, section_name: str):
    return to_kmd(address, None, f"Section <{section_name}>")


def segment_to_kmd(address: int, segment_name: str):
    return to_kmd(address, None, f"<{segment_name}>")


def data_to_kmd(address: int, data_string: str):
    # Split data into bytes: Will merge these into words later
    # split_bytes = [data_string[n:n+2] for n in range(0, len(data_string), 2)][::1]
    # out = []
    # for i, byte in enumerate(split_bytes):
    #     current_address = address + i
    #     kmd_line = f"{str(hex(current_address))[2:].rjust(8, '0')}: {byte} ;"
    #     if current_address % 4 != 0: out += [f"\t{kmd_line}"]
    #     else: out += [f"{kmd_line}"]

    if len(data_string) > 4:
        if len(data_string) == 8 and address % 4 == 0:
            pass  # Ignore word aligned words: Thats ok!
        else:
            if len(data_string) % 4 != 0:
                raise Exception(f"Invalid insn {data_string} at {hex(address)}")

            # Split into shorts
            shorts = [data_string[n : n + 4] for n in range(0, len(data_string), 4)]
            out = []
            for i, short in enumerate(shorts[::-1]):
                current_address = address + (i * 2)
                out.extend(data_to_kmd(current_address, short))

            return out

    return [f"{str(hex(address))[2:].rjust(8, '0')}: {data_string} ;"]
    # return out
