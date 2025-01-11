app [main!] {
    # TODO restore with basic-cli release
    cli: platform "../../basic-cli/platform/main.roc",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json

main! = \_args ->
    bytes = Str.to_utf8("[ [ 123,\n\"apples\" ], [  456,  \"oranges\" ]]")

    decoded : Decode.DecodeResult (List FruitCount)
    decoded = Decode.from_bytes_partial(bytes, Json.utf8)

    when decoded.result is
        Ok(tuple) -> Stdout.line!("Successfully decoded tuple, got ${to_str(tuple)}")
        Err(_) -> crash("Error, failed to decode image")

FruitCount : (U32, Str)

to_str : List FruitCount -> Str
to_str = \fcs ->
    fcs
    |> List.map(\(count, fruit) -> "${fruit}:${Num.to_str(count)}")
    |> Str.join_with(", ")
