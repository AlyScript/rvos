#!/bin/python3
import subprocess
import sys


def main():
    file = sys.argv[1]
    parse(file)
    pass


def parse(inFilePath: str):
    file_contents = get_obj_dump(inFilePath)

    initLine = True
    commentBuffer = []

    # Check for specific objdump lines that aren't disassembly
    disassembly_line_prefix = "000"  # Disassembly lines always start with an address

    split_line = file_contents.splitlines()
    print("KMD")
    for line in split_line:
        line = line.strip()  # Strip leading/trailing whitespace for cleanliness

        # 1. Skip Header/Separator lines
        if initLine is True:
            initLine = False
            commentBuffer = []
            continue

        if line.startswith("Disassembly"):
            initLine = True
            continue

        if line == "":
            initLine = True
            continue

        # 2. Handle Source Comments
        if line.startswith("SRCSRC:"):
            commentBuffer.append(line.removeprefix("SRCSRC:"))
            continue

        # 3. CRITICAL: Validate it's a disassembly line before splitting
        # Disassembly lines in your format look like: "40024: fd010113 add sp,sp,-48"
        # We check for a colon, and that the part before the colon is a valid address format.
        if ":" not in line or not line.split(":")[0].strip().startswith(
            disassembly_line_prefix
        ):
            # This handles section headers, data dumps, and other unexpected lines.
            commentBuffer = []  # Clear comments for non-instruction lines
            continue

        # If we reach here, it should be a valid instruction line

        try:
            # Revert to original parsing logic
            address = int(line.split(":")[0], base=16)
            parts = line.split(":")[1].split()

            # The data (opcode) is the first part after the colon
            data = parts[0]
            # The assembly instruction is the rest
            assembly = " ".join(parts[1:])

            print(f"{hex(address)} : {data} ; {assembly}")
            for comment in commentBuffer:
                print(f"{hex(address)} : ; {comment}")

            commentBuffer = []
        except:
            # Just in case the format is still bad, skip the line
            continue


def get_obj_dump(path) -> str:
    return subprocess.check_output(["./elftokmd.sh", path]).decode("utf-8")


main()
