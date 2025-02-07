BeginPackage["JerryI`Terakitchen`Services`Material`", {
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
    "JerryI`TDSTools`Material`",
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

createView[process_][props_] :=  Module[{index = 1}, With[{}, With[{
    controls = props["GlobalControls"],
    cli = props["Client"]
},

    With[{w = widget[process["Files"][[index]] ]},
        EventHandler[controls, {
            "Continue" -> Function[Null,

                With[{i = index}, 
                    process["Files"] = ReplacePart[process["Files"], i -> w["Get"] ];
                ];

                index++;
                EventFire[controls, "StartLoader", True];

                If[index > Length[process["Files"] ], 
                    w["Destroy"];
                    forward[process, props];   
                    EventFire[controls, "Destroy", True]; 
                ,
                    w["Next"][process["Files"][[index]]];
                    EventFire[controls, "StopLoader", True];
                ];
            ]
        }];   

        w["View"] 
    ]
    
] ] ]

materialParameters[files_List] := With[{
    p = jtp`processObject["Title" -> "Material parameters", "NeedsButton" -> True, "State" -> "Check the thickness and scaling", "NeedsWindow"->True ]
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

Options[materialParameters] = {"WorkingDirectory"->Directory[]}


End[]
EndPackage[]


JerryI`Terakitchen`Services`Material`Private`materialParameters