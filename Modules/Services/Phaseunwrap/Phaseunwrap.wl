BeginPackage["JerryI`Terakitchen`Services`PhaseUnwrap`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Language`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`WLX`",
    "JerryI`WLX`Importer`",
    "JerryI`WLX`WebUI`",
    "CoffeeLiqueur`Extensions`EditorView`",
    "JerryI`Misc`WLJS`Transport`",
    "CoffeeLiqueur`Extensions`InputsOutputs`",
    "CoffeeLiqueur`Extensions`Communication`",
    "JerryI`TDSTools`Trace`",
    "JerryI`TDSTools`Transmission`",
    "CoffeeLiqueur`Extensions`Graphics`"
}]


Needs["JerryI`Terakitchen`Process`" -> "jtp`", FileNameJoin[{"Modules", "Process.wl"}] ]

Begin["`Private`"]


root = $InputFileName // DirectoryName;
common = FileNameJoin[{$InputFileName // DirectoryName // ParentDirectory // ParentDirectory // ParentDirectory, "Common"}];


forward[process_, props_] := 
    With[{},
        process["ValidQ"] = False;
        EventFire[process["Promise"], Resolve, Join[props, <|"Files" -> process["Files"]|>] ];
        Delete[process];
    ]

widget = ImportComponent[FileNameJoin[{root, "Widget.wlx"}] ];

createView[process_][props_] :=  Module[{index = 1}, With[{event = CreateUUID[]}, With[{
    controls = props["GlobalControls"],
    cli = props["Client"],
    Widget = widget[process["Files"][[1]], process["Threshold"] ]
},
    EventHandler[controls, {
        "Continue" -> Function[Null,

            With[{
                i = index
            },
                process["Files"] = ReplacePart[process["Files"], i -> Widget["Get"] ];
            ];

            index++;

            EventFire[controls, "StartLoader", True];

            If[index > Length[process["Files"] ], 
                forward[process, props];
                Widget["Destroy"];
                EventFire[controls, "Destroy", True];
            ,
                Widget["NewMaterial"][process["Files"][[index]]];
                EventFire[controls, "StopLoader", True];
            ];
        ]
    }];

    Widget["View"]
    
] ] ]

unwrapPhase[files_List] := With[{
    p = jtp`processObject["Title" -> "Phase unwrapping", "NeedsButton" -> True, "State" -> "Check the threshold and fix phase jumps", "NeedsWindow"->True ]
},
    If[Length[files] == 0, 
        EventFire[p["Promise"], Reject, "Files are missing"];
    ];

    p["Files"] = files;
    p["View"] = createView[p];
    p["Threshold"] = 5.13;

    p["ValidQ"] = True;

    p
]

Options[unwrapPhase] = {"WorkingDirectory"->Directory[]}


End[]
EndPackage[]


JerryI`Terakitchen`Services`PhaseUnwrap`Private`unwrapPhase