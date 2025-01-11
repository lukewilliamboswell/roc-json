module [Json, utf8]

expect
    input : List U8
    input = Str.to_utf8("{\"first_segment\":\"ab\"}")

    actual : DecodeResult { first_segment : Str }
    actual = Decode.from_bytes_partial(input, @Json({}))

    expected : DecodeResult { first_segment : Str }
    expected = { rest: [], result: Ok({ first_segment: "ab" }) }

    actual == expected

## An opaque type with the `Encode.EncoderFormatting` and
## `DecoderFormatting` abilities.
Json := { field_name_mapping : FieldNameMapping, skip_missing_properties : Bool, null_decode_as_empty : Bool, empty_encode_as_null : EncodeAsNull }
    implements [
        Encode.EncoderFormatting {
            u8: encode_u8,
            u16: encode_u16,
            u32: encode_u32,
            u64: encode_u64,
            u128: encode_u128,
            i8: encode_i8,
            i16: encode_i16,
            i32: encode_i32,
            i64: encode_i64,
            i128: encode_i128,
            f32: encode_f32,
            f64: encode_f64,
            dec: encode_dec,
            bool: encode_bool,
            string: encode_string,
            list: encode_list,
            record: encode_record,
            tuple: encode_tuple,
            tag: encode_tag,
        },
        DecoderFormatting {
            u8: decode_u8,
            u16: decode_u16,
            u32: decode_u32,
            u64: decode_u64,
            u128: decode_u128,
            i8: decode_i8,
            i16: decode_i16,
            i32: decode_i32,
            i64: decode_i64,
            i128: decode_i128,
            f32: decode_f32,
            f64: decode_f64,
            dec: decode_dec,
            bool: decode_bool,
            string: decode_string,
            list: decode_list,
            record: decode_record,
            tuple: decode_tuple,
        },
    ]

## Returns a JSON `Encode.Encoder` and `Decoder`
utf8 = @Json({ field_name_mapping: Default, skip_missing_properties: Bool.true, null_decode_as_empty: Bool.true, empty_encode_as_null: default_encode_as_null })

EncodeAsNull : {
    list : Bool,
    tuple : Bool,
    record : Bool,
}

default_encode_as_null = {
    list: Bool.false,
    tuple: Bool.true,
    record: Bool.true,
}

## Mapping between Roc record fields and JSON object names
FieldNameMapping : [
    Default, # no transformation
    SnakeCase, # snake_case
    PascalCase, # PascalCase
    KebabCase, # kabab-case
    CamelCase, # camelCase
    Custom (Str -> Str), # provide a custom formatting
]

encode_u8 : U8 -> Encoder Json
encode_u8 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u16 : U16 -> Encoder Json
encode_u16 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u32 : U32 -> Encoder Json
encode_u32 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u64 : U64 -> Encoder Json
encode_u64 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u128 : U128 -> Encoder Json
encode_u128 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i8 : I8 -> Encoder Json
encode_i8 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i16 : I16 -> Encoder Json
encode_i16 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i32 : I32 -> Encoder Json
encode_i32 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i64 : I64 -> Encoder Json
encode_i64 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i128 : I128 -> Encoder Json
encode_i128 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_f32 : F32 -> Encoder Json
encode_f32 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_f64 : F64 -> Encoder Json
encode_f64 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_dec : Dec -> Encoder Json
encode_dec = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_bool : Bool -> Encoder Json
encode_bool = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_string : Str -> Encoder Json
encode_string = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_list : List elem, (elem -> Encoder Json) -> Encoder Json
encode_list = \_, _ -> Encode.custom(\bytes, _ -> bytes)

encode_record : List { key : Str, value : Encoder Json } -> Encoder Json
encode_record = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_tuple : List (Encoder Json) -> Encoder Json
encode_tuple = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_tag : Str, List (Encoder Json) -> Encoder Json
encode_tag = \_, _ -> Encode.custom(\bytes, _ -> bytes)

decode_u8 : Decoder U8 Json
decode_u8 = Decode.custom(\bytes, _ -> { result: Ok(1u8), rest: bytes })

decode_u16 : Decoder U16 Json
decode_u16 = Decode.custom(\bytes, _ -> { result: Ok(1u16), rest: bytes })

decode_u32 : Decoder U32 Json
decode_u32 = Decode.custom(\bytes, _ -> { result: Ok(1u32), rest: bytes })

decode_u64 : Decoder U64 Json
decode_u64 = Decode.custom(\bytes, _ -> { result: Ok(1u64), rest: bytes })

decode_u128 : Decoder U128 Json
decode_u128 = Decode.custom(\bytes, _ -> { result: Ok(1u128), rest: bytes })

decode_i8 : Decoder I8 Json
decode_i8 = Decode.custom(\bytes, _ -> { result: Ok(1i8), rest: bytes })

decode_i16 : Decoder I16 Json
decode_i16 = Decode.custom(\bytes, _ -> { result: Ok(1i16), rest: bytes })

decode_i32 : Decoder I32 Json
decode_i32 = Decode.custom(\bytes, _ -> { result: Ok(1i32), rest: bytes })

decode_i64 : Decoder I64 Json
decode_i64 = Decode.custom(\bytes, _ -> { result: Ok(1i64), rest: bytes })

decode_i128 : Decoder I128 Json
decode_i128 = Decode.custom(\bytes, _ -> { result: Ok(1i128), rest: bytes })

decode_f32 : Decoder F32 Json
decode_f32 = Decode.custom(\bytes, _ -> { result: Ok(1f32), rest: bytes })

decode_f64 : Decoder F64 Json
decode_f64 = Decode.custom(\bytes, _ -> { result: Ok(1f64), rest: bytes })

decode_dec : Decoder Dec Json
decode_dec = Decode.custom(\bytes, _ -> { result: Ok(1dec), rest: bytes })

decode_bool : Decoder Bool Json
decode_bool = Decode.custom(\bytes, _ -> { result: Ok(Bool.true), rest: bytes })

decode_tuple : state, (state, U64 -> [Next (Decoder state Json), TooLong]), (state -> Result val DecodeError) -> Decoder val Json where fmt implements DecoderFormatting
decode_tuple = \_, _, _ -> Decode.custom(\bytes, _ -> { result: Err(TooShort), rest: bytes })

decode_string : Decoder Str Json
decode_string = Decode.custom(\bytes, _ -> { result: Ok("1"), rest: bytes })

decode_list : Decoder elem Json -> Decoder (List elem) Json
decode_list = \_ -> Decode.custom(\bytes, _ -> { result: Err TooShort, rest: bytes })

decode_record : state, (state, Str -> [Keep (Decoder state Json), Skip]), (state, Json -> Result val DecodeError) -> Decoder val Json
decode_record = \_, _, _ -> Decode.custom(\bytes, _ -> { result: Err(TooShort), rest: bytes })
