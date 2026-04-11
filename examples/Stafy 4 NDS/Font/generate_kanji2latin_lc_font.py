import os

FONT_PATH = "font8x16.bin"
OUTPUT_PATH = "custom_lc_font.dat"

# Font Source Offsets
UPPER_A_OFFSET = 0x210
LOWER_A_OFFSET = 0x410

def get_glyph(font_data, char_code):
    if ord('A') <= char_code <= ord('Z'):
        offset = UPPER_A_OFFSET + (char_code - ord('A')) * 16
    elif ord('a') <= char_code <= ord('z'):
        offset = LOWER_A_OFFSET + (char_code - ord('a')) * 16
    else:
        return b'\x00' * 16
    return font_data[offset : offset + 16]


def generate_lc_font():
    if not os.path.exists(FONT_PATH):
        print(f"Error: {FONT_PATH} not found.")
        return

    with open(FONT_PATH, "rb") as f:
        font_data = f.read()

    letters = [chr(i) for i in range(ord('A'), ord('Z')+1)] + \
              [chr(i) for i in range(ord('a'), ord('z')+1)] + \
              [" "]

    records = []
    sjis_value = 0x889F # Starting ID for 'AA'

    for char1 in letters:
        for char2 in letters:
            b1 = (sjis_value >> 8) & 0xFF
            b2 = sjis_value & 0xFF
            header = bytes([b1, b2])
            #print( header)
            
            glyph1 = get_glyph(font_data, ord(char1))
            glyph2 = get_glyph(font_data, ord(char2))
            
            # Stitch 16x16 bitmap (32 bytes)
            bitmap = bytearray()
            for i in range(16):
                
                row1 = glyph1[i]
                row2 = glyph2[i]
                
                # FIX: If the right-hand character is a space, 
                # NitroPaint trims the width. We force a single pixel 
                # at the far right (bit 0) of one row (e.g., row 15).
                if char1 == " " and i == 15:
                    row1 |= 0x80  # 0x80 is the bit for the leftmost pixel
                if char2 == " " and i == 15:
                    row2 |= 0x01  # right-most pixel
                        
                bitmap.append(row1)
                bitmap.append(row2)
            
            # Store as a tuple (header_value, full_record_bytes)
            header_int = (header[0] << 8) | header[1]
            records.append((header_int, header + bitmap))
                
            lead = sjis_value >> 8
            trail = sjis_value & 0xFF
            trail += 1
            # Skip the 0x7F control code gap
            if trail == 0x7F:
                trail = 0x80
            # Roll over to the next lead byte row when we pass 0xFC
            elif trail > 0xFC:
                trail = 0x40
                lead += 1
            sjis_value = (lead << 8) | trail  # Recombine the bytes back into the integer

    # Sort records by the header value to pass the C tool's ascending check
    records.sort(key=lambda x: x[0])

    # Write the sorted file
    with open(OUTPUT_PATH, "wb") as out_file:
        for _, data in records:
            out_file.write(data)

    size = os.path.getsize(OUTPUT_PATH)
    print(f"Done! Created {OUTPUT_PATH}.")
    print(f"Total Records: {len(records)}. File Size: {size} bytes.")
    print(f"Pitch is {size // len(records) if len(records) > 0 else 0}.")

if __name__ == "__main__":
    generate_lc_font()
