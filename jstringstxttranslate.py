#!/bin/sh
'''exec' "$HOME/.local/share/pipx/venvs/ctranslate2/bin/python" "$0" "$@"
'''

import sys
import os


#def translate_with_argos(line):
#	# https://argos-translate.readthedocs.io/en/latest/source/examples.html
#	import argostranslate
#	import argostranslate.package
#	import argostranslate.translate
#	from_code = "ja"
#	to_code = "en"
#	r = argostranslate.translate.translate(line, from_code, to_code)
#	if len(r)<=1:
#		# use gtranslate via https://github.com/soimort/translate-shell
#		shell_cmd = "trans -b -from ja -to en"
#		import subprocess
#		r = subprocess.check_output("trans -b -from ja -to en \"" + line + "\"", shell=True, text=True).strip()
#	return r


def translate_with_sugoi(line):
	# https://huggingface.co/entai2965/sugoi-v4-ja-en-ctranslate2
	import ctranslate2
	import sentencepiece

	#set defaults
	model_path='sugoi-v4-ja-en-ctranslate2'
	#model_path=os.path.expanduser('~/.cache/huggingface/hub/models--entai2965--sugoi-v4-ja-en-ctranslate2/snapshots/71d67eb8e73ec2f5aaefc0689e03a4eb843d3a2b')
	sentencepiece_model_path=model_path+'/spm'

	device='cpu'
	#device='cuda'

	#load data
	#string1='は静かに前へと歩み出た。'
	#string2='悲しいGPTと話したことがありますか?'
	#raw_list=[string1,string2]
	raw_list=[line]

	#load models
	translator = ctranslate2.Translator(model_path, device=device)
	tokenizer_for_source_language = sentencepiece.SentencePieceProcessor(sentencepiece_model_path+'/spm.ja.nopretok.model')
	tokenizer_for_target_language = sentencepiece.SentencePieceProcessor(sentencepiece_model_path+'/spm.en.nopretok.model')

	#tokenize batch
	tokenized_batch=[]
	for text in raw_list:
		tokenized_batch.append(tokenizer_for_source_language.encode(text,out_type=str))

	#translate
	#https://opennmt.net/CTranslate2/python/ctranslate2.Translator.html?#ctranslate2.Translator.translate_batch
	#translated_batch=translator.translate_batch(source=tokenized_batch,beam_size=1)  #faster  https://github.com/OpenNMT/CTranslate2/blob/master/docs/decoding.md#greedy-search
	translated_batch=translator.translate_batch(source=tokenized_batch,beam_size=5)  #disable_unk=True
	assert(len(raw_list)==len(translated_batch))

	#decode
	for count,tokens in enumerate(translated_batch):
		translated_batch[count]=tokenizer_for_target_language.decode(tokens.hypotheses[0]).replace('<unk>','')

	#output
	for text in translated_batch:
		#print(text)
		return text
    

def translate_with_sugoi_bulk(raw_list):
	# https://huggingface.co/entai2965/sugoi-v4-ja-en-ctranslate2
	import ctranslate2
	import sentencepiece

	#set defaults
	model_path='sugoi-v4-ja-en-ctranslate2'
	#model_path=os.path.expanduser('~/.cache/huggingface/hub/models--entai2965--sugoi-v4-ja-en-ctranslate2/snapshots/71d67eb8e73ec2f5aaefc0689e03a4eb843d3a2b')
	sentencepiece_model_path=model_path+'/spm'

	device='cpu'
	#device='cuda'

	#load models
	translator = ctranslate2.Translator(model_path, device=device)
	tokenizer_for_source_language = sentencepiece.SentencePieceProcessor(sentencepiece_model_path+'/spm.ja.nopretok.model')
	tokenizer_for_target_language = sentencepiece.SentencePieceProcessor(sentencepiece_model_path+'/spm.en.nopretok.model')

	#tokenize batch
	tokenized_batch=[]
	for text in raw_list:
		tokenized_batch.append(tokenizer_for_source_language.encode(text,out_type=str))

	#translate
	#https://opennmt.net/CTranslate2/python/ctranslate2.Translator.html?#ctranslate2.Translator.translate_batch
	#translated_batch=translator.translate_batch(source=tokenized_batch,beam_size=1)  #faster  https://github.com/OpenNMT/CTranslate2/blob/master/docs/decoding.md#greedy-search
	translated_batch=translator.translate_batch(source=tokenized_batch,beam_size=5)  #disable_unk=True
	assert(len(raw_list)==len(translated_batch))

	#decode
	for count,tokens in enumerate(translated_batch):
		translated_batch[count]=tokenizer_for_target_language.decode(tokens.hypotheses[0]).replace('<unk>','')
	
	return translated_batch
	
	
