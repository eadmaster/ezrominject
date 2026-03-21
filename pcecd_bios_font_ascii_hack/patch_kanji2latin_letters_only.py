import os

# --- Configuration ---
BIOS_PATH = "syscard3.pce"
OUTPUT_PATH = "syscard3_patched.bin"

# 16x16 Font Configuration
FONT16_PATH = "font8x16.bin"
BIOS_START_OFFSET_16 = 0x138A2
FONT16_UPPER_A = 0x210       # 'A' offset in 16-byte chunks
FONT16_LOWER_A = 0x410       # 'a' offset in 16-byte chunks

# 12x12 Font Configuration
FONT12_PATH = "spleen-6x12.psfu"
BIOS_START_OFFSET_12 = 0x31FDA
FONT12_UPPER_A = 0x32C       # 'A' offset in 12-byte chunks
FONT12_LOWER_A = 0x4AC       # 'a' offset in 12-byte chunks


def get_glyph(font_data, char_code, upper_offset, lower_offset, height):
    """Calculates the offset and returns the bytes for a glyph of a specific height."""
    if ord('A') <= char_code <= ord('Z'):
        offset = upper_offset + (char_code - ord('A')) * height
    elif ord('a') <= char_code <= ord('z'):
        offset = lower_offset + (char_code - ord('a')) * height
    else:
        # Fallback to a space or null if character is out of range
        return b'\x00' * height
    return font_data[offset : offset + height]

def patch_bios():
    if not os.path.exists(BIOS_PATH):
        print(f"Error: {BIOS_PATH} missing.")
        return

    with open(BIOS_PATH, "rb") as f:
        bios_data = bytearray(f.read())

    # Create a list of all letters to iterate through
    letters = [chr(i) for i in range(ord('A'), ord('Z')+1)] + \
              [chr(i) for i in range(ord('a'), ord('z')+1)] + \
              [" "]

    total_combinations = len(letters) ** 2

    # --- 1. Patch the 16x16 Font ---
    if os.path.exists(FONT16_PATH):
        print(f"Patching 16x16 Font ({total_combinations} pairs) at {hex(BIOS_START_OFFSET_16)}...")
        with open(FONT16_PATH, "rb") as f:
            font16_data = f.read()
            
        current_ptr = BIOS_START_OFFSET_16
        sjis_value = 0x889F  # Starting SJIS encoding value

        for char1 in letters:
            for char2 in letters:
                glyph1 = get_glyph(font16_data, ord(char1), FONT16_UPPER_A, FONT16_LOWER_A, 16)
                glyph2 = get_glyph(font16_data, ord(char2), FONT16_UPPER_A, FONT16_LOWER_A, 16)

                stitched_tile = bytearray()
                for i in range(16):
                    stitched_tile.append(glyph1[i]) # Left half
                    stitched_tile.append(glyph2[i]) # Right half

                if current_ptr + 32 <= len(bios_data):
                    bios_data[current_ptr : current_ptr + 32] = stitched_tile
                    current_ptr += 32
                else:
                    print("Warning: Reached end of BIOS file before finishing all 16x16 pairs.")
                    break
                
                # Print mapping table to stdout (only need to do this during the first font loop)
                print("%X=%s%s" % (sjis_value, char1, char2))
                
                # Increment SJIS Logic
                lead = sjis_value >> 8
                trail = sjis_value & 0xFF
                trail += 1
                if trail == 0x7F:
                    trail = 0x80
                elif trail > 0xFC:
                    trail = 0x40
                    lead += 1
                sjis_value = (lead << 8) | trail 
    else:
        print(f"Warning: {FONT16_PATH} not found. Skipping 16x16 patch.")


    # --- 2. Patch the 6x12 Font ---
    if os.path.exists(FONT12_PATH):
        print(f"\nPatching 12x12 Font ({total_combinations} pairs) at {hex(BIOS_START_OFFSET_12)}...")
        with open(FONT12_PATH, "rb") as f:
            font12_data = f.read()

        sjis_value = 0x889F  # Starting SJIS encoding value
        current_ptr = BIOS_START_OFFSET_12

        for char1 in letters:
            for char2 in letters:
                # Use height=12 and the 12x12 offsets
                glyph1 = get_glyph(font12_data, ord(char1), FONT12_UPPER_A, FONT12_LOWER_A, 12)
                glyph2 = get_glyph(font12_data, ord(char2), FONT12_UPPER_A, FONT12_LOWER_A, 12)

                # Stitching Row-by-Row (12 rows of 2 bytes = 24 bytes per tile)
                stitched_tile = bytearray()
                bitstream = 0
                bit_count = 0
                for i in range(12):
                    c1 = (glyph1[i] >> 2) & 0x3F  # left-alinged
                    c2 = (glyph2[i] >> 2) & 0x3F

                    row12 = (c1 << 6) | c2   # 12 bits total

                    bitstream = (bitstream << 12) | row12
                    bit_count += 12

                    while bit_count >= 8:
                        bit_count -= 8
                        byte = (bitstream >> bit_count) & 0xFF
                        stitched_tile.append(byte)

                # flush remaining bits (if any)
                if bit_count > 0:
                    stitched_tile.append((bitstream << (8 - bit_count)) & 0xFF)


                if current_ptr + 18 <= len(bios_data):
                    bios_data[current_ptr : current_ptr + 18] = stitched_tile
                    current_ptr += 18
                else:
                    print("Warning: Reached end of BIOS file before finishing all 12x12 pairs.")
                    break
                    
                # Increment SJIS Logic
                lead = sjis_value >> 8
                trail = sjis_value & 0xFF
                trail += 1
                if trail == 0x7F:
                    trail = 0x80
                elif trail > 0xFC:
                    trail = 0x40
                    lead += 1
                sjis_value = (lead << 8) | trail 
    else:
        print(f"Warning: {FONT12_PATH} not found. Skipping 12x12 patch.")


    # --- Write to Output ---
    with open(OUTPUT_PATH, "wb") as f:
        f.write(bios_data)
    
    print(f"\nDone! Created {OUTPUT_PATH}")

if __name__ == "__main__":
    patch_bios()
