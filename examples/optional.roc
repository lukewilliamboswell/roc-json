app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json
import json.OptionOrNull exposing [OptionOrNull]

Object : { first_name : Str, last_name : OptionOrNull Str }

main =
    none_obj : Object
    none_obj = { first_name: "Luke", last_name: OptionOrNull.none({}) }
    null_obj : Object
    null_obj = { first_name: "Luke", last_name: OptionOrNull.null({}) }
    some_obj : Object
    some_obj = { first_name: "Luke", last_name: OptionOrNull.some("Boswell") }

    # noneJson == {"firstName":"Luke",}
    none_json = Encode.to_bytes(none_obj, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.false }) }))
    Stdout.line!((none_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON")))

    # nullNoneJson == {"firstName":"Luke","lastName":null}
    null_none_json = Encode.to_bytes(none_obj, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.true }) }))
    Stdout.line!((null_none_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON")))

    # nullJson == {"firstName":"Luke","lastName":null}
    null_json = Encode.to_bytes(null_obj, Json.utf8)
    Stdout.line!((null_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON")))

    # someJson == {"firstName":"Luke","lastName":"Boswell"}
    some_json = Encode.to_bytes(some_obj, Json.utf8)
    Stdout.line((some_json |> Str.from_utf8 |> Result.with_default("Failed to encode JSON")))