def translate_with_sugoi_bulk_shortest(raw_list):
    import ctranslate2
    import sentencepiece

    model_path=os.path.expanduser('~/.cache/huggingface/hub/models--entai2965--sugoi-v4-ja-en-ctranslate2/snapshots/71d67eb8e73ec2f5aaefc0689e03a4eb843d3a2b')
    sentencepiece_model_path=model_path+'/spm'
    device='cpu'

    translator = ctranslate2.Translator(model_path, device=device)
    tokenizer_for_source_language = sentencepiece.SentencePieceProcessor(sentencepiece_model_path+'/spm.ja.nopretok.model')
    tokenizer_for_target_language = sentencepiece.SentencePieceProcessor(sentencepiece_model_path+'/spm.en.nopretok.model')

    # Tokenize
    tokenized_batch = [tokenizer_for_source_language.encode(text, out_type=str) for text in raw_list]

    # Translate
    # num_hypotheses determines how many candidates are returned per source sentence
    # beam_size must be >= num_hypotheses
    results = translator.translate_batch(
        source=tokenized_batch, 
        beam_size=5, 
        num_hypotheses=5
    )

    final_translations = []

    # Decode and select shortest
    for result in results:
        # 1. Decode all candidates for this specific sentence
        candidates = [tokenizer_for_target_language.decode(h).replace('<unk>', '') for h in result.hypotheses]
        
        # 2. Pick the candidate with the minimum length (total characters)
        shortest = min(candidates, key=len)
        final_translations.append(shortest)
    
    return final_translations
    

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
        
        
	
def output_translated_file(input_file_str, output_file):
	
	curr_lines_list = []
	curr_addr_list = []
	BULK_SIZE = 100
	#BULK_SIZE = 1000  # takes too much RAM
	
	lines = input_file_str.splitlines()
	
	for i, line in enumerate(lines):
		if line.strip() == "" or line.startswith("#") or line.startswith(";"):
			# keep empty lines and comments
			output_file.write(line)
			continue
		
		try:
			address, text = line.split(" ", 1)
			addr_int = int(address, 16)
		except:
			# invalid address
			print("bad line:" + line)
			continue
			
		# Rule: If first char is single-byte ASCII, increment address and skip that char
		#if len(text) > 0 and ord(text[0]) < 255:
		#	addr_int += 1
		#	text = text[1:]
		#	# 2nd formatting char
		#	if len(text) > 0 and ord(text[0]) < 255:
		#		addr_int += 1
		#		text = text[1:]
		#	# 3rd formatting char
		#	if len(text) > 0 and ord(text[0]) < 255:
		#		addr_int += 1
		#		text = text[1:]
		#	# 4t formatting char
		#	if len(text) > 0 and ord(text[0]) < 255:
		#		addr_int += 1
		#		text = text[1:]
		#	#address = hex(addr_int)  # Convert back to hex string
		#	address = f"0x{addr_int:08x}"
        # end if
		
		# strip 1-byte chars from the beginning
		while len(text) > 0 and is_sjis_single_byte(text[0]):  # or ord(text[0])==0x88a1) # skip special 2-byte control code decoded as kanji
			addr_int += 1
			address = f"0x{addr_int:08x}"
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

		if (len(curr_lines_list) < BULK_SIZE) and (i != len(lines) - 2):  # bulk list is full or last line
			curr_lines_list.append(text)
			curr_addr_list.append(address)
		else:
			#translated_text = translate_with_argos(text)
			#translated_text = translate_with_sugoi(text)
			#translated_text_lines = translate_with_sugoi_bulk(curr_lines_list)  # normal translation
			translated_text_lines = translate_with_sugoi_bulk_shortest(curr_lines_list)
			for i, translated_line in enumerate(translated_text_lines):
				output_file.write("; " + curr_addr_list[i] + " " + curr_lines_list[i] + "\n")  # original line commented
				output_file.write(curr_addr_list[i] + " " + translated_line + "\n")  # translated line
				output_file.write("\n")  # empty line separator
			# endfor, empty buffers
			curr_lines_list.clear()
			curr_addr_list.clear()
		# end if
	# end for
	
	output_file.close()
# end of output_translated_file()


if __name__ == "__main__":
	import argparse, sys
	parser = argparse.ArgumentParser(description='translate jstrings txt dumps')
	parser.add_argument('infile', nargs='?', default="-", help="input file, defaults to stdin if unspecified. Supports passing urls.")
	parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'), default=sys.stdout, help="output file, defaults to stdout if unspecified")
	args = parser.parse_args()

	if args.infile == "-":
		infile = sys.stdin
		sys.stderr.write("reading from stdin...\n")
	elif args.infile.startswith(("http://", "ftp://", "https://")):  # TODO: proper URL validation
		from urllib.request import urlopen
		infile = urlopen(args.infile)
		# switch to text file mode
		infile = open(args.infile, encoding="utf-8", errors="ignore")
		#infile = codecs.getreader("utf-8")(infile)
	else:
		infile = open(args.infile)

	input_file_str = infile.read()
	
	output_translated_file(input_file_str, args.outfile)
