#!/bin/sh
'''exec' "$HOME/.local/share/pipx/venvs/ndspy/bin/python" "$0" "$@"
'''


import argparse
import sys
import os
import ndspy.rom

def main():
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(
        description="Replace a file inside a Nintendo DS ROM using ndspy."
    )
    parser.add_argument("input", help="Path to the input .nds ROM file")
    parser.add_argument("file_to_replace", help="Internal filename/path to replace (e.g., 'sound_data.sdat')")
    parser.add_argument("replacement_file", help="Path to the new file on your computer to inject")
    parser.add_argument("-o", "--output", help="Path to save the output ROM (optional)")

    args = parser.parse_args()

    if args.output:
        output_path = args.output
    else:
        # Default behavior: append '_edited' to the original filename
        base, ext = os.path.splitext(args.input)
        output_path = f"{base}_edited{ext}"

    print(f"[*] Loading ROM: {args.input}...")
    try:
        rom = ndspy.rom.NintendoDSRom.fromFile(args.input)
    except FileNotFoundError:
        print(f"[!] Error: ROM file '{args.input}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"[!] Error loading ROM: {e}")
        sys.exit(1)

    print(f"[*] Reading replacement file: {args.replacement_file}...")
    try:
        with open(args.replacement_file, 'rb') as f:
            replacement_data = f.read()
    except FileNotFoundError:
        print(f"[!] Error: Replacement file '{args.replacement_file}' not found.")
        sys.exit(1)

    print(f"[*] Replacing internal file '{args.file_to_replace}'...")
    try:
        rom.setFileByName(args.file_to_replace, replacement_data)
    except Exception as e:
        # Fallback method just in case the version of ndspy being used 
        # relies on the filename ID mapping directly.
        try:
            file_id = rom.filenames.idOf(args.file_to_replace)
            rom.files[file_id] = replacement_data
        except ValueError:
            print(f"[!] Error: The file '{args.file_to_replace}' was not found inside the ROM.")
            sys.exit(1)
        except Exception as fallback_err:
             print(f"[!] Error replacing file: {fallback_err}")
             sys.exit(1)

    print(f"[*] Saving edited ROM to: {output_path}...")
    try:
        rom.saveToFile(output_path)
    except Exception as e:
        print(f"[!] Error saving ROM: {e}")
        sys.exit(1)

    print("[+] Done!")

if __name__ == "__main__":
    main()