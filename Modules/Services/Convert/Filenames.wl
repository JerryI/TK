BeginPackage["JerryI`Terakitchen`Services`Convert`FileNames`", {
    "CoffeeLiqueur`Misc`Events`",
    "CoffeeLiqueur`Misc`Events`Promise`",
    "CoffeeLiqueur`WLX`",
    "CoffeeLiqueur`WLX`Importer`",
    "CoffeeLiqueur`WLX`WebUI`"
}]

Needs["JerryI`Terakitchen`Process`" -> "jtp`", FileNameJoin[{"Modules", "Process.wl"}] ]
Needs["JerryI`Terakitchen`Utils`Filenames`" -> "jtuf`", FileNameJoin[{"Utils", "Filenames", "Filenames.wl"}] ]

Begin["`Private`"]


groupFilesByTags[files_] := With[{groups = GroupBy[ <|"Tags" -> StringSplit[FileNameTake[#], "_"|"."], "Path"->#|> &/@ files, Function[item,
  If[Or @@ Map[StringMatchQ[#, ___~~("+45" | "180" )~~___, IgnoreCase -> True]&, item["Tags"] ],
    "Reference", "Sample"
  ]
] ]},
  If[Length[groups["Reference"] ] === 0 ||  Length[groups["Sample"] ] === 0 || MissingQ[groups["Reference"] ] ||  MissingQ[groups["Sample"] ],
    <|"Reference" -> {}, "Sample" -> {}|>
  ,
    groups
  ]
];

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

loadFiles[files_List] := Module[{}, With[{
    p = jtp`processObject["Title" -> "Names decoder", "NeedsButton" -> True, "State" -> "Check pairs of +/- polarization", "NeedsWindow"->True ]
},
    If[Length[files] == 0, 
        EventFire[p["Promise"], Reject, "Files are missing"];
        Return[False, Module];
    ];

    p["Files"] = groupFilesByTags[files];
    
    If[p["Files"]["Sample"] == {} || p["Files"]["Reference"] == {},
        Return[False, Module];
    ];

    p["Connections"] = jtuf`generateConnections[p["Files"] ];

    p["View"] = createView[p];

    p
] ]

Options[loadFiles] = {"WorkingDirectory"->Directory[]}

End[]
EndPackage[]

JerryI`Terakitchen`Services`Convert`FileNames`Private`loadFiles

