## Represents either a value, or nothing
## If you need to distinguish between a missing field and a `null` field you should use `OptionOrNull`
module [Option, none, some, get, get_result, from, from_result]

import Json

Option val := [Some val, None]
    implements [
        Eq,
        Decoding {
            decoder: decoder_res,
        },
        Encoding {
            to_encoder: to_encoder_res,
        },
    ]
## Missing or null
none = |{}| @Option(None)
## A value
some = |val| @Option(Some(val))
get = |@Option(val)| val
get_result = |@Option(val)| val
## use like `Option.from(Ok(val))`
from = |val| @Option(val)
## Convert a result with any `Err` to an Option
from_result : Result a * -> _
from_result = |val|
    when val is
        Ok(a) -> some(a)
        Err(_) -> none({})

to_encoder_res = |@Option(val)|
    Encode.custom(
        |bytes, fmt|
            when val is
                Some(contents) -> bytes |> Encode.append(contents, fmt)
                None -> bytes,
    )

decoder_res = Decode.custom(
    |bytes, fmt|
        when bytes is
            [] -> { result: Ok(none({})), rest: [] }
            _ ->
                when bytes |> Decode.decode_with(Decode.decoder, fmt) is
                    { result: Ok(res), rest } -> { result: Ok(some(res)), rest }
                    { result: Err(a), rest } -> { result: Err(a), rest },
)

## Used to indicate to roc highlighting that a string is json
json = |a| a

OptionTest : { name : Str, last_name : Option Str, age : Option U8 }
expect
    decoded : Result OptionTest _
    decoded =
        """
        { "age":1, "name":"hi" }
        """
        |> json
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8)

    expected = Ok({ name: "hi", last_name: none({}), age: some(1u8) })
    expected == decoded

expect
    decoded : Result OptionTest _
    decoded =
        """
        { "age":1, "name":"hi", "lastName":null }
        """
        |> json
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8)

    expected = Ok({ name: "hi", last_name: none({}), age: some(1u8) })
    expected == decoded

# TODO restore these tests
# expect
#     to_encode : OptionTest
#     to_encode =
#         { name: "hi", last_name: none({}), age: some(1u8) }
#     encoded =
#         to_encode
#         |> Encode.to_bytes(Json.utf8)
#         |> Str.from_utf8

#     expected =
#         """
#         { "age":1, "name":"hi", "last_name": null }
#         """
#         |> json
#         |> Ok
#     expected == encoded

# expect
#     to_encode : OptionTest
#     to_encode =
#         { name: "hi", last_name: none({}), age: some(1u8) }
#     encoded =
#         to_encode
#         |> Encode.to_bytes(Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.false }) }))
#         |> Str.from_utf8

#     expected =
#         """
#         { "age":1, "name":"hi" }
#         """
#         |> json
#         |> Ok
#     expected == encoded
