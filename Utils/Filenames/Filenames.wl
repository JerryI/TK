BeginPackage["JerryI`Terakitchen`Utils`Filenames`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`",
    "JerryI`Misc`Language`"
}]

groupFilesByTags;
generateConnections;
sortFileNames;
formPairs;
refWidget;

Begin["`Private`"]

Print["Loading neural net..."];

(* ELMo Contextual Word Representations Trained on 1B Word Benchmark *)
(* function by Vitaliy Kaurov *)
netNonContextual = Import[FileNameJoin[{$InputFileName // DirectoryName, "graph.wlnet"}] ];

groupFilesByTags[files_] := With[{groups = GroupBy[ <|"Tags" -> StringSplit[FileNameTake[#], "_"|"."], "Path"->#|> &/@ files, Function[item,
  If[Or @@ Map[StringMatchQ[#, ___~~("ref" | "hole" | "empty")~~___, IgnoreCase -> True]&, item["Tags"] ],
    "Reference", "Sample"
  ]
] ]},
  If[Length[groups["Reference"] ] === 0 ||  Length[groups["Sample"] ] === 0 || MissingQ[groups["Reference"] ] ||  MissingQ[groups["Sample"] ],
    <|"Reference" -> files, "Sample" -> Select[files, StringMatchQ[#, ___~~"sam"~~___, IgnoreCase -> True]& ]|>
  ,
    groups
  ]
];

sortFileNames[ l: List[__String] ] := With[{
  tag2vec = generator[(StringSplit[#, "_"|"."]& /@ l)  // Flatten // DeleteDuplicates]
},
  With[{
    tour = Drop[FindShortestTour[Map[Function[item, Total[tag2vec /@ ((StringSplit[item, "_"|"."]))] ], l] ][[2]], 1]
  },
    RotateLeft[tour,  - Position[tour, 1]//First ] // Reverse
  ]
  
]


generator[words_] := With[{},
  Quiet[netNonContextual[words] ]; (* THIS is a fucking bug of NeuralNet package *)
  AssociationThread[words->netNonContextual[words][[All,1]]]
]

generateConnections[base_Association] := With[{
  tag2vec = generator[base[[All,All, "Tags"]] // Values // Flatten // DeleteDuplicates]
},
  Table[With[{
     s = Total /@ Table[ 
        (*FB[*)((1.0)(*,*)/(*,*)(1.0 + Norm[tag2vec[k] - tag2vec[l] ]))(*]FB*) 
      , {k, i["Tags"]}, {l, j["Tags"]}]
  }, 
    
    Exp[-Total[s]/100.0]
  ], {i, base["Sample"]}, {j, base["Reference"]}]
];

formPairs[base_, connections_] := Table[With[{ref = Ordering[connections[[i]]][[1]]},
  <|"Sample"->base[["Sample", i, "Path"]], "Reference" -> base[["Reference", ref, "Path"]]|>
], {i, base["Sample"]//Length}]

applyPatch[{x_, x_}] := {1.5 x, 0.9 x}
applyPatch[{x_, y_}] := {x, y}

refWidget[base_, c_, OptionsPattern[] ] := Module[{
  System`gridColors, connections, board,
  object
}, With[{

  minMax = applyPatch @ MinMax[c // Flatten],
  color = ColorData["BeachColors"],
  ls = base["Sample"]//Length,
  lr = base["Reference"]//Length,
  getColor = Function[{color, connect, minMax},
    List @@ (color[(connect - minMax[[1]]) / (minMax[[2]] - minMax[[1]])])
  ],

  offset = Max[StringLength /@ Normal[base[["Reference", All, "Path"]]]]/50.0,
  event = OptionValue["Event"]
},


  object["Destroy"] := ClearAll[board, connections, object];
  object["Get"] := connections;

  connections = c;

  System`gridColors = Table[
    getColor[color, connections[[i,j]], minMax]
  , {i, 1, ls}, {j, 1, lr}];
  
  object["View"] = Graphics[{    
    board = Table[With[{i=i, j=j}, {
      RGBColor[System`gridColors[[i]][[j]]] // Offload,
      Rectangle[{i,j} - {0.4,0.4}, {i,j} + {0.4,0.4}]
    }], {i, 1, ls}, {j, 1, lr}],

    Table[Text[StringReplace[FileBaseName[base[["Reference", i, "Path"]]], "_"->"_"], {0.5, i}, {1,0}], {i, 1, lr}],

    Table[Rotate[Text[StringReplace[FileBaseName[base[["Sample", i, "Path"]]], "_"->"_"], {i, lr + 0.5}, {1,0}], 90Degree, {i, lr + 0.5}], {i, 1, ls}],

    EventHandler[Null, {
      "click" -> Function[xy,
        Do[
          If[RegionMember[board[[i,j,2]], xy], 
            connections[[i,j]] = If[
              connections[[i,j]] > Mean[minMax], 
                minMax[[1]], 
                minMax[[2]]
            ];   
            
            System`gridColors = Table[
              getColor[color, connections[[ii,jj]], minMax]
            , {ii, 1, ls}, {jj, 1, lr}];

            Break[];
          ];
        , {i, 1, ls}, {j, 1, lr}]        
      ]
    }]
  }, "GUI"->False, ImageSize->OptionValue[ImageSize], PlotRange->{{-2, ls + 1}, {-1, lr + 2}}];

  object

] ]

Options[refWidget] = {ImageSize->{500,500}, "Event":>CreateUUID[]}

End[]
EndPackage[]