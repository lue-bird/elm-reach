module VerifyExamples.Accessors.Library.Values0 exposing (..)

-- This file got generated by [elm-verify-examples](https://github.com/stoeffel/elm-verify-examples).
-- Please don't modify this file by hand!

import Test
import Expect

import Accessors.Library exposing (..)
import Dict exposing (Dict)
import Lens as L
import Accessors.Library exposing (..)
import Accessors exposing (..)



dictRecord : {foo : Dict String {bar : Int}}
dictRecord = { foo = [ ("a", { bar = 2 })
                     , ("b", { bar = 3 })
                     , ("c", { bar = 4 })
                     ] |> Dict.fromList
             }



spec0 : Test.Test
spec0 =
    Test.test "#values: \n\n    over (L.foo << values << L.bar) ((+) 1) dictRecord\n    --> {foo = [(\"a\", {bar = 3}), (\"b\", {bar = 4}), (\"c\", {bar = 5})] |> Dict.fromList}" <|
        \() ->
            Expect.equal
                (
                over (L.foo << values << L.bar) ((+) 1) dictRecord
                )
                (
                {foo = [("a", {bar = 3}), ("b", {bar = 4}), ("c", {bar = 5})] |> Dict.fromList}
                )