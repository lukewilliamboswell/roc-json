## Represents either a value, a missing field, or a null field
## Normally you would only need `Option` but this type exists for use with APIs that
## make a distinction between a json field being `null` and being missing altogether
##
## Ensure you set `null_as_undefined` and `empty_encode_as_null` to false in your json_options
## eg: `core.json_with_options { empty_encode_as_null: Bool.false, null_as_undefined: Bool.false }`
module [OptionOrNull, none, null, some, get, get_result, from]

import Json

OptionOrNull val := [Some val, None, Null]
    implements [
        Eq,
        Decoding {
            decoder: decoder_res,
        },
        Encoding {
            to_encoder: to_encoder_res,
        },
    ]

## Missing field
none = |{}| @OptionOrNull(None)
## Null
null = |{}| @OptionOrNull(Null)
## Some value
some = |val| @OptionOrNull(Some(val))

## Get option internals.
## For access to convinence methods and error accumulation you may want `Option.get_result`
get = |@OptionOrNull(val)| val

## Option as a result
get_result = |@OptionOrNull(val)|
    when val is
        Some(v) -> Ok(v)
        e -> Err(e)

from = |val| @OptionOrNull(val)

null_chars = "null" |> Str.to_utf8

to_encoder_res = |@OptionOrNull(val)|
    Encode.custom(
        |bytes, fmt|
            when val is
                Some(contents) -> bytes |> Encode.append(contents, fmt)
                None -> bytes
                Null -> bytes |> List.concat(null_chars),
    )

decoder_res = Decode.custom(
    |bytes, fmt|
        when bytes is
            [] -> { result: Ok(none({})), rest: [] }
            ['n', 'u', 'l', 'l', .. as rest] -> { result: Ok(null({})), rest: rest }
            _ ->
                when bytes |> Decode.decode_with(Decode.decoder, fmt) is
                    { result: Ok(res), rest } -> { result: Ok(some(res)), rest }
                    { result: Err(a), rest } -> { result: Err(a), rest },
)

## Used to indicate to roc highlighting that a string is json
json = |a| a

OptionTest : { name : OptionOrNull Str, last_name : OptionOrNull Str, age : U8 }
expect
    decoded : Result OptionTest _
    decoded =
        """
        {"name":null,"age":1}
        """
        |> json
        |> Str.to_utf8
        |> Decode.from_bytes(Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.false }), null_decode_as_empty: Bool.false }))

    expected = Ok({ age: 1u8, name: null({}), last_name: none({}) })
    expected == decoded

# Encode Option None record with null
expect
    encoded =
        dat : OptionTest
        dat = { last_name: none({}), name: null({}), age: 1 }
        dat
        |> Encode.to_bytes(Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.false }) }))
        |> Str.from_utf8

    expected =
        """
        {"age":1,"name":null}
        """
        |> json
        |> Ok
    expected == encoded
