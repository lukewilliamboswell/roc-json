app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json

DynamicJson : { type : Str, value : Str }
Dynamic : { value : [String(Str), Number(U64)] }

dynamic_json =
    """
    [
        {
            "type": "String",
            "value": { "s": "a text value" }
        },
        {
            "type": "Number",
            "value": { "n": 42 }
        }
    ]
    """
    |> Str.to_utf8

decode_dynamic : List U8 -> Result (List Dynamic) DecodeError
decode_dynamic = |bytes|
    decoded : DecodeResult (List DynamicJson)
    decoded = Decode.from_bytes_partial(bytes, Json.utf8)
    decoded.result
    |> Result.map_ok(
        |dyn_list|
            List.keep_oks(
                dyn_list,
                |dynamic|
                    when dynamic.type is
                        "String" ->
                            dynamic.value
                            |> Str.to_utf8
                            |> Decode.from_bytes(Json.utf8)
                            |> Result.map_ok(|val| { value: String(val.s) })

                        "Number" ->
                            dynamic.value
                            |> Str.to_utf8
                            |> Decode.from_bytes(Json.utf8)
                            |> Result.map_ok(|val| { value: Number(val.n) })

                        _ ->
                            Err(UnknownType),
            ),
    )

main! = |_args|
    when decode_dynamic(dynamic_json) is
        Ok(list) ->
            List.for_each_try!(list, |item|
                when item.value is
                    String(val) ->
                        Stdout.line!("String: ${val}")

                    Number(val) ->
                        Stdout.line!("Number: ${Num.to_str(val)}")
            )
        Err(_) ->
            Stdout.line!("Error decoding JSON")
