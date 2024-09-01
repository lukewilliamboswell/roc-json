app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json

main =
    bytes = Str.toUtf8 "[ [ 123,\n\"apples\" ], [  456,  \"oranges\" ]]"

    decoded : Decode.DecodeResult (List FruitCount)
    decoded = Decode.fromBytesPartial bytes Json.utf8

    when decoded.result is
        Ok tuple -> Stdout.line! "Successfully decoded tuple, got $(toStr tuple)"
        Err _ -> crash "Error, failed to decode image"

FruitCount : (U32, Str)

toStr : List FruitCount -> Str
toStr = \fcs ->
    fcs
    |> List.map \(count, fruit) -> "$(fruit):$(Num.toStr count)"
    |> Str.joinWith ", "
