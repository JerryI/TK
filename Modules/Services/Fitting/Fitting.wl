BeginPackage["JerryI`Terakitchen`Services`Fitting`", {
    "CoffeeLiqueur`Misc`Events`",
    "CoffeeLiqueur`Misc`Language`",
    "CoffeeLiqueur`Misc`Async`",
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
    "JerryI`TDSTools`Material`",
    "CoffeeLiqueur`Extensions`Graphics`"
}]



Begin["`Private`"]

Needs["JerryI`Terakitchen`Process`" -> "jtp`", FileNameJoin[{"Modules", "Process.wl"}] ]

root = $InputFileName // DirectoryName;
common = FileNameJoin[{$InputFileName // DirectoryName // ParentDirectory // ParentDirectory // ParentDirectory, "Common"}];

Needs["JerryI`Terakitchen`Services`Fitting`Proto`" -> "proto`", FileNameJoin[{root, "Proto.wl"}] ]


forward[process_, props_] := 
    With[{},
        process["ValidQ"] = False;
        EventFire[process["Promise"], Resolve, <|"Files" -> {process["File"]}|> ];
        Delete[process];
    ]


createView[process_][props_] :=  Module[{}, With[{}, With[{
    controls = props["GlobalControls"],
    cli = props["Client"]
},

    With[{w = proto`widget[process["File"] ]},
        EventHandler[controls, {
            "Continue" -> Function[Null,

                (* With[{i = index},  *)
                    (* process["Files"] = ReplacePart[process["Files"], i -> w["Get"] ]; *)
                (* ]; *)

                (* index++; *)
                process["File"] = w["Get"];
                w["Destroy"];
                
                forward[process, {}];   
                EventFire[controls, "Destroy", True]; 
            ]
        }];   

        w["View"] 
    ]
    
] ] ]

fittingService[files_List, path_] := Module[{object}, With[{
    p = jtp`processObject["Title" -> "Fitting wizard", "NeedsButton" -> True, "State" -> "Use time-domain or frequency-domain to fit the response", "NeedsWindow"->True ]
},
    If[Length[files] == 0, 
        EventFire[p["Promise"], Reject, "Files are missing"];
    ];

    object = files[[1]];

    If[!KeyExistsQ[object["Tags"], "Traces"], Module[{sam, ref},
      {sam, ref} = Import[FileNameJoin[{path, #}] ] &/@ object["Tags"]["Filename"];
      sam = TDTrace[QuantityArray[Drop[sam,1], {"Picoseconds", 1}] ];
      ref = TDTrace[QuantityArray[Drop[ref,1], {"Picoseconds", 1}] ];
      object = Append[object, "Tags"->Join[object["Tags"], <|"Traces"->{sam, ref}|>] ];
    ] ];

    p["Path"] = path;
    p["File"] = object;

    p["View"] = createView[p];
    p["ValidQ"] = True;

    p
] ]

Options[fittingService] = {"WorkingDirectory"->Directory[]}


End[]
EndPackage[]


JerryI`Terakitchen`Services`Fitting`Private`fittingService