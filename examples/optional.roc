app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/bi5zubJ-_Hva9vxxPq4kNx4WHX6oFs8OP6Ad0tCYlrY.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json
import json.OptionOrNull exposing [OptionOrNull]

Object : { first_name : Str, last_name : OptionOrNull Str }

main! = |_args|
    none_obj : Object
    none_obj = { first_name: "Luke", last_name: OptionOrNull.none({}) }
    null_obj : Object
    null_obj = { first_name: "Luke", last_name: OptionOrNull.null({}) }
    some_obj : Object
    some_obj = { first_name: "Luke", last_name: OptionOrNull.some("Boswell") }

    # noneJson == {"first_name":"Luke",}
    none_json = Encode.to_bytes(none_obj, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.false }) }))
    try(Stdout.line!((none_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON"))))

    # nullNoneJson == {"first_name":"Luke","last_name":null}
    null_none_json = Encode.to_bytes(none_obj, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.true }) }))
    try(Stdout.line!((null_none_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON"))))

    # nullJson == {"first_name":"Luke","last_name":null}
    null_json = Encode.to_bytes(null_obj, Json.utf8)
    try(Stdout.line!((null_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON"))))

    # someJson == {"first_name":"Luke","last_name":"Boswell"}
    some_json = Encode.to_bytes(some_obj, Json.utf8)
    try(Stdout.line!((some_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON"))))

    Ok({})
