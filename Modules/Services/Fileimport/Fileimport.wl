BeginPackage["JerryI`Terakitchen`Services`FileImporter`", {
    "CoffeeLiqueur`Misc`Events`",
    "CoffeeLiqueur`Misc`Language`",
    "CoffeeLiqueur`Misc`Events`Promise`",
    "CoffeeLiqueur`WLX`",
    "CoffeeLiqueur`WLX`Importer`",
    "CoffeeLiqueur`WLX`WebUI`",
    "CoffeeLiqueur`Extensions`EditorView`",
    "CoffeeLiqueur`Misc`WLJS`Transport`",
    "CoffeeLiqueur`Extensions`InputsOutputs`",
    "CoffeeLiqueur`Extensions`Communication`",
    "JerryI`TDSTools`Trace`",
    "JerryI`TDSTools`Transmission`",
    "CoffeeLiqueur`Extensions`System`"
}]


Needs["JerryI`Terakitchen`Process`" -> "jtp`", FileNameJoin[{"Modules", "Process.wl"}] ]

Begin["`Private`"]


root = $InputFileName // DirectoryName;
common = FileNameJoin[{$InputFileName // DirectoryName // ParentDirectory // ParentDirectory // ParentDirectory, "Common"}];

template = ImportComponent[FileNameJoin[{root, "Template.wlx"}] ];

parse[path_, opts_Association ] := With[{
    s =  Import[path, opts["Format"], HeaderLines->opts["Header"] ][[All, Take[ ToExpression/@Keys[ Select[ KeySortBy[opts["Cols"], ToExpression], #&] ], 2] ]]
},
    QuantityArray[Select[Drop[s, 0 ][[All, {1,2} ]], Function[test,
        NumericQ[test[[1]]] && NumericQ[test[[2]]]
    ] ], opts["Units"] ]
]

guessFormat[path_, l_Association ] := Module[{
    opts = l
},
    opts["Format"] = SelectFirst[
        Table[{o, MatchQ[First[ Drop[Import[path, o ], 10] ][[{1,2}]], {_?NumericQ, _?NumericQ}]}, {o, {"TSV", "CSV"}}]
    , #[[2]]&] // First // Quiet;

    opts["Header"] = SelectFirst[With[{i = Import[path, opts["Format"] ]},
        Table[{o, MatchQ[First[ Drop[i, o] ][[{1,2}]], {_?NumericQ, _?NumericQ}]}, {o, 0, 3}]
    ], #[[2]]&] // First // Quiet;

    opts
]

forward[process_, props_] := 
    With[{traces = Map[Function[pair,
        
        With[{
            s = TDTrace[ parse[pair["Sample"], process["ParsingOptions"] ], "PadZeros"->If[process["Padding"] == 0, None, process["Padding"] ] ],
            r = TDTrace[ parse[pair["Reference"], process["ParsingOptions"] ], "PadZeros"->If[process["Padding"] == 0, None, process["Padding"] ] ]
        },
            TransmissionObject[
                s,r,
                "Thickness" -> process["Thickness"],
                "Gain" -> process["Gain"],
                "Tags" -> <|
                    "Filename" -> {FileNameTake[pair["Sample"] ], FileNameTake[pair["Reference"] ]}, 
                    "Notes" -> process["Notes"],
                    "Traces" -> {s,r},
                    "Aperture" -> process["Aperture"],
                    "Sound" -> ListPlay[QuantityMagnitude[s["Trace"], {"Picoseconds", 1}][[All,2]], SampleRate->8000]
                |>
            ]
        ]

    ], process["Files"] ]},
        process["ValidQ"] = False;
        EventFire[process["Promise"], Resolve, Join[props, <|"Files" -> traces|>] ];
        Delete[process];
    ]

notValidQ[process_, props_] := With[{files = Join[process["Files"][[All, "Sample"]], process["Files"][[All, "Reference"]]]},
    SelectFirst[files, Function[f,
        !With[{q = QuantityMagnitude[parse[f, process["ParsingOptions"] ], {"Picoseconds", 1}]}, MatchQ[q, {{_?NumberQ, _?NumberQ}..}] && Length[q] > 100]
    ] ]
]

createView[process_][props_] :=  With[{event = CreateUUID[]}, With[{
    Widget = template[process["Files"][[1, "Sample"]], parse, process["ParsingOptions"] ],
    controls = props["GlobalControls"],
    cli = props["Client"]
},
    EventHandler[controls, {
        "Continue" -> Function[Null,



            EventFire[controls, "StartLoader", True];

            Function[new,
                process["ParsingOptions"] = new[[1]];
                process["Thickness"] = new[[2, "Thickness"]];
                process["Gain"] = new[[2, "Gain"]];
                process["Padding"] = new[[2, "Padding"]];
                process["Notes"] = Lookup[new[[2]], "Notes", ""];
                process["Aperture"] = new[[2, "Aperture"]];
            ] @ Widget["Get"];

            With[{v = notValidQ[process, props]},
                If[v =!= Missing["NotFound"], 
                    EventFire[controls, "StopLoader", True];
                    Then[ChoiceDialogAsync["Input data is not valid at "<>FileNameTake[v] ], Beep];
                    Return[];
                ];
            ];
            
            forward[process, props];
            Widget["Destroy"];
            EventFire[event, "Destroy", True];
            EventFire[controls, "Destroy", True];
        ]
    }];

    Widget["View"]
] ]

importFiles[files_List] := With[{
    p = jtp`processObject["Title" -> "Import wizard", "NeedsButton" -> True, "State" -> "Check units and select two columns", "NeedsWindow"->True ]
},
    If[Length[files] == 0, 
        EventFire[p["Promise"], Reject, "Files are missing"];
    ];

    p["Files"] = files;
    p["View"] = createView[p];
    p["Thickness"] = Quantity[1, "Millimeters"];
    p["Gain"] = 1.0;
    p["Padding"] = 0;
    p["Aperture"] = Quantity[2, "Millimeters"];
    p["ParsingOptions"] = guessFormat[files[[1, "Sample"]], <|"Format" -> "CSV", "Cols"-><|"1"->True, "2"->True|>, "Part" -> {1,2}, "Header" -> 1, "Units" -> {"Picoseconds", 1}|>];

    process["ValidQ"] = True;

    p
]

Options[importFiles] = {"WorkingDirectory"->Directory[]}


End[]
EndPackage[]


JerryI`Terakitchen`Services`FileImporter`Private`importFiles