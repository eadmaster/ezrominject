#! /usr/bin/env python
# -*- coding: utf-8 -*-

# ezrominject - Easy-to-use ROM text injector.
# Copyright (C) 2025-2026 - eadmaster
# https://github.com/eadmaster/ezrominject
# 
# ezrominject is free software: you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software Found-
# ation, either version 2 of the License, or (at your option) any later version.
#
# ezrominject is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with ezrominject.
# If not, see <http://www.gnu.org/licenses/>.


import sys
import os
import math

KANA_1_BYTE=False

INJECT_ASCII=False
INJECT_ASCII_LINE_SPLIT_LEN=14
INJECT_ASCII_MAX_LINES_COUNT=3
INJECT_ASCII_NEWLINE_VALUE=0x0A
INJECT_ASCII_END_VALUE=0x00
# TODO: convert as cmdline options

#TODO: keep ascii chars in the middle

ABBREVIATE=True

TBL_FILE=None

UPPERCASE=False


def read_table(filename):
    table = {}
    import codecs
    with codecs.open(filename, 'r', 'utf-8') as f:
        for line in f:
            if '=' in line:
                line = line.replace('\r', '').replace('\n', '')
                hex_code, glyph = line.split('=')
                #print("glyph: " + glyph)
                table[glyph] = bytes.fromhex(hex_code)
    return table


        
def encode_with_tbl(text, filename): # Pass the table object directly
    table = read_table(filename)
    res = bytearray()
    for char in text:
        if char in table:
            res.extend(table[char])
        else:
            print("err: char missing in table (skipped): " + str(char))
    #res.extend(bytes([INJECT_ASCII_NEWLINE_VALUE]))
    return bytes(res)
    
    
def remove_vowels_conditionally(text, x):
    vowels = "aeiou"
    #vowels = "aeiouAEIOU"
    words = text.split()
    processed_words = []

    for word in words:
        # Check if the word is long enough to process
        if len(word) >= x:
            # Keep the first character
            first_char = word[0]
            # Filter vowels only from the rest of the word
            rest_of_word = "".join([char for char in word[1:] if char not in vowels])
            
            processed_words.append(first_char + rest_of_word)
        else:
            processed_words.append(word)

    return " ".join(processed_words)
    
    
def abbreviate(text, target_len):
	
	text = text.replace(", ", ",") # space afer comma
	text = text.replace(". ", ".") # space afer dot
    
	import re
	#re.sub(old, new, s, flags=re.IGNORECASE)
    
	text = re.sub(" can't", "cant", text, flags=re.IGNORECASE)
	text = re.sub(" cannot", "cant", text, flags=re.IGNORECASE)
	text = re.sub(" won't", "wont", text, flags=re.IGNORECASE)
	text = re.sub(" will not", "wont", text, flags=re.IGNORECASE)
	text = re.sub("Mr.", "Mr", text, flags=re.IGNORECASE)
	text = re.sub("Ms.", "Ms", text, flags=re.IGNORECASE)
	text = re.sub("Miss ", "Ms ", text, flags=re.IGNORECASE)
	text = re.sub("there it is", "there", text, flags=re.IGNORECASE)

	text = re.sub(" one ", " 1 ", text, flags=re.IGNORECASE)
	text = re.sub(" two ", " 2 ", text, flags=re.IGNORECASE)
	text = re.sub(" three ", " 3 ", text, flags=re.IGNORECASE)
	text = re.sub(" four ", " 4 ", text, flags=re.IGNORECASE)
	text = re.sub(" five ", " 5 ", text, flags=re.IGNORECASE)
	text = re.sub(" six ", " 6 ", text, flags=re.IGNORECASE)
	text = re.sub(" seven ", " 7 ", text, flags=re.IGNORECASE)
	text = re.sub(" eight ", " 8 ", text, flags=re.IGNORECASE)
	text = re.sub(" nine ", " 9 ", text, flags=re.IGNORECASE)
	text = re.sub(" ten ", " 10 ", text, flags=re.IGNORECASE)
    
	if len(text) <= target_len:
		return text
        
    ### more aggressive
    
    # TODO: lexicographic analysis -> remove particles

	text = text.replace("Actually", "")
	text = text.replace("You see", "")
	text = text.replace("Anyway", "")
	text = text.replace("However", "")
    
	text = text.replace(" up", "up")
	text = text.replace(" you", " u")
	text = text.replace("you ", "u ")
	text = text.replace("You", "U")
	text = text.replace(" is ", "'s ")
	text = text.replace(" has ", "'s ")
	text = text.replace("\"", "")
	text = text.replace("!!", "!")
	text = text.replace(" the ", " ")
	text = text.replace("The ", "")
	text = text.replace("An ", "")
	text = text.replace(" an ", " ")
	text = text.replace(" to ", " ")
	#text = text.replace("Don't", "No")
	#text = text.replace("don't", "no")
	text = text.replace("'", "")
	
	#if text.count(' ') == 1:  # only 1 space in current line -> convert to PascalCase 
	#	text = text.title().replace(" ", "")

	if len(text) <= target_len:
		return text
	
	# else use https://github.com/ppannuto/python-abbreviate 
	#try:
	#	import abbreviate
	#except:
	#	return text
	#abbr = abbreviate.Abbreviate()
	#text = abbr.abbreviate(text, 5)
    
	return remove_vowels_conditionally(text, 6)
	
	
    
