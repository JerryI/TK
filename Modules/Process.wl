BeginPackage["JerryI`Terakitchen`Process`", {
    "KirillBelov`Objects`",
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`"
}]

processObject;

Begin["`Private`"]

CreateType[processObject, init, {
    "Title" -> "Generic",
    "State" -> "Unknown",
    "Progress" -> 0.0,
    "NeedsButton" -> True,
    "NeedsWindow" -> False,
    "View" -> (Null&)
}]

init[p_] := (
    p["Promise"] = Promise[];
    p["ValidQ"] = True;
    p
)

End[]

EndPackage[]