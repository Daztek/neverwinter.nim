import shared
import neverwinter/compressedbuf

let args = DOC """
De/compress a blob in the same way the game handles NWCompressedBuf data.

<magic> is a 4 byte string (e.g. "SQL3").

Input and output default to stdin/stdout respectively.

Usage:
  $0 [options] -c <magic> [-a <alg>]
  $0 [options] -d <magic>
  $USAGE

Options:
  -c                          Compress IN, expect <magic> or error
  -a --alg ALG                Algorithm to use for compression (one of """ & SupportedAlgorithms & """) [default: zstd]

  -d                          Decompress IN, expect <magic> or error

  -i IN                       Input file [default: -]
  -o OUT                      Output file [default: -]

  $OPT
"""

# Always fully read input file.
let input  = if $args["-i"] == "-":
  newStringStream(stdin.readAll())
else:
  newStringStream(readFile($args["-i"]))

let output = if $args["-o"] == "-": newFileStream(stdout) else: openFileStream($args["-o"], fmWrite)

let alg = parseEnum[Algorithm](($args["--alg"]).capitalizeAscii)
let magic = makeMagic($args["<magic>"])

if args["-c"]:
  compress(output, input, alg, magic)

elif args["-d"]:
  output.write(decompress(input, magic))