def to_fullwidth(text):
    """Converts Halfwidth ASCII to Fullwidth Unicode equivalents."""
    res = ""
    for char in text:
        code = ord(char)
        if code == 0x20: # Space
            res += chr(0x3000)
        elif 0x21 <= code <= 0x7E:
            res += chr(code + 0xfee0)
        else:
            res += char
    return res


def get_length_with_kana_as_1_byte(text):
    """
    Calculates length where:
    - Kanji/Other: 1 char
    - Kana/Symbols: 0.5 char
    - Result is rounded
    """
    total_len = 0.0
    for char in text:
        cp = ord(char)
        # Hiragana (3040-309F), Katakana (30A0-30FF), Japanese Symbols/Punct (3000-303F)
        if cp < 255 or (0x3000 <= cp <= 0x30FF):
            total_len += 0.5
        else:
            total_len += 1.0
    
    return math.floor(total_len)
    
    
def count_one_byte_chars(text):
    count = 0
    for char in text:
        if ord(char) < 256:
            count += 1
    return count
    
    
def has_no_kanas(text):
    """
    Returns True if the string contains NO Hiragana or Katakana.
    """
    for char in text:
        cp = ord(char)
        # Hiragana: 0x3040 - 0x309F
        # Katakana: 0x30A0 - 0x30FF
        if 0x3040 <= cp <= 0x30FF or cp == 0x3000:
            return False  # Found a kana or space
    return True
    
def is_sjis_single_byte(char):
    """
    Checks if a character occupies exactly 1 byte in Shift-JIS (cp932).
    This correctly identifies '｡' (65377) as a single-byte character.
    """
    try:
        return len(char.encode('cp932')) == 1
    except UnicodeEncodeError:
        return False
        
        
