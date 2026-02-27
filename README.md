
# ezrominject

Simple tool for in-place Shift-JIS text injection, compatible with many games.

It is designed to be used together with [jstrings](https://github.com/drojaazu/jstrings) as a text extractor.

The main limitation is that it cannot rewrite pointers: translated lines must not exceed the original length, longer strings will be truncated to fit.

This makes it suitable for:

 - Menu translations
 - Games with little text

Not compatible with:

 - Games using custom encodings or compressed text
 - Games whose fonts do not include Latin characters
 - Text stored as bitmap graphics or textures


## [Usage](https://github.com/eadmaster/ezrominject/wiki/Usage)

## [FAQs](https://github.com/eadmaster/ezrominject/wiki/FAQs)
