BeginPackage["JerryI`Terakitchen`Services`FileNames`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`WLX`",
    "JerryI`WLX`Importer`",
    "JerryI`WLX`WebUI`"
}]



Needs["JerryI`Terakitchen`Process`" -> "jtp`", FileNameJoin[{"Modules", "Process.wl"}] ]
Needs["JerryI`Terakitchen`Utils`Filenames`" -> "jtuf`", FileNameJoin[{"Utils", "Filenames", "Filenames.wl"}] ]

Begin["`Private`"]

root = $InputFileName // DirectoryName;
common = FileNameJoin[{$InputFileName // DirectoryName // ParentDirectory // ParentDirectory // ParentDirectory, "Common"}];

template = ImportComponent[FileNameJoin[{root, "Template.wlx"}] ];

forward[process_, props_] := With[{

},
    With[{result = jtuf`formPairs[process["Files"], process["Connections"] ]},
        process["ValidQ"] = False;
        EventFire[process["Promise"], Resolve, Join[props, <|"Files" -> result|>] ];
        Delete[process];
    ]
]

createView[process_][props_] :=  With[{event = CreateUUID[]}, With[{
    Widget = jtuf`refWidget[process["Files"], process["Connections"] ],
    controls = props["GlobalControls"],
    cli = props["Client"]
},
    EventHandler[controls, {
        "Continue" -> Function[Null,

            EventFire[controls, "StartLoader", True];
            process["Connections"] = Widget["Get"];
            forward[process, props];
            Widget["Destroy"];
            EventFire[controls, "Destroy", True];
        ]
    }];

    Widget["View"]
] ]

sortFileNames = jtuf`sortFileNames;

loadFiles[files_List] := With[{
    p = jtp`processObject["Title" -> "Names decoder", "NeedsButton" -> True, "State" -> "Check pairs of reference and sample", "NeedsWindow"->True ]
},
    If[Length[files] == 0, 
        EventFire[p["Promise"], Reject, "Files are missing"];
    ];

    p["Files"] = jtuf`groupFilesByTags[files];
    p["Connections"] = jtuf`generateConnections[p["Files"] ];

    p["View"] = createView[p];

    p
]

Options[loadFiles] = {"WorkingDirectory"->Directory[]}

End[]
EndPackage[]

{JerryI`Terakitchen`Services`FileNames`Private`loadFiles, JerryI`Terakitchen`Services`FileNames`Private`sortFileNames}