def run_injection(jap_path, eng_path, rom_path):
    # Dictionary to store {address: char_count}
    jap_map = {}

    # 1. Parse jap.txt (UTF-8)
    # Format: 0xAddress Text
    f_jap = open(jap_path, 'r', encoding='utf-8')
    for line in f_jap:
        parts = line.strip().split(' ', 1)
        if len(parts) < 2: continue
        
        try:
            addr_int = int(parts[0], 16)
        except:
            # invalid address
            continue
        
        text = parts[1]
        
        # Rule: If first char is single-byte ASCII, increment address and skip that char
        #if len(text) > 0 and ord(text[0]) < 255:
        #    addr_int += 1
        #    text = text[1:]
        #    # 2nd formatting char
        #    if len(text) > 0 and ord(text[0]) < 255:
        #        addr_int += 1
        #        text = text[1:]
                
        # strip 1-byte chars from the beginning
        while len(text) > 0 and is_sjis_single_byte(text[0]):
            addr_int += 1
            text = text[1:]

        # strip 1-byte chars from the end
        while len(text) > 0 and is_sjis_single_byte(text[-1]):
            text = text[:-1]
            
        if len(text)==0:
            continue
                
        if len(text)>=5 and has_no_kanas(text):
            # prolly not text
            print("skipped control line: " + text)
            continue
        
        jap_map[addr_int] = len(text) - math.ceil(count_one_byte_chars(text)/2)
        
        if KANA_1_BYTE:
            jap_map[addr_int] = get_length_with_kana_as_1_byte(text)
        if INJECT_ASCII:
            jap_map[addr_int] = 2* len(text) - math.ceil(count_one_byte_chars(text)/2)
            
    f_jap.close()

    # 2. Open Files for processing
    f_eng = open(eng_path, 'r', encoding='utf-8')
    f_rom = open(rom_path, 'r+b')

    # 3. Process English text and inject
    for line in f_eng:
        if line.startswith(";"):  # comment
            continue
        
        parts = line.strip().split(' ', 1)
        if len(parts) < 2:
            continue

        addr_str = parts[0]
        try:
            addr_int = int(addr_str, 16)
        except:
            continue
        
        eng_text = parts[1]

        # Match against processed Japanese addresses
        if not addr_int in jap_map:
            # try 1byte shifted address
            addr_int += 1
        # try 2nd formatting char
        if not addr_int in jap_map:
            addr_int += 1
        if not addr_int in jap_map:
            print(f"Skip: Address {addr_str} not found in {jap_path} logic")
            continue
        
        # replace some chars to save space
        eng_text = eng_text.replace("...", "…")
        eng_text = eng_text.replace("..", "…")
        eng_text = eng_text.replace(":", "：")
        eng_text = eng_text.replace(";", "；")
        eng_text = eng_text.replace(",", "、")
        eng_text = eng_text.replace("-", "ー")
        eng_text = eng_text.replace("—", "ー")
        eng_text = eng_text.replace("?", "？")
        eng_text = eng_text.replace("!", "！")
        eng_text = eng_text.replace("~", "〜")
        #eng_text = eng_text.replace(" ", "　")  # double-width space
        #eng_text = eng_text.replace(", ", ",")
        
        target_char_len = jap_map[addr_int]

        # Adjust character length (Truncate)
        if len(eng_text) >= (target_char_len) and ABBREVIATE:
            eng_text = abbreviate(eng_text, target_char_len)
            print("abbreviated: " + eng_text)
        if len(eng_text) >= (target_char_len):
            eng_text = eng_text[:target_char_len ]
            print("truncated: " + str(eng_text))
            
        # convert to uppercase if requsted
        if UPPERCASE:
            eng_text = eng_text.upper()
            
        if INJECT_ASCII:
            # 1. Word Wrap / Line Splitting
            import textwrap
            # Wrap text to the specified length
            wrapped_lines = textwrap.wrap(eng_text, width=INJECT_ASCII_LINE_SPLIT_LEN)
            
            # Enforce Max Line Count
            if len(wrapped_lines) > INJECT_ASCII_MAX_LINES_COUNT:
                truncated_lines = " ".join(wrapped_lines[INJECT_ASCII_MAX_LINES_COUNT:])
                print(f"!!! LINE LIMIT REACHED at {addr_str}: Discarded -> '{truncated_lines}'")
                wrapped_lines = wrapped_lines[:INJECT_ASCII_MAX_LINES_COUNT]
                
            # 2. Join lines with the Newline Value (e.g., 0x0A)
            # We convert the hex value to a character
            newline_char = chr(INJECT_ASCII_NEWLINE_VALUE)
            fw_text = newline_char.join(wrapped_lines)
            
            # 3. Handle Length and Termination
            # In ASCII mode, target_char_len likely refers to total available bytes.
            # We must leave 1 byte for the END_VALUE (0x00)
            max_bytes = target_char_len 
            
            # Convert to bytes immediately to check length
            out_bytes = fw_text.encode('ascii', errors='ignore')
            
            # Truncate if it exceeds space (leaving room for null terminator)
            if len(out_bytes) > (max_bytes - 1):
                out_bytes = out_bytes[:max_bytes - 1]
            
            # Add the End Value (Null terminator)
            out_bytes += bytes([INJECT_ASCII_END_VALUE])
            
            # 4. Padding
            # Fill the remaining space in the ROM block with 0x00 (or spaces)
            if len(out_bytes) < max_bytes:
                out_bytes = out_bytes.ljust(max_bytes, b'\x00')
                #out_bytes = out_bytes.ljust(max_bytes, bytes([INJECT_ASCII_NEWLINE_VALUE]))
        else:
            # convert to SJIS Fullwidth
            fw_text = to_fullwidth(eng_text)
        
        # Pad with Spaces
        if INJECT_ASCII:
            #fw_text = fw_text.ljust(target_char_len, chr(0x3000))
            fw_text = fw_text.ljust(target_char_len, chr(0x20))
        else:
            fw_text = fw_text.ljust(target_char_len, chr(0x3000))

        if not TBL_FILE:
            # Convert resulting string to Shift-JIS bytes
            # Fullwidth characters in S-JIS are 2 bytes each
            try:
                #out_bytes = fw_text.encode('shift_jis')
                out_bytes = fw_text.encode('cp932')  # ascii-compatible
            except UnicodeEncodeError:
                print(f"Error: Could not encode text at {addr_str} to S-JIS")
        else:
            out_bytes = encode_with_tbl(eng_text, TBL_FILE)
            # TODO: fill with spaces

        # Write to ROM
        f_rom.seek(addr_int)
        f_rom.write(out_bytes)
    #end for
    
    print(f"replaced: {hex(addr_int)} | Chars: {target_char_len} | {eng_text}")

    f_eng.close()
    f_rom.close()


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="ROM Injector for Japanese Translations")
    
    # Positional Arguments
    parser.add_argument("jap_txt", help="Path to the Japanese strings (UTF-8)")
    parser.add_argument("eng_txt", help="Path to the English strings (UTF-8)")
    parser.add_argument("rom", help="Path to rom file (.ext)")

    # Optional Flags
    
    parser.add_argument("--no-abbreviate", action="store_true", help="Disable replacement text abbreviation if it does not fit")
    parser.add_argument("--tbl-file", help="Table file to use to generate the replacement bytes")
    parser.add_argument("--kana-1-byte", action="store_true", help="Count kanas as 1-byte for string truncation")
    parser.add_argument("--uppercase", action="store_true", help="Convert replacement text into uppecase")
    parser.add_argument("--ascii-mode", action="store_true", help="Enable 1-byte ASCII injection mode")
    #parser.add_argument("--ascii-width", type=int, default=14, help="Wrap width for ASCII mode (default: 14)")
    #parser.add_argument("--ascii-max-lines", type=int, default=3, help="Max lines for ASCII mode (default: 3)")
    parser.add_argument("--ascii-newline", type=lambda x: int(x, 0), default=0x0A, help="Hex value for newline (default: 0x0A)")
    #parser.add_argument("--ascii-end-val", type=int, default=0x00, help="Hex value for string end (default: 0x00)")

    args = parser.parse_args()
    
    if args.kana_1_byte:
        KANA_1_BYTE=True
        
    if args.ascii_mode:
        INJECT_ASCII=True
        
    INJECT_ASCII_NEWLINE_VALUE=args.ascii_newline
    
    if args.no_abbreviate:
        ABBREVIATE=False
        
    if args.uppercase:
        UPPERCASE=True
    
    if args.tbl_file:
        TBL_FILE=args.tbl_file

    run_injection(args.jap_txt, args.eng_txt, args.rom)
    
    